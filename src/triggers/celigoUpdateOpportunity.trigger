trigger celigoUpdateOpportunity on Opportunity(before insert, before update) {
    List < Id > parentAndPartnerAccountIds = new List < Id > ();
    List < Id > AccountIds = new List < Id > ();
    List < Id > OwnerIds = new List < Id > ();
    for (Opportunity opportunity : System.Trigger.new) {

        if (opportunity.Celigo_Update__c) {
            opportunity.Celigo_Update__c = false;
            continue;
        }

        if (opportunity.StageName != 'W10 - Closed/Won' && opportunity.StageName != 'Closed Won')
            continue;
        if (opportunity.Booked_Date__c == null)
            continue;   
        System.debug('----opportunity id ----' + opportunity.Id);

        opportunity.Generate_Sales_Order__c = true;
        opportunity.Send_to_NetSuite__c = true;
        AccountIds.add(opportunity.AccountId);
        OwnerIds.add(opportunity.OwnerId);
    }
    System.debug('-- OwnerIds -- ' + OwnerIds);
    if (OwnerIds != null && OwnerIds.size() > 0) {
        Map < Id,User > mapUsers = new Map < Id,User > ([SELECT Id, Profile.Name, Email, Manager.Email, Contact.AccountId FROM User WHERE Id IN : OwnerIds]);
        System.debug('-- mapUsers -- ' + mapUsers);
        for (Opportunity opportunity : System.Trigger.new) {
            User user = mapUsers.get(opportunity.OwnerId);
            System.debug('-- user -- ' + user);
            if(user == null)
                continue;
            opportunity.SalesRep_Email__c = user.Email;
            //Justin Wong commented out.  Use WF rule - 8/24/2015 
            //opportunity.Netsuite_Customer__c = opportunity.AccountId;
            if (user.Profile.Name == 'AD Partner User') {
                parentAndPartnerAccountIds.add(user.Contact.AccountId);
                //Justin Wong commented out.  Use WF rule - 8/24/2015 
                //opportunity.Netsuite_Customer__c = user.Contact.AccountId;
                opportunity.SalesRep_Email__c = user.Manager.Email;
            }
        }
    }

    if (AccountIds != null && AccountIds.size() > 0) {
        List < Account > accounts = [Select Id, ParentId from Account Where Id in : AccountIds];
        for (Account a : accounts)
            if (a.ParentId != null)
                parentAndPartnerAccountIds.add(a.ParentId);

        if (parentAndPartnerAccountIds == null || parentAndPartnerAccountIds.size() < 1)
            return;

        List < Account > parentAndPartnerAccounts = [select Id, NetSuite_Push__c, NetSuite_Pull__c from Account where Id IN : parentAndPartnerAccountIds];

        List < Account > acctsToUpdate = new List < Account > ();

        for (Account parentAndPartnerAccount : parentAndPartnerAccounts) {
            parentAndPartnerAccount.NetSuite_Push__c = true;
            parentAndPartnerAccount.NetSuite_Pull__c = true;
            acctsToUpdate.add(parentAndPartnerAccount);
        }

        if (acctsToUpdate == null || acctsToUpdate.size() < 1)
            return;
        System.debug('----account ids to be updated----' + acctsToUpdate);
        update acctsToUpdate;

    }
}