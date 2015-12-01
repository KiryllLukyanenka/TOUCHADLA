@isTest
public class testLeadAssignmentTrigger
{
    @istest
    static void testTrigger()
    {
        Lead ld = new Lead(firstName = 'fn', Lastname = 'lN', Company = 'cy', Status = 'Open', Country = 'USA', State = 'ca', PostalCode = '1000');
        insert ld;
    }    
}