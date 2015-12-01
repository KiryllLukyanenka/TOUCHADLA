global with sharing class PortalDataType {
	public static final String DATE_FORMAT_LICENSE_USAGE='YYYY-MM-DDThh:mm:ssZ';
	public static final String EDITION_PRO='PRO';
	public static final String EDITION_PRO_TRIAL = 'PRO_TRIAL';
	public static final String EDITION_LITE = 'LITE';
	public static final String EDITION_NONE='--None--';
	
	public static final String LICENSING_MODEL_FIXED='FIXED';
	public static final String LICENSING_MODEL_OVERAGES='OVERAGE';
	public static final String LICENSING_MODEL_VARIABLE='VARIABLE';

	
	public class LicenseAgentInfo{
		public LicenseProduct_Metadata__c agentMetadata{get;set;}
		public License_Agent__c licAgent{get;
		set{
			licAgent = value;
			oldLicAgent = new License_Agent__c( Count__c=value.count__c,
												Agent_Type__c = value.Agent_Type__c,
												Max_Agents__c = value.Max_Agents__c,
												Licensing_Model__c = value.Licensing_Model__c,
												Expiration_Date__c = value.Expiration_Date__c
												);
		}}
		
		public String title{
			get{
				return agentMetadata!=null?agentMetadata.Name:licAgent.Agent_Type__c;
			}
		} 
		public String agentUIClassName{
			get{
				if(licAgent!=null){
					if('.NET'.equals(licAgent.Agent_Type__c)){
						return 'NET';
					}else if('C++ Dynamic'.equals(licAgent.Agent_Type__c)){
						return 'CPlusPlusDynamic';
					}else if('C++ SDK'.equals(licAgent.Agent_Type__c)){
						return 'CPlusPlusSDK';
					}else if('C++ Web Server'.equals(licAgent.Agent_Type__c)){
						return 'CPlusPlusWS';
					}
					return licAgent.Agent_Type__c;
				}
				return null;	
			}
		}
		
		public String agentText{get;set;}
		
		public Boolean isVisible{get;set;}
		
		public Boolean isAnalyticsAgent {
			get{
				return (licAgent!=null && BackendConstants.LICENSE_AGENT_CATEGORY_ANALYTICS.equals(licAgent.Category__c));
			}
		}
		
		public Boolean isEUMAgent{
			get{
				return (licAgent!=null && BackendConstants.LICENSE_AGENT_CATEGORY_EUM.equals(licAgent.Category__c));
			}
		}
		
		public List<SelectOption> productEditionSelectOptions{get{
			productEditionSelectOptions = new List<SelectOption>();
			if(BackendConstants.LICENSE_AGENT_CATEGORY_APM.equals(licAgent.Category__c)){
				productEditionSelectOptions.add(new SelectOption(EDITION_LITE,EDITION_LITE));
				productEditionSelectOptions.add(new SelectOption(EDITION_PRO_TRIAL,EDITION_PRO_TRIAL));
				productEditionSelectOptions.add(new SelectOption(EDITION_PRO,EDITION_PRO));
			}else if(BackendConstants.LICENSE_AGENT_CATEGORY_ANALYTICS.equals(licAgent.Category__c)){
				productEditionSelectOptions.add(new SelectOption(EDITION_LITE,EDITION_LITE));
				productEditionSelectOptions.add(new SelectOption(EDITION_PRO_TRIAL,EDITION_PRO_TRIAL));
				productEditionSelectOptions.add(new SelectOption(EDITION_PRO,EDITION_PRO));
			}else if(BackendConstants.LICENSE_AGENT_CATEGORY_EUM.equals(licAgent.Category__c) || 
						BackendConstants.LICENSE_AGENT_CATEGORY_SYNTHETIC.equals(licAgent.Category__c)){
				productEditionSelectOptions.add(new SelectOption('', EDITION_NONE));
				productEditionSelectOptions.add(new SelectOption(EDITION_LITE,EDITION_LITE));
				productEditionSelectOptions.add(new SelectOption(EDITION_PRO,EDITION_PRO));
			}
			return productEditionSelectOptions;
		}set;}
		
		public String selectedProductEdition{
		get{
			/*if(selectedProductEdition==null){
				selectedProductEdition = licAgent.Edition__c;
			}
			return selectedProductEdition;*/
			return licAgent.Edition__c;
		}
		set{
			selectedProductEdition = value;
			if(licAgent!=null){
				licAgent.Edition__c = value;
			}
		}}
		
		public String expirationDate{
			get{
				return licAgent.Expiration_Date__c.format();
			}
		}
		
		public List<SelectOption> productLicensingModelSelectOptions{get{
			productLicensingModelSelectOptions = new List<SelectOption>();
			if(BackendConstants.LICENSE_AGENT_CATEGORY_APM.equals(licAgent.Category__c)){
				productLicensingModelSelectOptions.add(new SelectOption(LICENSING_MODEL_FIXED,LICENSING_MODEL_FIXED));
				productLicensingModelSelectOptions.add(new SelectOption(LICENSING_MODEL_OVERAGES,LICENSING_MODEL_OVERAGES));
				productLicensingModelSelectOptions.add(new SelectOption(LICENSING_MODEL_VARIABLE,LICENSING_MODEL_VARIABLE));
			}else if(BackendConstants.LICENSE_AGENT_CATEGORY_ANALYTICS.equals(licAgent.Category__c)){
				productLicensingModelSelectOptions.add(new SelectOption(LICENSING_MODEL_FIXED,LICENSING_MODEL_FIXED));
			}else if(BackendConstants.LICENSE_AGENT_CATEGORY_EUM.equals(licAgent.Category__c)){
				productLicensingModelSelectOptions.add(new SelectOption(LICENSING_MODEL_FIXED,LICENSING_MODEL_FIXED));
				productLicensingModelSelectOptions.add(new SelectOption(LICENSING_MODEL_OVERAGES,LICENSING_MODEL_OVERAGES));
			}
            else if(BackendConstants.LICENSE_AGENT_CATEGORY_SYNTHETIC.equals(licAgent.Category__c)){
				productLicensingModelSelectOptions.add(new SelectOption(LICENSING_MODEL_FIXED,LICENSING_MODEL_FIXED));
			}            
			return productLicensingModelSelectOptions;
		}set;}
		
		public String selectedProductLicensingModel{
			get{
				return licAgent.Licensing_Model__c;
			}
			set{
				selectedProductLicensingModel = value;
				if(licAgent!=null){
					licAgent.Licensing_Model__c = selectedProductLicensingModel;
				}		
			}
		}
		
		public Map<String,Boolean> fieldEnableMap{
			get{
				if(fieldEnableMap == null){
					fieldEnableMap = new map<String,Boolean>();
				}
				return fieldEnableMap;
			}
			set;
		}
		
		public Map<String,Boolean> fieldVisibleMap{
			get{
				if(fieldVisibleMap == null){
					fieldVisibleMap = new map<String,Boolean>();
				}
				return fieldVisibleMap;
			}
			set;
		}
		
		public Boolean enableEdition{get;set;}
		
		public Boolean enableExpirationDate{get;set;}
		
		public Boolean enableLicensingModel{get;set;}
		public Boolean enableCount{get;set;}
		public Boolean enableMaxCount{get;set;}
		public Boolean enableRetention{get;set;}
		
		public Boolean visibleEdition{get;set;}
		
		public Boolean visibleExpirationDate{get;set;}
		public Boolean visibleLicensingModel{get;set;}
		public Boolean visibleCount{get;set;}
		public Boolean visibleMaxCount{get;set;}
		public Boolean visibleRetention{get;set;}
		
		public Boolean enabled{
			get{
				if(licAgent.Enabled__c!=null){
					return licAgent.Enabled__c;
				}
				return false;
			}
		}
		
		public Boolean isPro{
			get{
				return EDITION_PRO.equals(licAgent.Edition__c);
			}
		}
		
		public Boolean isFixedLicensingModel{
			get{
				return LICENSING_MODEL_FIXED.equalsIgnoreCase(selectedProductLicensingModel);
			}
		}
		
		public Boolean isOverageLicensingModel{
			get{
				return LICENSING_MODEL_OVERAGES.equals(selectedProductLicensingModel);
			}
		}
		
		public Boolean isVariableLicensingModel{
			get{
				return LICENSING_MODEL_VARIABLE.equals(selectedProductLicensingModel);
			}
		}
		public String debugMsg{get;set;}
		public License_Agent__c oldLicAgent{get;set;}
		public LicenseAgentInfo(){}
		public LicenseAgentInfo(LicenseAgentInfo licAgentInfo,Boolean includeLicenseLink){
			License_Agent__c newLicAgent = new License_Agent__c();
	 		newLicAgent.Agent_Type__c = licAgentInfo.licAgent.Agent_Type__c;
	 		newLicAgent.Count__c = licAgentInfo.licAgent.Count__c;
	 		newLicAgent.Expiration_Date__c = licAgentInfo.licAgent.Expiration_Date__c;
	 		newLicAgent.Licensing_Model__c = licAgentInfo.licAgent.Licensing_Model__c;
	 		newLicAgent.Max_Agents__c = licAgentInfo.licAgent.Max_Agents__c;
	 		newLicAgent.Edition__c = licAgentInfo.licAgent.Edition__c;
	 		newLicAgent.Category__c = licAgentInfo.licAgent.Category__c;
	 		newLicAgent.Retention_Period__c = licAgentInfo.licAgent.Retention_Period__c;
	 		if(includeLicenseLink){
	 			newLicAgent.License__c = licAgentInfo.licAgent.License__c;
	 		}
	 		this.agentText = licAgentInfo.agentText;
	 		this.licAgent = newLicAgent;
	 		this.agentMetadata = licAgentInfo.agentMetadata;
	 		this.productEditionSelectOptions = new list<SelectOption>();
		}
		
		private Boolean getMapValue(Map<String,Boolean> fieldMap,String fieldName){
			if(fieldMap.containsKey(fieldName)){
				return fieldMap.get(fieldName);	
			}
			return true;
		}
		
		public Integer getCount(){
			if(licAgent.Count__c!=null && licAgent.Count__c>0){
				try{
					return Integer.valueOf(licAgent.Count__c);
				}catch(Exception e){
				}
			}
			return 0;
		}
		public Integer getMaxCount(){
			if(licAgent.Max_Agents__c!=null && licAgent.Max_Agents__c>0){
				try{
					return Integer.valueOf(licAgent.Max_Agents__c);
				}catch(Exception e){
				}
			}
			return 0;
		}
	}
	
	
	public class LicenseUsageDataUI{
		public LicenseUsageDataUI(LicenseUsage usageFromBackend){
			this.licenseDetailObj = usageFromBackend.licenseDetailObj;
			list<UsageData> usageRecords = usageFromBackend.usageDataList;
			list<AgentUsageRecordUI> uiUsageRecords = new list<AgentUsageRecordUI>();
			if(usageRecords!=null){
				for(UsageData usageDataBkend:usageRecords){
					String usageTimeStr = usageDataBkend.timestamp;
					Datetime usageTime = Datetime.parse(usageTimeStr);
					//TODO format to datetime object
					System.debug(usageTime);
					list<AgentUsage> agentUsageList = usageDataBkend.usageData;
					for(AgentUsage agentUsage:agentUsageList){
						
					}
				}
			}
		}
		
		public LicenseUsageDataUI(){}
		public LicenseDetail__c licenseDetailObj {get;set;}
		public list<AgentUsageRecordUI> usageRecords {get;set;}
	}
	
	public class AgentUsageRecordUI{
		public License_Agent__c licAgent{get;set;}
		public Datetime usageDateTime{get;set;}
		public Integer provisionedCount{get;set;}
		public Integer maxCount {get;set;}
		public Integer usageCount{get;set;}
	} 
	
	
	public class LicenseUsage{
		public LicenseDetail__c licenseDetailObj{get;set;}
		public list<UsageData> usageDataList{get;set;}
	}
	
	public class UsageData{
		public String timestamp;
		public list<AgentUsage> usageData {get;set;}
	}
	
	public class AgentUsage{
		public String agentName{get;set;}
		public Integer usage{get;set;}
	}
	
	
	global class Users{
        public User_License[] users;
    }
    
    global class User_License{
        public String email;
        public String user_id;
        public String company_id;
        public License[] licenses;
    }
    
    global class License{
        public String MacAddress;//MAC_Address__c
        public String ProductType{get;set;}//Product_Type__c
        public String saasPassword;//SaaS_Password__c
        public String created_date;
        public String id;//License_BackendID__c
        public String customerSaasUrl{get;set;}//Custom_URL_Name__c
        public String saasAccount;//SAAS_Account__c
        public String expiryDate{get;set;}//License_Expiry_Date__c
        public String saasUserName;//SaaS_User_Name__c
        public String stage{get;set;} //Stage__c
        public String accessKey; //SaaS_Access_Key__c
        public String customerName;
        
        public String processState; //ProcessState__c
        public String salesforceLicenseID; //ID
        
        public LicenseAgent[] license_agents;//License_Agent__c
        public LicenseEUMDetails license_eum_details;//License_EUM_Details__c
        public LicenseContact[] license_contacts;
        public PortalContact[] contacts;
        public EUMDetails eum;//EUM
    }
    
    global class LicenseAgent{
        public Integer agent_count;//Count__c
        public String agent_type;//Agent_Type__c
    }
    
    global class EUMDetails{
        public String eum_account_name;
        public String eum_access_key;
        public String web_eum_type;
        public Integer web_agent_units;
        public String web_allow_overage;
        public String mobile_type;
        public Integer mobile_agent_units;
        public String mobile_allow_overage;
    }
    
    global class LicenseEUMDetails{
    	public String salesforceEUMID; //ID
    	public String accessKey;//Access_Key__c
    	public String state; //State__c
    }
    
    global class LicenseContact{
    	public String lastName;
    	public String email;
    	public String user_type;
    }
    
    global class PortalContact{
    	public String userID;
    	public String lastName;
    	public String firstName;
    	public String email;
    	public String user_type;
    	public String subscribeSaasNotification;
    	public String subscribeLicenseNotification;
    }
    
    global class Property{
    	public String key{get;set;}
    	public Object value{get;set;}
    }
}