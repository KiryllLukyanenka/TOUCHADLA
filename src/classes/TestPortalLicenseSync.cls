@IsTest
public with sharing class TestPortalLicenseSync {
	static testmethod void testSync(){
		String license = '{"users": [{"licenses": [{"eum": {"web_agent_units": "5", "mobile_type": "MOBILE_PRO", "eum_access_key": "d011b7a2-bee8-42d0-bcae-0741ca70d179", "eum_account_name": "6212-ss-R1340N1340Comp-1zcx4s06r1mj", "mobile_agent_units": "5", "web_eum_type": "EUM_PRO", "mobile_allow_overage": "False", "web_allow_overage": "False"}, "MacAddress": "", "licenseType": "selfservice-pro-trial", "customerName": "", "saasPassword": "", "accessKey": "", "license_contacts": [{"lastName": "N1340", "email": "r1340.n1340@test.com", "user_type": "primary"}, {"lastName": "N1341", "email": "r1341.n1341@test.com", "user_type": "additional"}, {"lastName": "OpT_2015_8_24__1_25_29", "email": "opt_2015_8_24__1_25_29_3@test.com", "user_type": "additional"}], "contacts": [{"firstName": "R1340", "lastName": "N1340", "userID": 6212, "user_type": "primary", "subscribeLicenseNotification": "True", "subscribeSaasNotification": "False", "email": "r1340.n1340@test.com"}, {"firstName": "R1341", "lastName": "N1341", "userID": 6213, "user_type": "additional", "subscribeLicenseNotification": "True", "subscribeSaasNotification": "False", "email": "r1341.n1341@test.com"}, {"firstName": "FName_3", "lastName": "OpT_2015_8_24__1_25_29", "userID": 5498, "user_type": "additional", "subscribeLicenseNotification": "True", "subscribeSaasNotification": "False", "email": "opt_2015_8_24__1_25_29_3@test.com"}], "expiryDate": "2015-10-27 00:00:00", "license_agents": [{"agent_count": "5", "agent_type": ".Net"}, {"agent_count": "5", "agent_type": "Database"}, {"agent_count": "5", "agent_type": "Java"}, {"agent_count": "5", "agent_type": "NodeJs"}, {"agent_count": "5", "agent_type": "PHP"}, {"agent_count": "5", "agent_type": "Python"}, {"agent_count": "0", "agent_type": "Machine"}, {"agent_count": "5", "agent_type": "EUM_PRO"}, {"agent_count": "5", "agent_type": "MOBILE_PRO"}], "customerSaasUrl": "", "saasAccount": "", "created_date": "2015-10-12 00:00:42", "ProductType": "On-Premise", "saasUserName": "", "id": "144463324129YWO", "stage": "SELFSERVICE_TRIAL"}], "user_id": 6212, "email": "r1340.n1340@test.com", "company_id": 11572}]}';
		
	  	PortalLicenseSynch portalLicSynch = new PortalLicenseSynch();
		RESTAPI.unitTestMode = true;
		Account acc = new Account(Name='AccTest');
		insert acc;
		Contact con  = new Contact(firstName='Fname',lastName='Opt',email='r1341.n1341@test.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
		insert con;
		Contact con2  = new Contact(firstName='Fname 2',lastName='Opt 2',email='opt_2015_8_24__1_25_29_3@test.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
		insert con2;
		
		/*Contact con  = new Contact(firstName='Fname 2',lastName='Opt 2',email='r1502.n1502@test.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
		insert con;*/
		
        Lead leadObj = new Lead();
        leadObj.FirstName='fName';
        leadObj.LastName = 'lName';
        leadObj.Email = 'r1340.n1340@test.com';
        leadObj.Company = 'R340N1340Comp';
        insert leadObj;
		
		
		
		List<String> emails = new List<String>();
		emails.add('r1340.n1340@test.com');
		
		portalLicSynch.emailIds = emails;
		portalLicSynch.accountIdForLeadConvert = acc.id;
		//portalLicSynch.userLicenses = u.users;
		portalLicSynch.action = PortalLicenseSynch.ACTION_PULL;
		System.debug('User lic : ' + portalLicSynch.userLicenses);
		portalLicSynch.synch();
		
        PortalDataType.Users u = (PortalDataType.Users) System.JSON.deserialize(license,PortalDataType.Users.class);
		portalLicSynch.action = PortalLicenseSynch.ACTION_STORE_LICENSES;
		portalLicSynch.userLicenses = u.users;
		portalLicSynch.synch();
	}
	
}