public class OpportunityAutoRenew {

   @future
   public static void CloneOpps(List<String> OppIdsToClone) {
      OppAutoRenewSetting__c RenewalDealRecordType = OppAutoRenewSetting__c.getInstance('Renewal Deal Record Type');
      
      List<Opportunity> ClonedOpps = new List<Opportunity>();
      Map<String,String> ClonedOppMap = new Map<String,String>();
      Map<String,String> OppTypes     = new Map<String,String>();

      for (Opportunity o : [SELECT Id,Name,AccountId,StageName,CloseDate,LeadSource,OwnerId,Type,RecordTypeId,Deal_Type__c,Renewal__c,
                            CurrencyIsoCode,PriceBook2Id,Previous_Opportunity__c,License_Term_in_Months__c,Project_Country__c,Project_Region__c,
                            Opportunity_Type__c,Primary_Contact__c,Deployment_Option__c,Partner_Involved__c,Secondary_Partner__c,ForecastCategoryName FROM Opportunity WHERE Id =: OppIdsToClone]) {
         Opportunity newOpp = o.clone(false, false, false, false);
         if (newOpp.Renewal__c == NULL) { 
            if (newOpp.Name.length() <= 110) { newOpp.Name += ' (Renewal)'; }
            newOpp.Renewal__c = 1;
         }   // end if it's a first renewal
         else if (newOpp.Renewal__c != NULL && newOpp.Renewal__c > 0) {
            // Attempt to change the name later using a regular expression, i.e. "Renewal" -> "Renewal #2"
            String[] NameParts = newOpp.Name.Split('\\ \\(Renew', 2);
            newOpp.Renewal__c++;
            String newName = NameParts[0] + ' (Renewal #' + String.valueOf(newOpp.Renewal__c) + ')';
            if (newName.length() < 120) { newOpp.Name = newName; }
         }
         newOpp.StageName = 'B2 - First Meeting/Qualification';
         newOpp.RecordTypeId = RenewalDealRecordType.Id__c;   // Sets the Record Type ID to be "Renewal Deal"
         newOpp.Previous_Opportunity__c = o.Id;
         Integer numMonths = Integer.valueOf(newOpp.License_Term_in_Months__c);
         newopp.LeadSource = 'Existing Customer';
         newopp.ForecastCategoryName = 'Pipeline';
         newopp.Project_Country__c = o.Project_Country__c;
         newopp.Project_Region__c = o.Project_Region__c;
         newopp.Type = o.Type;
         newopp.Deployment_Option__c = o.Deployment_Option__c;
         OppTypes.put(o.Id,o.Type);
         newopp.Opportunity_Type__c = o.Opportunity_Type__c;
         newopp.Deal_Type__c = 'Renewal - '+ o.Type;
         newopp.Primary_Contact__c = o.Primary_Contact__c;
         newopp.Secondary_Partner__c = o.Secondary_Partner__c;
         newopp.Partner_Involved__c = o.Partner_Involved__c;
         System.debug('+++ OPP CLOSE DATE: ' + newopp.Id + ' :: ' + newopp.CloseDate.format());
         newOpp.CloseDate = newOpp.CloseDate.addMonths(numMonths);
           //newopp.CloseDate = o.End_Date__c;
         ClonedOpps.add(newOpp);
      }  // end for Opportunity

      List<String> CreatedOppIds = new List<String>();
      if (ClonedOpps.size() > 0) {
         Database.SaveResult[] srList = Database.insert(ClonedOpps, true);
         for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
               CreatedOppIds.add(sr.GetId());
               System.debug('++++ New Opp Id: ' + sr.GetId());
            }
            else { 
               for(Database.Error err : sr.getErrors()) {
                  System.debug('The following error has occurred.');                    
                  System.debug(err.getStatusCode() + ': ' + err.getMessage());
                  System.debug('Account fields that affected this error: ' + err.getFields());
               }
            }   // end if/else
         }      // end for srList
      }
      
      // Create a map to link back old Opportunity Products
      for (Opportunity o : [SELECT Id,Type,Previous_Opportunity__c FROM Opportunity WHERE Id=:CreatedOppIds]) {
         ClonedOppMap.put(o.Previous_Opportunity__c, o.Id);
      }
      
      // SObject "clone()" method doesn't copy Line Items, so we need to do it by hand
      List<OpportunityLineItem> ClonedLineItems = new List<OpportunityLineItem>();
      for (OpportunityLineItem oli : [SELECT Id,Product2.Family,PricebookEntryId,OpportunityId,Discount,ListPrice,Quantity,UnitPrice,CurrencyIsoCode,
                                      TotalPrice FROM OpportunityLineItem WHERE OpportunityId =: OppIdsToClone]) {
         String newOppId = ClonedOppMap.get(oli.OpportunityId);
         String oldOppType = OppTypes.get(oli.OpportunityId);
         Boolean addLineItem = false;
         
         if      (oldOppType == 'Subscription' && oli.Product2.Family == 'Subscription License') { addLineItem = true; }
         else if (oldOppType == 'Perpetual' && oli.Product2.Family == 'Perpetual Maintenance and Support') { addLineItem = true; }
         
         if (addLineItem) {   // Add Item if Subscription or Perpetual
            OpportunityLineItem new_oli = new OpportunityLineItem(
               OpportunityId = newOppId, 
               PricebookEntryId = oli.PricebookEntryId,
               Discount = oli.Discount,
               Quantity = oli.Quantity,
               UnitPrice = oli.UnitPrice
            );
            ClonedLineItems.add(new_oli);
         }   // end add item
      }  // end for OpportunityLineItem
      
      if (ClonedLineItems.size() > 0) { insert ClonedLineItems; }
   }

}