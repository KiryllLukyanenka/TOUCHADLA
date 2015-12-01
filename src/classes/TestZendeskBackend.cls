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
private class TestZendeskBackend {
/*
    static testMethod void aceArchitectTest() {
    	EnvironmentSettings.testEnvironmentSettings();
        // TO DO: implement unit test
        User user = new User(LastName = 'TestUser', Alias = 'test', Username = 'testuser@tarams.com', CommunityNickname = 'testnick', Email = 'giribhushan.gururaj@tarams.com', UserRoleId = '00E80000001PKsy', ProfileId = '00e80000001KCh9',
        TimeZoneSidKey = 'America/Chicago', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        insert user;
        
        
        
        System.runAs ( user ) {
    		// put test setup code in here
    		RESTAPI.unitTestMode = true;
    		try{
            Test.startTest();

    		Account account  = new Account(Name = 'testOrg' , ACE_Architect__c = user.id,PortalId__c='55555');
    		insert account;
    		
    		ZendeskBackend.ZendeskUser zu = new ZendeskBackend.ZendeskUser();
    		ZendeskBackend.ZendeskUserPhoto zp = new ZendeskBackend.ZendeskUserPhoto();
    		ZendeskBackend.PortalResponse pr = new ZendeskBackend.PortalResponse();
    		ZendeskBackend.ZendeskDetail zd = new ZendeskBackend.ZendeskDetail(); 
    		
    		//ZendeskBackend.doZendeskTriggerCall(account.Name, account.id, user.Email, null, null, user.id, null, null, 123456, 'CREATE', null, 12345, null);
    		//ZendeskBackend.doZendeskTriggerCall(account.Name, account.id, user.Email, '', '', user.id, '', '', 12345, 'CREATE',new Map<Integer,String>(),123,12345);
    		
    		Test.stopTest();
            }catch(Exception e){}
		}
        
    }
    
    static testMethod void tamArchitectTest() {
    	EnvironmentSettings.testEnvironmentSettings();
        User user = new User(LastName = 'TestUser', Alias = 'test', Username = 'testuser@tarams.com', CommunityNickname = 'testnick', Email = 'giribhushan.gururaj@tarams.com', UserRoleId = '00E80000001PKsy', ProfileId = '00e80000001KDQi',
                TimeZoneSidKey = 'America/Chicago', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        insert user;
     
        System.runAs ( user ) {
    		// put test setup code in here
    		RESTAPI.unitTestMode = true;
    		Test.startTest();
            try{
    		Account account  = new Account(Name = 'testOrg' , Technical_Account_Manager__c = user.id,PortalId__c='55555');
    		insert account;

            Account_Zendesk__c az = new Account_Zendesk__c(Account__c=account.id);
            insert az;
            
            Contact con = new Contact(firstname = 'Test',lastname = 'Test',description='');
            insert con;
            List<Contact> partnerContacts = new List<Contact>(); 
            partnerContacts.add(con);
            Zendesk_Contact__c zc = new Zendesk_Contact__c(Account_Zendesk__c=az.id,Contact_Id__c=con.id);
            insert zc;
    		 
    		//ZendeskBackend.checkIf_ACE_TAM_NULL(account);
    		
    		
    		//ZendeskBackend.checkIf_Partner_Contacts_Changed(account, az, partnerContacts);
    		
    		//ZendeskBackend.ZendeskOrganization zo = new ZendeskBackend.ZendeskOrganization();
    		ZendeskBackend.ZendeskUser zu = new ZendeskBackend.ZendeskUser();
    		ZendeskBackend.ZendeskUserPhoto zp = new ZendeskBackend.ZendeskUserPhoto();
    		ZendeskBackend.PortalResponse pr = new ZendeskBackend.PortalResponse();
    		ZendeskBackend.ZendeskDetail zd = new ZendeskBackend.ZendeskDetail(); 
    		
    		Test.stopTest();
            }catch(Exception e){}
		}
        
    }
    
    static testMethod void testPartnerApi() {
    	EnvironmentSettings.testEnvironmentSettings();
    	RESTAPI.unitTestMode = true;
    	String requestJson = '{"type":"contact","portalid":[1111]}';
    	//ZendeskBackend.fetchZendeskIdFromPortal(requestJson);
    }
    
    static testMethod void aceArchitectTest2() {
    	EnvironmentSettings.testEnvironmentSettings();
        // TO DO: implement unit test
        User user = new User(LastName = 'TestUser', Alias = 'test', Username = 'testuser@tarams.com', CommunityNickname = 'testnick', Email = 'giribhushan.gururaj@tarams.com', UserRoleId = '00E80000001PKsy', ProfileId = '00e80000001KCh9',
        TimeZoneSidKey = 'America/Chicago', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        insert user;
        
        
        
        System.runAs ( user ) {
    		// put test setup code in here
    		RESTAPI.unitTestMode = true;
    		Test.startTest();
            try{
    		Account account  = new Account(Name = 'testOrg' , ACE_Architect__c = user.id,PortalId__c='55555');
    		insert account;
    		Account_Zendesk__c az = new Account_Zendesk__c();
    		az.Account__c = account.id;
    		az.Trigger_Id__c = '123456';
    		az.status__c = 'SUCCESS';
    		az.Organisation_Id__c = '45678';
    		az.SE__c = '1234';
    		az.TAM__c = '1234';
    		az.ACE_Architect__c = '1234';
    		insert az;
    		User_Zendesk__c uz = new User_Zendesk__c();
    		uz.User__c = user.id;
    		uz.Zendesk_User_Id__c = '1234';
    		insert uz;
    		
    		
    		//ZendeskBackend.doZendeskTriggerCall(account.Name, account.id, user.Email, null, null, user.id, null, null, 123456, 'CREATE', null, 12345, null);
    		//ZendeskBackend.doZendeskTriggerCall(account.Name, account.id, user.Email, '', '', user.id, '', '', 12345, 'CREATE',new Map<Integer,String>(),123,12345);
    		
    		Test.stopTest();
    		ZendeskBackend.checkTriggerDetails(account);
            }catch(Exception e){}
    		
		}
        
    }
    
    static testMethod void aceArchitectTest3() {
    	EnvironmentSettings.testEnvironmentSettings();
        // TO DO: implement unit test
        User user = new User(LastName = 'TestUser', Alias = 'test', Username = 'testuser@tarams.com', CommunityNickname = 'testnick', Email = 'giribhushan.gururaj@tarams.com', UserRoleId = '00E80000001PKsy', ProfileId = '00e80000001KCh9',
        TimeZoneSidKey = 'America/Chicago', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US');
        insert user;
        
        
        
        System.runAs ( user ) {
    		// put test setup code in here
    		RESTAPI.unitTestMode = true;
    		Test.startTest();
            try{
    		Account account  = new Account(Name = 'testOrg' , ACE_Architect__c = user.id);
    		insert account;
    		
    		
    		Test.stopTest();
            }catch(Exception e){}
		}
        
    }*/
}