public abstract class ProactiveResponse {
	public transient list<PortalGenericMap> responseDataList{get;set;}
	public transient PortalGenericMapList dataRows{get;set;}
	public abstract list<PortalGenericMap> deserialize(Object responseData);

	public virtual class HTTP extends ProactiveResponse{
		public transient String responseStr{get;set;}
		public transient HttpResponse responseObj {get;set;}
		public virtual override list<PortalGenericMap> deserialize(Object responseData){
			responseObj = (HttpResponse) responseData;
			responseStr = responseObj.getBody();
			return responseDataList;
		}
	}
	
	/*public abstract class SOQL extends ProactiveResponse{
		public abstract map<String,String> getFieldNameKeysMap();
		public override virtual list<PortalGenericMap> deserialize(Object responseData){
			responseDataList = new list<PortalGenericMap>();
			dataRows = new PortalGenericMapList(responseDataList);
			map<String,String> fieldNameKeysMap = getFieldNameKeysMap();
			try{
				list<SObject> sobjects = (list<SObject>) responseData;
				for(SObject sobj:sobjects){
					if(sobj!=null){
						PortalGenericMap objMap = new PortalGenericMap();
						for(String fieldName:fieldNameKeysMap.keyset()){
							Object value = sobj.get(fieldName);
							objMap.setValue(fieldNameKeysMap.get(fieldName),value);
						}
						responseDataList.add(objMap);
					}
				}
			}catch(Exception e){
				System.debug(LoggingLevel.Error, 'Error in Deserialization SOQL:'+ e.getMessage());
			}
			return responseDataList;
		}
	}*/
	
	public class AccountStats extends HTTP{
		
		public override list<PortalGenericMap> deserialize(object response){
			super.deserialize(response);
			System.debug(LoggingLevel.Info,'Deserializing Resppnse:'+responseStr);
			list<ProactiveDataType.AccountStat> accStatList  = (list<ProactiveDataType.AccountStat>)System.JSON.deserialize(responseStr,ProactiveDataType.AccountStat[].class);
			System.debug(LoggingLevel.Info,'Done Deserializing Resppnse:'+accStatList);
			System.debug(LoggingLevel.Info,accStatList);
			if(accStatList!=null){
				responseDataList = accStatList;
			}
			dataRows = new ProactiveDataType.AccountStatList(accStatList);
			System.debug(LoggingLevel.Info,'Data Rows:'+dataRows);
			return responseDataList;
		}
	}
	
	public class LoginStats extends HTTP{
		
		public override list<PortalGenericMap> deserialize(object response){
			super.deserialize(response);
			System.debug(LoggingLevel.Info,'Deserializing Resppnse:'+responseStr);
			list<ProactiveDataType.LoginStat> loginStatList  = (list<ProactiveDataType.LoginStat>)System.JSON.deserialize(responseStr,ProactiveDataType.LoginStat[].class);
			System.debug(LoggingLevel.Info,'Done Deserializing Resppnse:'+loginStatList);
			System.debug(LoggingLevel.Info,loginStatList);
			if(loginStatList!=null){
				responseDataList = loginStatList;
			}
			dataRows = new ProactiveDataType.LoginStatList(loginStatList);
			return responseDataList;
		}
	}
	
	
	public class Summary extends HTTP{
		
		public override list<PortalGenericMap> deserialize(object response){
			super.deserialize(response);
			System.debug(LoggingLevel.Info,'Deserializing Resppnse:'+responseStr);
			ProactiveDataType.AccountSummary accountSummary  = (ProactiveDataType.AccountSummary)System.JSON.deserialize(responseStr,ProactiveDataType.AccountSummary.class);
			list<ProactiveDataType.AccountSummary> accSummaryList = new list<ProactiveDataType.AccountSummary>();
			accSummaryList.add(accountSummary);
			System.debug(LoggingLevel.Info,'Done Deserializing Resppnse:'+accSummaryList);
			
			if(accSummaryList!=null){
				responseDataList = accSummaryList;
			}
			dataRows = new PortalGenericMapList(accSummaryList);
			return responseDataList;
		}
	}
	
	public class UsageTrend extends HTTP{
		
		public override list<PortalGenericMap> deserialize(object response){
			super.deserialize(response);
			System.debug(LoggingLevel.Info,'Deserializing Resppnse:'+responseStr);
			list<ProactiveDataType.UsageTrend> usageTrendList  = (list<ProactiveDataType.UsageTrend>)System.JSON.deserialize(responseStr,ProactiveDataType.UsageTrend[].class);
			System.debug(LoggingLevel.Info,'Done Deserializing Resppnse:'+usageTrendList);
			
			if(usageTrendList!=null){
				responseDataList = usageTrendList;
			}
			dataRows = new PortalGenericMapList(usageTrendList);
			return responseDataList;
		}
	}
	
	/*public class LicenseUsage extends HTTP{
		public override list<PortalGenericMap> deserialize(object response){
			super.deserialize(response);
			System.debug(LoggingLevel.Info,'Response:'+response);
			System.debug(LoggingLevel.Info,'Response String:'+responseStr);
			list<ProactiveDataType.LicenseUsage> licenseUsageList  = (list<ProactiveDataType.LicenseUsage>)System.JSON.deserialize(responseStr,ProactiveDataType.LicenseUsage[].class);
			responseDataList = new list<PortalGenericMap>();
			for(ProactiveDataType.LicenseUsage usageFromBkend:licenseUsageList){
				try{
					ProactiveDataType.LicenseUsageUI usageUI = new ProactiveDataType.LicenseUsageUI(usageFromBkend);
					if(usageUI.hasData){
						responseDataList.add(usageUI);
					}
				}catch(Exception e){
					System.debug(LoggingLevel.Error,e.getMessage()+'\n'+e.getStackTraceString());
				}
			}
			System.debug(LoggingLevel.Info,responseDataList);
			dataRows = new PortalGenericMapList(responseDataList);
			return responseDataList;
		}
	}
	*/
	/*public class LicenseStats extends SOQL{
		public override virtual map<String,String> getFieldNameKeysMap(){
			map<String,String> fieldNameKeysMap = new map<String,String>();
			
			return fieldNameKeysMap;
		}
	}*/
}