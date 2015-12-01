public with sharing class LicenseProvision_UpgradeController extends LicenseProvisionController{
	
	public LicenseProvision_UpgradeController(ApexPages.StandardController stdCtrlr){
		super(stdCtrlr,BackendConstants.OPCODE_TRANSITION_TO_PERMANENT);
	}
	
	public virtual override Pagereference initAction(){
		loggerHandle.setClassName(LicenseProvision_UpgradeController.class.getName());
		licenseOpcode = BackendConstants.OPCODE_TRANSITION_TO_PERMANENT;
		productTypeSelectOptions = CommonUtil.getProductTypeSelectOptions(licenseOpcode,stage);
		
		super.initAction();
		
		String operation = ApexPages.currentPage().getParameters().get('operation');
        this.pageTitle = 'Transition to Paid Permanent License';
        this.saveButtonTitle = 'Upgrade to Paid Permanent';
        if(licenseDetailObj!=null && licenseDetailObj.Product_Type__c.equals(AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE)){
        	if('paid_temp'.equals(operation)){
	        	fldsRender.permLicense = false;
	        	fldsRender.macAddress=false;
	        	fldsRender.perpLicense=false;
	        	this.pageTitle = 'Transition to Paid Temp License';
	        	this.saveButtonTitle = 'Upgrade To Paid Temp';
	        	this.licenseDetailObj.Is_Permanent__c = false;
	        }else{
	        	this.licenseDetailObj.Is_Permanent__c = true;
	        	fldsRender.permLicense = true;
	        	fldsRender.macAddress=true;
	        	fldsRender.perpLicense=true;
	        }
        }
        return null;
	}
}