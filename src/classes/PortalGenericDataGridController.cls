public with sharing class PortalGenericDataGridController {
	
	public String gridTitle{get;set;}
	
	public PortalGenericMapList dataRowList{
		get;
		set{
			dataRowList = value;
			/*ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Set Data Row List called:'+dataRowList);
	        ApexPages.addMessage(myMsg);*/
	        
			if(value!=null && rowList==null){
				rowList = value.rowList;
			}
		}
	}
	
	public list<PortalGenericMap> backupRowList{get;set;}
	
	public List<String> columnNames{
		get{
			if(dataRowList!=null && dataRowList.size()>0){
				return dataRowList.get(0).columnNames;
			}
			return null;
		}
	}
	
	public list<PortalGenericMap> rowList{get;set;}
	
	public String debugMsg{get;set;}
	public boolean groupingNeeded{
		get{
			if(dataRowList!=null){
				return dataRowList.hasGrouping;
			}
			return false;
		}
	}
	
	boolean filteringApplied = false;
	public String selectedValue{get;set;}
	public PageReference applySelection(){
		System.debug(LoggingLevel.Info,'Calling ApplySelection');
		Integer rowIndex=0;
		//debugMsg= 'Calling ApplySelection:'+displayData.filteringDataList.size();
		map<String,String> filterColumnSelections = new map<String,String>();
		for(FilteringData filteringDataObj:displayData.filteringDataList){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Filtering Value Selection handler:'+filteringDataObj.filteringColumnName+'='+filteringDataObj.filteringSelectedValue+'\n'+filteringDataObj.filteringSelectedValue);
	        ApexPages.addMessage(myMsg);
			System.debug(LoggingLevel.Info,'Filtering Value Selection handler:'+filteringDataObj.filteringColumnName+'='+filteringDataObj.filteringSelectedValue);
			//debugMsg+=filteringDataObj.filteringColumnName+'='+filteringDataObj.filteringSelectedValue+'\n';
			filterColumnSelections.put(filteringDataObj.filteringColumnName,filteringDataObj.filteringSelectedValue);
		}
		//debugMsg+='Calling Filter Logic:'+filterColumnSelections;
		System.debug(LoggingLevel.Info,'Calling Filter Logic:'+filterColumnSelections);
		try{
			//debugMsg+='ROWLISTBEFORE:'+dataRowList.rowList;
			rowList = dataRowList.filterValuesForSelection(filterColumnSelections);
			//debugMsg+='ROW LIST:'+rowList+' Set';
		}catch(Exception e){
			//debugMsg+='Exception:'+e.getMessage();
		} 
		return null;
	}
	
	/*public void sortValues(){
		String key = Apexpages.currentPage().getParameters().get('key');
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Key:'+key);
        ApexPages.addMessage(myMsg);
		rowList = dataRowList.sortDataRows(key);
	}*/
	
	public String searchKeyword{get;set;}
	/*
	public PageReference searchRows(){
		rowList = dataRowList.searchRows(searchKeyword);
		return null;
	}*/
	
	public boolean isPortalGenericMap(Object val){
		return (val instanceof PortalGenericMap);
	}
	
	public String filteringColumnNamesCSV{
		get;
		set{
			filteringColumnNamesCSV = value;
			buildFilteringColumnLevelsMap();
		}
	}
	
	public map<Integer,String> filteringColumnsLevelMap{get;set;}
	
	private void buildFilteringColumnLevelsMap(){
		filteringColumnsLevelMap = new map<Integer,String>();
		if(filteringColumnNamesCSV!=null){
			String[]columnNames = filteringColumnNamesCSV.split(',');
			for(integer i=0;i<columnNames.size();i++){
				String colname = columnNames[i];
				filteringColumnsLevelMap.put(i,colname);
			}
		}
	}
	
	private void setupPortalDisplayData(){
		{
			displayData = new PortalGenericDisplayData();
			displayData.dataSet = dataRowList;
			updateFilteringData();
		}
	}
	
	private void updateFilteringData(){
		//get filtering column names
		//for each filtering column names get unique values
		//construct the filtering column selection data
		integer filterLevel = 0;
		if(filteringColumnsLevelMap!=null){
			System.debug(LoggingLevel.Info,'FilteringData for:'+filteringColumnsLevelMap);
			for(Integer level:filteringColumnsLevelMap.keySet()){
				FilteringData filterData = new FilteringData();
				String colName = filteringColumnsLevelMap.get(level);
				if(colName!=null && dataRowList!=null){
					Set<String> uniqueValues = dataRowList.getUniqueValues(colName);
					filterData.filteringLevel = filterLevel++;
					filterData.filteringColumnName = colName;
					filterData.filteringSelectionValues = uniqueValues;
					filterData.filteringSelectedValue=null;
					displayData.addFilteringData(filterData);
				}
			}
		}
	}
	

	
	public PortalGenericDisplayData displayData {
		get{
			if(displayData==null){
				if(dataRowList!=null){
					setupPortalDisplayData();
				}
			}
			return displayData;
		}
		set;
	}
	
	public class PortalGenericDisplayData{
		public list<FilteringData> filteringDataList {
			get{
				if(filteringDataList==null){
					filteringDataList = new List<FilteringData>();
				}
				return filteringDataList;
			}
			set;
		}
		public transient PortalGenericMapList dataSet {get;set;}
		
		public void addFilteringData(FilteringData filteringDataObj){
			filteringDataList.add(filteringDataObj);
		}
	}
	
	public class FilteringData{
		public FilteringData(){
			System.debug(LoggingLevel.INFO,'ConstructingFilteringData');
		}
		public Integer filteringLevel {get;set;}
		public String filteringColumnName{get;set;}
		public String filteringSelectedValue{get;set;}
		public set<String> filteringSelectionValues{
			get;
			set{
				filteringSelectionValues = value;
				filteringSelectOptions = new list<SelectOption>();
				filteringSelectOptions.add(new SelectOption('--None--','--None--'));
				for(String val:value){
					SelectOption selOption = new SelectOption(val,val);
					filteringSelectOptions.add(selOption);
				}
			}
		}
		public list<SelectOption> filteringSelectOptions{get;set;}
	}
	
	public virtual class ChartData{
		public String chartTitle{get;set;}
		public String chartType{get;set;}
	}
	public class LineChartData extends ChartData{
		public list<map<String,String>> lineSeriesDataList{get;set;}
		public list<String> xaxisData{get;set;}
	}
}