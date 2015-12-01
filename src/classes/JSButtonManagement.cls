global class JSButtonManagement {
  webservice static String createVouchers(Id opportunityId, String newExpirationdate)
    {
    map<String, Complex_Product__c> productMap =
      new map<String, Complex_Product__c>();
    list<AppDynamics_University_Voucher__c> vouchersToCreateList =
      new list<AppDynamics_University_Voucher__c>();
    Opportunity oppObj;
    Decimal totalCards = 0;
    Decimal totalTraining = 0;

    try {
      for (Complex_Product__c c : [Select Name,
                                          Product_Code__c,
                                          Number_of_Training_Units__c,
                                          Number_of_Cards__c
                                   From Complex_Product__c
                                   Where Number_of_Cards__c != null
                                   Or Number_of_Training_Units__c != null]) {
        productMap.put(c.Product_Code__c, c);
      }
    } catch (Exception e) {
      return 'No Card/Training mappings found';
    }
    try {
      oppObj = [Select Id,
                       AccountId,
                       StageName,
                       Booked_Date__c,
                       End_Date__c,
                       (Select Id,
                               Quantity,
                               PricebookEntryId,
                               PricebookEntry.ProductCode
                        From OpportunityLineItems
                        Where PricebookEntry.ProductCode IN
                          :productMap.keySet()),
                       (Select Id,
                               ContactId
                        From OpportunityContactRoles
                        Where IsPrimary = true
                        And Contact.Self_Service_Pro_Trial__c = false)
                From Opportunity
                Where Id = :opportunityId];
      if (oppObj.StageName != 'W10 - Closed/Won') {
        return 'This Opportunity is not in \'W10 - Closed/Won\' status.';
      }
    } catch (Exception e) {
      return 'Invalid Opportunity Id';
    }

    if (oppObj.OpportunityLineItems == null ||
        oppObj.OpportunityLineItems.isEmpty()) {
      return 'No Training Products exist on this Opportunity';
    } else {
      for (OpportunityLineItem oli : oppObj.OpportunityLineItems) {
        if (oli.Quantity != null &&
            productMap.get(oli.PricebookEntry.ProductCode) != null) {
          totalCards +=
            oli.Quantity *
            productMap.get(oli.PricebookEntry.ProductCode).Number_of_Cards__c;
          totalTraining +=
            oli.Quantity *
            productMap.get(oli.PricebookEntry.ProductCode).Number_of_Training_Units__c;
        }
      }
      if (totalCards > 0) {
        vouchersToCreateList.add(new AppDynamics_University_Voucher__c(
          Opportunity__c = oppObj.Id,
          Account__c = oppObj.AccountId,
          Primary_Contact__c =
            oppObj.OpportunityContactRoles != null &&
            !oppObj.OpportunityContactRoles.isEmpty() ?
              oppObj.OpportunityContactRoles[0].ContactId : null,
          New_Expiration_Date__c = Date.parse(newExpirationdate),
          Type__c = 'Library Cards',
          Purchased_Quantity__c = totalCards));
      }
      if (totalTraining > 0) {
        vouchersToCreateList.add(new AppDynamics_University_Voucher__c(
          Opportunity__c = oppObj.Id,
          Account__c = oppObj.AccountId,
          Primary_Contact__c =
            oppObj.OpportunityContactRoles != null &&
            !oppObj.OpportunityContactRoles.isEmpty() ?
              oppObj.OpportunityContactRoles[0].ContactId : null,
          Type__c = 'Training Units',
         New_Expiration_Date__c = Date.parse(newExpirationdate),
          Purchased_Quantity__c = totalTraining));
      }
      if (!vouchersToCreateList.isEmpty()) {
        try {
          insert vouchersToCreateList;
          return '/' + oppObj.Id;
        } catch (Exception e) {
          return e.getMessage();
        }
      }
    }

    return 'No Training Products exist on this Opportunity';
  }
}