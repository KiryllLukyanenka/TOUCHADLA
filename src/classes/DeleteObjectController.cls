public with sharing class DeleteObjectController {
	public string salesforceObjType{get;set;}
	private ApexPages.StandardController stdCtrlr;
	
	public DeleteObjectController(ApexPages.StandardController stdCtrller){
		this.stdCtrlr = stdCtrller;
		init();
	}
	
	private SObject salesforceObj;
	private void init(){
		salesforceObj=stdCtrlr.getSubject();
		if(salesforceObj!=null){
			String objName = salesforceObj.getSObjectType().getDescribe().getName();
			salesforceObjType = objName;
		}
	}
	
	public PageReference doDelete(){
		Integer opCode= -1;
		List<BackendLayer.BackendParameter> params = new List<BackendLayer.BackendParameter>();
		if('User'.equals(salesforceObjType)){
			salesforceObj=DataLayerConstants.fetchSingle('User',salesforceObj.Id);
			opCode = BackendConstants.OPCODE_DELETE_USER;
			BackendLayer.BackendParameter param = new BackendLayer.BackendParameter();
			param.backendParameterType = BackendConstants.BACKEND_PARAM_TYPE_URL_APPEND;
			param.value = ((User)salesforceObj).Email;
			params.add(param);
		}else if('Contact'.equals(salesforceObjType)){
			salesforceObj=DataLayerConstants.fetchSingle('Contact',salesforceObj.Id);
			opCode = BackendConstants.OPCODE_DELETE_USER;
			BackendLayer.BackendParameter param = new BackendLayer.BackendParameter();
			param.backendParameterType = BackendConstants.BACKEND_PARAM_TYPE_URL_APPEND;
			param.value = ((Contact)salesforceObj).Email;
			params.add(param);
		}
		
		if(opCode!=-1){
			Backend backendObj = new Backend();
			backendObj.opCode = opcode;
			backendObj.getParameters().addAll(params);
			backendObj.setupInputParameters();
			BackendLayer backend = new BackendLayer();
			backend.addBackend(backendObj);
			backend.invokeBackend();
		}
		
		if('User'.equals(salesforceObjType)){
			String usrId = salesforceObj.Id;
			if(!usrId.equals(UserInfo.getUserId())){
				User usrObj = (User) salesforceObj;
				usrObj.IsActive=false;
				update usrObj;
			}
		}else{
			delete salesforceObj;
		}
		return stdCtrlr.cancel();
	}
	
	public static testMethod void testInit(){
		Contact contactObj = [Select Id from Contact limit 1];
		String contactId = contactObj.Id;
		contactObj = (Contact)DataLayerConstants.fetchSingle('Contact',contactId);
		DeleteObjectController controller = new DeleteObjectController(new ApexPages.Standardcontroller(contactObj));
		System.assertNotEquals(controller.salesforceObj,null);
	}
	
	public static testMethod void testDelete(){
		RESTAPI.unitTestMode=true;
		Contact contactObj = [Select Id from Contact limit 1];
		String contactId = contactObj.Id;
		contactObj = (Contact)DataLayerConstants.fetchSingle('Contact',contactId);
		DeleteObjectController controller = new DeleteObjectController(new ApexPages.Standardcontroller(contactObj));
		System.assertNotEquals(controller.salesforceObj,null);
		controller.doDelete();	
	}
	
	public static testMethod void testDelete2(){
		RESTAPI.unitTestMode=true;
		User contactObj = [Select Id from User limit 1];
		String contactId = contactObj.Id;
		contactObj = (User)DataLayerConstants.fetchSingle('User',contactId);
		DeleteObjectController controller = new DeleteObjectController(new ApexPages.Standardcontroller(contactObj));
		System.assertNotEquals(controller.salesforceObj,null);
		controller.doDelete();	
	}
}