public with sharing class HALicenseController extends AbstractLicenseController{
    
    public String eumWebDisplayString{get;set;}
    public String eumMobileDisplayString{get;set;}
    
    public HALicenseController(ApexPages.StandardController stdCtrlr){
        super(stdCtrlr);
    }  
      
    private LicenseDetail__c oldLicense;
    public override virtual void init(){
        super.init();
        loggerHandle.setClassName(HALicenseController.class.getName());
        licenseOpCode = BackendConstants.OPCODE_HA_LICENSE;
        
        inputLicenseId = ApexPages.currentPage().getParameters().get('licenseId');
        if(inputLicenseId!=null){
            licenseDetailObj = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',inputLicenseId);
        }
        eumInput = new LicenseEUMInput(null,null,null);
        if(licenseDetailObj!=null){
            oldLicense = licenseDetailObj;
            List<PortalDataType.LicenseAgentInfo> oldLicAgents = LicenseUtil.getLicenseAgentInfoList(oldLicense,-1);
            licenseDetailObj = LicenseUtil.createHALicense(oldLicense);
            licAgentInfoList = LicenseUtil.copyLicenseAgents(oldLicAgents,false);
            pageContextObj = licenseDetailObj;
            
            /*
            	Handling EUM records, if the licenses has EUM.
            */
            try{  
	        	licenseEUMDetails = (License_EUM_Details__c)DataLayerConstants.fetchSingleWithWhereClause('License_EUM_Details__c', ' where License__c = \''+oldLicense.Id+'\' and License__c!=null');
	        	
				if(licenseEUMDetails!=null){
					eumInput = LicenseUtil.getEUMLicenseInput(licenseEUMDetails);
					eumInput = LicenseUtil.createEUMLicense(eumInput,licenseDetailObj);
					if(eumInput.eumWeb!=null && eumInput.eumWeb.Type__c!=null){
						eumWebDisplayString = eumInput.eumWeb.Units__c+' '+eumInput.eumWeb.Type__c;
						if(eumInput.eumWeb.Units__c > 1){
							eumWebDisplayString +=' units';
						} else {
							eumWebDisplayString +=' unit';
						}
						if(eumInput.eumWeb.Allow_overages__c==false){
							eumWebDisplayString +=' without overages ';	
						} else{
							eumWebDisplayString +=' with overages ';
						}
					}
					if(eumInput.eumMobile!=null && eumInput.eumMobile.Type__c!=null){
						eumMobileDisplayString = eumInput.eumMobile.Units__c+' '+eumInput.eumMobile.Type__c;
						if(eumInput.eumMobile.Units__c > 1){
							eumMobileDisplayString +=' units';
						} else{
							eumMobileDisplayString +=' unit';
						}
						if(eumInput.eumMobile.Allow_overages__c==false){
							eumMobileDisplayString +=' without overages ';	
						} else{
							eumMobileDisplayString +=' with overages ';
						}
					}
				} 
        	}catch(Exception  e){
        		//Here, the flow comes to catch if License_EUM_Details__c query in line 28 fails to return zero records.
	        }
	        
        }
    }
    
    public override virtual Boolean validateObject(){
        if(licenseDetailObj==null){
            errorMessage = 'No License Data available, please try again.';
            return false;
        }
        String macAddress = licenseDetailObj.MAC_Address__c;
        if(macAddress==null || macAddress.trim().equals('')){
            errorMessage = 'Please provide Failover Node MAC Address to proceed with HA license creation.';
            return false;
        }
        if(!ValidatorUtil.isValidMacAddress(macAddress)){
            errorMessage = 'Please a valid MAC Address for failover.';
            return false;
        }
        return true;
    }
    public override virtual Boolean doPreSave(){
        super.doPreSave();
        upsert licenseDetailObj;
        
        /*
        	Inserting EUM records for HALicense.
        */
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
        
        /*
        	Quering oldLicense state to insert details into license history tracking for HALicense 
        	and setting the delta values status.
        */
        oldLicenseState = (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c', licenseDetailObj.id);
        deltaValues = false;
        
        return true;
    }
    public override virtual void setupBackend(){
        backend = new BackendLayer();
        licenseDetailObj.Name = oldLicense.Name+'_HA';
        List<Opportunity> opps = CommonUtil.getOpportunitiesForLicense(oldLicense);
        
        if(opps!=null && opps.size()>0){
            Opportunity opp = opps.get(0);
            accObj = opp.Account;
            List<ContactWrapper> licenseContacts= LicenseUtil.getLicenceContacts(oldLicense, opp, accObj, false);
            
            backend.addBackend(new LicenseBackend(licenseDetailObj,opp,accObj,licAgentInfoList,licenseContacts,eumInput,BackendConstants.OPCODE_HA_LICENSE));
        }
    }
    
    public PageReference doHaSave(){
        PageReference haPageReference = saveObject();
        if(haPageReference!=null){
			licenseDetailObj.Last_License_User__c = Userinfo.getUserId();
			licenseDetailObj.License_Time__c = System.now();        
			upsert licenseDetailObj;
			CommonUtil.copyOpportunities(oldLicense,licenseDetailObj);
			List<License_Agent__c> licAgents = new List<License_Agent__c>();
			try{
                for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgentInfoList){
                    License_Agent__c licAgent = licAgentInfo.licAgent;//new License_Agent__c();
                    if(licAgent.License__c==null){
                        licAgent.License__c=licenseDetailObj.Id;
                    }
                    licAgents.add(licAgent);
				}
				upsert licAgents;
	        }catch(Exception e){
	            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()+'\n'+e.getStackTraceString());
	            ApexPages.addMessage(myMsg);
	        }
	        LicenseUtil.copyLicenseContacts(oldLicense,licenseDetailObj);
        }
        return haPageReference;
    }
    
    public override virtual PageReference doCancel(){
        if(oldLicense!=null && oldLicense.Id!=null){
            PageReference licensePage = new PageReference('/'+oldLicense.Id);
            licensePage.setRedirect(false);
            return licensePage;
        }
        return stdController.cancel();
    }
}