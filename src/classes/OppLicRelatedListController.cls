public with sharing class OppLicRelatedListController {/*
	public String oppId{get;set;}
	public List<LicenseDetail__c> licenses{get{return licenses = Database.query('select Id,Name,License_Expiry_Date__c,Server_Agents__c,Net_Agents__c,Machine_Agents__c,MAC_Address__c from LicenseDetail__c where ID in (select License__c from License_Opportunity__c where Opportunity__c=\''+oppId+'\')');}set;}
	public List<HistoryWrapper> licenseHistories{get{return getHistroyWrappers();}}
	
	public OppLicRelatedListController(){
		//init();
	}
	
	private List<HistoryWrapper> getHistroyWrappers(){
		List<HistoryWrapper> historyWrappers = new List<HistoryWrapper>();
		LicenseDetail__c[] licIds = [select ID from LicenseDetail__c where ID IN (Select License__c from License_Opportunity__c where Opportunity__c =: oppId)];
		if(licenses!=null && licenses.size()>0){
			List<LicenseDetail__History>histories = [select Id,CreatedDate,CreatedById,Field,OldValue,NewValue from LicenseDetail__History where parentId IN:licIds ORDER BY CreatedDate DESC LIMIT 100];
			for(LicenseDetail__History licHistory:histories){
				HistoryWrapper history = new HistoryWrapper();
				history.actualHistory = licHistory;
				historyWrappers.add(history);
			}
		}
		return historyWrappers;
	}
	
	static testMethod void getHistoryWrappersTest() {
		OppLicRelatedListController licController = new OppLicRelatedListController();
		List<License_Opportunity__c> licOpps = CommonUtil.createLicense();
		if( licOpps != null & licOpps.size() > 0 ) {
			License_Opportunity__c licOpp = (License_Opportunity__c) licOpps.get(0);
			licController.oppId = licOpp.Opportunity__c;
			//LicenseDetail__History history = new LicenseDetail__History();
			//history.
			List<HistoryWrapper>  wrapper = licController.licenseHistories;
		}
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
	}
	
	
	public static testMethod void testOppLicRelatedList(){
		OppLicRelatedListController ctrlr = new OppLicRelatedListController();
		Opportunity oppObj = [Select ID from Opportunity LIMIT 1];
		String opportunityId = oppObj.Id;
		ctrlr.oppId = opportunityId;
		//System.assertNotEquals(ctrlr.licenseHistories,null);
	}*/
}