public virtual class ProactiveViewModelChart {
	public String title{get;set;}
	
	public String chartKey {get;set;}
	
	public list<ProactiveViewModelMetric.LoginDataSummaryAccount> controllerAccountsSummaryLoginChartData{
		get{
			if(controllerAccountsSummaryLoginChartData==null){
				controllerAccountsSummaryLoginChartData = new list<ProactiveViewModelMetric.LoginDataSummaryAccount>();
			}
			return controllerAccountsSummaryLoginChartData;
		}
		set;
	}
	
	public PortalGenericMapList chartDataSet{
		get{
			if(chartDataSet==null){
				chartDataSet = new PortalGenericMapList();
			}
			return chartDataSet;
		}
		set;
	}
	public list<map<String,String>> chartDataValueMap{
		get{
			if(chartDataValueMap==null){
				chartDataValueMap = new list<map<String,String>>();
			}
			return chartDataValueMap;
		}
		set;
	}
	public map<String,String> chartConfigProperties {
		get{
			if(chartConfigProperties == null){
				chartConfigProperties = new map<String, String>();
			}
			return chartConfigProperties;
		}
		set;
	}
	
	public void setupChartValueMap(){
		for(PortalGenericMap chartData:chartDataSet.rowList){
			if(chartData instanceof ProactiveViewModelMetric.LoginDataSummaryAccount){
				controllerAccountsSummaryLoginChartData.add((ProactiveViewModelMetric.LoginDataSummaryAccount)chartData);
			}
		}
		//system.debug(LoggingLevel.Info, 'Chart Data Row Set:'+chartDataSet.rowList);
		//system.debug(LoggingLevel.Info, 'Chart Data:'+controllerAccountsSummaryLoginChartData);
	}
	
	public class LoginSummaryControllerAccounts extends ProactiveViewModelChart{
		public LoginSummaryControllerAccounts(String controller){
			super();
			chartConfigProperties.put('dataField','loginCount');
			if('All'.equals(controller)){
				title = 'Trend of Logins across all controller';
				chartConfigProperties.put('labelField','controller');
			}else{
				title = 'Trend of Logins across all accounts of controller:'+controller;
				chartConfigProperties.put('labelField','account');
			}
		}
	}
	
	public String chartDataStr{
		get{
			return 'Chart of Type:'+title;
		}
	}
}