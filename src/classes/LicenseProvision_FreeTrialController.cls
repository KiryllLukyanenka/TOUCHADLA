public with sharing class LicenseProvision_FreeTrialController extends LicenseProvisionController{
	public LicenseProvision_FreeTrialController(ApexPages.StandardController stdCtrlr){
		super(stdCtrlr,BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
	}
	
	public override virtual PageReference initAction(){
		try{
			loggerHandle.setClassName(LicenseProvision_FreeTrialController.class.getName());
			licenseOpcode = BackendConstants.OPCODE_PROVISION_FREE_TRIAL;  
			
			showMacAddress=false;
	        licenseDetailObj = new LicenseDetail__c();
	        pageContextObj = licenseDetailObj;
	        Date todaysDate = System.now().date();
	        Date provisionDefaultDate = todaysDate.addDays(AppDConstants.getProvisionDefaultDate());
	        licenseDetailObj.License_Expiry_Date__c =  provisionDefaultDate;
	        
	        productTypeSelectOptions = CommonUtil.getProductTypeSelectOptions(licenseOpcode,stage);
	        deltaValues = false;
	        
	        super.initAction();
	        
	        if(myOpportunity!=null){
	        	pageTitle = 'Provision Free Trial License for Opportunity:'+myOpportunity.Name;
	        }
	        this.saveButtonTitle = 'Provision';
	        isPermanent = false;
	        
			if(licAgentInfoList!=null){
				for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgentInfoList){
					License_Agent__c licAgent = licAgentInfo.licAgent;
					if('Java'.equals(licAgent.Agent_Type__c)){
						licAgent.Count__c=10;
					}else{
						licAgent.Count__c=0;
					}
					licAgent.Max_Agents__c = licAgent.Count__c;
					if(licAgent.Licensing_Model__c==null){
						licAgent.Licensing_Model__c = 'FIXED';
					}
					if('Synthetic'.equals(licAgent.Agent_Type__c)){
						licAgent.Edition__c = PortalDataType.EDITION_NONE;
					}					
				}
			}
		}catch(Exception e){
			EmailUtil.notifyError(e, licenseDetailObj);
			loggerHandle.error(e.getMessage(),e);
			super.cancelOperation(e.getMessage(),e);
			//throw 
		}
		return null;
	}
}