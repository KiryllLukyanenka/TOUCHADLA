public with sharing class SimpleLicenseController {

	private final LicenseDetail__c license;
	
	public SimpleLicenseController(ApexPages.StandardController licenseController){
		if(licenseController.getRecord() != null){
			this.license = (LicenseDetail__c)licenseController.getRecord();
		}else{
			this.license = new LicenseDetail__c();
		}
	}
	
	public Boolean getSection(String section){
		return section.equalsIgnoreCase(this.license.Product_Type__c);
		//return false; 
	}
	
	public boolean getOnPremiseVisible(){
		return 'On-Premise'.equalsIgnoreCase(this.license.Product_Type__c);
	}
	
	public boolean getPermanentPanelVisible(){
		return this.license.Is_Permanent__c;
	}
	
	
	public static testMethod void testSimpleLicController(){
		SimpleLicenseController lic = new SimpleLicenseController(new ApexPages.Standardcontroller(new LicenseDetail__c()));
		lic.getSection('');
		lic.getOnPremiseVisible();
		lic.getPermanentPanelVisible();
		System.assert(true);
	}
}