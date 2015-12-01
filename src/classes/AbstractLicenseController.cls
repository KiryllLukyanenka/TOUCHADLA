/*
 *
 */
public abstract class AbstractLicenseController extends AbstractAppDController{
    public  Account accObj;
    public  Opportunity myOpportunity{get;set;}
    public LicenseDetail__c licenseDetailObj{get;set;}
    public AccountContactsADUAHelper aduaContactsHelper{get;set;}
    public List<License_Agent__c> licAgents{get;set;}
    public List<PortalDataType.LicenseAgentInfo> uiLicAgents{get;set;}
    public transient map<String,List<PortalDataType.LicenseAgentInfo>> categoryBasedLicenseAgentsForUI{get;set;}
    public License_Opportunity__c licOpp{get;set;}
    public License_System__c licSys{get;set;}
    public LicenseDetail__c oldLicenseState;
    public transient Map<String,List<SObject>> relationalLicenseHistoryMap = new Map<String,List<SObject>>();
    public LicenseEUMInput eumInput{get;set;}
    public List<ContactWrapper> licenseContacts{get;set;}
    public List<PortalDataType.LicenseAgentInfo> licAgentInfoList{get;set;}
    public String pageTitle{get;set;}
    public String oldProductType{get;set;}
    public String inputLicenseId{get;set;}
    public Boolean renderPrimaryContact{get;set;}
    public License_EUM_Details__c licenseEUMDetails{get;set;}
    public FieldsRender fldsRender{get;set;}  
    public Boolean showSelfService{get;set;}
    public Contact selfServiceContact{get;set;}
    public String selectedEUMAccountType{get;set;}
    public Boolean disableEUMOption1{get;set;}
    public Boolean eumUnitsEnabled{get;set;}
    public Boolean eumAllowOveragesEnabled{get;set;}
    public String eumTypeSelected{get;set;}
    public Boolean toggleButton{get;set;}
    public Boolean deltaValues{get;set;}
    public String eumAccountOption1{get;set;}
    public String eumAccountOption2{get;set;}
    public Boolean refreshLicenseAgents{get;set;}
    public List<String> licenseAgentCategories{get{
    		return BackendConstants.LICENSE_AGENT_CATEGORIES;
    }}
    public String getEumTypeSelected(){
        return eumTypeSelected;
    }
    
    public AbstractLicenseController thisController{
    	get{
    		return this;
    	}
    }
    
