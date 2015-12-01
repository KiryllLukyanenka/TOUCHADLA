public class PortalLicenseSynch {

    /*
     * Pull licenses from portal and store in SFDC
     */
    public static final String ACTION_PULL_AND_STORE_LICENSES = 'ACTION_PULL_AND_STORE_LICENSES';
    
    /*
     * Store licenses in SFDC based on input userLicenses
     */
    public static final String ACTION_STORE_LICENSES = 'ACTION_STORE_LICENSES';
    
    /*
     * Only pull licenses from portal
     */
    public static final String ACTION_PULL = 'ACTION_PULL';
    
    /*
     * Action to specify what needs to be done, 
     * - Pull License and Store dependencies
     * - Or store License dependencies based on input given
     */
    public String action{get;set;}
    
    /*
     * Input of email ids if action specified is ACTION_PULL_AND_STORE_LICENSES
     */
    public list<String> emailIds{get;set;}
    
    /*
     * Input of license if action specified is ACTION_STORE_LICENSES
     */
    public PortalDataType.User_License[] userLicenses{get;set;}
    
    public map<String,Contact> emailToContactMap {get;set;}
    
    private map<String,Lead> emailToLeadMap {get;set;} 
    
    private map<PortalDataType.License, String> licensePrimaryEmailMap{get;set;}
    
    private map<PortalDataType.License, list<String>> licenseAdditionalEmailsMap{get;set;}
    
    private map<PortalDataType.License, LicenseDetail__c> backendLicToSFLicMap {get;set;}

    private map<String,Account> accountToSystemNameMap = new map<String,Account>();
    
    /*
     * Set the opportunity id for manual lead convert
     */
    public  String opportunityId;
    
    /*
     * Set the salesforce account id for auto lead conversion
     */
    public String accountIdForLeadConvert {get;set;}
    
    private Map<String, String> appsMap = new Map<String, String>();
    private Map<String, UserData> userDataMap = new Map<String, UserData> (); 
    
    private List<CompanyUserAPIInput> contactsAndLeadsInput;
    
    public String ssBuyAcctName;
    
    private Account accSSBuy;
    
    private String systemName = '';
    
    /*
     * main logic to do all steps for the specified input actions. If action contains PULL, pull licenses from portal. If action contains
     * STORE, save the details in salesforce db
     */
    public void synch(){
    	try {
	    	if(action.contains('PULL')) {
		        pullLicenses();
	    	}
	    	if(action.contains('STORE')) {
	        	identifyAccountForAzure();
	        	if(accountIdForLeadConvert != null || ssBuyAcctName != null) {
			        identifyEmailsForLicenses();
			        identifyUserCompChanges();
			        if(accountIdForLeadConvert == null && ssBuyAcctName != null) {
			        	System.debug('Inside ss buy if');
			        	accSSBuy = new Account(name=ssBuyAcctName);
			        	//upsert accSSBuy;
			        	//accountIdForLeadConvert = accSSBuy.id;
			        }
			        
			        System.debug('accSSBuy : ' + accSSBuy);
			        try{
			        	invokeCompanyUserAPIs();
			        }catch(Exception e){
			        	EmailUtil.notifyError(e,null);
			        }
			        PortalLock.acquireLock();
			        if(accountIdForLeadConvert == null  && ssBuyAcctName != null) {
			        	upsert accSSBuy;
			        	accountIdForLeadConvert = accSSBuy.id;
			        }
			        convertLeads();
			        updatePermissions();
			        storeLicensesAndDependencies();
	        	}
	        }
	        System.debug('Ended');    
    	}
    	catch(Exception e) {
    		System.debug('Sync Stacktrace : ' + e.getStackTraceString());
    		System.debug('Sync Message : ' + e.getMessage());
    	}
    	
    }
    
    /*
     * If saas url contains azure, pull azure licenses and store in saleforce db
     */
    private void identifyAccountForAzure() {
    	System.debug('Inside identifyAccountForAzure');
    	if(userLicenses == null) {
    		return;
    	}
	     for(PortalDataType.User_License userLic : userLicenses) {
	     	for(PortalDataType.License lic:userLic.licenses){
				if(lic.customerSaasUrl != null && lic.customerSaasUrl.indexOf('azure-store') != -1){
			    	System.debug('Inside customerSaasUrl if');
			         try{
			         	String accID = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.MICROSOFT_WINDOWS_AZURE_STORE);
				    	System.debug('accID : ' + accID);
			         	
			            if(accID!=null && accountIdForLeadConvert == null){
			                accountIdForLeadConvert = accID;
			            }
			        }catch(Exception e){
			        }
			    }
	     	}	
	     } 	
    }
    
    /*
     * Create map of license and primary and addtional emails
     */
    private void identifyEmailsForLicenses() {
    	licensePrimaryEmailMap = new map<PortalDataType.License, String>();
    	licenseAdditionalEmailsMap = new map<PortalDataType.License, list<String>> ();
	     for(PortalDataType.User_License userLic : userLicenses) {
	     	for(PortalDataType.License lic:userLic.licenses){
	     		for(PortalDataType.PortalContact contact : lic.contacts) {
	     			if(contact.user_type == 'PRIMARY') {
	     				licensePrimaryEmailMap.put(lic, contact.email);
	     			}
	     			else {
	     				list<String> additionalEmails = licenseAdditionalEmailsMap.get(lic);
	     				if(additionalEmails == null) {
	     					additionalEmails = new list<String>();
	     					licenseAdditionalEmailsMap.put(lic, additionalEmails);
	     				}
	     				additionalEmails.add(contact.email);
	     			}
	     		}
	     	}
	     }
    }
    
    /*
     * Pull licenses from portal for given email ids
     */
    private void pullLicenses(){
        //TODO add the logic of invoking GETLicenseAPI and store the response in userLicenses
        BackendLayer bl = new BackendLayer();
        GetLicensesBackend backned = new GetLicensesBackend(emailIds);
        bl.addBackend(backned);
        if(bl.invokeBackend()){
            //Returned User Licenses Object from backend
            
            //TODO store in the this.UserLicenses object and not in local variable
            userLicenses = backned.userLicenses;
        }
        
    }
    
    /*
     * iterate through all license and license_users
     * get unique list of email ids
     * for the email ids check if there is an existing contact - build email id to contact map
     * if not check if there s a lead - build email id to lead map
     * for email to contact map - build CompanyUserAPIInput and add it list of companyUserAPIInput class
     * for email to lead map - build companyUserAPIInput and add accountId as account id persisted from any of the key from contactmap
     * store lead id instead of contact id in userdata
     */
    public void identifyUserCompChanges(){
        //TODO 
         System.debug('In identifyUserCompChanges');
         List<String> tempEmails ;//= emailIds;
         String companyId = '';
         if(tempEmails == null) {
         	tempEmails = new List<String>();
	         for(PortalDataType.User_License userLic : userLicenses) {
	         	companyId = userLic.company_id;
	         	for(PortalDataType.License lic:userLic.licenses){
	         		for(PortalDataType.PortalContact contact : lic.contacts) {
	         			tempEmails.add(contact.email);
	         		}
	         	}
	         }
         	
         }
         
		Set<String> emailSet = new Set<String>();
		List<String> emails = new List<String>();
		emailSet.addAll(tempEmails);
		emails.addAll(emailSet);
         

        System.debug('In identifyUserCompChanges 1 ' + emails);
        List<CompanyUserAPIInput> companyLeadInputs = new List<CompanyUserAPIInput>();
        List<CompanyUserAPIInput> companyConInputs = new List<CompanyUserAPIInput>();
         
        list<Contact> contactsExisting = [Select id, email,AccountId, FirstName, LastName, (Select id, Contact__c, User_Portal_Id__c,Docs__c,Download__c,ZenDesk__c,LMS__c ,ADUAUserDetails__c from Contact_Portal_User__r) from Contact where email in :emails];
        emailToContactMap = new map<String, Contact>();
        for(Contact existingCt: contactsExisting){
            emailToContactMap.put(existingCt.email,existingCt);
            System.debug('emailToCtMap : ' + existingCt.email);
        }
        
        System.debug('In identifyUserCompChanges 2');
         
        list<Lead> leadsExisting = [Select Id, LeadSource,Status,Email, Company, FirstName, LastName, ownerid from Lead where IsConverted=false and email in :emails];
        emailToLeadMap = new map<String, Lead>();
        for(Lead lead: leadsExisting){
        	//TODO add entry to it only if not present in the emailToContactMap
        	if(emailToContactMap.get(lead.email) == null) {
	            emailToLeadMap.put(lead.email,lead);
				System.debug('emailToLeadMap : ' + lead.email);
        	}
        }
        
        System.debug('In identifyUserCompChanges 3');
        System.debug('emailToContactMap : ' + emailToContactMap.size());
         
        Map<String, CompanyUserAPIInput> existingCompanyMap = new Map<String, CompanyUserAPIInput>();
        for(String email : emailToContactMap.keyset()) {
        	//TODO Use a Map here instead of a method wich iterates through the entries everytime
        	CompanyUserAPIInput companyInput = existingCompanyMap.get(emailToContactMap.get(email).accountId);
        	if(companyInput == null) {
	        	companyInput = new CompanyUserAPIInput();
	        	existingCompanyMap.put((emailToContactMap.get(email).accountId), companyInput);
        	}
        	companyInput.companyId = companyId;
        	companyInput.accountId = emailToContactMap.get(email).accountId;
        	System.debug('In identifyUserCompChanges 4');
        	
			List<UserData> users = companyInput.users;
			if(users == null) {
				users = new List<UserData>();
			}        	 
			UserData user = new UserData();
			user.userEmail = email;
			user.contactId = emailToContactMap.get(email).id;
			user.applications = 'download-zones/saas-public,download-zones/onpremise-public,docs/docs-customer,learning-system/lms-learner,community/community-customer,help';//TODO fill the hardcoded values
			appsMap.put(user.userEmail, user.applications);
			user.firstName = emailToContactMap.get(email).firstName;
			user.lastName = emailToContactMap.get(email).lastName;
			userDataMap.put(email, user);
			users.add(user);
			
			companyInput.users = users;
        	companyConInputs.add(companyInput);  
        }
        
        System.debug('In identifyUserCompChanges 5');
        
        Map<String, CompanyUserAPIInput> existingLeadCompanyMap = new Map<String, CompanyUserAPIInput>();
        
        for(String email : emailToLeadMap.keyset()) {
        	System.debug('In identifyUserCompChanges 6');
        	
        	//TODO Use a Map here instead of a method wich iterates through the entries everytime
        	CompanyUserAPIInput companyInput = null;
        	
        	if(companyConInputs.size() > 0) {
        		companyInput = existingLeadCompanyMap.get(companyConInputs[0].accountId);
        	}
        	if(companyInput == null) {
	        	companyInput = new CompanyUserAPIInput();
	        	companyInput.accountId = accountIdForLeadConvert;
	        	existingLeadCompanyMap.put(accountIdForLeadConvert, companyInput);
        	}
        	
        	/*if(accountIdForLeadConvert == null && companyConInputs.size() > 0) {
        		accountIdForLeadConvert = companyConInputs[0].accountId;
        	}*/
        	System.debug('accountIdForLeadConvert : ' + accountIdForLeadConvert);
        	
			List<UserData> users = companyInput.users;
			if(users == null) {
				users = new List<UserData>();
			}        	 
			UserData user = new UserData();
			user.userEmail = email;
			user.leadid = emailToLeadMap.get(email).id;
			user.applications = 'download-zones/saas-public,download-zones/onpremise-public,docs/docs-customer,learning-system/lms-learner,community/community-customer,help';//TODO fill the hardcoded values
			appsMap.put(user.userEmail, user.applications);
			user.firstName = emailToLeadMap.get(email).firstName;
			user.lastName = emailToLeadMap.get(email).lastName;
			//user.accountId = accountIdForLeadConvert;
			
			userDataMap.put(email, user);
			
			users.add(user);
			
			companyInput.users = users;
			System.debug('Lead company details : ' + companyInput.users);
        	companyLeadInputs.add(companyInput);
        	
        }
        
    	contactsAndLeadsInput = new List<CompanyUserAPIInput>();
    	contactsAndLeadsInput.addAll(companyConInputs);
    	contactsAndLeadsInput.addAll(companyLeadInputs);
    	
    	System.debug('In identifyUserCompChanges size : ' + contactsAndLeadsInput.size());  
        
        
    }
    
    public class LeadConversionInput{
    	String leadId;
    	String accountId;
    }
    
    /*
     * Do the lead auto conversion based on lead email map and account id passed from various flows to sync api
     */
    public void convertLeads(){
    	//TODO go through list of lead convertion input objects and do the lead conversion logic
    	//go through this.emailToLeadMap and do conversion
    	//after conversion for converted contacts, update the entries in this.emailToContactMap
    	
    	
    	//TODO Go through lead conversion inputs and not portal lead to license manager inputs
        list<LeadConversionInput> leads = new list<LeadConversionInput>();
    	
    	for(String email : emailToLeadMap.keyset()) {
    		Lead ld = emailToLeadMap.get(email);
            if(ld != null) {
                LeadConversionInput input = new LeadConversionInput();
                input.leadId = ld.id;
                input.accountId = accountIdForLeadConvert;
                leads.add(input);
            }
    	}
    	convertLeadsToContacts(leads);
    	
    }
    
    
    /*
     * Convert the lead under the target account. 
     * Here check is made to filter out leads that are already converted.
     * After the convertion is done, call updateConvertedContactIds to store 
     * the converted contact ids for each of the leads. 
     */
     
    public void convertLeadsToContacts(List<LeadConversionInput> leadInputs){
    	//TODO rework this to take list<LeadConvertionInput> as input 
        // FCCRM Edit: Running as passive user.
        FCRM.FCR_SupportAPI.SetPassiveModeInContext();
        //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        list<Database.Leadconvert> leadConvertInputs = new list<Database.Leadconvert>();
        // FCCRM Edit: create a set of lead status labels that represent a converted lead         
        List<LeadStatus> convertStatuses = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true];
        Set<String> convertStatusLabels = new Set<String>();
        // FCCRM Edit: create a map of leads by their Ids
        for (LeadStatus ls : convertStatuses) convertStatusLabels.add(ls.MasterLabel); 
        Set<Id> leadToConvertIds = new Set<Id>();
        for(LeadConversionInput input: leadInputs) leadToConvertIds.add(input.leadId);
        for(LeadConversionInput input: leadInputs){
            String leadId = input.leadId;
            System.debug('The lead id ' + leadId);
            Database.Leadconvert leadConvert = new Database.LeadConvert();
            leadConvert.setAccountId(input.accountId);
            leadConvert.setDoNotCreateOpportunity(true);
            leadConvert.setLeadId(leadId);
            //leadConvert.setConvertedStatus(convertStatus.MasterLabel);
             // FCCRM Edit: If lead status is mapped as a conversion status – leave the same status, else set status to 'Recycled' 
            leadConvert.setConvertedStatus('Recycled');
            leadConvertInputs.add(leadConvert);
        }
        list<Database.LeadConvertResult> lcrs = Database.convertLead( leadConvertInputs,false);
        
        updateConversionResult(lcrs);
    }
    
    
    /*
     * Query all the leads for the leadIds passed and retrieve the converted contact ids
     */
    private void updateConversionResult(list<Database.LeadConvertResult>leadConvertResults){
        //rewrite this to update emailIdToContactMap with new converted contacts.. remove all existing code
        List<String> contactIds = new List<String>();
        for(Database.LeadConvertResult leadConvertRes:leadConvertResults){
            if(leadConvertRes.isSuccess()){
         		contactIds.add(leadConvertRes.getContactId());
         		System.debug('Converted opp id : ' + leadConvertRes.getOpportunityId());
         		if(leadConvertRes.getOpportunityId() != null && opportunityId == null) {
         			opportunityId = leadConvertRes.getOpportunityId();
         		}   	
            }
            
	        Database.Error[] errors = leadConvertRes.getErrors();
	        for(Database.Error error : errors) {
	            System.debug('Lead conversion error : ' + error.getMessage());
	            System.debug('Error lead id : ' + leadConvertRes.getLeadId());
	            
	        }
        }
        
        list<Contact> contactsExisting = [Select id, email,AccountId, (Select id, Contact__c, User_Portal_Id__c,Docs__c,Download__c,ZenDesk__c,LMS__c ,ADUAUserDetails__c from Contact_Portal_User__r) from Contact where id in :contactIds];
        for(Contact existingCt: contactsExisting){
            emailToContactMap.put(existingCt.email,existingCt);
            System.debug('Applications : ' + appsMap.get(existingCt.email));
            System.debug('Applications map : ' + appsMap.get(existingCt.email));
            
        }
        
    }
    
    /*
     * Update user permissions on salesforce side
     */
	private void setupADUAContact(Contact con, String applications) {
		
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        }

        Contact_Portal_User__c contactPortalUser = null;
        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME) != null)  {
	        contactPortalUser = (Contact_Portal_User__c)con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).get(0);
    	}
    	else {
	        contactPortalUser = new Contact_Portal_User__c();
        	contactPortalUser.put('Contact__c',con.Id);
        	}
        
        if(applications.contains('docs') || applications.contains(AppDConstants.ACCESSIBLE_DOCS)){
            contactPortalUser.Docs__c = true;
        }else{
            contactPortalUser.Docs__c = false;
        }
        
        if(applications.contains('download-zones') || applications.contains(AppDConstants.ACCESSIBLE_DOWNLOADS)){
            contactPortalUser.Download__c = true;
        }else{
            contactPortalUser.Download__c = false;
        }

        if(applications.contains('learning-system') || applications.contains(AppDConstants.ACCESSIBLE_LMS)){
            contactPortalUser.LMS__c = true;            
            
        }else{
            contactPortalUser.LMS__c = false;
        }
        
        if(applications.contains('help') || applications.contains(AppDConstants.ACCESSIBLE_ZENDESK)){
            contactPortalUser.ZenDesk__c = true;
        }else{
            contactPortalUser.ZenDesk__c = false;
        }
		
        //update con;
        
        upsert contactPortalUser;
		
	}    
    
    /*
     * Update portal with newly created account. Move users to new account and set user permissions
     */
    public void invokeCompanyUserAPIs(){
        //TODO make company calls input will be company call api input class
        System.debug('In invokeCompanyUserAPIs : ' + contactsAndLeadsInput);
        
        if(contactsAndLeadsInput != null) {
			
	        for(CompanyUserAPIInput companyAPIInput : contactsAndLeadsInput) {
	        	BackendLayer companyBackend = new BackendLayer();
	        	
	        	Account accountObj;
	        	if(companyAPIInput.accountId != null) {
		            accountObj = (Account)DataLayerConstants.fetchSingle('Account', companyAPIInput.accountId);
	        	}
	        	else {
	        		System.debug('Fetching ss buy acc details : ' +  accSSBuy);
	        		accountObj = accSSBuy;
	        	}
	            AccountBackend accBackend = new AccountBackend(accountObj,BackendConstants.OPCODE_ADD_COMPANY);
	            companyBackend.addBackend(accBackend);
	            System.debug('Before caling company api');
	            
	        	if(companyAPIInput.users != null) {
					for(UserData user : companyAPIInput.users) {
			            Account accObj;
			        	if(companyAPIInput.accountId != null) {
				            accObj = (Account)DataLayerConstants.fetchSingle('Account', companyAPIInput.accountId);
			        	}
			        	else {
			        		System.debug('Fetching ss buy acc details : ' +  accSSBuy);
			        		accObj = accSSBuy;
			        	}
			            
			            System.debug('User email :' + user.userEmail);
						ContactBackend_V2 conBackend = new ContactBackend_V2(getADUAObject(companyAPIInput, userDataMap.get(user.userEmail)), accObj, BackendConstants.OPCODE_ADD_USER);
						companyBackend.addBackend(conBackend);
					}            
	        	}
		    
		    	System.debug('Before calling user api');    
		        if(companyBackend.invokeBackend()) {
			    	System.debug('After calling user api');    
			    	String ctResponse = companyBackend.getResponse(BackendConstants.OPCODE_ADD_USER);
			    	System.debug(ctResponse);
			    }
	            
	        }
        }
        
        
        if(contactsAndLeadsInput != null) {
	        //Not sure how to modify ContactBackend_V2 yet
	        //BackendLayer userBackend = new BackendLayer();
        } 
        
        
    }    
    /*
     * Update the license in salesforce with new values from portal
     */
    private void updateLicenseInSF(LicenseDetail__c licInSF,PortalDataType.License lic, map<String,List<License_Agent__c>> portalLicenseIDToLicAgents,map<String,LicenseEUMInput> portalLicenseIDToEUMDetails){
        licInSF.MAC_Address__c=lic.MacAddress;
        licInSF.Product_Type__c=lic.ProductType;
        licInSF.ProcessState__c='SUCCESS';
        licInSF.SaaS_Password__c=lic.saasPassword;
        licInSF.SAAS_Account__c=lic.saasAccount;
        licInSF.SAAS_UserName__c=lic.saasUserName;
        licInSF.SaaS_Access_Key__c=lic.accessKey;
        licInSF.Stage__c=lic.stage;
        licInSF.License_Expiry_Date__c=Date.valueOf(lic.expiryDate);
        licInSF.Last_License_User__c=UserInfo.getUserId();
        licInSF.LastOpcode__c = BackendConstants.OPCODE_PORTAL_SS_USER_UPGRADES_AGENTS;
        licInSF.License_Time__c=Date.valueOf(lic.created_date);
        licInSF.License_BackendID__c=lic.id;
        licInSF.Custom_URL_Name__c=lic.customerSaasUrl;
        list<License_Agent__c> licAgentsInSF = licInSF.License_Agents__r;
        if(licAgentsInSF==null){
            licAgentsInSF = new list<License_Agent__c>();
        }
        if('SAAS'.equals(licInSF.Product_Type__c)){
            licInSF.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
        }else{
            licInSF.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        }
        for(PortalDataType.LicenseAgent licAgent:lic.license_agents){
            boolean found=false;
            for(License_Agent__c licAgentInSF:licAgentsInSF){
                if(licAgentInSF.Agent_Type__c.equalsIgnoreCase(licAgent.agent_type)){
                    licAgentInSF.Count__c=licAgent.agent_count;
                    found=true;
                    break;
                }
            }
            if(!found){
                License_Agent__c licAgentSF = new License_Agent__c();
                licAgentSF.Agent_Type__c = licAgent.agent_type;
                licAgentSF.Count__c = licAgent.agent_count;
                licAgentSF.License__c=licInSF.ID;
                licAgentsInSF.add(licAgentSF);
            }
        }
        
        list<License_Agent__c> licAgentsSF = portalLicenseIDToLicAgents.get(lic.Id);
        if(licAgentsSF==null){
            licAgentsSF = new list<License_Agent__c>();
            portalLicenseIDToLicAgents.put(lic.Id,licAgentsSF);
        }
        for(License_Agent__c licAgentSF:licAgentsInSF){
            licAgentsSF.add(licAgentSF);
        }
        
        License_EUM_Details__c licenseEUMDetails = null;
        LicenseEUMInput eumInput = null;
        try{
            licenseEUMDetails = (License_EUM_Details__c)DataLayerConstants.fetchSingleWithWhereClause('License_EUM_Details__c', ' where License__c = \''+licInSF.Id+'\' and License__c!=null');
            eumInput = LicenseUtil.getEUMLicenseInput(licenseEUMDetails);
        }catch(Exception e){
            eumInput = LicenseUtil.getEUMLicenseInput(licenseEUMDetails);
        }
        
        if(lic.eum!=null){
            eumInput = getEUMDetails(eumInput, lic.eum);
            portalLicenseIDToEUMDetails.put(lic.id, eumInput);
        }
    }
    
    /*
     * Fetch existing licenses from salesforce based on license details pulled from portal
     */
    private map<String,LicenseDetail__c> getExistingLicenses(list<PortalDataType.User_License> userLicsFromBackend, map<String,List<License_Agent__c>> portalLicenseIDToLicAgents,map<String,LicenseEUMInput> portalLicenseIDToEUMDetails){
        map<String,PortalDataType.License> backendLicIdMap = new map<String,PortalDataType.License>();
        map<String,LicenseDetail__c> existingLicenses = new map<String,LicenseDetail__c>();
        
        //Populate backendLicIds by looping through input
        for(PortalDataType.User_License userLic:userLicsFromBackend){
            list<PortalDataType.License> licenses = userLic.licenses;
            if(licenses!=null){
                for(PortalDataType.License lic:licenses){
                    backendLicIdMap.put(lic.id,lic);
                }
            }
        }

        //Retrieve existing licenses in saleforce for the backendLicIDs got from input
        list<LicenseDetail__c> licensesInSF = null;
        try{
            licensesInSF = [Select ID,License_BackendID__c,
                            MAC_Address__c,Product_Type__c,ProcessState__c,SaaS_Password__c,SAAS_Account__c,
                            SAAS_UserName__c,SaaS_Access_Key__c,Stage__c,License_Expiry_Date__c,
                            Last_License_User__c, LastOPCODE__c,License_Time__c,Custom_URL_Name__c,
                            (Select License__c,Agent_Type__c,Count__c from License_Agents__r) 
                            from LicenseDetail__c where License_BackendID__c in:backendLicIdMap.keySet()];
        }catch(Exception e){
            EmailUtil.notifyError(e,  null);
        }

        for(LicenseDetail__c licInSF:licensesInSF){
            updateLicenseInSF(licInSF,backendLicIdMap.get(licInSF.License_BackendID__c),portalLicenseIDToLicAgents,portalLicenseIDToEUMDetails);
            existingLicenses.put(licInSF.License_BackendID__c,licInSF);
        }

        return existingLicenses;
    }
    
    /*
     *  Create or Update LicenseDetail__c, License_Agent__c, LicenseContact__c, License_System__c, License_EUM_Details__c, EUM_Web__c, EUM_Mobile__c
     */
    private void storeLicensesAndDependencies(){
        //TODO Create or Update LicenseDetail__c, License_Agent__c, LicenseContact__c, License_System__c, License_EUM_Details__c, EUM_Web__c, EUM_Mobile__c
        //Map for email to License detail object created or updated. This map will be used to create license contact association
        map<String,List<LicenseDetail__c>> licensesPulledFromPortalMap = new map<String,List<LicenseDetail__c>>();
        //map to portal license id to License Agent objects in salesforce
        map<String,List<License_Agent__c>> portalLicenseIDToLicAgents = new map<String,List<License_Agent__c>>();
        //mpa to portal license id to License EUM web and mobile objects in salesforce
        map<String,LicenseEUMInput> portalLicenseIDToEUMDetails = new map<String,LicenseEUMInput>();
        //map to store portal license id to matching license objects existing in salesforce which will be updated with values from portal
        map<String,LicenseDetail__c> existingLicenses = getExistingLicenses(userLicenses,portalLicenseIDToLicAgents,portalLicenseIDToEUMDetails);

        if(userLicenses!=null){
        	backendLicToSFLicMap = new map<PortalDataType.License, LicenseDetail__c>();
            for(PortalDataType.User_License userLic:userLicenses){
                String email = userLic.email;
                list<LicenseDetail__c> licensesForEmail = licensesPulledFromPortalMap.get(email);
                if(licensesForEmail==null){
                    licensesForEmail = new list<LicenseDetail__c>();
                    licensesPulledFromPortalMap.put(email,licensesForEmail);
                }
                for(PortalDataType.License lic:userLic.licenses){
                    String backendLicId = lic.id;
                    //Retrieve the existing license if already exists. This will be case during upgrade of licenses from self-service subscription update
                    LicenseDetail__c licDetail = existingLicenses.get(backendLicId);
                    //If License doesnot exist create new one
                    if(licDetail==null){
                        licDetail = createLicense(lic,portalLicenseIDToLicAgents);
                        LicenseEUMInput eumInput =  LicenseUtil.getEUMLicenseInput(null);
                        if(lic.eum!=null){
                            eumInput = getEUMDetails(eumInput, lic.eum);
                            portalLicenseIDToEUMDetails.put(lic.id, eumInput);
                        }
                    }
                    licensesForEmail.add(licDetail);
                    backendLicToSFLicMap.put(lic, licDetail);
                }

            }
        }
        
        list<LicenseDetail__c> licDetails = new list<LicenseDetail__c>();
        list<License_Agent__c> licAgents = new list<License_Agent__c>();
        list<License_Opportunity__c> licOpportunies = new list<License_Opportunity__c>();
        for(list<LicenseDetail__c> licenses:licensesPulledFromPortalMap.values()){
            licDetails.addAll(licenses);
        }
        //Insert new or Update existing licenses
        System.debug('licDetails : ' + licDetails);
        System.debug('licensesPulledFromPortalMap : ' + licensesPulledFromPortalMap);
        upsert licDetails;

        //Update License agents
        for(LicenseDetail__c lic:licDetails){
            List<License_Agent__c> licAgentsInMap = portalLicenseIDToLicAgents.get(lic.License_BackendID__c);
            for(License_Agent__c licAgent:licAgentsInMap){
                if(licAgent.License__c==null){
                    licAgent.License__c = lic.Id;   
                }
                licAgents.add(licAgent);
            }
        }
        upsert licAgents;
        
        if(portalLicenseIDToEUMDetails!=null && portalLicenseIDToEUMDetails.size()>0){
        	List<String> existingLicensesForEum = new List<String>();
            for(LicenseDetail__c lic:licDetails){
            	existingLicensesForEum.add(lic.id);
            }
            
            List<License_EUM_Details__c> existingEumDetails = [select id, license__c from License_EUM_Details__c where license__c in :existingLicensesForEum];
            
        	 
            for(LicenseDetail__c lic:licDetails){
                LicenseEUMInput eumInput = portalLicenseIDToEUMDetails.get(lic.License_BackendID__c);
                if(eumInput!=null){
                    if(eumInput.eumDetails.License__c==null){
                        eumInput.eumDetails.License__c = lic.id;
                    }
                    if(isEUMExisting(existingEumDetails, lic.id)) {
                    	continue;
                    }
                    
                    upsert eumInput.eumDetails;
                    
                    if(eumInput.eumWeb.License_EUM_Detail__c==null){
                        eumInput.eumWeb.License_EUM_Detail__c = eumInput.eumDetails.id;
                    }
                    if(eumInput.eumMobile.License_EUM_Detail__c==null){
                        eumInput.eumMobile.License_EUM_Detail__c = eumInput.eumDetails.id;
                    }
                    
                    upsert eumInput.eumWeb;
                    upsert eumInput.eumMobile;  
                }
            }
        }
        
        //if Opportunity exists, then store license-to-opportunity and also define contact roles
        System.debug('Before setting opp');
        List<String> existingLicIds = new List<String>();
        
        if(opportunityId!=null && !opportunityId.trim().equals('')){
            for(LicenseDetail__c lic:licDetails){
         		existingLicIds.add(lic.id);   	
            }
        }
				            	
		List<License_Opportunity__c> existingLicOpps = [select id, License__c, Opportunity__c from License_Opportunity__c where Opportunity__c = :opportunityId and License__c in : existingLicIds];         
        if(opportunityId!=null && !opportunityId.trim().equals('')){
            for(LicenseDetail__c lic:licDetails){
            	System.debug('Lic id : ' + lic.id);
            	System.debug('opp id : ' + opportunityId);
            	
            	if(isExistingLicOpp(existingLicOpps, opportunityId, lic.id)) {
            		continue;
            	}
            	
                License_Opportunity__c licOpportunity = new License_Opportunity__c();
                licOpportunity.License__c = lic.id;
                licOpportunity.Opportunity__c = opportunityId;
                licOpportunies.add(licOpportunity);
            }
            upsert licOpportunies;
            
            //Remove converted contactId - instead pass emailToContactMap
            //updateOpportunityContactRoles(opportunityId);  
        }
        
        /*
            Saving the license details in License History objects.
        */
        Map<String,List<SObject>> relationalLicenseHistoryMap = new Map<String,List<SObject>>();
        for(LicenseDetail__c lic: licDetails){
            relationalLicenseHistoryMap = LicenseUtil.getRelationalRecordsMap(lic);
            LicenseUtil.saveHistory(lic,relationalLicenseHistoryMap,'SUCCESS',false);
        }
        /*try{
            updateUserAndCompanyPortalID(userLicensesList,convertedCtIds);
        }catch(Exception e){
        }*/
        storeLicenseSystem(licensesPulledFromPortalMap,systemName);
        createLicenseContacts();
        
    }
    
    private boolean isExistingLicOpp(List<License_Opportunity__c> licOpps, String oppId, String licId) {
    	if(licOpps == null) {
    		return false;
    	}
    	for(License_Opportunity__c licOpp : licOpps) {
    		if(licId == licOpp.license__c && oppId == licOpp.Opportunity__c) {
    			return true;
    		} 
    		
    	}
    	
    	return false;
    	
    }
    
    
    /*
     * Create eum details in SFDC based on license data fetched from portal
     */
    private LicenseEUMInput getEUMDetails(LicenseEUMInput eumInput, PortalDataType.EUMDetails eum){
        eumInput.eumDetails.AccountName__c = eum.eum_account_name;
        eumInput.eumDetails.Access_Key__c = eum.eum_access_key;
        
        if(eum.web_eum_type.contains('PRO')){
            eumInput.eumWeb.Type__c = 'PRO';
        }else{
            eumInput.eumWeb.Type__c = 'LITE';
        }
        eumInput.eumWeb.Units__c = eum.web_agent_units; 
        eumInput.eumWeb.Allow_overages__c = Boolean.valueOf(eum.web_allow_overage);

        
        if(eum.mobile_type.contains('PRO')){
            eumInput.eumMobile.Type__c = 'PRO';
        }else{
            eumInput.eumMobile.Type__c = 'LITE';
        }
        eumInput.eumMobile.Units__c = eum.mobile_agent_units;
        eumInput.eumMobile.Allow_overages__c = Boolean.valueOf(eum.mobile_allow_overage);
        
        return eumInput;
    }

    
    /*
     * Create Salesforce License object for the license information got from backend
     */
    private LicenseDetail__c createLicense(PortalDataType.License lic,map<String,list<License_Agent__c>> portalLicenseIDToLicAgents){
        LicenseDetail__c licDetailSF = new LicenseDetail__c(MAC_Address__c=lic.MacAddress,
                                                            Product_Type__c=lic.ProductType, 
                                                            ProcessState__c='SUCCESS',
                                                            SaaS_Password__c=lic.saasPassword, 
                                                            SAAS_Account__c=lic.saasAccount,
                                                            SAAS_UserName__c=lic.saasUserName, 
                                                            SaaS_Access_Key__c=lic.accessKey,
                                                            Stage__c=lic.stage,
                                                            License_Expiry_Date__c=Date.valueOf(lic.expiryDate),
                                                            Last_License_User__c=UserInfo.getUserId(), 
                                                            LastOPCODE__c=BackendConstants.OPCODE_PORTAL_SS_USER_BUYS_AGENTS,
                                                            License_Time__c=Date.valueOf(lic.created_date),
                                                            License_BackendID__c=lic.id,
                                                            Custom_URL_Name__c=lic.customerSaasUrl);
        
        if('SAAS'.equals(licDetailSF.Product_Type__c)){
            licDetailSF.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
        }else{
            licDetailSF.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        }
        
        list<License_Agent__c> licAgentsSF = portalLicenseIDToLicAgents.get(lic.Id);
        if(licAgentsSF==null){
            licAgentsSF = new list<License_Agent__c>();
            portalLicenseIDToLicAgents.put(lic.Id,licAgentsSF);
        }
        for(PortalDataType.LicenseAgent licAgent:lic.license_agents){
            License_Agent__c licAgentSF = new License_Agent__c();
            licAgentSF.Agent_Type__c = licAgent.agent_type;
            licAgentSF.Count__c = licAgent.agent_count;
            licAgentsSF.add(licAgentSF);
        }
        return licDetailSF;
    }

    
    /* 
     * Associate list of converted contacts in to the opportunity contact role. If a role already exists then set role as Champion
     * Otherwise add a new role called Campion to the contact and set as primary if no primary contact role exists.
     */
    public void updateOpportunityContactRoles(String opportunityId){
    	List<String> ctIds = new List<String>();
    	for(String email : emailToContactMap.keySet()) {
    		Contact con = emailToContactMap.get(email);
    		ctIds.add(con.id);
    	}
        Opportunity myOpportunity = (Opportunity)DataLayerConstants.fetchSingle('Opportunity',opportunityId);
        	System.debug('In updateOpportunityContactRoles');
            if(CommonUtil.getPrimaryContactID(myOpportunity) == null){
	        	System.debug('In if block');
                List<OpportunityContactRole> oppRoles = [select Id,OpportunityId,IsPrimary,ContactId,Role from OpportunityContactRole where OpportunityId =:opportunityId and ContactId in: ctIds];
                if(oppRoles!=null && oppRoles.size() > 0){
                	System.debug('Opprole size > 1 ' + oppRoles.size());
                	for(OpportunityContactRole role: oppRoles){
                        role.Role = 'Champion';
                    }
                } else{
                	System.debug('Opprole size < 1 ' + oppRoles);
                    oppRoles = new List<OpportunityContactRole>(); 
                    for(String contactId: ctIds){
                        OpportunityContactRole opCtRole = new OpportunityContactRole();
                        opCtRole.OpportunityId=myOpportunity.Id;
                        opCtRole.ContactId=contactId;
                        opCtRole.Role = 'Champion';
                        opCtRole.IsPrimary = true;
                        oppRoles.add(opCtRole);
                    }
                }
				/*Map<String, OpportunityContactRole> existingOppRoleMap = new Map<String, OpportunityContactRole>();  
				for(OpportunityContactRole role: oppRoles){
                	existingOppRoleMap.put(role.ContactId, role);
                }
                for(String contactId: ctIds){
                	if(existingOppRoleMap.get(contactId) == null) {
	                    OpportunityContactRole opCtRole = new OpportunityContactRole();
	                    opCtRole.OpportunityId=myOpportunity.Id;
	                    opCtRole.ContactId=contactId;
	                    opCtRole.Role = 'Champion';
	                    opCtRole.IsPrimary = true;
	                    oppRoles.add(opCtRole);
                	}
                }*/
				                
                upsert oppRoles;
            }   
    }
    
    /*
     * Create license contacts based on map of primary emails and additional emails for each license 
     */
    private void createLicenseContacts(){
    	//go through licensePrimaryEmailsMap and get the emails for each license 
    	//from emailCtMap - get the contact for each email and create license contact for license to contact with prumary as true
    	//store in list of license contacts
    	// outside loop store license contacts to db
    	List<String> existingLicenses = new List<String>();
    	List<String> existingContacts = new List<String>();
    	
    	for(PortalDataType.License license : licensePrimaryEmailMap.keyset()) {
    		Contact con = emailToContactMap.get(licensePrimaryEmailMap.get(license));
    		System.debug('prim con email :' + licensePrimaryEmailMap.get(license));
    		System.debug('prim con :' + con);
    		System.debug('prim lic :' + backendLicToSFLicMap.get(license));
    		
    		//TODO check if contact is not null
    		if(con != null && (backendLicToSFLicMap.get(license) != null)) {
				existingLicenses.add(backendLicToSFLicMap.get(license).id);
				existingContacts.add(con.id);   			
    		}
    	}
    	
    	for(PortalDataType.License license : licenseAdditionalEmailsMap.keyset()) {
    		List<String> addtionalEmails = licenseAdditionalEmailsMap.get(license);
    		
    		for(String addlEmail : addtionalEmails) {
	    		Contact con = emailToContactMap.get(addlEmail);
	    		//TODO check if contact is not null, log error
	    		existingLicenses.add(backendLicToSFLicMap.get(license).id);
	    		existingContacts.add(con.id);
    		}
    	}
    	
    	List<License_Contacts__c> existingLicenseContacts = [select id, contact__c, license__c from License_Contacts__c where license__c in :existingLicenses and contact__c in :existingContacts];
    	
    	List<License_Contacts__c> licContacts = new List<License_Contacts__c>(); 
    	for(PortalDataType.License license : licensePrimaryEmailMap.keyset()) {
    		Contact con = emailToContactMap.get(licensePrimaryEmailMap.get(license));
    		System.debug('prim con email :' + licensePrimaryEmailMap.get(license));
    		System.debug('prim con :' + con);
    		System.debug('prim lic :' + backendLicToSFLicMap.get(license));
    		
    		//TODO check if contact is not null
    		if(con != null && (backendLicToSFLicMap.get(license) != null)) {
    			if(isExistingContact(existingLicenseContacts, backendLicToSFLicMap.get(license).id, con.id)) {
    				continue;
    			}
    			
	            License_Contacts__c newLicCt = new License_Contacts__c(Contact__c=con.Id,License__c=backendLicToSFLicMap.get(license).id,
	                                    Need_Operations_Email__c=true,
	                                    Need_Service_Email__c=true,
	                                    Contact_Type__c='Primary');
	            licContacts.add(newLicCt);
    		}
    	}
    	
    	for(PortalDataType.License license : licenseAdditionalEmailsMap.keyset()) {
    		List<String> addtionalEmails = licenseAdditionalEmailsMap.get(license);
    		
    		for(String addlEmail : addtionalEmails) {
	    		Contact con = emailToContactMap.get(addlEmail);
	    		//TODO check if contact is not null, log error
	    		System.debug('addlEmail :' + addlEmail);
	    		System.debug('con :' + con);
	    		System.debug('license : ' + backendLicToSFLicMap.get(license));
    			if(isExistingContact(existingLicenseContacts, backendLicToSFLicMap.get(license).id, con.id)) {
    				continue;
    			}
	    		
	            License_Contacts__c newLicCt = new License_Contacts__c(Contact__c=con.Id,License__c=backendLicToSFLicMap.get(license).id,
	                                    Need_Operations_Email__c=getLicenseEmailFlagForContact(license, addlEmail), //Hard code for now
	                                    Need_Service_Email__c=getOpsEmailFlagForContact(license, addlEmail), //Hard code for now
	                                    Contact_Type__c='ADDITIONAL');
	            licContacts.add(newLicCt);
    		}
    	}
    	
    	
    	upsert(licContacts);
    }
    
    
    private boolean getOpsEmailFlagForContact(PortalDataType.License license, String email) {
    	for(PortalDataType.PortalContact contact : license.contacts) {
    		if(contact.email == email) {
    			return Boolean.valueOf(contact.subscribeSaasNotification);
    		}
    	}	
    	
    	return true;
    }
    

    private boolean getLicenseEmailFlagForContact(PortalDataType.License license, String email) {
    	for(PortalDataType.PortalContact contact : license.contacts) {
    		if(contact.email == email) {
    			return Boolean.valueOf(contact.subscribeLicenseNotification);
    		}
    	}	
    	
    	return true;
    }

    
    private boolean isExistingContact(List<License_Contacts__c> existingLicenseContacts, String licId, String conId) {
    	if(existingLicenseContacts == null) {
    		return false;
    	}
    	for(License_Contacts__c licCt : existingLicenseContacts) {
    		if(licId == licCt.license__c && conId == licCt.contact__c) {
    			return true;
    		} 
    		
    	}
    	
    	return false;
    }
    

    private boolean isEumExisting(List<License_EUM_Details__c> eums, String licId) {
    	if(eums == null) {
    		return false;
    	}
    	for(License_EUM_Details__c eum : eums) {
    		if(licId == eum.license__c) {
    			return true;
    		} 
    		
    	}
    	
    	return false;
    }
    
    
    public class CompanyUserAPIInput{
        public String companyId;
        public String companyName;
        public String accountId;
        public List<UserData> users;
    }
    
    public class UserData{
        public string userEmail;
        public String contactId;
        public String leadId;
        public String applications;
        public String firstName;
        public String lastName;
    }
    
    /*
     * Create ADUA object to update portal with account and user details
     */
    private ADUAController_V2.ADUAUserDetails getADUAObject(CompanyUserAPIInput companyAPIInput, UserData userData) {
        //Account accountObj = (Account)DataLayerConstants.fetchSingle('Account', companyAPIInput.accountId);
		ADUAController_V2.ADUAUserDetails adua = new ADUAController_V2.ADUAUserDetails();
		System.debug('User data : ' + userData);
		adua.email = userData.userEmail;
		adua.isActive = 'true';
		adua.firstName = userData.firstName;
		adua.lastName = userData.lastName;
		
		Set<String> apps = new Set<String>();
		String[] appArr = userData.applications.split(',');
		for(String app : appArr) {
			apps.add(app);
		}
		adua.applications = apps;
		
		return adua;		
    }
    
   
       /*
     *  Backend Interaction Layer. 
     *  - Initializes the parameters 
     *  - make GetLicense API call 
     *  - Parse the repsonse and 
     *  - returns the user license list.
     */
     public class GetLicensesBackend extends Backend{
        public list<PortalDataType.User_License> userLicenses;
        public List<String> listOfEmails;
        public GetLicensesBackend(List<String> emails){
            super();
            this.listOfEmails = emails;
            this.opcode=BackendConstants.OPCODE_PORTAL_GET_LICENSE;
            setupInputParameters();
        }
        
        public override virtual void setupInputParameters(){
            List<JSONObject.value> contactEmailsArray = new List<JSONObject.value>();
            if(listOfEmails!=null){
                
                for(String emailId : listOfEmails ){
                    contactEmailsArray.add(
                        new JSONObject.value(new JSONObject(new JSONObject.JSONTokener(
                                                        '{"email":"'+emailId+'"}'))));
                }
            }
            BackendLayer.BackendParameter param = new BackendLayer.BackendParameter('emails',contactEmailsArray);
            System.debug('contactEmailsArray : ' + contactEmailsArray);
            getParameters().add(param);
            
        }
        
        public override virtual void handleResponse(String response, Integer statusCode){
            try{
            	System.debug('Response : ' + response);
                PortalDataType.Users u = (PortalDataType.Users) System.JSON.deserialize(response,PortalDataType.Users.class);
                this.userLicenses = u.users;
                removeDuplicates(this.userLicenses);
            }catch(Exception e){
                EmailUtil.notifyError(e,null);
            }
        }

    }
    
    private static void removeDuplicates(list<PortalDataType.User_License> userLicenses){
        map<String, PortalDataType.License> licMap = new map<String,PortalDataType.License>();
    	
        for(PortalDataType.User_License userLic:userLicenses){
            PortalDataType.License[] licensesForEmail = userLic.licenses;
            for(integer i = 0; i < userLic.licenses.size(); i++){
            	if(licMap.get(userLic.licenses[i].Id) != null) {
            		userLic.licenses.remove(i);
            		continue;
            	}
                licMap.put(userLic.licenses[i].Id, userLic.licenses[i]);
            }
            //userLic.licenses = licMap.values();
        }
    }
    
    private void updatePermissions() {
    	for(String email : emailToContactMap.keySet()) {
    		Contact con = emailToContactMap.get(email);
	    	setupADUAContact(con, appsMap.get(con.email));
    	}
 	   	
    }
    
    
    /*
     * Create and Store License-Contact and License-System with given system name and given set of contacts.
     */
    private void storeLicenseSystem(map<String,List<LicenseDetail__c>> 
                                                        licensesPulledFromPortalMap, String systemName ){
        //TODO need to make it more efficient by adding email filtering for the entries in backend to be retrieved only
        //list<Contact> convertedContacts = getContactsWithDefaultAccess(targetAccount,licensesPulledFromPortalMap.keySet());//[Select ID,Name,Email from Contact where AccountID=targetAccount.Id];
        list<License_System__c> licSystems = new list<License_System__c>();
        list<String> licIds = new list<String>();
 		for(String email:licensesPulledFromPortalMap.keySet()){
 			List<LicenseDetail__c> licenses = licensesPulledFromPortalMap.get(email);
 			for(LicenseDetail__c lic:licenses){
 				licIds.add(lic.Id);
 			}
 		}
 		list<License_System__c> licSystemsExisting = [Select License__c,Id,System__c from License_System__c where License__c in:licIds];
 		map<String, License_System__c> licIdToSystemMap = new map<String, License_System__c>();
 		for(License_System__c licSystem:licSystemsExisting){
            licIdToSystemMap.put(licSystem.License__c,licSystem);
        }
        
        for(String email:licensesPulledFromPortalMap.keySet()){
        	List<LicenseDetail__c> licenses = licensesPulledFromPortalMap.get(email);
 			for(LicenseDetail__c lic:licenses){
				if(lic!=null){
                	License_System__c licSys = licIdToSystemMap.get(lic.Id);
                    if(licSys == null){
                    	licSys = new License_System__c(license__c=lic.Id,System__c=systemName);
                    }
                    licSystems.add(licSys);
            	}
 			}
        }
        upsert licSystems;
    }
    
    
    public static void test(){
    	boolean lockObtained = PortalLock.acquireLockAsync();
    	System.debug(LoggingLevel.Info, 'Lock Obtained:'+lockObtained);	
    }
    
    
    
    /*
     * Wrapper for sync logic called from lead trigger.
     */
    @future (callout=true)
    public static void processData(List<String> listOfEmails, String acctId, String oppId, String acctName) {
    	try {
	    	PortalLicenseSynch sync = new PortalLicenseSynch();
	    	sync.action = PortalLicenseSynch.ACTION_PULL_AND_STORE_LICENSES; 
	    	sync.emailIds = listOfEmails;
	    	sync.accountIdForLeadConvert = acctId;
	    	sync.opportunityId = oppId;
	    	sync.ssBuyAcctName = acctName;
	    	sync.synch();	
    	}
    	catch(Exception e) {
    		System.debug('Stacktrace : ' + e.getStackTraceString());
    		System.debug('Message : ' + e.getMessage());
    	}
    	finally {
        	System.debug('After sync ...');
			PortalLock.releaseLock();
    	}
    	
    }
    
    public static PortalLicenseSynch processDataSync(list<String> listOfEmails, String acctId, String oppId, String accountName){
    	try {
    		PortalLicenseSynch sync = new PortalLicenseSynch();
		    sync.action = PortalLicenseSynch.ACTION_PULL_AND_STORE_LICENSES;
		    sync.emailIds = listOfEmails;
		    sync.accountIdForLeadConvert = acctId;
	    	sync.opportunityId = oppId;
	    	sync.ssBuyAcctName = accountName;
		    sync.synch();
		    return sync;
    	}
    	catch(Exception e) {
    		System.debug('Stacktrace : ' + e.getStackTraceString());
    		System.debug('Message : ' + e.getMessage());
    	}
    	finally {
        	System.debug('After sync ...');
			PortalLock.releaseLock();
    	}
    	return null;
    }
    
    public static PortalLicenseSynch processDataSync(PortalDataType.User_License[] userLicenses, String acctName) {
    	try {
    		PortalLicenseSynch sync = new PortalLicenseSynch();
		    sync.action = PortalLicenseSynch.ACTION_STORE_LICENSES; 
		    sync.ssBuyAcctName = acctName;
		    sync.userLicenses = userLicenses;
		    sync.synch();
		    return sync;
    	}
    	catch(Exception e) {
    		System.debug('Stacktrace : ' + e.getStackTraceString());
    		System.debug('Message : ' + e.getMessage());
    	}
    	finally {
        	System.debug('After sync ...');
			PortalLock.releaseLock();
    	}
    	return null;
    }
}