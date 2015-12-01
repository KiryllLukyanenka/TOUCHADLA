public with sharing class AssociateLicenseToOpportunityController extends AbstractAppDController {
	
	
	public LicenseDetail__c licenseDetailObj {get;set;}
	public License_Opportunity__c licenseOpportunityObj {get;set;}
	public String pageTitle {get;set;}
	public String licenseId {get;set;}
	public License_System__c licenseSystem{get;set;}
	public Contact primaryContact {get;set;}
	public Opportunity myOpportunity {get;set;}
	public ADUAController_V2.ADUAUser adUsers {get;set;}
	public ADUAUI aduaUIObj{get;set;}
	public Account accountObj {get;set;}
	public OpportunityContactRole selectedOppCt {get;set;}
	public OpportunityContactRole newOppCt {get;set;}
	
	public Boolean containsOppCtRole {get;set;}
	public Boolean showPanel {get;set;}
	
	public String selectedContact {get;set;}    
	
	/**
     * Standard Controller Constructor. 
     */
	public AssociateLicenseToOpportunityController(ApexPages.StandardController stdCtrlr){
        super(stdCtrlr);
    }
    
    /**
     * Overriden init method called from the Super Class AppDController's constructor.  
     */
    public override void init(){
    	try{
            super.init();
            loggerHandle.setClassName(AssociateLicenseToOpportunityController.class.getName());
	    	licenseId =  ApexPages.currentPage().getParameters().get('LicenseId');
	    	//containsOppCtRole = false;
	    	showPanel = false;
	    	pageTitle = '';
	    	if(licenseId!=null && !licenseId.trim().equals('') && !licenseId.trim().equalsIgnoreCase('null')){
				licenseDetailObj = (LicenseDetail__c) DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
				licenseOpportunityObj = (License_Opportunity__c)pageContextObj;
				licenseOpportunityObj.License__c = licenseDetailObj.id;  
				
				try{
                licenseSystem = [ select Id, License__c, System__c from License_System__c where License__c=:licenseDetailObj.id LIMIT 1];
                }catch(Exception e)
                {
                    //Creating a new license_system object
                    licenseSystem = new License_System__c();
                    licenseSystem.License__c = licenseDetailObj.Id;

                } 
				List<License_Contacts__c> licContacts = [Select License__c,Contact__r.Id,Contact__r.Name,Contact__r.Docs__c,Contact__r.Download__c,
														Contact__r.ZenDesk__c,Contact__r.LMS__c,Contact__r.FirstName,Contact__r.LastName,Contact__r.Email,
														Contact__r.No_longer_at_Company__c,Contact__r.Needs_Email__c,Contact_Type__c,Need_Operations_Email__c,Need_Service_Email__c
														 from License_Contacts__c where License__c=:licenseDetailObj.Id and Contact_Type__c='PRIMARY'];
														 
				if(licContacts!=null && licContacts.size()>0){	
					License_Contacts__c lc = licContacts.get(0);											 
					primaryContact = (Contact) DataLayerConstants.fetchSingle('Contact',lc.Contact__r.Id);
				}
	    	}
    	}catch(Exception e){
    		//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,''+e.getStackTraceString());
			//ApexPages.addMessage(myMsg);
    	}
    }
    
    public override Boolean validateObject(){
    	if(licenseOpportunityObj.Opportunity__c == null){
    		errorMessage = 'Please select opportunity.';
    		return false;
    	}
    	
    	if(selectedContact==null || selectedContact.equals('azureContact')){
    		if(newOppCt!=null && newOppCt.Role==null){
    			errorMessage = 'Please select role for Azure user.';
    			return false;
    		}
    	}
    	
    	return true;
    }
    
    public PageReference selectedLicenseOpportunity(){
    	if(licenseOpportunityObj.Opportunity__c!=null){
	    	myOpportunity = (Opportunity)DataLayerConstants.fetchSingle('Opportunity',licenseOpportunityObj.Opportunity__c);
	    	accountObj = (Account) DataLayerConstants.fetchSingle('Account', myOpportunity.AccountId+'');
			//Fetching Opportunity Contact Role
			try{
				selectedOppCt = [Select Id,ContactId,Contact.ID,Contact.Email,Contact.Name,IsPrimary,OpportunityId,Role from OpportunityContactRole where OpportunityID=:myOpportunity.Id and IsPrimary = true];
				selectedContact = 'existingContact';
				try{
					containsOppCtRole = !selectedOppCt.Contact.Id.equals(primaryContact.Id);
				}catch(Exception e){
                    //Setting this to true in any error in determining the contact role is same as the primary contact of license
					containsOppCtRole = true;
				}
				showPanel = false;
			}catch(Exception e){
				containsOppCtRole = false;
				showPanel = true;
				selectedContact = 'azureContact';						
			}
			newOppCt = new OpportunityContactRole();
			newOppCt.Role = 'Champion';
    	}
    	return null;
    }
    
    public PageReference saveLicenseOpportunity(){
    	if(licenseOpportunityObj.Opportunity__c!=null){
	    	//Migrating the contact to opportunity Account
			primaryContact.AccountId = myOpportunity.AccountId;
			accountObj = (Account) DataLayerConstants.fetchSingle('Account', primaryContact.AccountId+'');
			List<Contact> contacts = new List<Contact>();
			contacts.add(primaryContact);
			String requestJson = UsersUtil.getUserDetailsRequestJson(contacts,accountObj.Name);
			adUsers = UserDetailsBackend.getUserDetails(requestJson);
			ADUAController_V2.ADUAUserDetails aduaUser = null;    
	        if(adUsers!=null){
	            aduaUser = adUsers.users[0];
	        }
	        if(aduaUser!=null){
				aduaUIObj = ADUAUI.newInstance(primaryContact,aduaUser);
	        }
    	}
    	return saveObject();	
    }
    
    public override virtual void setupBackend(){
    	if(aduaUIObj!=null){
	    	aduaUIObj.updateADUAUserDetails(null);
	        backend = new BackendLayer();
	        AccountBackend accBackend = new AccountBackend(accountObj,BackendConstants.OPCODE_ADD_COMPANY);
	        backend.addBackend(accBackend);
	        ContactBackend_V2 ctcBackend= new ContactBackend_V2(aduaUIObj.aduaUser,accountObj,BackendConstants.OPCODE_ADD_USER);
	        backend.addBackend(ctcBackend);
    	}
    }
    
    public override virtual Boolean doPreSave(){
    	
    	if(selectedContact==null || selectedContact.equals('azureContact')){
    		newOppCt.OpportunityId = myOpportunity.id;
    		newOppCt.ContactId = primaryContact.id;
    		newOppCt.IsPrimary = true;
    		insert newOppCt;
    	}
    	
    	//Changing License system from Azure-Store to Sales-led
		licenseSystem.System__c = 'Sales-Led';
    	upsert licenseSystem;
    	
    	update primaryContact; 
    	
    	
    	return true;
    }
    
    public override virtual PageReference doPostSave(){
    	if(licenseId!=null){
            PageReference ref = new PageReference('/'+licenseId);
            ref.setRedirect(true);
            return ref;
        }
        return null;
  	}
    
    public override virtual PageReference doCancel(){
        if(licenseId!=null){
            PageReference ref = new PageReference('/'+licenseId);
            ref.setRedirect(true);
            return ref;
        }
        return null;
    }
    
    public static testMethod void testAssociateLicenseToOpportunityController1(){
    	EnvironmentSettings.testEnvironmentSettings();
    	RESTAPI.unitTestMode = true;
    	Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        Contact_Portal_User__c contactPortalUser = null;
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            //contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
            contactPortalUser = new Contact_Portal_User__c();
            contactPortalUser.put('Contact__c',con.Id);
            insert contactPortalUser;
        }
        Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=acc.id,CloseDate=System.now().date());
    	insert opp; 
    	LicenseDetail__c lic= new LicenseDetail__c();
    	lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
    	lic.License_Expiry_Date__c=System.now().date().addDays(10);
    	lic.Stage__c='PAID_TEMP';
    	upsert lic;
    	License_System__c licenseSystem = new License_System__c();
    	licenseSystem.License__c = lic.id;
    	licenseSystem.System__c = 'Azure-Store';
    	insert licenseSystem;
    	UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "'+con.email+'", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
    	AssociateLicenseToOpportunityController associateCtl = new AssociateLicenseToOpportunityController(new ApexPages.Standardcontroller(new License_Opportunity__c()));
    	associateCtl.licenseOpportunityObj = new License_Opportunity__c();
    	associateCtl.licenseOpportunityObj.Opportunity__c = opp.id;
    	associateCtl.licenseOpportunityObj.License__c = lic.id;
    }
    
    public static testMethod void testAssociateLicenseToOpportunityController2(){
    	EnvironmentSettings.testEnvironmentSettings();
    	RESTAPI.unitTestMode = true;
    	Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        Contact_Portal_User__c contactPortalUser = null;
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            //contactPortalUser = new Contact_Portal_User__c(Contact__c=con.id);
            contactPortalUser = new Contact_Portal_User__c();
            contactPortalUser.put('Contact__c',con.Id);
            insert contactPortalUser;
        }
        Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=acc.id,CloseDate=System.now().date());
    	insert opp; 
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=con.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	LicenseDetail__c lic= new LicenseDetail__c();
    	lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
    	lic.License_Expiry_Date__c=System.now().date().addDays(10);
    	lic.Stage__c='PAID_TEMP';
    	upsert lic;
    	License_System__c licenseSystem = new License_System__c();
    	licenseSystem.License__c = lic.id;
    	licenseSystem.System__c = 'Azure-Store';
    	insert licenseSystem;
    	
    	License_Contacts__c lc = new License_Contacts__c(License__c=lic.id,Contact__c=con.id,Contact_Type__c='PRIMARY');
    	insert lc; 
    	
    	UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "'+con.email+'", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
    	con = (Contact)DataLayerConstants.fetchSingle('Contact', con.id);//[select id,email,Accountid,(select id,Contact__c,Download__c,Docs__c,LMS__c,ZenDesk__c from Contact_portal_user__r) from contact where id=:con.id];
    	Pagereference page = new PageReference('/apex/AssociateLicenseToOpportunity.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
    	
    	AssociateLicenseToOpportunityController associateCtl = new AssociateLicenseToOpportunityController(new ApexPages.Standardcontroller(new License_Opportunity__c()));
    	associateCtl.primaryContact = con;
    	associateCtl.licenseOpportunityObj = new License_Opportunity__c();
    	associateCtl.licenseOpportunityObj.Opportunity__c = opp.id;
    	associateCtl.licenseOpportunityObj.License__c = lic.id;
    	associateCtl.selectedLicenseOpportunity();
    	associateCtl.saveLicenseOpportunity();
    	associateCtl.selectedContact = 'azureContact';
    	associateCtl.doPreSave();
    	associateCtl.doPostSave();
    	associateCtl.doCancel();
    }
    
    public static testMethod void testAssociateLicenseToOpportunityController3(){
    	EnvironmentSettings.testEnvironmentSettings();
    	RESTAPI.unitTestMode = true;
    	Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        Contact_Portal_User__c contactPortalUser = null;
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            //contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
            contactPortalUser = new Contact_Portal_User__c();
            contactPortalUser.put('Contact__c',con.Id);
            insert contactPortalUser;
        }
        Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=acc.id,CloseDate=System.now().date());
    	insert opp; 
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=con.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	LicenseDetail__c lic= new LicenseDetail__c();
    	lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
    	lic.License_Expiry_Date__c=System.now().date().addDays(10);
    	lic.Stage__c='PAID_TEMP';
    	upsert lic;
    	License_System__c licenseSystem = new License_System__c();
    	licenseSystem.License__c = lic.id;
    	licenseSystem.System__c = 'Azure-Store';
    	insert licenseSystem;
    	
    	License_Contacts__c lc = new License_Contacts__c(License__c=lic.id,Contact__c=con.id,Contact_Type__c='PRIMARY');
    	insert lc; 
    	
    	UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "'+con.email+'", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
    	
    	Pagereference page = new PageReference('/apex/AssociateLicenseToOpportunity.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
    	
    	AssociateLicenseToOpportunityController associateCtl = new AssociateLicenseToOpportunityController(new ApexPages.Standardcontroller(new License_Opportunity__c()));
    	associateCtl.licenseOpportunityObj = new License_Opportunity__c();
    	associateCtl.validateObject();
    }
    
    public static testMethod void testAssociateLicenseToOpportunityController4(){
    	EnvironmentSettings.testEnvironmentSettings();
    	RESTAPI.unitTestMode = true;
    	Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        Contact_Portal_User__c contactPortalUser = null;
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            //contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
            contactPortalUser = new Contact_Portal_User__c();
            contactPortalUser.put('Contact__c',con.Id);
            insert contactPortalUser;
        }
        Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=acc.id,CloseDate=System.now().date());
    	insert opp; 
    	OpportunityContactRole opc = new OpportunityContactRole(Contactid=con.id,Opportunityid = opp.id,isPrimary=true);
    	insert opc;
    	LicenseDetail__c lic= new LicenseDetail__c();
    	lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
    	lic.License_Expiry_Date__c=System.now().date().addDays(10);
    	lic.Stage__c='PAID_TEMP';
    	upsert lic;
    	License_System__c licenseSystem = new License_System__c();
    	licenseSystem.License__c = lic.id;
    	licenseSystem.System__c = 'Azure-Store';
    	insert licenseSystem;
    	
    	License_Contacts__c lc = new License_Contacts__c(License__c=lic.id,Contact__c=con.id,Contact_Type__c='PRIMARY');
    	insert lc; 
    	
    	UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "'+con.email+'", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
    	
    	Pagereference page = new PageReference('/apex/AssociateLicenseToOpportunity.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
    	
    	AssociateLicenseToOpportunityController associateCtl = new AssociateLicenseToOpportunityController(new ApexPages.Standardcontroller(new License_Opportunity__c()));
    	associateCtl.licenseOpportunityObj = new License_Opportunity__c();
    	associateCtl.licenseOpportunityObj.Opportunity__c = opp.id;
    	associateCtl.validateObject();
    }
    
}