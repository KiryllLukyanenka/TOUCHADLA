public with sharing class ContactsBackendController {
    public ContactsBackendController(ApexPages.StandardController stdCtrlr){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Contacts are being provisioned please wait...');
        ApexPages.addMessage(myMsg);
    }
      
    public PageReference initAction(){
        String inputLicenseID = ApexPages.currentPage().getParameters().get('licenseId');
        String inputDBLicenseID = ApexPages.currentPage().getParameters().get('dblicenseId');
        LicenseContactTransaction__c licTrans = null;
        DBLicenseContactTransaction__c dbLicTrans = null;
        if(inputLicenseID!=null){
	        try{
	            licTrans = [Select Account__c,License__c,AccMgrUsr__c,SalesRepUsr__c from LicenseContactTransaction__c where License__c=:inputLicenseId limit 1];
	        }catch(Exception e){
	            return null;
	        }
        }
          
        if(inputDBLicenseID!=null){
	        try{
	            dbLicTrans = [Select Account__c,DBLicense__c,AccMgrUsr__c,SalesRepUsr__c from DBLicenseContactTransaction__c where DBLicense__c=:inputDBLicenseID limit 1];
	        }catch(Exception e){
	            return null;
	        }
        }
        
        String licenseId;
        String accId;
        String accMgrUsrId;
        String salesRepUsrId;
        
        if(licTrans!=null){
			licenseId = licTrans.License__c;
			accId = licTrans.Account__c;
			accMgrUsrId = licTrans.AccMgrUsr__c;
			salesRepUsrId = licTrans.SalesRepUsr__c;
        }
        
        if(dbLicTrans!=null){
			licenseId = dbLicTrans.DBLicense__c;
			accId = dbLicTrans.Account__c;
			accMgrUsrId = dbLicTrans.AccMgrUsr__c;
			salesRepUsrId = dbLicTrans.SalesRepUsr__c;
        }
        
        Map<String,String> contactMap = new Map<String,String>();
        List<Contact_Portal_User__c> contactPortalUsers = new List<Contact_Portal_User__c>();
        
        
        LicenseDetail__c lic = null;
        DBTuna_License__c dblic = null;
        if(licTrans!=null){
			lic = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
        }else if(dbLicTrans!=null){
        	dblic = (DBTuna_License__c)DataLayerConstants.fetchSingle('DBTuna_License__c',licenseId);
        }
        try{
        Account acc = (Account)DataLayerConstants.fetchSingle('Account',accId);
        User accMgrUsr = (User)DataLayerConstants.fetchSingle('User',accMgrUsrId);
        User salesRepUsr = (User)DataLayerConstants.fetchSingle('User',salesRepUsrId);
        List<String> contactUserIds = new List<String>();
        //List<Contact> cts = DataLayerConstants.fetchMultiple('Contact',' where AccountId=\''+accId+'\' and PortalID__c Like \'PENDING%\' LIMIT 10');
          
        List<Contact_Portal_User__c> cts = Database.query('Select id, Contact__c,User_Portal_Id__c,Docs__c,Download__c,ZenDesk__c,LMS__c, '+
    									'ADUAUserDetails__c,Contact__r.Account.RecordType.Name,Contact__r.Account.Name, '+
    									'Contact__r.Account.RecordType.Id, Contact__r.Account.Id,Contact__r.Account.PortalID__c, '+
    									'Contact__r.Name,Contact__r.Description,Contact__r.Needs_Email__c,Contact__r.Email,Contact__r.LastName, '+ 
    									'Contact__r.Accessible_Systems__c, '+
    									'Contact__r.Account.OwnerId, Contact__r.FirstName,Contact__r.LMS_Portal_User_Contact__c, Contact__r.LMS_Cloned__c '+
    									'from Contact_Portal_User__c where Contact__r.accountid = \''+accId+'\' and User_Portal_Id__c like \'PENDING%\' LIMIT 10');
         
        /*[Select id, Contact__c,User_Portal_Id__c,Docs__c,Download__c,ZenDesk__c,LMS__c,
    									ADUAUserDetails__c,Contact__r.Account.RecordType.Name,Contact__r.Account.Name,
    									Contact__r.Account.RecordType.Id, Contact__r.Account.Id,Contact__r.Account.PortalID__c,
    									Contact__r.Name,Contact__r.Description,Contact__r.Needs_Email__c,Contact__r.Email,Contact__r.LastName, 
    									Contact__r.Accessible_Systems__c,
    									Contact__r.Account.OwnerId, Contact__r.FirstName,Contact__r.LMS_Portal_User_Contact__c, Contact__r.LMS_Cloned__c
    									from Contact_Portal_User__c where Contact__r.accountid =: accId and User_Portal_Id__c like 'PENDING%' LIMIT 10];*/
    									
    	for(Contact_Portal_User__c con: cts){
    		contactUserIds.add(con.id+'');
    	}
    									
    	List<ContactPortalUserHistory__c> ctUserHistoryList = [ Select Id, ApexClass__c,ApexVisualforcePage__c,Save_User_Status__c,Contact_Portal_User__c from ContactPortalUserHistory__c where Contact_Portal_User__c in:contactUserIds and Save_User_Status__c like 'PENDING%'];
    	
    	Map<Id,ContactPortalUserHistory__c> ctUserHistoryMap = new Map<Id,ContactPortalUserHistory__c>();
    	for(ContactPortalUserHistory__c cph: ctUserHistoryList){
    		ctUserHistoryMap.put(cph.Contact_Portal_User__c,cph);
    	}
        
        try{
        
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Called Init Action::AccId: ' +accId+'::Lic Id:'+licenseId+'::AccMgr:'+accMgrUsrId+'::SalesRep:'+salesRepUsrId);
        ApexPages.addMessage(myMsg);
        
        try{
        	
            List<ADUAController_V2.ADUAUserDetails> aduaUsers = new List<ADUAController_V2.ADUAUserDetails>();
            List<ADUAUI> aduaUIList = new List<ADUAUI>();
            BackendLayer backend = new BackendLayer();
            for(Contact_Portal_User__c con: cts){
    			ADUAController_V2.ADUAUserDetails aduaDe = (ADUAController_V2.ADUAUserDetails)JSON.deserialize(con.ADUAUserDetails__c, ADUAController_V2.ADUAUserDetails.class);
    			aduaDe.contactUserObj = con;
    			aduaUsers.add(aduaDe);
                List<ADUAController_V2.ADUAUserDetails> aduaUsersTemp = new List<ADUAController_V2.ADUAUserDetails>();
                aduaUsersTemp.add(aduaDe);
                backend.addBackend(new MultipleContactsBackend_V2(aduaUsersTemp, acc, accMgrUsr, salesRepUsr, null, BackendConstants.OPCODE_ADD_USER));
            }
            
			
            if(backend.invokeBackend()){
            	String jsonResponse = backend.getResponse(BackendConstants.OPCODE_ADD_USER);
                JSonObject jsonObj = new JSONObject(new JSONObject.JSONTokener(jsonResponse));
                String userStatusCode = backend.getStatusCode(BackendConstants.OPCODE_ADD_USER);
                
                List<Contact> contactsToSave = new List<Contact>();
				
				for(ADUAController_V2.ADUAUserDetails add: aduaUsers){
					Contact contactObj = (Contact)add.contactUserObj.get('Contact__r');
					try{
						String portalId = '';
						try{
							portalId = jsonObj.getValue(contactObj.Email).num+'';
						}catch(Exception e){
							//EmailUtil.notifyError(e, null);
						}
						Contact_Portal_User__c contactPortalUser = add.contactUserObj;
						contactPortalUser.ADUAUserDetails__c = '';
                		contactPortalUser.User_Portal_Id__c = portalId;
	            		contactPortalUsers.add(contactPortalUser);
	            		ADUAUtils.setupADUAContact(contactObj, add.getApplications());
	            		
	            		ContactPortalUserHistory__c cph = ctUserHistoryMap.get(contactPortalUser.id);
	            		cph.ApexClass__c = 'ContactsBackendController';
	            		cph.ApexVisualforcePage__c = 'ContactsBackend';
	            		cph.Save_User_Status__c = userStatusCode;
	            	}
	            	catch(Exception e){
	                	System.debug(e);
	                	EmailUtil.notifyError(e,null);
	            	}
					//contactsToSave.add(add.contactObj);  
				}
				//upsert contactsToSave;
				upsert contactPortalUsers;
				upsert ctUserHistoryList;
			
            }else{
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Backend Failed?:'+backend.getErrorMessage(false));
                    ApexPages.addMessage(myMsg);
                    myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Backend Failed?:'+backend.getResponse(BackendConstants.OPCODE_ADD_USER));
                    ApexPages.addMessage(myMsg);
                    EmailUtil.notifyError(backend.getErrorMessage(true),BackendConstants.BACKEND_ERROR_SUBJECT);
            }
            
            
        }catch(Exception e){
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+e.getMessage()+'::AccId: ' +accId+'::Lic Id:'+licenseId+'::AccMgr:'+accMgrUsrId+'::SalesRep:'+salesRepUsrId);
            ApexPages.addMessage(myMsg);
            //EmailUtil.notifyError(e,null);
        }
        
        
        myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Finished Init Action');
        ApexPages.addMessage(myMsg);
        
    }catch(Exception e){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+e.getMessage()+'::AccId: ' +accId+'::Lic Id:'+licenseId+'::AccMgr:'+accMgrUsrId+'::SalesRep:'+salesRepUsrId);
        ApexPages.addMessage(myMsg);
        EmailUtil.notifyError(e,null);
        return null;
    }
    
	for(Contact_Portal_User__c con: cts){
		if(con.User_Portal_Id__c.equals('PENDING_FOR_LICENSE')){
			con.User_Portal_Id__c = '';
	    }
	}
	upsert cts;
	
	for(ContactPortalUserHistory__c cph: ctUserHistoryList){
		if(cph.Save_User_Status__c.equals('PENDING_FOR_STATUS')){
			cph.Save_User_Status__c = 'Failed';
	    }
	}
	upsert ctUserHistoryList;
    }catch(Exception e){
    }
    
    Pagereference ref = null;
    if(inputLicenseID!=null){
    	ref = new Pagereference('/apex/LicenseContactsBackend?licenseId='+inputLicenseID);    	
    }
    
    if(inputDBLicenseID!=null){
    	ref = new Pagereference('/apex/LicenseContactsBackend?dblicenseId='+inputDBLicenseID);
    }
    ref.setRedirect(true);
    return ref;
    
    }
    
    public static testMethod void testInitAction(){
    	RESTAPI.unitTestMode = true;
    	LicenseDetail__c licDetail = [Select Id from LicenseDetail__c limit 1];
    	String licenseId = licDetail.Id;
    	Pagereference page = new PageReference('/apex/ContactsBackend.page');
        Test.setCurrentPage(page);
        Apexpages.currentPage().getParameters().put('licenseId',licenseId);
    	ContactsBackendController ctrlr = new ContactsBackendController(new ApexPages.Standardcontroller(licDetail));
    	ctrlr.initAction();
    	
    	DBTuna_License__c dblicDetail = [Select Id from DBTuna_License__c limit 1];
    	String dblicenseId = dblicDetail.Id;
    	Pagereference page1 = new PageReference('/apex/ContactsBackend.page');
        Test.setCurrentPage(page1);
        Apexpages.currentPage().getParameters().put('dblicenseId',dblicenseId);
    	ContactsBackendController ctrlr2 = new ContactsBackendController(new ApexPages.Standardcontroller(dblicDetail));
    	ctrlr2.initAction();
    	
    	Account acct = new Account();
    	Integer day  = System.now().date().day();
    	Integer month  = System.now().date().month();
    	Integer year = System.now().date().year();
    	acct.Name = day+'_'+month+'_'+year+'_acc2';
    	upsert acct;
    	
    	List<Contact> cts = new List<Contact>();
    	for(Integer i=0;i<20;i++){
    		Contact ct = new Contact();
    		ct.AccountId = acct.Id;
    		ct.LastName=acct.Name+'_'+i;
    		ct.Email = acct.Name+'_'+i+'@tarams.com';
    		ct.Download__c=true;
    		ct.ZenDesk__c = true;
    		cts.add(ct);
    	}
    	upsert cts;
    	Opportunity opp = new Opportunity();
    	opp.Name=acct.Name+'_Opp';
    	opp.CloseDate = System.now().date().addDays(20);
    	opp.StageName = 'A1 - Active';
    	opp.Probability = 80;
    	opp.AccountId = acct.Id;
    	opp.LeadSource = 'PPC';
    	upsert opp;
    	
    	LicenseDetail__c lic = new LicenseDetail__c();
    	lic.License_Expiry_Date__c = System.now().date().addDays(10);
    	lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
    	lic.Server_Agents__c = 2;
    	lic.Stage__c = 'TRIAL';
    	lic.ProcessState__c = 'SUCCESS';
    	upsert lic;
    	
    	DBTuna_License__c dblic = new DBTuna_License__c();
    	dblic.ExpiryDate__c = System.now().date().addDays(10);
    	dblic.Server_Name__c = 'Test';
    	dblic.Opportunity__c = opp.id;
    	upsert dblic;
    	
    	Apexpages.currentPage().getParameters().put('licenseId',lic.Id);
    	ContactsBackendController ctBckCtrlr = new ContactsBackendController(new Apexpages.Standardcontroller(new LicenseDetail__c()));
    	ctBckCtrlr.initAction();
    	
    	Apexpages.currentPage().getParameters().put('dblicenseId',dblic.Id);
    	ContactsBackendController ctBckCtrlr2 = new ContactsBackendController(new Apexpages.Standardcontroller(new DBTuna_License__c()));
    	ctBckCtrlr2.initAction();
    	
    	LicenseContactTransaction__c licTrans = new LicenseContactTransaction__c();
    	licTrans.Account__c = acct.Id;
    	licTrans.License__c = lic.Id;
    	licTrans.SalesRepUsr__c = UserInfo.getUserId();
    	licTrans.AccMgrUsr__c = acct.CreatedById;
    	upsert licTrans;
    	ctBckCtrlr.initAction();
    	
    	DBLicenseContactTransaction__c dblicTrans = new DBLicenseContactTransaction__c();
    	dblicTrans.Account__c = acct.Id;
    	dblicTrans.dbLicense__c = dblic.Id;
    	dblicTrans.SalesRepUsr__c = UserInfo.getUserId();
    	dblicTrans.AccMgrUsr__c = acct.CreatedById;
    	upsert dblicTrans;
    	ctBckCtrlr2.initAction();
    }
    
    public static testMethod void testInitAction2(){
    	RESTAPI.unitTestMode = true;
    	Account standardAccount = new Account(Name='Test');
    	insert standardAccount;
    	Contact standardContact = new Contact(LastName='TestName',AccountId=standardAccount.id,Email='test@test.com');
    	insert standardContact;
    	
    	Contact_Portal_User__c contactPortalUser = null;
    	if(standardContact.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || standardContact.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
			//contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
			contactPortalUser = new Contact_Portal_User__c();
			contactPortalUser.put('Contact__c',standardContact.Id);
			contactPortalUser.put('User_Portal_Id__c','PENDING');
			insert contactPortalUser;
    	}
    	 
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
    	
    	DBLicenseContactTransaction__c dblicTrans = new DBLicenseContactTransaction__c();
    	dblicTrans.Account__c = standardAccount.Id;
    	dblicTrans.dbLicense__c = lic.Id;
    	dblicTrans.SalesRepUsr__c = UserInfo.getUserId();
    	dblicTrans.AccMgrUsr__c = standardAccount.CreatedById;
    	upsert dblicTrans;
    	
    	Apexpages.currentPage().getParameters().put('dblicenseId',lic.Id);
    	ContactsBackendController ctBckCtrlr2 = new ContactsBackendController(new Apexpages.Standardcontroller(new DBTuna_License__c()));
    	ctBckCtrlr2.initAction();
    	
    }
}