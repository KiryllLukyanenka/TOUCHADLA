public with sharing class BackendConstants {
    public static final String DOWNLOAD_ZONE_SAAS_PUBLIC = 'saas-public';
    public static final String DOWNLOAD_ZONE_ON_PREMISE_PUBLIC= 'onpremise-public';
    public static final String DOWNLOAD_ZONE_ON_PREMISE_INTERNAL= 'onpremise-internal';
    public static final String DOWNLOAD_ZONE_AZURE= 'partners-azure';
    public static final String DOWNLOAD_ZONE_ON_PREMISE_BETA= 'onpremise-beta';
    public static final String DOWNLOAD_ZONE_DB_ON_PREMISE_PUBLIC= 'onpremise-appd4db';
    
    public static final String BACKEND_ERROR_SUBJECT = 'Backend error';
    
    public static final String ACCOUNT_CHILD_RELATIONAL_NAME = 'Account_Portal_Company__r';
    public static final String CONTACT_CHILD_RELATIONAL_NAME = 'Contact_Portal_User__r';
    
    public static final Integer BACKEND_PARAM_TYPE_NORMAL = 3;
    public static final Integer BACKEND_PARAM_TYPE_CHAIN_RESPONSE= 4;
    public static final Integer BACKEND_PARAM_TYPE_URL_APPEND= 5;
    public static final Integer BACKEND_PARAM_TYPE_LIST_OF_BACKEND= 7;
    public static final Integer BACKEND_PARAM_TYPE_BACKEND= 8;
      
    public static final String SERVER_URL = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.backendServerURL);//'http://sfqa.appdynamics.com';
    
    public static final Integer BACKEND_PARAM_TYPE_SIMPLE = 0;
    public static final Integer BACKEND_PARAM_JSON  = 1;
    public static final Integer BACKEND_PARAM_JSON_ARRAY = 2;
    public static final Integer BACKEND_PARAM_INT_VALUE= 6;
    public static final Integer BACKEND_PARAM_BOOLEAN_VALUE= 9;
    
    public static final String REQ_METHOD_POST = 'POST';
    public static final String REQ_METHOD_DELETE= 'DELETE';
    public static final String REQ_METHOD_GET= 'GET';
    
    public static final Integer OPCODE_ADD_COMPANY = 0;
    public static final Integer OPCODE_ADD_USER = 1;
    public static final Integer OPCODE_SEND_ADUA_ID = 2;
    public static final Integer OPCODE_DELETE_USER = 3;
    
    public static final Integer OPCODE_PROVISION_FREE_TRIAL= 4;
    public static final Integer OPCODE_EXTEND_TRIAL = 5;
    public static final Integer OPCODE_TRANSITION_TO_PERMANENT = 6;
    public static final Integer OPCODE_SEND_LIC_ID= 8;
    public static final Integer OPCODE_ADD_LICENSE= 9;
    public static final Integer OPCODE_SPLIT_LICENSE= 10;
    public static final Integer OPCODE_HA_LICENSE= 11;
    public static final Integer OPCODE_UNPROVISION_LICENSE= 12;
    public static final Integer OPCODE_VIEW_LICENSE= 13;
    
    public static final Integer OPCODE_GET_CONTROLLERS= 14;
    
    public static final Integer OPCODE_GET_LICENSES_CONTROLLER= 15;
    
    public static final Integer OPCODE_GET_LIC_TRANSACTION_STATE= 16;

    public static final Integer OPCODE_EXPIRE_LICENSE= 17;
    
    public static final Integer OPCODE_SEND_EXPIRY_REMINDER= 18;
    
    public static final Integer OPCODE_RESET_SAAS_PASSWORD = 19;
    
    public static final Integer OPCODE_DELETE_COMPANY = 20;
    
    public static final Integer OPCODE_DBTUNA_PROVISION = 21; 
    
    public static final Integer OPCODE_SS_FILTER_CONTACTS = 22;
    
    public static final Integer OPCODE_SS_GET_LICENSE=23;
    
    public static final Integer OPCODE_SS_CLAIM_LICENSE = 24;
    
    public static final Integer OPCODE_RUM_ACCOUNT_NAME_UPDATE = 25;
    
    public static final Integer OPCODE_PORTAL_GET_LICENSE = 26; 
    
    public static final Integer OPCODE_PORTAL_SS_USER_BUYS_AGENTS=27; 
    public static final Integer OPCODE_PORTAL_SS_USER_UPGRADES_AGENTS = 28; 
    public static final Integer OPCODE_CONVERT_TO_LITE = 29;
    
    public static final Integer OPCODE_GET_LICENSE_METADATA = 30;
    public static final Integer OPCODE_PROVISION_LICENSE = 31;
    public static final Integer OPCODE_MODIFY_LICENSE= 32;
    public static final Integer OPCODE_DISABLE_LICENSE = 33;
    public static final Integer OPCODE_GET_LICENSE = 34;
    public static final Integer OPCODE_GET_LICENSE_OPERATION_STATUS = 35;
    
    public static final Map<Integer,String> OPCODE_TO_OPERATION_MAP = new Map<Integer,String>{
        OPCODE_PROVISION_FREE_TRIAL => 'PROVISION_TRIAL',
        OPCODE_ADD_LICENSE => 'PROVISION_PAID',
        OPCODE_EXTEND_TRIAL => 'EXTEND_TRIAL',
        OPCODE_TRANSITION_TO_PERMANENT => 'UPGRADE_TO_PAID',
        OPCODE_UNPROVISION_LICENSE => 'DISABLE',
        OPCODE_HA_LICENSE => 'PROVISION_HA_LICENSE',
        OPCODE_CONVERT_TO_LITE => 'CONVERT_TO_LITE' 
    };
    
    public static final Map<String,String> AGENT_TYPE_BACKEND_MAP = new Map<String,String>{
		'Java' => 'Java',
    	'.NET' => '.Net',
    	'PHP' => 'PHP',
    	'NodeJs' => 'NodeJs',
    	'Log' => 'LogAnalytics',
    	'Transaction' => 'TransactionAnalytics',
    	'Database' => 'Database',
    	'Machine' => 'Machine',
    	'EUMMobile' => 'EUMWeb',
		'EUMWeb' => 'EUMMobile',
		'Python' => 'Python',
		'C++ SDK' => 'CPlusPlusSDK',
		'C++ Web Server' => 'CPlusPlusWS',
		'C++ Dynamic' => 'CPlusPlusDynamic'
    };
    /*
    	This map is used to mantains dispaly name for each download zone.
    */
    public static final Map<String,String> DOWNLOAD_ZONES_MAP = new Map<String,String>(); 
    static{
    	DOWNLOAD_ZONES_MAP.put(DOWNLOAD_ZONE_SAAS_PUBLIC,'AD Pro - SAAS');
    	DOWNLOAD_ZONES_MAP.put(DOWNLOAD_ZONE_ON_PREMISE_PUBLIC,'AD Pro - On Premise');
    	DOWNLOAD_ZONES_MAP.put(DOWNLOAD_ZONE_ON_PREMISE_INTERNAL,'Pro Internal');
    	DOWNLOAD_ZONES_MAP.put(DOWNLOAD_ZONE_AZURE,'Azure');
    	DOWNLOAD_ZONES_MAP.put(DOWNLOAD_ZONE_ON_PREMISE_BETA,'Beta Release Versions');
    	DOWNLOAD_ZONES_MAP.put(DOWNLOAD_ZONE_DB_ON_PREMISE_PUBLIC,'AppDynamics for Databases');
	}
	
    /*
    	This map is used to manitain zone enable status for partner on each download zone.
    */
    public static final Map<String,Boolean> IS_DOWNLOAD_ZONE_ENABLED_FOR_PARTNER = new Map<String,Boolean>();
    static{
    	IS_DOWNLOAD_ZONE_ENABLED_FOR_PARTNER.put(DOWNLOAD_ZONE_SAAS_PUBLIC,true);
    	IS_DOWNLOAD_ZONE_ENABLED_FOR_PARTNER.put(DOWNLOAD_ZONE_ON_PREMISE_PUBLIC,true);
    	IS_DOWNLOAD_ZONE_ENABLED_FOR_PARTNER.put(DOWNLOAD_ZONE_ON_PREMISE_INTERNAL,false);  
    	IS_DOWNLOAD_ZONE_ENABLED_FOR_PARTNER.put(DOWNLOAD_ZONE_AZURE,false);
    	IS_DOWNLOAD_ZONE_ENABLED_FOR_PARTNER.put(DOWNLOAD_ZONE_ON_PREMISE_BETA,false);
    	IS_DOWNLOAD_ZONE_ENABLED_FOR_PARTNER.put(DOWNLOAD_ZONE_DB_ON_PREMISE_PUBLIC,true);
    }
    
    /*
    	This map is used to mantains enabled status for each zone.
    */
    public static final Map<String,Boolean> IS_DOWNLOAD_ZONE_ENABLED = new Map<String,Boolean>();
    static{
    	IS_DOWNLOAD_ZONE_ENABLED.put(DOWNLOAD_ZONE_SAAS_PUBLIC,true);
    	IS_DOWNLOAD_ZONE_ENABLED.put(DOWNLOAD_ZONE_ON_PREMISE_PUBLIC,true);
    	IS_DOWNLOAD_ZONE_ENABLED.put(DOWNLOAD_ZONE_ON_PREMISE_INTERNAL,true);  
    	IS_DOWNLOAD_ZONE_ENABLED.put(DOWNLOAD_ZONE_AZURE,true);
    	IS_DOWNLOAD_ZONE_ENABLED.put(DOWNLOAD_ZONE_ON_PREMISE_BETA,true);
    	IS_DOWNLOAD_ZONE_ENABLED.put(DOWNLOAD_ZONE_DB_ON_PREMISE_PUBLIC,true);
    }
    
    public static final Map<String,String> EUM_TYPE_BACKEND_MAP = new Map<String,String>();
    static{
    	EUM_TYPE_BACKEND_MAP.put('LITE','EUM_LITE');
    	EUM_TYPE_BACKEND_MAP.put('PRO','EUM_PRO');  
    }  
    
    public static final Map<String,String> EUM_MOBILE_TYPE_BACKEND_MAP = new Map<String,String>();
    static{
    	EUM_MOBILE_TYPE_BACKEND_MAP.put('LITE','MOBILE_LITE');
    	EUM_MOBILE_TYPE_BACKEND_MAP.put('PRO','MOBILE_PRO');  
    }
    
	public static final Map<String,Map<String,Boolean>> LICENSE_AGENT_VISIBILITY_MAP = new Map<String,Map<String,Boolean>>();

    static{
    	LICENSE_AGENT_VISIBILITY_MAP.put(AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE,new Map<String,Boolean>
    				{'Java' => true,'.NET' => true,'PHP' => true,'Machine' => true,'Database' => true, 'NodeJs' => true,
    					'Log'=> false, 'Transaction'=>false,
    					'Python'=> true,'C++ SDK' => true,
    					'C++ Web Server' => true,'C++ Dynamic' => true,
    					'EUMWeb'=>false, 'EUMMobile'=>false});
    	LICENSE_AGENT_VISIBILITY_MAP.put(AppDConstants.LICENSE_PRODUCT_TYPE_SAAS,new Map<String,Boolean>{'Java' => true,'.NET' => true,
    					'PHP' => true,'Machine' => true,'Database' => true, 'NodeJs' => true,
    					'Log'=> false, 'Transaction'=>false,
    					'Python'=> true, 'C++ SDK' => true,
    					'C++ Web Server' => true,'C++ Dynamic' => true,
    					'EUMWeb'=>false, 'EUMMobile'=>false});  
    }
    
    public static final List<String> LICENSE_AGENTS = new List<String>(); 
    static{
    	LICENSE_AGENTS.add('Java');
    	LICENSE_AGENTS.add('.NET');
    	LICENSE_AGENTS.add('PHP');
    	LICENSE_AGENTS.add('Database');
        LICENSE_AGENTS.add('NodeJs');
        LICENSE_AGENTS.add('Python');
        LICENSE_AGENTS.add('Machine');
        LICENSE_AGENTS.add('Log');
        LICENSE_AGENTS.add('Transaction');
        LICENSE_AGENTS.add('EUMWeb');
        LICENSE_AGENTS.add('EUMLite');
        LICENSE_AGENTS.add('C++ SDK');
		LICENSE_AGENTS.add('C++ Web Server');
		LICENSE_AGENTS.add('C++ Dynamic');
        //LICENSE_AGENTS.add('C++');
        
        
    } 
    
    public static final String LICENSE_AGENT_CATEGORY_APM = 'APM';
    public static final String LICENSE_AGENT_CATEGORY_ANALYTICS = 'Analytics';
    public static final String LICENSE_AGENT_CATEGORY_EUM = 'EUM';
    public static final String LICENSE_AGENT_CATEGORY_SYNTHETIC = 'Synthetic';
    
    public static final List<String> LICENSE_AGENT_CATEGORIES = new List<String>();
    static{
    	LICENSE_AGENT_CATEGORIES.add(LICENSE_AGENT_CATEGORY_APM);
    	LICENSE_AGENT_CATEGORIES.add(LICENSE_AGENT_CATEGORY_ANALYTICS);
    	LICENSE_AGENT_CATEGORIES.add(LICENSE_AGENT_CATEGORY_SYNTHETIC);
    	//LICENSE_AGENT_CATEGORIES.add(LICENSE_AGENT_CATEGORY_EUM);
    }
    public static final List<String> LICENSE_AGENT_TYPES_APM = new list<String>();
    static{
    	LICENSE_AGENT_TYPES_APM.add('Java');
    	LICENSE_AGENT_TYPES_APM.add('.NET');
    	LICENSE_AGENT_TYPES_APM.add('PHP');
    	LICENSE_AGENT_TYPES_APM.add('NodeJs');
    	LICENSE_AGENT_TYPES_APM.add('Database');
        LICENSE_AGENT_TYPES_APM.add('Python');
    	LICENSE_AGENT_TYPES_APM.add('Machine');
    	LICENSE_AGENT_TYPES_APM.add('C++ SDK');
		LICENSE_AGENT_TYPES_APM.add('C++ Web Server');
		LICENSE_AGENT_TYPES_APM.add('C++ Dynamic');
    	//LICENSE_AGENT_TYPES_APM.add('C++');
    	
    }
    
    public static final List<String> LICENSE_AGENT_TYPES_ANALYTICS = new list<String>();
    static{
    	LICENSE_AGENT_TYPES_ANALYTICS.add('Log');
    	LICENSE_AGENT_TYPES_ANALYTICS.add('Transaction');
    }
     public static final List<String> LICENSE_AGENT_TYPES_EUM = new list<String>();
    static{
    	LICENSE_AGENT_TYPES_EUM.add('EUMWeb');
    	LICENSE_AGENT_TYPES_EUM.add('EUMMobile');
    }
    public static final List<String> LICENSE_AGENT_TYPES_SYNTHETIC = new list<String>();
    static{
    	LICENSE_AGENT_TYPES_SYNTHETIC.add('Synthetic');
    }
    
    public static final Map<String, List<String>> LICENSE_AGENT_CATEGORY_MAP = new Map<String,List<String>>();
    static{
    	LICENSE_AGENT_CATEGORY_MAP.put(LICENSE_AGENT_CATEGORY_APM,LICENSE_AGENT_TYPES_APM);
    	LICENSE_AGENT_CATEGORY_MAP.put(LICENSE_AGENT_CATEGORY_ANALYTICS,LICENSE_AGENT_TYPES_ANALYTICS);
    	//LICENSE_AGENT_CATEGORY_MAP.put(LICENSE_AGENT_CATEGORY_EUM,LICENSE_AGENT_TYPES_EUM);
    }
    
    public static String getAgentCategory(String agentType){
    	if(new Set<String>(LICENSE_AGENT_TYPES_APM).contains(agentType)){
    		return LICENSE_AGENT_CATEGORY_APM;
    	}else if(new Set<String>(LICENSE_AGENT_TYPES_ANALYTICS).contains(agentType)){
    		return LICENSE_AGENT_CATEGORY_ANALYTICS;
    	}
		else if(new Set<String>(LICENSE_AGENT_TYPES_SYNTHETIC).contains(agentType)){
    		return LICENSE_AGENT_CATEGORY_SYNTHETIC;
    	}    	
    	return null;
    }
    
    public static final Map<Integer,String> OPCODE_REQMETHOD_MAP = new Map<Integer,String>();
    static{
        OPCODE_REQMETHOD_MAP.put(OPCODE_ADD_COMPANY,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_ADD_USER,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_SEND_ADUA_ID,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_DELETE_USER,REQ_METHOD_DELETE);
        OPCODE_REQMETHOD_MAP.put(OPCODE_PROVISION_FREE_TRIAL,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_EXTEND_TRIAL,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_TRANSITION_TO_PERMANENT,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_SEND_LIC_ID,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_SPLIT_LICENSE,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_HA_LICENSE,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_ADD_LICENSE,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_GET_CONTROLLERS,REQ_METHOD_GET);
        OPCODE_REQMETHOD_MAP.put(OPCODE_GET_LIC_TRANSACTION_STATE,REQ_METHOD_GET);
        OPCODE_REQMETHOD_MAP.put(OPCODE_UNPROVISION_LICENSE,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_EXPIRE_LICENSE,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_SEND_EXPIRY_REMINDER,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_RESET_SAAS_PASSWORD,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_GET_LICENSES_CONTROLLER,REQ_METHOD_GET);
        OPCODE_REQMETHOD_MAP.put(OPCODE_DELETE_COMPANY,REQ_METHOD_GET);
        OPCODE_REQMETHOD_MAP.put(OPCODE_DBTUNA_PROVISION,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_SS_FILTER_CONTACTS,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_SS_GET_LICENSE,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_SS_CLAIM_LICENSE,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_PORTAL_GET_LICENSE,REQ_METHOD_POST);
        OPCODE_REQMETHOD_MAP.put(OPCODE_CONVERT_TO_LITE,REQ_METHOD_POST);
    }
    
    public static final Map<Integer,String> OPCODE_URL_MAP = new Map<Integer,String>();
    static{
        OPCODE_URL_MAP.put(OPCODE_ADD_COMPANY,SERVER_URL+'/accounts/company/');
        OPCODE_URL_MAP.put(OPCODE_ADD_USER,SERVER_URL+'/accounts/user/');
        OPCODE_URL_MAP.put(OPCODE_SEND_ADUA_ID,SERVER_URL+'/rest/user/salesforceid/');
        OPCODE_URL_MAP.put(OPCODE_DELETE_USER,SERVER_URL+'/rest/user/');
        OPCODE_URL_MAP.put(OPCODE_PROVISION_FREE_TRIAL,SERVER_URL+'/licence/operation/');
        OPCODE_URL_MAP.put(OPCODE_EXTEND_TRIAL,SERVER_URL+'/licence/operation/');
        OPCODE_URL_MAP.put(OPCODE_TRANSITION_TO_PERMANENT,SERVER_URL+'/licence/operation/');
        OPCODE_URL_MAP.put(OPCODE_SPLIT_LICENSE,SERVER_URL+'/licence/operation/');
        OPCODE_URL_MAP.put(OPCODE_UNPROVISION_LICENSE,SERVER_URL+'/licence/operation/');
        OPCODE_URL_MAP.put(OPCODE_EXPIRE_LICENSE,SERVER_URL+'/licence/operation/');
        OPCODE_URL_MAP.put(OPCODE_SEND_EXPIRY_REMINDER,SERVER_URL+'/licence/reminder/');
        
        OPCODE_URL_MAP.put(OPCODE_SEND_LIC_ID,SERVER_URL+'');
        OPCODE_URL_MAP.put(OPCODE_ADD_LICENSE,SERVER_URL+'/licence/operation/');
        OPCODE_URL_MAP.put(OPCODE_HA_LICENSE,SERVER_URL+'/licence/operation/');
        OPCODE_URL_MAP.put(OPCODE_GET_CONTROLLERS,SERVER_URL+'/controller/available/');
        
        OPCODE_URL_MAP.put(OPCODE_GET_LIC_TRANSACTION_STATE,SERVER_URL+'/licence/transaction/');
        
        OPCODE_URL_MAP.put(OPCODE_RESET_SAAS_PASSWORD,SERVER_URL+'/licence/operation/');
        
        OPCODE_URL_MAP.put(OPCODE_GET_LICENSES_CONTROLLER,SERVER_URL+'/controller/');
        
        OPCODE_URL_MAP.put(OPCODE_DELETE_COMPANY,SERVER_URL+'/accounts/company/');
        
        OPCODE_URL_MAP.put(OPCODE_DBTUNA_PROVISION,SERVER_URL+'/licence/generatedbtunalicence/');
        
        OPCODE_URL_MAP.put(OPCODE_SS_FILTER_CONTACTS ,SERVER_URL+'/account/selfservice/api/checklicenses/');
        
        OPCODE_URL_MAP.put(OPCODE_SS_GET_LICENSE ,SERVER_URL+'/account/selfservice/api/getlicenses/');
        
        OPCODE_URL_MAP.put(OPCODE_SS_CLAIM_LICENSE ,SERVER_URL+'/account/selfservice/api/claimlicenses/');
        OPCODE_URL_MAP.put(OPCODE_PORTAL_GET_LICENSE ,SERVER_URL+'/api/getlicenseinfo/');
        OPCODE_URL_MAP.put(OPCODE_CONVERT_TO_LITE ,SERVER_URL+'/licence/operation/');
        
    }
    
    
    public static final Map<Integer,String> UNIT_TEST_RESPONSES_MAP=new Map<Integer,String>();
    static{
    	UNIT_TEST_RESPONSES_MAP.put(OPCODE_SS_FILTER_CONTACTS,'{"emailId": ["srinidhi.test1242@tarams.com"]}');
    	UNIT_TEST_RESPONSES_MAP.put(OPCODE_SS_GET_LICENSE,' {"users": [{"licences": [{ "eum": {"web_agent_units": "5","mobile_type": "MOBILE_PRO","eum_access_key": "4975c501-a1eb-4c3d-9ae3-21262dbe2585","eum_account_name": "ranjanprabhub2sept422@gmail.com-ss-TaramsSoftwareTechnologies-aue7unbaltnn","mobile_agent_units": "5","web_eum_type": "EUM_PRO","mobile_allow_overage": "False","web_allow_overage": "False"}, "MacAddress": null, "ProductType": "SAAS", "saasPassword": "tt6e6qlb1xl9", "contacts": [{"lastName": "Test", "primaryContact": true, "email": "srinidhi.test1242@tarams.com"}], "saas": {"envName": "selfservice"}, "operationType": "SS_PROVISION_TRIAL", "license_agents": [{"agent_count": "5", "agent_type": ".Net", "old_count": "0"}, {"agent_count": "0", "agent_type": "PHP", "old_count": "0"}, {"agent_count": "5", "agent_type": "Java", "old_count": "0"}, {"agent_count": "10", "agent_type": "Total", "old_count": "0"}, {"agent_count": "0", "agent_type": "Machine", "old_count": "0"}], "licenseId": "137677778536ITF", "customerSaasUrl": "Test1242Tarams", "saasAccount": "Test1242Tarams", "expiryDate": "2013-09-01 00:00:00", "saasUserName": "Test1242Tarams", "customerName": "Test1242Tarams"}], "email": "srinidhi.test1242@tarams.com"}]}');
    	UNIT_TEST_RESPONSES_MAP.put(OPCODE_SS_CLAIM_LICENSE,'{"licenceId": ["137677778536ITF"]}');
    	UNIT_TEST_RESPONSES_MAP.put(OPCODE_GET_CONTROLLERS,'{"paid48": 612, "paid49": 622, "paid40": 592, "paid29.azure.appdynamics.com": 412, "paid43": 542, "paid44": 572, "paid45": 562, "paid46": 582, "paid47": 602, "paid42": 522, "ss-prod-test": 492, "controller-uk-01.apm.ntt.eu": 322, "paid32": 442, "staging": 132, "paid33": 432, "paid39": 532, "paid31": 552, "paid30": 422, "paid19": 302, "paid18": 282, "paid35": 462, "paid34": 452, "paid37": 482, "paid36": 472, "prod81": 202, "paid12": 232, "paid11": 222, "paid10": 212, "paid17": 292, "paid16": 272, "paid15": 262, "paid14": 252, "paid13": 242, "paid38": 512, "c1.azure.appdynamics.com": 312, "paid8": 192, "test73": 42, "prod73": 62, "paid7": 162, "paid6": 47, "paid5": 52, "paid22": 372, "paid23": 362, "paid20": 332, "paid21": 352, "paid26": 392, "paid24": 382, "paid25": 342, "dotnet": 142, "paid28": 402, "paid29": 502, "onpremise controller": 1}');
    	UNIT_TEST_RESPONSES_MAP.put(OPCODE_PORTAL_GET_LICENSE,'{"users": [{"licenses": [{"eum": {"web_agent_units": "5", "mobile_type": "MOBILE_PRO", "eum_access_key": "d011b7a2-bee8-42d0-bcae-0741ca70d179", "eum_account_name": "6212-ss-R1340N1340Comp-1zcx4s06r1mj", "mobile_agent_units": "5", "web_eum_type": "EUM_PRO", "mobile_allow_overage": "False", "web_allow_overage": "False"}, "MacAddress": "", "licenseType": "selfservice-pro-trial", "customerName": "", "saasPassword": "", "accessKey": "", "license_contacts": [{"lastName": "N1340", "email": "r1340.n1340@test.com", "user_type": "primary"}, {"lastName": "N1341", "email": "r1341.n1341@test.com", "user_type": "additional"}, {"lastName": "OpT_2015_8_24__1_25_29", "email": "opt_2015_8_24__1_25_29_3@test.com", "user_type": "additional"}], "contacts": [{"firstName": "R1340", "lastName": "N1340", "userID": 6212, "user_type": "primary", "subscribeLicenseNotification": "True", "subscribeSaasNotification": "False", "email": "r1340.n1340@test.com"}, {"firstName": "R1341", "lastName": "N1341", "userID": 6213, "user_type": "additional", "subscribeLicenseNotification": "True", "subscribeSaasNotification": "False", "email": "r1341.n1341@test.com"}, {"firstName": "FName_3", "lastName": "OpT_2015_8_24__1_25_29", "userID": 5498, "user_type": "additional", "subscribeLicenseNotification": "True", "subscribeSaasNotification": "False", "email": "opt_2015_8_24__1_25_29_3@test.com"}], "expiryDate": "2015-10-27 00:00:00", "license_agents": [{"agent_count": "5", "agent_type": ".Net"}, {"agent_count": "5", "agent_type": "Database"}, {"agent_count": "5", "agent_type": "Java"}, {"agent_count": "5", "agent_type": "NodeJs"}, {"agent_count": "5", "agent_type": "PHP"}, {"agent_count": "5", "agent_type": "Python"}, {"agent_count": "0", "agent_type": "Machine"}, {"agent_count": "5", "agent_type": "EUM_PRO"}, {"agent_count": "5", "agent_type": "MOBILE_PRO"}], "customerSaasUrl": "", "saasAccount": "", "created_date": "2015-10-12 00:00:42", "ProductType": "On-Premise", "saasUserName": "", "id": "144463324129YWO", "stage": "SELFSERVICE_TRIAL"}], "user_id": 6212, "email": "r1340.n1340@test.com", "company_id": 11572}]}');
    }
}