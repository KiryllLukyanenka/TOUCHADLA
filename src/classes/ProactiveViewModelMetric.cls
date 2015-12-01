public virtual class ProactiveViewModelMetric {
	public String title;
	
	public String accountId {get;set;}
	
	public Account account{get;set;}
	
	public PortalGenericMapList dataSet{get;set;}
	
	public list<String> filteringColumnNames {get;set;}
	
	public list<SelectOption> chartSelectOptions {
		get{
			if(chartSelectOptions == null){
				chartSelectOptions = new list<SelectOption>();
			}
			return chartSelectOptions;
		}
		set;
	}
	
	public String selectedChartKey{get;set;}
	
	public set<String> chartKeys {
		get{
			if(chartKeys==null){
				chartKeys = new set<String>();
			}
			return chartKeys;
		}
		set;
	}
	
	public list<String> chartKeysList{
		get{
			if(chartKeysList==null){
				chartKeysList = new list<String>();
			}
			return chartKeysList;
		}
		set;}
	
	public map<String,ProactiveViewModelChart> chartDataMap{
		get{
			if(chartDataMap==null){
				chartDataMap = new map<String,ProactiveViewModelChart>();
			}
			return chartDataMap;
		}
		set;
	}
	
	public map<String, list<SelectOption>> selectOptionsForFilteringKeyMap {
		get{
			if(selectOptionsForFilteringKeyMap==null){
				selectOptionsForFilteringKeyMap = new map<String, list<SelectOption>>();
			}
			return selectOptionsForFilteringKeyMap;
		}
		set;
	}
	
	
	public map<String,String> selectedValueForKeyMap {
		get{
			if(selectedValueForKeyMap==null){
				selectedValueForKeyMap = new map<String,String>();
			}
			return selectedValueForKeyMap;
		}
		set;
	}
	
	public ProactiveViewModelMetric(String accountId, PortalGenericMapList dataFromProactive, list<String> filteringColumnNames){
		this.accountId = accountId;
		this.dataSet = dataFromProactive;
		this.filteringColumnNames = filteringColumnNames;
		
		//Proacess Data and build the filtering unique keys and select option values
		setupDataFiltering();
		 
		//Setup the chart data as supported by specific implementation of ProactiveUI
		setupChartData();
		
		for(String chartKey:chartKeysList){
			if(selectedChartKey==null){
				selectedChartKey = chartKey;
			}
			ProactiveViewModelChart chartModel = chartDataMap.get(chartKey);
			if(chartModel!=null){
				chartModel.setupChartValueMap();
				SelectOption chartKeySelOption = new SelectOption(chartKey,chartKey);
				chartSelectOptions.add(chartKeySelOption);
			}
		}
		
	}
	
	
	
	protected virtual void setupDataFiltering(){
		/*
		 * Add a default --none-- filtering option to the map
		 * Go through each data set
		 * If a key is present in filtering key set
		 * get the list of select options from the map selectOptionsForFilteringKeyMap
		 * if list is empty set a new list in the map
		 * add the new selectoption(val,val) to the map
		 */
		
		list<PortalGenericMap> dataRows = dataSet.rowList;
		for(PortalGenericMap dataRow:dataRows){
			//Build filtering
			for(String filteringColumnName:filteringColumnNames){
				list<SelectOption> selectOptionsForCol = selectOptionsForFilteringKeyMap.get(filteringColumnName);
				if(selectOptionsForCol==null){
					selectOptionsForCol = new list<SelectOption>();
					//Add Empty Row for --none-- to indicate no selection which is default
					selectOptionsForCol.add(new SelectOption('--None--','--None--'));
					selectOptionsForFilteringKeyMap.put(filteringColumnName,selectOptionsForCol);
				}
				try{
					String value = dataRow.getValue(filteringColumnName).val+'';
					SelectOption selOption = new SelectOption(value,value);
					selectOptionsForCol.add(selOption);
				}catch(Exception e){
					System.debug(LoggingLevel.Error, 'Error in getting the value for filtering column:'+filteringColumnName);
				}
				if(!selectedValueForKeyMap.containsKey(filteringColumnName)){
					selectedValueForKeyMap.put(filteringColumnName,'--None--');
				}
			}
		}
	}
	
	protected void addChartKey(String chartKey){
		if(!chartKeys.contains(chartKey)){
			chartKeys.add(chartKey);
			chartKeysList.add(chartKey);
		}
	}
	
	protected virtual void setupChartData(){
		//Default Empty Implementation
		System.debug('Called Empty SetupChartData');
	}
	
	private static list<String> filteringcolumNames_LoginStats = new list<String>();
	static{
		filteringcolumNames_LoginStats.add('Controller URL');
		filteringcolumNames_LoginStats.add('Account');
	}
	
	
	public virtual class LoginStats extends ProactiveViewModelMetric{ 
		
		public LoginStats(String accountId, PortalGenericMapList dataFromProactive){
			super(accountId,dataFromProactive,filteringcolumNames_LoginStats);
		}
		
		public PortalGenericMapList loginSummaryChartData {get;set;}
		
		private list<String> controllers {get;set;}
		
		private void addToControllerAccountsChart(String controller, String account, Integer loginCount){
			ProactiveViewModelChart chartDataForController = chartDataMap.get('Controller-'+controller);
			if(chartDataForController == null){
				chartDataForController = new ProactiveViewModelChart.LoginSummaryControllerAccounts(controller);
				chartDataForController.chartKey = 'Controller-'+controller;
				chartDataMap.put('Controller-'+controller,chartDataForController);
			}
			LoginDataSummaryAccount summaryDataForControllerAcc = null;
			for(PortalGenericMap chartRow:chartDataForController.chartDataSet.rowList){
				LoginDataSummaryAccount summaryData = null;
				if(chartRow instanceof LoginDataSummaryAccount){
					summaryData = (LoginDataSummaryAccount) chartRow;
					if(controller.equals('All')){
						if(account.equals(summaryData.controller)){
							summaryDataForControllerAcc = summaryData;
							break;
						}
					}else if(controller.equals(summaryData.controller)){
						if(account!=null && account.equals(summaryData.account)){
							summaryDataForControllerAcc = summaryData;
							break;
						}
					}
				}
			}
			
			if(summaryDataForControllerAcc == null){
				if('All'.equals(controller)){
					summaryDataForControllerAcc = new LoginDataSummaryAccount(account,null,0);
				}else{
					summaryDataForControllerAcc = new LoginDataSummaryAccount(controller,account,0);
				}
				chartDataForController.chartDataSet.rowList.add(summaryDataForControllerAcc);
			}
			summaryDataForControllerAcc.loginCount += loginCount;
		}
		
		/*
		 * Construct the Login Stats chart data set of type PortalGenericMapList for each of the different supported keys
		   1 for all controllers login metric
		   and 1 each for a specific controllers login metric per account
		   and 1 by user for a given controller
		 */
		public override virtual void setupChartData(){
			super.setupChartData();
			System.debug('Called LoginStats SetupChartData');
			addChartKey('Controller-All');
			try{
				for(PortalGenericMap dataRow:dataSet.rowList){
					System.debug(LoggingLevel.Info,'Setting up chart Key for :'+dataRow);
					String controller = dataRow.getValue('Controller URL').val+'';
					String account = dataRow.getValue('Account').val+'';
					Integer logins = 0;
					try{
						logins = Integer.valueOf(dataRow.getValue('Login Count').val);
					}catch(Exception e){
					}
					
					addChartKey('Controller-'+controller);
					
					addToControllerAccountsChart('All',controller,logins);
					
					addToControllerAccountsChart(controller,account,logins);
				}
			}catch(Exception e){
				System.debug(LoggingLevel.info, 'Error in setting up login stats chart data');
				System.debug(LoggingLevel.Error,e);
				System.debug(LoggingLevel.Error,e.getStackTraceString());
			}
			System.debug(LoggingLevel.Info,'ChartKeys:'+chartKeys);
		}
	}
	
	public class LoginDataSummaryAccount extends PortalGenericMap{
		public LoginDataSummaryAccount(String controller, String account,Integer loginCount){
			this.controller = controller;
			this.account = account;
			this.loginCount = loginCount;
		}
		
		public String controller{
			get;
			set{
				controller = value;
				setValue('controller',value);
			}
		}
		
		public String account{
			get;
			set{
				account = value;
				setValue('account',value);
			}
		}
		public Integer loginCount{
			get;
			set{
				loginCount = value;
				setValue('loginCount',value);
				if(value<100){
					axisValue=value;
				}else if(value>100 && value<=500){
					axisValue= 500;
				}else if(value>500 && value<=1000){
					axisValue= 1000;
				}else{
					axisValue= 1000;
				}
			}
		}
		
		public Integer axisValue{
			get;
			set{
				axisValue = value;
				setValue('axisValue',value);
			}
		}
	}
}