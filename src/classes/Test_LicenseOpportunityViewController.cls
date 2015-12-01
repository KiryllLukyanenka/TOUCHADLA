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
private class Test_LicenseOpportunityViewController {
	
	static void createLicense() {
		Opportunity opp = [Select Id from Opportunity LIMIT 1];
        List<LicenseDetail__c>  licenses = new  List<LicenseDetail__c>();
        for( integer i =0; i<1; i++) {
        	LicenseDetail__c lic = new LicenseDetail__c();
        	lic.Product_Type__c = 'On-Premise';
        	lic.License_BackendID__c = '100';
        	lic.License_Expiry_Date__c = System.now().date().addDays(15);
        	lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        	lic.Server_Agents__c  = 10;
        	lic.Net_Agents__c  = 10;
        	lic.Stage__c = 'TRIAL';
        	licenses.add(lic);
        		
        }
        
        insert licenses;
        List<License_Opportunity__c> licOpps = new List<License_Opportunity__c>();
        for (integer i =0; i<licenses.size(); i++ ) {
        	LicenseDetail__c lic = licenses.get(i);
        	License_Opportunity__c licOpp = new License_Opportunity__c();
        	licOpp.Opportunity__c = opp.id;
        	licOpp.license__c = lic.id;
        	licOpps.add(licOpp);
        }
       	insert licOpps;
		
	}

    public static testmethod void licenseViewControllerSuccess()
    {
    	createLicense();
        //string licenseId = 'a01U0000000LtsIIAS';
        License_Opportunity__c licenseOpportunityObject =[select License__c, Opportunity__c,Name,ID from License_Opportunity__c limit 1];//where License__c=:licenseId limit 1];//new License_Opportunity__c();
        
        //licenseOpportunityObject.Id = 'a0890000005dMIfAAM';
        ApexPages.StandardController stdController = new ApexPages.StandardController(licenseOpportunityObject);
        LicenseOpportunityViewController controller = new LicenseOpportunityViewController(stdController);
        
        PageReference pageRef = new PageReference('/Apex/LicenseOpportunityDetail');
        Test.setCurrentPage(pageRef);
        
        PageReference nextPage = controller.redirectToLicense();
        
        Boolean startsWithLicenseId = nextPage.getUrl().startsWith('/'+licenseOpportunityObject.License__c);
        
        System.assertEquals(startsWithLicenseId, true);
    }
    
    
    public static testmethod void licenseViewControllerFailure()
    {
    	createLicense();
        License_Opportunity__c licenseOpportunityObject =new License_Opportunity__c();//[select ID from License_Opportunity__c where Id=:'a0890000005dMIfAAM'];//new License_Opportunity__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(licenseOpportunityObject);
        LicenseOpportunityViewController controller = new LicenseOpportunityViewController(stdController);
        
        PageReference pageRef = new PageReference('/Apex/LicenseOpportunityDetail');
        Test.setCurrentPage(pageRef);
        
        PageReference nextPage = controller.redirectToLicense();
        
        System.assertEquals(nextPage, null);
    }
}