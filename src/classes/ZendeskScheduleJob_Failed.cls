global class  ZendeskScheduleJob_Failed implements Schedulable {
	global void execute(SchedulableContext SC) {
		/*List<Account> accountsList = new List<Account>();
		List<Account_Zendesk__c> accountZendesks = [select Id, Account__c, Description__c, OP_CODE__c, Organisation_Id__c, Status__c, Trigger_Id__c, ACE_Architect__c, TAM__c, SE__c from Account_Zendesk__c where Status__c in ('FAILED') limit 2];
		for(Account_Zendesk__c az:accountZendesks){
           Account account = [select Id, Name , ACE_Architect__c, ACE_Architect__r.Email, CreatedBy.Email, Technical_Account_Manager__c, Technical_Account_Manager__r.Email from Account where id =:az.Account__c];
           if(!ZendeskBackend.checkIf_ACE_TAM_NULL(account)){
           		if(accountsList.size()<2){
           			accountsList.add(account);
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