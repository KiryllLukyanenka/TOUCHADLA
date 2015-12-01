trigger PartnerAccountOpportunity on Opportunity (before insert) {
    Set<Id> OwnerIds = new Set<Id>();
    String PARTNER_ACCOUNT_FIELD = 'Partner_Involved__c';
    String PARTNER_ACCOUNT_OWNER_FIELD = 'Partner_Account_Owner__c';
    
    for(Opportunity o :trigger.new){
        OwnerIds.add(o.OwnerId); 
    }
    
    Map<Id,User> userMap = new Map<Id,User>([select  u.Contact.AccountId ,u.Contact.Account.OwnerId ,u.UserType from User u where id in :OwnerIds]);
    System.debug('userMap '+userMap );
    for(Opportunity o : trigger.new){
         User usr = userMap.get(o.OwnerId);
         if (usr == null || usr.UserType == null) continue;
         if(usr.UserType.equals('PowerPartner') && (usr.Contact.Account.OwnerId != null)){
                 o.put(PARTNER_ACCOUNT_OWNER_FIELD, usr.Contact.Account.OwnerId);
          }
    }
}