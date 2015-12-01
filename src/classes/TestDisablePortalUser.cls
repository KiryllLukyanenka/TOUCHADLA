public with sharing class TestDisablePortalUser {
	public static testMethod void testTestDisablePortalUser1(){
		EnvironmentSettings.testEnvironmentSettings();
		RESTAPI.unitTestMode = true;
    	Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","docs/docs-partner-fez","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "test@appdynamics.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        
        con.No_longer_at_Company__c = true;
        update con;
	}
	
	public static testMethod void testTestDisablePortalUser2(){
		EnvironmentSettings.testEnvironmentSettings();
		RESTAPI.unitTestMode = true;
    	Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        
        LicenseDetail__c ld = new LicenseDetail__c(License_Expiry_Date__c= System.today());
        insert ld;
        
        License_Contacts__c lc = new License_Contacts__c(Contact__c=con.id,Contact_Type__c='PRIMARY',License__c=ld.id);
        insert lc;
        
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","docs/docs-partner-fez","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "test@appdynamics.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        
        con.No_longer_at_Company__c = true;
        update con;
	}
	
	public static testMethod void testTestDisablePortalUser3(){
		EnvironmentSettings.testEnvironmentSettings();
		RESTAPI.unitTestMode = true;
    	Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        
        LicenseDetail__c ld = new LicenseDetail__c(License_Expiry_Date__c= System.today());
        insert ld;
        
        License_Contacts__c lc = new License_Contacts__c(Contact__c=con.id,Contact_Type__c='PRIMARY',License__c=ld.id);
        insert lc;
        
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","docs/docs-partner-fez","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "test@appdynamics.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":false}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        
        con.No_longer_at_Company__c = false;
        update con;
	}
}