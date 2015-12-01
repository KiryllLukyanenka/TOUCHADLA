global class ZendeskScheduleJob_Success implements Schedulable {
	global void execute(SchedulableContext SC) {
		/*List<Account> accountsList = new List<Account>();
		List<Account_Zendesk__c> accountZendesks = [select Id, Account__c, Account__r.ACE_Architect__c, Account__r.ACE_Architect__r.Email, Account__r.CreatedBy.Email, Account__r.Technical_Account_Manager__c, Account__r.Technical_Account_Manager__r.Email, Description__c, OP_CODE__c, Organisation_Id__c, Status__c, Trigger_Id__c, ACE_Architect__c, TAM__c, SE__c from Account_Zendesk__c where Status__c in ('SUCCESS')];
		for(Account_Zendesk__c az:accountZendesks){
           //Account account = [select Id, Name , ACE_Architect__c, ACE_Architect__r.Email, CreatedBy.Email, Technical_Account_Manager__c, Technical_Account_Manager__r.Email from Account where id =:az.Account__c];
           //ZendeskBackend.checkTriggerDetails(account);
           if(ZendeskBackend.checkIf_ACE_TAM_Changed(az.Account__r, az)){
           		if(accountsList.size()<2){
           			accountsList.add(az.Account__r);
           		} else{
           			break;
           		}
           }
		}
		if(accountsList.size()>0){
			for(Account account:accountsList){
				ZendeskBackend.checkTriggerDetails(account);
			}
		}*/
	}
}