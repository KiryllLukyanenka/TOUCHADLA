public with sharing class ADUADetailsController_V2 extends AbstractAppDController{
	public Boolean contactMode = false;
	public Boolean accountMode = false;
	
	public Account accountObj{get;set;}
	public Contact contactObj{get;set;}
	
	public AccountContactsADUAHelper accCtADUAHelper{get;set;}
	
	public List<ADUAController_V2.ADUAUserDetails> aduaUsers {get;set;}
    
    public String displayStyle {get;set;}
	
	private List<ADUAUI> aduaUIList;
	
	public ADUADetailsController_V2(ApexPages.StandardController stdCtrler){
		super(stdCtrler);
	}
    
	public  PageReference initAction(){
		try{
			loggerHandle.setClassName(ADUADetailsController_V2.class.getName());
			if(pageContextObj!=null){
			String objName = pageContextObj.getSObjectType().getDescribe().getName();
			if('Account'.equals(objName)){
				accountMode=true;
				accountObj = (Account)pageContextObj;
				accountObj = (Account) DataLayerConstants.fetchSingle('Account',pageContextObj.Id);
				pageContextObj = accountObj;
				accCtADUAHelper=AccountContactsADUAHelper.newInstance(accountObj);
			}else{
				contactMode=true;
				pageContextObj = (Contact) DataLayerConstants.fetchSingle('Contact',pageContextObj.Id);
				contactObj = (Contact) pageContextObj;
				if(contactObj.AccountId!=null){
					accountObj = (Account) DataLayerConstants.fetchSingle('Account', contactObj.AccountId+'');
				}
				accCtADUAHelper=AccountContactsADUAHelper.newInstance(accountObj,contactObj);
			}
			
			if(accountObj==null){
				disableUIComponent = true;
				errorMessage = 'Please associate contact with an Account.';
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);
            	ApexPages.addMessage(myMsg);
			}
            else {
                if(UsersUtil.isPartner(accountObj)) {
                    displayStyle = 'display:block';
                }
                else{
                    displayStyle = 'display:none';
                }
            }
		}
		}catch(Exception e){
			EmailUtil.notifyError(e, null);
			loggerHandle.error(e.getMessage(),e);
		}
		return null;
	}
	
	
    public override Boolean validateObject(){
		if(accCtADUAHelper.pageContacts!=null && accCtADUAHelper.pageContacts.size()>0){
			Boolean flag = true;
			for(Contact ct:accCtADUAHelper.pageContacts){
				if(ct.email==null || ct.email==''){
					flag = false;
					errorMessage = 'Please specify Email for all the contacts';
					break;
				}
			}
			return flag;
		}
		errorMessage = 'No Contacts available to define the Access.';
		return  true;
	}
	
    
    public override void setupBackend(){
    	backend = new BackendLayer();
		if(accountObj!=null){
			AccountBackend accBackend = new AccountBackend(accountObj,BackendConstants.OPCODE_ADD_COMPANY);
			backend.addBackend(accBackend);
		}

    	aduaUIList = new List<ADUAUI>();
    	System.debug(LoggingLevel.Info,'Setting backend for Contacts:'+accCtADUAHelper.contactWrapperList.size());
    	for(ContactWrapper ctWrapper: accCtADUAHelper.contactWrapperList){
    		Contact ct = ctWrapper.ContactObj;
    		ADUAUI aduaUIObj = ctWrapper.aduaUIObj;//accCtADUAHelper.contactADUAUIMap.get(ct.ID+'');
    		System.debug(LoggingLevel.Info,'ADUA UI Obj:'+aduaUIObj+' Is Changed:'+aduaUIObj.isChanged());
    		if(aduaUIObj!=null && aduaUIObj.isChanged()){
    			aduaUIObj.updateADUAUserDetails(null);
				//aduaUIObj.aduaUser.contactObj = ct;
				aduaUsers = new List<ADUAController_V2.ADUAUserDetails>();
				aduaUsers.add(aduaUIObj.aduaUser);

				aduaUIList.add(aduaUIObj);
				System.debug(LoggingLevel.Info,'Adding Backend for contct:'+aduaUsers+' acc:'+accountObj);
				backend.addBackend(new MultipleContactsBackend_V2(aduaUsers, accountObj, null,null,null,BackendConstants.OPCODE_ADD_USER));
    		}
    	}
    } 
    
    public override boolean doPreSave(){
    	try{
    		String response = backend.getResponse(BackendConstants.OPCODE_ADD_COMPANY);
    		String ctResponse = backend.getResponse(BackendConstants.OPCODE_ADD_USER);
    		
    		System.debug(LoggingLevel.INFO,'ADUADetailsController_V2 Ct Response:'+backend.restAPIObj.requestBody);
    		String companyId = response;
			Account_Portal_Company__c accountPortalCompany = null;
			if(response!=null){
				if(accountObj!=null){
					accountPortalCompany = AccountContactsADUAHelper.saveAccountPortalDetails(response, accountObj);
					
					if(accountPortalCompany!=null){
						/*
						 * Changing the page context object to Account_Portal_Company__c. 
						 */
						if(accountMode){
							pageContextObj = accountPortalCompany;
						}
					}
				}
			}
			
			Map<String,String> contactsMap = new Map<String,String>();
			
			JSONObject jsonResponse = new JSONObject(new JSONObject.JSONTokener(ctResponse));
			String userStatusCode = backend.getStatusCode(BackendConstants.OPCODE_ADD_USER);
			
			AccountContactsADUAHelper.updateContactPortalUserDetails(aduaUIList, jsonResponse);
			
			/*	
				Changing the page context object to Account_Portal_Company__c. 
			*/
			if(accountMode){
				pageContextObj = accountPortalCompany;
			}else {
				/*
					Changing the page context object to contact_portal_user. 
				*/
				//pageContextObj = contactPortalUsers.get(0);
				pageContextObj = aduaUIList.get(0).contactPortalUser;
			}
			
    	}catch(Exception e){
    		errorMessage = e.getMessage()+'\n'+e.getStackTraceString();
    		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);
          ApexPages.addMessage(myMsg);
			loggerHandle.error(e.getMessage(),e);
    	}
		return true;
    }
    
    public override PageReference doPostSave(){
    	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'AppDynamics User Account Information updated Succesfully');
      	ApexPages.addMessage(myMsg);
    	return null;
  	}
    
	public static testMethod void testADUADetailsController_V2_1(){
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
        
        Pagereference page = new PageReference('/apex/Account_ADUA_Details_Page_V2.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('ContactId',con.Id);
		UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUADetailsController_V2 ad = new ADUADetailsController_V2(new ApexPages.Standardcontroller(con));
        ad.initAction();   
        ad.accCtADUAHelper.refreshUsers();
        ad.validateObject();
        try{
        ad.setupBackend();
        ad.saveObject();
        ad.doPreSave();
        }catch(Exception e){}
    }
    
    public static testMethod void testADUADetailsController_V2_2(){
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
        
        Pagereference page = new PageReference('/apex/Account_ADUA_Details_Page_V2.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('ContactId',con.Id);
		UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUADetailsController_V2 ad = new ADUADetailsController_V2(new ApexPages.Standardcontroller(acc));
        ad.initAction();
        ad.accCtADUAHelper.refreshUsers();
        ad.accCtADUAHelper.next();
        ad.accCtADUAHelper.previous();
        ad.validateObject(); 
        try{
        ad.setupBackend();  
        ad.saveObject();
        ad.doPreSave();
        ad.doPostSave();
        }catch(Exception e){}
    }
    
    public static testMethod void testADUADetailsController_V2_3(){
    	EnvironmentSettings.testEnvironmentSettings();
    	RESTAPI.unitTestMode = true;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln');
        insert con;
        
        Contact_Portal_User__c contactPortalUser = null;
    	if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
			//contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
			contactPortalUser = new Contact_Portal_User__c();
			contactPortalUser.put('Contact__c',con.Id);
			insert contactPortalUser;
    	}
        
        con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        
        Pagereference page = new PageReference('/apex/Account_ADUA_Details_Page_V2.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('ContactId',con.Id);
		UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUADetailsController_V2 ad = new ADUADetailsController_V2(new ApexPages.Standardcontroller(con));
        ad.initAction();
    }
    
    public static testMethod void testADUADetailsController_V2_4(){
    	EnvironmentSettings.testEnvironmentSettings();
    	RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        
        Pagereference page = new PageReference('/apex/Account_ADUA_Details_Page_V2.page');
        Test.setCurrentPage(page);
		UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "testcontact25thaugust@tarams.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        ADUADetailsController_V2 ad = new ADUADetailsController_V2(new ApexPages.Standardcontroller(acc));
        ad.initAction();
        
        ad.validateObject(); 
        
    }
}