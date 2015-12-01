public class EnvironmentSettings {
    public static String MICROSOFT_WINDOWS_AZURE_STORE = 'MICROSOFT_WINDOWS_AZURE_STORE';
    public static String backendServerURL = 'backendServerURL';
    public static String apiToken = 'apiToken';
    public static String privateKey = 'privateKey';
    public static String AD_FINANCE_PROFILE_ID = 'AD_FINANCE_PROFILE_ID';
    public static String AD_SALES_OPS_PROFILE_ID = 'AD_SALES_OPS_PROFILE_ID';
    public static String AD_SYS_ADMINISTRATORS_PROFILE_ID = 'AD_SYS_ADMINISTRATORS_PROFILE_ID';
    public static String AD_LMS_PROFILE_ID = 'AD_LMS_PROFILE_ID'; 
    public static String LMS_USER_REG_TO = 'LMS_USER_REG_TO';
    public static String LMS_USER_CC = 'LMS_USER_CC';
    public static String DBTUNA_BCC = 'DBTUNA_BCC';  
    public static String LMS_USER_REG_TEMPLATE_NAME = 'LMS_USER_REG_TEMPLATE_NAME';
    public static String DBTUNA_TEMPLATE_NAME = 'DBTUNA_TEMPLATE_NAME';
    public static String APPDYNAMICS_COMPANY_ID = 'APPDYNAMICS_COMPANY_ID';
    public static String PARTNER_DBTUNALICENSE_LIMIT = 'PARTNER_DBTUNALICENSE_LIMIT';
    public static String ZENDESK_URL = 'ZENDESK_URL';
    public static String SALESFORCE_ERROR_MESSAGE_SUBJECT = 'SALESFORCE_ERROR_MESSAGE_SUBJECT';
    public static String APPDYNAMICS_NOTIFY_ADDRESS = 'APPDYNAMICS_NOTIFY_ADDRESS';
    public static String APPDYNAMICS_NOTIFY_ADDRESS_CC = 'APPDYNAMICS_NOTIFY_ADDRESS_CC';    
    public static String SALESFORCE_ERROR_SUBJECT_LIMIT = 'SALESFORCE_ERROR_SUBJECT_LIMIT';
    public static String SALESFORCE_URL = 'SALESFORCE_URL';
    public static String SUPPORTED_AGENT_TYPES = 'SUPPORTED_AGENT_TYPES';
    public static String ANALYTICS_DEFAULT_DATA_RETENTION = 'ANALYTICS_DEFAULT_DATA_RETENTION';
    public static String TOTAL_TRANSACTION_CHECKS = 'TOTAL_TRANSACTION_CHECKS';
    public static String ANALYTICS_TXN_SAAS_DEFAULT_DATA_RETENTION = 'ANALYTICS_TXN_SAAS_DEFAULT_DATA_RETENTION';
    public static String ANALYTICS_LOG_SAAS_DEFAULT_DATA_RETENTION = 'ANALYTICS_LOG_SAAS_DEFAULT_DATA_RETENTION';
    public static String ANALYTICS_TXN_ON_PREM_DEFAULT_DATA_RETENTION = 'ANALYTICS_TXN_ON_PREM_DEFAULT_DATA_RETENTION';
    public static String ANALYTICS_LOG_ON_PREM_DEFAULT_DATA_RETENTION = 'ANALYTICS_LOG_ON_PREM_DEFAULT_DATA_RETENTION';
	public static String MAX_LIC_CONTACTS = 'MAX_LIC_CONTACTS';
	public static String ENABLE_CONVERT_TO_LITE = 'ENABLE_CONVERT_TO_LITE';
	public static String SYNC_KEY = 'SYNC_KEY';
	public static String BROWSER_ANALYTICS_ON_PREM_DEFAULT_DATA_RETENTION = 'BROWSER_ANALYTICS_ON_PREM_DEFAULT_DATA_RETENTION';
	public static String BROWSER_ANALYTICS_SAAS_DEFAULT_DATA_RETENTION = 'BROWSER_ANALYTICS_SAAS_DEFAULT_DATA_RETENTION';
	public static String MOBILE_ANALYTICS_ON_PREM_DEFAULT_DATA_RETENTION = 'MOBILE_ANALYTICS_ON_PREM_DEFAULT_DATA_RETENTION';
	public static String MOBILE_ANALYTICS_SAAS_DEFAULT_DATA_RETENTION = 'MOBILE_ANALYTICS_SAAS_DEFAULT_DATA_RETENTION';

    
    
    private static Map<String,String> portalPropertyMap;
    
    private static EnvironmentSettings instanceVar;
    public Portal_Settings__c portalSetting;
    public static EnvironmentSettings instance{get{if(instanceVar==null){instanceVar = new EnvironmentSettings();}return instanceVar;}}
    
    private EnvironmentSettings(){
    	
    	String organization;
    	portalPropertyMap = new Map<String,String>();
    	
    	if(UserInfo.getOrganizationId().startsWith('00D80000000MDAy')){ //This is AppDynamics Production Salesforce Organization ID
    		organization = 'Production';
        }else{
        	organization = 'QA';
        }

        try{        
            portalSetting = [select id,Instance__c,(select id,key__c,value__c from Portal_Property__r) from Portal_Settings__c where Instance__c =: organization limit 1];
        }catch(Exception e){
            try{
                portalSetting = initializePortalSettings(organization);
            }catch(Exception ex){
                EmailUtil.notifyError(ex,null);
            }
        }
        for(Portal_Property__c portalProperty: portalSetting.Portal_Property__r){
        	portalPropertyMap.put(portalProperty.key__c,portalProperty.value__c);
        }    	
    }

    private Portal_Settings__c initializePortalSettings(String organization){
        Portal_Settings__c ps =  new Portal_Settings__c(Instance__c=organization);
        insert ps;
        if('Production'.equals(organization)){
            Portal_Property__c pp1 = new Portal_Property__c(key__c='MICROSOFT_WINDOWS_AZURE_STORE',value__c='00180000017RYSK',Portal_Setting__c=ps.id);
            insert pp1;
            Portal_Property__c pp2 = new Portal_Property__c(key__c='backendServerURL',value__c='http://portal.appdynamics.com',Portal_Setting__c=ps.id);
            insert pp2;
            Portal_Property__c pp3 = new Portal_Property__c(key__c='apiToken',value__c='ADSALESFORCE',Portal_Setting__c=ps.id);
            insert pp3;
            Portal_Property__c pp4 = new Portal_Property__c(key__c='privateKey',value__c='c2497f7b1984136281062ec632fa1934',Portal_Setting__c=ps.id);
            insert pp4;
            Portal_Property__c pp5 = new Portal_Property__c(key__c='AD_FINANCE_PROFILE_ID',value__c='00e80000001KCba',Portal_Setting__c=ps.id);
            insert pp5;
            Portal_Property__c pp6 = new Portal_Property__c(key__c='AD_SALES_OPS_PROFILE_ID',value__c='00e80000001KCbk',Portal_Setting__c=ps.id);
            insert pp6;
            Portal_Property__c pp7 = new Portal_Property__c(key__c='AD_SYS_ADMINISTRATORS_PROFILE_ID',value__c='00e80000000kJ3J',Portal_Setting__c=ps.id);
            insert pp7;
            Portal_Property__c pp8 = new Portal_Property__c(key__c='AD_LMS_PROFILE_ID',value__c='00e80000001KDlw',Portal_Setting__c=ps.id);
            insert pp8;
            Portal_Property__c pp9 = new Portal_Property__c(key__c='LMS_USER_REG_TO',value__c='portal-team@appdynamics.com',Portal_Setting__c=ps.id);
            insert pp9;
            Portal_Property__c pp10 = new Portal_Property__c(key__c='LMS_USER_CC',value__c='portal-team@appdynamics.com',Portal_Setting__c=ps.id);
            insert pp10;
            Portal_Property__c pp11 = new Portal_Property__c(key__c='DBTUNA_BCC',value__c='portal-team@appdynamics.com',Portal_Setting__c=ps.id);
            insert pp11;
            Portal_Property__c pp12 = new Portal_Property__c(key__c='LMS_USER_REG_TEMPLATE_NAME',value__c='LMS_Parnter_User_Reg',Portal_Setting__c=ps.id);
            insert pp12;
            Portal_Property__c pp13 = new Portal_Property__c(key__c='DBTUNA_TEMPLATE_NAME',value__c='DBTuna Email',Portal_Setting__c=ps.id);
            insert pp13;
            Portal_Property__c pp14 = new Portal_Property__c(key__c='APPDYNAMICS_COMPANY_ID',value__c='5172',Portal_Setting__c=ps.id);
            insert pp14;
            Portal_Property__c pp15 = new Portal_Property__c(key__c='ZENDESK_URL',value__c='https://appdynamics.zendesk.com',Portal_Setting__c=ps.id);
            insert pp15;
            Portal_Property__c pp16 = new Portal_Property__c(key__c='SALESFORCE_ERROR_MESSAGE_SUBJECT',value__c='[Alert Production] Salesforce Exception',Portal_Setting__c=ps.id);
            insert pp16;
            Portal_Property__c pp17 = new Portal_Property__c(key__c='APPDYNAMICS_NOTIFY_ADDRESS',value__c='portal-team@appdynamics.com',Portal_Setting__c=ps.id);
            insert pp17;
            Portal_Property__c pp18 = new Portal_Property__c(key__c='APPDYNAMICS_NOTIFY_ADDRESS_CC',value__c='portal-team@appdynamics.com',Portal_Setting__c=ps.id);
            insert pp18;
            Portal_Property__c pp19 = new Portal_Property__c(key__c='SALESFORCE_ERROR_SUBJECT_LIMIT',value__c='150',Portal_Setting__c=ps.id);
            insert pp19;
            Portal_Property__c pp20 = new Portal_Property__c(key__c='SALESFORCE_URL',value__c='https://na6.salesforce.com/',Portal_Setting__c=ps.id);
            insert pp20;
            Portal_Property__c pp21 = new Portal_Property__c(key__c='SUPPORTED_AGENT_TYPES',value__c='Java,.NET,PHP,Database,NodeJs,Python,Machine,Log,'+
            'Transaction,EUMWeb,EUMLite',Portal_Setting__c=ps.id);
            insert pp21;
            
            Portal_Property__c pp22 = new Portal_Property__c(key__c='ANALYTICS_DEFAULT_DATA_RETENTION',value__c='90',Portal_Setting__c=ps.id);
            insert pp22;

            Portal_Property__c pp23 = new Portal_Property__c(key__c='TOTAL_TRANSACTION_CHECKS',value__c='7',Portal_Setting__c=ps.id);
            insert pp23;
            Portal_Property__c pp24 = new Portal_Property__c(key__c='ANALYTICS_TXN_SAAS_DEFAULT_DATA_RETENTION',value__c='30',Portal_Setting__c=ps.id);
            insert pp24;
            
            Portal_Property__c pp25 = new Portal_Property__c(key__c='ANALYTICS_LOG_SAAS_DEFAULT_DATA_RETENTION',value__c='7',Portal_Setting__c=ps.id);
            insert pp25;
            
            Portal_Property__c pp26 = new Portal_Property__c(key__c='ANALYTICS_TXN_ON_PREM_DEFAULT_DATA_RETENTION',value__c='90',Portal_Setting__c=ps.id);
            insert pp26;

            Portal_Property__c pp27 = new Portal_Property__c(key__c='ANALYTICS_LOG_ON_PREM_DEFAULT_DATA_RETENTION',value__c='90',Portal_Setting__c=ps.id);
            insert pp27;

            Portal_Property__c pp28 = new Portal_Property__c(key__c='MAX_LIC_CONTACTS',value__c='100',Portal_Setting__c=ps.id);
            insert pp28;
            Portal_Property__c pp29 = new Portal_Property__c(key__c='ENABLE_CONVERT_TO_LITE',value__c='True',Portal_Setting__c=ps.id);
            insert pp29;
            Portal_Property__c pp30 = new Portal_Property__c(key__c='SYNC_KEY',value__c='',Portal_Setting__c=ps.id);
            insert pp30;
            Portal_Property__c pp31 = new Portal_Property__c(key__c='BROWSER_ANALYTICS_ON_PREM_DEFAULT_DATA_RETENTION',value__c='7',Portal_Setting__c=ps.id);
            insert pp31;
            Portal_Property__c pp32 = new Portal_Property__c(key__c='BROWSER_ANALYTICS_SAAS_DEFAULT_DATA_RETENTION',value__c='7',Portal_Setting__c=ps.id);
            insert pp32;
            Portal_Property__c pp33 = new Portal_Property__c(key__c='MOBILE_ANALYTICS_ON_PREM_DEFAULT_DATA_RETENTION',value__c='7',Portal_Setting__c=ps.id);
            insert pp33;
            Portal_Property__c pp34 = new Portal_Property__c(key__c='MOBILE_ANALYTICS_SAAS_DEFAULT_DATA_RETENTION',value__c='7',Portal_Setting__c=ps.id);
            insert pp34;

            
        }else{
            Portal_Property__c pp1 = new Portal_Property__c(key__c='MICROSOFT_WINDOWS_AZURE_STORE',value__c='',Portal_Setting__c=ps.id);
            insert pp1;
            Portal_Property__c pp2 = new Portal_Property__c(key__c='backendServerURL',value__c='https://portal-staging.saastest.appdynamics.com',Portal_Setting__c=ps.id);
            insert pp2;
            Portal_Property__c pp3 = new Portal_Property__c(key__c='apiToken',value__c='ADSALESFORCE',Portal_Setting__c=ps.id);
            insert pp3;
            Portal_Property__c pp4 = new Portal_Property__c(key__c='privateKey',value__c='851e137c7ead9694df4509c110011f2b',Portal_Setting__c=ps.id);
            insert pp4;
            Portal_Property__c pp5 = new Portal_Property__c(key__c='AD_FINANCE_PROFILE_ID',value__c='00e80000001KCba',Portal_Setting__c=ps.id);
            insert pp5;
            Portal_Property__c pp6 = new Portal_Property__c(key__c='AD_SALES_OPS_PROFILE_ID',value__c='00e80000001KPYy',Portal_Setting__c=ps.id);
            insert pp6;
            Portal_Property__c pp7 = new Portal_Property__c(key__c='AD_SYS_ADMINISTRATORS_PROFILE_ID',value__c='00e80000001KPYt',Portal_Setting__c=ps.id);
            insert pp7;
            Portal_Property__c pp8 = new Portal_Property__c(key__c='AD_LMS_PROFILE_ID',value__c='00e80000001KDlw',Portal_Setting__c=ps.id);
            insert pp8;
            Portal_Property__c pp9 = new Portal_Property__c(key__c='LMS_USER_REG_TO',value__c='appdynamics.portal@tarams.com',Portal_Setting__c=ps.id);
            insert pp9;
            Portal_Property__c pp10 = new Portal_Property__c(key__c='LMS_USER_CC',value__c='appdynamics.portal@tarams.com',Portal_Setting__c=ps.id);
            insert pp10;
            Portal_Property__c pp11 = new Portal_Property__c(key__c='DBTUNA_BCC',value__c='appdynamics.portal@tarams.com',Portal_Setting__c=ps.id);
            insert pp11;
            Portal_Property__c pp12 = new Portal_Property__c(key__c='LMS_USER_REG_TEMPLATE_NAME',value__c='LMS_Parnter_User_Reg',Portal_Setting__c=ps.id);
            insert pp12;
            Portal_Property__c pp13 = new Portal_Property__c(key__c='DBTUNA_TEMPLATE_NAME',value__c='DBTuna Email',Portal_Setting__c=ps.id);
            insert pp13;
            Portal_Property__c pp14 = new Portal_Property__c(key__c='APPDYNAMICS_COMPANY_ID',value__c='5172',Portal_Setting__c=ps.id);
            insert pp14;
            Portal_Property__c pp15 = new Portal_Property__c(key__c='ZENDESK_URL',value__c='https://appdynamics1378939022.zendesk.com',Portal_Setting__c=ps.id);
            insert pp15;
            Portal_Property__c pp16 = new Portal_Property__c(key__c='SALESFORCE_ERROR_MESSAGE_SUBJECT',value__c='[Alert] Salesforce Exception',Portal_Setting__c=ps.id);
            insert pp16;
            Portal_Property__c pp17 = new Portal_Property__c(key__c='APPDYNAMICS_NOTIFY_ADDRESS',value__c='appdynamics.portal@tarams.com',Portal_Setting__c=ps.id);
            insert pp17;
            Portal_Property__c pp18 = new Portal_Property__c(key__c='APPDYNAMICS_NOTIFY_ADDRESS_CC',value__c='appdynamics.portal@tarams.com',Portal_Setting__c=ps.id);
            insert pp18;
            Portal_Property__c pp19 = new Portal_Property__c(key__c='SALESFORCE_ERROR_SUBJECT_LIMIT',value__c='150',Portal_Setting__c=ps.id);
            insert pp19;
            Portal_Property__c pp20 = new Portal_Property__c(key__c='SALESFORCE_URL',value__c='https://test.salesforce.com/',Portal_Setting__c=ps.id);
            insert pp20;
            Portal_Property__c pp21 = new Portal_Property__c(key__c='SUPPORTED_AGENT_TYPES',value__c='Java,.NET,PHP,Database,NodeJs,Python,Machine,Log,'+
            'Transaction,EUMWeb,EUMLite,C++ SDK,C++ Web Server,C++ Dynamic',Portal_Setting__c=ps.id);
            insert pp21;
            
            Portal_Property__c pp22 = new Portal_Property__c(key__c='ANALYTICS_DEFAULT_DATA_RETENTION',value__c='90',Portal_Setting__c=ps.id);
            insert pp22;
			
			Portal_Property__c pp23 = new Portal_Property__c(key__c='TOTAL_TRANSACTION_CHECKS',value__c='7',Portal_Setting__c=ps.id);
			insert pp23;
            Portal_Property__c pp24 = new Portal_Property__c(key__c='ANALYTICS_TXN_SAAS_DEFAULT_DATA_RETENTION',value__c='30',Portal_Setting__c=ps.id);
            insert pp24;
            
            Portal_Property__c pp25 = new Portal_Property__c(key__c='ANALYTICS_LOG_SAAS_DEFAULT_DATA_RETENTION',value__c='7',Portal_Setting__c=ps.id);
            insert pp25;
            
            Portal_Property__c pp26 = new Portal_Property__c(key__c='ANALYTICS_TXN_ON_PREM_DEFAULT_DATA_RETENTION',value__c='90',Portal_Setting__c=ps.id);
            insert pp26;

            Portal_Property__c pp27 = new Portal_Property__c(key__c='ANALYTICS_LOG_ON_PREM_DEFAULT_DATA_RETENTION',value__c='90',Portal_Setting__c=ps.id);
            insert pp27;

            Portal_Property__c pp28 = new Portal_Property__c(key__c='MAX_LIC_CONTACTS',value__c='100',Portal_Setting__c=ps.id);
            insert pp28;
            
            Portal_Property__c pp29 = new Portal_Property__c(key__c='ENABLE_CONVERT_TO_LITE',value__c='True',Portal_Setting__c=ps.id);
            insert pp29;

            Portal_Property__c pp30 = new Portal_Property__c(key__c='SYNC_KEY',value__c='',Portal_Setting__c=ps.id);
            insert pp30;

            Portal_Property__c pp31 = new Portal_Property__c(key__c='BROWSER_ANALYTICS_ON_PREM_DEFAULT_DATA_RETENTION',value__c='7',Portal_Setting__c=ps.id);
            insert pp31;
            Portal_Property__c pp32 = new Portal_Property__c(key__c='BROWSER_ANALYTICS_SAAS_DEFAULT_DATA_RETENTION',value__c='7',Portal_Setting__c=ps.id);
            insert pp32;
            Portal_Property__c pp33 = new Portal_Property__c(key__c='MOBILE_ANALYTICS_ON_PREM_DEFAULT_DATA_RETENTION',value__c='7',Portal_Setting__c=ps.id);
            insert pp33;
            Portal_Property__c pp34 = new Portal_Property__c(key__c='MOBILE_ANALYTICS_SAAS_DEFAULT_DATA_RETENTION',value__c='7',Portal_Setting__c=ps.id);
            insert pp34;
			
        }
        return ps;
    }
    
    public String getPropertyValue(String key){
    	if(key == 'SYNC_KEY') {
    		Portal_Property__c syncVal = [select id,key__c,value__c from Portal_Property__c where key__c = 'SYNC_KEY'];
    		return syncVal.value__c;
    	}
    	return portalPropertyMap.get(key);
    }
    
    
    public void setPropertyValue(String key, String value) {
    	String organization;
    	
    	if(UserInfo.getOrganizationId().startsWith('00D80000000MDAy')){ //This is AppDynamics Production Salesforce Organization ID
    		organization = 'Production';
        }else{
        	organization = 'QA';
        }
		Portal_Settings__c portalSetting = [select id,Instance__c,(select id,key__c,value__c from Portal_Property__r) from Portal_Settings__c where Instance__c =: organization limit 1];
		Portal_Property__c prop = [select id,key__c,value__c from Portal_Property__c where key__c = :key];
		prop.value__c = value;
		update prop;
    	
    }
    
    public static testMethod void testInitializePortalSettings(){
        EnvironmentSettings.instance.initializePortalSettings('Production');
        EnvironmentSettings.instance.initializePortalSettings('QA');
    }

    public static testMethod void testEnvironmentSettings(){
		Portal_Settings__c ps = new Portal_Settings__c(Instance__c='Production');
		insert ps;
		Portal_Property__c pp1 = new Portal_Property__c(key__c='MICROSOFT_WINDOWS_AZURE_STORE',value__c='',Portal_Setting__c=ps.id);
		insert pp1;
		Portal_Property__c pp2 = new Portal_Property__c(key__c='backendServerURL',value__c='http://portal-staging.saastest.appdynamics.com',Portal_Setting__c=ps.id);
		insert pp2;
		Portal_Property__c pp3 = new Portal_Property__c(key__c='apiToken',value__c='ADSALESFORCE',Portal_Setting__c=ps.id);
		insert pp3;
		Portal_Property__c pp4 = new Portal_Property__c(key__c='privateKey',value__c='851e137c7ead9694df4509c110011f2b',Portal_Setting__c=ps.id);
		insert pp4;
		Portal_Property__c pp5 = new Portal_Property__c(key__c='AD_FINANCE_PROFILE_ID',value__c='00e80000001KCba',Portal_Setting__c=ps.id);
		insert pp5;
		Portal_Property__c pp6 = new Portal_Property__c(key__c='AD_SALES_OPS_PROFILE_ID',value__c='00e80000001KCbk',Portal_Setting__c=ps.id);
		insert pp6;
		Portal_Property__c pp7 = new Portal_Property__c(key__c='AD_SYS_ADMINISTRATORS_PROFILE_ID',value__c='00e80000000kJ3J',Portal_Setting__c=ps.id);
		insert pp7;
		Portal_Property__c pp8 = new Portal_Property__c(key__c='AD_LMS_PROFILE_ID',value__c='00e80000001KDlw',Portal_Setting__c=ps.id);
		insert pp8;
		Portal_Property__c pp9 = new Portal_Property__c(key__c='LMS_USER_REG_TO',value__c='appdynamics.portal@tarams.com',Portal_Setting__c=ps.id);
		insert pp9;
		Portal_Property__c pp10 = new Portal_Property__c(key__c='LMS_USER_CC',value__c='appdynamics.portal@tarams.com',Portal_Setting__c=ps.id);
		insert pp10;
		Portal_Property__c pp11 = new Portal_Property__c(key__c='DBTUNA_BCC',value__c='appdynamics.portal@tarams.com',Portal_Setting__c=ps.id);
		insert pp11;
		Portal_Property__c pp12 = new Portal_Property__c(key__c='LMS_USER_REG_TEMPLATE_NAME',value__c='LMS_Parnter_User_Reg',Portal_Setting__c=ps.id);
		insert pp12;
		Portal_Property__c pp13 = new Portal_Property__c(key__c='DBTUNA_TEMPLATE_NAME',value__c='DBTuna Email',Portal_Setting__c=ps.id);
		insert pp13;
		Portal_Property__c pp14 = new Portal_Property__c(key__c='APPDYNAMICS_COMPANY_ID',value__c='5172',Portal_Setting__c=ps.id);
		insert pp14;
		Portal_Property__c pp15 = new Portal_Property__c(key__c='ZENDESK_URL',value__c='https://appdynamics1378939022.zendesk.com',Portal_Setting__c=ps.id);
		insert pp15;
		Portal_Property__c pp16 = new Portal_Property__c(key__c='SALESFORCE_ERROR_MESSAGE_SUBJECT',value__c='[Alert] Salesforce Exception',Portal_Setting__c=ps.id);
		insert pp16;
		Portal_Property__c pp17 = new Portal_Property__c(key__c='APPDYNAMICS_NOTIFY_ADDRESS',value__c='appdynamics.portal@tarams.com',Portal_Setting__c=ps.id);
		insert pp17;
		Portal_Property__c pp18 = new Portal_Property__c(key__c='APPDYNAMICS_NOTIFY_ADDRESS_CC',value__c='appdynamics.portal@tarams.com',Portal_Setting__c=ps.id);
		insert pp18;
		Portal_Property__c pp19 = new Portal_Property__c(key__c='SALESFORCE_ERROR_SUBJECT_LIMIT',value__c='150',Portal_Setting__c=ps.id);
		insert pp19;
		Portal_Property__c pp20 = new Portal_Property__c(key__c='SALESFORCE_URL',value__c='https://cs3.salesforce.com/',Portal_Setting__c=ps.id);
		insert pp20;
		
		Portal_Property__c pp21 = new Portal_Property__c(key__c='SUPPORTED_AGENT_TYPES',value__c='Java,.NET,PHP,Database,NodeJs,Python,Machine,Log,'+
		'Transaction,EUMWeb,EUMLite',Portal_Setting__c=ps.id);
		insert pp21;
		
		Portal_Property__c pp22 = new Portal_Property__c(key__c='ANALYTICS_DEFAULT_DATA_RETENTION',value__c='90',Portal_Setting__c=ps.id);
		insert pp22;

		Portal_Property__c pp23 = new Portal_Property__c(key__c='TOTAL_TRANSACTION_CHECKS',value__c='3',Portal_Setting__c=ps.id);
		insert pp23;
		
    }
    
}