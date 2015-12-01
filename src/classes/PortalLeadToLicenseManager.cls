/*
 * PortalLeadToLicenseManager provides following functionalities:
 * - For every lead, convert to a contact
 * - Retrieve licenses from backend for each of these contacts
 * - Store license in salesforce along with license-user mapping
 * All the above operations are discrete functionalities so any combination 
 * of the above functionalities can be called.
 */
public with sharing class PortalLeadToLicenseManager {
    private static map<String,Account> accountToSystemNameMap = new map<String,Account>();
    private static list<String> allConvertedContactIds = new list<String>();
    private static String globalAccountId = null;
    /*
     * 1. Convert Lead under the target account
     * 2. Make Portal Call to get License
     * 3. Insert LicenseDetail with response from 2
     * 4. Insert new License contact for the license in 3 and contact in 1
     * 5. Insert new License System and mark as License as in 3 and System as Azure
     */
    public static void execute(list<PortalLeadToLicenseManagerInput> inputs){
        System.debug('In lead conversion logic');
        list<String> leadIds = new list<String>();
        list<String> convertedCtIds = new list<String>();
        String opportunityId = null;
        String systemName = null;
        map<String,PortalLeadToLicenseManagerInput> leadInputMap = getLeadInputMap(inputs);     
        convertLeadsToContacts(leadInputMap);
        
        for(PortalLeadToLicenseManagerInput pli: inputs){
            if(systemName==null){
                systemName = pli.systemName;
            }

            if(!pli.converted){
                leadIds.add(pli.leadId);
            }else{
                convertedCtIds.add(pli.convertedContactId);
                if(opportunityId==null){
                    opportunityId = pli.convertedOpportunityId;
                }
                if(globalAccountId==null){
                    globalAccountId = pli.convertedAccountId;
                }
            }
        }

        //Retrieve all the licesense details from portal and associate with the converted contact and opportunity
        allConvertedContactIds.addAll(convertedCtIds);
        String accId = globalAccountId;
        pullLicensesFromPortal(convertedCtIds,systemName,opportunityId);
        //Opportunity ID will be defined during manual lead convertion for self-service trials
        if(opportunityId!=null && !opportunityId.trim().equals('')){
            updateUsersToPortal(allConvertedContactIds, accId);
        }
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
    
    
    /*
     * Convert the lead under the target account. 
     * Here check is made to filter out leads that are already converted.
     * After the convertion is done, call updateConvertedContactIds to store 
     * the converted contact ids for each of the leads. 
     */
    public static void convertLeadsToContacts(map<String, PortalLeadToLicenseManagerInput> leadInputs){
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
        for(PortalLeadToLicenseManagerInput input: leadInputs.values()) leadToConvertIds.add(input.leadId);
        for(PortalLeadToLicenseManagerInput input: leadInputs.values()){
            String leadId = input.leadId;
            String accountName = input.accountName;
            Database.Leadconvert leadConvert = new Database.LeadConvert();
            globalAccountId = input.convertedAccountId;
            if(globalAccountId==null || globalAccountId.trim().equals('')){
                globalAccountId = (getTargetAccount(accountName,input.leadOwnerId).Id);
            }
            leadConvert.setAccountId(globalAccountId);
            leadConvert.setDoNotCreateOpportunity(true);
            leadConvert.setLeadId(leadId);
            //leadConvert.setConvertedStatus(convertStatus.MasterLabel);
             // FCCRM Edit: If lead status is mapped as a conversion status – leave the same status, else set status to 'Recycled' 
            leadConvert.setConvertedStatus(convertStatusLabels.contains(input.status) ? input.status : 'Recycled');
            leadConvertInputs.add(leadConvert);
        }
        list<Database.LeadConvertResult> lcrs = Database.convertLead( leadConvertInputs,false);
        
        updateConvertionResult(leadInputs,lcrs);
    }
    
    /*
     * Query all the leads for the leadIds passed and retrieve the converted contact ids
     */
    private static void updateConvertionResult(map<String,PortalLeadToLicenseManagerInput> leadInputMap, list<Database.LeadConvertResult>leadConvertResults){
        
        for(Database.LeadConvertResult leadConvertRes:leadConvertResults){
            if(leadConvertRes.isSuccess()){
                String leadId = leadConvertRes.getLeadId();
                PortalLeadToLicenseManagerInput input = leadInputMap.get(leadId);
                input.converted=true;
                input.convertedAccountId=leadConvertRes.getAccountId();
                input.convertedContactId=leadConvertRes.getContactId();
                input.convertedOpportunityId=leadConvertRes.getOpportunityId();
            }
            Database.Error[] errors = leadConvertRes.getErrors();
            for(Database.Error error : errors) {
                System.debug('Lead conversion error : ' + error.getMessage());
            }
        }
        
    }
    /*
     * Initialize the account name for the System Name. 
     * If not found in the system, create new account first time, 
     * then use the same account
     */
    private static Account initializeTargetAccount(String systemName, String leadOwnerId){
        Account targetAccount = accountToSystemNameMap.get(systemName);
        //If Azure retrieving the Account by ID mentioned in the portal property
        if(systemName.equalsIgnoreCase('Microsoft Windows Azure Store')){
            try{
                    String accID = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.MICROSOFT_WINDOWS_AZURE_STORE);
                    if(accID!=null){
                        targetAccount = new Account(ID=accID);
                        
                        accountToSystemNameMap.put(systemName,targetAccount);
                    }
            }catch(Exception e){
            }
        }
    if(targetAccount==null){
            try{
                targetAccount = [Select ID from Account where Name=:systemName limit 1];
            }catch(Exception e){}
            if(targetAccount==null){
                targetAccount = new Account(name=systemName,Industry='Service Provider/SI');
                if(leadOwnerId!=null && !leadOwnerId.trim().equals('')){
                    targetAccount.OwnerId = leadOwnerId;
                }
                upsert targetAccount;
            }
            accountToSystemNameMap.put(systemName,targetAccount);
        }
        return targetAccount;
    }

    public static Account getTargetAccount(String systemName, String leadOwnerId){
        return initializeTargetAccount(systemName,leadOwnerId);
    }
    
    /*
      Upgrading user from Self-Service user to Enterprise.
      1. Quering for Contact and Account details.
      2. Making Company and User backend calls.
      3. If the getUserDetails Api fails then, we are manually add all ther permissions and make backend calls.
      4. After successful backend calls, saving application status for a contact in Salesforce 
         by calling ADUAUtils.setupADUAContact().
    */
    @future (callout=true)
    public static void updateUsersToPortal(list<String> convertedCtIds, String accId){
        List<Contact> contactObjects = Database.query('select ID,ADUAUserDetails__c,Enable_Access__c, docs_fez__c, LMS__c, No_longer_at_Company__c,Docs__c,Download__c, Needs_Email__c,ZenDesk__c, Email, LastName, PortalID__c, Name,FirstName, LMS_Portal_User_Contact__c, LMS_Cloned__c, (Select id, Contact__c, User_Portal_Id__c,Docs__c,Download__c,ZenDesk__c,LMS__c ,ADUAUserDetails__c from Contact_Portal_User__r) from Contact where id in:convertedCtIds');
                                    
        Map<String,Contact> contactObjectMap = new Map<String,Contact>();                                    
        for(Contact con: contactObjects){
            System.debug('updateUsersToPortal : ' + con.email);
            contactObjectMap.put(con.email,con);
        }
                                    
        Account accountObj = (Account)DataLayerConstants.fetchSingle('Account', accId);
        ADUAController_V2.ADUAUser adUsers = null;
        String requestJson = UsersUtil.getUserDetailsRequestJson(contactObjects,accountObj.Name);  
        try{
            adUsers = UserDetailsBackend.getUserDetails(requestJson);
            if(adUsers!=null){
                System.debug('adUsers is not null');
                for(ADUAController_V2.ADUAUserDetails aduaUserDetails : adUsers.users){
                    String applicationStr = aduaUserDetails.getApplications();
                    System.debug('The application string : ' + applicationStr);
                    if(!applicationStr.contains('help')){
                        aduaUserDetails.applications.add('help');
                    }
                    if(!applicationStr.contains('learning-system/lms-learner')){
                        aduaUserDetails.applications.add('learning-system/lms-learner');
                    }
                }
            }else{
                System.debug('adUsers is null');
                adUsers = new ADUAController_V2.ADUAUser();
                adUsers.users = new List<ADUAController_V2.ADUAUserDetails>();
                for(Contact con: contactObjects){
                    ADUAController_V2.ADUAUserDetails adua = new ADUAController_V2.ADUAUserDetails();
                    adua.firstName = con.firstName;
                    adua.lastName = con.lastName;
                    adua.email = con.email;
                    adua.isActive = 'true';
                    adua.applications = new Set<String>();
                    adua.applications.add('download-zones/onpremise-public');
                    adua.applications.add('download-zones/saas-public');
                    adua.applications.add('help');
                    adua.applications.add('docs/docs-customer');
                    //adua.applications.add('learning-system/lms-learner');
                    adUsers.users.add(adua);
                }                                
                
            }
            
            BackendLayer backend = new BackendLayer();
            AccountBackend accBackend = new AccountBackend(accountObj,BackendConstants.OPCODE_ADD_COMPANY);
            backend.addBackend(accBackend);
            backend.addBackend(new MultipleContactsBackend_V2(adUsers.users, accountObj, null,null,null,BackendConstants.OPCODE_ADD_USER));
                
            if(backend.invokeBackend()){
                String accountResponse = backend.getResponse(BackendConstants.OPCODE_ADD_COMPANY);
                
                if(accountResponse == 'None') {
                    accountResponse = '';
                }
                Account_Portal_Company__c accountPortalCompany;
                
                if(accountObj.Portal_Company__r!=null && accountObj.Portal_Company__r.size()>0){
                        accountPortalCompany = accountObj.Portal_Company__r.get(0);
                        accountPortalCompany.Company_Portal_Id__c = accountResponse;
                }else{
                    accountPortalCompany = new Account_Portal_Company__c(
                        Company_Portal_Id__c = accountResponse);
                    accountPortalCompany.put('Account__c',accountObj.Id);
                }
                
                if(accountPortalCompany!=null){
                    upsert accountPortalCompany;
                }
                    
                for(ADUAController_V2.ADUAUserDetails aduaUserDetails : adUsers.users){
                    Contact con = contactObjectMap.get(aduaUserDetails.email);
                    ADUAUtils.setupADUAContact(con, aduaUserDetails.getApplications());
                }
            }
                
        }catch(Exception e){
            
        }
                                
    }

    /*
     * For a given list of contact ids, this method will: 
     * - initiate GetLicenseAPI call
     * - parse the response and insert license with agents in salesforce
     * - Insert license-contact for the generated license and input contacts
     * - insert in license-system with the specified system name
     */
    @future (callout=true)
    public static void pullLicensesFromPortal(list<string>convertedCtIds,String systemName, String opportunityId){
        BackendLayer bl = new BackendLayer();
        GetLicensesBackend backned = getLicenseBackendHandle(convertedCtIds);
        bl.addBackend(backned);
        if(bl.invokeBackend()){
            //Returned User Licenses Object from backend
            list<PortalDataType.User_License> userLicensesList = backned.userLicenses;
            
            try{
                //Parse the backendResponse and store Salesforce license
                storeLicensesAndDependenciesToSF(userLicensesList,systemName,convertedCtIds,opportunityId);
            }catch(Exception e){
                EmailUtil.notifyError(e,null);
            }
        }else{
           System.debug(LoggingLevel.Info,bl.getErrorMessage(true));
           EmailUtil.notifyError(bl.getErrorMessage(true),null);
        }
    }

    /*
     * Initiate GetLicenseBackend object for the given contactIds
     */
    private static GetLicensesBackend getLicenseBackendHandle(list<String> convertedCtIds){
        List<Contact> convertedContacts = [Select Id,Name,Email,FirstName,LastName from Contact 
                                                        where ID in:convertedCtIds];

        list<ContactWrapper> ctWrapperList = new list<ContactWrapper>();
        list<Contact_Portal_User__c> ctPortalUsers = new list<Contact_Portal_User__c>();
        
        for(Contact ct:convertedContacts){
            ContactWrapper ctWrapper = new ContactWrapper();
            ctWrapper.contactObj = ct;
            ctWrapper.selected=true;
            ctWrapperList.add(ctWrapper);
            Contact_Portal_User__c ctPortalUser = new Contact_Portal_User__c(Docs__c=true, ZenDesk__c=true, 
                                                                            Download__c=true, LMS__c=true);
            ctPortalUser.put('Contact__c',ct.Id);
            ctPortalUsers.add(ctPortalUser);
        }
        GetLicensesBackend getLicBkend = new GetLicensesBackend(ctWrapperList); 
        return getLicBkend;
    }



// Handle Portal User ID and Company ID for self-service users in Claim License flows
    /* public static void updateUserAndCompanyPortalID(list<PortalDataType.User_License> userLicenses,List<string> contactIds){
     String contactQuery = 'select id,Email,Account.id,(select id,Contact__c,User_Portal_Id__c from Contact_Portal_User__r) from contact where id in :contactIds';
        
     List<Contact> contactObjects = Database.query(contactQuery);       
 
        for(Contact con: contactObjects){
        for(PortalDataType.User_License userLic: userLicenses){
                
                    if(con.Contact_Portal_User__r == null &&  con.Email == userLic.email   ){
                        Contact_Portal_User__c ctPortalUser = new Contact_Portal_User__c();
                        ctPortalUser.Contact__c = con.Id;
                        ctPortalUser.User_Portal_Id__c = userLic.user_id ;
                        upsert ctPortalUser;
                        
                        /*Account_Portal_Company__c acctPortalCompany = new Account_Portal_Company__c();
                        acctPortalCompany.Account__c = con.Account.Id;
                        acctPortalCompany.Company_Portal_Id__c = userLic.company_id;
                        upsert acctPortalCompany;*//*
                    }   
            }           
        }    
     }*/


    /*
     * Store the licenses in salesforce along with license-contacts, license-systems and license agents
     */
    public static void storeLicensesAndDependenciesToSF(List<PortalDataType.User_License> userLicensesList, String systemName,list<string> convertedCtIds, String opportunityId){
        //Map for email to License detail object created or updated. This map will be used to create license contact association
        map<String,List<LicenseDetail__c>> licensesPulledFromPortalMap = new map<String,List<LicenseDetail__c>>();
        //map to portal license id to License Agent objects in salesforce
        map<String,List<License_Agent__c>> portalLicenseIDToLicAgents = new map<String,List<License_Agent__c>>();
        //mpa to portal license id to License EUM web and mobile objects in salesforce
        map<String,LicenseEUMInput> portalLicenseIDToEUMDetails = new map<String,LicenseEUMInput>();
        //map to store portal license id to matching license objects existing in salesforce which will be updated with values from portal
        map<String,LicenseDetail__c> existingLicenses = getExistingLicenses(userLicensesList,portalLicenseIDToLicAgents,portalLicenseIDToEUMDetails);

        if(userLicensesList!=null){
            for(PortalDataType.User_License userLic:userLicensesList){
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
            for(LicenseDetail__c lic:licDetails){
                LicenseEUMInput eumInput = portalLicenseIDToEUMDetails.get(lic.License_BackendID__c);
                if(eumInput!=null){
                    if(eumInput.eumDetails.License__c==null){
                        eumInput.eumDetails.License__c = lic.id;
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
        if(opportunityId!=null && !opportunityId.trim().equals('')){
            for(LicenseDetail__c lic:licDetails){
                License_Opportunity__c licOpportunity = new License_Opportunity__c();
                licOpportunity.License__c = lic.id;
                licOpportunity.Opportunity__c = opportunityId;
                licOpportunies.add(licOpportunity);
            }
            upsert licOpportunies;
            
            updateOpportunityContactRoles(opportunityId,convertedCtIds);  
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
        storeLicenseSystem(licensesPulledFromPortalMap,systemName,convertedCtIds);
        storeLicenseContacts(userLicensesList, licensesPulledFromPortalMap);
    }

    /* 
     * Associate list of converted contacts in to the opportunity contact role. If a role already exists then set role as Champion
     * Otherwise add a new role called Campion to the contact and set as primary if no primary contact role exists.
     */
    public static void updateOpportunityContactRoles(String opportunityId,list<String> convertedCtIds){
        Opportunity myOpportunity = (Opportunity)DataLayerConstants.fetchSingle('Opportunity',opportunityId);
            if(CommonUtil.getPrimaryContactID(myOpportunity) == null){
                List<OpportunityContactRole> oppRoles = [select Id,OpportunityId,IsPrimary,ContactId,Role from OpportunityContactRole where OpportunityId =:opportunityId and ContactId in: convertedCtIds];
                if(oppRoles!=null && oppRoles.size() > 0){
                    for(OpportunityContactRole role: oppRoles){
                        role.Role = 'Champion';
                    }
                } else{
                    oppRoles = new List<OpportunityContactRole>(); 
                    for(String contactId: convertedCtIds){
                        OpportunityContactRole opCtRole = new OpportunityContactRole();
                        opCtRole.OpportunityId=myOpportunity.Id;
                        opCtRole.ContactId=contactId;
                        opCtRole.Role = 'Champion';
                        opCtRole.IsPrimary = true;
                        oppRoles.add(opCtRole);
                    }
                }
                upsert oppRoles;
            }   
    }

    /*
     * Filter already existing licenses in salesforce to avoid duplication. This filtering relies on backend license id.
     */
    private static map<String,LicenseDetail__c> getExistingLicenses(list<PortalDataType.User_License> userLicsFromBackend, map<String,List<License_Agent__c>> portalLicenseIDToLicAgents,map<String,LicenseEUMInput> portalLicenseIDToEUMDetails){
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
     * Update the license in salesforce with new values from portal
     */
    private static void updateLicenseInSF(LicenseDetail__c licInSF,PortalDataType.License lic, map<String,List<License_Agent__c>> portalLicenseIDToLicAgents,map<String,LicenseEUMInput> portalLicenseIDToEUMDetails){
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
    
    private static LicenseEUMInput getEUMDetails(LicenseEUMInput eumInput, PortalDataType.EUMDetails eum){
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
    private static LicenseDetail__c createLicense(PortalDataType.License lic,map<String,list<License_Agent__c>> portalLicenseIDToLicAgents){
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
     * Create and Store License-Contact and License-System with given system name and given set of contacts.
     */
    private static void storeLicenseSystem(map<String,List<LicenseDetail__c>> 
                                                        licensesPulledFromPortalMap, String systemName,list<String> convertedCtIds ){
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
    
    /*
     *  Backend Interaction Layer. 
     *  - Initializes the parameters 
     *  - make GetLicense API call 
     *  - Parse the repsonse and 
     *  - returns the user license list.
     */
     public class GetLicensesBackend extends Backend{
        public list<ContactWrapper> contactWrapperList;
        public list<PortalDataType.User_License> userLicenses;
        public map<String,list<LicenseDetail__c>> contactEmailLicensesMap=new map<String,list<LicenseDetail__c>>();
        public map<String,list<License_Agent__c>>portalLicenseIDToLicAgentsMap=new map<String,list<License_Agent__c>>();
        public GetLicensesBackend(List<ContactWrapper> contactWrapperList){
            super();
            this.contactWrapperList = contactWrapperList;
            this.opcode=BackendConstants.OPCODE_PORTAL_GET_LICENSE;
            setupInputParameters();
        }
        
        public override virtual void setupInputParameters(){
            List<JSONObject.value> contactEmailsArray = new List<JSONObject.value>();
            if(contactWrapperList!=null){
                
                for(ContactWrapper ctWrapper:contactWrapperList){
                    contactEmailsArray.add(
                        new JSONObject.value(new JSONObject(new JSONObject.JSONTokener(
                                                        '{"email":"'+ctWrapper.contactObj.Email+'"}'))));//ctWrapper.contactObj.Email));
                }
            }
            BackendLayer.BackendParameter param = new BackendLayer.BackendParameter('emails',contactEmailsArray);
            getParameters().add(param);
            
        }
        
        public override virtual void handleResponse(String response, Integer statusCode){
            try{
                System.debug('The 302833 response : ' + response);
                PortalDataType.Users u = (PortalDataType.Users) System.JSON.deserialize(response,PortalDataType.Users.class);
                this.userLicenses = u.users;
                removeDuplicates(this.userLicenses);
            }catch(Exception e){
                EmailUtil.notifyError(e,null);
            }
        }
        
        private void correctLicenseContacts(){
        	for(PortalDataType.User_License userLic: this.userLicenses){
        		PortalDataType.License[] licenses = userLic.licenses;
        		for(PortalDataType.License lic: licenses){
        			if(lic.contacts == null || lic.contacts.size() == 0){
        				PortalDataType.PortalContact ct = new PortalDataType.PortalContact();
        				ct.email = userLic.email;
        				ct.user_type = 'primary';
        				ct.userId = userLic.user_id;
        				ct.subscribeSaasNotification = 'true';
    					ct.subscribeLicenseNotification = 'true';
    					lic.contacts = new list<PortalDataType.PortalContact>();
    					lic.contacts.add(ct); 
        			}
        		}
        	}
        }
    }
    
    private static void removeDuplicates(list<PortalDataType.User_License> userLicenses){
        for(PortalDataType.User_License userLic:userLicenses){
            PortalDataType.License[] licensesForEmail = userLic.licenses;
            map<String, PortalDataType.License> licMap = new map<String,PortalDataType.License>();
            for(PortalDataType.License lic:licensesForEmail){
                licMap.put(lic.Id, lic);
            }
            userLic.licenses = licMap.values();
        }
    }

    private static void storeLicenseContacts(PortalDataType.User_License[] licencesPulledFromPortal, 
                                                             Map<String, List<LicenseDetail__c>> sfLicences) {
        Set<String> emails = sfLicences.keySet();
        List<LicenseDetail__c> allSfLicences = new List<LicenseDetail__c>();
        for(String email : emails) {
            allSfLicences.addAll(sfLicences.get(email));
        }
        List<License_contacts__c> licCts = new List<License_contacts__c>();
        for(PortalDataType.User_License portalUserLic : licencesPulledFromPortal) {
            for(PortalDataType.License portalLic : portalUserLic.licenses) {
                LicenseDetail__c sfLic = getSfLicence(allSfLicences, portalLic.id);
                String acctName = getAccountName(getPrimaryUserForLicense(portalLic));
                licCts.addAll(createLicenseContacts(portalLic, sfLic, acctName));
            }
        }     
        
        //upsert licCts;
    }
    
    private static testMethod void teststoreLicenseContacts(){
    	String licJson = PortalLeadToLicenseManager.testGetLicenseJSONString();
    	PortalDataType.Users u = (PortalDataType.Users) System.JSON.deserialize(licJson,PortalDataType.Users.class);
        list<PortalDataType.User_License> licUsers = u.users;
        try{
        	storeLicenseContacts(licUsers,new map<String,List<LicenseDetail__c>>());
        }catch(Exception e){}
    }
    
    public static String getPrimaryUserForLicense(PortalDataType.License portalLic) {
    	for (PortalDataType.PortalContact contact : portalLic.contacts) {
            if(contact.user_type.equals('primary')) {
                return contact.email;
            }
        }
        
        return null;
    }
    
    private static testMethod void testGetPrimaryUserForLicense(){
    	String licJson = PortalLeadToLicenseManager.testGetLicenseJSONString();
    	PortalDataType.Users u = (PortalDataType.Users) System.JSON.deserialize(licJson,PortalDataType.Users.class);
        list<PortalDataType.User_License> licUsers = u.users;
        
    	getPrimaryUserForLicense(licUsers[0].licenses[0]);
    }
    
    private static String getAccountName(String primaryContact) {
        Contact con = [select accountid from contact where email = :primaryContact limit 1];
        String acctId = con.accountid;
        Account acct = [select name from account where id = :acctId];
        return acct.name;
    }
    
    private static testMethod void testGetAccountName(){
    	Account acc = new Account(name='testAcc');
    	insert acc;
    	Contact ct = new Contact(firstName='firstName',
				    	lastName='lastName', 
				    	email='email@test.com',
				    	AccountId=acc.Id);
		insert ct;
		getAccountName(ct.email);
    }
    
    private static LicenseDetail__c getSfLicence(List<LicenseDetail__c> sfLicences, String licenceBackendId) {
        for(LicenseDetail__c sfLic : sfLicences) {
            if(sfLic.License_BackendID__c.equals(licenceBackendId)) {
                return sfLic;
            }
        }
        return null;
    }
    
    private static testMethod void testGetSfLicense2(){
    	list<LicenseDetail__c> lics = new list<LicenseDetail__c>();
    	getSfLicence(lics,'');
    }
    
    private static List<License_contacts__c> createLicenseContacts(PortalDataType.License portalLic, LicenseDetail__c sfLic, String acctName) {
        List<String> portalEmails = new List<String>();
        String primaryCtEmail = '';
        for(PortalDataType.PortalContact contact : portalLic.contacts) {
            portalEmails.add(contact.email);
            if('primary'.equalsIgnoreCase(contact.user_type)){
            	primaryCtEmail = contact.email;
            }
            System.debug('portalEmails : ' + contact.email);
        }
        
        list<License_Contacts__c> licCtExisting = [Select Contact__c,Contact__r.email, Contact__r.AccountId, ID, License__c, Need_Operations_Email__c, Need_Service_Email__c, Contact_Type__c from License_Contacts__c where Contact__r.email in :portalEmails and license__r.id = :sfLic.id];
        map<String,License_Contacts__c> emailToLicCtMap = new map<String, License_Contacts__c>();
        for(License_Contacts__c licCt:licCtExisting){
            emailToLicCtMap.put(licCt.Contact__r.email,licCt);
            System.debug('emailToLicCtMap : ' + licCt.Contact__r.email);
        }
        
        list<Contact> contactsExisting = [Select id, email,AccountId from Contact where email in :portalEmails];
        map<String,Contact> emailToCtMap = new map<String, Contact>();
        for(Contact existingCt: contactsExisting){
            emailToCtMap.put(existingCt.email,existingCt);
            if(primaryCtEmail == null || primaryCtEmail.equals('')){
            	primaryCtEmail = existingCt.email;
            }
            if(globalAccountId == null && primaryCtEmail.equals(existingCt.email)){
                globalAccountId = existingCt.accountId;
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
        Map<String, EmailDS> emails = new Map<String, EmailDS>();
        EmailDS emailData = null;
        for(PortalDataType.PortalContact contact : portalLic.contacts) {
            if (emailToLicCtMap.get(contact.email) != null) {
                continue;
            }
            Contact sfLicenseCt = emailToCtMap.get(contact.email);
            
            if(sfLicenseCt != null  && (emailToLicCtMap.get(contact.email) == null)) {
                System.debug('Adding enterprise user : ' + sfLicenseCt.Id);
                License_Contacts__c newLicCt = new License_Contacts__c(Contact__c=sfLicenseCt.Id,License__c=sfLic.id,
                                        Need_Operations_Email__c=Boolean.valueOf(contact.subscribeLicenseNotification),
                                        Need_Service_Email__c=Boolean.valueOf(contact.subscribeSaasNotification),
                                        Contact_Type__c=contact.user_type);
                licCts.add(newLicCt);
            }
            Lead ld = emailToLeadMap.get(contact.email);
            emailData = new EmailDS();
            emailData.subscribeSaasNotification = Boolean.valueOf(contact.subscribeSaasNotification);
            emailData.subscribeLicenseNotification = Boolean.valueOf(contact.subscribeLicenseNotification);
            emails.put(contact.email, emailData);            
            if(ld != null) {
                PortalLeadToLicenseManagerInput input = new PortalLeadToLicenseManagerInput();
                input.email = ld.Email;
                input.status = ld.status;
                input.accountName = acctName;
                input.leadOwnerId = ld.ownerid;
                input.leadId = ld.id;
                input.convertedAccountId = globalAccountId;
                leads.add(input);
            }
        }
        
        convertLeadsToContacts(getLeadInputMap(leads));
        
        for(PortalLeadToLicenseManagerInput pli : leads) {
            EmailDS leadEmailData = emails.get(pli.email);
            if(pli.ConvertedContactId!=null){
            	License_Contacts__c newLicCt = new License_Contacts__c(Contact__c=pli.convertedContactId,License__c=sfLic.id,
                                    Need_Operations_Email__c=Boolean.valueOf(leadEmailData.subscribeLicenseNotification),
                                    Need_Service_Email__c=Boolean.valueOf(leadEmailData.subscribeSaasNotification),
                                    Contact_Type__c='ADDITIONAL');
            	licCts.add(newLicCt);
            }
        }

        list<String> convertedCtIds = new list<String>();
        String opportunityId = null;
        
        for(PortalLeadToLicenseManagerInput convertedLead : leads){
            convertedCtIds.add(convertedLead.convertedContactId);
            if(opportunityId == null){
                opportunityId = convertedLead.convertedOpportunityId;
            }
            if(globalAccountId == null){
                globalAccountId = convertedLead.convertedAccountId;
            }
        }

        //Opportunity ID will be defined during manual lead convertion for self-service trials
        System.debug('Before updating contacts ...' + opportunityId);
        System.debug('Before updating contacts ...' + globalAccountId);
        
        //if(opportunityId!=null && !opportunityId.trim().equals('')){
        //    System.debug('Updating contacts ...');
        //    updateUsersToPortal(convertedCtIds,accountId);
        //}
        allConvertedContactIds.addAll(convertedCtIds);
        for(License_Contacts__c licct:licCts){
        	System.debug('Debug of LicCt:'+licCt);
        }
        upsert licCts;
        return licCts;
    }
    
    public static Account getAccount(String companyId){
        Account acct = null;
    
        Account_Portal_Company__c accountPortalCompany = null;
        try{
            accountPortalCompany = (Account_Portal_Company__c)Database.query('Select Id, Account__c, Account__r.Name, Account__r.Owner.isActive, Account__r.OwnerId, Account__r.id, Company_Portal_Id__c from Account_Portal_Company__c where Company_Portal_Id__c = \''+companyId+'\' limit 1');
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Error in retrieving account by portal id:'+ companyId);
        }
         
        if(accountPortalCompany!=null){
            acct = (Account)accountPortalCompany.getSObject('Account__r');
        }

        return acct;
    }
    
    private static testMethod void testGetAccount(){
    	Account acc = new Account(name = 'test_123');
    	insert acc;
    	Account_Portal_Company__c accComp = new Account_Portal_Company__c(Account__c = acc.Id, Company_Portal_ID__c='123');
    	insert accComp;
    	Account acct = getAccount('123');
    	getAccount('123notexist');
    }
    
    
    public class EmailDS {
        public Boolean subscribeSaasNotification;
        public Boolean subscribeLicenseNotification;
    }   
    
    public static testMethod void testRemoveDuplicates(){
        String json = '{"users": [{"licenses": [{"MacAddress": "None","customerName": "azure-store-777228-1","saasPassword": "roqzujY2","license_contacts": [],"expiryDate": "2038-01-01 00:00:00","license_agents": [{"agent_count": "10","agent_type": ".Net"},{"agent_count": "0","agent_type": "PHP"},{"agent_count": "0","agent_type": "Java"},{"agent_count": "0","agent_type": "Machine"}],"customerSaasUrl": "azure-store-777228-1","saasAccount": "azure-store-777228-1","created_date": "2013-10-29 17:22:16","ProductType": "SAAS","saasUserName": "azure-store-777228-1","id": "138309253618AE1"},{"MacAddress": "None","customerName": "azure-store-777228-1","saasPassword": "roqzujY2","license_contacts": [],"expiryDate": "2038-01-01 00:00:00","license_agents": [{"agent_count": "10","agent_type": ".Net"},{"agent_count": "0","agent_type": "PHP"},{"agent_count": "0","agent_type": "Java"},{"agent_count": "0","agent_type": "Machine"}],"customerSaasUrl": "azure-store-777228-1","saasAccount": "azure-store-777228-1","created_date": "2013-10-29 17:22:16","ProductType": "SAAS","saasUserName": "azure-store-777228-1","id": "138309253618AE1"}],"email": "firstName_lastName_1@tarams.com"}]}';
        PortalDataType.Users u = (PortalDataType.Users) System.JSON.deserialize(json,PortalDataType.Users.class);
        removeDuplicates(u.users);
        
        
    }
    
    private static testMethod void testCreatePortalLicContacts(){
    	String licJson = PortalLeadToLicenseManager.testGetLicenseJSONString();
    	PortalDataType.Users u = (PortalDataType.Users) System.JSON.deserialize(licJson,PortalDataType.Users.class);
        list<PortalDataType.User_License> licUsers = u.users;
        Account acc = new Account(name='testPortalLicTarams');
        insert acc;
        
        Contact primaryCt = new Contact(firstName='test', lastName='user1', email='tuser1@test.com', AccountId=acc.Id);
        insert primaryCt;
        
        Contact ct1 = new Contact(firstName='testct', lastName='user2', email='tuser2ct@test.com', AccountId=acc.Id);
        insert ct1;
        
        Lead lead1 = new Lead(firstName='test', lastName='user3', email='tuser3ld@test.com', Company='testcompany');
        insert lead1;
        
        LicenseDetail__c lic1 = new LicenseDetail__c();
        lic1.Product_Type__c='Hosted (SaaS)';
        lic1.Stage__c = 'TRIAL';
        lic1.License_Expiry_Date__c = System.now().addDays(15).date();
        lic1.Custom_URL_Name__c = 'testSaasLic';
        insert lic1;
        License_Contacts__c licCt = new License_Contacts__c(License__c = lic1.id, contact__c=primaryCt.Id,contact_type__c='PRIMARY');
        insert licCt;
        
        createLicenseContacts(licUsers[0].licenses[0],lic1,acc.name);
    }
    
    /*
     * Test Methods
     */
    public static String testGetLicenseJSONString(){
        Integer numOfUsers=5;
        String returnVal='{"users": [';
        for(Integer i=0;i<numOfUsers;i++){
            returnVal+='{'+
            '"licenses": ['+
                '{'+
                    '"MacAddress": "None",'+
                    '"customerName": "azure-store-777228-'+i+'",'+
                    '"saasPassword": "roqzujY2",'+
                    '"expiryDate": "2038-01-01 00:00:00",'+
                    '"license_agents": ['+
                        '{'+
                            '"agent_count": "10",'+
                            '"agent_type": ".Net"'+
                        '},'+
                        '{'+
                            '"agent_count": "0",'+
                            '"agent_type": "PHP"'+
                        '},'+
                        '{'+
                            '"agent_count": "0",'+
                            '"agent_type": "Java"'+
                        '},'+
                        '{'+
                            '"agent_count": "0",'+
                            '"agent_type": "Machine"'+
                        '}'+
                    '],'+
                    '"customerSaasUrl": "azure-store-777228-'+i+'",'+
                    '"saasAccount": "azure-store-777228-'+i+'",'+
                    '"created_date": "2013-10-29 17:22:16",'+
                    '"ProductType": "SAAS",'+
                    '"saasUserName": "azure-store-777228-'+i+'",'+
                    '"id": "138309253618AE'+i+'",'+
                    '"contacts":['+
                    '{'+
                    '"firstName": "tuser1",'+
                    '"lastName": "tuser1",'+
                    '"subscribeSaasNotification": "True",'+
                    '"email": "tuser1@test.com",'+
                    '"user_type": "primary",'+
                    '"userID": "123",'+
                    '"subscribeLicenseNotification": "True"'+
                    '},'+
                    '{'+
                    '"firstName": "tuser2ct",'+
                    '"lastName": "tuser2",'+
                    '"subscribeSaasNotification": "True",'+
                    '"email": "tuser2ct@test.com",'+
                    '"user_type": "additional",'+
                    '"userID": "124",'+
                    '"subscribeLicenseNotification": "True"'+
                    '},'+
                    '{'+
                    '"firstName": "tuser3ld",'+
                    '"lastName": "tuser3ld",'+
                    '"subscribeSaasNotification": "True",'+
                    '"email": "tuser3ld@test.com",'+
                    '"user_type": "additional",'+
                    '"userID": "456",'+
                    '"subscribeLicenseNotification": "True"'+
                    '}'+
                    ']'+
                '}'+
            '],'+
            '"email": "firstName_lastName_'+i+'@tarams.com"'+
        '}';
            if(i<numOfUsers-1){
                returnVal+=','; 
            }
        }
         
        returnVal+=']}';
        return returnVal;
    }
    
    public static testMethod void testGetSfLicence(){
    	String licJson = PortalLeadToLicenseManager.testGetLicenseJSONString();
    	PortalDataType.Users u = (PortalDataType.Users) System.JSON.deserialize(licJson,PortalDataType.Users.class);
        list<PortalDataType.User_License> licUsers = u.users;
        LicenseDetail__c lic1 = new LicenseDetail__c();
        lic1.Product_Type__c='Hosted (SaaS)';
        lic1.Stage__c = 'TRIAL';
        lic1.License_Expiry_Date__c = System.now().addDays(15).date();
        lic1.Custom_URL_Name__c = 'testSaasLic';
        lic1.License_BackendID__c = licUsers[0].licenses[0].id;
        insert lic1;
        List<LicenseDetail__c> sfLicenses = new list<LicenseDetail__c>();
        sfLicenses.add(lic1);
        getSfLicence(sfLicenses,licUsers[0].licenses[0].id);
    }
    
    public static testMethod list<PortalDataType.User_License> testGetUserLicenses(){
        String json=testGetLicenseJSONString();
        PortalDataType.Users u = (PortalDataType.Users) System.JSON.deserialize(json,PortalDataType.Users.class);
        list<PortalDataType.User_License> licUsers = u.users;
        return licUsers;
    }

    public static testMethod void testParseSSGetLicenseJSON(){
        String json=testGetLicenseJSONString();
        Map<String,Contact> emailCtMap = new Map<String,Contact>();
        Contact ct = new Contact();
        ct.FirstName='fName';
        ct.LastName='lName';
        ct.Email='a.einstein@tarams.com';
        upsert ct;
        emailCtMap.put('a.einstein@tarams.com',ct);
        System.debug(json);
        PortalDataType.Users u = (PortalDataType.Users) System.JSON.deserialize(json,PortalDataType.Users.class);
        list<PortalDataType.User_License> licUsers = u.users;
        
        System.debug(licUsers.size());
        PortalDataType.License cjl = new PortalDataType.License();
        PortalDataType.LicenseAgent cla = new PortalDataType.LicenseAgent();
        PortalDataType.User_License cul = new PortalDataType.User_License();
        PortalDataType.Users cu = new PortalDataType.Users();
    }
    
    public static testMethod list<String> testGetConvertedContactIds(){
        EnvironmentSettings.testEnvironmentSettings();
        
        list<Lead> leads = insertNewLeads();
        list<String> leadIds = new list<String>();
        for(Lead leadObj:leads){
            leadIds.add(leadObj.Id);
        }
        return leadIds;
        //return null;
	    //return getConvertedContactIds(leadIds);
    }
    
    public static testMethod list<String> testFilterConvertedLeadIds(){
        EnvironmentSettings.testEnvironmentSettings();
        list<Lead> leads = insertNewLeads();
        list<String> leadIds = new list<String>();
        for(Lead leadObj:leads){
            leadIds.add(leadObj.Id);
        }
        return leadIds;//getConvertedContactIds(leadIds);
        //return null;
    }

    public static testMethod void testGetAccount_ValidName_WithOutAccountPresent(){
        try{
            Account acc = [Select ID,Name from Account where Name='Microsoft Windows Azure Store' limit 1];
            delete acc;
        }catch(Exception e){
        }
        getTargetAccount('Microsoft Windows Azure Store',null);
    }

    public static testMethod void testGetAccount_ValidName_WithAccountPresent(){
        try{
            Account acc = [Select ID,Name from Account where Name='Microsoft Windows Azure Store' limit 1];
        }catch(Exception e){
            Account acc = new Account(name='Microsoft Windows Azure Store');
            insert acc;
        }
        getTargetAccount('Microsoft Windows Azure Store',null);
    }

    public static testMethod void testGetAccount_WithInvalidName(){
        getTargetAccount('Microsoft Windows Azure StoreNotExisiting',Userinfo.getUserId());
    }
    
    public static list<Lead> insertNewLeads(){
        EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode=true;
        list<Lead> leadObjs = new list<Lead>();
        list<String> leadIds = new list<String>();
        for(integer i=0;i<5;i++){
            Lead leadObj = new Lead(FirstName='FirstName_'+i, LastName='LastName_'+i,
                                    Email='firstName_lastName_'+i+'@tarams.com', Company='Microsoft Windows Azure Store',
                                    LeadSource = 'MICROSOFT WINDOWS AZURE STORE');
            leadObjs.add(leadObj);
        }
        try{
            insert leadObjs;
        }catch(Exception e){
            System.debug(LoggingLevel.Info,e.getStackTraceString());
        }
        return leadObjs;
    }
    
    public static testMethod list<Lead> insertSelfServiceNewLeadsAndConvert(){
        EnvironmentSettings.testEnvironmentSettings();
        list<Lead> leadObjs = new list<Lead>();
        list<String> leadIds = new list<String>();
        Lead leadObj = new Lead(FirstName='FirstName_1', LastName='LastName_1',
                                    Email='firstName_lastName_1@tarams.com', Company='SelfSeviceCompany',
                                    LeadSource = 'Website');
        System.debug(LoggingLevel.Info,'#############SRINIDHI########1');
        RESTAPI.unitTestMode=true;  
        try{
            insert leadObj;
            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadObj.id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(false);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
            System.assert(true,lcr.isSuccess());
            
            List<PortalLeadToLicenseManagerInput> inputList = new List<PortalLeadToLicenseManagerInput>();
            String convertedCtID = lcr.getContactId();
            String convertedAccId = lcr.getAccountId();
            globalAccountId = convertedAccId;
            String convertedOppId = lcr.getOpportunityId();
            
            inputList.add(PortalLeadToLicenseManagerInput.newInstance(convertedCtId,convertedAccId,convertedOppId,'Website'));
            PortalLeadToLicenseManager.execute(inputList);
            list<string>convertedCtIds = new list<String>();
            convertedCtIds.add(convertedCtID);
            PortalLeadToLicenseManager.updateUsersToPortal(convertedCtIds, convertedAccId);
            
        }catch(Exception e){
            System.debug(LoggingLevel.Info,'#############SRINIDHI###2');
            System.debug(LoggingLevel.Info,e.getStackTraceString());
        }
        return leadObjs;
    }
    
    private static testMethod void testExecute(){
        EnvironmentSettings.testEnvironmentSettings();
        RESTAPI.unitTestMode=true;
        /*list<Lead> leadObjs = insertNewLeads();
        list<String> leadIds = new list<String>();
        for(Lead leadObj:leadObjs){
            leadIds.add(leadObj.Id);
        }*/
    }
}