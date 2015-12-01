@isTest
private class TestOpportunityPageRedirectExtension 
{    
    @isTest 
    static void testPageRedirect()
    {
        ApexPages.currentPage().getParameters().put('retURL', '/home/home.jsp');
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Opportunity());
        OpportunityPageRedirectExtension extension = new OpportunityPageRedirectExtension(stdController);
        extension.redirect();
    }
    //Custom: Partner Community Login User
    @isTest 
    static void testPageRedirect2()
    {
        List<User> users = [select Id from User where Profile.Name = 'Custom: Partner Community Login User' and IsActive = true limit 1];
        if(users.size() > 0)
        {
            system.runas(users[0])
            {
                ApexPages.currentPage().getParameters().put('retURL', '/home/home.jsp');
                
                ApexPages.StandardController stdController = new ApexPages.StandardController(new Opportunity());
                OpportunityPageRedirectExtension extension = new OpportunityPageRedirectExtension(stdController);
                extension.redirect();
            }
        }
    }
}