trigger ContactAfterTrigger on Contact (after insert, after update) {
    
    //Created on 2014-7-2 ---> Share the new contacts to all partner users that are in one account with the contact owner
    // Find all contact Ids
    Set<String> contactIds = new Set<String>(); 
    for(Contact contact : Trigger.new){
        if(Trigger.isInsert || (Trigger.isUpdate && contact.OwnerId != Trigger.oldMap.get(contact.Id).OwnerId)){
            contactIds.add(contact.Id);
        }
    }
    
    if(contactIds.size() > 0){
        // Find the contacts that their owners are parter.
        List<Contact> contacts = new List<Contact>();
        Set<String> accountIds = new Set<String>();
        for(Contact con :[select Id, Owner.AccountId from Contact where id in:contactIds]){
            if(con.Owner.AccountId != null){
                contacts.add(con);
                accountIds.add(con.Owner.AccountId);
            }
        }
        
        if(accountIds.size() > 0){
            // Find all partner users in these accounts and create shares
            List<ContactShare> shares = new List<ContactShare>();
            for(User user : [select Id, AccountId from User where AccountId = :accountIds and IsActive = true]){
                for(Contact con : contacts){
                    if(con.Owner.AccountId == user.AccountId && con.OwnerId != user.Id){
                        ContactShare share = new ContactShare(ContactId = con.Id, UserOrGroupId = user.Id, ContactAccessLevel = 'Edit');
                        shares.add(share);
                    }
                }
            }
            insert shares;
        }
    }
}