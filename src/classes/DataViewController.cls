public with sharing class DataViewController {
	public transient List<SObject> dataSet{get;set;}
	public transient List<String> columnAccessVars{get;set;}
	public transient list<map<String,String>> dataValueMapList{get;set;}
	public String soql{get;set;}
	public String dateTimeFilterField{get;set;}
	public String timeRange{get;set;}
	public String timeFilterStartTime{get;set;}
	public String timeFilterEndTime{get;set;}
	private boolean refreshData;
	
	public boolean getRefreshData(){
		return refreshData;
	}
	public void setRefreshData(boolean refeshData){
		this.refreshData=refreshData;
		try{
			loadData();
		}catch(Exception e){
			EmailUtil.notifyError(e,null);
		}
	}
	
	private void loadData(){
		String soql = this.soql;
		system.debug('SOQL:'+soql);
		String colNamesStr = soql.toUpperCase().substring(soql.indexOf('SELECT')+'SELECT'.length()+1);
		colNamesStr = colNamesStr.substring(0,colNamesStr.lastIndexOf('FROM'));
		system.debug('COL NAmes:'+colNamesStr);
		colNamesStr = colNamesStr.trim();
		columnAccessVars = colNamesStr.split(',');
		/*if(dateTimeFilterField!=null && !dateTimeFilterField.trim().equals('')){
			DateTime startDate=null;
			DateTime endDate=null;
			if(timeRange!=null){
				if('WEEKLY'.equals(timeRange)){
					startDate = System.now().addDays(-7);
					endDate = System.now();
				}else if('MONTHLY'.equals(timeRange)){
					startDate = System.now().addDays(-30);
					endDate = System.now();
				}else if('QUARTERLY'.equals(timeRange)){
					startDate = System.now().addDays(-3*30);
					endDate = System.now();
				}else if('WEEKLY'.equals(timeRange)){
					startDate = System.now().addDays(-365);
					endDate = System.now();
				}
			}else{
				startDate = Datetime.parse(timeFilterStartTime);
				endDate = Datetime.parse(timeFilterEndTime);
			}
			
			if(startDate!=null){
				if(!soql.contains('WHERE')){
					soql+=soql+' WHERE ';
				}
				soql+=dateTimeFilterField+'>'+ startDate;
				
			}
			if(endDate==null){
				endDate = System.now();
				soql+=' AND '+dateTimeFilterField+'<'+ startDate;
			}
		}*/
		System.debug('SOQL Executed:'+soql);
		
		try{
			dataSet = Database.query(soql);
			
		}catch(Exception e){
			system.debug('Exception:'+e.getMessage());
			//EmailUtil.notifyError(e,null);
		}
		if(dataSet.size()==0){
			try{
				SObject sobj = Database.query(soql);
				dataSet.add(sobj);
				system.debug('DATA SET SIZE AFTER ADDING:'+dataset.size());
				system.debug('SOBJECT:'+sobj);
			}catch(Exception e){
				system.debug('Exception:'+e.getMessage());
				//EmailUtil.notifyError(e,null);
			}
		}
		system.debug('Data Set Size:'+dataSet.size());
		parseQueryOutput();
	}
	
	private void parseQueryOutput(){
		dataValueMapList = new list<map<String,String>>();
		map<String, String> colVarToFieldLabelMap = new map<String,String>();
		if(dataSet!=null){
			
			for(SObject sobj:dataSet){
				map<String,String> sobjMap = new map<String,String>();
				map<String,SOBJECT> childSObjectNameMap = new map<String,SOBJECT>();	
				for(String colVar:columnAccessVars){
					System.debug('COL VALUE:'+colVar);
					colVar = colVar.trim();
					if(colVar.contains('.')){
						list<String> colRelHeirarchy = colVar.split('\\.');
						Sobject finalVal=sobj;
						system.debug('COL REL HEIRARCHY:'+colVar+':size:'+colRelHeirarchy.size());
						for(integer i=0;i<colRelHeirarchy.size()-1;i++){
							String colRel = colRelHeirarchy.get(i);
							colRel=colRel.trim();
							for(String key:childSObjectNameMap.keySet()){
								System.debug('##KEY:'+key+' ###VAL:'+childSObjectNameMap.get(key));
							}
							
							SObject childObj = childSObjectNameMap.get(colRel);
							System.debug('MAP GET OF KEY:'+colRel+' IS:'+childObj);
							if(childObj==null){
								System.debug('###SRINIDHI GETTING VALUE OF:'+colRel+' ON OBJECT:'+finalVal);
								finalVal = finalVal.getSObject(colRel);
								childSObjectNameMap.put(colRel,finalVal);
							}else{
								finalVal = childObj;
							}
							System.debug('###SRINIDHI GOT VALUE OF:'+finalVal);
						}
						if(finalVal!=null){
							String fieldName = colRelHeirarchy.get(colRelHeirarchy.size()-1);
							String val = finalVal.get(fieldName)+'';
							String fieldLabel = colVarToFieldLabelMap.get(colVar); 
							if(fieldLabel==null){
								Schema.DescribeSObjectResult objDesc = finalVal.getSObjectType().getDescribe();
								Map<String, Schema.SObjectField> allFields = objDesc.fields.getMap();
								fieldLabel = allFields.get(fieldName).getDescribe().getLabel();
								colVarToFieldLabelMap.put(colVar,fieldLabel);
							}
							sobjMap.put(fieldLabel,val);
							System.debug('Adding to Map:'+colVar+' Value:'+val);
						}
					}else{
						Schema.DescribeSObjectResult objDesc = sobj.getSObjectType().getDescribe();
						String fieldLabel = colVarToFieldLabelMap.get(colVar); 
						if(fieldLabel==null){
							Map<String, Schema.SObjectField> allFields = objDesc.fields.getMap();
							fieldLabel = allFields.get(colVar).getDescribe().getLabel();
							colVarToFieldLabelMap.put(colVar,fieldLabel);
						}	
						sobjMap.put(fieldLabel,sobj.get(colVar)+'');
						
						System.debug('Adding to Map:'+colVar+' Value:'+sobj.get(colVar));
					}
					
				}
				dataValueMapList.add(sobjMap);
			}
		}
		if(dataValueMapList.size()>0){
			set<String> labelNames = dataValueMapList.get(0).keySet();
			columnAccessVars = new list<String>();
			columnAccessVars.addAll(labelNames);
		}
		system.debug('Map Size:'+dataValueMapList.size());
	}
	
	public DataViewController(){
		columnAccessVars = new list<String>();
		dataSet = new list<SObject>();
	}
	
	public String getValue(SObject sobj, String fieldName){
		if(sobj!=null){
			return sobj.get(fieldName)+'';
		}else{
			return 'N/A';
		}
	}
}