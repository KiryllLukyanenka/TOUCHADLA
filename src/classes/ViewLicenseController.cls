/**
 * Class: ViewLicenseController
 * Package: None 
 * Description: This class is used to show Details of the License.
 * Following are the functionalities:
 *  * Viewing the License Details.
 *  * Setting Button rerender properties depending upon the License Product type, opcode and stage.
 *  * Polling to portal to get transaction status.
 *  * Making Rest call to portal to resend License Email to the customer and diable the License.
 */
public with sharing class ViewLicenseController extends AbstractLicenseController{
	private static map<Integer,String> LICENSE_OPCODE_TO_OPERATION_MAP = new map<Integer,String>{ 
	        				BackendConstants.OPCODE_PROVISION_FREE_TRIAL => 'Provision Trial',
	        				BackendConstants.OPCODE_EXTEND_TRIAL => 'Extend Expiration',
	        				BackendConstants.OPCODE_TRANSITION_TO_PERMANENT => 'Upgrade to Paid Permanent',
	        				BackendConstants.OPCODE_SS_CLAIM_LICENSE => 'Claim Self Service License',
	        				BackendConstants.OPCODE_PORTAL_SS_USER_BUYS_AGENTS => 'Pulled the Self-Service License bought by the user',
	        				BackendConstants.OPCODE_PORTAL_SS_USER_UPGRADES_AGENTS => 'Updated the Self-Service License for agent upgrades',
	        				BackendConstants.OPCODE_ADD_LICENSE => 'Provision Paid Permanent',
	        				BackendConstants.OPCODE_HA_LICENSE => 'HA License',
                            BackendConstants.OPCODE_CONVERT_TO_LITE => 'CONVERT_TO_LITE'};
    public LicenseDetail__c haLicenseData{get;set;}
    public String lastOperation{get;set;}
    public String lastOperationUser{get;set;}
    public String eumWebDisplayString{get;set;}  
    public String eumMobileDisplayString{get;set;}
    public BtnRender render{get;set;} 
    public Boolean originalHALicenseShown{get;set;}
    public Boolean enablePoll{get;set;}
    public Boolean disableUnProvision{get;set;}
    public Boolean disableConvertToLite{get;set;}
    public Boolean disableExtendTrial{get;set;}
    public Boolean disableTransitionToPaid{get;set;}
    public Boolean disableTransitionToPaidTemp{get;set;}
    public Boolean disableHA{get;set;}
    public Boolean disableResendBtn{get;set;}
    public Boolean customSaaSURLShown{get;set;}
    public Boolean coRadiantURLShown{get;set;}
    public Boolean productTypeShown{get;set;}
    public Boolean macAddrShown{get;set;}
    public String extendLicenseButtonTitle{get;set;}
    public Boolean showMacAddress{get;set;}
    public Boolean haLicenseShown{get;set;}
    public String saasURL{get;set;}
    public License_Opportunity__c licOpp{get;set;}
    public Contact primaryContact = null;
	public AccountContactsADUAHelper accCtADUAHelper{get;set;}
	public Integer transactionCounter = 0;
    
    /*
     * BtnRender wrapper class is used to maintain UI buttons permission for different profiles in the 
     * License Details Page(ViewLicensePage).
     */
    public class BtnRender{
        public Boolean extend{get;set;}
        public Boolean paidTemp{get;set;}
        public Boolean paid{get;set;}
        public Boolean ha{get;set;}
        public Boolean resend{get;set;}
        public Boolean disable{get;set;}
        public Boolean convertToLite{get;set;}
    } 
        
    /*
     *
     */
    public ViewLicenseController(ApexPages.StandardController stdCtrlr){
        super(stdCtrlr);
    }
    
    /*
     * Here, we are initialize the Button rerender properties depending upon the License Product type, opcode and stage.
     * These properties are used in the License Details UI Page(ViewLicensePage)/ 
     */
    private void initializeBtnRender(){
    	try{
    		boolean convertToLiteEnabled = true;
    		try{
    			convertToLiteEnabled = Boolean.valueOf(EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.ENABLE_CONVERT_TO_LITE));
    		}catch(Exception e){}
        render = new BtnRender();
        if(licenseDetailObj.Stage__c == null){
            licenseDetailObj.Stage__c = 'TRIAL';
        }
        if(!licenseDetailObj.Stage__c.contains('DISABLED')){
            render.extend = LicenseUtil.isOperationSupport(licenseDetailObj,BackendConstants.OPCODE_EXTEND_TRIAL);
			render.disable = LicenseUtil.isOperationSupport(licenseDetailObj,BackendConstants.OPCODE_UNPROVISION_LICENSE);
			render.convertToLite = convertToLiteEnabled && LicenseUtil.isOperationSupport(licenseDetailObj,BackendConstants.OPCODE_UNPROVISION_LICENSE);
			
            if('SELFSERVICE_TRIAL'.equals(licenseDetailObj.Stage__c)){            
            	render.resend = false;
            }else{
            	render.resend = true;
            }
            if(!licenseDetailObj.Product_Type__c.contains('SaaS')){
		render.paidTemp = LicenseUtil.isOperationSupport(licenseDetailObj,BackendConstants.OPCODE_TRANSITION_TO_PERMANENT);
	    }
	    render.paid = LicenseUtil.isOperationSupport(licenseDetailObj,BackendConstants.OPCODE_TRANSITION_TO_PERMANENT);
	    render.ha = false;
            if(licenseDetailObj.Stage__c.contains('EXPIRED')){
            	if(licenseDetailObj.Stage__c.contains('PAID')){
            		render.paidTemp=false;
            		if(licenseDetailObj.Stage__c.contains('PAID_PERMANENT')){
                    	render.paid = false;
                	}
            	}
                
            }else if(licenseDetailObj.Stage__c.contains('PAID')){
                render.paidTemp = false;
                if(licenseDetailObj.Stage__c.contains('PAID_PERMANENT')){
                    render.paid = false;
                }
                render.ha = LicenseUtil.isOperationSupport(licenseDetailObj,BackendConstants.OPCODE_HA_LICENSE);
            }
        }
    	}catch(Exception e){
    		showErrorMessage(e.getMessage()+'\n'+e.getStackTraceString());
    	}
    }
    
   /*
    * Action method is called on page load on ViewLicensePage.vf.
    * Here we do following functionalities:
    *  * Setting Button rerender properties depending upon the License Product type, opcode and stage.
    *  * Building display string for EUM web and mobile.
    *  * Polling to portal to get transaction status.
    *  * Setting the title of the License details page
    *  * Validating the HA License details.
    */
    public override virtual PageReference initAction(){
	    try{
	        licenseOpCode = BackendConstants.OPCODE_VIEW_LICENSE;
	        super.initLicenseAndAllLicenseDependencies(null);
	        pageContextObj = licenseDetailObj;
	        
	        /*
	         * If the License contains EUM then, here we are building display string for EUM web and mobile in ViewLicensePage.	
	         */
	        Integer eumUnits = 0;
	        Boolean overrages = false;
	        
	        if(eumInput.eumWeb!=null && eumInput.eumWeb.Type__c!=null){
	        	eumWebDisplayString = eumInput.eumWeb.Units__c+' '+eumInput.eumWeb.Type__c;
	        	eumWebDisplayString +=(eumInput.eumWeb.Units__c > 1)?' units': ' unit';
	        	eumWebDisplayString +=(eumInput.eumWeb.Allow_overages__c)?' with overages ':' without overages ';
	        }
	        if(eumInput.eumMobile!=null && eumInput.eumMobile.Type__c!=null){
	        	eumMobileDisplayString = eumInput.eumMobile.Units__c+' '+eumInput.eumMobile.Type__c;
	        	eumMobileDisplayString +=(eumInput.eumMobile.Units__c > 1)?' units':' unit';
	        	eumMobileDisplayString +=(eumInput.eumMobile.Allow_overages__c)?' with overages ':' without overages ';
	        } else {
	        	if(eumWebDisplayString!=null && !eumWebDisplayString.trim().equals('')){
	        		eumMobileDisplayString = 'Please the update the license to enable EUM Mobile for the customer.';
	        	}	
	        }
	        
	        /*
			 * Getting the oldLicenseState and this is usefull for IN_PROGRESS and DISABLE license flows.   	
	         */
			oldLicenseState = (LicenseDetail__c) DataLayerConstants.fetchSingle('LicenseDetail__c',licenseDetailObj.Id);
			
	        /*
	         * Here, we are appending ".saas.appdynamics.com" to SAAS URL. 
	         */
	        licAgentInfoList = LicenseUtil.getLicenseAgentInfoList(licenseDetailObj,-1);
	        saasURL = licenseDetailObj.Custom_URL_Name__c+'.saas.appdynamics.com';
	        
	        /*
	         * Setting previous license state opcode.
	         */
			Integer lastOpCode = (licenseDetailObj.LastOpCode__c!=null)?Integer.valueOf(licenseDetailObj.LastOpCode__c):0;
	        
	        /*
	         * Here, we are fetching the details of the user who provisined the last state of the License. 
	         */
	        String licenseUsrId = licenseDetailObj.Last_License_User__c;
	        lastOperationUser = licenseUsrId;
	        if(licenseUsrId!=null){
	            if(Userinfo.getUserId().equals(licenseUsrId)){
	                lastOperationUser = UserInfo.getName();
	            }else{
	            	User lastUsr=null;
	            	try{
	                	lastUsr = [select id,Name from user where Id=:licenseUsrId];
	            	}catch(Exception e){
	            		
	            	}
	                if(lastUsr!=null){
	                    lastOperationUser = lastUsr.Name;
	                }
	            }
	        }
	        																					
	        
	        /*
	         * Fetching the MAC Address of the License. 
	         */
	        String macAddress = licenseDetailObj.MAC_Address__c;
	        
	        /*
	         * Setting the last operation status of the License depending upon the last License opcode. 
	         */
	        lastOperation=LICENSE_OPCODE_TO_OPERATION_MAP.get(lastOpCode);
	        if(lastOpCode == BackendConstants.OPCODE_ADD_LICENSE){
	        	lastOperation = (AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(licenseDetailObj.Product_Type__c) && (macAddress==null || macAddress.trim().equals('')))?'Provision Paid Temp':'Provision Paid Permanent';
	        }else if(lastOpCode == BackendConstants.OPCODE_TRANSITION_TO_PERMANENT){
	        	lastOperation = (AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(licenseDetailObj.Product_Type__c) && (macAddress==null || macAddress.trim().equals('')))?'Upgrade to Paid Temp': 'Upgrade to Paid Permanent';
	        }
	       
	        if(togglebutton == null){
	        	togglebutton = false;
	        }
	        
	        licenseContacts = (togglebutton)? LicenseUtil.getLicenceContacts(licenseDetailObj,null,accObj,true):LicenseUtil.getLicenceContacts(licenseDetailObj,myOpportunity,null,true);
	        
	        /*
	         * Here, we are calling initializeBtnRender() to initialize the Button rerender properties which are used in the ViewLicensePage.
	         */
	        initializeBtnRender();
	        
	        /*
	         * Here, we are setting the enablePoll status depending upon the License status.
	         */
	    	System.debug('Counter : ' + transactionCounter);
	
			transactionCounter = 0;
			enablePoll = true;   	
	    	if(ApexPages.currentPage().getParameters().get('rc') != null) {
		    	transactioncounter = Integer.valueOf(ApexPages.currentPage().getParameters().get('rc')); 
	    	} 

			Integer totalChecks = 0;
			try {
			   	totalChecks = Integer.valueOf(EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.TOTAL_TRANSACTION_CHECKS));
			}
			catch(Exception e) {
				licenseDetailObj.BackendStatus__c = 'Retry attempts value is not an integer. Please contact portal-support for more assistance';
				licenseDetailObj.ProcessState__c = 'FAILED';
				upsert licenseDetailObj;
				totalChecks = 3; //To prevent error msg in ++transactionCounter > totalChecks check
				enablePoll = false;
			}
	    	
	    	System.debug('totalChecks : ' + totalChecks);

	    	if(licenseDetailObj.ProcessState__c == 'FAILED') {
	    		System.debug('Exceeded maximum attempts or json deserialization failed');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,licenseDetailObj.BackendStatus__c);
                ApexPages.addMessage(myMsg);
				
        		enablePoll = false;
        	}
	    	
	    	if((++transactionCounter > totalChecks) &&  (licenseDetailObj.ProcessState__c == 'IN_PROGRESS')) {
	    		enablePoll = false;
	    		licenseDetailObj.ProcessState__c = 'FAILED';
				licenseDetailObj.BackendStatus__c = 'Maximum attempts exceeded. Please contact portal-support for more assistance.';
				upsert licenseDetailObj;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,licenseDetailObj.BackendStatus__c);
                ApexPages.addMessage(myMsg);
	    	}
	    	
	    	if(licenseDetailObj.ProcessState__c == 'SUCCESS') {
        		enablePoll = false;
        	}
	        
	        /*
	         * Setting the title of the License details page(ViewLicensePage).
	         */
	        pageTitle = 'License Detail '+licenseDetailObj.ProcessState__c;
	        
	        /*
	         * Fetching the License Product type.
	         */
	        oldProductType = licenseDetailObj.Product_Type__c;
	        
	        /*
	         * Here, we setting the visibility status of SAAS-URL and Mac-Address fields depending upon the ProductType.
	         * These fields are used in the UI(ViewLicensePage). 
	         */
	        coRadiantURLShown = false;
	        if(AppDConstants.LICENSE_PRODUCT_TYPE_SAAS.equals(oldProductType) || AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE.equals(oldProductType)){
	            customSaaSURLShown=true;
	            macAddrShown = false;
	            if(licenseDetailObj.Is_EUM__c){
	                coRadiantURLShown = true;
	            }
	        }else{
	            customSaaSURLShown=false;
	            macAddrShown =licenseDetailObj.Is_Permanent__c;
	        }
	        
	        /*
	         * Fetching the HA License data.
	         */
	        haLicenseData = LicenseUtil.getHALicense(licenseDetailObj);
	        
	        /*
	         * Checking if the License is HA License. Depending on that we set the visibility status of 
			 * originalHALicense section.
	         */
	        originalHALicenseShown = licenseDetailObj.Is_HA__c;
	        
	        /*
	         * Setting the status of haLicenseShown variable as true/false. 
	         * This variable is used to show/hide HA License details in the UI.
	         */
	        haLicenseShown = haLicenseData!=null;
	        
	        /*
     		 * Depending upon the transaction status(IN_PROGRESS/SUCCESS/FAILED) and logged in user type, we enable/disable UI controls License details Page(ViewLicensePage). 
     		 */
	        String transactionStatus = licenseDetailObj.ProcessState__c;
	        showMacAddress = false;
	        extendLicenseButtonTitle = 'Extend Trial License';
	        if(Userinfo.getUserType().contains('Partner')){
	            disableHA = true;
	            disableUnProvision = true;
	            disableConvertToLite = true;
	            disableExtendTrial = true;
                disableTransitionToPaid = true;
	            disableTransitionToPaidTemp = true;
	        }else{
	            if('IN_PROGRESS'.equals(transactionStatus) || 
	            		(  'FAILED'.equalsIgnoreCase(transactionStatus) && 
	            			(licenseDetailObj.License_BackendID__c==null || ''.equals(licenseDetailObj.License_BackendID__c.trim())
	            			))){
	            				disableAllControls();
	            }
	            else{
	            	enableDisableByStage();
	            }
	        }
    	}catch(Exception ex){
    		EmailUtil.notifyError(ex, licenseDetailObj);
    		showErrorMessage(ex.getMessage()+'\n'+ex.getStackTraceString());
    	}
    	
        return null;
    }  
    
    /*
     * When this method is called we set all the UI Buttons to disable mode. 
     */
    private void disableAllControls(){
        disableExtendTrial = true;
        disableTransitionToPaid = true;
        disableTransitionToPaidTemp = true;
        disableConvertToLite = true;
        disableHA = true;
        disableUnProvision = true;
        disableResendBtn = true;
    }
    
    /*
     * When this method is called we enable/disable UI buttons depending upon the License Stage .
     */
    private void enableDisableByStage(){
    	disableHA = true;
    	disableTransitionToPaid=false;
        disableTransitionToPaidTemp=false;
        if(licenseDetailObj.Stage__c.contains('PAID')){
        	disableTransitionToPaid=licenseDetailObj.Stage__c.contains('PAID_PERMANENT');
            showMacAddress = AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(licenseDetailObj.Product_Type__c);
			disableHA = !AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(licenseDetailObj.Product_Type__c);
        }
        extendLicenseButtonTitle =(licenseDetailObj.Stage__c.contains('PAID'))? 'Extend Paid License':'Extend Trial License';
        disableResendBtn =!AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(licenseDetailObj.Product_Type__c);
        disableConvertToLite = !licenseDetailObj.Stage__c.contains('TRIAL');
    }
    
    /*
     * Here, we make rest call to portal to check the transaction status of a License.  
     * If the call is success we update the history record of the License.
     */
    public PageReference pollForStateCompletion(){
    	try{
    	/*
    	 * Initializing the BackendLayer and adding the LicenseTransactionCheck operation to backend to it.
    	 * And making a rest call to portal.
    	 */
        backend = new BackendLayer();
        backend.addBackend(new LicenseBackend.LicenseTransactionCheck(licenseDetailObj,eumInput));
        
        if(backend.invokeBackend()){
            upsert licenseDetailObj;
            
            /*
			 * Calling updateLicenseHistory method from LicenseUtil to update license history record with
        	 * Transaction status. 	
        	 */
            try{
                System.debug('Triggering updateLicenseHistory');
            	LicenseUtil.updateLicenseHistory(licenseDetailObj, oldLicenseState, licenseDetailObj.ProcessState__c);
            }catch(Exception e){
            	EmailUtil.notifyError(e, null);
            }
            
            pageTitle += 'License Detail Updated ';   
        }else{    
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,backend.getErrorMessage(false));
            ApexPages.addMessage(myMsg);
            upsert licenseDetailObj;  
            EmailUtil.notifyError(backend.getErrorMessage(true),BackendConstants.BACKEND_ERROR_SUBJECT);
        }
    	}catch(Exception e){
    		showErrorMessage(e.getMessage()+'\n'+e.getStackTraceString());
    	}
        
        try{
            if(ApexPages.currentPage().getUrl().contains('ViewLicensePage40')){
                Pagereference ref = new PageReference('/apex/ViewLicensePage40?id='+licenseDetailObj.Id+'&rc='+transactionCounter+'&enablePoll='+enablePoll);
                ref.setRedirect(true);
                return ref;
            }
        }catch(Exception e){
                
        }
        PageReference ref = new PageReference('/apex/ViewLicensePage40?id='+licenseDetailObj.Id+'&rc='+transactionCounter+'&enablePoll='+enablePoll);
        ref.setRedirect(true);
        
        return ref;
    }
    
    /*
     * This is Action method for "Associate to an Opportunity" Button On License Detail Page. 
     * We redirect to "Associate License To Opportunity" page, where we associate Azure License to an Opportunity.
     */
    public PageReference associateLicenseToOpportunity(){
    	PageReference ref = new PageReference('/apex/AssociateLicenseToOpportunity?LicenseId='+licenseDetailObj.Id);
        ref.setRedirect(false);
        return ref;
    }
    
    /*
     * Here, we toggle between License and Account contacts. 
     */
    public PageReference showAllContacts(){
    	this.togglebutton=!toggleButton;
    	licenseContacts = (toggleButton)?LicenseUtil.getLicenceContacts(licenseDetailObj, myOpportunity,accObj,false):LicenseUtil.getLicenceContacts(licenseDetailObj, myOpportunity,null,false);
		return null;
	}
    
    /**
     * Action method for Extend Trial License Button on License Detail Page.
     * 
     * Usage: 
     * VisualForce Page - ViewLicensePage.page
     */
    public PageReference extendTrial(){
        try{
            if(ApexPages.currentPage().getUrl().contains('ViewLicensePage40')){
                Pagereference ref = new PageReference('/apex/LicenseProvision_Extend40?LicenseId='+licenseDetailObj.Id);
                ref.setRedirect(false);
                return ref;
            }
        }catch(Exception e){
                
        }
        //PageReference ref = new PageReference('/apex/LicenseProvision_Extend40?LicenseId='+licenseDetailObj.Id);
        PageReference ref = new PageReference('/apex/LicenseProvision_Extend?LicenseId='+licenseDetailObj.Id);
        ref.setRedirect(false);
        return ref;
    }
    
    /*
     * Action method for "Upgrade to Paid Permanent" License Button on License Detail Page(ViewLicensePage).
     * We redirect to Upgrade License Page.
     */
    public PageReference transitionToPaid(){
        try{
            if(ApexPages.currentPage().getUrl().contains('ViewLicensePage40')){
                Pagereference ref = new PageReference('/apex/LicenseProvision_Upgrade40?LicenseId='+licenseDetailObj.Id);
                ref.setRedirect(false);
                return ref;
            }
        }catch(Exception e){
                
        }
        //PageReference ref = new PageReference('/apex/LicenseProvision_Upgrade40?LicenseId='+licenseDetailObj.Id);
        PageReference ref = new PageReference('/apex/LicenseProvision_Upgrade?LicenseId='+licenseDetailObj.Id);
        ref.setRedirect(false);
        return ref;
    }
    
    /*
     * Action method for "Upgrade to Paid Temp" License Button on License Detail Page(ViewLicensePage).
     * We redirect to Upgrade License Page.
     */
    public PageReference transitionToPaidTemp(){
        try{
            if(ApexPages.currentPage().getUrl().contains('ViewLicensePage40')){
                Pagereference ref = new PageReference('/apex/LicenseProvision_Upgrade40?LicenseId='+licenseDetailObj.Id+'&operation=paid_temp');
                ref.setRedirect(false);
                return ref;
            }
        }catch(Exception e){
                
        }
        //PageReference ref = new PageReference('/apex/LicenseProvision_Upgrade40?LicenseId='+licenseDetailObj.Id+'&operation=paid_temp');
        PageReference ref = new PageReference('/apex/LicenseProvision_Upgrade?LicenseId='+licenseDetailObj.Id+'&operation=paid_temp');
        ref.setRedirect(false);
        return ref;
    }
    
    /*
     * Action method for "HA License" Button on License Detail Page(ViewLicensePage).
     * We redirect to HA License Page.
     */
    public PageReference haLicense(){
        PageReference ref = new PageReference('/apex/HALicensePage?licenseId='+licenseDetailObj.Id);
        ref.setRedirect(false);
        return ref;
    }
    
    /*
     * Action method for "Disable" Button on License Detail Page(ViewLicensePage).
     * We make rest call to portal to diable the License. 
     */
    public PageReference disableAction(){
        licenseOpcode = BackendConstants.OPCODE_UNPROVISION_LICENSE;
        licenseDetailObj.Reason__c = 'Disabled....';
        pageTitle='Disabled';
        PageReference saveObjRef = saveObject();

        return saveObjRef;
    }
    
    
    private boolean disableAccountContacts;
    
    /*
     * Here, we are Setting up the BackendLayer for Disabling the License. 
     */
    public override virtual void setupBackend(){
        backend = new BackendLayer();
        if(licenseOpCode == BackendCOnstants.OPCODE_UNPROVISION_LICENSE || licenseOpCode == BackendCOnstants.OPCODE_CONVERT_TO_LITE){
			backend.addBackend(new LicenseBackend(licenseDetailObj,myOpportunity,accObj,licAgentInfoList,licenseContacts,eumInput,licenseOpcode));
        }
    }
    
    public override virtual Boolean doPreSave(){
    	super.doPreSave();
    	try{
			relationalLicenseHistoryMap = LicenseUtil.getRelationalRecordsMap(oldLicenseState);
    	}catch(Exception e){
    		EmailUtil.notifyError(e, null);
    	}
    	return true;
    }
    
    /*
     * Saving the License contacts with License email notification permissions.
     */
    public PageReference saveLicenseContacts(){
		if(licenseContacts.size() > 0){
			LicenseUtil.updateLicenseContacts(licenseContacts,licenseDetailObj);  
		}
    	return null;
    }
    
    /*
     * Action method for "Resend" Button on License Detail Page(ViewLicensePage).
     * We make rest call to portal to resend License Email to the customer.
     */
    public PageReference resendLicense(){
    	
        try{
            String stage = licenseDetailObj.Stage__c;
            String lastTransactionStatus = licenseDetailObj.ProcessState__c;
            
            if('EXPIRED'.equals(stage) || licenseDetailObj.License_Expiry_Date__c < system.now()){
            	return cancelOperation('Unable to Resend License as the license is Expired.', null);
            }
                        
            Integer lastOpCode =(licenseDetailObj.LastOpcode__c!=null)?Integer.valueOf(licenseDetailObj.LastOpcode__c): -1;
            
            if('FAILED'.equals(lastTransactionStatus)){
                if(licenseDetailObj.License_BackendID__c!=null){
                    lastOpCode = BackendConstants.OPCODE_EXTEND_TRIAL;
                }else{
                	return cancelOperation('Unable to Resend License as the license Provision Failed.', null);
                }
            }
            
            
            
            BackendLayer layer = new BackendLayer();
                        
            /*
            	Reading the license contacts and checking if the primary contact has portal id associated with it.
            	If there is no portal, we are making user call first and then, making resend license call.
            */
            if(licenseContacts!=null && licenseContacts.size() > 0){
            	for(ContactWrapper cw: licenseContacts){
            		if(cw.getIsPrimary()){
            			primaryContact = cw.contactObj;
            			break;
            		}
            	}
            	if(primaryContact!=null){
            		primaryContact = (Contact)DataLayerConstants.fetchSingle('Contact',primaryContact.id+'');
            		if(primaryContact.Contact_Portal_User__r!=null && primaryContact.Contact_Portal_User__r.size()>0){
            			Contact_Portal_User__c cpu = primaryContact.Contact_Portal_User__r.get(0);
            			Account_Portal_Company__c apc = [select id, Company_Portal_Id__c, Account__c from Account_Portal_Company__c where Account__c=:accObj.id limit 1];
            			if(cpu!=null && cpu.User_Portal_Id__c==null){
            				
            				accCtADUAHelper = AccountContactsADUAHelper.newInstance(accObj,primaryContact);
            				ADUAUI aduaUIObj = accCtADUAHelper.contactADUAUIMap.get(primaryContact.ID+'');

            				AccountBackend accBackend = new AccountBackend(accObj,BackendConstants.OPCODE_ADD_COMPANY);
        					layer.addBackend(accBackend);

            				ContactBackend_V2 ctcBackend= new ContactBackend_V2(aduaUIObj.aduaUser,accObj,BackendConstants.OPCODE_ADD_USER);
            				layer.addBackend(ctcBackend);
							
            			}
            		}
            	}
            }
            
            Backend backendObj = LicenseUtil.getLicenseBackend(lastOpCode,licenseDetailObj, myOpportunity, accObj, 
														licAgentInfoList,licenseContacts,eumInput);
            
            
            layer.addBackend(backendObj);
            if(layer.invokeBackend()){
            	/*
            		If there is user call then, we are reading the response and storing the user 
            		portal id.
            	*/
            	try{
            		String ctResponse = layer.getResponse(BackendConstants.OPCODE_ADD_USER);
            		if(ctResponse!=null){
            			JSONObject jsonResponse = new JSONObject(new JSONObject.JSONTokener(ctResponse));
                		System.debug( 'PortalID__c adua'+jsonResponse.getValue(primaryContact.Email).num+'' );
                
						String portalId = jsonResponse.getValue(primaryContact.Email).num+'';
						Contact_Portal_User__c contactPortalUser = (Contact_Portal_User__c)primaryContact.getSObjects(BackendConstants.CONTACT_CHILD_RELATIONAL_NAME).get(0);
            	
		                if(contactPortalUser!=null){
		                	contactPortalUser.User_Portal_Id__c = portalId;
		                	upsert contactPortalUser;
		                }
            		}
            	}catch(Exception e){
            		EmailUtil.notifyError(e, null);
            	}
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'License Email is Succesfully resent.');
                ApexPages.addMessage(myMsg);
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'License Resend Failed due to Server error.');
                ApexPages.addMessage(myMsg);
            }
        }catch(Exception ex){
        	EmailUtil.notifyError(ex, null);
            return cancelOperation('',ex);         
        }
        
        return null;
    }

    public PageReference convertToLite(){
		licenseOpcode = BackendConstants.OPCODE_CONVERT_TO_LITE;
        
        List<License_Agent__c> licAgents = new List<License_Agent__c>();
		licenseDetailObj.Stage__c = 'LITE';
		licenseDetailObj.License_Expiry_Date__c = Date.parse('1/1/2038'); 
        for(PortalDataType.LicenseAgentInfo agent : licAgentInfoList) {
            if(agent != null && agent.licAgent != null){
            	if(agent.licAgent.count__c != 0) {
            		if('Machine'.equals(agent.licAgent.Agent_Type__c) || agent.agentMetadata.Is_Beta__c ){
            			agent.licAgent.Count__c = 0;
                		agent.licAgent.Max_Agents__c = 0;	
            		}else{
            			agent.licAgent.count__c = 1;
               	 		agent.licAgent.Max_Agents__c = 1;	
            		}
               	}
               	if(BackendConstants.LICENSE_AGENT_CATEGORY_ANALYTICS.equals(agent.licAgent.Category__c)){
               		agent.licAgent.Retention_Period__c = '0';
               	}
                agent.licAgent.Licensing_Model__c = 'FIXED';
                agent.licAgent.EDITION__c = 'LITE';
                agent.licAgent.Expiration_Date__c = Date.parse('1/1/2038');
                licAgents.add(agent.licAgent);
            }
        }

        if(eumInput != null) {
            if(eumInput.eumWeb != null && eumInput.eumWeb.Units__c > 0) {
                eumInput.eumWeb.Type__c = 'LITE';
                eumInput.eumWeb.Allow_overages__c = false;
                eumInput.eumWeb.Units__c = 1;
            }
            if(eumInput.eumMobile != null && eumInput.eumMobile.Units__c > 0) {
                eumInput.eumMobile.Type__c = 'LITE';
                eumInput.eumMobile.Allow_overages__c = false;
                eumInput.eumMobile.Units__c = 1;
            }
        }
        
   		PageReference saveObjRef = saveObject(); 
		
		update licenseDetailObj;
		
        upsert licAgents;
        
        if(eumInput != null) {
            if(eumInput.eumWeb != null && eumInput.eumWeb.Units__c > 0) {
                upsert(eumInput.eumWeb);
            }
            if(eumInput.eumMobile != null && eumInput.eumMobile.Units__c > 0) {
                upsert(eumInput.eumMobile);
            }
        }
		return saveObjRef; 
    }
    
    private static testMethod ViewLicenseController initialiseController(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'  ');
    	lic.LastOpCode__c=BACKENDCONSTANTS.OPCODE_ADD_LICENSE;
    	upsert lic;
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	return lp;
    }
    
    
    public static testMethod void testGetLicenseBackend(){
    	ViewLicenseController vc = initialiseController();
    	LicenseUtil.getLicenseBackend(BackendConstants.OPCODE_PROVISION_FREE_TRIAL, vc.licenseDetailObj,vc.myOpportunity, vc.accObj, vc.licAgentInfoList,
								vc.licenseContacts,vc.eumInput);
		LicenseUtil.getLicenseBackend(BackendConstants.OPCODE_ADD_LICENSE, vc.licenseDetailObj,vc.myOpportunity, vc.accObj, vc.licAgentInfoList,
								vc.licenseContacts,vc.eumInput);
		LicenseUtil.getLicenseBackend(BackendConstants.OPCODE_EXTEND_TRIAL, vc.licenseDetailObj,vc.myOpportunity, vc.accObj, vc.licAgentInfoList,
								vc.licenseContacts,vc.eumInput);
		LicenseUtil.getLicenseBackend(BackendConstants.OPCODE_TRANSITION_TO_PERMANENT, vc.licenseDetailObj,vc.myOpportunity, vc.accObj, vc.licAgentInfoList,
								vc.licenseContacts,vc.eumInput);
		LicenseUtil.getLicenseBackend(BackendConstants.OPCODE_HA_LICENSE, vc.licenseDetailObj,vc.myOpportunity, vc.accObj, vc.licAgentInfoList,
								vc.licenseContacts,vc.eumInput);
		vc.licenseDetailObj.Is_HA__c = true;
		LicenseUtil.getLicenseBackend(BackendConstants.OPCODE_HA_LICENSE, vc.licenseDetailObj,vc.myOpportunity, vc.accObj, vc.licAgentInfoList,
								vc.licenseContacts,vc.eumInput);
		LicenseUtil.getLicenseBackend(BackendConstants.OPCODE_ADD_LICENSE, vc.licenseDetailObj,vc.myOpportunity, vc.accObj, vc.licAgentInfoList,
								vc.licenseContacts,vc.eumInput);						
    }
    
    private static testMethod void testAssociateOpportunity(){
    	initialiseController().associateLicenseToOpportunity();
    }
    
    private static testMethod void testShowAllContacts(){
    	initialiseController().showAllContacts();
    }
    
    private static testMethod void testSaveLicenseContacts(){
    	initialiseController().saveLicenseContacts();
    }
    
    /*
     * All the Test Methods for ViewLicenseController.
     */
    private static testMethod void testLastOpCodeProvisionPaid(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'  ');
    	lic.LastOpCode__c=BACKENDCONSTANTS.OPCODE_ADD_LICENSE;
    	upsert lic;
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    }
    
    private static testMethod void testLastOpCodeExtend(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	lic.LastOpCode__c=BACKENDCONSTANTS.OPCODE_EXTEND_TRIAL;
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    }
    
    private static testMethod void testLastOpCodeUPGRADE(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\' ');
    	lic.LastOpcode__c = BACKENDCONSTANTS.OPCODE_TRANSITION_TO_PERMANENT;
    	upsert lic;
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    }
    
    private static testMethod void testLastUserNotLoggedInUser(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\' AND Last_License_User__c!=\''+UserInfo.getUserId()+'\' ');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c=null;
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.initializeBtnRender();
    }
    private static testMethod void testStageNull(){
    	
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\' ');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c=null;
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.initializeBtnRender();
    }
    
    private static testMethod void testExpired(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c='PAID_TEMP_EXPIRED';
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();
    }
    
    private static testMethod void testEnableDisableByStage1(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c='TRIAL';
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();
    }
    
    private static testMethod void testEnableDisableByStage2(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c='TRIAL_EXPIRED';
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();    
    }
    
    private static testMethod void testEnableDisableByStage3(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c='PAID_TEMP';
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();    
    }
    
    private static testMethod void testEnableDisableByStage4(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c='PAID_TEMP_EXPIRED';
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();    
    }
    
    
    private static testMethod void testEnableDisableByStage5(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c='PAID_PERMANENT';
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();    
    }
    
    
    private static testMethod void testEnableDisableByStage6(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c='PAID_PERMANENT_EXPIRED';
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();    
    }
    
    private static testMethod void testEnableDisableByStage7(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c='DISABLED';
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();    
    }
    
    private static testMethod void testEnableDisableByStage8(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
    	lic.Custom_URL_Name__c='TaramsTest_20130402';
    	lic.Stage__c='PAID_PERMANENT';
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();    
    }
    
    private static testMethod void testEnableDisableByStage9(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
    	lic.Custom_URL_Name__c='TestTarams_20130204';
    	lic.Stage__c='TRIAL';
    	upsert lic;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();    
    }
    
    private static testMethod void testEnableDisableByStage10(){
    	Pagereference page = new PageReference('/apex/ViewLicensePage.page');
    	Test.setCurrentPage(page);
    	LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Apexpages.currentPage().getParameters().put('id',lic.Id);
    	lic.Is_EUM__c=true;
    	lic.RUM_Enabled__c=true;
    	lic.Stage__c='PAID_TEMP';
    	upsert lic;
    	List<PortalDataType.LicenseAgentInfo> agentInfoList = LicenseUtil.getLicenseAgentInfoList(lic, -1);
    	List<License_Agent__c> licAgents = new List<License_Agent__c>();
    	for(PortalDataType.LicenseAgentInfo licAgentInfo:agentInfoList){
    		licAgentInfo.licAgent.Count__c=0;
    		if(licAgentInfo.licAgent.License__c==null){
    			licAgentInfo.licAgent.License__c=lic.Id;
    		}
    		licAgents.add(licAgentInfo.licAgent);
    	}
    	upsert licAgents;
    	ViewLicenseController lp = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	lp.initAction();
    	lp.disableAllControls();
    	lp.enableDisableByStage();
    }
    
    static testMethod void testAllButtonCalls(){
    	RESTAPI.unitTestMode=true;
		Opportunity opp = (Opportunity)DataLayerConstants.fetch('Opportunity').get(0);
		ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
		
		LicenseDetail__c lic= new LicenseDetail__c();
    	lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE;
    	lic.License_Expiry_Date__c=System.now().date().addDays(10);
    	lic.Stage__c='PAID_TEMP';
    	upsert lic;
    	License_Opportunity__c licOpp = new License_Opportunity__c();
    	licOpp.License__c=lic.ID;
    	licOpp.Opportunity__c=opp.Id;
    	upsert licOpp;
    	List<License_Agent__c> licAgents = LicenseUtil.getLicenseAgents(lic,LicenseUtil.getSupportedProductsMetadata(),false,1);
    	for(License_Agent__c licAgent:licAgents){
    		licAgent.Count__c=10;
    		licAgent.License__c=lic.Id;
    	}
    	upsert licAgents;
    	Test.setCurrentPage(new ApexPages.Pagereference('/apex/ViewLicensePage'));
    	ViewLicenseController viewCtl = new ViewLicenseController(new ApexPages.Standardcontroller(lic));
    	viewCtl.initAction();
    	viewCtl.extendTrial();
    	viewCtl.transitionToPaid();
    	viewCtl.transitionToPaidTemp();
    	viewCtl.haLicense();
    	RestAPI.unitTestMode=true;
    	viewCtl.resendLicense();
    	viewCtl.disableAction();
    }
}