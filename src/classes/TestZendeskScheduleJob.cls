/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestZendeskScheduleJob {
/*
    static testMethod void zendeskFailure() {
        // TO DO: implement unit test
        Account account  = new Account(Name = 'testOrg');
    	insert account;
    	Account_Zendesk__c az = new Account_Zendesk__c(name = 'testAZ',Account__c = account.Id,Status__c = 'FAILED');
        Test.startTest();
    	ZendeskScheduleJob zs = new ZendeskScheduleJob();
    	String jobId = System.schedule('testLicenseExpiryCheckJobTest',
            '0 0 0 3 9 ? 2022', 
            zs);
        Test.StopTest();
    }
    
    static testMethod void zendeskSuccess() {
        // TO DO: implement unit test
        Account account  = new Account(Name = 'testOrg1');
    	insert account;
    	Account_Zendesk__c az = new Account_Zendesk__c(name = 'testAZ',Account__c = account.Id,Status__c = 'SUCCESS');
        Test.startTest();
    	ZendeskScheduleJob_Success zs = new ZendeskScheduleJob_Success();
    	String jobId = System.schedule('testLicenseExpiryCheckJobTest',
            '0 0 0 3 9 ? 2022', 
            zs);
        Test.StopTest();
    }
    
    static testMethod void zendeskEmpty() {
        // TO DO: implement unit test
        Account account  = new Account(Name = 'testOrg2');
    	insert account;
        Test.startTest();
    	ZendeskScheduleJob_Empty zs = new ZendeskScheduleJob_Empty();
    	String jobId = System.schedule('testLicenseExpiryCheckJobTest',
            '0 0 0 3 9 ? 2022', 
            zs);
        Test.StopTest();
    }*/
}