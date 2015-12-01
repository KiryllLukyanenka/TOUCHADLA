public with sharing class ContactBackend_V2 extends Backend{
	
	private User accMgrUsr;
    private User salesRepUsr;
    private User oppOwnerUsr;
    private Account accountObj;
    
    public ADUAController_V2.ADUAUserDetails adua{get;set;}
	
	public ContactBackend_V2(ADUAController_V2.ADUAUserDetails adua,Account accountObj, Integer opCode){
		this.adua = adua;
		this.accountObj = accountObj;
        this.opCode = opCode;
        setupInputParameters();
	}
	
	public ContactBackend_V2(ADUAController_V2.ADUAUserDetails adua, Account accountObj, User accMgrUsr,  User salesRepUsr, User oppOwnerUsr, Integer opCode){
        super();
        this.adua = adua;
        this.accountObj = accountObj;
        this.opCode = opCode;
        this.accMgrUsr = accMgrUsr;
        this.salesRepUsr= salesRepUsr;
        this.oppOwnerUsr = oppOwnerUsr;
        setupInputParameters();
    }
	
	public virtual override void setupInputParameters(){
		String email = (adua.Email!=null)?adua.Email:'';
        BackendLayer.BackendParameter param = new BackendLayer.BackendParameter('email',email);
        getParameters().add(param);
          
        //String firstName = (adua.FirstName!=null && !adua.FirstName.trim().equals('\\'))?adua.FirstName:'';
        String firstName = adua.FirstName; //(adua.FirstName!=null && !adua.FirstName.trim().equals('\\'))?adua.FirstName:'';
        if(firstName == null) {
            firstName = '';
        }
        String lastName = adua.lastName;
        String name = firstName + ' ' + lastName;
        
        param = new BackendLayer.BackendParameter('userName',name);
        getParameters().add(param);
        
        
        param = new BackendLayer.BackendParameter('firstName',firstName);
        System.debug('First name : ' + firstName);
        System.debug('After escaping : ' + param.value);
        
        getParameters().add(param);
        
        param = new BackendLayer.BackendParameter('lastName',lastName);
        getParameters().add(param);
        
        Boolean enableAccess = false;
        Boolean docsPresent=false;
        Boolean downloadPresent=false;
        Boolean zendeskPresent=false;
        Boolean lmsPresent = false;
        
        String userType = 'customer';
        if(adua.Email!=null && adua.Email.containsIgnoreCase('@appdynamics.com')){
        	userType='internal';
        }
        String accMgrEmail='';
        String salesRepEmail='';
        String oppOwnerEmail='';
        String techOwner='';
        String accMgr='';
        String salesRep='';
        
        if(accountObj!=null){
        	String recType=accountObj.RecordType.Name;
            if('Partner Account'.equals(recType)){
                userType = 'partner';
            }
            salesRep = Userinfo.getUserId();
            accMgr = accountObj.OwnerId;
            if(accMgrUsr==null || salesRepUsr==null){
                List<User> usrObjs = [Select Id,Name,LastName,Email from User where Id =: salesRep OR Id=:accMgr];
                for(User usr:usrObjs){
                    String usrId = usr.Id;
                    if(usrId.equals(accMgr)){
                        accMgrUsr = usr;
                    }
                    else if(usrId.equals(salesRep)){
                        salesRepUsr = usr;
                    }
                }
            }
        }
        
        List<JsonObject.value> rolesArr = new List<JsonObject.value>();
        //rolesArr.add(new JSONObject.value(roles));
        //if(adua.conWrapper.getIsPrimary()) {
        //	rolesArr.add(new JSonObject.value('Company Admin'));
        //}
        //else {
        //	rolesArr.add(new JSonObject.value('User'));
        //}
        
        //System.debug('rolesArr' + rolesArr.get(0).toString());
		
        param = new BackendLayer.BackendParameter('roles',rolesArr);
		System.debug('Adding roles');
        getParameters().add(param);
        
        System.debug(LoggingLevel.Info,'#######DOCS Present:'+docsPresent+'###Download Present:'+downloadPresent+'####ZenDeskPresent:'+zenDeskPresent);

        String applications = '';
        List<JsonObject.value> applicationsArr = new List<JsonObject.value>();
        
		for(String temp:adua.applications){
            System.debug('Application list : ' + temp);
			if(temp!=null && !temp.trim().equals('')){
				if(temp.contains('docs')){
					enableAccess = true;
					applications='docs/docs-'+userType;
            		applicationsArr.add(new JsonObject.value('docs/docs-'+userType));
            		if(temp.contains('docs-partner-fez')){
            			applicationsArr.add(new JsonObject.value('docs/docs-partner-fez'));
		            }	
				} else{
					enableAccess = true;
					applicationsArr.add(new JsonObject.value(temp));
				}
			} else{
				enableAccess = false;
			}
		}
        
        param = new BackendLayer.BackendParameter('isActive',adua.isActive+'');
        getParameters().add(param);
         
        param = new BackendLayer.BackendParameter('applications',applicationsArr);
        getParameters().add(param);
        
        param = new BackendLayer.BackendParameter('techOwner',techOwner);
        getParameters().add(param);
        salesRepEmail = (salesRepUsr!=null)?salesRepUsr.email:'';
        param = new BackendLayer.BackendParameter('salesRepEmail',salesRepEmail);
        getParameters().add(param);
        accMgrEmail = (accMgrUsr!=null)?accMgrUsr.Email:'';
        param = new BackendLayer.BackendParameter('accountManagerEmail',accMgrEmail);
        getParameters().add(param);
                
        oppOwnerEmail = (oppOwnerUsr!=null)? oppOwnerUsr.Email:'';
        param = new BackendLayer.BackendParameter('opportunityOwnerEmail',oppOwnerEmail);
        getParameters().add(param);
        
        param = new BackendLayer.BackendParameter('userType',userType);
        getParameters().add(param);
        
        param = new BackendLayer.BackendParameter('salesforceContactId',adua.contactId);
        getParameters().add(param);
        
        param = new BackendLayer.BackendParameter('salesforceAccountId',accountObj.id);
        getParameters().add(param);

        param = new BackendLayer.BackendParameter();
        param.key = 'companyId';
        Account_Portal_Company__c accountPortalCompany = null;
        list<SObject> accPortalCompanies = accountObj.getSObjects(BackendConstants.ACCOUNT_CHILD_RELATIONAL_NAME);
        if(accPortalCompanies != null && accPortalCompanies.size()>0){
            accountPortalCompany = (Account_Portal_Company__c) accPortalCompanies.get(0);
        }
        
        if(accountPortalCompany!=null && accountPortalCompany.Company_Portal_Id__c !=null && 
            accountPortalCompany.Company_Portal_Id__c != 'None' && accountPortalCompany.Company_Portal_Id__c != ''){
            System.debug('Portal company id : ' + accountPortalCompany.Company_Portal_Id__c);
            Integer compId = Integer.valueOf(accountPortalCompany.Company_Portal_Id__c);
            param.intVal= compId;
            param.backendParameterType = BackendConstants.BACKEND_PARAM_INT_VALUE;
            getParameters().add(param);
        }else{
            param.backendParameterType = BackendConstants.BACKEND_PARAM_TYPE_CHAIN_RESPONSE;
            param.chainOpcode=BackendConstants.OPCODE_ADD_COMPANY;
            getParameters().add(param);
        }
	}
}