@isTest
public class testAssignAccountScheudle
{
    @isTest
    static void testSchedule()
    {
        assignAccountToTerritoriesScheudle schedulable = new assignAccountToTerritoriesScheudle();
        SchedulableContext contenx;
        schedulable.execute(contenx);
    }
}