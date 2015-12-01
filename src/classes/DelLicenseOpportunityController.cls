public with sharing class DelLicenseOpportunityController {
	private ApexPages.StandardController stdController;
	public License_Opportunity__c licOpp{get;set;}
	public DelLicenseOpportunityController(ApexPages.StandardController stdController){
		this.stdController = stdController;
		licOpp = (License_Opportunity__c)stdController.getRecord();
		licOpp = (License_Opportunity__c)DataLayerConstants.fetchSingle('License_Opportunity__c', licOpp.Id);
	}
	public PageReference deleteAction(){
		if(licOpp!=null){
			List<License_Opportunity__c> licenseOpps = DataLayerConstants.fetchMultiple('License_Opportunity__c', 'License__c',licOpp.License__c);
			if(licenseOpps!=null){
				if(licenseOpps.size()>1){
					delete licOpp;
					PageReference ref = new PageReference('/'+licOpp.License__c);
					ref.setRedirect(false);
					return ref;
				}else{
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Cannot Remove Opportunity License Association as the license doesnot have any other Opportunity association');
	            	ApexPages.addMessage(myMsg);
	            	ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.INFO,'Please associate another opportunity for the license and then try deleting the association');
	            	ApexPages.addMessage(myMsg2);
	            	return null;
				}
			}
		}
		return stdController.cancel();
	}
	
	public static testMethod void deleteInit(){
		LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
		lic.License_Expiry_Date__c = System.now().date().addDays(5);
		lic.Server_Agents__c = 2;
		upsert lic;
		
		List<Opportunity> opps = DataLayerConstants.fetchMultiple('Opportunity', ' LIMIT 2');
		Opportunity opp1 = opps.get(0);
		Opportunity opp2 = opps.get(1);
		License_Opportunity__c licOpp = new License_Opportunity__c();
		licOpp.License__c = lic.Id;
		licOpp.Opportunity__c = opp1.Id;
		upsert licOpp;
		
		DelLicenseOpportunityController ctrlr = new DelLicenseOpportunityController(new ApexPages.StandardController(licOpp));
		ctrlr.deleteAction();
		
		License_Opportunity__c licOpp1 = new License_Opportunity__c();
		licOpp1.License__c = lic.Id;
		licOpp1.Opportunity__c = opp2.Id;
		upsert licOpp1;
		
		ctrlr.deleteAction();
	}
}