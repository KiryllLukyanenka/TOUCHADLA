public with sharing class PortalControllerLicense extends AbstractAPPDController{
	private map<string, string> operationToEditionMap = new map<String, String>{
		'provisiontrial' => 'pro-trial',
		'provisionpaid' => 'pro',
		'upgrade' => 'pro'
	};
	public Opportunity oppObj{get;set;}
	public Account accObj {get;set;}
	
	public PortalControllerLicense(ApexPages.StandardController stdController){
		super(stdController);
		try{
			Opportunity opp = (Opportunity) stdController.getRecord();
			if(opp!=null){
				this.oppObj = (Opportunity)DataLayerConstants.fetchSingle('Opportunity', opp.Id);
				this.accObj = (Account) DataLayerConstants.fetchSingle('Account', this.oppObj.AccountId);
			}
		}catch(Exception e){
		}
		
		/*editionSelectOptions = new list<SelectOption>();
		editionSelectOptions.add(new SelectOption('pro-trial','pro-trial'));
		editionSelectOptions.add(new SelectOption('pro','pro'));*/
		
		productTypeSelectOptions = new list<SelectOption>();
		productTypeSelectOptions.add(new SelectOption('onprem','onprem'));
		productTypeSelectOptions.add(new SelectOption('saas','saas'));
	}
	
	public PortalModelLicense.LicenseMetadata discoveryResult {get;set;}
	
	public PortalModelLicense.License licenseObj {get;set;}
	
	public list<SelectOption> productTypeSelectOptions{get;set;}
	
	public list<SelectOption> editionSelectOptions{get;set;}
	
	public LicenseDetail__c sfLicenseObj{get;set;}
	
	public map<String, PortalModelLicense.Property> metadataPropertyMap{get;set;}
	
	public list<String> productCategories {get;set;}
	
	public map<String, list<PortalModelLicense.Product>> categoryBasedProducts {get;set;}
	
	public list<PortalModelLicense.LicenseUser> licenseUsers {get;set;}
	
	public PortalLicenseHelper licenseHelper {get;set;}
		
	public void initAction(){
		String licenseId = null;
		String action = 'provisiontrial';
		try{
			licenseId = ApexPages.currentPage().getParameters().get('licenseId');
			if(licenseId!=null && !licenseId.trim().equals('')){
				this.sfLicenseObj = (LicenseDetail__c) DataLayerConstants.fetchSingle('LicenseDetail__c', licenseId);
				this.oppObj = CommonUtil.getOpportunitiesForLicense(this.sfLicenseObj).get(0);
				this.oppObj = (Opportunity)DataLayerConstants.fetchSingle('Opportunity', oppObj.Id);
				this.accObj = (Account) DataLayerConstants.fetchSingle('Account', this.oppObj.AccountId);	
			}
			action = ApexPages.currentPage().getParameters().get('operation');
		}catch(Exception e){
			EmailUtil.notifyError(e, null);
		}
		if(action==null){
			action = 'provisiontrial';
		}
		
		String edition = operationToEditionMap.get(action);
		
		if(this.sfLicenseObj!=null){
			if(this.sfLicenseObj.License_BackendID__c!=null){
				PortalBackendLicense.GetLicense getLicenseBkend = new PortalBackendLicense.GetLicense(this.sfLicenseObj.License_BackendID__c);
				getLicenseBkend.invokeBackend();
				this.licenseObj = getLicenseBkend.licenseObj;
			}
		}
		
		getMetadata(edition, 'onprem');
		
		if(operationToEditionMap.get(action)!=null){
			this.licenseObj.edition = operationToEditionMap.get(action);
		}
		if(action == 'upgrade' || action == 'provisionpaid'){
			this.licenseObj.edition = 'pro';
		}else{
			this.licenseObj.edition = 'pro-trial';
		}
		
		for(PortalModelLicense.Product prod:this.licenseObj.products){
			if(action == 'update'){
				if(this.licenseObj.edition=='pro-trial' || 
					(this.licenseObj.edition == 'pro' && prod.edition == 'pro')){
					prod.edition = this.licenseObj.edition;
				}
			}else{
				prod.edition = this.licenseObj.edition;
			}
			if(prod.edition == 'pro-trial'){
				prod.model = 'fixed';
			}
			
			if(prod.model == 'fixed' || prod.max_units <= prod.units){
				prod.max_units = prod.units;
			}
		}
	}
	
	public PageReference deploymentChanged(){
		System.debug(LoggingLevel.Info, 'Deployment Changed:'+this.licenseObj.edition+':'+this.licenseObj.deployment.type);
		getMetadata(this.licenseObj.edition, this.licenseObj.deployment.type);
		return null;
	}
	
	private void getMetadata(String edition, String deployment){
		PortalBackendLicense.GetMetadata metadataBackend = new PortalBackendLicense.GetMetadata('pro-trial','onprem');
		metadataBackend.invokeBackend();
		this.discoveryResult = metadataBackend.metadataResponse;
		if(this.licenseObj == null){
			this.licenseObj = this.discoveryResult.default_request;
		}
		PortalLicenseHelper.DAO licDao = new PortalLicenseHelper.DAO();
		licDao.backendLicense = this.licenseObj;
		
		this.sfLicenseObj = licDao.fromBackend();
		
		metadataPropertyMap = new map<String, PortalModelLicense.Property>();
		for(PortalModelLicense.Property prop:this.discoveryResult.metadata){
			metadataPropertyMap.put(prop.name, prop);
		}
		
		this.licenseHelper = new PortalLicenseHelper(this.licenseObj, this.discoveryResult.metadata, 
			this.accObj, this.oppObj, this.sfLicenseObj);
		this.productCategories = this.licenseHelper.categories;
		this.categoryBasedProducts = this.licenseHelper.categoryBasedProducts;
		System.debug(LoggingLevel.Info, 'License Categories:'+this.productCategories);
		
		this.licenseUsers = this.licenseHelper.getLicenseUsersForOpportunity();
	}
	
	public override virtual void setupBackend(){
		this.licenseObj.end_date = this.licenseObj.expiration_date;
		this.licenseObj.contacts = this.licenseUsers;
		PortalModelLicense.Product[] products = this.licenseObj.products;
		for(PortalModelLicense.Product prod:products){
			prod.model = prod.model.toLowerCase();
		}
		if(this.licenseObj.deployment.attributes.mac_address==null){
			this.licenseObj.deployment.attributes.mac_address = '';
		}
		if(this.licenseObj.deployment.attributes.hostname == null){
			this.licenseObj.deployment.attributes.hostname = '';
		}
		if(this.licenseObj.deployment.attributes.account_name == null){
			this.licenseObj.deployment.attributes.account_name = '';
		}
		if(this.licenseObj.deployment.attributes.user_name == null){
			this.licenseObj.deployment.attributes.user_name = '';
		}
		if(this.licenseObj.deployment.attributes.password == null){
			this.licenseObj.deployment.attributes.password = '';
		}
		if(this.licenseObj.deployment.attributes.access_key == null){
			this.licenseObj.deployment.attributes.access_key = '';
		}
		PortalModelLicense.LicenseSource src = new PortalModelLicense.LicenseSource();
		src.type = 'salesforce';
		list<PortalModelLicense.LicenseSourceProperty> props = new list<PortalModelLicense.LicenseSourceProperty>();
		src.properties = props;
		this.licenseObj.source = src;
		
		PortalModelLicense.LicenseCompany comp = new PortalModelLicense.LicenseCompany();
		comp.name = 'test';
		comp.type = 'enterprise';
		
		this.licenseObj.company = comp;
		String operationId = '';
		
		if(this.licenseObj.id==null){
			PortalBackendLicense.ProvisionLicense provisionBackend = new PortalBackendLicense.ProvisionLicense(this.licenseObj);
			provisionBackend.invokeBackend();
			operationId = provisionBackend.operationId;
		}else{
			PortalBackendLicense.ModifyLicense provisionBackend = new PortalBackendLicense.ModifyLicense(this.licenseObj);
			provisionBackend.invokeBackend();
			operationId = provisionBackend.operationId;
			
		}
		
		this.sfLicenseObj.Transaction_ID__c = operationId;
	}
	
	public override virtual Boolean doPreSave(){
		//Store the license operation id in transaction id of the license
		upsert sfLicenseObj;
		License_Opportunity__c lic_op = null;
		try{
			 lic_op = [Select Id, License__c, Opportunity__c from License_Opportunity__c where License__c =: sfLicenseObj.Id and Opportunity__c=:oppObj.Id limit 1];
		}catch(Exception e){
			System.debug('No Lic Opp exists, creating new one');
		}
		if(lic_op == null){
			lic_op = new License_Opportunity__c(Opportunity__c = oppObj.Id, License__c = sfLicenseObj.Id);
			upsert lic_op;
		}
		
		PortalLicenseHelper.DAO licDao = new PortalLicenseHelper.DAO();
		this.licenseObj.contacts = this.licenseUsers;
		licDao.backendLicense = this.licenseObj;
		licDao.sfLicense = this.sfLicenseObj;
		licDao.updateLicenseContacts();
		licDao.updateLicenseProducts();
		return true;
	}
	public override void doSave(){
		
	}
	public override virtual PageReference doPostSave(){
		PageReference ref = new PageReference('/apex/PortalLicenseView?id='+this.sfLicenseObj.id);
		return ref;
	}
	
	public void onSave(){
		//Backend call to create/update the license POST/PUT
		//Response is shown with an automated/button-initiated poll 
	}
}