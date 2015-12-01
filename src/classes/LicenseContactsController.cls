public with sharing class LicenseContactsController {
    public LicenseContactsController(ApexPages.StandardController stdCtrlr){
        
    }
    
    public PageReference initAction(){
        String inputLicenseID = ApexPages.currentPage().getParameters().get('licenseId');
        String inputDBLicenseID = ApexPages.currentPage().getParameters().get('dblicenseId');
        LicenseContactTransaction__c licTrans = null;
        DBLicenseContactTransaction__c dbLicTrans = null;
        if(inputLicenseID!=null){
	        try{
	            licTrans = [Select Id,License__c, Account__c, AccMgrUsr__c,SalesRepUsr__c from LicenseContactTransaction__c where License__c=:inputLicenseID];
	        }catch(Exception e){
	        }
        }
        
        if(inputDBLicenseID!=null){
	        try{
	            dbLicTrans = [Select Id,DBLicense__c, Account__c, AccMgrUsr__c,SalesRepUsr__c from DBLicenseContactTransaction__c where DBLicense__c=:inputDBLicenseID];
	        }catch(Exception e){
	        }
        }
        
        String url = '';
        if(licTrans!=null){
            url = '/apex/ContactsBackend?licenseId='+inputLicenseID;
            String accId = licTrans.Account__c;
            //List<Contact> cts = null;
            List<Contact_Portal_User__c> cts = null;
            try{
                //cts = DataLayerConstants.fetchMultiple('Contact',' where AccountId=\''+accId+'\' and PortalID__c Like \'PENDING%\' LIMIT 10');
                cts = DataBase.query('Select Id,ADUAUserDetails__c,Contact__c,Docs__c,Download__c,LMS__c,User_Portal_Id__c,ZenDesk__c from Contact_Portal_User__c where Contact__r.accountid =: accId and User_Portal_Id__c like \'PENDING%\' LIMIT 10');//[Select Id,ADUAUserDetails__c,Contact__c,Docs__c,Download__c,LMS__c,User_Portal_Id__c,ZenDesk__c from Contact_Portal_User__c where Contact__r.accountid =: accId and User_Portal_Id__c like 'PENDING%' LIMIT 10];
            }catch(Exception e){
                   
            }
            if(cts!=null && cts.size()>0){
                url = '/apex/ContactsBackend?licenseId='+inputLicenseID;
            }else{
                delete licTrans;
                url = '/'+inputLicenseID;
            }
        }else if(inputLicenseID!=null){
            url = '/'+inputLicenseID; 
        }
        
        if(dbLicTrans!=null){
            url = '/apex/ContactsBackend?dblicenseId='+inputLicenseID;
            String accId = dbLicTrans.Account__c;
            //List<Contact> cts = null;
            List<Contact_Portal_User__c> cts = null;
            try{
                //cts = DataLayerConstants.fetchMultiple('Contact',' where AccountId=\''+accId+'\' and PortalID__c Like \'PENDING%\' LIMIT 10');
                cts = Database.query('Select Id,ADUAUserDetails__c,Contact__c,Docs__c,Download__c,LMS__c,User_Portal_Id__c,ZenDesk__c from Contact_Portal_User__c where Contact__r.accountid =: accId and User_Portal_Id__c like \'PENDING%\' LIMIT 10');//[Select Id,ADUAUserDetails__c,Contact__c,Docs__c,Download__c,LMS__c,User_Portal_Id__c,ZenDesk__c from Contact_Portal_User__c where Contact__r.accountid =: accId and User_Portal_Id__c like 'PENDING%' LIMIT 10];
            }catch(Exception e){}  
            if(cts!=null && cts.size()>0){
                url = '/apex/ContactsBackend?dblicenseId='+inputDBLicenseID;
            }else{
                delete dbLicTrans;
                url = '/'+inputDBLicenseID;
            }
        }else if(inputDBLicenseID!=null){
            url = '/'+inputDBLicenseID; 
        }
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'URL is:'+url+' input license id:'+inputLicenseID);
        ApexPages.addMessage(myMsg);
        //return null;
        PageReference ref = new PageReference(url);
        ref.setRedirect(false); 
        return ref;
    }
    
    public static testMethod void testInitAction(){
    	LicenseDetail__c licDetail = [Select Id from LicenseDetail__c  limit 1];
    	String licenseId = licDetail.Id;
    	LicenseContactsController ctrlr = new LicenseContactsController(new ApexPages.Standardcontroller(licDetail));
    	ctrlr.initAction();
    	
    	Account acct = new Account();
    	Integer day  = System.now().date().day();
    	Integer month  = System.now().date().month();
    	Integer year = System.now().date().year();
    	acct.Name = day+'_'+month+'_'+year+'_acc1';
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
    	
    	Apexpages.currentPage().getParameters().put('licenseId',lic.Id);
    	LicenseContactsController ctBckCtrlr = new LicenseContactsController(new Apexpages.Standardcontroller(new LicenseDetail__c()));
    	ctBckCtrlr.initAction();
    	
    	LicenseContactTransaction__c licTrans = new LicenseContactTransaction__c();
    	licTrans.Account__c = acct.Id;
    	licTrans.License__c = lic.Id;
    	licTrans.SalesRepUsr__c = UserInfo.getUserId();
    	licTrans.AccMgrUsr__c = acct.CreatedById;
    	upsert licTrans;
    	ctBckCtrlr.initAction();
    	
    	DBTuna_License__c dblicDetail = [Select Id from DBTuna_License__c limit 1];
    	String dblicenseId = dblicDetail.Id;
    	ContactsBackendController ctrlr2 = new ContactsBackendController(new ApexPages.Standardcontroller(dblicDetail));
    	ctrlr2.initAction();
    	
    	DBTuna_License__c dblic = new DBTuna_License__c();
    	dblic.ExpiryDate__c = System.now().date().addDays(10);
    	dblic.Server_Name__c = 'Test';
    	dblic.Opportunity__c = opp.id;
    	upsert dblic;
    	
    	Apexpages.currentPage().getParameters().put('dblicenseId',dblic.Id);
    	ContactsBackendController ctBckCtrlr2 = new ContactsBackendController(new Apexpages.Standardcontroller(new DBTuna_License__c()));
    	ctBckCtrlr2.initAction();
    	
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
    	LicenseContactsController ctrlr = new LicenseContactsController(new ApexPages.Standardcontroller(new DBTuna_License__c()));
    	ctrlr.initAction();
    	
    }
    
    public static testMethod void testInitAction3(){
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
    	
    	LicenseDetail__c lic = new LicenseDetail__c();
            lic.Product_Type__c = 'On-Premise';
            lic.License_BackendID__c = '100';
            lic.License_Expiry_Date__c = System.now().date().addDays(15);
            lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
            //lic.Server_Agents__c  = 10;
            //lic.Net_Agents__c  = 10;
            lic.Stage__c = 'TRIAL';
            insert lic;
    	
    	LicenseContactTransaction__c licTrans = new LicenseContactTransaction__c();
    	licTrans.Account__c = standardAccount.Id;
    	licTrans.License__c = lic.Id;
    	licTrans.SalesRepUsr__c = UserInfo.getUserId();
    	licTrans.AccMgrUsr__c = standardAccount.CreatedById;
    	upsert licTrans;
    	
    	Apexpages.currentPage().getParameters().put('licenseId',lic.Id);
    	LicenseContactsController ctrlr = new LicenseContactsController(new ApexPages.Standardcontroller(new LicenseDetail__c()));
    	ctrlr.initAction();
    	
    }
}