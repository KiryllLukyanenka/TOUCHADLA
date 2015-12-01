/**
 * CommonUtil.cls
 *
 * Encapsulates common Utility methods required by many controllers through out the application.
 * All the methods are static as they do not need to maintain state between method calls.
 *  
 */  
public with sharing class CommonUtil {
	
	private static Map<String,Boolean> triggerProgressTrackerMap = new map<String,Boolean>();
	
	public static Boolean isInProgress(String key){
		System.debug('In isInProgress');
		String runningKey = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.SYNC_KEY);
		System.debug('After fetching runningKey');
		/*if(runningKey != null && key != null && !key.equals(runningKey)) {
			System.debug('if runningKey');
			
			return false;
		}*/
		
		System.debug('After if runningKey' + runningKey);
		
		if(runningKey != null && runningKey != ''){
			System.debug('In second if : ' + triggerProgressTrackerMap);
			/*if(triggerProgressTrackerMap.get(runningKey) == null) {
				return false;
			}*/
			//return triggerProgressTrackerMap.get(runningKey);
			return true;
		}
		
		return false;
	}

    public static String activeInProgressKey(){
        try{
            return EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.SYNC_KEY);
        }catch(Exception e){
        }
        return null;
    }
	
	public static void setInProgress(String key, Boolean inProgress){
		triggerProgressTrackerMap.put(key,inProgress); 
		if(inProgress == false) {
			key = '';
		}
 		EnvironmentSettings.instance.setPropertyValue('SYNC_KEY', key);
	}
    private static List<Zone__c> allZoneList=null;
    
    public static Boolean inProgressContext=false;

    public static Boolean isPartnerUserLoggedIn(){
        String loggedInUserType = Userinfo.getUserType();
        if(loggedInUserType!=null && loggedInUserType.toLowerCase().contains('partner')){
            return true;
        }
        return false;
    }
    
    public static List<Opportunity> getOpportunitiesForLicense(LicenseDetail__c lic){
        if(lic!=null && lic.Id!=null){
            try{
                List<Opportunity> opportunities = Database.query('select ID, Owner.Id, Owner.Name, Owner.Email, Name,Account.Id,Account.Name,Account.PortalID__c,Account.OwnerID,Account.RecordTypeId,Account.CreatedById  from Opportunity where ID in (select Opportunity__c from License_Opportunity__c where License__c=\''+lic.Id+'\')');/*Partner_Technical_Owner__c,Technical_Owner__c,*/
                return opportunities;
            }catch(Exception qe){
            }
        }
        return null;
    }
        
    public static void updateLicenseResponse(String jsonResponse, LicenseDetail__c lic,License_EUM_Details__c eumDetails){
        System.debug('################Response:'+jsonResponse);
        try{
        	jsonResponse = jsonResponse.replaceAll('\\\\"','"');
        }catch(Exception e){
        	
        }
        if(jsonResponse!=null && !jsonResponse.trim().equals('') && lic!=null){
            JSONObject jsonObj = null;
            try{
                jsonObj = new JSONObject(new JSONObject.JSONTokener(jsonResponse));
            }catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Error Processing License Response:'+jsonResponse+'. Please contact portal-support for more assistance.');
                ApexPages.addMessage(myMsg);
        		EmailUtil.notifyError(e, null);
				lic.BackendStatus__c = 'JSON deserialization failed. Please contact portal-support for more assistance';
				lic.ProcessState__c = 'FAILED';
            }
            if(jsonObj!=null){
                String transactionStatusJSON = jsonObj.getString('status');
                if(transactionStatusJSON!=null && !transactionStatusJSON.equals('')){
                    JSONObject.value[] statusVals = JSONObject.JSONArray(new JSONObject.JSONTokener(transactionStatusJSON));
                    System.debug(LoggingLevel.Info,'Status:'+transactionStatusJSON);
                    if(statusVals!=null){
                        for(JSonObject.value statusVal:statusVals){
                            if('license'.equals(statusVal.obj.getString('name'))){
                                String transactionStatus = statusVal.obj.getString('status');
                                lic.ProcessState__c = transactionStatus;
                            }else if('RUM'.equals(statusVal.obj.getString('name'))){
                                String rumStatus= statusVal.obj.getString('status');
                                String oldState = lic.RUM_State__c;
                                String reason = statusVal.obj.getString('reason');
                                if(eumDetails!=null){
                                	if(rumStatus!=null && rumStatus.equals('SUCCESS')){
	                                    String rumAccessKey = statusVal.obj.getString('rum-access-key');
	                                    eumDetails.Access_Key__c = rumAccessKey;
                                    	String state = statusVal.obj.getString('state');
                                    	eumDetails.State__c = state;
                                	} else {
                                		eumDetails.Reason__c = rumStatus + ' - ' +reason;
                                	}
                                    
                                    upsert eumDetails;
                                }
                            }
                        }
                    }
                }else{
                    lic.ProcessState__c='IN_PROGRESS';
                }

                if(jsonObj.has('transactionId')){
                    String transactionId = jsonObj.getString('transactionId');
                    System.debug(LoggingLevel.Info,'trans:'+transactionId);
                    lic.Transaction_ID__c = transactionId;
                }
                
                // Vidyanand : Srinidhi - Why were you checking this for backend being null  ?
                // In the case of changing from on premise to saas or vice versa we will need to change
                // backendId to the new license that was created.
                
                if(jsonObj.has('licenseId') != null && jsonObj.getString('licenseId') != null 
                    && !jsonObj.getString('licenseId') .equals('') && lic != null ){
                    lic.License_BackendID__c = jsonObj.getString('licenseId');
                }           
                
                if(jsonObj.has('licenseStage')){
                    String stage = jsonObj.getString('licenseStage');
                    if(stage!=null && !stage.equals('')){
                        lic.Stage__c = stage;
                    }
                }
                lic.BackendStatus__c = jsonResponse+'::';
                if(AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE.equals(lic.Product_Type__c)){
                    String stage = lic.Stage__c;
                    if(stage!=null){
                        if(stage.contains('PAID')){
                            lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Utility method to retrieve all the Contacts belonging to an account of the given opportunity.
     *
     * Usage:
     * Apex Controller - Opportunity_LicenseController.cls
     * VisualForce Page - License_ProvisionFreePage.page
     */
    public static List<Contact> getAccountContactsToAddToBackend(Opportunity oppObj){
        ID accountId = oppObj.AccountId;
        if(accountId != null){
            List<Contact> contacts = [select Id,Name,LastName,Needs_Email__c,FirstName,Email,Enable_Access__c,Download__c,ZenDesk__c,LMS__C, Accessible_Systems__c,PortalID__c,AccountId,Docs__c from Contact where AccountId=:accountId and No_longer_at_Company__c=:false];//Id IN(Select ContactId from OpportunityContactRole where opportunityId=:oppObj.Id) and AccountId<>''];
            return contacts;
        }else{
            return null;
            //throw new Exception ('Opportunity '+oppObj.Name+' is not associated with any Account');           
        }
    }
    
    public static String getPrimaryContactID(Opportunity oppObj){
        List<OpportunityContactRole> roles = [select Id,OpportunityId,IsPrimary,ContactId from OpportunityContactRole where OpportunityId =: oppObj.Id and IsPrimary=: true]; //oppObj.OpportunityContactRoles;
        if(roles!=null && roles.size()>0){
            OpportunityContactRole role = roles.get(0);
            if(role!=null){
                return role.ContactId;
            } 
        }
        return null;
    }
    
    public static Boolean isPrimaryContactRolePresent(Opportunity oppObj){
        List<OpportunityContactRole> roles = [select Id,OpportunityId,IsPrimary,ContactId from OpportunityContactRole where OpportunityId =: oppObj.Id and IsPrimary=: true]; //oppObj.OpportunityContactRoles;
        return (roles!=null && roles.size()>0);
    }
    
    /**
     * Utility method to make backend call to AppDynamics to retrieve Controller Version informations
     * to be used for Provisioning SaaS Hosted Licenses.
     *
     * The response from AppDynamics will contain the following values:
     * 1) Controller Version String
     * 2) Corresponding ID which is used in AppDynamcis backend.
     *
     * Sample format of the Server response is:
     * {"AD Pro EUM Edition (3.45.5)": 45 , "AD Pro (2.17)": 23 }
     * Which is a JSON Object with keys as Controller Names with Version and value as backend ID.
     */
    public static List<SelectOption> getControllerVersionsFromBackend(){
        List<SelectOption> returnVal = new List<SelectOption>();
        
        BackendLayer backend= new BackendLayer();
        Backend backendObj = new Backend();
        backendObj.opCode = BackendConstants.OPCODE_GET_CONTROLLERS;
        backend.addBackend(backendObj);
        if(backend.invokeBackend()){
            String response = backend.getResponse(BackendConstants.OPCODE_GET_CONTROLLERS);
            if(response!=null && !response.trim().equals('')){
                JSONObject jsonObj = JSONObject.instance(response);
                Set<String> keys = jsonObj.keys();
                if(keys!=null){
                    SelectOption option = new SelectOption('','--None--');
                        returnVal.add(option);
                    for(String key:keys){
                        String controllerName = key;
                        JSONObject.value controllerIDVal = jsonObj.getValue(key);
                        String controllerId = controllerIDVal.num+'';
                        option = new SelectOption(controllerId,controllerName);
                        returnVal.add(option);
                    }
                }
            }
        }
        return returnVal;
    }
    
    public static List<JSONObject.value> jsonArrayOfContactRoles(LicenseDetail__c licenseObject,List<ContactWrapper> licenseContacts,List<OpportunityTeamMember> teamMembers){
        List<JSONObject.value> returnVal = new List<JSONObject.value>();
        String jsonArrayString = '';
        if(licenseContacts!=null){
            for(ContactWrapper ctWrapper:licenseContacts){
                Contact ct=ctWrapper.contactObj;
                if(ctWrapper.licContact.Need_Operations_Email__c || ctWrapper.licContact.Need_Service_Email__c){
                    JSONObject ctJSON = getContactJSON(ct.FirstName,ct.LastName,ct.Email, ctWrapper.getIsPrimary(),ctWrapper.licContact.Need_Operations_Email__c, ctWrapper.licContact.Need_Service_Email__c);
                    returnVal.add(new JSONObject.value(ctJSON));
                }
            }
        }
        String adHocEmailIds=licenseObject.Ad_hoc_Email_Ids__c;
        if(adHocEmailIds!=null && !adHocEmailIds.trim().equals('')){
            String[] adHocEmails = adHocEmailIds.split(',');
            for(String adHocEmail:adHocEmails){
                JSONObject adHocJson = getContactJSON('','',adHocEmail, false,true,false);
                returnVal.add(new JSONObject.value(adHocJson));
                //jsonArrayString += individualJSon.valueToString()+',';
            }
        }
        if(teamMembers!=null){
            for(OpportunityTeamMember teamMember:teamMembers){
                if(teamMember.User.Email!=null){
                    JSONObject individualJSon = getContactJSON(teamMember.User.FirstName,teamMember.User.LastName,teamMember.User.Email, false,true,false);
                    returnVal.add(new JSONObject.value(individualJSon));
                }
            }
        }
        return returnVal;
    }
        
    private static JSONObject getContactJSON(String firstName, String lastName, String email, Boolean isPrimary, Boolean needLicenseEmail, Boolean needServiceEmail){
        JSONObject individualJSon = new JSONObject();
        if(firstName != null) {
        	firstName = firstName.replace('\\','');
        }
        individualJSon.putOpt('firstName', new JSONObject.value(firstName));
        if(lastName != null) {
        	lastName = lastName.replace('\\','');
        }
        individualJSon.putOpt('lastName', new JSONObject.value(lastName));
        individualJSon.putOpt('email', new JSONObject.value(email));
        individualJSon.putOpt('primaryContact', new JSONObject.value(isPrimary));
        individualJSon.putOpt('contactType', (isPrimary!=null&&isPrimary)?new JSONObject.value('primary'):new JSONObject.value('additional'));
        individualJSon.putOpt('subscribeNotification', (needServiceEmail!=null && needServiceEmail)?new JSONObject.value(true):new JSONObject.value(false));
        individualJSon.putOpt('licenseNotification', (needLicenseEmail!=null && needLicenseEmail)?new JSONObject.value(true):new JSONObject.value(false));
        return individualJSon;
    }
    
    /**
     * Copy opportunities from Source License to target license. This internally queries all opportunity
     * ids for source license from License_Opportunity table and inserts those values for new license in
     * the same table. 
     * This feature is used to Copy Opportunities while splitting license and creating HA license.  
     */
    public static void copyOpportunities(LicenseDetail__c lic1,LicenseDetail__c lic2){
        try{
            List<Opportunity> oppList = [select ID,Name from Opportunity where Id IN (Select Opportunity__c from License_Opportunity__c where License__c =: lic1.Id)];
            if(oppList!=null){
                for(Opportunity opp:oppList){
                    License_Opportunity__c licOpp = new License_Opportunity__c();
                    licOpp.Opportunity__c = opp.Id;
                    licOpp.License__c = lic2.Id;
                    upsert licOpp;
                }
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }   
    }
    
    public static List<SelectOption> getProductTypeSelectOptions(Integer opCode, String stage){
        List<SelectOption> values = new List<SelectOption>();
        values.add(new SelectOption('On-Premise','On-Premise'));
        values.add(new SelectOption('Hosted (SaaS)','Hosted (SaaS)'));
        return values;
    }
    
    public static String getTechincalOwnerEmail(Opportunity oppObj){
        /*if(oppObj!=null)
        {
            String technicalOwner = oppObj.Technical_Owner__c;
            if(technicalOwner==null){
                technicalOwner = oppObj.Partner_Technical_Owner__c;
            }
            if(technicalOwner!=null)
            {
                Integer startIndex=technicalOwner.indexOf('(');
                Integer endIndex=technicalOwner.lastIndexOf(')');
                if(startIndex<endIndex && startIndex!=-1 && endIndex!=-1)
                {
                    return technicalOwner.substring(startIndex+1,endIndex);
                }
            }
        }*/
        return '';
    }
    
    public static void addZones(){
    	List<Zone__c> zonePaths = new List<Zone__c>(); 
    	for(String zonePath: BackendConstants.DOWNLOAD_ZONES_MAP.keySet()){
    		Zone__c zone = new Zone__c();
    		zone.Zone_Path__c = zonePath;
    		zone.Enabled__c = BackendConstants.IS_DOWNLOAD_ZONE_ENABLED.get(zonePath);
    		zone.Enabled_for_Partner__c = BackendConstants.IS_DOWNLOAD_ZONE_ENABLED_FOR_PARTNER.get(zonePath);
        	zone.Name = BackendConstants.DOWNLOAD_ZONES_MAP.get(zonePath);
        	zonePaths.add(zone);
    	}
    	insert zonePaths;
    }
    
    public static List<Zone__c> getAllZoneList(){
        if(allZoneList==null){
            allZoneList = new List<Zone__c>();
            allZoneList = [SELECT ID,Name,Zone_Path__c,Enabled__c,Enabled_for_Partner__c from Zone__c];
        }
        return allZoneList;
    }
        
    public static String generatePassword() {
        DateTime now = System.now();        
        String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+ now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';        
        Blob bsig = Crypto.generateDigest('MD5', Blob.valueOf(formattednow));        
        //String token =  EncodingUtil.base64Encode(bsig);   
        String token =  EncodingUtil.convertToHex(bsig);//base64Encode(bsig);
        if(token.length()<=12){
            return token;
        }
        return token.substring(0, 12);            
    }
    
    public static String generateAccountName(String accountName,String licenseId) {
        String normalisedString = '';
        normalisedString = accountName.replaceAll('[^A-Za-z0-9]','');
        
        if(normalisedString.trim().equals('')){
            normalisedString = 'EUMAccount';
        }
         
        return normalisedString+'-'+licenseId;
    }
    
	public static string getPageName(){
		String pageName = ApexPages.CurrentPage().getUrl();     
		pageName = pageName.replaceFirst('/apex/','');          
		pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');   
		string[] pageNameExtra = pageName.split('%3F',0);      
		pageName = pageNameExtra[0];                            
		return pageName;                                        
	}
	
	public static testMethod void getOpportunitiesForLicenseTest() {
        //LicenseDetail__c lic = CommonUtil.createOnlyLicense();
        License_Opportunity__c licOpp = [Select Opportunity__c,License__c from License_Opportunity__c where Opportunity__c!='' limit 1];
        String licID = licOpp.License__c;
        LicenseDetail__c lic = [Select Id from LicenseDetail__c where ID=:licID];
        CommonUtil.getOpportunitiesForLicense(lic);
        LicenseDetail__c lic2 = new LicenseDetail__c();
        CommonUtil.getOpportunitiesForLicense(lic2);
    }
	
	public static testMethod void testGetAccountContactsToAddToBackend(){
        Opportunity opp = [Select Id,AccountId from Opportunity where AccountId!='' LIMIT 1];
        CommonUtil.getAccountContactsToAddToBackend(opp);
    }
    
	public static testMethod void testGetPrimaryContactID(){
        Opportunity opp = [Select Id,AccountId from Opportunity where AccountId!='' LIMIT 1];
        CommonUtil.getPrimaryContactID(opp);
    }
    
    public static testMethod void testIsPrimaryContactRolePresent(){
        Opportunity opp = [Select Id,AccountId from Opportunity where AccountId!='' LIMIT 1];
        CommonUtil.isPrimaryContactRolePresent(opp);
    }
    
    public static testMethod void getControllerVersionsFromBackendTest() {
        // This is a useless test really
        CommonUtil.getControllerVersionsFromBackend();
    }
    
	public static testMethod void testGetProductTypeSelectOptions(){
        CommonUtil.getProductTypeSelectOptions(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,'TRIAL');
    }
    
    public static testMethod void testGetTechnicalOwnerEmail(){
       /* Opportunity opp = new Opportunity();//[Select Id,Name,Technical_Owner__c from Opportunity where Technical_Owner__c!='' limit 1];
        opp.Technical_Owner__c='Srinidhi (srinidhi.acharya@tarams.com)';
        getTechincalOwnerEmail(opp);*/
        getTechincalOwnerEmail(null);
    }
    
    public static testMethod void testGetTechnicalOwnerEmail12(){
        /*Opportunity opp = new Opportunity();//[Select Id,Name,Technical_Owner__c from Opportunity where Technical_Owner__c!='' limit 1];
        opp.Partner_Technical_Owner__c='Srinidhi (srinidhi.acharya@tarams.com)';
        getTechincalOwnerEmail(opp);*/
        getTechincalOwnerEmail(null);
    }
    
    public static testMethod void testAddZones(){
        CommonUtil.addZones();
    }
    
    public static testMethod void testGeneratePassword(){
        CommonUtil.generatePassword();
    }
    
    public static testMethod void testUpdateLicenseResponse1(){
    	CommonUtil.updateLicenseResponse('acd',new LicenseDetail__c(),new License_EUM_Details__c());
	}

	public static testMethod void testUpdateLicenseResponse2(){
    	CommonUtil.updateLicenseResponse('abc""fsafsdef"',new LicenseDetail__c(),new License_EUM_Details__c());
	}

	public static testMethod void testUpdateLicenseResponse3(){
	    LicenseDetail__c lic = new LicenseDetail__c();
    	lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
	    CommonUtil.updateLicenseResponse('{"transactionId":"123","licenseId":"123","licenseStage":"PAID_PERMANENT","status":[{"status": "SUCCESS", "name": "license"}, {"status": "SUCCESS", "name": "RUM", "rum-access-key": "dd87dd06-1cbc-4fc6-be96-2252efa7b794", "state": "enabled", "rum-account-name": "TestTaramsRUMAcc10May2", "reason": "Successfully created RUM Account"}]}',lic,new License_EUM_Details__c());
	}

	public static testMethod void testGetAccountContactsToAddToBackend1(){
	    Opportunity opp = new Opportunity();
	    CommonUtil.getAccountContactsToAddToBackend(opp);
	}
}