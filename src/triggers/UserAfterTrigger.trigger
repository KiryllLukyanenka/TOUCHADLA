trigger UserAfterTrigger on User (after insert) {
	
	//Created on 2014-7-7 ---> Share all contacts to the new user, the contacts are owned by the related user with in one account of the new user
	// Find the related account ids and user ids
	Set<String> accountIds = new Set<String>();
	Set<String> userIds = new Set<String>();
	for(User user : Trigger.new){
		if(user.ContactId != null){
			accountIds.add(user.AccountId);
			userIds.add(user.Id);
		}
	}
	TriggerUtil.createShareForNewUser(userIds, accountIds);
}