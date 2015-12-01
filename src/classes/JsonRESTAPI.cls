public with sharing class JsonRESTAPI extends RESTAPI{
	//private List<BackendLayer.BackendParameter> params;
	
	public JsonRESTAPI(String url, String method, List<BackendLayer.BackendParameter> params, String previousResponse, Map<Integer,String> prevResponeMap ){
		this.requestMethod = method;
		serviceURL = url;
		String jsonString = '';
		JSONObject json = null;
		if(params!=null)
		{
			json = getJSon(params,previousResponse,prevResponeMap);
		}
		if(json!=null){
			jsonString = json.valueToString();
		}
		if('POST'.equals(method)){
			requestBody = jsonString;
			
		}else if('GET'.equals(method)){
			if(jsonString!=null && !jsonString.trim().equals('')){
				serviceURL+='?'+jsonString;
			}
		}
		
	}
	
	private JSONObject getJSon(List<BackendLayer.BackendParameter> params,String previousResponse, Map<Integer,String> prevResponeMap){
		JSONObject json = null;
		for(BackendLayer.BackendParameter param: params){
				JSONObject.value jsonVal = null;
				if(param.backendParameterType == BackendConstants.BACKEND_PARAM_TYPE_LIST_OF_BACKEND){
					String jsonValStr = '';
					List<JSonObject.value> jsonValues = new List<JSonObject.value>();//JSONObject.jsonarray ( new JSONObject.JSONTokener ('['+jsonValStr+']'));
					for(Backend child:param.backendList){
						List<BackendLayer.BackendParameter> childParams = child.getParameters();
						JSonObject childJSon = getJSon(childParams,previousResponse,prevResponeMap);
						jsonValues.add(new JSonObject.value(childJSon));
						//jsonValStr +=childJSon.valueToString()+',';
					}
					
					jsonVal =  new JSonObject.value(jsonValues); 
				}else if(param.backendParameterType == BackendConstants.BACKEND_PARAM_TYPE_BACKEND){
					Backend child = param.backendData;
					List<BackendLayer.BackendParameter> childParams = child.getParameters();
					JSonObject childJSon = getJSon(childParams,previousResponse,prevResponeMap);
					jsonVal =  new JSonObject.Value(childJSon);//new JSonObject.value(jsonValStr);
				}
				if(param.backendParameterType == BackendConstants.BACKEND_PARAM_TYPE_URL_APPEND){
					serviceURL+=param.value+'/';
				}else if(param.backendParameterType == BackendConstants.BACKEND_PARAM_TYPE_CHAIN_RESPONSE){
					Integer prevOpCode = param.chainOpcode;
					String prevResponse = prevResponeMap.get(prevOpCode);
					if(prevResponse==null){
						prevResponse = previousResponse;
					}
					if(prevResponse!=null){
						jsonVal = new JSONObject.value();
						jsonVal.str = prevResponse;
					}
				} 
				if(param.backendParameterType == BackendConstants.BACKEND_PARAM_TYPE_SIMPLE){
					jsonVal = new JSONObject.value(param.value);
					//jsonVal.str = param.value;
				}else if(param.backendParameterType == BackendConstants.BACKEND_PARAM_JSON_ARRAY){
					jsonVal = new JSONObject.value(param.jsonArrayVal);
				}else if(param.backendParameterType == BackendConstants.BACKEND_PARAM_INT_VALUE){
					jsonVal = new JSONObject.value();
					jsonVal.num= param.intVal;
				}
				if(jsonVal!=null){
					if(json == null){
						json = new JSONObject();
					}
					json.putOpt(param.key, jsonVal);
				}
			}
			return json;
	}
}