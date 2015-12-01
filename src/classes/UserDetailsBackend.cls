public with sharing class UserDetailsBackend {
	public static String testResponseJson = '';
	public static ADUAController_V2.ADUAUser getUserDetails(String  requestJson){
		try{
			RESTAPI api = new RESTAPI();
	    	api.serviceURL =EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.backendServerURL)+'/accounts/getuserdetails/';
	    	Map<String,String> headersMap = new Map<String,String>();
			Long timestamp = DateTime.now().getTime();
			String signatureKey = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.privateKey) + timestamp;
			Blob signatureBlob = Blob.valueOf(signatureKey);
			String signature = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', signatureBlob));
			headersMap.put('Timestamp',  '' + timestamp);
			headersMap.put('Api_token', EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.apiToken));
			headersMap.put('Signature' , signature);
			api.headers = headersMap;
			api.requestMethod='POST';
			api.requestBody = requestJson;
			if(!RESTAPI.unitTestMode){
				api.invoke();
				//System.debug('response status code==='+ api.response.getStatusCode());
				if(api.response.getStatusCode()==200){
					System.debug('response==='+ api.response.getBody());
					String jsonString = api.response.getBody().replace('accounts-groups', 'accounts_groups');
					//jsonString = jsonString.replace('isActive', 'isUserActive');
					//System.debug('jsonString==='+ jsonString);
					System.JSONParser parser = System.JSON.createParser(jsonString);
					ADUAController_V2.ADUAUser aduaUsers = (ADUAController_V2.ADUAUser)JSON.deserialize(jsonString, ADUAController_V2.ADUAUser.class);
					if(aduaUsers.companyId != null && aduaUsers.companyId.equals('None')) {
						aduaUsers.companyId = '';
					}
					//aduaUsers.getUserApiStatus = api.response.getStatusCode();
					for(ADUAController_V2.ADUAUserDetails ad: aduaUsers.users){
                        ad.firstName = ad.firstName.replace('\\','');
						ad.getUserApiStatus = '200';
                        ad.lastName = ad.lastName.replace('\\','');
						ad.getUserDetailsResponse = ad.getApplications();
					}
					return aduaUsers; 
				} else{
					String error = api.response.getBody();
					//ADUAController_V2.ADUAUser aduaUsers =  new ADUAController_V2.ADUAUser();
					//aduaUsers.getUserApiStatus = string.valueOf(api.response.getStatusCode());
					//aduaUsers.getUserDetailsResponse = api.response.getBody().replace('accounts-groups', 'accounts_groups');
					//EmailUtil.notifyError(e, null);	
					return null;
				}
			} else{
				testResponseJson = '{"users": [{"applications": ["docs/docs-customer","docs/docs-partner-fez","help","download-zones/saas-public"], "userId": 55883, "email": "test@appdynamics.com", "firstName": "Test", "lastName": "TestContact25thAugust","isActive":true}],"companyId": 35012,"accounts_groups":"","name":"testAccount"}';
				System.JSONParser parser = System.JSON.createParser(testResponseJson);
				ADUAController_V2.ADUAUser aduaUsers = (ADUAController_V2.ADUAUser)parser.readValueAs(ADUAController_V2.ADUAUser.class);
			 	return aduaUsers;
			}
		}catch(Exception e){
			EmailUtil.notifyError(e, null);
		}
		return null; 
	}
}