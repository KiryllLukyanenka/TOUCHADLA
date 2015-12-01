@isTest (seeAllData=true)
private class JSButton_Test {

    @isTest static void createVouchersTest() {
    User u1 = [SELECT Id FROM User WHERE Alias='dmoli'];
        
        //Run As U1
    System.RunAs(u1){

    
        Account a = TestClassUtility.createAccount();
    insert a;

    Id oppTrainingRecordType =
      Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
        'Training and Services').getRecordTypeId();
    Opportunity o = TestClassUtility.createOpportunity(a);
    o.RecordTypeId = oppTrainingRecordType;
    insert o;

    Product2 p = TestClassUtility.createProduct();
    p.ProductCode = 'ENB-TRU-01-TRNG';
    p.Name = 'Training Units';
    insert p;

    Pricebook2 pb = [Select Id
                     From Pricebook2 Where IsStandard = True
                     limit 1];

    PricebookEntry pbe = TestClassUtility.createPricebookEntry(pb, p);
    insert pbe;

    Test.startTest();

    String result = JSButtonManagement.createVouchers('00O000000000000', '09/01/2017');
    system.assert(result == 'Invalid Opportunity Id');

    result = JSButtonManagement.createVouchers(o.Id, '09/01/2017');
    system.assert(
      result == 'This Opportunity is not in \'W10 - Closed/Won\' status.');

    o.StageName = 'W10 - Closed/Won';
    o.FSR_Not_Required_On_Opp__c = true;
    o.ISR_Not_Required_On_Opp__c = true;
    o.Primary_Competitor__c = 'New Relic';
    o.Primary_Competitor_Strengths__c = 'Strength1';
    o.Primary_Competitor_Weaknesses__c = 'Weakness1';
    update o;

    result = JSButtonManagement.createVouchers(o.Id, '09/01/2017');
    system.assert(result == 'No Training Products exist on this Opportunity');

    OpportunityLineItem oli =
      TestClassUtility.createOpportunityLineItem(o, pbe);
    insert oli;
    result = JSButtonManagement.createVouchers(o.Id, '09/01/2017');
    system.assert(result == '/' + o.Id);
    }
    Test.stopTest();
    }
}