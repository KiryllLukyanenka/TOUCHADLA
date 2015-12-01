public class CreateSuperUserController
{
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String Username { get; set; }
    public Boolean IsPrmSuperUser { get; set; }
   
    
    public CreateSuperUserController()
    {
    
        User currentUser = [select Id, COntact.AccountId, COntact.Account.Name, IsPrmSuperUser from User where Id = :Userinfo.getUserId()];
        IsPrmSuperUser = currentUser.IsPrmSuperUser;
    }
    
    
    
    public PageReference createUser()
    {  
        User currentUser = [select Id, COntact.AccountId, COntact.Account.Name, IsPrmSuperUser from User where Id = :Userinfo.getUserId()];
        Id partnerCntRecordTypeId = [select Id from RecordType where Name = 'Partner Contact' and sobjectType = 'Contact'].Id;
        Contact objContact = new COntact(AccountId = currentUser.COntact.AccountId, RecordTypeId = partnerCntRecordTypeId, Firstname = firstname, Lastname = lastname, Email = email, FCRM__FCR_Status__c = 'Open');
        insert  objContact;
        //List<Campaign> partnerCampaigns = [select Id from Campaign where Name = 'Test Campaign'];
        //if(partnerCampaigns.size() > 0)
        //{
            //CampaignMember partnerUserMember = new CampaignMember(CampaignId = partnerCampaigns[0].Id, ContactId = objContact.Id);
            //insert partnerUserMember;
       // }
        try
        {
            if(objContact != null)
            {
                //Select Exist Customer portel User's profile
                Profile pf = [SELECT Id FROM profile 
                              WHERE name='Custom: Partner Community Login User' limit 1];   
                //Create user 
                User mockUser = new User(contactId=objContact.Id, 
                                username=Username, 
                                firstname=firstName,
                                lastname=lastName, 
                                email=email,
                                communityNickname = lastName + '_'+Math.random(),
                                alias = string.valueof(firstName.substring(0,1) + 
                                        lastName.substring(0,1) ), 
                                profileid = pf.Id, emailencodingkey='UTF-8',
                                languagelocalekey='en_US', 
                                localesidkey='en_US', 
                                timezonesidkey='America/Los_Angeles');                  
                insert mockUser;
                return new PageReference('/apex/superUserlist');
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return null;
    }
}