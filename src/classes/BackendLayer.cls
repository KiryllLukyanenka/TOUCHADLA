public with sharing class BackendLayer {
	//public List<BackendData> backendDataList=new List<BackendData>();
	public List<Backend> backendList=new List<Backend>();
	public RESTAPI restAPIObj{get;set;}
	
	public BackendLayer(){
		  
	}
	
	public void addBackend(Backend backendObj){
		backendObj.url = BackendConstants.OPCODE_URL_MAP.get(backendObj.opcode);
		backendObj.requestMethod = BackendConstants.OPCODE_REQMETHOD_MAP.get(backendObj.opcode);
		backendList.add(backendObj);
	}
		
	public String getErrorMessage(){
		String errorMessage = '';
		if(backendList!=null && backendList.size()>0){
			for(Backend backendObj:backendList){
				if(backendObj.errorMessage!=null){
					errorMessage += backendObj.errorMessage;
				}
			}
		}else{
			errorMessage = 'No Result from backend';
		}
		return errorMessage;
	}
	  
	public String getErrorMessage(Boolean detail){
		String errorMessage = '';
		if(!detail){
			if(backendList!=null && backendList.size()>0){
				for(Backend backendObj:backendList){
					if(backendObj.errorMessage!=null){
						errorMessage += backendObj.errorMessage;
					}
				}
			}else{
				errorMessage = 'No Result from backend';
			}
		}else{
		 if(backendList!=null && backendList.size()>0){	
		 	for(Backend backendObj:backendList){
		 		errorMessage ='<br/><b>User details:</b><br/>';
              errorMessage +='<br/>User Id: '+UserInfo.getUserId()+'<br/>';
              errorMessage +='<br/>User Name: '+UserInfo.getUserName()+'<br/>';
              
              errorMessage +='REQUEST URL:'+restAPIObj.serviceURL;
              errorMessage +='<br/>REQUEST Headers:<br/>';
              for(String header:restAPIObj.headers.keySet()){
                  String val = restAPIObj.headers.get(header);
                  errorMessage +='<br/>'+header+':'+val+'<br/>';
              }
              errorMessage +='<br/>REQ PARAM:'+restAPIObj.requestBody;
              errorMessage += 'Params Count:'+backendObj.getParameters().size();
              errorMessage +='<br/>REQ Method:'+restAPIObj.requestMethod;
              errorMessage += '<br/>Backend returned with a error:'+restAPIObj.response.getStatusCode();
              errorMessage +='<br/>Response:'+restAPIObj.response.getBody();
		 	}
		 }
			
		}
		return errorMessage;
	}
	
	public Boolean invokeBackend(){
		Boolean returnVal = true;
		String previousResponse = null;
		Map<Integer,String> prevResponseMap = new Map<Integer,String>();
		for(Backend backendObj:backendList){
			if(AppDConstants.Backend_Mode == AppDconstants.Backend_Mode_REQ_PARAM){
				restAPIObj = new JsonRESTAPI(backendObj.url,backendObj.requestMethod,backendObj.getParameters(),previousResponse,prevResponseMap);//new SimpleRESTAPI(backendObj.url,backendObj.requestMethod,backendObj.getParameters(),previousResponse,prevResponseMap);
			}else{
				restAPIObj = new JsonRESTAPI(backendObj.url,backendObj.requestMethod,backendObj.getParameters(),previousResponse,prevResponseMap);
			}
			System.debug('Invoking remote service - Start');
			Map<String,String> headersMap = new Map<String,String>();
			Long timestamp = DateTime.now().getTime();
			String signatureKey = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.privateKey) + timestamp;
			Blob signatureBlob = Blob.valueOf(signatureKey);
			String signature = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', signatureBlob));
			headersMap.put('Timestamp',  '' + timestamp);
			headersMap.put('Api_token', EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.apiToken));
			headersMap.put('Signature' , signature);
			restAPIObj.headers = headersMap;
			restAPIObj.invoke();
			System.debug('Invoking remote service - End');
			if(restAPIObj.response!=null){
				backendObj.response = restAPIObj.response.getBody();
				previousResponse = backendObj.response;
				prevResponseMap.put(backendObj.opCode,previousResponse);
				backendObj.statusCode = restAPIObj.response.getStatusCode();
				
				if(backendObj.statusCode!=200){
					returnVal = false;
					/*backendObj.errorMessage ='REQUEST URL:'+restAPIObj.serviceURL;
					backendObj.errorMessage +='\nREQ PARAM:'+restAPIObj.requestBody;
					backendObj.errorMessage += 'Params Count:'+backendObj.getParameters().size();
					backendObj.errorMessage +='\nREQ Method:'+restAPIObj.requestMethod;*/
					//backendObj.errorMessage += '\nBackend returned with a error:'+restAPIObj.response.getStatusCode();
					backendObj.errorMessage = restAPIObj.response.getBody();
					//backendObj.errorMessage +='\nResponse:'+restAPIObj.response.getBody();
					backendObj.handleError(backendObj.errorMessage);
					return false;
				}
				backendObj.handleResponse(backendObj.response, backendObj.statusCode);
				//return data.responseStatusCode==200;
			}else{
				backendObj.errorMessage = 'Request URL not found or not responding.';
				returnVal = false;
			}
		}
		return returnVal;
	}
	
	/*public String getResponse(){
		String response = '';
		for(Backend bk:backendList){
			Integer opcode = bk.opCode;
			response+='::RES for OPCODE:'+opcode+' = '+getResponse(opcode);
		}
		return response;
	}*/
	
	public String getResponse(Integer backendOpcode){
               if(RESTAPI.unitTestMode){
    		return BackendConstants.UNIT_TEST_RESPONSES_MAP.get(backendOpcode);
    	         }
		for(Backend data:backendList){
			if(data.opcode == backendOpcode && data.statusCode==200){
				return data.response;
			}
		}
		return null;
	}
	
	public String getStatusCode(Integer backendOpcode){
		for(Backend data:backendList){
			if(data.opcode == backendOpcode && data.statusCode==200){
				return data.statusCode+'';
			}
		}
		return null;
	}
	
	public class BackendParameter{
		public Backend backendData;
		public List<Backend> backendList;
		public Integer backendParameterType{get;set;}
		public Integer chainOpcode{get;set;}
		public BackendParameter(){
			this.chainOpcode = -1;
			this.backendParameterType = BackendConstants.BACKEND_PARAM_TYPE_SIMPLE;
		}
		
		public BackendParameter(String key, List<JSONObject.value> valArray){
			this.chainOpcode = -1;
			this.key = key;
			this.jsonArrayVal = valArray;
			this.backendParameterType = BackendConstants.BACKEND_PARAM_JSON_ARRAY;
		}
		public BackendParameter(String key, String value){
			this.chainOpcode = -1;
			this.key = key;
			this.value = value;
			if(this.value!=null){
				this.value = this.value.replace('\\','');
			}
			this.backendParameterType = BackendConstants.BACKEND_PARAM_TYPE_SIMPLE;
		}
		
		public BackendParameter(String key,Backend backend){
			this.chainOpcode = -1;
			this.key = key;
			this.backendData = backend;
			this.backendParameterType = BackendConstants.BACKEND_PARAM_TYPE_BACKEND;
		}
		
		public BackendParameter(String key,Integer value){
			this.chainOpcode = -1;
			this.key = key;
			this.intVal= value;
			this.backendParameterType = BackendConstants.BACKEND_PARAM_INT_VALUE;
		}
		
		public BackendParameter(String key,List<Backend> values){
			this.chainOpcode = -1;
			this.key = key;
			this.backendList= values;
			this.backendParameterType = BackendConstants.BACKEND_PARAM_TYPE_LIST_OF_BACKEND;
		}
		
		public BackendParameter(String key,Boolean value){
			this.chainOpcode = -1;
			this.key = key;
			this.booleanVal = value;
			this.backendParameterType = BackendConstants.BACKEND_PARAM_BOOLEAN_VALUE;
		}
		
		public Boolean usePreviousBackendResponse;
		public Integer prevBackendOpcodeForValue;
		public String key{get;set;}
		public String value{get;set;}
		public Integer intVal{get;set;}
		public Boolean booleanVal{get;set;}
		public List<JSonObject.value> jsonArrayVal{get;set;} 
		public JSONObject.value jsonValue{get;set;} 
	}
}