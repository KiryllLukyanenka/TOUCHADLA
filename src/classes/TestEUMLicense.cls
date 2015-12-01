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
private class TestEUMLicense {

    static testMethod void testEUM_1() {
        LicenseEUMInput eumInput = new LicenseEUMInput(null,null,null);
        LicenseUtil.getEUMLicenseInput(null);
        LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c = 'On-Premise';
        lic.License_BackendID__c = '100';
        lic.License_Expiry_Date__c = System.now().date().addDays(15);
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        lic.Server_Agents__c  = 10;
        lic.Net_Agents__c  = 10;
        lic.Stage__c = 'TRIAL';
        insert lic;
        
        License_EUM_Details__c eumLicense =  new License_EUM_Details__c();
        eumLicense.License__c = lic.id;
        eumLicense.AccountName__c = 'TestEUM';
        insert eumLicense;
        
        LicenseUtil.getEUMLicenseInput(eumLicense);
    }
    
    static testMethod void testEUM_2() {
    	LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c = 'On-Premise';
        lic.License_BackendID__c = '100';
        lic.License_Expiry_Date__c = System.now().date().addDays(15);
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        lic.Server_Agents__c  = 10;
        lic.Net_Agents__c  = 10;
        lic.Stage__c = 'TRIAL';
        insert lic;
        
    	License_EUM_Details__c eum =  new License_EUM_Details__c();
        eum.License__c = lic.id;
        eum.AccountName__c = 'TestEUM';
        insert eum;
        
        EUM_Mobile__c eumMobile = new EUM_Mobile__c();
        eumMobile.Allow_overages__c = false;
        eumMobile.License_EUM_Detail__c = eum.id;
        eumMobile.Type__c = 'LITE';
        eumMobile.Units__c = 1;
        insert eumMobile;
        
        EUM_Web__c eumWeb = new EUM_Web__c();
        eumWeb.Allow_overages__c = false;
        eumWeb.License_EUM_Detail__c = eum.id;
        eumWeb.Type__c = 'LITE';
        eumWeb.Units__c = 1;
        insert eumWeb;
        
        eum = (License_EUM_Details__c)DataLayerConstants.fetchSingle('License_EUM_Details__c', eum.id);
        LicenseUtil.getEUMLicenseInput(eum);
    }
}