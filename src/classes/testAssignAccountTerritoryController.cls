@isTest
public class testAssignAccountTerritoryController
{
    @isTest
    static void testController()
    {
         Id standardAccountRecordTypeId = [select Id from RecordType where SobjectType = 'Account' and Name = 'Standard Account' limit 1].Id;
        Account testAccount = new Account(name = 'acme', Industry='Education', BillingCOuntry = 'USA', X500K_Email_Sent__c = true, Account_Balance__c = 100000, BillingState = 'CA', BillingPostalCode = '1500', RecordTypeId = standardAccountRecordTypeId);
        insert testAccount;
        PageReference testPage = new PageReference('/apex/AssignAccountTerritory?id=' + testAccount.Id);
        test.setCurrentPage(testPage);
        AssignAccountTerritoryCOntroller controller = new AssignAccountTerritoryCOntroller();
        controller.assignTerritory();
    }
}