/*
	*License History Controller provides following functionalities:
	*Querys for all History records for a license.
	*Maps each history record with HistoryWrapper.
	*Builds actionable String for each history record.
*/
public with sharing class LicenseHistoryController_V2 {
	public License_History_Tracking__c licHistoryObj{get;set;} 
	public String licenseIdCtrller;
	
	/*
		Returns license record id.
	*/
	public String getLicenseIdCtrller(){
		return licenseIdCtrller;
	}
	
	/*
		Sets license record id.
	*/
	public void setLicenseIdCtrller(String param){
		this.licenseIdCtrller = param;
	}
	
	public List<HistoryWrapper> licenseHistories{get{return getHistoryWrappers(licenseIdCtrller);}set;}
	
	/*
		Returns list of HistoryWrapper values.
	*/
	public List<HistoryWrapper> getHistoryWrappers(String licenseID){
		List<HistoryWrapper> returnVal= new List<HistoryWrapper>();
		try{
			List<License_History_Tracking__c> licHistoryList = [SELECT Id, License__c, License_Operation__c, Status__c, CreatedDate, CreatedById,User__c, DateTime__c, (select Id, New_Value__c, Old_Value__c, Property_Field_Name__c, Property_Object_ID__c, Property_Object_Name__c, CreatedDate, CreatedById from License_History_Property__r) 
																FROM License_History_Tracking__c where License__c=:licenseID and Status__c = 'SUCCESS' order By DateTime__c desc];
		
		
			if(licHistoryList!=null && licHistoryList.size()>0){
				Integer maxIndex = licHistoryList.size();
				for(Integer i = 0;i<licHistoryList.size(); i++){
					License_History_Tracking__c lht = licHistoryList.get(i);
					/*
						Checking if there are any License Properties.
					*/ 
					if(lht.License_History_Property__r.size()>0){
						HistoryWrapper history = new HistoryWrapper(lht,i,maxIndex-1);
						returnVal.add(history);
					}
				}
			}
		}catch(Exception e){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getStackTraceString());
            ApexPages.addMessage(myMsg);
		}
		return returnVal;
	}
	
	/*
		Wrapper class used to map each history record with Actionable String.
	*/
	public class HistoryWrapper{
		public License_History_Tracking__c actualHistory{get;set;}
		public Integer index {get;set;}
		public Integer maxIndex {get;set;}
		
		public HistoryWrapper(License_History_Tracking__c actualHistory, Integer index, Integer maxIndex){
			this.actualHistory = actualHistory;
			this.index = index;
			this.maxIndex = maxIndex; 
		}
		
		/*
			Builds Actionable string which contains old and new history details.
		*/
		public String getActionString(){
			String sActionFormat = 'Changed <b>LicenseData</b>';
			String newValues = '<b>';
			String oldValues = '';
			
			Map<String,String> newValuesMap = new Map<String,String>();
			Map<String,String> oldValuesMap = new Map<String,String>();
			 
			String newValuesString = '';
 			String oldValuesString = '';
 			
 			for(License_History_Property__c lhp: actualHistory.License_History_Property__r){
 				if(HistoryMap.objectsFieldsAndLabelNamesMap.get(lhp.Property_Object_Name__c)!=null && HistoryMap.objectsFieldsAndLabelNamesMap.get(lhp.Property_Object_Name__c).get(lhp.Property_Field_Name__c)!=null){
 					newValuesString +=''+HistoryMap.objectsFieldsAndLabelNamesMap.get(lhp.Property_Object_Name__c).get(lhp.Property_Field_Name__c)+':'+lhp.New_Value__c+'; ';
 					oldValuesString +=''+HistoryMap.objectsFieldsAndLabelNamesMap.get(lhp.Property_Object_Name__c).get(lhp.Property_Field_Name__c)+':'+lhp.Old_Value__c+';' ;
 				}
 			}
 			
 			if(index == maxIndex){
				sActionFormat +=' to <b>'+newValuesString+'</b>';
			} else{
				sActionFormat +=' from '+oldValuesString+' to <b>'+newValuesString+'</b>';
			}
            return sActionFormat;
		}	
	}
}