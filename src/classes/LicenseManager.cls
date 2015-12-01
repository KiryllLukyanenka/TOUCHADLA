@RestResource(urlMapping='/license_manager/*')
global class LicenseManager {
    /* SAMPLE JSON INPUT
    
        {
            "licenseDetail": {
                "attributes": {
                    "type": "LicenseDetail__c"
                },
                "License_BackendID__c": "a0QS0000001KRSYMA4",
                "Product_Type__c": "Hosted (SaaS)",
                "License_Expiry_Date__c": "2013-01-01",
                "Custom_URL_Name__c": "test",
                "SAAS_UserName__c": "test",
                "SAAS_Password__c": "test",
                "SAAS_Access_Key__c": "test",
                "SAAS_Account__c": "test",
                "MAC_Address__c": "test",
                "Stage__c": "test",
                "ProcessState__c": "SUCCESS" | "IN_PROGRES" | "FAILED"
            },
            "agentDetails": [
                {
                    "attributes": {
                        "type": "License_Agent__c"
                    },
                    "Agent_Type__c": "Java",
                    "Count__c": 10
                },
                {
                    "attributes": {
                        "type": "License_Agent__c"
                    },
                    "Agent_Type__c": ".NET",
                    "Count__c": 10
                }
            ],
            "eumDetails": {
                "attributes": {
                    "type": "License_EUM_Details__c"
                },
                "Access_Key__c": "test",
                "AccountName__c": "Test",
                "Agent_Units__c": 10,
                "Allow_Overages__c": true,
                "Type__c": "LITE"
            }
        }

    */
    @HttpPost
    global static void updateLicense(LicenseDetail__c licenseDetail, License_EUM_Details__c eumDetails, List <License_Agent__c> agentDetails) {
        // Create response context and set the default values
        RestResponse response = RestContext.response;
        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{"status":"success"}');
        
        try{
            // If license input is null, throw exception
            if (licenseDetail == null) {
                response.statusCode = 400;
                response.responseBody = Blob.valueOf('{"status":"failure","reason":"No license provided."}');
                
                return;
            }

            LicenseDetail__c licenseInSF = null;

            try {
                // Retrieve license with matching backend ID
                licenseInSF = [ select  Product_Type__c, License_Expiry_Date__c, Custom_URL_Name__c,
                                        SAAS_UserName__c, SAAS_Password__c, SAAS_Access_Key__c,
                                        SAAS_Account__c, MAC_Address__c, Stage__c
                                from    LicenseDetail__c
                                where   License_BackendID__c =: licenseDetail.License_BackendID__c ];
            } catch (Exception e) { /* Just catch and release. */ }   

            // If we can't find a license, return immediately
            if (licenseInSF == null) {
                response.statusCode = 404;
                response.responseBody = Blob.valueOf('{"status":"failure","reason":"No license found."}');
                
                return;
            }                              

            // Update license details with new input values as long as they are not null
            licenseInSF.Product_Type__c = licenseDetail.Product_Type__c!=null?licenseDetail.Product_Type__c:licenseInSF.Product_Type__c;
            if ('saas'.equalsIgnoreCase(licenseInSF.Product_type__c)) {
                licenseInSF.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
            }

            licenseInSF.License_Expiry_Date__c = licenseDetail.License_Expiry_Date__c!=null?licenseDetail.License_Expiry_Date__c:licenseInSF.License_Expiry_Date__c;
            licenseInSF.Custom_URL_Name__c = licenseDetail.Custom_URL_Name__c!=null?licenseDetail.Custom_URL_Name__c:licenseInSF.Custom_URL_Name__c;
            licenseInSF.SAAS_UserName__c = licenseDetail.SAAS_UserName__c!=null?licenseDetail.SAAS_UserName__c:licenseInSF.SAAS_UserName__c;
            licenseInSF.SAAS_Password__c = licenseDetail.SAAS_Password__c!=null?licenseDetail.SAAS_Password__c:licenseInSF.SAAS_Password__c;
            licenseInSF.SAAS_Access_Key__c = licenseDetail.SAAS_Access_Key__c!=null?licenseDetail.SAAS_Access_Key__c:licenseInSF.SAAS_Access_Key__c;
            licenseInSF.SAAS_Account__c = licenseDetail.SAAS_Account__c!=null?licenseDetail.SAAS_Account__c:licenseInSF.SAAS_Account__c;
            licenseInSF.MAC_Address__c = licenseDetail.MAC_Address__c!=null?licenseDetail.MAC_Address__c:licenseInSF.MAC_Address__c;
            licenseInSF.Stage__c = licenseDetail.Stage__c!=null?licenseDetail.Stage__c:licenseInSF.Stage__c;
            licenseInSF.ProcessState__c = licenseDetail.ProcessState__c!=null?licenseDetail.ProcessState__c:licenseInSF.ProcessState__c;

            List <License_Agent__C> agentsInSF = null;

            // If agentDetails is empty, perform noop, return error code at the end
            if (agentDetails == null || agentDetails.size()  == 0) {
                response.statusCode = 206;
                response.responseBody = Blob.valueOf('{"status":"failure","reason":"No agents provided."}');
            } else {
                
                // Retrieve agents for the provided license
                try {
                    agentsInSF = [  select  Agent_Type__c, Count__c, License__c 
                                    from    License_Agent__c
                                    where   License__c =: licenseInSF.ID ];
                } catch (Exception e) { /* Just catch and release. */ }

                if (agentDetails.size() > 0) {

                    for (License_Agent__c laInInput:agentDetails) {
                        boolean found = false;
                        
                        if (laInInput.Count__c < 0) {
                            laInInput.Count__c = 0;
                        }
						if(agentsInSF!=null && agentsInSF.size()>0){
	                        for (License_Agent__c laInSF:agentsinSF) {
	
	                            if (laInSF.Agent_Type__c.equalsIgnoreCase(laInInput.Agent_Type__c)) {
	                                found = true;
	                                laInSF.Count__c = laInInput.Count__c;
	                                break;
	                            }
	                        }
						}

                        // If we can't retrieve the appropriate agents, we shouldn't fail. We'll just insert them
                        // as new agent records. 

                        // When inserting new records, ensure that License__c is set to this license ID queried from database.
                        if (!found) {
                            License_Agent__c newSFAgent = new License_Agent__c(Agent_Type__c = laInInput.Agent_Type__c,
                                                                               Count__c = laInInput.Count__c,
                                                                               License__c = licenseInSF.id);
                            agentsinSF.add(newSFAgent);
                        }
                    }
                }
            }

            License_EUM_details__c eumInSF = null; 

            // If eumDetails are empty, perform noop, return error code at the end
            if (eumDetails == null) {
                response.statusCode = 206;
                response.responseBody = Blob.valueOf('{"status":"failure","reason":"No eum data provided."}');
            } else {

                // Retrieve EUM details and update with new input
                try {
                    eumInSF = [ select  Access_Key__c, AccountName__c, Agent_Units__c, 
                                        Allow_Overages__c, Type__c, License__c 
                                from    License_EUM_details__c 
                                where   License__c =: licenseInSF.ID ];
                } catch (Exception e) { /* Just catch and release. */ }   

                // If we can't retrieve the EUM details, then create them appropriately.
                if (eumInSF == null) {

                    // Make sure that the eumDetails object that was passed in is not empty.
                    if (eumDetails.Access_Key__c != null && eumDetails.AccountName__c != null &&
                        !eumDetails.Access_Key__c.trim().equals('') &&
                        !eumDetails.AccountName__c.trim().equals('')) {

                        eumInSF = new License_EUM_details__c(   Access_Key__c = eumDetails.Access_Key__c,
                                                                AccountName__c = eumDetails.AccountName__c,
                                                                Agent_Units__c = eumDetails.Agent_Units__c,
                                                                Allow_Overages__c = eumDetails.Allow_Overages__c,
                                                                Type__c = eumDetails.Type__c,
                                                                License__c = licenseInSF.id);
                    }
                } else {
                    eumInSF.Access_Key__c = eumDetails.Access_Key__c!=null?eumDetails.Access_Key__c:eumInSF.Access_Key__c;            
                    eumInSF.AccountName__c = eumDetails.AccountName__c!=null?eumDetails.AccountName__c:eumInSF.AccountName__c;            
                    eumInSF.Agent_Units__c = eumDetails.Agent_Units__c!=null?eumDetails.Agent_Units__c:eumInSF.Agent_Units__c;            
                    eumInSF.Allow_Overages__c = eumDetails.Allow_Overages__c!=null?eumDetails.Allow_Overages__c:eumInSF.Allow_Overages__c;            
                    eumInSF.Type__c = eumDetails.Type__c!=null?eumDetails.Type__c:eumInSF.Type__c;            
                }
            }        

            // Fire updates for licenseDetail, licenseAgent, and eumDetails
            update licenseInSF;

            if (agentsInSF != null) {
                upsert agentsInSF;
            }

            if (eumInSF != null) {
                upsert eumInSF;
            }

            response.responseBody = Blob.valueOf('{"status":"success","license":"'+licenseInSF.id+'"}');

        } catch(Exception e) {
            // If an Exception is thrown, throw server error with appropriate exception message.
            response.statusCode = 500;
            response.responseBody = Blob.valueOf('{"status":"failure","reason":'+JSON.serialize(e.getMessage()+'\n'+e.getStackTraceString())+'}');
        }
    }
    
    private static testMethod LicenseDetail__c getLicenseDetail(){
    	LicenseDetail__c licDetail = new LicenseDetail__c(Product_Type__c='Hosted (SaaS)', License_Expiry_Date__c=System.now().date(),
    														Stage__c='PAID_PERMANENT',Custom_URL_Name__c='testSaaS13', ProcessState__c='SUCCESS',
    														License_BackendID__c='123');
    	insert licDetail;
    	return licDetail;
    }
    
    private static list<License_Agent__c> getLicAgents(LicenseDetail__c lic){
    	list<License_Agent__c> licAgents = new list<License_Agent__c>();
    	licAgents.add(new License_Agent__c(Agent_Type__c='Java',Count__c=10,License__c=lic.Id));
    	licAgents.add(new License_Agent__c(Agent_Type__c='.NET',Count__c=10,License__c=lic.Id));
    	licAgents.add(new License_Agent__c(Agent_Type__c='PHP',Count__c=10,License__c=lic.Id));
    	licAgents.add(new License_Agent__c(Agent_Type__c='Machine',Count__c=10,License__c=lic.Id));
    	return licAgents;
    }
    
    private static License_EUM_Details__c getLicEUMDetails(LicenseDetail__c lic){
    	License_EUM_Details__c eumDetails = new License_EUM_Details__c(AccountName__c='testEUM',Agent_Units__c=10,Allow_Overages__c=true,
    																	Access_Key__c='asfasf',License__c=lic.Id); 
    	return eumDetails;
    }
    
    private static testMethod void testupdateLicense_1(){
    	LicenseDetail__c lic1 = getLicenseDetail();
    	RestContext.request = (new RestRequest());       // pass the request and response objects to the method
	    RestContext.response = (new RestResponse());
	    updateLicense(null,null, null);
    }
    
    private static testMethod void testupdateLicense_2(){
    	LicenseDetail__c lic1 = getLicenseDetail();
    	RestContext.request = (new RestRequest());       // pass the request and response objects to the method
	    RestContext.response = (new RestResponse());
	    updateLicense(lic1,null, null);
    }
    
     private static testMethod void testupdateLicense_3(){
    	LicenseDetail__c lic1 = new LicenseDetail__c();
    	RestContext.request = (new RestRequest());       // pass the request and response objects to the method
	    RestContext.response = (new RestResponse());
	    updateLicense(lic1,null, null);
    }
    
    private static testMethod void testupdateLicense_4(){
    	LicenseDetail__c lic1 = getLicenseDetail();
    	RestContext.request = (new RestRequest());       // pass the request and response objects to the method
	    RestContext.response = (new RestResponse());
	    updateLicense(lic1,null, getLicAgents(lic1));
    }
    
    private static testMethod void testupdateLicense_5(){
    	LicenseDetail__c lic1 = getLicenseDetail();
    	RestContext.request = (new RestRequest());       // pass the request and response objects to the method
	    RestContext.response = (new RestResponse());
	    updateLicense(lic1,getLicEUMDetails(lic1), getLicAgents(lic1));
    }
}