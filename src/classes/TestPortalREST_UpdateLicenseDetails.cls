/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestPortalREST_UpdateLicenseDetails {
    
    public static testMethod void testUpdateLicensesSuccess() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://cs1.salesforce.com/services/apexrest/portal/update_license_details/*';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        LicenseDetail__c lic = new LicenseDetail__c();
        lic.Product_Type__c = 'On-Premise';
        lic.License_BackendID__c = '100';
        lic.Stage__c = 'TRIAL';
        lic.ProcessState__c = 'IN_PROGRESS';
        lic.License_Expiry_Date__c =  Date.newInstance(2014, 7, 7); 
        insert lic;
     
        License_EUM_Details__c eum =  new License_EUM_Details__c();
        eum.License__c = lic.id;
        eum.Access_Key__c = '4983338f-4dab-4343-895c-b67a59b31285';
        eum.State__c = 'In Progress';
        eum.AccountName__c = 'TestEUM';
        insert eum;
        
        License_History_Tracking__c lht = new License_History_Tracking__c();
        lht.License__c = lic.id;
        lht.License_Operation__c = 'TRIAL';
        lht.Status__c = 'IN_PROGRESS';
        lht.User__c = UserInfo.getUserId();
        insert lht;
        
        PortalDataType.LicenseEUMDetails licenseEum = new PortalDataType.LicenseEUMDetails();
        licenseEum.accessKey = '4983338f-4dab-4343-895c-b67a59b31285';
        licenseEum.salesforceEUMID = eum.Id;
        licenseEum.state = 'SUCCESS';
        
        
        List<PortalDataType.License> licenses = new List<PortalDataType.License>();
        PortalDataType.License license = new PortalDataType.License();
        PortalREST_UpdateLicenseDetails.updateLicenses(licenses);
        
        license.created_date = '7/7/2014';
        license.stage = 'TRIAL';
        license.expiryDate = '7/10/2014';
        
        license.salesforceLicenseID = lic.id;
        license.id = lic.License_BackendID__c;
        license.license_eum_details = licenseEum;
        license.ProductType = 'On-Premise';
        license.processState = 'SUCCESS';
        licenses.add(license);
        PortalREST_UpdateLicenseDetails.updateLicenses(licenses);
        
        license.created_date = '7/7/2014';
        license.stage = 'TRIAL';
        license.expiryDate = '7/10/2014';
        
        license.salesforceLicenseID = 'abcdef';
        license.id = lic.License_BackendID__c;
        license.license_eum_details = licenseEum;
        license.ProductType = 'On-Premise';
        license.processState = 'SUCCESS';
        licenses.add(license);
        PortalREST_UpdateLicenseDetails.updateLicenses(licenses);
   }
}