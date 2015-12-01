global class ZendeskScheduleJob implements Schedulable {
	global void execute(SchedulableContext SC) {
		/*List<Account_Zendesk__c> accountZendesks = [select Id, Account__c, Description__c, OP_CODE__c, Organisation_Id__c, Status__c, Trigger_Id__c, ACE_Architect__c, TAM__c, SE__c from Account_Zendesk__c where Status__c in ('SUCCESS','FAILED')];
		for(Account_Zendesk__c az:accountZendesks){
           Account account = [select Id, Name , ACE_Architect__c, ACE_Architect__r.Email, CreatedBy.Email, Technical_Account_Manager__c, Technical_Account_Manager__r.Email from Account where id =:az.Account__c];
           ZendeskBackend.checkTriggerDetails(account);
		}*/
	}
}