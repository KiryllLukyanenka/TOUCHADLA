@isTest
public class testYesAccountsToTerritoriesSchedule
{
    @isTest
    static void testSchedule()
    {
        yesterdayAccountsToTerritoriesSchedule schedulable = new yesterdayAccountsToTerritoriesSchedule();
        SchedulableContext contenx;
        schedulable.execute(contenx);
    }
}