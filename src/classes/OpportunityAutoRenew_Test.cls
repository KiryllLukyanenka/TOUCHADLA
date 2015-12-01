@isTest
private class OpportunityAutoRenew_Test {

// Extend Test class to test multiples/bulk

   private static testMethod void testClone() {
      Database.SaveResult sr;

      RecordType[] RecordType_query = [SELECT Id FROM RecordType WHERE Name='Renewal Deal' AND SObjectType='Opportunity'];
      String RenewalDealId = RecordType_query[0].Id;
      
      OppAutoRenewSetting__c rdrt = new OppAutoRenewSetting__c();
      rdrt.Name = 'Renewal Deal Record Type';
      rdrt.Id__c = RenewalDealId;
      insert rdrt;
      
      // Create Pricebook and Products
      Pricebook2 pb = new Pricebook2(
         Name = 'Default Pricebook',
         IsActive = true
      );
      sr = Database.insert(pb);
      String PricebookId = sr.GetId();
      
      Product2 testSub = new Product2(
         Name = 'Test Subscription',
         Family = 'Subscription License'
      );
      sr = Database.insert(testSub);
      String SubId = sr.GetId();

      Product2 testPerp = new Product2(
         Name = 'Test Perpetual',
         Family = 'Perpetual Maintenance and Support'
      );
      sr = Database.insert(testPerp);
      String PerpId = sr.GetId();

      PricebookEntry stdPb = new PricebookEntry(
         Product2Id = SubId,
         Pricebook2Id = Test.getStandardPricebookId(),
         UnitPrice = 55.00,
         IsActive = true
      );
      insert stdPb;
      stdPb = new PricebookEntry(
         Product2Id = PerpId,
         Pricebook2Id = Test.getStandardPricebookId(),
         UnitPrice = 75.00,
         IsActive = true
      );
      insert stdPb;

      PricebookEntry pbe = new PricebookEntry(
         Product2Id = SubId,
         Pricebook2Id = PricebookId,
         UnitPrice = 123.00,
         UseStandardPrice = false,
         IsActive = true
      );
      sr = Database.insert(pbe);
      SubId = sr.GetId();
      pbe = new PricebookEntry(
         Product2Id = PerpId,
         Pricebook2Id = PricebookId,
         UnitPrice = 80.00,
         UseStandardPrice = false,
         IsActive = true
      );
      sr = Database.insert(pbe);
      PerpId = sr.GetId();
      
      Territory_AppD__c t = new Territory_AppD__c(Name = 'Test Territory',
                                                 Geo__c = 'North America',
                                                 Region__c = 'West',
                                                 Assigned_To_ID__c = '00580000006Aq0QAAS');  
      insert t;
          
      // Insert a new Account
      Account newAccount = new Account (Name = 'Test Account', 
                                        BillingStreet = '303 2nd Street', 
                                        BillingCity = 'San Francisco', 
                                        BillingState = 'CA', 
                                        BillingCountry= 'United States', 
                                        //Territory_AppD__c = 'a1k34000001se1MAAQ',
                                        Territory_AppD__c = t.Id,
                                        Subsidiary__c = 'AppDynamics, Inc.');
      sr = Database.insert(newAccount);
      String AccountId = sr.GetId();
      
      OpportunityLineItem newLineItem;
      
      Opportunity newSubOpp = new Opportunity(
         Name = 'Subscription Test Opp',
         AccountId = AccountId,
         StageName = 'A1 - Pipeline Generation',
         CloseDate = Date.today(),
         License_Term_in_Months__c = 12,
         Type = 'Subscription',
         Pricebook2Id = PricebookId
      );
      System.debug('++++ SUB OPP INSERT CLOSE DATE: ' + newSubOpp.CloseDate.format());
      sr = Database.insert(newSubOpp);
      String SubOppId = sr.GetId();
      newLineItem = new OpportunityLineItem(
         OpportunityId = SubOppId,
         PricebookEntryId = SubId,
         Quantity = 1,
         TotalPrice = 123.00
      );
      insert newLineItem;
      
      Opportunity newPerpOpp = new Opportunity(
         Name = 'Perpetual Test Opp',
         AccountId = AccountId,
         StageName = 'A1 - Pipeline Generation',
         CloseDate = Date.today(),
         License_Term_in_Months__c = 12,
         Type = 'Perpetual',
         Pricebook2Id = PricebookId
      );
      System.debug('++++ PERP OPP INSERT CLOSE DATE: ' + newPerpOpp.CloseDate.format());
      sr = Database.insert(newPerpOpp);
      String PerpOppId = sr.GetId();
      newLineItem = new OpportunityLineItem(
         OpportunityId = PerpOppId,
         PricebookEntryId = PerpId,
         Quantity = 1,
         TotalPrice = 80.00
      );
      insert newLineItem;

      Opportunity newSecondRenewOpp = new Opportunity(
         Name = 'Second Renewal Opp (Renewal)',
         AccountId = AccountId,
         StageName = 'A1 - Pipeline Generation',
         CloseDate = Date.today(),
         License_Term_in_Months__c = 12,
         Type = 'Subscription',
         Renewal__c = 1,
         Pricebook2Id = PricebookId
      );
      sr = Database.insert(newSecondRenewOpp);
      
      Opportunity newThirdRenewOpp = new Opportunity(
         Name = 'Third Renewal Opp (Renewal #2)',
         AccountId = AccountId,
         StageName = 'A1 - Pipeline Generation',
         CloseDate = Date.today(),
         License_Term_in_Months__c = 12,
         Type = 'Subscription',
         Renewal__c = 2,
         Pricebook2Id = PricebookId
      );
      sr = Database.insert(newThirdRenewOpp);   
      
      Test.startTest();
      newSubOpp.Booked_Date__c = Date.today();
      newSubOpp.StageName = 'W10 - Closed/Won';
      newSubOpp.FSR_Not_Required_On_Opp__c = true;
      newSubOpp.ISR_Not_Required_On_Opp__c = true;
      newSubOpp.Primary_Competitor__c = 'New Relic';
      newSubOpp.Primary_Competitor_Strengths__c = 'Strength1';
      newSubOpp.Primary_Competitor_Weaknesses__c = 'Weakness1';
      update newSubOpp;
      newPerpOpp.Booked_Date__c = Date.today();
      newPerpOpp.StageName = 'W10 - Closed/Won';
      newPerpOpp.FSR_Not_Required_On_Opp__c = true;
      newPerpOpp.ISR_Not_Required_On_Opp__c = true;
      newPerpOpp.Primary_Competitor__c = 'New Relic';
      newPerpOpp.Primary_Competitor_Strengths__c = 'Strength1';
      newPerpOpp.Primary_Competitor_Weaknesses__c = 'Weakness1';
      update newPerpOpp;
      newSecondRenewOpp.Booked_Date__c = Date.today();
      newSecondRenewOpp.StageName = 'W10 - Closed/Won';
      newSecondRenewOpp.FSR_Not_Required_On_Opp__c = true;
      newSecondRenewOpp.ISR_Not_Required_On_Opp__c = true;
      newSecondRenewOpp.Primary_Competitor__c = 'New Relic';
      newSecondRenewOpp.Primary_Competitor_Strengths__c = 'Strength1';
      newSecondRenewOpp.Primary_Competitor_Weaknesses__c = 'Weakness1';
      update newSecondRenewOpp;
      newThirdRenewOpp.Booked_Date__c = Date.today();
      newThirdRenewOpp.StageName = 'W10 - Closed/Won';
      newThirdRenewOpp.FSR_Not_Required_On_Opp__c = true;
      newThirdRenewOpp.ISR_Not_Required_On_Opp__c = true;
      newThirdRenewOpp.Primary_Competitor__c = 'New Relic';
      newThirdRenewOpp.Primary_Competitor_Strengths__c = 'Strength1';
      newThirdRenewOpp.Primary_Competitor_Weaknesses__c = 'Weakness1';
      update newThirdRenewOpp;
      Test.stopTest();
      
      // A new Opportunity should have been created (cloned) with a Stage of B2
      Opportunity[] o_query = [SELECT Id,StageName,Booked_Date__c,Previous_Opportunity__c,Renewal__c FROM Opportunity WHERE Name='Subscription Test Opp (Renewal)'];
      Opportunity clonedOpp = o_query[0];
      System.assertEquals('B2 - First Meeting/Qualification', clonedOpp.StageName);
      System.assertEquals(newSubOpp.Id,clonedOpp.Previous_Opportunity__c);
      System.assertEquals(1,clonedOpp.Renewal__c);
      
      // A new Opportunity Line Item should have been created as well
      OpportunityLineItem[] oli_query = [SELECT Id,OpportunityId,TotalPrice FROM OpportunityLineItem
                                         WHERE OpportunityId =: clonedOpp.Id AND PricebookEntryId =: SubId];
      OpportunityLineItem clonedLineItem = oli_query[0];
      System.assertEquals(123.00, clonedLineItem.TotalPrice);
      
      // Check for the new Perpetual one as well
      o_query = [SELECT Id,StageName,Booked_Date__c,Previous_Opportunity__c,Renewal__c FROM Opportunity WHERE Name='Perpetual Test Opp (Renewal)'];
      clonedOpp = o_query[0];
      System.assertEquals('B2 - First Meeting/Qualification', clonedOpp.StageName);
      System.assertEquals(newPerpOpp.Id,clonedOpp.Previous_Opportunity__c);
      System.assertEquals(1,clonedOpp.Renewal__c);
      oli_query = [SELECT Id,OpportunityId,TotalPrice FROM OpportunityLineItem
                   WHERE OpportunityId !=: clonedOpp.Id AND PricebookEntryId =: PerpId];
      clonedLineItem = oli_query[0];
      System.assertEquals(80.00, clonedLineItem.TotalPrice);

      for (Opportunity o : [SELECT Id,Name,Renewal__c FROM Opportunity WHERE Renewal__c > 1]) {
         System.debug('+++ ' + o.Name);
      }

/*      
      // Test for the Second Renewal
      o_query = [SELECT Id,StageName,Booked_Date__c,Previous_Opportunity__c FROM Opportunity WHERE Name='Second Renewal Opp (Renewal #2)'];
      clonedOpp = o_query[0];
      System.assertEquals('B2 - First Meeting/Qualificaton', clonedOpp.StageName);
      
      // Test for the Third Renewal
      o_query = [SELECT Id,StageName,Booked_Date__c,Previous_Opportunity__c FROM Opportunity WHERE Name='Third Renewal Opp (Renewal #3)'];
      clonedOpp = o_query[0];
      System.assertEquals('B2 - First Meeting/Qualificaton', clonedOpp.StageName);
*/



   }

}