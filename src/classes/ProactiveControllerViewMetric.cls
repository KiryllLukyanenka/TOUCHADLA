public with sharing class ProactiveControllerViewMetric {
	public ProactiveViewModelMetric metricData{
		get;
		set{
			metricData = value;
			if(value!=null){
				selectedChartKey = value.selectedChartKey;
				selectedChartData = value.chartDataMap.get(selectedChartKey);
				chartDataMap = new map<Object,ProactiveViewModelChart>();
				for(String key:value.chartDataMap.keySet()){
					chartDataMap.put(key,value.chartDataMap.get(key));
				}
			}
		}
	}
	public Map<Object,ProactiveViewModelChart> chartDataMap{get;set;}
	private String selectedChartKey;
	
	public String getSelectedChartKey(){
		return selectedChartKey;
	}
	
	public void setSelectedChartKey(String val){
		this.selectedChartKey = val;
	}
	
	private ProactiveViewModelChart selectedChartData;
	
	public ProactiveViewModelChart getSelectedChartData(){
		return metricData.chartDataMap.get(metricData.selectedChartKey);
	}
	
	public String debugMessage{get;set;}
	
	
	public PageReference applySelection(){
		debugMessage = 'Apply Selection called for:'+metricData.selectedChartKey;
		selectedChartData = metricData.chartDataMap.get(metricData.selectedChartKey);
		//debugMessage = 'Chart data to be loaded:'+selectedChartData;
		System.debug(debugMessage);
		return null;
	}
}