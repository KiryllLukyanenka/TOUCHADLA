trigger DisablePortalUser on Contact (after update) {/*
	if(Trigger.isAfter && Trigger.isUpdate){
		List<Contact> updatedContacts = Trigger.new;
		List<String> contactIds = new List<String>();
				
		for(Contact con: updatedContacts){
			if(con.No_longer_at_Company__c && con.Email!=null){
				contactIds.add(con.id+'');
			}
		}	
		if(contactIds.size() > 0){
			UsersUtil.disablePortalUsers(contactIds);
		}
	}*/
}