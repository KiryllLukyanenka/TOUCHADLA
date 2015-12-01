public virtual class PortalBackendLicense extends Backend{
	
	public String jsonData {
		get{
			if(requestScopeData!=null){
				return System.JSON.serialize(requestScopeData);
			}return null;
		}
	}
	
	public void invokeBackend(){
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(this.url);
		req.setMethod(this.requestMethod);
		System.debug(LoggingLevel.Info, 'JSON DATA:'+jsonData);
		if(jsonData!=null){
			System.debug(LoggingLevel.Info, 'JSON DATA SETTING?:'+jsonData);
			req.setBody(jsonData);
		}
		Long timestamp = DateTime.now().getTime();
		String signatureKey = '851e137c7ead9694df4509c110011f2b';
		Blob signatureBlob = Blob.valueOf(signatureKey+timestamp);
		String signature = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', signatureBlob));
		req.setHeader('Timestamp',timestamp+'');
		req.setHeader('Api_token','license_api_admin');
		req.setHeader('Signature',signature);
		if(req.getMethod()!='GET'){
			req.setHeader('Content-Type', 'application/json');
		}			
		System.debug(LoggingLevel.Info,'TimeStmap:'+ timestamp);
		System.debug(LoggingLevel.Info,'Signature:'+ signature);
		HttpResponse res = h.send(req);
		this.responseObj = res;
		System.debug(LoggingLevel.Info, 'RESPONSE:'+res.getBody());
		this.handleResponse(res.getBody(), res.getStatusCode());
		String message = 'REQUEST: Method='+ req.getMethod() +' Body ='+ req.getBody();
		message += '\n' + 'RESPONSE STATUS:' + res.getStatusCode();
		message += '\n' + 'RESPONSE:' + res.getBody();
		System.debug(LoggingLevel.Info, message);
		//EmailUtil.notifyError(message,'Error in API Call');
	}
	
	public Object requestScopeData {get;set;}
	
	public String getId(String location){
		location = location.trim();
		if(location.endsWith('/')){
			location = location.substring(0,location.length()-1);
		}
		String id = location.substring(location.lastIndexOf('/')  + 1);
		System.debug(LoggingLevel.Info, 'License/Operation ID:' + location);
		return id;
	}
	
	
	public class GetMetadata extends PortalBackendLicense{
		public PortalModelLicense.LicenseMetadata metadataResponse {get;set;}
		public GetMetadata(String edition, String deployment){
			super();
			this.opCode = BackendConstants.OPCODE_GET_LICENSE_METADATA;
			//'https://portal-staging.saastest.appdynamics.com/api/rest/v1/licenses/metadata/pro-trial/saas/salesforce/?format=json'
			this.url = BackendConstants.SERVER_URL + '/api/rest/v1/licenses/metadata/'+edition+'/'+deployment+'/salesforce/?format=json';
			this.requestMethod = 'GET';
		}
				
		public override void handleResponse(String response, Integer statusCode){
			System.debug(LoggingLevel.Info, 'Response from server:'+response);
			System.debug(LoggingLevel.Info, 'Status from server:'+statusCode);
			this.response = response;
			this.statusCode = statusCode;
			this.metadataResponse =  (PortalModelLicense.LicenseMetadata) System.JSON.deserialize(response,PortalModelLicense.LicenseMetadata.class);
		}
	}
	
	public class ProvisionLicense extends PortalBackendLicense{
		public String operationLocation {get;set;}
		public String operationId {get;set;}
		public ProvisionLicense(PortalModelLicense.License licenseData){
			super();
			this.opCode = BackendConstants.OPCODE_PROVISION_LICENSE;
			this.url = BackendConstants.SERVER_URL + '/api/rest/v1/licenses/';
			this.requestMethod = 'POST';
			this.requestScopeData = licenseData;
		}
		
		public override void handleResponse(String response, Integer statusCode){
			this.response = response;
			this.statusCode = statusCode;
			this.operationLocation = this.responseObj.getHeader('Location');
			this.operationId = getId(this.operationLocation);
			System.debug(LoggingLevel.Info, 'LOCATION TO CHECK STATUS:' + this.operationLocation); 
		}
	}
	
	public class CheckOperationStatus extends PortalBackendLicense{
		public String operationId {get;set;}
		public String operationLocation {get;set;}
		public String licenseId {get;set;}
		public PortalModelLicense.LicenseOperation operationStatusData {get;set;}
		public CheckOperationStatus(String operationId){
			super();
			this.operationId = operationId;
			this.opCode = BackendConstants.OPCODE_GET_LICENSE_OPERATION_STATUS;
			this.url = BackendConstants.SERVER_URL + '/api/rest/v1/licenses/operations/'+operationId+'/?format=json';
			this.requestMethod = 'GET';
		}
		
		public override void handleResponse(String response, Integer statusCode){
			this.response = response;
			this.statusCode = statusCode;
			this.operationLocation = this.responseObj.getHeader('Location');
			if(operationLocation!=null){
				if(statusCode==201){
					this.licenseId = getId(this.operationLocation);	
				}else{
					this.operationId = getId(this.operationLocation);
				}
			}
			this.operationStatusData =  (PortalModelLicense.LicenseOperation) System.JSON.deserialize(response,PortalModelLicense.LicenseOperation.class);
			
			System.debug(LoggingLevel.Info, 'LOCATION TO CHECK STATUS:' + this.operationLocation);
			System.debug(LoggingLevel.Info, 'Operation ID:'+ this.operationId);
			System.debug(LoggingLevel.Info, 'License ID:'+ this.licenseId); 
		}
	}
	
	public class GetLicense extends PortalBackendLicense{
		public String licenseId {get;set;}
		public PortalModelLicense.License licenseObj {get;set;}
		public GetLicense(String licenseId){
			super();
			this.licenseId = licenseId;
			this.opCode = BackendConstants.OPCODE_GET_LICENSE;
			this.url = BackendConstants.SERVER_URL + '/api/rest/v1/licenses/'+licenseId+'?format=json';
			this.requestMethod = 'GET';
		}
		
		public override void handleResponse(String response, Integer statusCode){
			this.response = response;
			this.statusCode = statusCode;
			this.licenseObj = (PortalModelLicense.License) System.JSON.deserialize(response,PortalModelLicense.License.class); 
		}
	}
	
	public class ModifyLicense extends PortalBackendLicense{
		public String operationId {get;set;}
		public String operationLocation {get;set;}
		public ModifyLicense(PortalModelLicense.License licenseData){
			super();
			this.opCode = BackendConstants.OPCODE_PROVISION_LICENSE;
			this.url = BackendConstants.SERVER_URL + '/api/rest/v1/licenses/'+licenseData.id+'/';
			this.requestMethod = 'PUT';
			this.requestScopeData = licenseData;
		}
		
		public override void handleResponse(String response, Integer statusCode){
			this.response = response;
			this.statusCode = statusCode;
			this.operationLocation = this.responseObj.getHeader('location'); 
			this.operationId = getId(this.operationLocation);
			System.debug(LoggingLevel.Info, 'LOCATION TO CHECK STATUS:' + this.operationLocation);
		}
	}
	
	public class DisableLicense extends PortalBackendLicense{
		public String operationLocation {get;set;}
		public DisableLicense(PortalModelLicense.License licenseData){
			super();
			this.opCode = BackendConstants.OPCODE_PROVISION_LICENSE;
			this.url = BackendConstants.SERVER_URL + '/api/rest/v1/licenses/'+licenseData.id+'/';
			this.requestMethod = 'DEL';
			this.requestScopeData = licenseData;
		}
		
		public override void handleResponse(String response, Integer statusCode){
			this.response = response;
			this.statusCode = statusCode;
			this.operationLocation = this.responseObj.getHeader('location'); 
		}
	}
}