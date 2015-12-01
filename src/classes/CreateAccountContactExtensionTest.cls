@isTest
public class CreateAccountContactExtensionTest {

    @isTest(SeeAllData=true) static void testCreateAccountContactExtension(){
        Opportunity oppt = [select Id from Opportunity where DR_Contact_Last_Name__c != null and DR_Email_Address__c != null and DR_Company_Name__c != null limit 1];
        CreateAccountContactExtension controller = new CreateAccountContactExtension(new ApexPages.StandardController(oppt));
        controller.RelatedAccount.Name = 'test';
        controller.save();
    }
}