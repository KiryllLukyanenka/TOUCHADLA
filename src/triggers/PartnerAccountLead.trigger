/***********************************************
    Trigger: PartnerAccountLead 
    This trigger Checks user is partner user then update fields
    Author – Cleartask
    Date – 16/3/2011    
    Revision History    
 ***********************************************/
trigger PartnerAccountLead on Lead (before insert) {
   
    Set<Id> OwnerIds = new Set<Id>();
    String PARTNER_ACCOUNT_FIELD = 'Partner_Involved__c';
    String PARTNER_ACCOUNT_OWNER_FIELD = 'Partner_Account_Owner__c';
    
    for(Lead l :trigger.new){
        OwnerIds.add(l.OwnerId); 
    }
    
    Map<Id,User> userMap = new Map<Id,User>([select  u.Contact.AccountId ,u.Contact.Account.OwnerId ,u.UserType from User u where id in :OwnerIds]);
    System.debug('userMap '+userMap );
    for(Lead l : trigger.new){
         User usr = userMap.get(l.OwnerId);
         if (usr == null || usr.UserType == null) continue;
         if(usr.UserType.equals('PowerPartner')){
             if(usr.Contact.AccountId != null){
                 l.put(PARTNER_ACCOUNT_FIELD, usr.Contact.AccountId);
             }
             if(usr.Contact.Account.OwnerId != null){
                 l.put(PARTNER_ACCOUNT_OWNER_FIELD, usr.Contact.Account.OwnerId);
             }
          }
    }
}