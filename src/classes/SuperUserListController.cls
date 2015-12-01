public class SuperUserListController
{
    public SuperUserListController()
    {
        retrieveUsers();
    }
    
    public Boolean IsPrmSuperUser { get; set; }
    public List<userItemInfo> ActiveUserList { get; set; }
    public List<userItemInfo> InactiveUserList { get; set; }
    public STring CurrentUserId { get; set; }
    public String UserId { get; set; }
    public String PartnerName { get; set; }
    public String SortFieldActiveUser { get; set; }
    public String SortDescActiveUser { get; set; }
    public String SortFieldInActiveUser { get; set; }
    public String SortDescInActiveUser { get; set; }
    
    public pageReference activateUser()
    {
        User theUser = new User(Id = UserId);
        theUser.IsActive = true;
        update theUser;
        retrieveUsers();
        return null;
    }
    
    public pageReference inactiveUser()
    {
        User theUser = new User(Id = UserId);
        theUser.IsActive = false;
        update theUser;
        retrieveUsers();
        return null;
    }
    
    public void retrieveUsers()
    {
        ActiveUserList = new List<userItemInfo>();
        InactiveUserList = new List<userItemInfo>();
        Id AccountId = null;
        User currentUser = [select Id, COntact.AccountId, COntact.Account.Name, IsPrmSuperUser from User where Id = :Userinfo.getUserId()];
        CurrentUserId = currentUser.Id;
        AccountId = currentUser.COntact.AccountId;
        PartnerName = currentUser.COntact.Account.Name;
        IsPrmSuperUser = currentUser.IsPrmSuperUser;
        String activeUserSoql = 'select Id, FIrstname, Lastname, COntactId, Email, CreatedDate, LastLoginDate from User where Contact.AccountId = :AccountId and IsActive = true';
        if(SortFieldActiveUser != null && SortFieldActiveUser != '')
        {
            activeUserSoql += ' order by ' + SortFieldActiveUser;
            if(SortDescActiveUser != null && SortDescActiveUser == '1')
            {
                activeUserSoql += ' desc';
            }
        }
        else
        {
            activeUserSoql += ' Order by Firstname';
        }
        List<User> ActiveUsers = database.query(activeUserSoql);
        String inactiveUserSoql = 'select Id, FIrstname, Lastname, COntactId, Email, CreatedDate, LastLoginDate from User where Contact.AccountId = :AccountId and IsActive = false';
        if(SortFieldInActiveUser != null && SortFieldInActiveUser != '')
        {
            inactiveUserSoql += ' order by ' + SortFieldInActiveUser;
            if(SortDescInActiveUser != null && SortDescInActiveUser == '1')
            {
                inactiveUserSoql += ' desc';
            }
        }
        else
        {
            inactiveUserSoql += ' Order by Firstname';
        }
        List<User> InActiveUsers = database.query(inactiveUserSoql);
        Map<Id, Integer> contactCetificationNumberMap = new Map<Id, Integer>();
        Set<Id> cntIds = new Set<Id>();
        for(User theUser : ActiveUsers)
        {
            cntIds.add(theUser.ContactId);
        }
        for(User theUser : InactiveUsers)
        {
            cntIds.add(theUser.ContactId);
        }
        
        for(User theUser : ActiveUsers)
        {
            UserItemInfo thisUserItem = new UserItemInfo();
            thisUserItem.theUser = theUser;
            thisUseritem.cetificationNumber = contactCetificationNumberMap.get(theUser.ContactId);
            ActiveUserList.add(thisUseritem);            
        }
        for(User theUser : InactiveUsers)
        {
            UserItemInfo thisUserItem = new UserItemInfo();
            thisUserItem.theUser = theUser;
            thisUseritem.cetificationNumber = contactCetificationNumberMap.get(theUser.ContactId);
            InactiveUserList.add(thisUseritem);
        }
    }
    
    public class userItemInfo
    {
        public userItemInfo()
        {
        }
        
        public User theUser { get; set; }
        public Integer cetificationNumber { get; set; }
    }
}