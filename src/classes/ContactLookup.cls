/*
 * This class is defined with "with sharing" keyword, to make the sharing rule and profile enforced.
 *
 * Eric He
*/
public with sharing class ContactLookup 
{
    /*
     * Static method to be called by the remote action from DealRegistration page to lookup the Contact records
     * that the current portal user has access to. The "with sharing" keyword must be specified here.
     * For DealRegistration page, all the Account records across the organization should be retrieved, but only
     * the Contact records that the current portal user has access to should be retrieved.
    */    
    public static Contact getPrimaryContact(String contactEmail, String companyNumber)
    {
        List<Contact> contacts = [select Id, Name, Email, FirstName, LastName, Phone, Title from Contact where Email = :contactEmail and Account.DunsNumber = :companyNumber];
        return (contacts.size() > 0 ? contacts[0] : null);
    }
}