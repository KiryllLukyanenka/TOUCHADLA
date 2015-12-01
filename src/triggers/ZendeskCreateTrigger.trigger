trigger ZendeskCreateTrigger on Account (after insert, after update) {
    List<Account> accounts = Trigger.new;
    List<Account> limitedAccounts = accounts;
    //Integer maxBackendCalls = Limits.getLimitCallouts();
    //Integer maxPerAccount = 5;
    if(accounts.size() > 2){ //* maxPerAccount<maxBackendCalls){
        limitedAccounts = new List<Account>();
        limitedAccounts.add(accounts.get(0));
        limitedAccounts.add(accounts.get(1));
    } 
    for(Account account:limitedAccounts){
        try{
            ZendeskBackend.checkTriggerDetails(account);  
        }catch(Exception e){
            EmailUtil.notifyError(e,null);
        }  
    }
}