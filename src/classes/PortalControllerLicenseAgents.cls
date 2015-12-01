/*
 * Apex Controller for Generic License Agents Component.
 * This controller serves both Detail and Edit flows of license for license agents.
 * This is encapsulated with AbstractLicenseController and used in 
 * both LicenseProvisionController and ViewLicenseController
 */
public with sharing class PortalControllerLicenseAgents {
    
    public Boolean refresh{
        get;
        set{
            refresh = value;
            setLicenseControllerHandler();
        }
    }

	/*
	 * License object for which license agents are being shown or updated.
	 */
	public LicenseDetail__c licenseDetailObj{get;set;}

	private integer licenseOpcode;
	
	/*
	 * Any one of the license provision controller classes for either provision/update/upgrade/change deployment license operations
	 */
	public AbstractLicenseController licenseController{
		get;
		set{
			licenseController = value;
			setLicenseControllerHandler();
			//updateUI();
		}
	}
	
	/*
	 * Initialize the connection between the parent license provision page's controller and this component controller.
	 * Also initialize license and license agent objects from parent page.
	 */
	private void setLicenseControllerHandler(){
		licenseController.licAgentsController = this;
		this.licenseDetailObj = licenseController.licenseDetailObj;
		this.licenseAgents = licenseController.licAgentInfoList;
		this.licenseOpcode = licenseController.licenseOpcode;
	}
	
	/*
	 * Remote action called for JS to get the default licensing model for an edition.
	 * If user has PRO TRIAL edition then return FIXED as default edition.
	 * This is called as AJAX remote function from JS. 
	 * Eventually all the biz logics in all the controllers should be moved in this format.
	 */
	@RemoteAction
	public static String getLicensingModel(String product,String edition, String currentLicensingModel){
		if(PortalDataType.EDITION_PRO_TRIAL.equals(edition)){
			return PortalDataType.LICENSING_MODEL_FIXED;
		}
		return currentLicensingModel;
	}
	
	
	/*
	 * Master List of all license agents for a gicven license object.
	 * Set method is overriden so that whenever there is a change in license agents list, 
	 * the map of category based agents is rebuilt.
	 */
	public list<PortalDataType.LicenseAgentInfo> licenseAgents{get;
		set{
			licenseAgents = value;
			updateCategoryLicenseAgentsMap();
		}
	}
	
	//TODO Need to remove this as this is no longer used
	public Boolean refreshUI{get;set;}
	
	/*
	 * Category based map of License Agents used in the License Agents component
	 */
	public map<String,List<PortalDataType.LicenseAgentInfo>> categoryLicenseAgentsMap{get;set;} 
	
	/*
	 * Map to categorize the license agent objects by Category as APM/ANalytics and EUM (infuture)
	 * This will be used by the repeater component to show up the license agents grid for each of the categories
	 */
	public map<String,PortalDataType.LicenseAgentInfo> agentTypeLicenseAgentsMap{
		get{
			return buildAgentTypeMap(agentTypeLicenseAgentsMap);
		}
		set;
	}
	
	/*
	 * UI property for the List of supported Agent Categories
	 */
	public List<String> licenseAgentCategories{get;set;}
	
	
    /*
     *
     */
    private map<String,PortalDataType.LicenseAgentInfo> buildAgentTypeMap( map<String,PortalDataType.LicenseAgentInfo> localMap){
    	if(localMap == null && categoryLicenseAgentsMap!=null){
	    	localMap = new map<String,PortalDataType.LicenseAgentInfo>();
	    	
			for(list<PortalDataType.LicenseAgentInfo> licAgents:categoryLicenseAgentsMap.values()){
				for(PortalDataType.LicenseAgentInfo licAgent:licAgents){
					localMap.put(licAgent.licAgent.Agent_Type__c,licAgent);
				}
			}
			agentTypeLicenseAgentsMap = localMap;
    	}
    	
    	return localMap;
    }
    
    /*
     *
     */
	private void updateCategoryLicenseAgentsMap(){
		categoryLicenseAgentsMap = new map<String,List<PortalDataType.LicenseAgentInfo>>();
		for(PortalDataType.LicenseAgentInfo licAgentInfo:licenseAgents){
			if(licAgentInfo.isVisible!=null && licAgentInfo.isVisible){
				list<PortalDataType.LicenseAgentInfo> listOfUnits = categoryLicenseAgentsMap.get(licAgentInfo.licAgent.Category__c);
				if(listOfUnits==null){
				 	listOfUnits = new list<PortalDataType.LicenseAgentInfo>();
				 	categoryLicenseAgentsMap.put(licAgentInfo.licAgent.Category__c,listOfUnits);
				} 
				listOfUnits.add(licAgentInfo);
			}
		}
		licenseAgentCategories = new list<String>();
		for(String agentCategory:categoryLicenseAgentsMap.keySet()){
			if(!BackendConstants.LICENSE_AGENT_CATEGORY_EUM.equals(agentCategory)){
				licenseAgentCategories.add(agentCategory);
			}
		}
	}
	
	public PageReference productTypeChange(){
		updateCategoryLicenseAgentsMap();
		return null;
	}
	
	public Boolean showEUMAccountDetails{get;set;}

	/*
	 * Setting Count and Max Count based on the licensing Model
	 *
	 */
	public void licenseAgentCountChange(){
	 	for(PortalDataType.LicenseAgentInfo licAgent:licenseAgents){
		 	if(licAgent!=null){
		 		updateLicenseCountMaxCountForLicModel(licAgent);
		 		updateDataRetention(licAgent);
		 	}
	 	}
        LicenseUtil.calculateApplicationAnalytics(licenseAgents);
	 }
	 
	 /*
	  * Call back action for License Edition change for Product.
	  * If Pro Trial is selected, then set the Licensing Model to Fixed and update the max count accordingly.
	  */
	 public PageReference licenseEditionChange(){
	 	for(PortalDataType.LicenseAgentInfo licAgent:licenseAgents){
		 	if(licAgent!=null){
		 		updateLicensingModelForEdition(licAgent);
				updateLicenseCountMaxCountForLicModel(licAgent);	 		
		 	}
	 	}
        
	 	licenseController.setEumLite();
        
	 	return null;
	 }
	 
	 /*
	  * Setting the license model to Fixed for any thing other than PRO.
	  */
	 private void updateLicensingModelForEdition(PortalDataType.LicenseAgentInfo licAgent){
	 	if(!PortalDataType.EDITION_PRO.equals(licAgent.licAgent.Edition__c)){
	 		licAgent.licAgent.Licensing_Model__c = PortalDataType.LICENSING_MODEL_FIXED;
	 	}
	 }
	 
	 /*
	  * License Model change handler to update count and Max count.
	  */
	 public PageReference licensingModelChange(){
	 	for(PortalDataType.LicenseAgentInfo licAgent:licenseAgents){
		 	if(licAgent!=null){
		 		updateLicenseCountMaxCountForLicModel(licAgent);
		 	}
	 	}
	 	return null;
	 }
	 
	/*
	  * Updates the max count based on the licensing model
	  * Licensing Model == Fixed
	  *		Max Count = Count
	  * Licensing Model == VARIABLE
	  *      Count = 0
	  *      Max Count = DEFAULT TO 100
	  * Licensing Model == OVERAGE
	  *      0 < Count < = 250 : Max Count = count + 250
	  *      Count > 250       : Max Count = 2 * count
	  */
	 /*
	  * If Licensing Model = FIXED
	  *   MAX COUNT = COUNT
	  * IF Licensing MOdel = OVERAGES
	  *   MAX COUNT = COUNT + 250 or COUNT * 2
	  * IF VARIABLE
	  *   COUNT =0
	  *   MAX COUNT = 100
	  */
	 private void updateLicenseCountMaxCountForLicModel(PortalDataType.LicenseAgentInfo licAgent){
 		if(licAgent.isFixedLicensingModel){
 			licAgent.licAgent.Max_Agents__c = licAgent.licAgent.Count__c;
 		}else{
 			if(licAgent.isVariableLicensingModel){
 				licAgent.licAgent.Count__c = 0;
 				licAgent.licAgent.Max_Agents__c = 100;
 			}else if(licAgent.isOverageLicensingModel){
 				if(licAgent.licAgent.Count__c!=null && licAgent.licAgent.Count__c>0){
 					if(licAgent.licAgent.Count__c<=250){
 						licAgent.licAgent.Max_Agents__c = licAgent.licAgent.Count__c + 250;
 					}else{
 						licAgent.licAgent.Max_Agents__c = licAgent.licAgent.Count__c * 2;
 					}
 				}else{
 					licAgent.licAgent.Count__c = 0;
 					licAgent.licAgent.Max_Agents__c = 0;
 				}
 			}
 		}	
	 }
	 
	 private void updateDataRetention(PortalDataType.LicenseAgentInfo licAgent){
	 	if(licAgent.isAnalyticsAgent){
	 		Integer retentionVal = 0;
	 		try{
	 			retentionVal = Integer.valueOf(licAgent.licAgent.Retention_Period__c);
	 		}catch(Exception e){
	 			//DO NOTHING as if the value is non-parsable above default 0 will hold good.
	 		}
	 		if(licAgent.getCount()>0 || licAgent.getMaxCount() > 0){
	 			if(retentionVal==0 || LicenseUtil.isOnPremise(licenseDetailObj)  
	 				|| LicenseUtil.isTrial(licenseDetailObj, licenseOpcode)){
		 			licAgent.licAgent.Retention_Period__c = LicenseUtil.setDataRetentionDefaults(licenseDetailObj, licAgent.licAgent);
		 		}
	 		}
		 	else{
		 		licAgent.licAgent.Retention_Period__c = '0';	
		 	}
	 	}
	 }
	 
	 //Test Methods.
	 //TODO Need to move to test class
	 
	 public static testmethod void testUpdateMaxCount(){
	 	PortalControllerLicenseAgents ctrl = new PortalControllerLicenseAgents();
	 	LicenseDetail__c lic = new LicenseDetail__c();
        List<PortalDataType.LicenseAgentInfo> licAgentInfoList = LicenseUtil.getLicenseAgentInfoList(lic,BackendConstants.OPCODE_ADD_LICENSE);
        ctrl.licenseAgents = licAgentInfoList;
        for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgentInfoList){
        	if('Java'.equals(licAgentInfo.licAgent.Agent_Type__c)){
        		licAgentInfo.licAgent.Licensing_Model__c = PortalDataType.LICENSING_MODEL_OVERAGES;
        		licAgentInfo.licAgent.Count__c = 100;
        	}
        	if('NodeJs'.equals(licAgentInfo.licAgent.Agent_Type__c)){
        		licAgentInfo.licAgent.Licensing_Model__c = PortalDataType.LICENSING_MODEL_OVERAGES;
        		licAgentInfo.licAgent.Count__c = 300;
        	}
        	if('PHP'.equals(licAgentInfo.licAgent.Agent_Type__c)){
        		licAgentInfo.licAgent.Licensing_Model__c = PortalDataType.LICENSING_MODEL_VARIABLE;
        		licAgentInfo.licAgent.Count__c = 0;
        	}
        	if('Database'.equals(licAgentInfo.licAgent.Agent_Type__c)){
        		licAgentInfo.licAgent.Licensing_Model__c = PortalDataType.LICENSING_MODEL_OVERAGES;
        		licAgentInfo.licAgent.Count__c = 0;
        	}
        	if('Machine'.equals(licAgentInfo.licAgent.Agent_Type__c)){
        		licAgentInfo.licAgent.Edition__c = PortalDataType.EDITION_PRO_TRIAL;
        		licAgentInfo.licAgent.Licensing_Model__c = PortalDataType.LICENSING_MODEL_OVERAGES;
        		licAgentInfo.licAgent.Count__c = 10;
        	}
        }
	 	ctrl.licenseAgentCountChange();
	 	ctrl.licensingModelChange();
	 	ctrl.updateCategoryLicenseAgentsMap();
	 	ctrl.licenseEditionChange();
	 	ctrl.buildAgentTypeMap(null);
	 }
	 
	 public static testmethod void testInitialize(){
	 	PortalControllerLicenseAgents ctrl = new PortalControllerLicenseAgents();
	 	
	 	LicenseDetail__c lic = new LicenseDetail__c();
	 	LicenseProvision_FreeTrialController freeTrialController = new LicenseProvision_FreeTrialController(new ApexPages.StandardController(lic));
	 	ctrl.licenseController = null;
	 	ctrl.licenseController = freeTrialController;
	 	ctrl.setLicenseControllerHandler();
	 	ctrl.refreshUI = true;
	 	
        List<PortalDataType.LicenseAgentInfo> licAgentInfoList = LicenseUtil.getLicenseAgentInfoList(lic,BackendConstants.OPCODE_ADD_LICENSE);
        ctrl.licenseAgents = licAgentInfoList;
        ctrl.updateCategoryLicenseAgentsMap();
	 	ctrl.licenseAgentCountChange();
	 	ctrl.licensingModelChange();
	 	ctrl.licenseEditionChange();
	 	ctrl.buildAgentTypeMap(null);
	 }
	 
	 public static testMethod void testGetLicensingMode(){
	 	getLicensingModel('Java','PRO_TRIAL', 'FIXED');
	 	getLicensingModel('Java','PRO', 'FIXED');
	 }
}