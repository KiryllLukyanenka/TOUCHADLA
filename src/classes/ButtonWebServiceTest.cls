@isTest
public class ButtonWebServiceTest {
    
    @isTest static void testButtonWebService(){
        Account account = new Account(Name = 'account');
        insert account;
        Opportunity oppt = new Opportunity(AccountId = account.Id, Name = 'oppt', StageName = 'Pipeline Generation', CloseDate = System.today());
        insert oppt;
        User portalUser = [select Name from User where IsPortalEnabled = true and IsActive = true limit 1];
        ButtonWebService.extendExpiration(portalUser.Name, oppt.Id);
        ButtonWebService.requestQuote(portalUser.Id, oppt.Id);
        ButtonWebService.closedOrWon(portalUser.Name, oppt.Id);
    }
}