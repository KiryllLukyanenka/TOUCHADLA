/*
 * License Provision controller base class for Provision/Extend/Upgrade and Modify flows
 */
public virtual class LicenseProvisionController extends AbstractLicenseController{
    public List<SelectOption> controllersList{get;set;}
    public List<SelectOption> productTypeSelectOptions{get;set;}

    public Boolean accNameModify{get;set;}  
    public Boolean accNameReadOnly{get;set;} 
    
    public User accMgrUsr{get;set;}
    public User salesRepUsr{get;set;}
    public User oppOwnerUsr{get;set;}
    public String accountManager{get;set;}
    public String technicalOwner{get;set;}
    public String salesRep{get;set;}
    public Boolean isPermanent{get;set;}
    
    public String pageTitle{get;set;}
    public String saveButtonTitle{get;set;}
    
    public Boolean showMacAddress{get;set;}
    public Boolean showPermanentLicense{get;set;}
    
    public String stage;

    private String inputOpportunityId;
    public String debugArea{get;set;}

    Contact primaryCtct;

    private List<Contact_Portal_User__c> otherCts=new List<Contact_Portal_User__c>();
    
    public List<ADUAController_V2.ADUAUserDetails> aduaUsers;
    public List<ADUAUI> aduaUIList;
    public List<ADUAUI> aduaUIPendingList; 
    
    public Boolean applyExpiryDate{get;set;} 
    public Boolean disableLicenseModel{get;set;}
    
    public Boolean backendInvoked{get;set;}
    
    public List<SelectOption> productEditionSelectOptions = new list<SelectOption>();
    
    public LicenseProvisionController(ApexPages.StandardController stdCtrlr,Integer opcode){
        super(stdCtrlr);
        opcode = opcode;
    }
    
    public String licenseMode{
    	get{
    		if(licenseDetailObj!=null){
    			String stage = '';
    			if(licenseDetailObj.Stage__c!=null){
    				stage = licenseDetailObj.Stage__c;
    			}
    			if(stage!=null && stage.contains('PAID')){
    				return 'paid';
    			}else{
    				return 'trial';	
    			}
    		}
    		return 'trial';
    	}
    	set{
    		licenseMode = value;
    	}
	}
	
	
    public override virtual void init(){
    	super.init();
        controllersList=CommonUtil.getControllerVersionsFromBackend();
        eumAccountOption1='<b>Create new EUM Account:</b> For customers using EUM for the first time or need a seperate EUM envinornment.';
        eumAccountOption2='<b>Link to existing EUM Account:</b> For customers with an already configured EUM environment and want to continue using the same environment.';  
    }
    
    public override virtual PageReference initAction(){
        try{
        	backendInvoked=false;
            String licenseId =  ApexPages.currentPage().getParameters().get('LicenseId');
            if(licenseId!=null && !licenseId.trim().equals('') && !licenseId.trim().equalsIgnoreCase('null')){
                pageContextObj = (LicenseDetail__c) DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId); 
                licenseDetailObj = (LicenseDetail__c)pageContextObj;
            }
            
            inputOpportunityId = ApexPages.currentPage().getParameters().get('Opportunity_Id');
            super.initLicenseAndAllLicenseDependencies(inputOpportunityId);
            updateAccMgrSalesRep();

            stage = licenseDetailObj!=null?licenseDetailObj.Stage__c:'';
            isPermanent='PAID_TEMP'.equals(stage) || 'PAID_PERMANENT'.equals(stage)||'PAID_PERMANENT_EXPIRED'.equals(stage) ||'PAID_TEMP_EXPIRED'.equals(stage);
            //licenseOpcode = BackendConstants.OPCODE_PROVISION_FREE_TRIAL; 
            productTypeSelectOptions = CommonUtil.getProductTypeSelectOptions(licenseOpcode,stage);
            
            oldProductType = (licenseDetailObj!=null && licenseDetailObj.Id!=null)?licenseDetailObj.Product_Type__c:oldProductType;
        }catch(Exception e){
            String errorMessage='';
            errorMessage += 'Error:'+e.getMessage()+'\n'+e.getStackTraceString();
        }
        
        try{
        	try{
	            licAgentInfoList = LicenseUtil.getLicenseAgentInfoList(licenseDetailObj,licenseOpcode);
            }catch(Exception e){
                super.cancelOperation('',e);
        	}
        	super.uiValidation();
            
            if(accObj==null){
            	return super.cancelOperation('There is no Account associated with this opportunity. Please associate opportunity with an account and then retry',null);
            }
            //licenseContacts.sort();
        
            List<Contact> contactsFromDifferentAccount = new List<Contact>();
        
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
                super.cancelOperation(errorMessage,null);
            }
            if(myOpportunity!=null){
                updateAccMgrSalesRep();
                String primaryContactId = COmmonUtil.getPrimaryContactID(myOpportunity);
                //accountContactsToAddToBackend = CommonUtil.getAccountContactsToAddToBackend(myOpportunity);
            
                if(!CommonUtil.isPrimaryContactRolePresent(myOpportunity)){
                    String errorMessage = 'There are no primary contacts associated with this opportunity. Please click Define Primary Contact button to define primary contact.';
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errorMessage);///  mm Please make sure to associate one primary contact by navigating <a href="'+link+'">here</a>');
                    ApexPages.addMessage(myMsg);
                    renderPrimaryContact=true;
                    provisionDisabled = true;
                    loggerHandle.error(errorMessage);
                }else{
                    if(primaryContactId!=null ){
                        primaryCtct = (Contact) DataLayerConstants.fetchSingle('Contact',primaryContactId);
                        String accId = null;
                        if(primaryCtct!=null){
                        	accId = primaryCtct.AccountId;
                        }
                        if(accId==null || accId.equals('')){
                            errorMessage='Primary contact belongs to a different account than the opportunity. Please click Define Primary Contact button to assign a primary contact belonging to same account.';
                            renderPrimaryContact=true;
                            return super.cancelOperation(errorMessage,null);
                        }
                        if(accObj.id!=accId){
                            errorMessage = 'Please choose primary contact from the same account to which '+myOpportunity.Name+' belongs to.';
                            return super.cancelOperation(errorMessage,null);
                        }
                        if(primaryCtct.Email==null || primaryCtct.Email.equals('')){
                            errorMessage = 'Email is not specified for primary contact. Please review the contact and provide Email.';
                            return super.cancelOperation(errorMessage,null);
                        }
                    
                        if(primaryCtct.No_longer_at_Company__c){
                            errorMessage = 'Please specify active contact as primary contact from the same account to which '+myOpportunity.Name+' belongs to.';
                            return super.cancelOperation(errorMessage,null);
                        }
                        licenseDetailObj.Account_Manager__c = accountManager;
                        licenseDetailObj.Sales_Rep__c = salesRep;
                        licenseDetailObj.Technical_Owner__c = technicalOwner;
                        licenseDetailObj.Primary_Contact__c = '';
                    }
                }
                if(aduaContactsHelper.licenseContacts!=null && aduaContactsHelper.licenseContacts.size()==0){
                    errorMessage = 'There are no active contacts associated with this Account. Please add new contacts or activate existing contacts.';
                    return super.cancelOperation(errorMessage,null);
                }
            }
        }
        catch(Exception e){
            String errorMessage = 'System exception. Please contact Salesforce Administrator.';
			return super.cancelOperation(errorMessage,e);
        }
        if(licenseDetailObj!=null && licenseDetailObj.Id==null && 
                (licenseOpcode==BackendConstants.OPCODE_PROVISION_FREE_TRIAL||licenseOpcode==BackendConstants.OPCODE_ADD_LICENSE)){
                insert licenseDetailObj;
        }
        
        return null;
    }

    private void updateAccMgrSalesRep(){
        String userId = accObj!=null?accObj.OwnerId:null;
        accountManager=userId+' Usr Id ';//+usr.Email+')';
        String loggedInUserId = Userinfo.getUserId();
        salesRep = loggedInUserId;
        
        try{
            accMgrUsr = [Select Id,Name,Email from User Where Id =: userId];
        }catch(Exception e){
            accMgrUsr = null;
        }
        salesRepUsr = [Select Id,Name,Email from User Where Id =: loggedInUserId];
        if(accMgrUsr!=null){
            accountManager=accMgrUsr.Name+' ('+accMgrUsr.Email+')';
        }
        salesRep = salesRepUsr.Name+' ('+salesRepUsr.Email+')';
        
        if(myOpportunity!=null){
            technicalOwner='';//myOpportunity.Technical_Owner__c;
        }
        //oppOwnerUsr = myOpportunity.Owner;
    }
    
    public PageReference showAllContacts(){
        boolean toggleButtonActive = toggleButton!=null&&toggleButton;
        this.togglebutton=!toggleButtonActive;
        aduaContactsHelper = toggleButtonActive?AccountContactsADUAHelper.newInstance(null,myOpportunity,licenseDetailObj): AccountContactsADUAHelper.newInstance(accObj,myOpportunity,licenseDetailObj);
        //this.licenseContacts = aduaContactsHelper.licenseContacts;
        return null;
    }

    public override virtual Boolean validateObject(){
    	//errorMessage=selectedEUMAccountType+','+selectedEUMAccountType.equals('oldEUMAccount');
    	if(fldsRender.isOppsUser==true && selectedEUMAccountType!=null && selectedEUMAccountType.equals('oldEUMAccount')){
    		if(eumInput.eumDetails.AccountName__c==null || eumInput.eumDetails.AccountName__c.trim().equals('')){
    			errorMessage += 'Please enter EUM Account Name';
				return false;
    		}
		}
		
		/*
		 *Validating Email ids in Additional Recipients Field.  
		*/
		
		if(licenseDetailObj.Ad_hoc_Email_Ids__c!=null){
		
			String emailRegExpression = '(([A-Za-z0-9_\\-\\.\\$])+\\@([A-Za-z0-9_\\-\\.])+\\.([A-Za-z]{2,4}))(((;|,|; | ;| ; |,|,){1}([A-Za-z0-9_\\-\\. ])+\\@([A-Za-z0-9_\\-\\.])+\\.([A-Za-z]{2,4}))*)';
			String additionalRecipients = licenseDetailObj.Ad_hoc_Email_Ids__c;
			List<String> additionalRecipientsList = additionalRecipients.split(',');
			
			for(String additionalRecipientEmail : additionalRecipientsList ){
				additionalRecipientEmail = additionalRecipientEmail.trim();
            	if(!Pattern.matches(emailRegExpression,additionalRecipientEmail)){
                    errorMessage = 'Please enter email ids in comma separated format in Additional Recipients.';
					return false;
			 	}			
			 }
		}
    	
        try{
            ValidatorUtil.validate(licenseDetailObj, licenseOpcode);
            ValidatorUtil.validateAgents(licAgentInfoList, licenseOpcode, licenseDetailObj.Product_Type__c,eumInput);
            if(!validateContactsForLicense()){
                return false;
            }  
        }catch(ValidatorUtil.ValidationException e){
            errorMessage = e.getMessage();
            return false;
        }
        
        if(myOpportunity!=null){
            if(myOpportunity.AccountId==null){
                errorMessage = 'Please associate opportunity:'+myOpportunity.Name+' with any one of Salesforce Accounts to provision license.';
                return false;
            }
            return true;
        }
        
        return true;
    }

    public override virtual void setupBackend(){
    	Integer MAX = 5;
        Integer i = 0; 
        
        
        aduaUIList = new List<ADUAUI>();
        aduaUIPendingList = new List<ADUAUI>();
        backend = new BackendLayer();
        if(myOpportunity==null){
        	//Not making Company and User calls for Azure and Self-Service licenses imported
        	return;
        }
        backend = new BackendLayer();
        if(accObj!=null){
            AccountBackend accBackend = new AccountBackend(accObj,BackendConstants.OPCODE_ADD_COMPANY);
            backend.addBackend(accBackend);
        }
        if(aduaContactsHelper!=null && aduaContactsHelper.contactWrapperList!=null){
            for(ContactWrapper ctWrapper: aduaContactsHelper.contactWrapperList){
            	Contact ct = ctWrapper.contactObj;
                ADUAUI aduaUIObj =ctWrapper.aduaUIObj;
                if(aduaUIObj!=null){
                    Boolean isPrimary = ctWrapper.getIsPrimary();// (aduaUIObj.licCt!=null && aduaUIObj.licCt.Contact_Type__c.equals('PRIMARY'));
                    aduaUIObj.updateADUAUserDetails(licenseDetailObj);
                    if((aduaUIObj.isChanged()) || isPrimary){
                        Contact_Portal_User__c contactPortalUser = aduaUIObj.contactPortalUser;//ct.Contact_Portal_User__r.get(0);
                        if(i<max){
                            i++;
                            //TEMP Fix for Gateway tiemout errors to send one user call at a time
                            aduaUsers = new List<ADUAController_V2.ADUAUserDetails>();
                            aduaUsers.add(aduaUIObj.aduaUser);
                            aduaUIList.add(aduaUIObj);
                            backend.addBackend(new MultipleContactsBackend_V2(aduaUsers, accObj, accMgrUsr,salesRepUsr,null,BackendConstants.OPCODE_ADD_USER));
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

        if(eumInput.eumWeb.Type__c!=null && eumInput.eumMobile.Type__c!=null){
            eumInput.eumDetails.RUM_Enabled__c = true;
            if(selectedEUMAccountType.equals('newEUMAccount') && (eumInput.eumDetails.AccountName__c==null || eumInput.eumDetails.AccountName__c.trim().equals(''))){
                eumInput.eumDetails.AccountName__c = CommonUtil.generateAccountName(accObj.name, licenseDetailObj.id);
            }
        }

        backend.addBackend(new LicenseBackend(licenseDetailObj,myOpportunity,accObj,licAgentInfoList,aduaContactsHelper.licenseContacts,eumInput,licenseOpcode));
    }
    
    public override virtual Boolean doPreSave(){
    	backendInvoked  = true;
    	oldLicenseState = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c', licenseDetailObj.id);  
    	try{
    		relationalLicenseHistoryMap = LicenseUtil.getRelationalRecordsMap(oldLicenseState);
    	}catch(Exception e){
    		EmailUtil.notifyError(e, null);
    	}
        super.doPreSave();
        
        if(aduaContactsHelper.licenseContacts == null){
            return true;
        }
        
        if(AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(licenseDetailObj.Product_Type__c)){
            licenseDetailObj.Custom_URL_Name__c = null;
        }
        
       	String backendAccId = backend.getResponse(BackendConstants.OPCODE_ADD_COMPANY);
        if(backendAccId!=null && !backendAccId.trim().equals('')){
   	
		    Account_Portal_Company__c accountPortalCompany = null; 
		      
	    	if(accObj!=null){
				AccountContactsADUAHelper.saveAccountPortalDetails(backendAccId, accObj);
	        }           
        }
        
        String contactJSONResponse= '';
        
        contactJSONResponse = backend.getResponse(BackendConstants.OPCODE_ADD_USER);
        /*String userStatusCode = backend.getStatusCode(BackendConstants.OPCODE_ADD_USER);*/
        if(contactJSONResponse!=null && !contactJSONResponse.trim().equals('')){
            try{
    			Map<String,String> contactsMap = new Map<String,String>();
    			
    			JSONObject jsonResponse = new JSONObject(new JSONObject.JSONTokener(contactJSONResponse));
    			
    			AccountContactsADUAHelper.updateContactPortalUserDetails(aduaUIList, jsonResponse);
    			
    			upsert otherCts; 
    			
    			for(ADUAUI aduaUIObj: aduaUIPendingList){
    				Contact_Portal_User__c contactPortalUser = aduaUIObj.contactPortalUser;
    				UsersUtil.saveContactHistory(aduaUIObj,contactPortalUser,CommonUtil.getPageName(),'LicenseProvisionController', 'PENDING_FOR_STATUS');
    			}
    			
        	}catch(Exception e){
                String errMsg = 'Contact JSON Response:'+contactJSONResponse+'\n\nError:'+e.getMessage()+'\n'+e.getStackTraceString();
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,errMsg);
                ApexPages.addMessage(myMsg);
        		EmailUtil.notifyError(e, null);
                loggerHandle.error(errMsg,e);
        	}
        }
        return true;
    }
    
    public override virtual PageReference doPostSave(){
        licenseDetailObj.Last_License_User__c = Userinfo.getUserId();
        licenseDetailObj.License_Time__c = System.now();
        
        upsert licenseDetailObj;
        if(eumInput.eumDetails!=null && eumInput.eumDetails.AccountName__c!=null){
        	eumInput.eumDetails.License__c = licenseDetailObj.id;
			upsert eumInput.eumDetails;
			
			if(eumInput.eumWeb.License_EUM_Detail__c == null){
				eumInput.eumWeb.License_EUM_Detail__c = eumInput.eumDetails.id;
			}
			if(eumInput.eumMobile.License_EUM_Detail__c == null){
				eumInput.eumMobile.License_EUM_Detail__c = eumInput.eumDetails.id;
			} 
			upsert eumInput.eumWeb;
			upsert eumInput.eumMobile;
		}
        List<License_Agent__c> licAgents = new List<License_Agent__c>();
        for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgentInfoList){
            License_Agent__c licAgent = licAgentInfo.licAgent;
            if(licAgent.License__c==null){
                licAgent.License__c=licenseDetailObj.Id;
            }
            if(licAgent.Count__c > 0 || licAgent.Max_Agents__c>0){
            	licAgent.Enabled__c = true;
            }
            licAgents.add(licAgent);
        }
        upsert licAgents;
        if(aduaContactsHelper.licenseContacts.size()>0){
            try{
                LicenseUtil.updateLicenseContacts(aduaContactsHelper.licenseContacts,licenseDetailObj);
            }  catch(Exception e){
                EmailUtil.notifyError(e, null);
                loggerHandle.error(e.getMessage(),e);
            }
        }

        if(licOpp==null && myOpportunity!=null){
            licOpp = new License_Opportunity__c(Opportunity__c=myOpportunity.Id,License__c=licenseDetailObj.id);
        }
        if(licOpp!=null){
          upsert licOpp;
        }
        
        PageReference postSaveRef = super.doPostSave();

        List<Contact_Portal_User__c> cts = Database.query('Select Id,ADUAUserDetails__c,Contact__c,Docs__c,Download__c,LMS__c,User_Portal_Id__c,ZenDesk__c from Contact_Portal_User__c where Contact__r.accountid = \''+accObj.Id+'\' and User_Portal_Id__c like \'PENDING%\'');//[Select Id,ADUAUserDetails__c,Contact__c,Docs__c,Download__c,LMS__c,User_Portal_Id__c,ZenDesk__c from Contact_Portal_User__c where Contact__r.accountid =: accObj.Id and User_Portal_Id__c like 'PENDING%'];

        if(cts!=null && cts.size()>0){
            LicenseContactTransaction__c licTransaction = new LicenseContactTransaction__c();
            licTransaction.Account__c = accObj.Id;
            licTransaction.License__c = licenseDetailObj.Id;
            licTransaction.AccMgrUsr__c = accMgrUsr.Id;
            licTransaction.SalesRepUsr__c = salesRepUsr.Id;
            upsert licTransaction; 
            PageReference ref = new PageReference('/apex/LicenseContactsBackend?licenseId='+licenseDetailObj.Id);
            ref.setRedirect(false);
            return ref;
        }
        
        return postSaveRef;
    }
    
    public Boolean validateContactsForLicense(){
        if(aduaContactsHelper.licenseContacts==null){
            errorMessage = 'No Contacts';
            return false;
        }
        if(aduaContactsHelper.licenseContacts!=null){
            for(ContactWrapper licCt:aduaContactsHelper.licenseContacts){
                Contact contctToAddToBackend = licCt.contactObj;
                String contactEmail = contctToAddToBackend.Email;
                if(licCt.licContact.Need_Operations_Email__c){
                    if(contactEmail==null || contactEmail.trim().equals('')){
                        errorMessage = 'Email is not specified for one or more contacts. Please review all the contacts and provide Email.';
                        return false;
                    }
                }
            }
        }
        return true;
    } 

    /*
     * Overriding the AbstractLicenseControllers doCancel functionality. Here we check if opcode is Provision Free Trial or 
     * Provision PAID, then we will delete the license object, as the license was inserted on page load to get the salesforce id 
     * to be sent to backend. Since the license operation is cancelled before provision, we will delete the license which was 
     * inserted.
     * After this we will call the super class functionality of doCancel
     */
    public override virtual PageReference doCancel(){
        if(licenseOpcode==BackendConstants.OPCODE_PROVISION_FREE_TRIAL||licenseOpcode==BackendConstants.OPCODE_ADD_LICENSE){
        	if(backendInvoked==null || !backendInvoked){
            	delete licenseDetailObj;
        	}
            if(myOpportunity != null){
                PageReference ref = new PageReference('/'+myOpportunity.Id);
                return ref;
            }
        }
        return super.doCancel();
    }
    
     public static testMethod void testUiValidation1(){
        Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=true;
        lic.RUM_Enabled__c=true;
        upsert lic;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_PROVISION_FREE_TRIAL;
        lp.initAction();
    }
    
    
    public static testMethod void testUiValidation2(){
        Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;  
        upsert lic;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_PROVISION_FREE_TRIAL;
        lp.initAction();
    }
        
    public static testMethod void testUiValidation3(){
        Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;  
        upsert lic;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_EXTEND_TRIAL;
        lp.initAction();
    }
    
    public static testMethod void testUiValidation4(){
        Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='PAID_TEMP';
        lic.Is_Permanent__c=false;
        upsert lic;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_EXTEND_TRIAL;
        lp.initAction();
    }
    
    public static testMethod void testUiValidation5(){
        Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='PAID_PERMANENT';
        lic.Is_Permanent__c=true;
        upsert lic;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_EXTEND_TRIAL;
        lp.initAction();
    }
    
    public static testMethod void testUiValidation6(){
        Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='PAID_TEMP';
        lic.Is_Permanent__c=false;
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        upsert lic;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_TRANSITION_TO_PERMANENT;
        lp.initAction();
    }
    
    public static testMethod void testUiValidation7(){
        Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='TRIAL';
        lic.Is_Permanent__c=true;
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
        upsert lic;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_TRANSITION_TO_PERMANENT;
        lp.initAction();
    }
    
    public static testMethod void testUiValidation8(){
        Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='TRIAL';
        lic.Is_Permanent__c=true;
        lic.Support__c=true;
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
        lic.Custom_URL_Name__c='TestCustomURL_20130204';
        upsert lic;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_TRANSITION_TO_PERMANENT;
        lp.initAction();
    }
    
    
    public static testMethod void testUiValidation9(){
        Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='TRIAL';
        lic.Is_Permanent__c=false;
        lic.Custom_URL_Name__c='TestCustomURL_20130204';
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE;
        upsert lic;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_PROVISION_FREE_TRIAL;
        lp.initAction();
    }
    public static testMethod void testUiValidation10(){
    	 Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='TRIAL';
        lic.Is_Permanent__c=false;
        lic.Custom_URL_Name__c='TestCustomURL_20130204';
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE;
        upsert lic;
        License_EUM_Details__c led = new License_EUM_Details__c();
        led.Access_Key__c = '';
        led.License__c = lic.id;
        upsert led;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_PROVISION_FREE_TRIAL;
        lp.initAction();
    }
    
    public static testMethod void testUiValidation11(){
    	 Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='TRIAL';
        lic.Is_Permanent__c=false;
        lic.Custom_URL_Name__c='TestCustomURL_20130204';
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE;
        upsert lic;
        License_EUM_Details__c led = new License_EUM_Details__c();
        led.Access_Key__c = '';
        led.License__c = lic.id;
        upsert led;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_PROVISION_FREE_TRIAL;
        lp.initAction();
    }
    
    public static testMethod void testUiValidation12(){
    	 Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='TRIAL';
        lic.Is_Permanent__c=false;
        lic.Custom_URL_Name__c='TestCustomURL_20130204';
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE;
        upsert lic;
        License_EUM_Details__c led = new License_EUM_Details__c();
        led.Access_Key__c = '';
        led.License__c = lic.id;
        upsert led;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_PROVISION_FREE_TRIAL;
        lp.initAction();
    }
    
    public static testMethod void testUiValidation13(){
    	 Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='TRIAL';
        lic.Is_Permanent__c=false;
        lic.Custom_URL_Name__c='TestCustomURL_20130204';
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE;
        upsert lic;
        License_EUM_Details__c led = new License_EUM_Details__c();
        led.Access_Key__c = '';
        led.License__c = lic.id;
        upsert led;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_PROVISION_FREE_TRIAL;
        lp.selectedEUMAccountType = 'newEUMAccount';
        lp.initAction();
    }
    
    public static testMethod void testUiValidation14(){
    	Pagereference page = new PageReference('/apex/LicenseProvision_Upgrade.page');
        Test.setCurrentPage(page);
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        Apexpages.currentPage().getParameters().put('LicenseId',lic.Id);
        lic.Is_EUM__c=false;
        lic.RUM_Enabled__c=false;
        lic.Stage__c='TRIAL';
        lic.Is_Permanent__c=false;
        lic.Custom_URL_Name__c='TestCustomURL_20130204';
        lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE;
        upsert lic;
        License_EUM_Details__c led = new License_EUM_Details__c();
        led.Access_Key__c = '';
        led.License__c = lic.id;
        upsert led;
        LicenseProvisionController lp = new LicenseProvision_ExtendController(new ApexPages.Standardcontroller(lic));
        lp.licenseOpcode=BackendConstants.OPCODE_PROVISION_FREE_TRIAL;
        lp.selectedEUMAccountType = 'oldEUMAccount';
        lp.initAction();
    }
    
}