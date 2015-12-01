public virtual class PortalGenericMap {
	//public Integer groupingLevel;
	public map<String,PortalGenericMapValue> internalMap{
		get{
			if(internalMap==null){
				internalMap = new map<String,PortalGenericMapValue>();
			}
			return internalMap;
		}
		set;
	}
	
	public PortalGenericMapValue getValue(String key){
		return internalMap.get(key);
	}
	
	public void setValue(String key, Object value){
		columnNames.add(key);
		internalMap.put(key,new PortalGenericMapValue(value));
	}
	
	/*public void setValue(String key, Object value, Integer groupingLevel){
		setValue(key,value);
		this.groupingLevel = groupingLevel;
	}*/

	public list<String> columnNames{
		get{
			if(columnNames==null){
				columnNames = new list<String>();	
			}
			return columnNames;
		}
		set;
	}
	
	
	public class PortalGenericMapValue{
		public PortalGenericMapValue(){}
		public PortalGenericMapValue(Object val){
			this.val = val;
		}
		public Object val{get;set;}
		public boolean isPortalGenericMap{
			get{
				return val!=null && val instanceof PortalGenericMap;
			}
			set;
		}
	}
}