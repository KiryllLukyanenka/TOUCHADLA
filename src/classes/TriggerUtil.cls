/**
 * Class: TriggerUtil
 * Purpose: Provide common functionalities as helper methods for tirggers.
 */
public class TriggerUtil {
	
	@future
	public static void createShareForNewUser(Set<String> userIds, Set<String> accountIds){
		if(userIds.size() > 0 && accountIds.size() > 0){
			// Find all contacts owned by the users
			List<Contact> contacts = [select Id, AccountId, Owner.AccountId from Contact where Owner.AccountId in :AccountIds];
			
			// Create contact shares
			List<ContactShare> contactShares = new List<ContactShare>();
			for(User user : [select Id, ContactId, AccountId from User where Id in :userIds]){
				for(Contact contact : contacts){
					if(user.ContactId != null && user.AccountId == contact.Owner.AccountId){
						contactShares.add(new ContactShare(ContactId = contact.Id, UserOrGroupId = user.Id, ContactAccessLevel = 'Edit'));
					}
				}
			}
			insert contactShares;
		}
	}
}