    public PageReference uiValidation(){
        fldsRender = new AbstractLicenseController.FieldsRender();
        fldsRender.eum = true;
		System.debug('Testing portalstg deployment');

        if(licenseDetailObj==null){
            return null;
        }
        fldsRender.eum = CommonUtil.isPartnerUserLoggedIn()?false:true;
        fldsRender.coRadiant = CommonUtil.isPartnerUserLoggedIn()?false:true;
        fldsRender.controller= false;
        fldsRender.saasUsr= false;
        fldsRender.saasManual= false;
        fldsRender.saasAcc= false;
        //fldsRender.php = true;
        String productType=licenseDetailObj.Product_Type__c;
        if(licenseOpcode==BackendConstants.OPCODE_PROVISION_FREE_TRIAL){
            fldsRender.macAddress = false;
            fldsRender.permLicense= false;
            fldsRender.perpLicense= false;
        }else if(licenseOpcode==BackendConstants.OPCODE_EXTEND_TRIAL){
            
            if(licenseDetailObj.Stage__c==null || licenseDetailObj.Stage__c.contains('TRIAL') || licenseDetailObj.Stage__c.contains('PAID_TEMP')){
                fldsRender.macAddress = false;
                fldsRender.permLicense= false;
                fldsRender.perpLicense= false;  
            }else{
                fldsRender.permLicense= true;
                fldsRender.macAddress = licenseDetailObj.Is_Permanent__c && AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(productType);
                fldsRender.perpLicense= licenseDetailObj.Is_Permanent__c;
            }
        }else if(licenseOpCode==BackendConstants.OPCODE_ADD_LICENSE || licenseOpcode==BackendConstants.OPCODE_TRANSITION_TO_PERMANENT){
            //fldsRender.php = false;
            fldsRender.permLicense= true;
            fldsRender.macAddress = licenseDetailObj.Is_Permanent__c&&AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(productType);
            fldsRender.perpLicense= licenseDetailObj.Is_Permanent__c;
        }
        if(licenseDetailObj.Product_Type__c==null || AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(licenseDetailObj.Product_Type__c)){
            fldsRender.customURL= false;
        }else{
            //fldsRender.php=false;
            
            fldsRender.supportProvisioning = LicenseUtil.hasSpecialPrivileges();
            if(licenseDetailObj.Support__c!=null && licenseDetailObj.Support__c){               
                fldsRender.saasUsr= true;
                fldsRender.saasManual= true;
                fldsRender.saasAcc= true;
                fldsRender.controller= true;
            }
            fldsRender.customURL= true;
            fldsRender.macAddress = false;
        }
    
    	fldsRender.eum = licenseDetailObj.Is_EUM__c;
    	fldsRender.coRadiant = licenseDetailObj.Is_EUM__c;

        fldsRender.isOppsUser = LicenseUtil.hasSpecialPrivileges();
        
        if(fldsRender.isOppsUser){
            if(selectedEUMAccountType!=null && selectedEUMAccountType.equals('newEUMAccount')){
                fldsRender.disableEUMAccountNameField = true;
                eumInput.eumDetails.Import_EUM__c = false;
                eumInput.eumDetails.AccountName__c = '';
            }else if(selectedEUMAccountType!=null && selectedEUMAccountType.equals('oldEUMAccount')){
                fldsRender.disableEUMAccountNameField = false;
                eumInput.eumDetails.Import_EUM__c = true;
            }
        } else{
            eumInput.eumDetails.Import_EUM__c = false;
        }
        
        System.debug(LoggingLevel.INFO, 'License Agent Controller:'+ licAgentsController);
        if(licAgentsController!=null){
            licAgentsController.licenseAgentCountChange();
        }	
        return null;
    }
    
    public PortalControllerLicenseAgents licAgentsController{get;set;}
    
    public Boolean showAssociateOpportunity{get;set;}
    
	public class FieldsRender{
		//public Boolean php{get;set;}
		public Boolean rum{get;set;}
		public Boolean rumAccName{get;set;}
		public Boolean supportProvisioning{get;set;}
		public Boolean controller{get;set;}
		public Boolean macAddress{get;set;}
		public Boolean customURL{get;set;}
		public Boolean eum{get;set;}
		public Boolean coRadiant{get;set;}
		public Boolean saasUsr{get;set;}
		public Boolean saasAcc{get;set;}
		public Boolean saasManual{get;set;}
		public Boolean permLicense{get;set;}
		public Boolean perpLicense{get;set;}
		public Boolean disableEUMAccountNameField{get;set;}
		public Boolean eumSection{get;set;}
		public Boolean isOppsUser{get;set;}
	}
	
	public AbstractLicenseController(){
		super();
	}
	
	public AbstractLicenseController(ApexPages.standardController stdController){
		super(stdController);
	}
	
	public virtual PageReference initAction(){
		License_Opportunity__c licOpp = (License_Opportunity__c) DataLayerConstants.fetchSingle('License_Opportunity__c', 'License__c',inputLicenseId);
		if(licOpp!=null){
			myOpportunity = (Opportunity) DataLayerConstants.fetchSingle('Opportunity', licOpp.Opportunity__c);
			if(!CommonUtil.isPrimaryContactRolePresent(myOpportunity)){
	            PageReference primaryContactRolePage = new PageReference('/apex/PrimaryContactPage?accountId='+myOpportunity.AccountId+'&opportunityId='+myOpportunity.Id+'&noAccPrimary=false&action='+licenseOpcode+'&LicenseId='+inputLicenseId);
	            primaryContactRolePage.setRedirect(false);
	            return primaryContactRolePage;
	        }
		}
		return null;
	} 
	
