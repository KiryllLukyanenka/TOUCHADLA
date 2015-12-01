@RestResource(urlMapping='/portal/system_license_manager/*')
global class PortalREST_SystemLicenseManager{
    @HttpPost
    global static void addUserLicenses(List<PortalDataType.User_License> userLicenses,String systemName) {
        // Create response context and set the default values
        RestResponse response = RestContext.response;
        Account acc;
        String acctName;
        List<String> emails = new List<String>();
        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"status":"success"}');
        
        //check if userLicense is empty throw error
        if(userLicenses==null || userLicenses.size()==0){
            response.statusCode=400;
            response.responseBody = Blob.valueOf('{"status":"failure","reason":"UserLicenses json is empty"}');
            return;
        }

        //If SystemName is not Azure - throw unsupported
        /*if(!'MICROSOFT WINDOWS AZURE STORE'.equalsIgnoreCase(systemName)){
            response.statusCode=406;
            response.responseBody = Blob.valueOf('{"status":"failure","reason":"SystemName other than MICROSOFT WINDOWS AZURE STROE NOT ACCEPTABLE"}');
            return;
        }*/
        
        list<string> convertedCtIds = new list<String>();
        
        set<String> emailIds = new set<String>();
        for(PortalDataType.User_License userLic:userLicenses){
			String email =userLic.email;
			if(!emailIds.contains(email)){
				emailIds.add(email);
			}
		}
        
		if('MICROSOFT WINDOWS AZURE STORE'.equalsIgnoreCase(systemName)){
			System.debug('In MICROSOFT WINDOWS AZURE STORE logic');
	        //Check if there is a contact already in salesforce to do associate the license to
	        Account targetAccount = PortalLeadToLicenseManager.getTargetAccount(systemName,null);
	        list<Contact> ctForEmails = [Select ID,Email from Contact where AccountID =:targetAccount.Id and Email in: emailIds];
	        Integer foundCount=0;
	        for(String email:emailIds){
	            boolean found=false;
	            for(Contact ct:ctForEmails){
	                if(email.equals(ct.email)){
	                    convertedCtIds.add(ct.id+'');
	                    found=true;
	                    foundCount++;
	                    break;
	                }
	            }
	            if(!found){
	                response.statusCode=206;
	                response.responseBody = Blob.valueOf('{"status":"warning","reason":"no contact with email:'+email+' found in salesforce"}');
	                //return;
	            }
	        }
	        if(foundCount==0){
	            response.statusCode=404;
	            response.responseBody = Blob.valueOf('{"status":"failure","reason":"no contacts found in salesforce"}');
	            return;
	        }
		}else if('SS_Buy'.equalsIgnoreCase(systemName)){
			/*
			 * Self-Service Buy flow.
			 */
	        List<Lead> leadRecords = [select id, ConvertedContactId, ConvertedAccountId, ConvertedOpportunityId, isConverted,Email,leadSource,status from Lead  where  email in:emailIds];
	        List<PortalLeadToLicenseManagerInput> inputList = new List<PortalLeadToLicenseManagerInput>();
	        
	        for(Lead leadState: leadRecords){
	        	String convertedCtID = '';
				String convertedAccId = '';
			    String convertedOppId = '';
	        	if(leadState.isConverted){
	        		convertedCtID = leadState.ConvertedContactId;
					convertedAccId = leadState.ConvertedAccountId;
			    	convertedOppId = leadState.ConvertedOpportunityId;
			    	//accId = leadState.ConvertedAccountId;
	        	}
			        
				String leadId = leadState.id;
				String email = leadState.email;
					
				String leadSource = leadState.leadSource;
				
				PortalLeadToLicenseManagerInput input = PortalLeadToLicenseManagerInput.newInstance(leadId, email, leadSource, true,leadState.isConverted,convertedCtID,convertedAccId,convertedOppId);
				input.status = leadState.status; 
				inputList.add(input);
				//acc = new Account(name='SS_Buy_' + leadState.email);
				//upsert acc;
				acctName = 'SS_Buy_' + leadState.email;
				emails.add(leadState.email);
	        }
	        
	        for(PortalLeadToLicenseManagerInput pli: inputList){
            	if(pli.converted){
                	convertedCtIds.add(pli.convertedContactId);
            	}
        	}
		}else if('enterprise'.equalsIgnoreCase(systemName)){
			/*
			 * Enterprise License update flow.
			 */
			set<String> userIds = new set<String>();
			set<String> contactIds = new set<String>();
			
	        for(PortalDataType.User_License userLic:userLicenses){
	            String userId =userLic.email;
	            if(!userIds.contains(userId)){
	                userIds.add(userId);
	            }
	        }
	        
	        List<Contact_Portal_User__c> contactPortalUsers = [select id, Contact__c, User_Portal_Id__c from Contact_Portal_User__c where User_Portal_Id__c in:userIds];
	        for(Contact_Portal_User__c cpu: contactPortalUsers){
				if(cpu.Contact__c!=null){
	         		contactIds.add(cpu.Contact__c);
	         	}
	        }

	        convertedCtIds.addAll(contactIds); 
		}
		
		/*
		 * Storing the licenses for all Azure, SS_buy and enterprise flows. 
		 */
		try{
			//PortalLeadToLicenseManager.storeLicensesAndDependenciesToSF(userLicenses,systemName,convertedCtIds,null);
			if(acctName != null) {
				PortalLicenseSynch.processDataSync(userLicenses, acctName);
			}
	    }catch(Exception e){
			response.statusCode = 500;
	        response.responseBody = Blob.valueOf('{"status":"failure","reason":'+JSON.serialize(e.getMessage()+'\n'+e.getStackTraceString())+'}');
	    }
    }
    
    private static testMethod void testAddUserLicenses_1(){
        
        RestContext.request = (new RestRequest());       // pass the request and response objects to the method
        RestContext.response = (new RestResponse());
        addUserLicenses(null,'MICROSOFT WINDOWS AZURE STORE'); 
    }
    
    private static testMethod void testAddUserLicenses_2(){
        RestContext.response = new RestResponse();
        addUserLicenses(PortalLeadToLicenseManager.testGetUserLicenses(),'MICROSOFT WINDOWS AZURE STORE'); 
    }
    
    private static testMethod void testAddUserLicenses_3(){
        RestContext.response = new RestResponse();
        addUserLicenses(PortalLeadToLicenseManager.testGetUserLicenses(),'MICROSOFT WINDOWS AZURE STORE_WRONG'); 
    }  
    
    private static testMethod void testAddUserLicenses_4(){
        EnvironmentSettings.testEnvironmentSettings();
        //PortalLeadToLicenseManager.insertNewLeads();
        //RestContext.response = new RestResponse();
        //addUserLicenses(PortalLeadToLicenseManager.testGetUserLicenses(),'MICROSOFT WINDOWS AZURE STORE'); 
    } 
}