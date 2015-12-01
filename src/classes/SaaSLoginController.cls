public with sharing class SaaSLoginController {

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

	public PageReference saasLogin(){
		Id id = System.currentPageReference().getParameters().get('license_id');
		LicenseDetail__c license = (LicenseDetail__c)[Select SAAS_UserName__c ,SaaS_Password__c from LicenseDetail__c where Id = :id][0];
		String username = license.SAAS_UserName__c;
		String password = license.SaaS_Password__c;
		PageReference pageRef = new PageReference('http://www.google.com?id='+username+'&password='+password);
		return pageRef;
	} 
	
	
	public static testMethod void testSaasLogin(){
		createLicense();
		String licenseId='';
		LicenseDetail__c lic = [Select ID from LicenseDetail__c limit 1];
		licenseId = lic.Id;
		SaaSLoginController controller = new SaaSLoginController();
		ApexPages.currentPage().getParameters().put('license_id',licenseId);
		PageReference ref = controller.saasLogin();
		System.assertNotEquals(ref, null);	
	}
}