/**
 * Apex Class: AccountContactsADUAHelper
 * 
 * This class contains controller code to get contacts for a given account, opportunity and license.
 *
 * This retrieves all the contacts of an account or for a given opportunity or for a given license/dbtunalicense
 *
 * For each contact, it also makes a backend call to getUserDetails with all the email ids of the contacts and gets
 * User permissions from backend interms of ADUAUI object.
 * It is optimized to fetch for only max of 5 contacts at a time in case of used from Account object's perspective.i.e.,
 * when we pass account object and do not pass opportunity and license referecnes.
 * otherwise it will get all the contacts data in get user call. 
 * for all the above processing done, it will create ContactWrapper objects and expose it for use by 
 * ADUA Page ==> ADUA Controller
 * License Provision Pages ==> License Provision Controller
 *  
 */
public with sharing class AccountContactsADUAHelper {
    
    /*
     * Account for which the contacts are to be retireved with backend information.
     */
    public transient Account accountObj;
    /*
     * List of contact wrapper for a givne account/opp/license with backend information
     */
    public List<ContactWrapper> licenseContacts{get;set;}
    
    /*
     * Stores all the contacts retireved for any of the input
     */
    public transient List<Contact> allContacts{get;set;}
    
    /*
     * Stores all the contacts retireved for a given account
     */
    public transient List<Contact> allContactsAccount;
    
    /*
     * Stores all the contacts retireved for a given opportunity
     */
    public transient List<Contact> opportunityContacts;
    
    /*
     * Used during pagination support in Account ADUA Page, to show only maxPerPage entries
     * in one page.
     */
    public transient List<Contact> pageContacts{get;set;}
    
    /*
     * How many contacts to be shown at once. Default value is 5 and non-tunable right now.
     */
    public Integer maxPerPage{get;set;}
    
    /*
     * Current page in the account adua page
     */
    public Integer pageIndex{get;set;}
    
    /*
     * Total number of pages of cotnacts in account adua page.
     */
    public Integer totalPages{get;set;}
    
    /*
     * Map of ADUAUI by contact ID. Used to show the ADUAUI details in Visualforce pages
     */
    public transient Map<String,ADUAUI> contactADUAUIMap{get;set;}
    
    /*
     * Map of contact objects by email id. Need not be exposed public. Need to revalidate naeed.
     */
    public transient Map<String,Contact> contactObjectMap;
    
    /*
     * Map of ContactWrapper objects for a given license.
     */
    public transient Map<String,ContactWrapper> licContactMap{get;set;}
    
    /*
     * Set to true by Account ADUA page to enable pagination. When set to true only maxPerPage
     * entries are fetched and retrieved; Otherwise all contacts data are fetched.
     */
    public Boolean paginationNeeded;
    
    /*
     * Indicating whether this is used by LicenseProvision pages or DBTuna pages. It stores either
     * LicenseDetail__c or DBTunaLicense__c
     */
    public String objName = '';
    
    /* 
     * Static helper method used from Account ADUA context to get paginated list of contacts
     * with backend user permission details for a given account
     */ 
    public static AccountContactsADUAHelper newInstance(Account accountObj){
        return new AccountContactsADUAHelper(accountObj);
    }
    
    /* 
     * Static helper method used from Account ADUA context to get paginated list of contacts
     * with backend user permission details for a given account
     */ 
    public static AccountContactsADUAHelper newInstance(Account acc,Contact ct){
        return new AccountContactsADUAHelper(acc,ct);
    }
    
    /* 
     * Static helper method used from License Provision pages, used to get all contacts for a given opportunity or license with
     * backend user permission details for a given account
     */ 
    public static AccountContactsADUAHelper newInstance(Account acc,Opportunity opportunityObj,LicenseDetail__c license){
        return new AccountContactsADUAHelper(acc,opportunityObj,license);
    }
    
    /* 
     * Static helper method used from dbtuna license Provision flow, used to get all contacts for a given opportunity or dbtunalicense with
     * backend user permission details for a given account
     */ 
    public static AccountContactsADUAHelper newInstance(Account acc,Opportunity opportunityObj,DBTuna_License__c license){
        return new AccountContactsADUAHelper(acc,opportunityObj,license);
    }
    
    
    /*
     * Constructor to initialize this object for a given account
     */
    private AccountContactsADUAHelper(Account accountObj){
        contactADUAUIMap=new Map<String,ADUAUI>();
        this.accountObj = accountObj;
        objName = 'LicenseDetail__c';
        allContacts = new list<Contact>();
        if(accountObj!=null){
            allContacts = DataLayerConstants.fetchMultiple('Contact', 'AccountId',accountObj.Id);
            paginationNeeded=true;      
        }
        pageIndex=0;
        maxPerPage=5;
        refreshUsers();
    }
    
    /*
     * Constructor to initialize this object for a given account and contact
     */
    private AccountContactsADUAHelper(Account accountObj, Contact contactObj){
        contactADUAUIMap=new Map<String,ADUAUI>();
        this.accountObj = accountObj;
        objName = 'LicenseDetail__c';
        allContacts = new list<Contact>();
        if(accountObj!=null && contactObj!=null){
            allContacts = new list<Contact>();
            allContacts.add(contactObj);
            paginationNeeded=false;
            refreshUsers();     
        }
    }
    
    /*
     * Constructor to initialize this object for a given account/opportunity or license
     */
    private AccountContactsADUAHelper(Account accountObj,Opportunity opportunityObj,LicenseDetail__c license){
        contactADUAUIMap=new Map<String,ADUAUI>();
        this.accountObj = accountObj;
        if(accountObj==null && opportunityObj!=null && opportunityObj.AccountId!=null){
            this.accountObj = opportunityObj.Account;
        }
        objName = 'LicenseDetail__c';
        allContacts = new list<Contact>();
        
        if(license!=null){  
            licenseContacts = LicenseUtil.getLicenceContacts(license, opportunityObj, accountObj, false);
            
            licContactMap = new Map<String,ContactWrapper>();
            integer i=0;
            Integer maxContacts = 100;
            try{
                maxContacts = Integer.valueOf(EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.MAX_LIC_CONTACTS));
            }catch(Exception e){}

            for(ContactWrapper ctWrapper:licenseContacts){
                if(i >= maxContacts){
                    break;
                }
                licContactMap.put(ctWrapper.contactObj.Id,ctWrapper);
                allContacts.add(ctWrapper.contactObj);
                i++;
            }
            paginationNeeded=false;
        }else{
            if(accountObj!=null){
                allContacts = DataLayerConstants.fetchMultiple('Contact', 'AccountId',accountObj.Id);
                paginationNeeded=true;      
            }
        }
        
        pageIndex=0;
        maxPerPage=5;
        refreshUsers();
    }
    
    /*
     * Constructor to initialize this object for a given account/opportunity or dbtuna license
     */
    private AccountContactsADUAHelper(Account accountObj,Opportunity opportunityObj,DBTuna_License__c license){
        contactADUAUIMap=new Map<String,ADUAUI>();
        this.accountObj = accountObj;
        objName = 'DBTuna_License__c';
        if(license!=null && opportunityObj!=null){
            licenseContacts = new List<ContactWrapper>();
            licenseContacts = LicenseUtil.getDBContacts(license, opportunityObj, accountObj, false);
            //licenseContacts.sort();
            licContactMap = new Map<String,ContactWrapper>();
            for(ContactWrapper licCt:licenseContacts){
                licContactMap.put(licCt.contactObj.Id,licCt);
            }
        }
        //allContacts = DataLayerConstants.fetchMultiple('Contact', 'AccountId',accountObj.Id);
        //allContacts = DataLayerConstants.fetchMultiple('Contact', ' WHERE AccountId = \''+accountObj.Id+'\' and No_longer_at_Company__c=false ');
		
        allContacts = new List<Contact>();
        for(Integer i = 0; i < licenseContacts.size(); i ++) {
        	allContacts.add(((ContactWrapper)licenseContacts.get(i)).contactObj);
			System.debug('Added to allContacts');
        }

        pageIndex=0;
        maxPerPage=5;
        paginationNeeded=false;
        refreshUsers();
    }
    
    /*
     * Called for the first time to initialize the contactwrapper with all the backend user permisisons, primary/additional contact information
     * or during pagination while navigating to next pages in account adua page.
     */
    public void refreshUsers(){
        System.debug(LoggingLevel.Info,'Refreshing the users list');
        if(allContacts!=null){
            if(paginationNeeded){
                totalPages = allContacts.size()/maxPerPage+1;
                Integer upperLimit= 0;
                pageContacts = new List<Contact>();
                if(pageIndex*maxPerPage+maxPerPage>allContacts.size()){
                    upperLimit = allContacts.size();
                }else{
                    upperLimit = pageIndex*maxPerPage+maxPerPage;
                }
                for(Integer i=pageIndex*maxPerPage;i<upperLimit;i++){
                    pageContacts.add(allContacts.get(i));
                }
                
            }else{
                pageContacts=allContacts;
            }
            fetchFromBackend();
        }
    }
    
    /*
     * Called from refreshUsers method to fetch user permissions from portal 
     * for all of the current contacts list (all contacts or contacts of the 
     * current page during pagination).
     */
    public void fetchFromBackend(){
        System.debug(LoggingLevel.Info,'Fetching from backend the users list');
        contactWrapperList = new list<ContactWrapper>();
        List<Contact> contactsToFetch = new List<Contact>();
        contactWrapperMap = new map<Contact,ContactWrapper>();
        contactObjectMap = new Map<String,Contact>();
        for(Contact ct:pageContacts){
            String ctID=ct.ID;
            if(ct.Email!=null && contactADUAUIMap.get(ctID)==null){
                contactsToFetch.add(ct);
                contactObjectMap.put(ct.Email,ct);
            }
        }
        if(contactsToFetch.size()>0){
            if(accountObj==null){
                for(Contact con: contactsToFetch){
                    if(con.AccountId!=null){
                        accountObj = con.Account;
                        break;
                    }
                }
            }
            String requestJson = UsersUtil.getUserDetailsRequestJson(contactsToFetch,accountObj.Name);  
            ADUAController_V2.ADUAUser adUsers = UserDetailsBackend.getUserDetails(requestJson);
            
        
            //fetching contact portal users... need to think of better solution
            pageContacts = UsersUtil.getContactPortalUsers(pageContacts, accountObj);
            
            for(Contact ct:pageContacts){
                String ctID=ct.ID;
                if(ct.Email!=null && contactADUAUIMap.get(ctID)==null){
                    contactObjectMap.put(ct.Email,ct);
                }
            }
            if(adUsers!=null && adUsers.users!=null){
                for(ADUAController_V2.ADUAUserDetails aduaUserDetails : adUsers.users){
                    Contact ct = contactObjectMap.get(aduaUserDetails.email);
                    ContactWrapper ctWrapper = null;
                    if(ct!=null && licContactMap!=null){
                         ctWrapper = licContactMap.get(ct.Id);
                    }
                    if(ctWrapper == null){
                        ctWrapper = new ContactWrapper();
                        ctWrapper.accountObj = accountObj;
                        ctWrapper.contactObj = ct;
                    }
                    ADUAUI aduaUIObj = null;
                    if('LicenseDetail__c'.equals(objName)){
                        aduaUIObj = ADUAUI.newInstance(ct,aduaUserDetails,ctWrapper.licContact);    
                    }
                    else if('DBTuna_License__c'.equals(objName)){
                        aduaUIObj = ADUAUI.newInstance(ct,aduaUserDetails,ctWrapper.dbLicContact);  
                    }
                    else{
                        aduaUIObj = ADUAUI.newInstance(ct,aduaUserDetails);
                    }
                    contactADUAUIMap.put(ct.ID+'',aduaUIObj);
                    ctWrapper.aduaUIObj = aduaUIObj;
                    contactWrapperMap.put(ct,ctWrapper);
                }
            }
        } else{
            pageContacts = UsersUtil.getContactPortalUsers(pageContacts, accountObj);
        }
        for(Contact ct:pageContacts){
            if(contactADUAUIMap.get(ct.ID)==null){
                ADUAUI aduaUIObj = ADUAUI.newInstance(ct,null);
                contactADUAUIMap.put(ct.ID+'',aduaUIObj);
            }
            if(contactWrapperMap.get(ct)!=null){
            	contactWrapperList.add(contactWrapperMap.get(ct));
            }
        }
        if(licenseContacts!=null){
            licenseContacts = contactWrapperList; 
        }
        System.debug(LoggingLevel.Info,'Fetching the users list:'+contactWrapperList);
    }
    private transient map<Contact,ContactWrapper> contactWrapperMap;
    public list<ContactWrapper> contactWrapperList{get;set;}
    
    /*
     * Navigate to next page. Circular navigation - will go back to first page after last page.
     */
    public PageReference next(){
        pageIndex++;
        pageIndex = Math.mod(pageIndex, totalPages);
        refreshUsers();
        return null;
    }
    
    /*
     * Navigate to previous page. Circular navigation - will go back to last page after first page.
     */
    public PageReference previous(){
        pageIndex--;
        if(pageIndex<0){
            pageIndex=totalPages-1;
        }
        refreshUsers();
        return null;
    }
    
    /*
     * Show all contacts to turnoff pagination and show all contacts from the first page.
     */
    public PageReference showAllContacts(){
        pageIndex=0;
        allContacts = allContactsAccount;
        refreshUsers();
        return null;
    }

    /*
     * This method is used to Update contact portal user details.
     */
    public static void updateContactPortalUserDetails(List<ADUAUI> aduaUIList, JSONObject contactJsonResponse){
        List<Contact_Portal_User__c> contactPortalUsers = new List<Contact_Portal_User__c>();
        
        for(ADUAUI aduaUIObj: aduaUIList){
                ADUAController_V2.ADUAUserDetails ad = aduaUIObj.aduaUser;
                
                try{
                    String portalId = '';
                    try{
                        portalId = contactJsonResponse.getValue(aduaUIObj.contactObj.Email).num+''; 
                    }catch(Exception e){}
                    
                    Contact_Portal_User__c contactPortalUser = aduaUIObj.contactPortalUser;//ad.contactObj.Contact_Portal_User__r.get(0);
                    contactPortalUser.User_Portal_Id__c = portalId;
                    contactPortalUsers.add(contactPortalUser);
                    
                    ADUAUtils.setupADUAContact(aduaUIObj.contactObj, ad.getApplications());
                }
                catch(Exception e){}
                
            }
            
            upsert contactPortalUsers;
    }
    
    /*
     * This method is used to update company portal Id in Account_Portal_Company object.
     */
    public static Account_Portal_Company__c saveAccountPortalDetails(String accountResponse, Account accountObj){
        
        String companyId = accountResponse;
        Account_Portal_Company__c accountPortalCompany = null;
        
		if(companyId == 'None') {
			companyId = '';
		}

        if(accountObj!=null){
            if(accountObj.getSObjects(BackendConstants.ACCOUNT_CHILD_RELATIONAL_NAME)!=null && accountObj.getSObjects(BackendConstants.ACCOUNT_CHILD_RELATIONAL_NAME).size()>0){
                accountPortalCompany = (Account_Portal_Company__c)accountObj.getSObjects(BackendConstants.ACCOUNT_CHILD_RELATIONAL_NAME).get(0);
				accountPortalCompany.Company_Portal_Id__c = companyId;
            }else{
               accountPortalCompany = new Account_Portal_Company__c(Company_Portal_Id__c = companyId);
                accountPortalCompany.put('Account__c',accountObj.Id);
            }
            
            if(accountPortalCompany!=null){
                upsert accountPortalCompany;
            }
        }
        
        return accountPortalCompany;
    }

    public static testMethod void testAccountContactsADUAHelper_1(){
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
            contactPortalUser.put('Contact__c',con.id);
            insert contactPortalUser;
        }  
        Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=acc.id,CloseDate=System.now().date());
        insert opp;
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "'+con.email+'", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        LicenseDetail__c ld = new LicenseDetail__c(License_Expiry_Date__c=System.now().date());
        insert ld;
        License_Contacts__c lc = new License_Contacts__c(Contact__c=con.id,Contact_Type__c='PRIMARY',License__c=ld.id);
        insert lc;
        AccountContactsADUAHelper.newInstance(acc,opp, ld);
    }
    
    public static testMethod void testAccountContactsADUAHelper_2(){
        EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        Contact_Portal_User__c contactPortalUser = null;
        /*if(con.Contact_Portal_User__r==null || con.Contact_Portal_User__r.size()==0){
            contactPortalUser = new Contact_Portal_User__c(Contact__c = con.Id);
            insert contactPortalUser;
        }*/
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            contactPortalUser = new Contact_Portal_User__c();
            contactPortalUser.put('Contact__c',con.Id);
            insert contactPortalUser;
        }
        
        Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=acc.id,CloseDate=System.now().date());
        insert opp;
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "'+con.email+'", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        DBTuna_License__c ld = new DBTuna_License__c(Opportunity__c=opp.id,ExpiryDate__c=System.now().date());
        insert ld;
        DBLicense_Contacts__c lc = new DBLicense_Contacts__c(Contact__c=con.id,Contact_Type__c='PRIMARY',DBLicense__c=ld.id);
        insert lc;
        AccountContactsADUAHelper.newInstance(acc,opp, ld);
    }
    
    public static testMethod void testAccountContactsADUAHelper_3(){
        EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode = true;
        Account acc = new Account(Name='Test Account',PortalID__c='123456',RecordTypeId='01280000000LrcY');
        insert acc;
        Contact con  = new Contact(firstName='Test fn',lastName='Test ln',email='test@appdynamics.com',Accountid=acc.id,Download__c=true,Docs__c=true,ZenDesk__c=true,LMS__c=true);
        insert con;
        Contact_Portal_User__c contactPortalUser = null;
        /*if(con.Contact_Portal_User__r==null || con.Contact_Portal_User__r.size()==0){
            contactPortalUser = new Contact_Portal_User__c(Contact__c=con.Id);
            insert contactPortalUser;
        }*/
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            contactPortalUser = new Contact_Portal_User__c();
            contactPortalUser.put('Contact__c',con.Id);
            insert contactPortalUser;
        }
        
        Opportunity opp = new Opportunity(Name='TestOpp',StageName='A1 - Active',Deal_Type__c='New',LeadSource='Website',Accountid=acc.id,CloseDate=System.now().date());
        insert opp;
        UserDetailsBackend.testResponseJson = '{"users": [{"applications": ["docs/docs-customer","help","download-zones/saas-public","learning-system/lms-learner"], "userId": 55883, "email": "'+con.email+'", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
        DBTuna_License__c ld = new DBTuna_License__c(Opportunity__c=opp.id,ExpiryDate__c=System.now().date());
        insert ld;
        DBLicense_Contacts__c lc = new DBLicense_Contacts__c(Contact__c=con.id,Contact_Type__c='PRIMARY',DBLicense__c=ld.id);
        insert lc;
        AccountContactsADUAHelper achd = AccountContactsADUAHelper.newInstance(acc,opp, ld);
        achd.paginationNeeded = true;
        achd.totalPages = 10;
        achd.maxPerPage = 10;
        achd.pageIndex = 1;
        //achd.next();
        achd.previous();
    }

    public static testMethod void testsaveAccountPortalDetails_1(){
        Account accObj = new Account(name='TestAccount');
        insert accObj;
        saveAccountPortalDetails('1234',accObj);
    }
    
    public static testMethod void testsaveAccountPortalDetails_2(){
        Account accObj = new Account(name='TestAccount');
        insert accObj;
        
        Account_Portal_Company__c accountPortalCompany = new Account_Portal_Company__c(Company_Portal_Id__c = '1234');
        accountPortalCompany.put('Account__c',accObj.Id);
        insert accountPortalCompany;
        
        accObj = (Account)DataLayerConstants.fetchSingle('Account', accObj.id);
        
        saveAccountPortalDetails('1234',accObj);
    }
    
}