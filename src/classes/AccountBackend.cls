/**
 * Class: AccountBackend
 * Package: None 
 * Abstract: Class responsible for setting all the input parameters needed for Account(company) backend call
 * Extends the base functionalities from Backend class
 */
public virtual class AccountBackend extends Backend{
	/*
	 * Account object being stored as company in portal.
	 */
    public Account accountObj{get;set;}
    
    /*
     * Account Portal Company instance to store reference to portal company id for the salesforce account.
     */
    public Account_Portal_Company__c accPortalCompany{get;set;}
    
    /*
     * Constructor to initialize the account backend interface.
     * Here we set the OPCODE to ADD_COMPANY as passed by the callser
     * and set the account object which needs to be added to backend
     * Then setupInputParameters is called which adds all the backend 
     * parameters needed for account backend call
     */
    public AccountBackend(Account accountObj, Integer opCode){
        this.opCode = opCode;
        this.accountObj = accountObj;
        //Initializing Account Portal Company Reference
        if(accountObj.id != null) {
	        if(accountObj.getSObjects(BackendConstants.ACCOUNT_CHILD_RELATIONAL_NAME)!=null && accountObj.getSObjects(BackendConstants.ACCOUNT_CHILD_RELATIONAL_NAME).size()>0){
				this.accPortalCompany = (Account_Portal_Company__c)accountObj.getSObjects(BackendConstants.ACCOUNT_CHILD_RELATIONAL_NAME).get(0);
	        }else{
	        	//Requerying or Creating a new object of Type AccountPortalCompany
	        	Account tempAcc = (Account)DataLayerConstants.fetchSingle('Account',accountObj.Id);
	        	if(tempAcc.getSObjects(BackendConstants.ACCOUNT_CHILD_RELATIONAL_NAME)!=null && tempAcc.getSObjects(BackendConstants.ACCOUNT_CHILD_RELATIONAL_NAME).size()>0){
	        		this.accPortalCompany = (Account_Portal_Company__c)tempAcc.getSObjects(BackendConstants.ACCOUNT_CHILD_RELATIONAL_NAME).get(0);
	        	}else{
	        		//this.accPortalCompany = new Account_Portal_Company__c(Account__c=accountObj.Id);
	                this.accPortalCompany = new Account_Portal_Company__c();
	                this.accPortalCompany.put('Account__c',accountObj.Id);
	        	}
	        }
        }
        //Call SetupInputParameters method of Backend, so that all the input parameters for backend call are initialized
        setupInputParameters();
    }
    
    /*
     * Initialize all the backend parameters needed to be sent to portal for adding this account
     * as a company
     */
    public override virtual void setupInputParameters(){

        /*
         * Setting the Portal Company ID by looking from Account_Portal_Company object
         * If there is no Company ID retrieved due to missing Account_portal_company entry
         * for this account then company id is not sent and portal treats it as a fresh creation
         * i.e., add new company.
         * If a company id is successfully obtained and passed in, then portal treats this call
         * as update or rename a company with the matching ID.
         */
        
        String portalId = '';
        //Account_Portal_Company__c accountPortalCompany = null;
        if(accPortalCompany!=null){
        	portalId = accPortalCompany.Company_Portal_Id__c;
        }
        
        //Send id param only id non-null
        if(portalId!=null && !portalId.trim().equals('') && !portalId.equals('None')){
            BackendLayer.BackendParameter param1 = new BackendLayer.BackendParameter('id',portalId);
            getParameters().add(param1);
        }
		
        
        /* 
         * Send account name in salesforce as company name in backend.
         * This name will also be used to rename company in backend during update call as explained above
         */
        BackendLayer.BackendParameter param2 = new BackendLayer.BackendParameter('companyName',accountObj.Name);
        getParameters().add(param2);
        
        /*
         * Check if partner is logged in using CommonUtil#isPartnerLoggedIn method
         * If partner user is the user doing account backend call, then send the below two additional params
         * <ul>
         *     <li>ownerAccountName - Account name of the partner user</li>
         *     <li>ownerAccountBackendId - Partner user's company backend id </li>
         * </ul>
         * The account of the partner user is obtained using User-->Contact-->Account relationship.
         */
        if(CommonUtil.isPartnerUserLoggedIn()){
            User user = [Select Id,Contact.Account.Name,Contact.PortalID__c,Contact.Account.PortalID__c from User where Id=:UserInfo.getUserId()];
            BackendLayer.BackendParameter param = new BackendLayer.BackendParameter('ownerAccountName',user.Contact.Account.Name);
            getParameters().add(param);
            param = new BackendLayer.BackendParameter('ownerAccountBackendId',user.Contact.Account.PortalID__c);
            getParameters().add(param);
        }
        
        /*
         * Sending the companyType as either internal/partner/customer based on below conditions:
         * <ul>
         *     <li> account.name contains AppDynamics then ==> Internal
         *          account-groups ==> internal
         *     <li> account.recordType == VAR Account or Partner Account ==> partner
         *          account-groups ==> partners/trusted-partner
         *     <li> otherwise ==> customer
         *          account-groups ==> customers/enterprise
         * </li>
         */
        
        BackendLayer.BackendParameter recordTypeParam= null;
        String recordType = accountObj.RecordType.Name;
        List<JsonObject.value>accGrps = new List<JSonObject.value>();
        
        if(accountObj.Name.containsIgnoreCase('AppDynamics')){
        	//internal
        	recordTypeParam = new BackendLayer.BackendParameter('companyType','internal');
            getParameters().add(recordTypeParam);
            accGrps.add(new JSonObject.value('internal'));
        }else{
        	
	        if('VAR Account'.equalsIgnoreCase(recordType)|| 'Partner Account'.equalsIgnoreCase(recordType)){
	        	//partner
	            recordTypeParam = new BackendLayer.BackendParameter('companyType','partner');
	            getParameters().add(recordTypeParam);
	            accGrps.add(new JSonObject.value('partners/trusted-partners'));
	        }else{
	        	//customer
	            recordTypeParam = new BackendLayer.BackendParameter('companyType','customer');
	            getParameters().add(recordTypeParam);
	            accGrps.add(new JSonObject.value('customers/enterprise'));
	        }
        }
        BackendLayer.BackendParameter param = new BackendLayer.BackendParameter('accounts-groups',accGrps);
        getParameters().add(param);
 		 //Adding Account ID Needed for ViewCentral which is used as Organization ID
        param = new BackendLayer.BackendParameter('salesforceAccountId',accountObj.id);
        getParameters().add(param);
    }
    
    /*
     * Overriding Backend's handleResponse method. This is overriden to set 
     */
    public override virtual void handleResponse(String response,Integer statusCode){
    	/*
    	 * Set Company Portal ID in Account Portal Company Reference. This can be then used
    	 * by controller's doPreSave method to persist the data in DB.
    	 */
        if(accPortalCompany!=null && response!=null && !response.trim().equals('')){
            accPortalCompany.Company_Portal_Id__c = response;
        }
    }
}