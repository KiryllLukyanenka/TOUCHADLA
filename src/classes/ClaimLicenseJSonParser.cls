public with sharing class ClaimLicenseJSonParser{
    
    public static List<ClaimLicenseController.LicenseWrapper> parseSSGetLicenseJSON(String getLicenseJSON,Map<String,Contact> contactEmailMap){
		System.debug('My claim license json : ' + getLicenseJSON);
        List<ClaimLicenseController.LicenseWrapper> licenseWrapperList = new List<ClaimLicenseController.LicenseWrapper>();
        Users u = (Users) System.JSON.deserialize(getLicenseJSON,Users.class);
        System.debug(LoggingLevel.Info,u);
        List<User_License>userLicList = u.users;
        List<License_Contacts__c> licContacts = new List<License_Contacts__c>();
        List<Contact> listOfContacts = new List<Contact>();
        List<Lead> listOfLeads = new List<Lead>();
        Set<String> listOfEmails = new Set<String>();
        List<LicenseDetail__c> sfAllLicences = new List<LicenseDetail__c>();
        
        for(User_License userLic:userLicList){
            List<License> licenses = userLic.licences;
            for(License lic:licenses){
                for(LicenseContact licCtToAdd : lic.license_contacts) {
                    listOfEmails.add(licCtToAdd.email);
                }
            }
        }
        
        for(User_License userLic:userLicList){
            String email = userLic.email;
            Contact contactObj = contactEmailMap.get(email);
            List<License> licenses = userLic.licences;
            for(License lic:licenses){
                LicenseDetail__c licenseObj = null; //intitailising to null before fetching the object
                //adding try catch to check for licence object being null
                try{
                    licenseObj = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c','License_BackendID__c',lic.licenseid);
                }catch(Exception e){   
                }
                System.debug(LoggingLevel.Info,'License for backend ID:'+lic.licenseId+' lic='+licenseObj);
                if (licenseObj == null){
                    licenseObj = new LicenseDetail__c();
                }
                licenseObj.Custom_URL_Name__c = lic.customerSaasUrl;
                licenseObj.Product_Type__c = lic.ProductType;
                licenseObj.SaaS_Account__c = lic.saasAccount;
                licenseObj.SaaS_Password__c = lic.saasPassword;
                licenseObj.SAAS_UserName__c =  lic.saasUserName;
                licenseObj.License_Expiry_Date__c = Date.valueOf(lic.expiryDate);
                licenseObj.License_BackendID__c = lic.licenseId;
                licenseObj.MAC_Address__c = lic.MacAddress;
                licenseObj.Primary_Contact__c = contactObj.Name + '('+contactObj.Email+' )';
                licenseObj.LastOPCODE__c = BackendConstants.OPCODE_SS_CLAIM_LICENSE;
                licenseObj.ProcessState__c='SUCCESS';
                if('SAAS'.equals(licenseObj.Product_Type__c)){
                    licenseObj.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
                }else{
                    licenseObj.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
                }
                licenseObj.Stage__c='SELFSERVICE_TRIAL';
                licenseObj.Last_License_User__c = Userinfo.getUserId();
                licenseObj.License_Time__c = System.now();
                upsert licenseObj;
                
                sfAllLicences.add(licenseObj);
                    
                List<LicenseAgent> licAgents = lic.license_agents;
                List<License_Agent__c> sfLicAgents = licenseObj.License_Agents__r;
                if(sfLicAgents==null){
                    sfLicAgents = new List<License_Agent__c>();
                }
                for(LicenseAgent licAgent:licAgents){
                    if('.Net'.equalsIgnoreCase(licAgent.agent_type)){
                        licAgent.agent_type = '.NET';
                    }
                    if(!'Total'.equals(licAgent.agent_type)){
                        License_Agent__c sfLicAgent = null;
                        for(License_Agent__c licAgentInSF: sfLicAgents){
                            if(licAgentInSF.Agent_Type__c.equalsIgnoreCase(licAgent.agent_type)){
                                sfLicAgent = licAgentInSF;
                                break;
                            }
                        }
                        if(sfLicAgent==null){
                            sfLicAgent = new License_Agent__c();
                            sfLicAgent.License__c=licenseObj.Id;
                            sfLicAgents.add(sfLicAgent);
                        }
                        sfLicAgent.Count__c=licAgent.agent_count;
                        sfLicAgent.Agent_Type__c = licAgent.agent_type;
                                
                    }
                }
                upsert sfLicAgents;

                Map<String,List<SObject>> relationalLicenseHistoryMap = new Map<String,List<SObject>>();
                relationalLicenseHistoryMap = LicenseUtil.getRelationalRecordsMap(licenseObj);
                LicenseUtil.saveHistory(licenseObj,relationalLicenseHistoryMap,'SUCCESS',false);
                
                licenseObj = (LicenseDetail__c) DataLayerConstants.fetchSingle('LicenseDetail__c',licenseObj.Id);
                ClaimLicenseController.LicenseWrapper licWrapper = new ClaimLicenseController.LicenseWrapper();
                licWrapper.licenseObj = licenseObj;
                licWrapper.selected=true;
                licWrapper.contactObj = contactObj;
                
                licenseWrapperList.add(licWrapper);
                
            }
        }
            
        List<License_contacts__c> licCts = new List<License_contacts__c>();
        for(User_License portalUserLic : userLicList) {
            for(License portalLic : portalUserLic.licences) {
                LicenseDetail__c sfLic = getSfLicence(sfAllLicences, portalLic.licenseId);
                licCts.addAll(createLicenseContacts(portalLic, sfLic));
            }
        }     
            
        upsert licCts;
        
        return licenseWrapperList;
    }
    
    private static LicenseDetail__c getSfLicence(List<LicenseDetail__c> sfLicences, String licenceBackendId) {
        for(LicenseDetail__c sfLic : sfLicences) {
            if(sfLic.License_BackendID__c.equals(licenceBackendId)) {
                return sfLic;
            }
        }
        
        return null;
    }
    
    private static List<License_contacts__c> createLicenseContacts(License portalLic, LicenseDetail__c sfLic) {
        List<String> portalEmails = new List<String>();
        String primaryCtEmail = '';
        for(LicenseContact contact : portalLic.license_contacts) {
            portalEmails.add(contact.email);
            if('primary'.equalsIgnoreCase(contact.user_type)){
            	primaryCtEmail = contact.email;
            }
            System.debug('portalEmails : ' + contact.email);
        }
        
        list<License_Contacts__c> licCtExisting = [Select Contact__c,Contact__r.email, ID, License__c, Need_Operations_Email__c, Need_Service_Email__c, Contact_Type__c from License_Contacts__c where Contact__r.email in :portalEmails and license__r.id = :sfLic.id];
        map<String,License_Contacts__c> emailToLicCtMap = new map<String, License_Contacts__c>();
        for(License_Contacts__c licCt:licCtExisting){
            emailToLicCtMap.put(licCt.Contact__r.email,licCt);
            System.debug('emailToLicCtMap : ' + licCt.Contact__r.email);
        }
        String accId = null;
        list<Contact> contactsExisting = [Select id, email, AccountId from Contact where email in :portalEmails];
        map<String,Contact> emailToCtMap = new map<String, Contact>();
        for(Contact existingCt: contactsExisting){
            emailToCtMap.put(existingCt.email,existingCt);
            if(primaryCtEmail == null || primaryCtEmail.equals('')){
            	primaryCtEmail = existingCt.email;
            }
            if(accId==null && primaryCtEmail.equals(existingCt.email)){
                accId = existingCt.AccountId;
            }
            System.debug('emailToCtMap : ' + existingCt.email);
        }

        list<Lead> leadsExisting = [Select Id, LeadSource,Status,Email, Company, ownerid from Lead where IsConverted=false and email in :portalEmails];
        map<String,Lead> emailToLeadMap = new map<String, Lead>();
        for(Lead lead: leadsExisting){
            emailToLeadMap.put(lead.email,lead);
        }
        
        list<License_Contacts__c> licCts = new list<License_Contacts__c>();
        list<PortalLeadToLicenseManagerInput> leads = new list<PortalLeadToLicenseManagerInput>();
        Map<String, EmailData> emails = new Map<String, EmailData>();
        EmailData emailData = null;
        
        for(LicenseContact contact : portalLic.license_contacts) {
            if (emailToLicCtMap.get(contact.email) != null) {
                continue;
            }
            Contact sfLicenseCt = emailToCtMap.get(contact.email);
            if(sfLicenseCt != null && (emailToLicCtMap.get(contact.email) == null)) {
                System.debug('Adding enterprise user : ' + sfLicenseCt.Id);
                License_Contacts__c newLicCt = new License_Contacts__c(Contact__c=sfLicenseCt.Id,License__c=sfLic.id,
                                        Need_Operations_Email__c=Boolean.valueOf(contact.subscribeLicenseNotification),
                                        Need_Service_Email__c=Boolean.valueOf(contact.subscribeSaasNotification),
                                        Contact_Type__c=contact.user_type);
                licCts.add(newLicCt);
            }
            Lead ld = emailToLeadMap.get(contact.email);
            emailData = new EmailData();
            emailData.subscribeSaasNotification = Boolean.valueOf(contact.subscribeSaasNotification);
            emailData.subscribeLicenseNotification = Boolean.valueOf(contact.subscribeLicenseNotification);
            emails.put(contact.email, emailData);            
            if(ld != null) {
                PortalLeadToLicenseManagerInput input = new PortalLeadToLicenseManagerInput();
                input.email = ld.Email;
                input.status = ld.status;
                input.accountName = ld.Company;
                input.convertedAccountId = accId;
                input.leadOwnerId = ld.ownerid;
                input.leadId = ld.id;
                leads.add(input);
            }
        }
        //Setting the in progress so that there is no chained reaction of pulling licenses for additional users
        PortalLock.acquireLock();
        PortalLeadToLicenseManager.convertLeadsToContacts(getLeadInputMap(leads));
        PortalLock.releaseLock();

        for(PortalLeadToLicenseManagerInput pli : leads) {
            EmailData leadEmailData = emails.get(pli.email);
            if(pli.convertedContactId!=null && !pli.convertedContactId.trim().equals('')){
                License_Contacts__c newLicCt = new License_Contacts__c(Contact__c=pli.convertedContactId,License__c=sfLic.id,
                                    Need_Operations_Email__c=Boolean.valueOf(leadEmailData.subscribeLicenseNotification),
                                    Need_Service_Email__c=Boolean.valueOf(leadEmailData.subscribeSaasNotification),
                                    Contact_Type__c='ADDITIONAL');
                licCts.add(newLicCt);
            }
        }

        upsert licCts;
        
        return licCts;
    }
    
    /*
     * Helper method to get the Lead Input map by Lead ID
     */
    public static map<String, PortalLeadToLicenseManagerInput> getLeadInputMap(list<PortalLeadToLicenseManagerInput> leadInputs){
        map<String,PortalLeadToLicenseManagerInput> leadInputMap = new map<String, PortalLeadToLicenseManagerInput>();
        for(PortalLeadToLicenseManagerInput leadInput:leadInputs){
            String leadId = leadInput.leadId;
            leadInputMap.put(leadId,leadInput);
        }
        return leadInputMap;
    }
    
    public class Users{
        public User_License[]users;
    }
    
    public class User_License{
        public String email;
        public License[] licences;
    }
    
    public class License{
        public String MacAddress;
        public String ProductType;
        public String saasPassword;
        public String created_date;
        public String operationType;
        public String licenseId;
        public String customerSaasUrl;
        public String saasAccount;
        public String expiryDate;
        public String saasUserName;
        public String customerName;
        public LicenseAgent[] license_agents;
        public LicenseContact[] license_contacts;
    }
    
    public class LicenseAgent{
        public Integer agent_count;
        public String agent_type;
        public Integer old_count;
    }
    
    public class LicenseContact{
    	public String userID;
    	public String lastName;
    	public String firstName;
    	public String email;
    	public String user_type;
    	public String subscribeSaasNotification;
    	public String subscribeLicenseNotification;
    }
    
    public class SAASEnv{
        public String envName;
    }
	
	public class EmailData {
		public Boolean subscribeSaasNotification;
		public Boolean subscribeLicenseNotification;
	}
    
    public static testMethod void testParseSSGetLicenseJSON(){
    	EnvironmentSettings.testEnvironmentSettings();
    	RESTAPI.unittestMode=true;
        String json=' {"users": [{"licences": [{"MacAddress": null, "ProductType": "On-Premise", "saasPassword": "jyvfeckopk5i", "license_contacts": [{"lastName": "einstein", "primaryContact": true, "email": "a.einstein@tarams.com","userID":"1223","user_type":"primary","subscribeSaasNotification":"true","subscribeLicenseNotification":"true"}], "saas": {"envName": "selfservice"}, "operationType": "SS_PROVISION_TRIAL", "license_agents": [{"agent_count": "5", "agent_type": ".Net", "old_count": "0"}, {"agent_count": "0", "agent_type": "PHP", "old_count": "0"}, {"agent_count": "5", "agent_type": "Java", "old_count": "0"}, {"agent_count": "10", "agent_type": "Total", "old_count": "0"}, {"agent_count": "0", "agent_type": "Machine", "old_count": "0"}], "licenseId": "136887570298LDJ", "customerSaasUrl": "physicstesttarams", "saasAccount": "physicstesttarams", "expiryDate": "2013-06-02 00:00:00", "saasUserName": "physicstesttarams", "customerName": "physics"},{"MacAddress": null, "ProductType": "SAAS", "saasPassword": "jyvfeckopk5i",  "license_contacts": [{"lastName": "einstein", "primaryContact": true, "email": "a.einstein@tarams.com","userID":"1223","user_type":"primary","subscribeSaasNotification":"true","subscribeLicenseNotification":"true"}], "saas": {"envName": "selfservice"}, "operationType": "SS_PROVISION_TRIAL", "license_agents": [{"agent_count": "5", "agent_type": ".Net", "old_count": "0"}, {"agent_count": "0", "agent_type": "PHP", "old_count": "0"}, {"agent_count": "5", "agent_type": "Java", "old_count": "0"}, {"agent_count": "10", "agent_type": "Total", "old_count": "0"}, {"agent_count": "0", "agent_type": "Machine", "old_count": "0"}], "licenseId": "136887570298LDJ", "customerSaasUrl": "physicstesttarams", "saasAccount": "physicstesttarams", "expiryDate": "2013-06-02 00:00:00", "saasUserName": "physicstesttarams", "customerName": "physics"}], "email": "a.einstein@tarams.com"}]}';
        Map<String,Contact> emailCtMap = new Map<String,Contact>();
        Contact ct = new Contact();
        ct.FirstName='fName';
        ct.LastName='lName';
        ct.Email='a.einstein@tarams.com';
        upsert ct;
        emailCtMap.put('a.einstein@tarams.com',ct);
        ClaimLicenseJSonParser.parseSSGetLicenseJSON(json,emailCtMap);
        
        ClaimLicenseJSonParser.License cjl = new ClaimLicenseJSonParser.License();
        ClaimLicenseJSonParser.LicenseAgent cla = new ClaimLicenseJSonParser.LicenseAgent();
        ClaimLicenseJSonParser.SAASEnv cls = new ClaimLicenseJSonParser.SAASEnv();
        ClaimLicenseJSonParser.User_License cul = new ClaimLicenseJSonParser.User_License();
        ClaimLicenseJSonParser.Users cu = new ClaimLicenseJSonParser.Users();
        LicenseContact licCt = new LicenseContact();
    }
    
    
    
}