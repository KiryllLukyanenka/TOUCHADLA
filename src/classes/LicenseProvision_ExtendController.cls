public with sharing class LicenseProvision_ExtendController  extends LicenseProvisionController{
	
	public LicenseProvision_ExtendController(ApexPages.StandardController stdCtrlr){
		super(stdCtrlr,BackendConstants.OPCODE_EXTEND_TRIAL);
	}
	
	public override virtual void init(){
		super.init();
		  
	}  
	
	public override virtual PageReference initAction(){
		licenseOpcode = BackendConstants.OPCODE_EXTEND_TRIAL;
		//showProductType = false;
		productTypeSelectOptions = CommonUtil.getProductTypeSelectOptions(licenseOpcode,stage);
		
		super.initAction();
		
        this.pageTitle = 'Update Trial License';
        if(licenseDetailObj!=null && licenseDetailObj.Stage__c!=null && licenseDetailObj.Stage__c.startsWith('PAID')){
            this.pageTitle = 'Update Paid License';
        }
        this.saveButtonTitle = 'Update';
        return null;
	}
}