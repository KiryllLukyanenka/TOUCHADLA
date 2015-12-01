@RestResource(urlMapping='/portal/update_license_details/*')
global class PortalREST_UpdateLicenseDetails {
    /*
     * UpdateLicenses method is exposed through update_license_details rest api.
     * In this method we update IN_PROGRESS licenses 
     */
    @HttpPost
    global static void updateLicenses(List<PortalDataType.License> licenses) { 
        RestResponse response = RestContext.response;
        try{
            if(licenses!=null && licenses.size()>0){
                
                List<String> licenseIds = new List<String>();
                Map<String,PortalDataType.License> licnesesMAP = new Map<String,PortalDataType.License>();
                
                for(PortalDataType.License license: licenses){
                    licnesesMAP.put(license.salesforceLicenseID, license);
                }
                
                List<LicenseDetail__c> licenseDetails = [select Id, ProcessState__c, Stage__c, (select id, Access_Key__c, AccountName__c, State__c from License_EUM_Details__r), (select id, License__c, License_Operation__c, User__c, Status__c from License_History_Tracking__r where Status__c='IN_PROGRESS' ORDER BY CreatedDate DESC limit 1) from LicenseDetail__c where id IN: licnesesMAP.keySet()];
                List<License_EUM_Details__c> licenseEumDetails = new List<License_EUM_Details__c>();
                List<License_History_Tracking__c> licenseHistoryTracking = new List<License_History_Tracking__c>();
                
                /*
                 * Here, we are looping through license records and updating the details.
                 */ 
                for(LicenseDetail__c licenseDetail: licenseDetails){
                    PortalDataType.License license = licnesesMAP.get(licenseDetail.id);
                    licenseDetail.ProcessState__c = license.processState;
                    licenseDetail.Stage__c = license.stage;
                    licenseDetail.License_BackendID__c = license.id;        
                    
                    /*
                     * Updating License EUM details.
                     */
                    if(licenseDetail.License_EUM_Details__r!=null && licenseDetail.License_EUM_Details__r.size()>0 && license.license_eum_details!=null){
                        License_EUM_Details__c led = licenseDetail.License_EUM_Details__r.get(0);
                        led.Access_Key__c = license.license_eum_details.accessKey;
                        led.State__c = license.license_eum_details.state;
                        licenseEumDetails.add(led);  
                    }
                    
                    /*
                     * Updating License History tracking status.
                     */
                    if(licenseDetail.License_History_Tracking__r!=null && licenseDetail.License_History_Tracking__r.size()>0){
                        License_History_Tracking__c lht = licenseDetail.License_History_Tracking__r.get(0);
                        lht.Status__c = license.processState;
                        licenseHistoryTracking.add(lht);
                    }
                    
                }
                
                update licenseDetails;
                
                if(licenseEumDetails.size()>0){
                    update licenseEumDetails;
                }
                if(licenseHistoryTracking.size()>0){
                    update licenseHistoryTracking;
                }
                
                response.statusCode = 200;
                response.responseBody = Blob.valueOf('{"status":"SUCCESS"}');
                 
            }
        }catch(Exception e){
            response.statusCode = 500;
            response.responseBody = Blob.valueOf('{"status":"failure","reason":"'+e.getMessage()+'"}'); 
        }
    }
    
}