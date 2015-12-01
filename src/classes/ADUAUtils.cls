@RestResource(urlMapping='/manage_user/*')
global class ADUAUtils {
    
    /*
     * Manage User API to be used from Portal Edit user flows to send updated name back to salesforce
     */
    @HttpPost
    global static void manageUser(String firstName,String lastName,String email,String accountName,String companyId,String userId,String applications){
        firstName = firstName.replace('\\','');
        firstName=String.escapeSingleQuotes(firstName);
        lastName = lastName.replace('\\','');
        lastName=String.escapeSingleQuotes(lastName);  
        accountName = accountName.replace('\\','');
        accountName=String.escapeSingleQuotes(accountName);
        ResponseHandler resHandler = null;
        RestResponse response = RestContext.response;
        try{
            
            /*
             * Checking if there is any Self-Service lead exist for the given email.
             * If the lead exsists then, we convert the convert and claim the Self-Service license
             * by calling execute method from PortalLeadToLicenseManager.cls.
             */
            Lead leadObj = null;
            try{
                leadObj = [Select Id, LeadSource,Status,Email, Company from Lead where IsConverted=false and email =:email limit 1];
            }catch(Exception e){}
            
            if(leadObj!=null){
                List<PortalLeadToLicenseManagerInput> inputList = new List<PortalLeadToLicenseManagerInput>();
                PortalLeadToLicenseManagerInput input = PortalLeadToLicenseManagerInput.newInstance(leadObj.id,leadObj.LeadSource);
                input.email = leadObj.Email;
                input.status = leadObj.status;
                input.accountName = accountName;
                inputList.add(input);
                
                String key='';
                for(PortalLeadToLicenseManagerInput ip:inputList){
                    key+=ip.email;
                }
                Account Acct;
				try {
                	acct = getAccount(companyId, accountName);
				}	         
				Catch(Exception e) {
					//Ignore
					System.debug('No enpterprise account yet');
				}       
            	List<String> listOfEmails = new List<String>();
            	listOfEmails.add(email);
		    	PortalLicenseSynch sync = new PortalLicenseSynch();
		    	sync.action = PortalLicenseSynch.ACTION_PULL_AND_STORE_LICENSES; 
		    	sync.emailIds = listOfEmails;
		    	if(acct != null) {
			    	sync.accountIdForLeadConvert = acct.Id;
		    	}
		    	else {
		    		sync.ssBuyAcctName = accountName;
		    	}
		    	sync.opportunityId = null;
		    	String acctId = null;
		    	if(acct != null && acct.id != null) {
		    		acctId = acct.id;
		    	}
		    	sync = PortalLicenseSynch.processDataSync(listOfEmails, acctId, null, accountName);
		    	
            	
                //PortalLeadToLicenseManager.execute(inputList);
        
                response.statusCode = 200;
                String ctId = sync.emailToContactMap.get(email).id;
                System.debug('ctId : ' + ctId);
                if(ctId!=null){
                    Contact con = (Contact)DataLayerConstants.fetchSingle('Contact', ctId);
                    resHandler = new ResponseHandler('success',null,con);
                    response.responseBody = Blob.valueOf(JSON.serialize(resHandler));
                }else{
                    resHandler = new ResponseHandler('failure','Failure in converting lead to contact',null);
                    response.responseBody = Blob.valueOf(JSON.serialize(resHandler));
                }
            }else{
                
                /*
                 * Here, we get contact record for a given user details.
                 */
                Contact con = getContact(firstName, lastName, email, accountName, companyId,userid,response);
                if(con!=null){
                    setupADUAContact(con, applications);
                    resHandler = new ResponseHandler('success',null,con);
                    response.statusCode = 200;
                    response.responseBody = Blob.valueOf(JSON.serialize(resHandler));
                }
            }
        }catch(Exception e){
                response.statusCode = 500;
                resHandler = new ResponseHandler('failure',e.getMessage()+'\n'+e.getStackTraceString(),null);
                response.responseBody = Blob.valueOf(JSON.serialize(resHandler));
        }
    }
    
    /*
     * Querys for Account and Account_Portal_Company__c record for a given companyId and accountName.
     */
    public static Account getAccount(String companyId, String accountName){
         //Account acct = (Account)DataLayerConstants.fetchSingleWithWhereClause('Account',' WHERE PortalID__c = \''+companyId+'\' ');
        Account acct = null;
		if(companyId == 'None') {
			companyId = '';
		}
        Account_Portal_Company__c accountPortalCompany = null;
        try{
            accountPortalCompany = (Account_Portal_Company__c)Database.query('Select Id, Account__c, Account__r.Name, Account__r.Owner.isActive, Account__r.OwnerId, Account__r.id, Company_Portal_Id__c from Account_Portal_Company__c where Company_Portal_Id__c = \''+companyId+'\' limit 1');
        }catch(Exception e){
        	System.debug('Manage user error : ' + e.getMessage());
	   		System.debug('Manage user Stacktrace : ' + e.getStackTraceString());
            System.debug(LoggingLevel.ERROR, 'Error in retrieving account by portal id:'+ companyId);
        }
         
        if(accountPortalCompany!=null){
            acct = (Account)accountPortalCompany.getSObject('Account__r');
        }

         if(acct == null){
            acct = (Account)DataLayerConstants.fetchSingle('Account', ' Name ', accountName);
            
            if(acct != null && acct.getSObjects('Account_Portal_Company__r') != null && acct.getSObjects('Account_Portal_Company__r').size()>0){
                accountPortalCompany =(Account_Portal_Company__c) (acct.getSObjects('Account_Portal_Company__r').get(0));
                accountPortalCompany.Company_Portal_Id__c = companyId;
            }else{
                accountPortalCompany = new Account_Portal_Company__c(Company_Portal_Id__c=companyId);
                accountPortalCompany.put('Account__c',acct.id);
            }
            
            if(accountPortalCompany!=null){
                upsert accountPortalCompany;
            }
         }
        
        return acct;
    }
    
    /*
     * Querys for contact record under a given portalId and accountName.
     * If the contact record does not exsist then, we create new contact under the Account.
     */
    public static Contact getContact(String firstName,String lastName,String email,String accountName,String companyId,String userId,RestResponse response){
        Account acct = getAccount(companyId, accountName);
        if(acct!=null){
            if(acct.Owner.isActive){
                Contact con = (Contact)DataLayerConstants.fetchSingleWithWhereClause('Contact', ' WHERE Accountid = \''+acct.id+'\' and Email = \''+email+'\'');
                
                if(con==null){      
                    con = new Contact(firstName = firstName, lastName = lastName, Email = email, PortalID__c = userId, Accountid = acct.id, Ownerid = acct.OwnerId);
                }else{
                    con.FirstName = firstName;
                    if(lastName!=null && !lastName.equals('')){
                        con.LastName = lastName;
                    }
                }
                upsert con;  
                
                if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
                    Contact_Portal_User__c contactPortalUser = new Contact_Portal_User__c();
                    contactPortalUser.put('Contact__c',con.id);
                    contactPortalUser.put('User_Portal_Id__c',userId); 
                    insert contactPortalUser;
                    con = (Contact)DataLayerConstants.fetchSingleWithWhereClause('Contact', ' WHERE Accountid = \''+acct.id+'\' and Email = \''+email+'\' ');
                }
                
                return con;
            }else{
                response.statusCode = 206;
                ResponseHandler resHandler = new ResponseHandler('partial','The Account owner of '+accountName+' is inActive. Please contact Salesforce Adminstrator to change the owner of the Account.',null);
                response.responseBody = Blob.valueOf(JSON.serialize(resHandler));
            }
        }else{
            response.statusCode = 404;
            ResponseHandler resHandler = new ResponseHandler('failure','Cannot find Account record with name: '+accountName+' and portal id: '+companyId+'',null);
            response.responseBody = Blob.valueOf(JSON.serialize(resHandler));
        }
        
        return null;
    }
    
    /*
     * Updating the Contact ADUA permissions with the given applications string.
     * Example: application: 'docs/docs-partner,download-zones/saas-public,download-zones/onpremise-public,help,learning-system/lms-learner'
     */
    public static void setupADUAContact(Contact con, String applications){

        if(con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME)==null || con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).size()==0){
            con = (Contact)DataLayerConstants.fetchSingle('Contact',con.id);
        }
        Contact_Portal_User__c contactPortalUser = (Contact_Portal_User__c)con.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).get(0);
        
        if(applications.contains('docs') || applications.contains(AppDConstants.ACCESSIBLE_DOCS)){
            contactPortalUser.Docs__c = true;
        }else{
            contactPortalUser.Docs__c = false;
        }
        
        if(applications.contains('download-zones') || applications.contains(AppDConstants.ACCESSIBLE_DOWNLOADS)){
            contactPortalUser.Download__c = true;
        }else{
            contactPortalUser.Download__c = false;
        }

        if(applications.contains('learning-system') || applications.contains(AppDConstants.ACCESSIBLE_LMS)){
            contactPortalUser.LMS__c = true;            
            
        }else{
            contactPortalUser.LMS__c = false;
        }
        
        if(applications.contains('help') || applications.contains(AppDConstants.ACCESSIBLE_ZENDESK)){
            contactPortalUser.ZenDesk__c = true;
        }else{
            contactPortalUser.ZenDesk__c = false;
        }
		
        if(applications.contains('community-fanclub') || applications.contains(AppDConstants.ACCESSIBLE_FAN_CLUB)){
            con.Registered_Fan_Club__c = 'Yes';
        }else{
            con.Registered_Fan_Club__c = 'No';
        }
        
        update con;
        
        upsert contactPortalUser;
    }
    
    /*
     * This Wrapper class is used to build response for a Rest Request.
     */
    public class ResponseHandler{
        public String status{get;set;}
        public String reason{get;set;}
        public Contact contact{get;set;} /* I think we should use SObject to make response more generic but, at present using contact object for manage user api. */
        
        public ResponseHandler(String status,String reason,Contact contact){
            this.status = status;
            this.reason = reason;
            this.contact = contact;
        }
    }
    
}