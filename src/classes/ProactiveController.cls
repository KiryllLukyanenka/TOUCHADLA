public abstract class ProactiveController {
	public String accountId{
		get;
		set{
			accountId = value;
			if(uiData!=null){
				uiData.accountId = accountId;
			}
		}
	}
	
	public ProactiveViewModelMetric uiData{get;set;}
	
	public ProactiveRequest proactiveRequest{
		get{
			if( proactiveRequest==null){
				buildRequest();
			}
			return proactiveRequest;
		}
		set;
	}
	public ProactiveResponse proactiveResponse{
		get{
			if(proactiveResponse == null){
				buildResponse();
			}
			return proactiveResponse;
		}
		set;
	}
	
	public ProactiveBackend proactiveBkend{
		get{
			if(proactiveBkend == null){
				proactiveBkend = buildProactiveBackend();
			}
			return proactiveBkend;
		}
		set;
	}
	
	public transient list<PortalGenericMap>  statsDataList {get;set;}
	public transient PortalGenericMapList  statsDataRows {get;set;}
	
	public String metric{
		get;
		set{
			metric = value;
		}
	}
	public String pageTitle{get;set;}
	
	public abstract void buildRequest();
	
	public abstract void buildResponse();
	
	public abstract ProactiveBackend buildProactiveBackend();
	
	public virtual PageReference invokeProactive(){
		try{
			/*ProactiveBackend backend = buildProactiveBackend();
			backend.request = proactiveRequest;
			backend.proactiveResponse = proactiveResponse;*/
			proactiveBkend.invoke();
			this.statsDataList = proactiveResponse.responseDataList;
			this.statsDataRows = proactiveResponse.dataRows;
			System.debug(LoggingLevel.Info,'ProactiveResponse data rows:'+statsDataRows);
			if(metric=='LOGIN_STATS'){
				uiData = new ProactiveViewModelMetric.LoginStats(accountId,statsDataRows);
			}
		}catch(Exception e){
			String errorMessage = '';
			if(e!=null){
				errorMessage+=e.getMessage()+'\nStack:'+e.getStackTraceString();
			}
			showErrorMessage(errorMessage);
		}
		return null;
	}
	
	/*
	 * Common Helper method to show Error message on the VisualForce Page
	 */
	public void showErrorMessage(String message){
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,message);
        ApexPages.addMessage(myMsg);
	}
	
	public Boolean reload{get;
		set{
			reload=value;
			if(reload){
				try{
					invokeProactive();
				}catch(Exception e){
					showErrorMessage(e.getMessage()+'\n'+e.getStackTraceString());
				}
			}		
		}
	}
}