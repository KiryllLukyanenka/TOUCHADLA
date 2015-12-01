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
private class TestADUAUtils {

    /*static testMethod void myUnitTest() {
    	EnvironmentSettings.testEnvironmentSettings();
        // TO DO: implement unit test
        Account account = new Account(name='TestAccount');
        RestContext.request = (new RestRequest());       // pass the request and response objects to the method
        RestContext.response = (new RestResponse());
        insert account;
        try{
            ADUAUtils.manageUser('april232013','lname','april232013@tarams.com',account.name,account.PortalID__c,'433','help,download-zones/saas-public,docs/docs-partner,learning-system/lms-learner');
        }catch(Exception e){
            System.debug(e);
        }
        RestContext.request = (new RestRequest());       // pass the request and response objects to the method
        RestContext.response = (new RestResponse());
        try{
            ADUAUtils.manageUser('april232013','lname','april232013@tarams.com',account.name,account.PortalID__c,'433','help,download-zones/saas-public,docs/docs-partner');
        }catch(Exception e){
            System.debug(e);
        }
        RestContext.request = (new RestRequest());       // pass the request and response objects to the method
        RestContext.response = (new RestResponse());
        try{
            ADUAUtils.manageUser('april232013','lname','april232013@tarams.com',account.name,account.PortalID__c,'433','help,docs/docs-partner');
        }catch(Exception e){
            System.debug(e);
        }
        RestContext.request = (new RestRequest());       // pass the request and response objects to the method
        RestContext.response = (new RestResponse());
        try{
            ADUAUtils.manageUser('april232013','lname','april232013@tarams.com',account.name,account.PortalID__c,'433','docs/docs-partner');
        }catch(Exception e){
            System.debug(e);
        }
        Lead leadObj = new Lead();
        leadObj.FirstName='fName_'+1;
        leadObj.LastName = 'lName_'+1;
        leadObj.Email = 'testTarams_fName_lName_1@tarams.com';
        leadObj.Company = 'testTarams_fName_lName';
        insert leadObj;
        ADUAUtils.manageUser(leadObj.firstName, leadObj.lastName, leadObj.email, leadObj.Company, '1234', '123', 'help');
    }
    */
    static testMethod void testManageUser() {
    	EnvironmentSettings.testEnvironmentSettings();
        // TO DO: implement unit test
         Account acc = new Account();
         acc.Name = 'testAccount';
         acc.OwnerId = userinfo.getuserid();
         insert acc;
         Account_Portal_Company__c acp = new Account_Portal_Company__c();
    	 acp.Company_Portal_Id__c = '2453';
         acp.Account__c = acc.Id;
         insert acp;
        RestContext.request = (new RestRequest());       // pass the request and response objects to the method
        RestContext.response = (new RestResponse());
        try{
            ADUAUtils.manageUser('april232013','lname','april232013@tarams.com',acc.name,acc.PortalID__c,'433','help,download-zones/saas-public,docs/docs-partner,learning-system/lms-learner');
        }catch(Exception e){
            System.debug(e);
        }
         ADUAUtils.manageUser('april232013','lname','april232013@tarams.com',acc.name,acc.PortalID__c,'433','help,download-zones/saas-public,docs/docs-partner,learning-system/lms-learner');
    	 Lead leadObj = new Lead();
         leadObj.FirstName='fName_'+1;
         leadObj.LastName = 'lName_'+1;
         leadObj.Status = 'first';
         leadObj.LeadSource = 'Website';
         leadObj.IsConverted = false;
         leadObj.Email = 'testTarams_fName_lName_1@tarams.com';
         leadObj.Company = 'testTarams_fName_lName';
         insert leadObj;
         ADUAUtils.manageUser(leadObj.FirstName, leadObj.LastName, leadObj.Email,leadObj.Company,'1234','123', 'help');
         Account acct = new Account();
         acct.Name = 'testAccount';
         acct.OwnerId = userinfo.getuserid();
         insert acct;
         Account_Portal_Company__c acpt = new Account_Portal_Company__c();
    	 acpt.Company_Portal_Id__c = '2453';
         acpt.Account__c = acct.Id;
         insert acpt;
         Contact con = new Contact();
         con.FirstName = 'TestContact';
         con.LastName = 'test';
         con.email = 'test@test.com';
         con.AccountId = acct.Id;
         insert con; 
              ADUAUtils.manageUser(con.FirstName, con.LastName, con.email,acct.Name,acpt.Company_Portal_Id__c,'123', 'help');
    
    }
    
    static testMethod void testGetAccount() {
    	
    	Account acc = new Account();
    	acc.Name = 'testAccount';
    	insert acc;
    	Account_Portal_Company__c acp = new Account_Portal_Company__c();
    	acp.Company_Portal_Id__c = '2453';
    	insert acp;
    	ADUAUtils.getAccount(acp.Company_Portal_Id__c,acc.Name);
    }
    static testMethod void testGetContact(){
    	 RestResponse response = RestContext.response;
         //ADUAUtils.getContact('testContact','test', 'testCon@test.com','testAcc','1234','456',response);
         Account acc = new Account();
         acc.Name = 'testAccount';
         acc.OwnerId = userinfo.getuserid();
         insert acc;
         Account_Portal_Company__c acp = new Account_Portal_Company__c();
    	 acp.Company_Portal_Id__c = '2453';
         acp.Account__c = acc.Id;
         insert acp;
         Contact con = new Contact();
         con.FirstName = 'TestContact';
         con.LastName = 'test';
         con.email = 'test@test.com';
         insert con; 
         User u = [select id,isActive from user where id=:userinfo.getuserid()];
         if ( u.isActive) {
         	ADUAUtils.getContact(con.FirstName,con.LastName, con.email,acc.Name,acp.Company_Portal_Id__c,'123',response);
         }
         Contact con1 = new Contact();
         con1.FirstName = 'TestContact';
         con1.LastName = 'test';
         con1.email = 'test@test.com';
         con1.AccountId = acc.Id;
         insert con1; 
         User u1 = [select id,isActive from user where id=:userinfo.getuserid()];
         if ( u1.isActive) {
         	ADUAUtils.getContact(con.FirstName,con.LastName, con.email,acc.Name,acp.Company_Portal_Id__c,'123',response);
         }
         //ADUAUtils.getContact(con.FirstName,con.LastName, con.email,'testAcc','5678','123',response);
         
    } 
    
    static testMethod void testSetupADUAContact(){
    	 Account acc = new Account();
         acc.Name = 'testAccount';
         acc.OwnerId = userinfo.getuserid();
         insert acc;
         Account_Portal_Company__c acp = new Account_Portal_Company__c();
    	 acp.Company_Portal_Id__c = '2453';
         acp.Account__c = acc.Id;
         insert acp;
         Contact con = new Contact();
         con.FirstName = 'TestContact';
         con.LastName = 'test';
         con.email = 'test@test.com';
         con.AccountId = acc.Id;
         insert con;
         Contact_Portal_User__c cpu = new Contact_Portal_User__c();
         cpu.Contact__c = con.Id;
         insert cpu;          	
         ADUAUtils.setupADUAContact(con,'help');     	
    }
}