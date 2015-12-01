public class TestClassUtility {
  public static Account createAccount() {
  
     Territory_AppD__c t = new Territory_AppD__c(Name = 'Test Territory',
                                                 Geo__c = 'North America',
                                                 Region__c = 'West',
                                                 Assigned_To_ID__c = '00580000006Aq0QAAS');
                                                   
     Account a = new Account(Name = 'Test Account',
                            BillingStreet = '303 2nd Street', 
                            BillingCity = 'San Francisco', 
                            BillingState = 'CA', 
                            BillingCountry= 'United States', 
                            //Territory_AppD__c = 'a1k34000001se1MAAQ',
                            Territory_AppD__c = t.Id,
                            Subsidiary__c = 'AppDynamics, Inc.');
    return a;
  }

  public static Opportunity createOpportunity(Account a) {
    Opportunity o = new Opportunity(
      Name = 'Test Opportunity',
      AccountId = a.Id,
      StageName = 'New',
      CloseDate = system.today());
    return o;
  }

  public static Product2 createProduct() {
    Product2 p = new Product2(Name = 'Test Product', ProductCode = 'Test Code');
    return p;
  }

  public static PricebookEntry createPricebookEntry(Pricebook2 pb, Product2 p) {
    PricebookEntry pe = new PricebookEntry(Pricebook2Id = pb.Id,
      Product2Id = p.Id, UnitPrice = 2, IsActive = true);
    return pe;
  }

  public static OpportunityLineItem createOpportunityLineItem(
      Opportunity o,
      PricebookEntry pbe) {
    OpportunityLineItem oli = new OpportunityLineItem(
      OpportunityId = o.Id,
      PricebookEntryId = pbe.Id,
      Quantity = 1,
      TotalPrice = 100);
    return oli;
  }
}