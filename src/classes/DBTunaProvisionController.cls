public with sharing class DBTunaProvisionController extends AbstractAppDController {
	public Account accObj;
	public Opportunity myOpportunity{get;set;}
	public String saveButtonTitle{get;set;}
	public User salesRep{get;set;}
	public Contact primaryContact{get;set;}
	public Boolean provisionDisabled{get;set;}
	public Boolean isPartner{get;set;}
	public Boolean isAllowedToProvision{get;set;}
	public String expiryDateFormat{get;set;}
	public List<Contact> accountContactsToAddToBackend{get;set;}
	public User accMgrUsr{get;set;}
    public List<Contact> contactsToProvision = new List<Contact>();
    public String accountManager{get;set;}
    public String technicalOwner{get;set;}  
    public String salesRepDetails{get;set;}
    public String notifyEmailsString{get;set;}
    public List<String> notifyEmailsList{get;set;}
    public List<ContactWrapper> dblicenseContacts{get;set;}
    public String displayStyle {get;set;}
	
	
	public List<Contact> contactObjects{get;set;}
	public Map<String,Contact> contactObjectMap{get;set;}
    public Map<String,ContactWrapper> contactLicenseObjectMap{get;set;}
    public ADUAController_V2.ADUAUser adUsers {get;set;}
	

	public AccountContactsADUAHelper aduaContactsHelper{get;set;}
	public Map<ContactWrapper,ADUAUI> contactADUAUIMap{get;set;}
	
	public String requestJson {get;set;}

	public DBTunaProvisionController(ApexPages.StandardController stdCtrlr){
		super(stdCtrlr);
	}
	
	public override virtual Boolean validateObject(){
		DBTuna_License__c lic = (DBTuna_License__c)pageContextObj;
		if(lic.ExpiryDate__c == null){
			errorMessage = 'Please provide the date of expiry for the license.';
            return false;
		}
		if(lic.ExpiryDate__c <= System.now().date()){	
			errorMessage = 'License Expiry Date Should be after today';	
			return false;
		}
		
		if(lic.Server_Name__c == null || lic.Server_Name__c.equals('')){	
			errorMessage = 'Please provide server name.';	
			return false;
		}
		
		if(!validateContactsForLicense()){
			return false;
		}
             	
		return true;
	}
	  
	public Boolean validateContactsForLicense(){
        if(dblicenseContacts!=null){
            String primaryCtId = CommonUtil.getPrimaryContactID(myOpportunity);
            for(ContactWrapper licCt:dblicenseContacts){
                Contact contctToAddToBackend = licCt.contactObj;
                String contctId = contctToAddToBackend.Id; 

                String contactEmail = contctToAddToBackend.Email;
                if(contctToAddToBackend.Needs_Email__c){
                    if(contactEmail==null || contactEmail.trim().equals('')){
                        errorMessage = 'Email is not specified for one or more contacts. Please review all the contacts and provide Email.';
                        return false;
                    }
                }
            }
        }
        return true;
    } 
	
	private void updateAccMgrSalesRep(){
        //System.debug(myOpportunity.Id);
        String accId = myOpportunity.AccountId; 
        String userId = accObj.OwnerId;
        accountManager=userId+' Usr Id ';//+usr.Email+')';
        String loggedInUserId = Userinfo.getUserId();
        salesRepDetails = loggedInUserId;
        
        try{
            accMgrUsr = [Select Id,Name,Email from User Where Id =: userId];
        }catch(Exception e){
            accMgrUsr = null;
        }
        salesRep = [Select Id,Name,Email,UserType from User Where Id =: loggedInUserId];
        
        if(accMgrUsr!=null){
            accountManager=accMgrUsr.Name+' ('+accMgrUsr.Email+')';
        }
        salesRepDetails = salesRep.Name+' ('+salesRep.Email+')';
        
        if(myOpportunity!=null){
            technicalOwner='';//myOpportunity.Technical_Owner__c;
        }
    }
	
	
	public PageReference initAction(){
		try{
			loggerHandle.setClassName(DBTunaProvisionController.class.getName());
		DBTuna_License__c lic = (DBTuna_License__c)pageContextObj;
		isPartner = false;
		isAllowedToProvision = true;
		String inputOpportunityId =  ApexPages.currentPage().getParameters().get('Opportunity_Id');
		myOpportunity = inputOpportunityId!=null?(Opportunity)DataLayerConstants.fetchSingle('Opportunity_Account_Owner',inputOpportunityId):null;
		saveButtonTitle = 'Provision';
		salesRep = [select Id, Name, Email, UserType from User where id =:Userinfo.getUserId()];
		
		accObj = (Account)DataLayerConstants.fetchSingle('Account',myOpportunity.AccountId);//[Select Id,CreatedById, OwnerId,Technical_Account_Manager__r.Id,Technical_Account_Manager__r.Email ,Name,PortalID__c,RecordType.Name,RecordType.Id,(Select Id,Account__c, Company_Portal_Id__c from Account_Portal_Company__r) from Account where Id=:myOpportunity.AccountId];
		updateAccMgrSalesRep();
		
		if(!CommonUtil.isPrimaryContactRolePresent(myOpportunity)){
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'There are no primary contacts associated with this opportunity.');
        	    ApexPages.addMessage(myMsg);
            	provisionDisabled = true;
		} else{
			primaryContact = [select id, name, email, AccountId, No_longer_at_Company__c from Contact where id =:CommonUtil.getPrimaryContactID(myOpportunity)];
				if(primaryContact.Email==null){
		 			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'There are no email for primary contacts associated with this opportunity.');
        	    	ApexPages.addMessage(myMsg);
            		provisionDisabled = true;
		 		}
		 		if(accObj.id!=primaryContact.AccountId){
					provisionDisabled = true;
					errorMessage = 'Primary contact should belong to same opportunity account.';
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);
					ApexPages.addMessage(myMsg);
		 		}
		 		
		 		if(primaryContact.No_longer_at_Company__c){
					provisionDisabled = true;
					errorMessage = 'Please specify active contact as primary contact from the same account to which '+myOpportunity.Name+' belongs to.';
					ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);
					ApexPages.addMessage(myMsg);
		 		}
		 		
		 	lic.Account_Manager__c = accountManager;
			lic.Sales_Rep__c = salesRepDetails;  
			lic.Technical_Owner__c = technicalOwner;
			//lic.Primary_Contact__c = '';
			//lic.Primary_Contact__c = primaryContact.Name+'('+primaryContact.Email+')';		
		 	accountContactsToAddToBackend = CommonUtil.getAccountContactsToAddToBackend(myOpportunity);
		}
		
		if(salesRep.UserType.contains('Partner')){
			lic.Server_Name__c = 'TUNATEMP';
			lic.ExpiryDate__c = date.today().addDays(30);
			expiryDateFormat = ''+lic.ExpiryDate__c.month() +'/'+ lic.ExpiryDate__c.day()+'/'+ lic.ExpiryDate__c.year();
			isPartner = true; 
			List<Opportunity_Partner_DBLicense__c> dblicenseList = DataLayerConstants.fetchMultiple('Opportunity_Partner_DBLicense__c','Opportunity__c ',inputOpportunityId);
			if(dblicenseList != null && dblicenseList.size() == Integer.valueOf(EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.PARTNER_DBTUNALICENSE_LIMIT))){
				isAllowedToProvision = false;
			}	
		}
		
		aduaContactsHelper = AccountContactsADUAHelper.newInstance(accObj,myOpportunity,lic);
        dblicenseContacts = aduaContactsHelper.licenseContacts;
		
		accObj = (Account)DataLayerConstants.fetchSingle('Account',myOpportunity.AccountId);//[Select Id,CreatedById, OwnerId,Technical_Account_Manager__r.Id,Technical_Account_Manager__r.Email ,Name,PortalID__c,RecordType.Name,RecordType.Id,(Select Id,Account__c, Company_Portal_Id__c from Account_Portal_Company__r) from Account where Id=:myOpportunity.AccountId];
		updateAccMgrSalesRep();
		
        List<Contact> contactsFromDifferentAccount = new List<Contact>();
        if(UsersUtil.isPartner(accObj)) {
            displayStyle = 'display:block';
        }
        else{
            displayStyle = 'display:none';
        }
        
		for(ContactWrapper cw: aduaContactsHelper.licenseContacts){
		   if(cw.contactObj.AccountId==null || cw.contactObj.AccountId!=accObj.id){
				contactsFromDifferentAccount.add(cw.contactObj);
			}
		}
        
		if(contactsFromDifferentAccount.size()>0){
			errorMessage = 'Following contacts in the opportunity does not belong to the account:<a href="/'+ accObj.Id +'">'+accObj.Name+'</a>:';
			errorMessage += '<ul>';
		
			for(Contact con: contactsFromDifferentAccount){
			   errorMessage +='<li><a href="/' + con.id + '">'+con.Name+'</a></li>';
			}
			errorMessage += '</ul>';
			errorMessage += 'In order to be able to proceed with license operation please either edit the above contacts and select the Account:<a href="/'+ accObj.Id +'">'+accObj.Name+'</a> <br/> or remove them from<a href="/p/opp/ContactRoleEditUi/e?oppid='+myOpportunity.id+'&retURL=%2F'+myOpportunity.id+'">opportunity-contact roles</a>.';
			provisionDisabled = true;
			super.cancelOperation(errorMessage,null);
		}

        
        if(dblicenseContacts!=null && dblicenseContacts.size()==0){
			provisionDisabled = true;
			errorMessage = 'There are no active contacts associated with this Account. Please add new contacts or activate existing contacts.';
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);
			ApexPages.addMessage(myMsg);
        }
        
        contactObjects = new List<Contact>();		
		}catch(Exception e){
			String errorMessage = '\n\nError:'+e.getMessage()+'\n'+e.getStackTraceString();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);
            ApexPages.addMessage(myMsg);
		}
		return null;
	}
	
	private List<Contact> contactsAddedToBackend=new List<Contact>();
    //private List<Contact> otherCts=new List<Contact>();
    private List<Contact_Portal_User__c> otherCts=new List<Contact_Portal_User__c>();
    
    public List<ADUAController_V2.ADUAUserDetails> aduaUsers;
    public List<ADUAUI> aduaUIList;    
    public List<ADUAUI> aduaUIPendingList;
	
	public override virtual void setupBackend(){
		DBTuna_License__c lic = (DBTuna_License__c)pageContextObj;
		
		Integer MAX = 5;
        Integer i = 0; 
        notifyEmailsString = '';
        
        //aduaUsers = new List<ADUAController_V2.ADUAUserDetails>();
        aduaUIList = new List<ADUAUI>();
        aduaUIPendingList = new List<ADUAUI>();

        backend = new BackendLayer();
		if(accObj!=null){
			AccountBackend accBackend = new AccountBackend(accObj, BackendConstants.OPCODE_ADD_COMPANY);
			backend.addBackend(accBackend);
		}
        
        if(aduaContactsHelper!=null && aduaContactsHelper.contactWrapperList!=null){
       	for(ContactWrapper ctWrapper: aduaContactsHelper.contactWrapperList){
       		Contact ct = ctWrapper.contactObj;
    		ADUAUI aduaUIObj =ctWrapper.aduaUIObj;
    		if(aduaUIObj!=null){
    			Boolean isPrimary = (aduaUIObj.licCt!=null && aduaUIObj.licCt.Contact_Type__c.equals('PRIMARY'));
    			//aduaContactsHelper.licContactMap.get(ct.id).contactObj.Needs_Email__c
    			if(ct.Needs_Email__c){
					String ctID = ct.Id;
					if(!isPrimary){
						notifyEmailsString +=ct.Email+',';
						
					}
       			}
    			aduaUIObj.updateADUAUserDetails(lic);
    			if((aduaUIObj.isChanged()) || isPrimary){
					Contact_Portal_User__c contactPortalUser = aduaUIObj.contactPortalUser;//ct.Contact_Contact_Portal_User__r.get(0);
					if(i<max){
	    				i++;
	    				//TEMP Fix for Gateway tiemout errors to send one user call at a time
                        aduaUsers = new List<ADUAController_V2.ADUAUserDetails>();
	    				aduaUsers.add(aduaUIObj.aduaUser);
	    				aduaUIList.add(aduaUIObj);
	    				backend.addBackend(new MultipleContactsBackend_V2(aduaUsers, accObj, accMgrUsr, salesRep, null, BackendConstants.OPCODE_ADD_USER));
    				}else{
    					aduaUIPendingList.add(aduaUIObj);
	    				contactPortalUser.User_Portal_Id__c='PENDING_FOR_LICENSE';
		    			contactPortalUser.ADUAUserDetails__c = System.JSON.serialize(aduaUIObj.aduaUser);
		    			otherCts.add(contactPortalUser);  
    				}
    			}	
    		}
       	}
    }	
		
		//backend.addBackend(new MultipleContactsBackend_V2(aduaUsers, accObj, accMgrUsr, salesRep, null, BackendConstants.OPCODE_ADD_USER));
		
		backend.addBackend(new DBTunaBackend((DBTuna_License__c)pageContextObj));
	}
	
	public override virtual Boolean doPreSave(){
		DBTuna_License__c lic = (DBTuna_License__c)pageContextObj;
		if(accountContactsToAddToBackend == null){
            return true;
        }
        String backendAccId = backend.getResponse(BackendConstants.OPCODE_ADD_COMPANY);
		if(backendAccId!=null && !backendAccId.trim().equals('')){
			Account_Portal_Company__c accountPortalCompany = null;    
			if(accObj!=null){
				AccountContactsADUAHelper.saveAccountPortalDetails(backendAccId, accObj);
			}        
		}
        
        String additionalCts = '';
        
        String contactJSONResponse= '';
        contactJSONResponse = backend.getResponse(BackendConstants.OPCODE_ADD_USER);
        String userStatusCode = backend.getStatusCode(BackendConstants.OPCODE_ADD_USER);
        try{
        
    	try{
			Map<String,String> contactsMap = new Map<String,String>();
			
			JSONObject jsonResponse = new JSONObject(new JSONObject.JSONTokener(contactJSONResponse));
			
			AccountContactsADUAHelper.updateContactPortalUserDetails(aduaUIList, jsonResponse);  
			
			/*for(ADUAUI aduaUIObj: aduaUIList){
				ADUAController_V2.ADUAUserDetails ad = aduaUIObj.aduaUser;
				try{
					String portalId = '';
					try{
						portalId = jsonResponse.getValue(aduaUIObj.contactObj.Email).num+'';	
					}catch(Exception e){
							
					}
					Contact_Portal_User__c contactPortalUser = aduaUIObj.contactPortalUser;//ad.contactObj.Contact_Contact_Portal_User__r.get(0);
                	contactPortalUser.User_Portal_Id__c = portalId;
            		contactPortalUsers.add(contactPortalUser);
            		UsersUtil.saveContactHistory(aduaUIObj,contactPortalUser,CommonUtil.getPageName(),'DBTunaProvisionController', userStatusCode);
            		ADUAUtils.setupADUAContact(aduaUIObj.contactObj, ad.getApplications());
            		contactsMap.put(aduaUIObj.contactObj.id+'',ad.getApplications());
	            }
	            catch(Exception e){
	                System.debug(e);
	            }
			}*/
			
			upsert otherCts;
			
			/*for(ADUAUI aduaUIObj: aduaUIPendingList){
				Contact_Portal_User__c contactPortalUser = aduaUIObj.contactPortalUser;
				UsersUtil.saveContactHistory(aduaUIObj,contactPortalUser,CommonUtil.getPageName(),'DBTunaProvisionController', 'PENDING_FOR_STATUS');
			}*/
			
    	}catch(Exception e){
    		
    	}
		
        lic.Additional_Contacts__c = additionalCts;
        
        }catch(Exception e){
        	  String errMsg = 'Contact JSON Response:'+contactJSONResponse+'\n\nError:'+e.getMessage()+'backend:'+backend+'\n'+e.getStackTraceString();
                
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errMsg);
              ApexPages.addMessage(myMsg);
              EmailUtil.notifyError(e, null);
        }
            
		String backendResponse = backend.getResponse(BackendConstants.OPCODE_DBTUNA_PROVISION);
		try{
			JSONObject jsonResponse = new JSONObject(new JSONObject.JSONTokener(backendResponse));
			lic.Opportunity__c = myOpportunity.id;
			lic.LicenseKey__c = jsonResponse.getString('licence_key');
		}catch(Exception e){
			EmailUtil.notifyError(e, null); 
			return true;
		}
		return true;
	}
	
	public override virtual PageReference doPostSave(){
		if(myOpportunity!=null) {
			DBTuna_License__c lic = (DBTuna_License__c)pageContextObj;
			
			try{
        		List<DBLicense_Contacts__c> licCtsToDelete = [Select ID,Contact__c,dbLicense__c from DBLicense_Contacts__c where dbLicense__c=:lic.Id];
        		delete licCtsToDelete;
        	}catch(Exception e){
        		DBLicense_Contacts__c licCtToDelete = [Select ID,Contact__c,dbLicense__c from DBLicense_Contacts__c where dbLicense__c=:lic.Id];
        		delete licCtToDelete;
        	}
        	
        	List<DBLicense_Contacts__c> licCts = new List<DBLicense_Contacts__c>();
	        for(ContactWrapper ctWrapper:dblicenseContacts){
	        	if(ctWrapper.contactObj.Needs_Email__c){
	        		DBLicense_Contacts__c licCt = new DBLicense_Contacts__c();
	        		licCt.Contact__c = ctWrapper.contactObj.Id;
	        		licCt.dbLicense__c=lic.Id;
	        		licCt.Contact_Type__c = ctWrapper.dbLicContact.Contact_Type__c;
	        		licCts.add(licCt);
	        	}
	        }
	        upsert licCts;
			
			if(isPartner){
				Opportunity_Partner_DBLicense__c opb = new Opportunity_Partner_DBLicense__c();
				opb.Opportunity__c = myOpportunity.id;
				opb.DBLicense__c = lic.id;
				insert opb;
			}
			try{
				if(!notifyEmailsString.equals('')){
					notifyEmailsString +=myOpportunity.Account.owner.Email+','+salesRep.Email;
					//String ccEmails = notifyEmailsString.Substring(0,notifyEmailsString.length()-1);		
					
					EmailUtil.sendDBTunaLicenseEmail(lic, myOpportunity, primaryContact, salesRep, notifyEmailsString);
				} else{
					notifyEmailsString +=myOpportunity.Account.owner.Email+','+salesRep.Email;
					
					EmailUtil.sendDBTunaLicenseEmail(lic, myOpportunity, primaryContact, salesRep, notifyEmailsString);
				}
			}catch(Exception e){
					errorMessage = e.getMessage();
			}
			
			//List<Contact> cts = DataLayerConstants.fetchMultiple('Contact',' Where AccountId=\''+accObj.Id+'\' and PortalID__c like \'PENDING%\'');
			List<Contact_Portal_User__c> cts = Database.query('Select Id,ADUAUserDetails__c,Contact__c,Docs__c,Download__c,LMS__c,User_Portal_Id__c,ZenDesk__c from Contact_Portal_User__c where Contact__r.accountid = \''+accObj.Id+'\' and User_Portal_Id__c like \'PENDING%\'');//[Select Id,ADUAUserDetails__c,Contact__c,Docs__c,Download__c,LMS__c,User_Portal_Id__c,ZenDesk__c from Contact_Portal_User__c where Contact__r.accountid =: accObj.Id and User_Portal_Id__c like 'PENDING%'];
        	if(cts!=null && cts.size()>0){  
	            DBLicenseContactTransaction__c licTransaction = new DBLicenseContactTransaction__c();
	            licTransaction.Account__c = accObj.Id;
	            licTransaction.DBLicense__c = lic.Id;
	            licTransaction.AccMgrUsr__c = accMgrUsr.Id;
	            licTransaction.SalesRepUsr__c = salesRep.Id;
	            upsert licTransaction; 
	            PageReference ref = new PageReference('/apex/LicenseContactsBackend?dblicenseId='+lic.Id);
	            ref.setRedirect(false);
	            return ref;
        	}
			
			PageReference ref = new PageReference('/'+lic.id);
			ref.setRedirect(true);
			
			return ref;
		}
		else
			return super.doPostSave();			
	}
	
	public override virtual PageReference doCancel(){
        if(myOpportunity != null){
            PageReference ref = new PageReference('/'+myOpportunity.Id);
            ref.setRedirect(true);
            return ref;
        }
        return stdController.cancel();
	}
}