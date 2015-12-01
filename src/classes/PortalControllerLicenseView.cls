public with sharing class PortalControllerLicenseView extends AbstractAppDController{
	
	public PortalModelLicense.License licenseObj{get;set;}
	
	public list<PortalModelLicense.LicenseUser> licenseUsers {get;set;}
	
	public list<String> productCategories {get;set;}
	
	public map<String, list<PortalModelLicense.Product>> categoryBasedProducts {get; set;}
	
	public LicenseDetail__c sfLicenseObj {get;set;}
	
	public PortalModelLicense.LicenseOperation operationStatus {get;set;}
	
	public PortalLicenseHelper licenseHelper{get;set;}
	
	public String licenseId {get;set;}
	public String operationId {get;set;}
	
	public PortalControllerLicenseView(ApexPages.StandardController stdController){
		super(stdController);
		this.sfLicenseObj = (LicenseDetail__c) stdController.getRecord();
		this.sfLicenseObj = (LicenseDetail__c) DataLayerConstants.fetchSingle('LicenseDetail__c', this.sfLicenseObj.Id);
	}
	
	public PageReference initAction(){
		//String sfLicId = ApexPages.currentPage().getParameters().get('id')
		this.operationId = this.sfLicenseObj.Transaction_Id__c;
		this.licenseObj = new PortalModelLicense.License();
		//this.licenseObj.setSfLicense(this.sfLicenseObj);
		checkLicenseOperationStatus();
		update this.sfLicenseObj;
		return null;
	}
	
	
	public PageReference checkLicenseState(){
		checkLicenseOperationStatus();
		return null;
	}
	
	private void checkLicenseOperationStatus(){
		PortalBackendLicense.CheckOperationStatus bkend = new PortalBackendLicense.CheckOperationStatus(this.operationId);
		bkend.invokeBackend();
		this.operationStatus = bkend.operationStatusData;
		if(this.operationStatus.success){
			this.licenseId = bkend.licenseId;
			PortalBackendLicense.GetLicense getLicenseBkend = new PortalBackendLicense.GetLicense(this.licenseId);
			getLicenseBkend.invokeBackend();
			this.licenseObj = getLicenseBkend.licenseObj;
			setupLicenseAndAssociations();
			this.sfLicenseObj.License_BackendID__c = this.licenseObj.Id;
			this.sfLicenseObj.ProcessState__c = 'SUCCESS';
			system.debug(LoggingLevel.Info, 'EDITION FROM BACKEND GET:' + this.licenseObj.edition);
		}
	}
	
	private void setupLicenseAndAssociations(){
		this.licenseHelper = new PortalLicenseHelper(this.licenseObj, null, 
			null, null, this.sfLicenseObj);
		this.productCategories = this.licenseHelper.categories;
		this.categoryBasedProducts = this.licenseHelper.categoryBasedProducts;
		System.debug(LoggingLevel.Info, 'License Categories:'+this.productCategories);
		
		this.licenseUsers = this.licenseObj.contacts;//this.licenseHelper.getLicenseUsersForOpportunity();
		update this.sfLicenseObj;
	}
	
	public PageReference updateLicense(){
		PageReference ref = new PageReference('/apex/PortalLicensePage?licenseId='+this.sfLicenseObj.Id+'&operation=update');
		return ref;
	}
	
	public PageReference upgradeLicense(){
		PageReference ref = new PageReference('/apex/PortalLicensePage?licenseId='+this.sfLicenseObj.Id+'&operation=upgrade');
		return ref;
	}
}