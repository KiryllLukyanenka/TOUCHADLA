public with sharing class AppDConstants {
    
    public static final Integer Backend_Mode_REQ_PARAM = 1;
    public static final Integer Backend_Mode_JSON = 2;
    public static Integer Backend_Mode= Backend_Mode_JSON;
    
    public static final String AppDCompanyName = 'AppDynamics';
    
    public static final String UserType_Internal= 'INTERNAL';
    public static final String UserType_Partner= 'PARTNER';
    public static final String UserType_Customer= 'CUSTOMER';
    
    public static final String PRIVILEGED_USER_GROUP_NAME= 'license-order-ops';
    
    public static final String LICENSE_PRODUCT_TYPE_ON_PREMISE = 'On-Premise';
    public static final String LICENSE_PRODUCT_TYPE_SAAS = 'Hosted (SaaS)';
    public static final String LICENSE_PRODUCT_TYPE_SAAS_LITE = 'Hosted (SaaS Lite)';
    
    public static final Integer DEFAULT_EXPIRY_DATE_ON_PROVISION = 15;
    
    public static final Integer DEFAULT_EXPIRY_DATE_ON_PROVISION_PARTNERS = 30;
	    
    public static Integer getProvisionDefaultDate(){
        return (Userinfo.getUserType().contains('Partner'))? DEFAULT_EXPIRY_DATE_ON_PROVISION_PARTNERS: DEFAULT_EXPIRY_DATE_ON_PROVISION;
    }
    public static Integer getProvisionTrialMaxUnits(){
        return (Userinfo.getUserType().contains('Partner'))? MAX_JAVA_NET_AGENTS : MAX_JAVA_NET_AGENTS_INTERNAL;
    }
    
    public static final Integer MAX_SPLIT_COUNT = 5;
    
    public static final Integer MAX_JAVA_NET_AGENTS = 10;
    public static final Integer MAX_JAVA_NET_AGENTS_INTERNAL = 50;
    
    public static final String ACCESSIBLE_ZENDESK = 'Help Center';
    public static final String ACCESSIBLE_DOCS= 'Online Docs';
    public static final String ACCESSIBLE_DOWNLOADS = 'Download Server';
    public static final String ACCESSIBLE_LMS= 'AppDynamics University';
    public static final String AppDynamics_LMS_Partner_Customers_Account= 'AppDynamics LMS Partner Customers';
    public static final String ACCESSIBLE_FAN_CLUB = 'Community Fan Club';
    public static final String MINDTICKLE_SSO = 'Mindtickle SSO';
	
    public static Map<Integer,String[]> allowedAgentTypes=new Map<Integer,String[]>();
    public static String[] allAgents= new String[]{'Java','.Net','.PHP','Machine'};
    static{
    	allowedAgentTypes.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,allAgents);
    	allowedAgentTypes.put(BackendConstants.OPCODE_PROVISION_FREE_TRIAL,allAgents);
    }
}