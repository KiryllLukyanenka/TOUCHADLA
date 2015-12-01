@IsTest(SeeAllData=true) 
private class DBTunaProvisionTest {
	
	static testMethod void testForDatabaseLicense(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,Email='test@test.com');
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();
    	DBTuna_License__c lic = (DBTuna_License__c)ctrl.pageContextObj;
    	lic.ExpiryDate__c = System.now().date().addDays(4);
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	ctrl.saveObject();
    	ctrl.doCancel();
    	EmailUtil.sendLMSUserRegistrationEmail('232323', 'TestName', 'test@test.com');
    }
    
    static testMethod void testForDatabaseLicenseWithServerNameNull(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,Email='test@test.com');
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	DBTuna_License__c lic = (DBTuna_License__c)ctrl.pageContextObj;
    	lic.ExpiryDate__c = System.now().date().addDays(4);
    	lic.Server_Name__c = null;
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	ctrl.initAction();
    	ctrl.saveObject();
    	ctrl.doCancel();
    }
    
    static testMethod void testForDatabaseLicenseWithExpiryDateToday(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,Email='test@test.com');
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();
    	DBTuna_License__c lic = (DBTuna_License__c)ctrl.pageContextObj;
    	lic.ExpiryDate__c = System.now().date();
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	ctrl.saveObject();
    	ctrl.doCancel();
    }
    
    static testMethod void testForDatabaseLicenseWithExpiryDateNull(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,Email='test@test.com');
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();
    	DBTuna_License__c lic = (DBTuna_License__c)ctrl.pageContextObj;
    	lic.ExpiryDate__c = null;
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	ctrl.saveObject();
    	ctrl.doCancel();
    }
    
    static testMethod void testForDatabaseLicenseWithNoPrimaryContact(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,Email='test@test.com');
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();
    	DBTuna_License__c lic = (DBTuna_License__c)ctrl.pageContextObj;
    	lic.ExpiryDate__c = null;
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	ctrl.saveObject();
    	ctrl.doCancel();
    }
    
    static testMethod void testForDatabaseLicenseWithContactEmailNull(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id);
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();
    	DBTuna_License__c lic = (DBTuna_License__c)ctrl.pageContextObj;
    	lic.ExpiryDate__c = null;
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	ctrl.saveObject();
    	ctrl.doCancel();
    }
    
    static testMethod void testForDatabaseLicenseAndGetDBLicensesForOpportunities(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,Email='test@test.com');
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	
    	DBTuna_License__c lic = new DBTuna_License__c();
    	lic.ExpiryDate__c = System.now().date().addDays(4);
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	insert lic;
    	
    	List<String> opportunityIds = new List<String>();
    	opportunityIds.add(opp.id);
    }
    
    static testMethod void testForDatabaseLicenseDetails(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,Email='test@test.com');
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	DBTuna_License__c lic = new DBTuna_License__c();
    	lic.ExpiryDate__c = System.now().date().addDays(4);
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	insert lic;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	/*Pagereference ref = new PageReference('/apex/DBTunaLicenseDetails');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Id',lic.Id);*/
    	//DBTunaLicenseDetailsController ctrl = new DBTunaLicenseDetailsController(stdCtrler);
    	//ctrl.lic = lic;  
    }   
    
    static testMethod void testForDBTunaLicenseDetails(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,Email='test@test.com');
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	
    	DBTuna_License__c lic = new DBTuna_License__c();
    	lic.ExpiryDate__c = System.now().date().addDays(4);
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	insert lic;
    	  
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(lic);
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseDetails/'+lic.id);
    	Test.setCurrentPage(ref);
    	
    	DBTunaLicenseDetailsController ctrl = new DBTunaLicenseDetailsController(stdCtrler);
    
    }
    
     static testMethod void testForDBTunaProvisionController(){
        
        RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id);
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();
    	DBTuna_License__c lic = (DBTuna_License__c)ctrl.pageContextObj;
    	lic.ExpiryDate__c = System.now().date().addDays(4);
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	ctrl.saveObject();               
     
     }
     
     static testMethod void testForDBTunaProvisionControllerWithDifferentPrimaryContact(){
        
        RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	
    	Account standardAccount2 = new Account(Name='Test2');
    	insert standardAccount2;
    	
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id);
    	insert standardContact; 
    	
    	Contact standardContact2 = new Contact(LastName='TestName2',AccountId=standardAccount2.id);
    	insert standardContact2; 
    	
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact2.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();
    	DBTuna_License__c lic = (DBTuna_License__c)ctrl.pageContextObj;
    	lic.ExpiryDate__c = System.now().date().addDays(4);
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	ctrl.saveObject();               
     
     }
     
     static testMethod void testForDBTunaProvisionControllerWithNoContacts(){
        
        RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();               
     }
     
     static testMethod void testForDBTunaProvisionControllerWithPrimaryContactNoLongerAtCompany(){
        
        RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,No_longer_at_Company__c = true);
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();
    	DBTuna_License__c lic = (DBTuna_License__c)ctrl.pageContextObj;
    	lic.ExpiryDate__c = System.now().date().addDays(4);
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	ctrl.saveObject();               
     
     }
     
     static testMethod void testForDBTunaProvisionControllerDoPreSave(){
        
        RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id);
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();
    	DBTuna_License__c lic =  new DBTuna_License__c();
		ctrl.pageContextObj = lic;
    	lic.ExpiryDate__c = System.now().date().addDays(4);
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	insert lic;
    	try{
    	for(ContactWrapper ctWrapper:ctrl.aduaContactsHelper.contactWrapperList){
    		ctWrapper.contactObj.Needs_Email__c = true;
    	}
    	
    	ctrl.saveObject();               
    	ctrl.doPostSave();
    	}catch(Exception e){}
     }
     
     static testMethod void testForDatabaseLicenseHistory(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,Email='test@test.com');
    	insert standardContact; 
    	Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=standardAccount.id,CloseDate=System.now().date());
    	insert opp;
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=standardContact.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	ApexPages.Standardcontroller stdCtrler = new ApexPages.Standardcontroller(new DBTuna_License__c());
    	Pagereference ref = new PageReference('/apex/DBTunaLicenseProvision');
    	Test.setCurrentPage(ref);
    	ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
    	DBTunaProvisionController ctrl = new DBTunaProvisionController(stdCtrler);
    	ctrl.initAction();
    	DBTuna_License__c lic = (DBTuna_License__c)ctrl.pageContextObj;
    	lic.ExpiryDate__c = System.now().date().addDays(4);
    	lic.Server_Name__c = 'TestServerName';
    	lic.LicenseKey__c = 'aksdkladksadla';
    	lic.Opportunity__c = opp.id;
    	insert lic;
    	update lic;
    	
    	GenericHistoryController ghc = new GenericHistoryController();
    	ghc.myObject = lic;
    	ghc.getObjectHistory();
    	GenericHistoryController.objectHistoryLine ohl = new GenericHistoryController.objectHistoryLine(); 
    }
    	
}