	public PageReference showPrimaryContactPage(){
    	if(myOpportunity!=null){
    		String retUrl = ApexPages.currentPage().getUrl();
            retUrl=myOpportunity.Id;
            String link = '/p/opp/ContactRoleEditUi/e?oppid='+myOpportunity.Id+'&retURL='+retUrl;
            PageReference ref= new PageReference(link);
            return ref;
    	}
    	return null;
    }
	
	public void initLicenseAndAllLicenseDependencies(String opportunityID){
		licenseDetailObj = (LicenseDetail__c) pageContextObj;
		if(licenseDetailObj!=null){
			if(licenseDetailObj.Id!=null){
        		licenseDetailObj = (LicenseDetail__c) DataLayerConstants.fetchSingle('LicenseDetail__c',licenseDetailObj.Id);
        		deltaValues = true;
			}
		}else{
			licenseDetailObj = new LicenseDetail__c();
			deltaValues = false;
		}
        
		//Initialize License Opportunity
		if(opportunityID==null){
	    	try{
	    		licOpp = [select Id, License__c, Opportunity__c from License_Opportunity__c where License__c=:licenseDetailObj.id];
	    	}catch(Exception e){
	    		//Is a non-sales-led license
				loggerHandle.warn(e.getMessage(),e);
	    	}
			List<Opportunity> opps = CommonUtil.getOpportunitiesForLicense(licenseDetailObj);
	    	
	    	 if(opps!=null && opps.size()>0){
	            myOpportunity = opps.get(0);
	        }
		}else{
			myOpportunity =	(Opportunity)DataLayerConstants.fetchSingle('Opportunity',opportunityID);
		}
		if(myOpportunity!=null && myOpportunity.AccountId!=null){
			try{
				accObj = (Account)DataLayerConstants.fetchSingle('Account',myOpportunity.AccountId+''); 
			}catch(Exception e){
				//showErrorMessage('There is no permission on the Account record associated with this opportunity. Please contact Account owner for the required permissions.');
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'There is no permission on the Account record associated with this opportunity. Please contact Account owner for the required permissions.');
            	ApexPages.addMessage(myMsg);
			}
			aduaContactsHelper = AccountContactsADUAHelper.newInstance(null,myOpportunity,licenseDetailObj);  
        	licenseContacts = aduaContactsHelper.licenseContacts;//LicenseUtil.getContacts(licenseDetailObj, myOpportunity,accObj,false);
        	showAssociateOpportunity = false;
		}else{
			//TODO Initialize from License contacts
			//Initialize License Contacts
			aduaContactsHelper = AccountContactsADUAHelper.newInstance(null,null,licenseDetailObj);  
        	licenseContacts = aduaContactsHelper.licenseContacts;//LicenseUtil.getContacts(licenseDetailObj, myOpportunity,accObj,false);
    		//licContacts = LicenseUtil.getLicenceContacts(licenseDetailObj,null,null,false);
			if(licenseContacts!=null && licenseContacts.size()>0){
				String accId = licenseContacts.get(0).ContactObj.AccountId;
				accObj = (Account)DataLayerConstants.fetchSingle('Account',accId);
			}
			showAssociateOpportunity = true;
		}
    	//Initialize License Sys
        try{
    		licSys = [select Id, License__c, System__c from License_System__c where License__c=:licenseDetailObj.id];
    	}catch(Exception e){
    		//Is a new License	
    	}
    	if(licSys==null){
    		licSys = new License_System__c(License__c=licenseDetailObj.id);
			//insert licenseSystem; -- Should not insert on load.. Should be inserted in doPreSave
    	}
    	
