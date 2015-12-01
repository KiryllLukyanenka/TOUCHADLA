public with sharing class Controller_PermissionCheck {
	
	public Controller_PermissionCheck(){
		String operation = Apexpages.currentPage().getParameters().get('operation');
		if(operation == null || operation.trim().length() == 0){
			throw new PermissionException('Operation parameter not specified in request');
		}
		Profile pro = [Select Name from Profile where Id = : UserInfo.getProfileId()];
		String profile = pro.Name;
		
		if(!hasPermission(operation, profile)){
			throw new PermissionException('You do not have permissions to perform the \''+operation+'\' operation. Please contact your Salesforce Administrator to enable this.');
		}
	}
	
	private Boolean hasPermission(String operation , String profile){
		if (operation.equalsIgnoreCase('ProvisionTrial')){
			//anyone can do a 'Provision Trial'
			return true;
		}else if (operation.equalsIgnoreCase('ProvisionPaid')){
			return 'System Administrator'.equalsIgnoreCase(profile) || LicenseUtil.isOperationSupport(null,BackendConstants.OPCODE_ADD_LICENSE);
		}else{
			throw new PermissionException('Unknown operation \''+operation+'\'');
		}
	}
	public class PermissionException extends Exception{}
}