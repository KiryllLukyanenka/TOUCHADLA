trigger LicenseTransactionHandler on LicenseDetail__c (before update){
	for(LicenseDetail__c license :trigger.new){	
		String lastProcessState = license.ProcessState__c;
		if('SUCCESS'.equalsIgnoreCase(lastProcessState)){
	        String customerSaaSUrl = license.Custom_URL_Name__c;
	        String productType = license.Product_Type__c;
	        Date expiryDate = license.License_Expiry_Date__c;
	        String macAdress = license.MAC_Address__c;
	        String stage= license.Stage__c;
	        Integer java= Integer.valueOf(license.Java_Agents_Rollup__c);
	        Integer net= Integer.valueOf(license.Net_Agents_Rollup__c);
	        Integer machine= Integer.valueOf(license.Machine_Agents_Rollup__c);
	        Integer php= Integer.valueOf(license.PHP_Agents_Rollup__c);
	        
	        String licenseData = 'Deployment-Option: '+productType+'; Expiry Date:'+expiryDate+'; Java/.Net/Machine Agents/php:'+java+'/'+net+'/'+machine+'/'+php+'; Stage:'+stage+'; ';
	        
	        if(AppDConstants.LICENSE_PRODUCT_TYPE_ON_PREMISE.equals(productType)){
	        	licenseData+='Mac Address:'+macAdress;
	        }else{
	        	licenseData+='SaaS URL:'+customerSaaSUrl;
	        }
	        licenseData = licenseData.length()>255?licenseData.substring(0,255):licenseData;
	        
	        license.LicenseData__c = licenseData;
		}
        //System.debug(LoggingLevel.Info,'@@@@@Failed License:'+lastProcessState );
        
        if(!'Failed'.equalsIgnoreCase(lastProcessState)){
        	//System.debug(LoggingLevel.Info,'@@@@@Failed License');
        	
        	//String jsonStr = new LicenseJSONParser(license).toJson();
            //license.FailoverBackup__c = jsonStr;
        	
        	//String jsonFailoverBackupString = license.FailoverBackup__c;
        	/*if(jsonFailoverBackupString!=null){
	        	jsonFailoverBackupString = jsonFailoverBackupString.replaceAll('&quot;','"');
	        	//System.debug(LoggingLevel.Info,'@@@@@Failed License:'+jsonFailoverBackupString);
	        	if(jsonFailoverBackupString!=null && !jsonFailoverBackupString.trim().equals('')){
	        		String newJsonString = new LicenseJSonParser(license).toJson(); 
	        		//new LicenseJSonParser(jsonFailoverBackupString).replaceFromJson(license);
	        		//System.debug(LoggingLevel.Info,'@@@@@Failed License:'+license);
	        		//license.FailoverBackup__c = newJsonString;
	        	}
        	}*/
        }
    }
}