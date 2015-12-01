global class ZendeskScheduleJob_Empty implements Schedulable {
	global void execute(SchedulableContext SC) {
		/*List<Account> accountsList = new List<Account>();
		List<Account> accountsNotInZendesk = [select Id, ACE_Architect__c, Technical_Account_Manager__c from Account where PortalID__c != null and ID NOT IN(Select Account__c from Account_Zendesk__c)];
		
		//List<Account> aaa = [select Id,(select Id, Account__c from Account_Zendesk__r) from Account_Zendesk__c];
		for(Account account:accountsNotInZendesk){
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