    	//Initialize License Contacts
    	//licContacts = LicenseUtil.getLicenceContacts(licenseDetailObj,myOpportunity,accObj,false);
    	//Initialize Self-Service Contacts -- This needs cleanup
    	//This is not needed - We should not have dependency on License to contact for self-service licenses seperately than other licenses
    	try{
        	List<License_Contacts__c>selfServiceContacts = [Select Contact__r.Id,Contact__r.Name,Contact__r.Email,License__r.Id from License_Contacts__c where License__c=:licenseDetailObj.Id and Contact_Type__c='SELF_SERVICE' limit 1];
        	if(selfServiceContacts!=null){
        		selfServiceContact = ((License_Contacts__c)selfServiceContacts.get(0)).Contact__r;
        		showSelfService=true;
        	}
        }catch(Exception e){
            loggerHandle.warn(e.getMessage(),e);
        }
        //Initialize Agents
        licAgentInfoList = LicenseUtil.getLicenseAgentInfoList(licenseDetailObj, BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
        initializeUILicenseAgents();
        
        /*
        	New EUM code.  
        */
        try{  
        	licenseEUMDetails = (License_EUM_Details__c)DataLayerConstants.fetchSingleWithWhereClause('License_EUM_Details__c', ' where License__c = \''+licenseDetailObj.Id+'\' and License__c!=null');
        	eumInput = LicenseUtil.getEUMLicenseInput(licenseEUMDetails);
        	if(eumInput.eumDetails == null || (eumInput.eumDetails!=null && eumInput.eumDetails.AccountName__c == null && eumInput.eumDetails.Access_Key__c == null)){
        		selectedEUMAccountType = 'newEUMAccount';
        		disableEUMOption1 = false;
        	}else{
        		selectedEUMAccountType = 'oldEUMAccount';
        		disableEUMOption1 = true;
        	}
        }catch(Exception  e){
        	eumInput = LicenseUtil.getEUMLicenseInput(licenseEUMDetails);
        	selectedEUMAccountType = 'newEUMAccount';
        	disableEUMOption1 = false;
          loggerHandle.warn(e.getMessage(),e);
        }
	}
	
