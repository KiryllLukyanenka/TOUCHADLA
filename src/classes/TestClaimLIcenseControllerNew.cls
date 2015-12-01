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
private class TestClaimLIcenseControllerNew {

    static testMethod void testGetContacts() {
        Account acc = new Account(Name='Claim lic account');
        upsert acc;
        
        Opportunity opp = new Opportunity(Name='Calim ic Opp',StageName='A1 - Active',Deal_Type__c='New',Accountid=acc.id,CloseDate=System.now().date());
        upsert opp;
        
        Contact con1  = new Contact(firstName='Test fn1',lastName='Test ln1',email='test1@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        upsert con1;
        Contact con2  = new Contact(firstName='Test fn2',lastName='Test ln2',email='test2@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        upsert con2;
        
        ClaimLIcenseControllerNew ctrlr = new ClaimLicenseControllerNew(new ApexPages.StandardController(opp));
        ctrlr.getContacts();
    }
    
    
    static testmethod void testGetLicenses() {
        Account acc = new Account(Name='Claim lic account');
        upsert acc;
        
        Opportunity opp = new Opportunity(Name='Calim ic Opp',StageName='A1 - Active',Deal_Type__c='New',Accountid=acc.id,CloseDate=System.now().date());
        upsert opp;
        
        EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
	    List<ContactWrapper> contactsList = new List<ContactWrapper>();
        Contact con  = new Contact(firstName='Test fn1',lastName='Test ln1',email='r1340.n1340@test.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        ContactWrapper conWrapper = new ContactWrapper();
        conWrapper.selected = true;
        conWrapper.contactObj = con;
        contactsList.add(conWrapper);
    	ClaimLicenseControllerNew ctrlr = new ClaimLicenseControllerNew(new ApexPages.StandardController(opp));
    	ctrlr.contactsList = contactsList;
    	ctrlr.getLicenses();
        
    	
    }
   
    static testmethod void testClaimLicense() {
        Account acc = new Account(Name='Claim lic account');
        upsert acc;
        
        Opportunity opp = new Opportunity(Name='Calim ic Opp',StageName='A1 - Active',Deal_Type__c='New',Accountid=acc.id,CloseDate=System.now().date());
        upsert opp;

		ClaimLicenseControllerNew.LicenseWrapper licWrapper = new ClaimLicenseControllerNew.LicenseWrapper();
		licWrapper.selected = true;
		licWrapper.contactEmail = 'r1340.n1340@test.com';
		PortalDataType.License licenseObj = new PortalDataType.License();
		licenseObj.MacAddress = '11-11-11-11-11-11';
		licenseObj.ProductType = 'On-Premise';
		licenseObj.saasPassword = 'abcd';
		licenseObj.created_date = '2015-10-12 00:00:42';
		licenseObj.id = '144463324129YWO';
		licenseObj.customerSaasUrl = '';
		licenseObj.saasAccount = '';
		licenseObj.expiryDate = '2015-10-27 00:00:00';
		licenseObj.saasUserName = '';
		licenseObj.stage = 'SELFSERVICE_TRIAL';
		licenseObj.accessKey = '';
		licenseObj.customerName = '';
		licenseObj.salesforceLicenseID = '';
		
		PortalDataType.PortalContact[] contacts = new PortalDataType.PortalContact[2];
		PortalDataType.PortalContact contact1 = new PortalDataType.PortalContact();
		contact1.userID = '6212';
		contact1.lastName = 'N1340';
		contact1.firstName = 'R1340';
		contact1.email = 'r1340.n1340@test.com';
		contact1.user_type = 'primary';
		contact1.subscribeSaasNotification = 'True';
		contact1.subscribeLicenseNotification = 'True';

		PortalDataType.PortalContact contact2 = new PortalDataType.PortalContact();
		contact2.userID = '6213';
		contact2.lastName = 'N1341';
		contact2.firstName = 'R1341';
		contact2.email = 'r1341.n1341@test.com';
		contact2.user_type = 'additional';
		contact2.subscribeSaasNotification = 'True';
		contact2.subscribeLicenseNotification = 'True';
		
		contacts[0] = contact1;
		contacts[1] = contact2;
		
		PortalDataType.LicenseAgent[] agents = new PortalDataType.LicenseAgent[1];
		PortalDataType.LicenseAgent agent = new PortalDataType.LicenseAgent();
		agent.agent_count = 5;
		agent.agent_type = '.Net';
		agents[0] = agent;
		
		licenseObj.license_agents = agents;
		licenseObj.contacts = contacts;
		
		licWrapper.licenseObj = licenseObj;
		
		ClaimLicenseControllerNew.LicenseWrapper[] lics = new ClaimLicenseControllerNew.LicenseWrapper[1];
		lics[0] = licWrapper; 
		
    	ClaimLicenseControllerNew ctrlr = new ClaimLicenseControllerNew(new ApexPages.StandardController(opp));
    	ctrlr.licenseWrappers = lics;
    	ctrlr.claimLicense();
    }   
   
}