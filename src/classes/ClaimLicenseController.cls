public with sharing class ClaimLicenseController extends AbstractAppDController{
    public Opportunity opportunityObj{get;set;}
    public List<ContactWrapper> contactsList{get;set;}
    public List<LicenseWrapper> licensesToClaim{get;set;}
    public List<LicenseWrapper> allLicensesClaimed{get;set;}
    private MAP<String,Contact> emailCtMAP = new MAP<String,Contact>();
    public String backendResponse1{get;set;}
    public String backendResponse2{get;set;}
    public String claimLicPageLoadingText{get;set;}
    public Boolean showContactsPage{get;set;}
    public Boolean showClaimLicPage{get;set;}
    public Boolean showDebugPage{get;set;}
    public Integer currentView{get;set;}
    public static final Integer VIEW_SELECT_USER=0;  
    public static final Integer VIEW_SELECT_LIC=1;
    public static final Integer VIEW_SUMMARY=2;
    public static final Integer VIEW_ALL_CLAIM_LIC=3;
    public static final Integer VIEW_NO_CONTACTS=4;  
    public ClaimLicenseController(ApexPages.StandardController stdController){
        super(stdController);
    }
    
    public virtual override void init(){
        super.init();
        loggerHandle.setClassName(ClaimLicenseController.class.getName());
        currentView=0;
        opportunityObj = (Opportunity) stdController.getRecord();
        opportunityObj = (Opportunity) DataLayerConstants.fetchSingle('Opportunity',opportunityObj.Id);
        List<Contact> accContacts = CommonUtil.getAccountContactsToAddToBackend(opportunityObj);
        contactsList = new List<ContactWrapper>();
        for(Contact accContact:accContacts){
            ContactWrapper ctWrapper = new ContactWrapper();
            ctWrapper.contactObj=accContact;
            ctWrapper.selected=true;
            contactsList.add(ctWrapper);
            emailCtMAP.put(accContact.Email,accContact);
        }
    }
    
    public PageReference filterContacts(){
        try{
            FilterContactsBackend bk = new FilterContactsBackend(contactsList);
            BackendLayer backend = new BackendLayer();
            backend.addBackend(bk);
            claimLicPageLoadingText='Filtering Contacts';
            contactsList = new List<ContactWrapper>();
            if(backend.invokeBackend()){
                String filteredContacts = backend.getResponse(BackendConstants.OPCODE_SS_FILTER_CONTACTS);
                claimLicPageLoadingText='RESPONSE:'+filteredContacts;
                if(filteredContacts!=null){
                    for(String emailID:emailCtMap.keySet()){
                        if(emailID!=null && filteredContacts.contains(emailID)){
                            ContactWrapper ctWrapper = new ContactWrapper();
                            ctWrapper.contactObj = emailCtMap.get(emailID);
                            ctWrapper.selected=true;
                            contactsList.add(ctWrapper);
                        }
                    }
                }
            }
            else{
                claimLicPageLoadingText=backend.restAPIObj.serviceURL+'\n'+backend.restAPIObj.requestBody+'\n'+backend.restAPIObj.requestMethod;
                claimLicPageLoadingText+='\nResponse:'+backend.getErrorMessage(false);
                errorMessage = 'Error when querying for self service license availablity for contacts. Please try again later.';
                errorMessage+='\n\n'+claimLicPageLoadingText;  
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);
                ApexPages.addMessage(myMsg);                
            }
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()+'\n'+e.getStackTraceString());
            ApexPages.addMessage(myMsg);
        	EmailUtil.notifyError(e, null); 
        }
        if(contactsList==null || contactsList.size()==0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'There are no users with active self-service license to be claimed. Please refer below for list of self-service license claimed earlier');
            ApexPages.addMessage(myMsg);
            getAllClaimedLicenses();
            currentView=VIEW_ALL_CLAIM_LIC;
        }
        return null;
    }
    
    public PageReference getLicensesToBeClaimed(){
        claimLicPageLoadingText='Page Loaded';
        GetLicensesBackend getLicBackend = new GetLicensesBackend(contactsList);
        //getLicBackend.contactWrapperList = contactsList;
        BackendLayer backendLayer = new BackendLayer();
        backendLayer.addBackend(getLicBackend);
        
        if(backendLayer.invokeBackend()){
            String getLicBackendResponse = backendLayer.getResponse(BackendConstants.OPCODE_SS_GET_LICENSE);
            claimLicPageLoadingText=getLicBackendResponse;
            licensesToClaim = ClaimLicenseJSonParser.parseSSGetLicenseJSON(getLicBackendResponse, emailCtMap);
            currentView=VIEW_SELECT_LIC;
        }else{
            claimLicPageLoadingText=backendLayer.restAPIObj.serviceURL+'\n'+backendLayer.restAPIObj.requestBody+'\n'+backendLayer.restAPIObj.requestMethod;
            claimLicPageLoadingText+='\nResponse:'+backendLayer.getErrorMessage(false);  
            errorMessage = 'Error when querying for self service license availablity for contacts. Please try again later.';
            errorMessage+='\n\n'+claimLicPageLoadingText;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    public override virtual Boolean validateObject(){
        
        return true;
    }
    
    /*public override virtual void setupBackend(){
        backend = new BackendLayer();
        ClaimLicenseBackend claimLicBkend = new ClaimLicenseBackend(licensesToClaim);
        backend.addBackend(claimLicBkend);
    }*/
    
    /*public override virtual Boolean doPreSave(){
        String claimLicResponse = backend.getResponse(BackendConstants.OPCODE_SS_CLAIM_LICENSE);
        claimLicPageLoadingText = 'RESPONSE:'+ claimLicResponse;
        List<LicenseDetail__c> licensesToDelete = new List<LicenseDetail__c>();
        /*for(LicenseWrapper licWrapper:licensesToClaim){
            if(!claimLicResponse.contains(licWrapper.licenseObj.Id)){
                if(licWrapper.selected){
                    licensesToDelete.add(licWrapper.licenseObj);
                    licWrapper.selected=false;
                }
            }
            delete licensesToDelete;
        }
        return true;
    }*/
    
    public override virtual PageReference doPostSave(){
        List<License_Opportunity__c> licOppList = new List<License_Opportunity__c>();
        List<OpportunityContactRole> oppCtRoleList = new List<OpportunityContactRole>();
        List<License_Opportunity__c> licOpps = DataLayerConstants.fetchMultiple('License_Opportunity__c','Opportunity__c',opportunityObj.Id);
        map<String,License_Opportunity__c> licOppsMap = new map<String,License_Opportunity__c>(); 
        for(License_Opportunity__c licOpp:licOpps){
        	licOppsMap.put(licOpp.License__c,licOpp);
        }
        list<String> contactIds = new list<String>();
        for(Integer i=0;i<licensesToClaim.size();i++){
            LicenseWrapper licWrapper=licensesToClaim.get(i);
            if(licWrapper.selected){
                String licenseID=licWrapper.licenseObj.Id;
                License_Opportunity__c licOpp = licOppsMap.get(licenseId);
                if(licOpp==null){
                	licOpp = new License_Opportunity__c();
                	licOpp.Opportunity__c = opportunityObj.Id;
                	licOpp.License__c=licenseID;
                }
                
                licOppList.add(licOpp);
                Contact licCt = licWrapper.contactObj;
                contactIds.add(licCt.Id);
            }else{
                licensesToClaim.remove(i);
                i--;
            }
        }
        upsert licOppList;
        PortalLeadToLicenseManager.updateOpportunityContactRoles(opportunityObj.Id,contactIds);
        currentView=VIEW_SUMMARY;
        return null;
    }
    
    public virtual override PageReference doCancel(){
        PageReference page = new PAgeReference('/'+opportunityObj.Id);
        if(currentView==VIEW_SELECT_LIC){
            currentView=VIEW_SELECT_USER;
            try{
            List<LicenseDetail__c> licenseToDeleteList = new List<LicenseDetail__c>();
            for(LicenseWrapper licWrapper:licensesToClaim){
                if(licWrapper.licenseObj!=null){
                    licenseToDeleteList.add(licWrapper.licenseObj);
                }
            }
            delete  licenseToDeleteList;
            }catch(Exception e){
                
            }
            return null;
        }
        return page;
    }
    
    private void getAllClaimedLicenses(){
        allLicensesClaimed=new List<LicenseWrapper>();
        List<License_Opportunity__c> licOpps = [Select License__r.ID,License__r.Product_Type__c,License__r.License_Expiry_Date__c,License__r.Stage__c,License__r.Java_Agents_Rollup__c,License__r.Net_Agents_Rollup__c,License__r.Custom_URL_Name__c from License_Opportunity__c where Opportunity__c=:opportunityObj.Id and License__r.LastOpCode__c=:BackendConstants.OPCODE_SS_CLAIM_LICENSE];
        List<String>licenseIDs = new List<String>();
        for(License_Opportunity__c licOpp:licOpps){
            LicenseDetail__c lic = licOpp.License__r;
            LicenseWrapper licWrapper = new LicenseWrapper();
            licWrapper.licenseObj=lic;
            licWrapper.selected=true;
            allLicensesClaimed.add(licWrapper);
            licenseIds.add(lic.Id);
        }
        //List<License_Contacts__c> ssLicContacts = [Select Id,Name,Contact__r.Id,Contact__r.Name,Contact__r.Email,License__c from License_Contacts__c where License__c IN:licenseIds];
        
    }
    
    public class ContactWrapper{
        public Boolean selected{get;set;}
        public Contact contactObj{get;set;}
    }
    
    public class LicenseWrapper{
        public LicenseDetail__c licenseObj{get;set;}
        public Contact contactObj{get;set;}
        public Boolean selected{get;set;}
    }
    
    public class FilterContactsBackend extends Backend{
        
        public List<ContactWrapper> contactWrapperList;
        public FilterContactsBackend(List<ContactWrapper> contactWrapperList){
            super();
            this.contactWrapperList = contactWrapperList;
            this.opcode=BackendConstants.OPCODE_SS_FILTER_CONTACTS;
            setupInputParameters();
        }
        
        public override virtual void setupInputParameters(){
            List<JSONObject.value> contactEmailsArray = new List<JSONObject.value>();
            if(contactWrapperList!=null){
                for(ContactWrapper ctWrapper :contactWrapperList){
                    if(ctWrapper.selected){
                        contactEmailsArray.add(new JSONObject.value(ctWrapper.contactObj.Email));
                    }
                }
            }
            BackendLayer.BackendParameter param = new BackendLayer.BackendParameter('emailId',contactEmailsArray);
            getParameters().add(param);
            
        }
    }
    
    public class GetLicensesBackend extends Backend{
        public List<ContactWrapper> contactWrapperList;
        public GetLicensesBackend(List<ContactWrapper> contactWrapperList){
            super();
            this.contactWrapperList = contactWrapperList;
            this.opcode=BackendConstants.OPCODE_SS_GET_LICENSE;
            setupInputParameters();
        }
        
        public override virtual void setupInputParameters(){
            List<JSONObject.value> contactEmailsArray = new List<JSONObject.value>();
            if(contactWrapperList!=null){
                
                for(ContactWrapper ctWrapper :contactWrapperList){
                    if(ctWrapper.selected){
                        contactEmailsArray.add(new JSONObject.value(ctWrapper.contactObj.Email));
                    }
                }
            }
            BackendLayer.BackendParameter param = new BackendLayer.BackendParameter('emailId',contactEmailsArray);
            getParameters().add(param);
            
        }
        
    }
    
    public static testMethod void testClaimLicense1(){
    	EnvironmentSettings.testEnvironmentSettings();
    	Pagereference page = new PageReference('/apex/ClaimLicense.page');
        Test.setCurrentPage(page);
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact con = new Contact(firstName='TestFirstName',lastName='TestLastname',Email='test@tarams.com',AccountId=acc.id);
        insert con; 
        Opportunity opp = new Opportunity(Name='TestOpp',AccountId=acc.id,StageName='A1 - Active',CloseDate=date.today());
        insert opp;
        
        ClaimLicenseController cl = new ClaimLicenseController(new ApexPages.Standardcontroller(opp));
        cl.init();
    }
    
    public static testMethod void testClaimLicense2(){
    	EnvironmentSettings.testEnvironmentSettings();
    	Pagereference page = new PageReference('/apex/ClaimLicense.page');
        Test.setCurrentPage(page);
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact con = new Contact(firstName='TestFirstName',lastName='TestLastname',Email='test@tarams.com',AccountId=acc.id);
        insert con; 
        Opportunity opp = new Opportunity(Name='TestOpp',AccountId=acc.id,StageName='A1 - Active',CloseDate=date.today());
        insert opp;
        RESTAPI.unitTestMode = true;
        ClaimLicenseController cl = new ClaimLicenseController(new ApexPages.Standardcontroller(opp));
        cl.init();
        cl.filterContacts();
	}
	
	public static testMethod void testClaimLicense3(){
		EnvironmentSettings.testEnvironmentSettings();
    	Pagereference page = new PageReference('/apex/ClaimLicense.page');
        Test.setCurrentPage(page);
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact con = new Contact(firstName='TestFirstName',lastName='TestLastname',Email='test@tarams.com',AccountId=acc.id);
        insert con; 
        Opportunity opp = new Opportunity(Name='TestOpp',AccountId=acc.id,StageName='A1 - Active',CloseDate=date.today());
        insert opp;
        RESTAPI.unitTestMode = true;
        ClaimLicenseController cl = new ClaimLicenseController(new ApexPages.Standardcontroller(opp));
        cl.init();
        cl.filterContacts();
        cl.validateObject();
        try{
        	ContactWrapper ctWrapper = new ContactWrapper();
            ctWrapper.contactObj=con;
            ctWrapper.selected=true;
        	cl.contactsList.add(ctWrapper);
	        cl.getLicensesToBeClaimed();
        }catch(Exception e){}
        
        ClaimLicenseController.ContactWrapper clcw = new ClaimLicenseController.ContactWrapper();
        ClaimLicenseController.LicenseWrapper cllw = new ClaimLicenseController.LicenseWrapper();
        cl.saveObject();
        cl.getAllClaimedLicenses();
        //cl.doPreSave();
        //cl.doPostSave();
        cl.currentView=VIEW_SELECT_LIC;
        cl.doCancel();
        
        //Pagereference page1 = new PageReference('/apex/ViewLicensePage.page');
    	//Test.setCurrentPage(page1);
    	//LicenseDetail__c lic = cl.licensesToClaim.get(0).licenseObj;
    	//Apexpages.currentPage().getParameters().put('id',lic.Id);
    	//ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
  }
  
  public static testMethod void testClaimLicense4(){
  	  EnvironmentSettings.testEnvironmentSettings();
      Pagereference page = new PageReference('/apex/ClaimLicense.page');
        Test.setCurrentPage(page);
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact con = new Contact(firstName='TestFirstName',lastName='TestLastname',Email='srinidhi.test1242@tarams.com',AccountId=acc.id);
        insert con; 
        Opportunity opp = new Opportunity(Name='TestOpp',AccountId=acc.id,StageName='A1 - Active',CloseDate=date.today());
        insert opp;
        ClaimLicenseController cl = new ClaimLicenseController(new ApexPages.Standardcontroller(opp));
        cl.init();
        cl.filterContacts();
        cl.validateObject();
        try{
        	ContactWrapper ctWrapper = new ContactWrapper();
            ctWrapper.contactObj=con;
            ctWrapper.selected=true;
        	cl.contactsList.add(ctWrapper);
	        cl.getLicensesToBeClaimed();
        }catch(Exception e){}
  }
    
}