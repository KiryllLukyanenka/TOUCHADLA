public with sharing class LicenseProvision_PaidController extends LicenseProvisionController{
	
	public LicenseProvision_PaidController(ApexPages.StandardController stdCtrlr){
		super(stdCtrlr,BackendConstants.OPCODE_ADD_LICENSE);
	}
	
	public override virtual PageReference initAction(){
		loggerHandle.setClassName(LicenseProvision_PaidController.class.getName());
		licenseDetailObj.Stage__c = 'PAID_PERMANENT';
		licenseOpcode = BackendConstants.OPCODE_ADD_LICENSE;  
	    showPermanentLicense = true;
	    showMacAddress=true;  
	    licenseDetailObj = new LicenseDetail__c();
	    pageContextObj = licenseDetailObj;
	    Date todaysDate = System.now().date();
	    Date provisionDefaultDate = todaysDate.addDays(AppDConstants.getProvisionDefaultDate());
	    licenseDetailObj.License_Expiry_Date__c =  provisionDefaultDate;
	    productTypeSelectOptions = CommonUtil.getProductTypeSelectOptions(licenseOpcode,stage);
	    deltaValues = false;
	    
	    super.initAction();
	    
	 	pageTitle = 'Provision Paid License for Opportunity:'+myOpportunity.Name;
	 	this.saveButtonTitle = 'Provision';
	 	isPermanent = true;
	 	licenseDetailObj.Stage__c = 'PAID_PERMANENT';
	 	if(licAgentInfoList!=null){
			for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgentInfoList){
				License_Agent__c licAgent = licAgentInfo.licAgent;
				licAgent.Count__c=0;
				if(licAgent.Licensing_Model__c==null){
					licAgent.Licensing_Model__c = 'FIXED';
				}
				licAgent.Max_Agents__c=licAgent.Count__c;
				licAgent.Edition__c = PortalDataType.EDITION_PRO;
				licAgentinfo.selectedProductEdition = PortalDataType.EDITION_PRO;
				if(licAgent.Agent_Type__c == 'Synthetic'){
					licAgent.Edition__c = PortalDataType.EDITION_NONE;
				}
			}
		}
		return null;
	}
	
	public static testMethod void testCase(){
		RESTAPI.unitTestMode=true;
		Opportunity opp = (Opportunity)DataLayerConstants.fetch('Opportunity').get(0);
		ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
		
		LicenseDetail__c lic= new LicenseDetail__c();
    	lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
    	//licenseObj.Custom_URL_Name__c='SRINIDHI_TEST_2513';
    	lic.License_Expiry_Date__c=System.now().date().addDays(10);
    	lic.Stage__c='PAID_TEMP';
    	upsert lic;
    	License_Opportunity__c licOpp = new License_Opportunity__c();
    	licOpp.License__c=lic.ID;
    	licOpp.Opportunity__c=opp.Id;
    	upsert licOpp;
    	List<License_Agent__c> licAgents = LicenseUtil.getLicenseAgents(lic,LicenseUtil.getSupportedProductsMetadata(),false, 1);
    	for(License_Agent__c licAgent:licAgents){
    		licAgent.Count__c=10;
    		licAgent.License__c=lic.Id;
    	}
    	upsert licAgents;
		LicenseProvision_PaidController ctrlr = new LicenseProvision_PaidController(new ApexPages.StandardController(lic));
		ctrlr.initAction();
		try{
		ctrlr.setupBackend();
		ctrlr.doPreSave();
		ctrlr.doPostSave();
		ctrlr.doPreSave();
		ctrlr.doCancel();
		}catch(Exception e){}
		
	} 
}