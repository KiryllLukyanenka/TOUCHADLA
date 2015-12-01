public with sharing class ADUAController_V2 extends AbstractAppDController{
    private String contactID;
    public String pageTitle{get;set;}
    public ADUAUser adUsers {get;set;}
    public Contact contactObj {get;set;}
    public Account contactAcc {get;set;}
    public Boolean isPartnerLoggedIn {get;set;}
    public ADUAUI aduaUIObj{get;set;} 
    
    /**
     * Standard Controller Constructor. 
     */ 
    public ADUAController_V2(ApexPages.StandardController stdController){
        super(stdController);
    }
    
    /**
     * Overriden init method called from the Super Class AppDController's constructor.  
     */
    public override void init(){
    	super.init();
        if(contactId==null){
            contactId = ApexPages.currentPage().getParameters().get('ContactId');
        }
    }
    
    public  PageReference initAction(){
        try{
        	/*if(loggerHandle==null){
        		loggerHandle =Logger.getLogger('ADUAController_V2');
        	}*/
        	loggerHandle.setClassName(ADUAController_V2.class.getName());
        if(contactId!=null){
            contactObj = (Contact)DataLayerConstants.fetchSingle('Contact',contactId);
            if(contactObj.AccountId!=null){
            	contactAcc=(Account)DataLayerConstants.fetchSingle('Account',contactObj.AccountId);//contactObj.Account;
            }
            loggerHandle.debug('Initializing ADUA Page for contact:'+contactId+ ' of Account:'+contactObj.AccountId);
        }
        
        if(contactAcc!=null){
        	disableUIComponent = false;
	        isPartnerLoggedIn = UsersUtil.isPartner(contactAcc);        
	        
	        if(contactObj!=null){
	            pageContextObj= contactObj;
	        }
	        pageTitle = 'Setup AppDynamics User Account for Contact: ';
	        pageTitle +=contactObj.Name;
            String cName = contactAcc.Name.replace('\\','');
	        String requestJson = '{"companyName":"'+cName.replaceAll('"','\\\\"')+'","emails":["'+contactObj.email+'"]}';
	        adUsers = UserDetailsBackend.getUserDetails(requestJson);
	        ADUAUserDetails aduaUser = null;    
	        if(adUsers!=null){
	            aduaUser = adUsers.users[0];
	        }
	        
	        List<Contact> contactList = new List<Contact>();
	        contactList.add(contactObj);
	        contactObj = UsersUtil.getContactPortalUsers(contactList, contactAcc).get(0);
	        aduaUIObj=ADUAUI.newInstance(contactObj,aduaUser);
        } else{
        	disableUIComponent = true;
        	errorMessage = 'Please associate contact with an Account.';
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);
            ApexPages.addMessage(myMsg);
            loggerHandle.error(errorMessage);
        }
        
        }catch(Exception e){
        	
            loggerHandle.error(e.getMessage(),e);
        }
        
        return null;
    }
    
    public String downloadsVisible{get;set;}
	public String docsVisible{get;set;}
    
	/**
     * Implementation of Validation method to put validation code specific to ADUA operations.
     * This will be called during save process from the super class.
     */
    public override Boolean validateObject(){
    	if(contactObj.Email== null || contactObj.Email.trim()==''){
			errorMessage = 'Please provide Email ID for the Contact when AppDynamics Access is enabled';
			return false;
		}
		if(contactObj.AccountId == null){
			errorMessage = 'Please select the account to which the Contact belongs';
			return false;
		}
		/*if(aduaUser.applications!=null && aduaUser.applications.size()==0){
			errorMessage = 'Please select the systems to which the user has access to under Accessible Systems for AppDynamics';
			return false;
		}*/
		if(aduaUIObj.active){
			if(aduaUIObj.systemEntries!=null && aduaUIObj.systemEntries.size()>0){
				Boolean isSelected = false;
				Boolean isDownloadSelected = false;
				Boolean isDownloadZoneSelected = false;
				
				for(ADUAUI.SystemEntry se: aduaUIObj.systemEntries){
					if(se.selected){
						isSelected = true;
						if(se.systemName.equals(AppDConstants.ACCESSIBLE_DOWNLOADS)){
							isDownloadSelected = true;
							for(ADUAUI.ADUAZoneDetails ad: aduaUIObj.zoneList){
								if(ad.selected){
									isDownloadZoneSelected = true;
								}
							}
						}
					}
				}
				if(!isSelected){
					errorMessage = 'Please select the systems to which the user has access to under Accessible Systems for AppDynamics';
					return false;
				}
				
				if(isDownloadSelected && !isDownloadZoneSelected){
					errorMessage = 'Please select download zone(s) for the user access.';
					return false;
				}
			}
		}
		return true;
    }
    
	/**
    * Overriding setupbackend to initialize backend calls and parameters based on 
    * the operation being carriedout as Save/Update and Delete.
    */
    public override void setupBackend(){
    	aduaUIObj.updateADUAUserDetails(null);
    	backend = new BackendLayer();
		AccountBackend accBackend = new AccountBackend(contactAcc,BackendConstants.OPCODE_ADD_COMPANY);
        backend.addBackend(accBackend);
		ContactBackend_V2 ctcBackend= new ContactBackend_V2(aduaUIObj.aduaUser,contactAcc,BackendConstants.OPCODE_ADD_USER);
		backend.addBackend(ctcBackend);
    }
    
    public override PageReference doCancel(){
    	if(contactID!=null){
            PageReference ref = new PageReference('/'+contactID);
            ref.setRedirect(true);
            return ref;
        }
        return null;
    }
    
    public override boolean doPreSave(){
    	try{
        	
        	try{
				String response = backend.getResponse(BackendConstants.OPCODE_ADD_COMPANY);
         		String ctResponse = backend.getResponse(BackendConstants.OPCODE_ADD_USER);
         		loggerHandle.debug('Resonse for Company Call:'+response);
         		loggerHandle.debug('Resonse for User Call:'+ctResponse);
         		String companyId = response;
         		Account_Portal_Company__c accountPortalCompany = null; 
                if(response!=null){
                	if(contactAcc!=null){
                		accountPortalCompany = AccountContactsADUAHelper.saveAccountPortalDetails(response, contactAcc);
                	}
				}
                JSONObject jsonResponse = new JSONObject(new JSONObject.JSONTokener(ctResponse));
                System.debug( 'PortalID__c adua'+jsonResponse.getValue(contactObj.Email).num+'' );
                
				String portalId = jsonResponse.getValue(contactObj.Email).num+'';
				Contact_Portal_User__c contactPortalUser = (Contact_Portal_User__c)contactObj.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).get(0);
				contactPortalUser.User_Portal_Id__c = portalId;
            	
            	/*
            		Changing the page context object to contact_portal_user. 
            	*/  
                if(contactPortalUser!=null){
                	upsert contactPortalUser;
                	pageContextObj = contactPortalUser;
                }
                
                if(aduaUIObj.isChanged()){
                	UsersUtil.saveContactHistory(aduaUIObj,contactPortalUser,CommonUtil.getPageName(),'ADAUController_V2', backend.getStatusCode(BackendConstants.OPCODE_ADD_USER));
                }
            	ADUAUtils.setupADUAContact(contactObj, aduaUIObj.aduaUser.getApplications());    
            	
                //contactObj.PortalID__c = jsonResponse.getValue(contactObj.Email).num+'';
			}catch(Exception e){
            	System.debug(e);
            	loggerHandle.warn(e.getMessage(),e);
			}
            //upsert contactObj;  
        }
        catch(Exception e){
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(myMsg);
            ApexPages.addMessage(myMsg);
            loggerHandle.error(e.getMessage(),e);
        } 
        return true;
    }
    
    public override PageReference doPostSave(){
    	loggerHandle.debug('Finished ADUA for Contact'+ contactId);
    	PageReference ref = new PageReference('/'+contactId);
		ref.setRedirect(true);
		return ref;
    }

    public class ADUAUser{
        public  ADUAUserDetails[] users{get;set;}
        public  String name{get;set;}
        public String accounts_groups{get;set;}
        public String companyId{get;set;}
        public String getUserApiStatus{get;set;}
        public String getUserDetailsResponse{get;set;}
    }
    
    public class ADUAUserDetails{
        public  String email{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String userId{get;set;}
        public String isActive{get;set;}
        public String contactId{get;set;}
        public Contact_Portal_User__c contactUserObj{get;set;}
        public transient ContactWrapper conWrapper{get;set;}
        public Set<String> applications;
        public String getUserApiStatus{get;set;}
        public String getUserDetailsResponse{get;set;}
        
        public String getApplications(){
            String app = '';
        if(applications!=null){
                for(String application: applications){
                    app += application + ';';
                }
        }
            return app;
        }
    }
    
    /*
    	Test cases for the new ADUA controller
    */
    public static testMethod void testADUAController_V2_1(){
    	EnvironmentSettings.testEnvironmentSettings();
    	RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account',PortalID__c='123456');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@tarams.com',Accountid=acc.id);
        insert con;
        
        Contact_Portal_User__c contactPortalUser = null;
    	if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
			//contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
			contactPortalUser = new Contact_Portal_User__c();
			contactPortalUser.put('Contact__c',con.Id);
			insert contactPortalUser;
    	}
        
        con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        
        Pagereference page = new PageReference('/apex/ADUA_page_v2.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('ContactId',con.Id);
        CommonUtil.addZones();
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","docs/docs-partner-fez","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUAController_V2 ad = new ADUAController_V2(new ApexPages.Standardcontroller(con));
        ad.initAction();
        ad.setupBackend();
        ad.saveObject();
        UsersUtil.saveContactHistory(ad.aduaUIObj,contactPortalUser,'TestPage','ADAUController_V2', '200');
        ad.doCancel();
        ad.doPostDelete();
        ad.doPreDelete();
    }
    
    public static testMethod void testADUAController_V2_2(){
    	EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@tarams.com',Accountid=acc.id);
        insert con;
        
        Contact_Portal_User__c contactPortalUser = null;
    	if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
			//contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
			contactPortalUser = new Contact_Portal_User__c();
			contactPortalUser.put('Contact__c',con.Id);
			insert contactPortalUser;
    	}
        
        con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        
        Pagereference page = new PageReference('/apex/ADUA_page_v2.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('ContactId',con.Id);
        CommonUtil.addZones();
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": [], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":false}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUAController_V2 ad = new ADUAController_V2(new ApexPages.Standardcontroller(con));
        ad.initAction();
        ad.setupBackend();
        ad.saveObject();
        UsersUtil.saveContactHistory(ad.aduaUIObj,contactPortalUser,'TestPage','ADAUController_V2', '200');
        ad.doCancel();
        ad.doPostDelete();
        ad.doPreDelete();
    }
    
    public static testMethod void testADUAController_V2_3(){
    	EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@tarams.com',Accountid=acc.id);
        insert con;
        
        Contact_Portal_User__c contactPortalUser = null;
    	if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
			//contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
			contactPortalUser = new Contact_Portal_User__c();
			contactPortalUser.put('Contact__c',con.Id);
			insert contactPortalUser;
    	}
        
        con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        
        Pagereference page = new PageReference('/apex/ADUA_page_v2.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('ContactId',con.Id);
        CommonUtil.addZones();
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": [], "userId": null, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":false}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUAController_V2 ad = new ADUAController_V2(new ApexPages.Standardcontroller(con));
        ad.initAction();
    }
    
    public static testMethod void testADUAController_V2_4(){
    	EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account',PortalID__c='123456');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@tarams.com',Accountid=acc.id);
        insert con;
        
        Contact_Portal_User__c contactPortalUser = null;
    	if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
			//contactPortalUser = new Contact_Portal_User__c(Contact__c=con.id);
			contactPortalUser = new Contact_Portal_User__c();
			contactPortalUser.put('Contact__c',con.Id);
			insert contactPortalUser;
    	}
        
        con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        
        Pagereference page = new PageReference('/apex/ADUA_page_v2.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('ContactId',con.Id);
        CommonUtil.addZones();
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUAController_V2 ad = new ADUAController_V2(new ApexPages.Standardcontroller(con));
        ad.initAction();
        ad.setupBackend();
        ad.saveObject();
        
        for(ADUAUI.SystemEntry sy: ad.aduaUIObj.getSystemEntries()){
        	if(sy.selected==true){
        		sy.selected = false;
        	} else{
        		sy.selected = true;
        	}
        }
        if(ad.aduaUIObj.fez == true){
        	ad.aduaUIObj.fez = false;
        }else{
        	ad.aduaUIObj.fez = true;
        }
        ad.aduaUIObj.updateADUAUserDetails(null);
        UsersUtil.saveContactHistory(ad.aduaUIObj,contactPortalUser,'TestPage','ADAUController_V2', '200');
        ad.doCancel();
        ad.doPostDelete();
        ad.doPreDelete();
    }
    
    public static testMethod void testADUAController_V2_5(){
    	EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',Accountid=acc.id);
        insert con;
        
        Contact_Portal_User__c contactPortalUser = null;
    	if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
			//contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
			contactPortalUser = new Contact_Portal_User__c();
			contactPortalUser.put('Contact__c',con.Id);
			insert contactPortalUser;
    	}
          
        con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        
        Pagereference page = new PageReference('/apex/ADUA_page_v2.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('ContactId',con.Id);
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUAController_V2 ad = new ADUAController_V2(new ApexPages.Standardcontroller(con));
        ad.initAction();
        ad.validateObject();
        
    }
      
    public static testMethod void testADUAController_V2_6(){
    	EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        ADUAUI.ADUAZoneDetails ad = new ADUAUI.ADUAZoneDetails();
        ADUAController_V2.ADUAUser au = new ADUAController_V2.ADUAUser();
        ADUAController_V2.ADUAUserDetails aud = new ADUAController_V2.ADUAUserDetails();
    }
}