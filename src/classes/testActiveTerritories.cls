@isTest
public class testActiveTerritories
{
    @isTest
    static void testSchedule()
    {
        Id acctTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Account' limit 1].Id;
        Territory_AppD__c testLt = new Territory_AppD__c(Name = 'Acme', Type__c = 'Geography', Assigned_To_Type__c = 'User', Assigned_To_ID__c = Userinfo.getUserId(), Assigned_To__c = userinfo.getUserName(), Order__c = 1, RecordTypeId = acctTerritoryRecordTypeId, Active__c = false, Effective_Date__c = date.today().addDays(-10));
        insert testLt;
        ActiveTerritories schedulable = new ActiveTerritories();
        SchedulableContext contenx;
        schedulable.execute(contenx);
    }
}