@isTest
public class UserAfterTriggerTest {
  
  @isTest public static void testUserAfterTrigger(){
    Account account = new Account(Name = 'test');
    insert account;
    Contact contact = new Contact(LastName = 'test contact', AccountId = account.Id);
    insert contact;
    
    Profile profile = [select Id from Profile where UserType = 'PowerPartner' limit 1];
    
    User user = new User();
    user.FirstName = 'first';
    user.LastName = 'last';
    user.UserName = 'UserAfterTrigger@test.com';
    user.Email = 'UserAfterTrigger@test.com';
    user.CommunityNickname = 'test1';
    user.Alias = 'test1';
    user.ProfileId = profile.Id;
    user.TimeZoneSidKey = 'America/Tijuana';
    user.LocaleSidKey = 'en_US';
    user.EmailEncodingKey = 'UTF-8';
    user.LanguageLocaleKey = 'en_US';
    user.ContactId = contact.Id;
    insert user;
  }
}