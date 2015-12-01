public with sharing class LicenseHistoryController {
	
	// For test code coverage
	public LicenseHistoryController(String forTest){}
	
	/*
	public LicenseDetail__c licObj{get;set;} 
	public String licenseIdCtrller;
	public String getLicenseIdCtrller(){
		return licenseIdCtrller;
	}
	public void setLicenseIdCtrller(String param){
		this.licenseIdCtrller = param;
	}
	
	public List<HistoryWrapper> licenseHistories{get{return getHistoryWrappers(licenseIdCtrller);}set;}
		
	public List<HistoryWrapper> getHistoryWrappers(String licenseID){
		licObj= (LicenseDetail__c)DataLayerConstants.fetchSingle('LicenseDetail__c',licenseId);
		List<HistoryWrapper>returnVal= new List<HistoryWrapper>();
		if(licObj!=null){
			List<LicenseDetail__History>licenseHistories = [select Id,CreatedDate,CreatedById,Field,OldValue,NewValue from LicenseDetail__History where parentId=:licObj.Id ORDER BY CreatedDate DESC];
			for(LicenseDetail__History licHistory:licenseHistories){
				HistoryWrapper history = new HistoryWrapper();
				history.actualHistory = licHistory;
				returnVal.add(history);
			}
		}
		return returnVal;
	}
		
	public LicenseHistoryController(){
	}
	
	public LicenseHistoryController(ApexPages.StandardController stdController){
	}
	
	public class HistoryWrapper{
		public LicenseDetail__History actualHistory{get;set;}
	
		public String getActionString(){
			string sActionFormat = '';
 
            if (actualHistory!= null) {
                sActionFormat = 'Record {0}.';
 				
                if (actualHistory.newValue != null && actualHistory.oldValue == null) {
                    sActionFormat = 'Changed <strong>{1}</strong> to <strong>{3}</strong>.';
                }
                else if (actualHistory.newValue != null && actualHistory.oldValue != null) {
                    sActionFormat = 'Changed <strong>{1}</strong> from {2} to <strong>{3}</strong>.';
                }
                else if (actualHistory.Field != null && actualHistory.Field.equalsIgnoreCase('created')) {
                    sActionFormat = 'Created.';
                }
            }
 
            return sActionFormat;
		}	
	}*/
}