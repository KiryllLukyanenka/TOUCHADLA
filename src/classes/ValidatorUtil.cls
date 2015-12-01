public with sharing class ValidatorUtil {
	private static final String HEXADECIMAL_BIT = '[0-9a-f]';
	private static final String MAC_ADDRESS_REGEX = HEXADECIMAL_BIT+HEXADECIMAL_BIT+'[:-]'+HEXADECIMAL_BIT+HEXADECIMAL_BIT+'[:-]'+HEXADECIMAL_BIT+HEXADECIMAL_BIT+'[:-]'+HEXADECIMAL_BIT+HEXADECIMAL_BIT+'[:-]'+HEXADECIMAL_BIT+HEXADECIMAL_BIT+'[:-]'+HEXADECIMAL_BIT+HEXADECIMAL_BIT;
	private static final String NODE_NAME_REGEX = '[a-zA-Z0-9][a-zA-Z0-9-_]+'; 
	private static final String URL_REGEX = '\\b(https?|ftp|file)://[-A-Z0-9+&@#/%?=~_|!:,.;]*[-A-Z0-9+&@#/%=~_|]';
	
	public static Boolean matches(String input, String regex){
		if(input!=null){
			input = input.toLowerCase();
			Pattern macPattern = Pattern.compile(regex);
			Matcher macMatcher = macPattern.matcher(input);
			return macMatcher.matches();  
		}
		return false;
	}
	
	public static Boolean isValidMacAddress(String input){
		return matches(input,MAC_ADDRESS_REGEX);
	}
	
	public static Boolean isValidNodeName(String input){
		return matches(input,NODE_NAME_REGEX);
	}
	
	public static testMethod void testIsValidNodeName(){
		Boolean isValid  = isValidNodeName('safsftestt321-sfasf');
		System.assertEquals(true,isValid);
	}
	
	static testMethod void testValidate9(){
		LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
		lic.Custom_URL_Name__c='#$%^^&^@@#!~saa   ><>?</_+=-';
		lic.License_Expiry_Date__c = System.now().date().addDays(1);
		upsert lic;
		try{
			ValidatorUtil.validate(lic,BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
		}catch(Exception e){}	
	}
	
	static testMethod void testValidate10(){
		LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE;
		lic.Custom_URL_Name__c='#$%^^&^@@#!~saa   ><>?</_+=-';
		lic.License_Expiry_Date__c = System.now().date().addDays(1);
		upsert lic;
		try{
		ValidatorUtil.validate(lic,BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
		}catch(Exception e){}
	}
	
	static testMethod void testValidate11(){
		LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_SAAS_LITE;
		//lic.Custom_URL_Name__c='#$%^^&^@@#!~saa   ><>?</_+=-';
		lic.License_Expiry_Date__c = System.now().date().addDays(1);
		//upsert lic;
		try{
		ValidatorUtil.validate(lic,BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
		}catch(Exception e){}
	}
	
	static testMethod void testValidate12(){
		LicenseDetail__c lic = new LicenseDetail__c();
		lic.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
		lic.Custom_URL_Name__c='abc';
		lic.License_Expiry_Date__c = System.now().date().addDays(1);
		upsert lic;
		LicenseDetail__c lic2 = new LicenseDetail__c();
		lic2.Product_Type__c=AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
		lic2.Custom_URL_Name__c='abc';
		lic2.License_Expiry_Date__c = System.now().date().addDays(1);
		try{
		ValidatorUtil.validate(lic,BackendConstants.OPCODE_PROVISION_FREE_TRIAL);
		}catch(Exception e){}
	}
	
	public static testMethod void testValidate1(){
		ValidatorUtil.matches(null,URL_REGEX);	
	}
	
	public static testMethod void testValidate2(){
		LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	lic.Product_Type__c = AppDConstants.LICENSE_PRODUCT_TYPE_SAAS;
    	lic.Manual_SaaS_Fields__c=true;
    	lic.Custom_URL_Name__c='TestTarams2413_unique_2';
    	lic.SaaS_Account__c='TestTarams2413_unique_2';
    	lic.SAAS_UserName__c = 'TestTarams2413_unique_2';
    	try{ValidatorUtil.validate(lic,BackendConstants.OPCODE_PROVISION_FREE_TRIAL);}catch(Exception e){}
	}
	
	public static testMethod void testValidate3(){
		LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	lic.Ad_hoc_Email_Ids__c='abc@taramsc.om;\ndef@tarams.com';
		try{ValidatorUtil.validate(lic,BackendConstants.OPCODE_PROVISION_FREE_TRIAL);}catch(Exception e){}	
	}
	
	public static testMethod void testValidate4(){
		LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
		lic.License_Expiry_Date__c=null;
    	try{ValidatorUtil.validate(lic,BackendConstants.OPCODE_PROVISION_FREE_TRIAL);}catch(Exception e){}	
	}
	
	public static testMethod void testValidate5(){
		LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Date expDate = System.now().date();
    	expDate = expDate.addDays(-10);
    	lic.License_Expiry_Date__c=expDate;
		try{ValidatorUtil.validate(lic,BackendConstants.OPCODE_PROVISION_FREE_TRIAL);}catch(Exception e){}
	}
	
	public static testMethod void testValidate6(){
		LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	List<PortalDataType.LicenseAgentInfo> licAgentInfoList = LicenseUtil.getLicenseAgentInfoList(lic, -1);
    	Date expDate = System.now().date();
    	expDate = expDate.addDays(-10);
    	lic.License_Expiry_Date__c=expDate;
		try{ValidatorUtil.validateAgents(licAgentInfoList,BackendConstants.OPCODE_PROVISION_FREE_TRIAL,lic.Product_Type__c, new LicenseEUMInput(null,null,null));}catch(Exception e){}	
	}
	public static testMethod void testValidate7(){
		LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	try{ValidatorUtil.validate(lic,BackendConstants.OPCODE_UNPROVISION_LICENSE);}catch(Exception e){}	
	}
	
	
	public static testMethod void testValidate8(){
		LicenseDetail__c lic = (LicenseDetail__c)DataLayerConstants.fetchSingleWithWhereClause('LicenseDetail__c',' WHERE STAGE__c = \'TRIAL\' AND ProcessState__c=\'SUCCESS\' AND License_BackendID__c!=\'\'');
    	Date expDate = System.now().date();
    	expDate = expDate.addDays(50);
    	lic.License_Expiry_Date__c=expDate;
		try{ValidatorUtil.validate(lic,BackendConstants.OPCODE_TRANSITION_TO_PERMANENT);}catch(Exception e){}
	}
	
	
	public static Boolean isValidURL(String input){
		//return matches(input,URL_REGEX);
		return true;
	}
	static testMethod void testValidate13(){
		try{
		validate(null,BackendConstants.OPCODE_ADD_LICENSE);
		}catch(Exception e){}
	}
	public static Boolean validate(LicenseDetail__c licenseObject, Integer opcode) {
		if(opcode==BackendConstants.OPCODE_UNPROVISION_LICENSE||opcode==BackendConstants.OPCODE_EXPIRE_LICENSE){
			return true;
		}
		if(licenseObject==null){
			throw new ValidationException('License data cannot be created, Please retry.');
		}
		
		String productType = licenseObject.Product_Type__c;
		String customerURL = licenseObject.Custom_URL_Name__c;
		String saasAcc = customerURL;
		if(licenseObject.Manual_SaaS_Fields__c){
			saasAcc = licenseObject.SaaS_Account__c;
		}
		Date currentDate = System.now().date();
		Date maxExpiryDate = currentDate.addDays(40); //45    - changed from 45 to 40
		
		Date maxExpiryDatePaidTemp = currentDate.addDays(60); //45    - changed from 45 to 40
		
		Boolean eumSelected = licenseObject.IS_EUM__c;
		String coradiantURL = licenseObject.Coradiant_Integration_URL__c;
		
		Boolean isPermanent = licenseObject.Is_Permanent__c;
		Boolean isPerpetual = licenseObject.Is_Perpetual__c;
		String macAddr = licenseObject.MAC_Address__c;
		String adHocEmailIds = licenseObject.Ad_hoc_Email_Ids__c;
		String stage = licenseObject.Stage__c;
		Boolean rumEnabled = false;
		/*if(licenseObject.RUM_Enabled__c!=null){
			rumEnabled = licenseObject.RUM_Enabled__c;
		}
		String rumAccName = licenseObject.RUM_Account_Name__c;*/
		if(adHocEmailIds!=null && !adHocEmailIds.equals('')){
			try{
				adHocEmailIds = adHocEmailIds.replaceAll('\n','');
				adHocEmailIds = adHocEmailIds.replaceAll('\r','');
				licenseObject.Ad_hoc_Email_Ids__c = adHocEmailIds;
			}catch(Exception e){
			}
		}
		if(isPerpetual){
			licenseObject.License_Expiry_Date__c = Date.newInstance(2038, 1,1);
		}
		Date expiryDate = licenseObject.License_Expiry_Date__c;
		
		if(expiryDate==null){
			throw new ValidationException('Please specify Expiry date for License');
		}
		
		if(expiryDate<=currentDate){
			throw new ValidationException('License Expiry Date Should be after today');
		}
		
		/*if(opcode!=BackendConstants.OPCODE_TRANSITION_TO_PERMANENT && 
		opcode!=BackendConstants.OPCODE_ADD_LICENSE && opcode!=BackendConstants.OPCODE_EXTEND_TRIAL && opcode!=BackendConstants.OPCODE_MODIFY_LICENSE)*/
		if(!LicenseUtil.hasSpecialPrivileges()){
			if(opcode==BackendConstants.OPCODE_PROVISION_FREE_TRIAL)
			{	
				if(expiryDate>maxExpiryDate){
					throw new ValidationException('License Expiry Date Should not be more than 40 days from today');
				}
			}else if(opcode==BackendConstants.OPCODE_TRANSITION_TO_PERMANENT ||opcode==BackendConstants.OPCODE_ADD_LICENSE){
				if(AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(productType)){
					if(macAddr==null || macAddr.trim().equals('')){
						if(expiryDate>maxExpiryDatePaidTemp){
							throw new ValidationException('Paid License without MAC Address cannot have Expiry Date more than 60 days from today');
						}
					}
				}
			}else if(opcode==BackendConstants.OPCODE_EXTEND_TRIAL){
				if('TRIAL'.equals(stage)){
					if(expiryDate>maxExpiryDate){
						throw new ValidationException('License Expiry Date Should not be more than 40 days from today');
					}
				}else if('PAID_TEMP'.equals(stage)){
					if(expiryDate>maxExpiryDatePaidTemp){
						throw new ValidationException('Paid License without MAC Address cannot have Expiry Date more than 60 days from today');
					}
				}
			}
		}
		
		/*
		if(opcode==BackendConstants.OPCODE_EXTEND_TRIAL){
			if(licenseObject.Stage__c!=null && !licenseObject.Stage__c.equalsIgnoreCase('Paid')){
				if(expiryDate>maxExpiryDate){
					throw new ValidationException('License Expiry Date Should not be more than 45 days from today');
				}	
			}
		}
		*/
		if(isPermanent){
			if(AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(productType)){
				if(macAddr==null || macAddr.trim().equals('')){
					throw new ValidationException('Please Specify a MAC Address for Permanent License');
				}
				if(!isValidMacAddress(macAddr)){
					throw new ValidationException('Please Specify a Valid MAC Address for Permanent License');
				}
			}
		}else{
			licenseObject.MAC_Address__c = '';
		}
		
		if(licenseObject.Product_Type__c!=null){
			if(AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(productType)){
				if(macAddr!=null && !macAddr.trim().equals('')){
					if(!isValidMacAddress(macAddr)){
						throw new ValidationException('Please Specify a Valid MAC Address');
					}
				}
			}else if(AppDConstants.LICENSE_PRODUCT_TYPE_SAAS.equals(productType)){
				if(customerURL==null){
					throw new ValidationException('Please Specify Customer SaaS URL');
				}

				if(!isValidNodeName(customerURL)){
					throw new ValidationException('Please Specify a Valid Customer SaaS URL. The URL must begin with a letter or a number and should contain only letters, numbers and hyphen');
				}
				if(eumSelected){
					if(coradiantURL==null){
						throw new ValidationException('Please Specify CoRadiant Integration URL');
					}
					if(!isValidURL(coradiantURL)){
						throw new ValidationException('Please Specify a Valid CoRadiant Integration URL');
					}
				}			
			}else{
				throw new ValidationException('Please specify a Valid Deployment Option of the License');
			}
		}else{
			throw new ValidationException('Please specify Deployment Option of the License');
		}
		
		/*if(rumEnabled){
			if(rumAccName==null || rumAccName.trim().equals('')){
				throw new ValidationException('Please specify account name for RUM Integration');
			}
			if(!isValidNodeName(rumAccName)){
				throw new ValidationException('Please specify a Valid Account name for RUM Integration');
			}
			if(!LicenseUtil.isUniqueRUMAccountName(licenseObject)){
				throw new ValidationException('Please specify a unique account name for RUM Integration');
			}
		}*/
		return true;
	}
	
	public static Boolean validateAgents(List<PortalDataType.LicenseAgentInfo> licAgents,Integer opcode,String productType,LicenseEUMInput eumInput){
		
		Integer maxTotalUnits = 150;
		Integer totalUnits =0;
		Integer maxUnits = AppDConstants.getProvisionTrialMaxUnits();
		Boolean maxUnitsForProvisionExceeded = false;
		Map<String,Integer> unitValuesMap = new Map<String,Integer>();
		Boolean valueSpecified=false;
		for(PortalDataType.LicenseAgentInfo licAgentInfo:licAgents){
			License_Agent__c licAgent = licAgentInfo.licAgent;
			Integer val = 0;
			String agentType=licAgent.Agent_Type__c;
			try{
				if(licAgent.Count__c!=null){
					val = Integer.valueOf(licAgent.Count__c);
				}
				if(PortalDataType.LICENSING_MODEL_VARIABLE.equals(licAgent.Licensing_Model__c)){
					try{
						val = Integer.valueOf(licAgent.Max_Agents__c);
					}catch(Exception e){}	
				}
			}catch(Exception e){}
			if(val<0){
				throw new ValidationException('Please specify a non-negative value for '+licAgent.Agent_Type__c+' Agent Units');
			}
			if(!agentType.equals('Machine')){
				if(val>0){
					valueSpecified=true;	
				}
			}
			if(val>maxUnits){
				maxUnitsForProvisionExceeded=true;
			}
			totalUnits+=val;
			unitValuesMap.put(licAgent.Agent_Type__c,val);
		}
		
		
		if(eumInput!=null){
			if(eumInput.eumWeb!=null && eumInput.eumWeb.Type__c!=null){
				if(eumInput.eumWeb.Type__c.equals('PRO')){
					if(eumInput.eumWeb.Units__c!=null && eumInput.eumWeb.Units__c > 0){
						valueSpecified = true;
					} else {
						valueSpecified = false;
					}
				} else if(eumInput.eumWeb!=null && eumInput.eumWeb.Type__c!=null && eumInput.eumWeb.Type__c.equals('LITE')){
					valueSpecified = true;
				}
				
				if(!valueSpecified){
					throw new ValidationException('Please specify number of units for EUM Web for the license to be provisioned');
				}
			}
			
			if(eumInput.eumMobile!=null && eumInput.eumMobile.Type__c!=null){
				if(eumInput.eumMobile.Type__c.equals('PRO')){
					if(eumInput.eumMobile.Units__c!=null && eumInput.eumMobile.Units__c > 0){
						valueSpecified = true;
					} else {
						valueSpecified = false;
					}
				} else if(eumInput.eumMobile!=null && eumInput.eumMobile.Type__c!=null && eumInput.eumMobile.Type__c.equals('LITE')){
					valueSpecified = true;
				}
				
				if(!valueSpecified){
					throw new ValidationException('Please specify number of units for EUM Mobile for the license to be provisioned');
				}
			}
		}
		
		if(!valueSpecified){
			throw new ValidationException('Please specify unit count value for atleast one of the agent type for the license to be provisioned');
		}
		  
		if(!LicenseUtil.hasSpecialPrivileges()){
			if(opcode == BackendConstants.OPCODE_PROVISION_FREE_TRIAL){
				if(maxUnitsForProvisionExceeded){
					throw new ValidationException('Maximum of '+maxUnits+' Java/.Net/PHP/Machine Agent units can be provisioned for trial license');
				}
			}else{
				if(AppDConstants.LICENSE_PRODUCT_TYPE_SAAS.equals(productType)){
					if(totalUnits>=maxTotalUnits){
						throw new ValidationException('A '+Integer.valueOf(totalUnits)+' nodes license requires a dedicated controller, please contact the saas operations team to provision this license');//Sum of Java/.Net and Machine Units should not be more than 400 units per license');
					}
				}
			}
		}
		return true;
	}
	
	public class ValidationException extends Exception{
		
	}
}