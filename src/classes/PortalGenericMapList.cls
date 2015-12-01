public virtual class PortalGenericMapList {
	
	public PortalGenericMapList(){
	}
	
	public PortalGenericMapList(list<PortalGenericMap> rowList){
		this.rowList = rowList;
	}
	
	public PortalGenericMapList(list<PortalGenericMap> rowList, map<Integer,String> keyGroupingLevelMap){
		this.rowList = rowList;
		this.groupByLevelKeysSelections = keyGroupingLevelMap;
		setupDataGrouping();
	}
	
	public list<PortalGenericMap> rowList{
		get{
			if(rowList==null){
				rowList = new list<PortalGenericMap>();
			}
			return rowList;
		}
		set;
	}

	public Boolean isEmpty{
		get{
			return this.rowList==null || this.rowList.size()==0;
		}
	}
	
	public PortalGenericMap get(integer index){
		return rowList.get(index);
	}
	
	public integer size(){
		return rowList.size();
	}
	
	public map<Integer,String> groupByLevelKeysSelections{
		get{
			if(groupByLevelKeysSelections==null){
				groupByLevelKeysSelections = new map<Integer,String>();
			}
			return groupByLevelKeysSelections;
		}
		set;
	}
	
	public Boolean hasGrouping{
		get{
			return groupByLevelKeysSelections.size()>0;
		}
	}
	
	public Set<Integer> groupingLevels{
		get{
			return groupByLevelKeysSelections.keySet();
		}
	}
	
	public map<Integer,set<String>> groupBySelections{
		get{
			if(groupBySelections==null){
				groupBySelections = new map<Integer,set<String>>();
			}
			return groupBySelections;
		}
		set;
	}
	
	public virtual void setupDataGrouping(){
		System.debug(LoggingLevel.Info,'#Srinidhi setting up grouping');
		try{
			if(hasGrouping){
				for(Integer groupingLevel:groupingLevels){
					String key = groupByLevelKeysSelections.get(groupingLevel);
					for(PortalGenericMap row:rowList){
						String rowVal = row.getValue(key).val+'';
						set<String> selections = groupBySelections.get(groupingLevel);
						if(selections == null){
							selections = new set<String>();
							groupBySelections.put(groupingLevel,selections);
						}
						if(!selections.contains(rowVal)){
							selections.add(rowVal);
						}
					}
				}
			}
		}catch(Exception e){
			System.debug(LoggingLevel.Error,'Exception in Grouping:'+e.getMessage()+'::Stack:'+e.getStackTraceString());
		}
		System.debug(LoggingLevel.Info,'#Srinidhi Has groupings:'+hasGrouping);
		System.debug(LoggingLevel.Info,'#Srinidhi set up selections:'+groupBySelections);
	}
	
	
	
	public list<PortalGenericMap> filterValuesForSelection(map<String,String> levelValuesMap){
		System.debug(LoggingLevel.INFO, '#SRINIDHI:Filtering started');
		list<PortalGenericMap> groupSelection = this.rowList; 
		System.debug(LoggingLevel.INFO, 'Filtering started');
		for(String filterColName:levelValuesMap.keySet()){
			String valtoFilter = levelValuesMap.get(filterColName);
			System.debug(LoggingLevel.INFO, 'Field to filter:'+filterColName+' val to filter:'+valtoFilter);
			if(valtoFilter!=null && !valtoFilter.trim().equals('--None--') && !valtoFilter.trim().equals('')){
				groupSelection = getFilteredValues(groupSelection, filterColName, valtoFilter);
			}
		}
		return groupSelection;
	}
	
	public list<PortalGenericMap> getFilteredValues(list<PortalGenericMap> sourceValues, String key, String valueToFilter){
		list<PortalGenericMap> filteredValues = new list<PortalGenericMap>();
		for(PortalGenericMap portalGenericMapSrc:sourceValues){
			String val = portalGenericMapSrc.internalMap.get(key).val+'';
			if(valueToFilter.equalsIgnorecase(val)){
				filteredValues.add(portalGenericMapSrc);
			}
		}
		return filteredValues;
	}
	
	public Set<String> getUniqueValues(String colName){
		Set<String> uniqueValues = new Set<String>();
		for(PortalGenericMap row:rowList){
			if(row.getValue(colName)!=null){
				String val = row.getValue(colName).val+'';
				if(!uniqueValues.contains(val)){
					uniqueValues.add(val);
				}
			}
		}
		return uniqueValues;
	}
}