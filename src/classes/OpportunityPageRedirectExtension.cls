public with sharing class OpportunityPageRedirectExtension 
{   
    public OpportunityPageRedirectExtension(ApexPages.StandardController stdController) 
    {        
    }

    // Redirects the user to either the custom VF page or the standard opportunity new page,
    // depending if current user is community user or internal user.
    public PageReference redirect()
    {
        String redirectURL;        
        // If it's community user, take the user to the custom VF page.
        //if(UserInfo.getUserType().equalsIgnoreCase('PowerPartner'))
        String profileName = [select Profile.Name from User where Id = :UserInfo.getUserId()].Profile.Name;
        PageReference pageRef;
        Boolean redirectToGatingPage = false;
        if(profileName == 'Custom: Partner Community Login User')
        { 
            pageRef = Page.DealRegistration;          
        }
        // if not, take the user back to the standard opportunity new page.
        else
        {
            pageRef = Page.FCRM__FCR_NewOpportunityButton;       
        }           
        Map<String, String> parameterMap = ApexPages.currentPage().getParameters();
        for(String key : parameterMap.keySet())
        {          
            if(key != 'sfdc.override' && key != 'save_new')
            {
                pageRef.getParameters().put(key, parameterMap.get(key));              
            }              
        }
        pageRef.setRedirect(true);
        return pageRef;       
    }    
}