	public void initializeUILicenseAgents(){
		uiLicAgents = new list<PortalDataType.LicenseAgentInfo>();
        categoryBasedLicenseAgentsForUI = new map<String,list<PortalDataType.LicenseAgentInfo>>();
        boolean isPro = false;
        if(licenseDetailObj.Stage__c!=null && licenseDetailObj.Stage__c.contains('PAID')){
        	isPro = true;
        }
        boolean isPaidOperation = false;
        if(licenseOpcode==BackendConstants.OPCODE_ADD_LICENSE || licenseOpcode==BackendConstants.OPCODE_TRANSITION_TO_PERMANENT){
            isPro = true;
            isPaidOperation = true;
        }
        String productType = licenseDetailObj.Product_Type__c;
        for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgentInfoList){
            if(licAgentInfo.selectedProductEdition!=null){
                if(licenseDetailObj.Product_Type__c!=null && licenseDetailObj.Product_Type__c.equals('On-Premise')){
                    licAgentInfo.licAgent.Licensing_Model__c =PortalDataType.LICENSING_MODEL_FIXED;
                }
                if(isPro){
                    licAgentInfo.enableEdition= licAgentInfo.licAgent.Count__c>0;
                    if(!licAgentInfo.enableEdition || isPaidOperation){
                    	licAgentinfo.selectedProductEdition = PortalDataType.EDITION_PRO;
                    }
                }
            }
            
            licAgentInfo.isVisible = (productType!=null)?BackendConstants.LICENSE_AGENT_VISIBILITY_MAP.get(productType).get(licAgentInfo.licAgent.Agent_Type__c):true;
            System.debug(productType+' AgentType:'+licAgentInfo.licAgent.Agent_Type__c+' ISVISIBLE:'+licAgentInfo.isVisible);
            if(licAgentInfo.isVisible!=null && licAgentInfo.isVisible){
                for(String agentCategory:BackendConstants.LICENSE_AGENT_CATEGORIES){
                    if(agentCategory.equals(licAgentInfo.licAgent.Category__c)){
                        List<PortalDataType.LicenseAgentInfo> agents = categoryBasedLicenseAgentsForUI.get(agentCategory);
                        if(agents == null){
                            agents = new List<PortalDataType.LicenseAgentInfo>();
                            categoryBasedLicenseAgentsForUI.put(agentCategory,agents);
                        }
                        agents.add(licAgentInfo);
                    }
                    uiLicAgents.add(licAgentInfo);
                }
            }
        }
    }
    
    public Integer licenseOpcode{get;set;}
    public override virtual void init(){
        super.init();
        if(licenseDetailObj ==null){
            licenseDetailObj = new LicenseDetail__c();
        }
    }
    
    public override virtual Boolean validateObject(){
        if(licenseDetailObj!=null){
            return ValidatorUtil.validate(licenseDetailObj, licenseOpcode);
        }
        return true;
    }
    
    public override virtual Boolean doPreSave(){
        String backendResponse='';
        backendResponse= backend.getResponse(licenseOpcode);
        licenseDetailObj.BackendStatus__c = 'Response for OPCODE:'+licenseOpcode+' = '+backendResponse;
        if(backendResponse!=null){
            try{
                CommonUtil.updateLicenseResponse(backendResponse, licenseDetailObj, eumInput.eumDetails);
            }catch(Exception e){
                licenseDetailObj.BackendStatus__c = 'Exception:'+e+' for License Backend call\n Response:'+backendResponse+' \n Request URL:'+backend.restAPIObj.serviceURL;
                EmailUtil.notifyError(backend.getErrorMessage(true),BackendConstants.BACKEND_ERROR_SUBJECT);    
             loggerHandle.error(e.getMessage(),e); 
            }
        }
        if(backend.restAPIObj!=null){
            licenseDetailObj.BackendStatus__c= backend.restAPIObj.serviceURL+'\n Req:'+backend.restAPIObj.requestBody;
        }
        licenseDetailObj.LastOpcode__c = licenseOpcode;
        return true;
    }
    
    public override virtual PageReference doPostSave(){
        if(licenseDetailObj!=null && licenseDetailObj.Id!=null){
            /*
            * Calling saveLicenseHistory method from LicenseUtil to save old and new state in License History Tracking object.
            */
            try{
                System.debug('Triggering saveHistory');
                //LicenseUtil.saveHistory(oldLicenseState,'IN_PROGRESS',deltaValues);
                LicenseUtil.saveHistory(oldLicenseState,relationalLicenseHistoryMap,'IN_PROGRESS',deltaValues);
            }catch(Exception e){
                EmailUtil.notifyError(e, null);
                loggerHandle.error(e.getMessage(),e);
            }
            try{
                if(ApexPages.currentPage().getUrl().contains('LicenseProvision_FreeTrial40') || 
                	ApexPages.currentPage().getUrl().contains('LicenseProvision_Paid40') ||
                	ApexPages.currentPage().getUrl().contains('LicenseProvision_Upgrade40') ||
                	ApexPages.currentPage().getUrl().contains('LicenseProvision_Extend40') ||
                	ApexPages.currentPage().getUrl().contains('LicenseProvision_Modify40')
                	){
                    Pagereference ref = new PageReference('/apex/ViewLicensePage40?id='+licenseDetailObj.Id);
                    ref.setRedirect(false);
                    return ref;
                }
            }catch(Exception e){
                
            }
            Pagereference ref = new PageReference('/'+licenseDetailObj.Id);
            ref.setRedirect(false);
            return ref;
        }
        return null;
    }
    
    public override virtual PageReference doCancel(){
        if(licenseDetailObj!=null && licenseDetailObj.Id!=null){
            Pagereference ref = new PageReference('/'+licenseDetailObj.Id);
            ref.setRedirect(false);
            return ref;
        }
        return stdController.cancel();
    }
    
    protected Boolean isProLicense(){
        String licenseStage = licenseDetailObj.Stage__c;
        if(licenseStage!=null && licenseStage.contains('PAID')){
            return true;
        }
        return false;
    }
    
    protected Boolean isPaidLicenseOperation(){
        return (licenseOpcode==BackendConstants.OPCODE_ADD_LICENSE || licenseOpcode==BackendConstants.OPCODE_TRANSITION_TO_PERMANENT);
    }
    
    public class LicenseAgentsController{
        public LicenseAgentsController(){
            
        }
    }
    
    public PageReference setEUMLite() {
    	License_Agent__c syntheticAgent = null;
    	System.debug(LoggingLevel.Info,'Inside My Method');
    	for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgentInfoList){
    		if('Synthetic'.equals(licAgentInfo.licAgent.Agent_Type__c)){
    			syntheticAgent = licAgentInfo.licAgent;
    		}
    	}
    	System.debug(LoggingLevel.Info, 'My Method Synthetic:'+syntheticAgent);
		boolean anyInput = eumInput.eumWeb.Type__c!=null || eumInput.eumMobile.Type__c!=null || (syntheticAgent!=null && syntheticAgent.Edition__c!=null);
		System.debug(LoggingLevel.Info, 'My Method:'+anyInput);
		System.debug(LoggingLevel.Info, 'My Method:'+syntheticAgent.Edition__c);
		if(anyInput){
			if(eumInput.eumWeb.Units__c == null){
				eumInput.eumWeb.Units__c = 1;
			}
			if(eumInput.eumMobile.Units__c == null){
				eumInput.eumMobile.Units__c = 1;
			}
            if(syntheticAgent!=null && (syntheticAgent.Count__c ==null || syntheticAgent.Count__c == 0)){
                syntheticAgent.Count__c = 1;
                syntheticAgent.Max_Agents__c = 1;
            }
			if(eumInput.eumWeb.Type__c != 'LITE' && eumInput.eumWeb.Type__c != 'PRO'){
				eumInput.eumWeb.Type__c = 'LITE';
				eumInput.eumWeb.Units__c = 1;
			}
			if(eumInput.eumMobile.Type__c != 'LITE' && eumInput.eumMobile.Type__c != 'PRO'){
				eumInput.eumMobile.Type__c = 'LITE';
				eumInput.eumMobile.Units__c = 1;
			}
			if(syntheticAgent!=null && syntheticAgent.Edition__c != 'LITE' && syntheticAgent.Edition__c!='PRO'){
				syntheticAgent.Edition__c = 'LITE';
				syntheticAgent.Count__c = 1;
				syntheticAgent.Max_Agents__c = 1;
			}
			System.debug(LoggingLevel.INFO, 'EUM MOBILE TYPE:'+eumInput.eumMobile.Type__c);
			System.debug(LoggingLevel.INFO, 'EUM WEB TYPE:'+eumInput.eumWeb.Type__c);
		}
        return null;
    }

    public static testMethod void testSetSynthetic(){
        RESTAPI.unitTestMode = true;
        ApexPages.StandardController sc = new ApexPages.StandardController(new License_Opportunity__c());
        LicenseProvision_FreeTrialController ctrlr = new LicenseProvision_FreeTrialController(sc);  
        LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
        ctrlr.licAgentInfoList = LicenseUtil.getLicenseAgentInfoList(lic, BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
        ctrlr.eumInput = new LicenseEUMInput(new License_EUM_Details__c(), new EUM_Web__c(), new EUM_Mobile__c());
        ctrlr.eumInput.eumWeb.Type__c = 'LITE'; 
        ctrlr.setEUMLite();
    }

    public static testMethod void testSetSynthetic1(){
        RESTAPI.unitTestMode = true;
       ApexPages.StandardController sc = new ApexPages.StandardController(new License_Opportunity__c());
       LicenseProvision_FreeTrialController ctrlr = new LicenseProvision_FreeTrialController(sc);  
       LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
       ctrlr.licAgentInfoList = LicenseUtil.getLicenseAgentInfoList(lic, BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
       ctrlr.eumInput = new LicenseEUMInput(new License_EUM_Details__c(), new EUM_Web__c(), new EUM_Mobile__c());
       ctrlr.eumInput.eumMobile.Type__c = 'LITE'; 
       ctrlr.setEUMLite();
    }

}