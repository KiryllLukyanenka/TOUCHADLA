public class AssignAccountTerritoryCOntroller
{
    public PageReference assignTerritory()
    {
        String acctId = ApexPages.currentPage().getParameters().get('id');
        Account acct = [select Id, DoAssignTerritory__c from Account where Id = :acctId limit 1];
        if(acct.DoAssignTerritory__c == true)
        {
            acct.DoAssignTerritory__c = false;
        }
        else if(acct.DoAssignTerritory__c == false)
        {
            acct.DoAssignTerritory__c = true;
        }
        update acct;
        pageReference retPage = new PageReference('/' + acctId);
        retPage.setRedirect(true);
        return retPage;
    }
}