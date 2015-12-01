public virtual class Backend {
	public Backend(){
		
	}
	public String url{get;set;}
	public String requestMethod{get;set;}
	public Integer opCode{get;set;}
	private List<BackendLayer.BackendParameter> parameters=new List<BackendLayer.BackendParameter>();
	public Integer statusCode{get;set;}
	public String response{get;set;}
	public String errorMessage{get;set;}
	
	public SObject sfObject{get;set;} 
	
	public HttpRequest requestObj {get;set;}
	public HttpResponse responseObj {get;set;}
	
	public Backend(SObject sObj,Integer opCode){
		this.sfObject = sObj;
		this.opCode = opCode;
		//setupInputParameters();
	}
	public List<BackendLayer.BackendParameter> getParameters(){
		return parameters;
	}
	public void setParameters(List<BackendLayer.BackendParameter> params){
		this.parameters = params;
	}
	public virtual void setupInputParameters(){
		
	}
	
	public virtual void handleResponse(String response, Integer statusCode){
		this.response = response;
		this.statusCode = statusCode;
	}
	
	public virtual void handleError(String errorMessage){
		this.errorMessage = errorMessage;
	}
}