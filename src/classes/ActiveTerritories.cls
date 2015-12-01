global class ActiveTerritories implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {
        List<Territory_AppD__c> inactiveTerritories = [select Id, Active__c, Effective_Date__c from Territory_AppD__c where Active__c = false and Effective_Date__c <= :Date.today()];
        for(Territory_AppD__c inactiveTerritory : inactiveTerritories)
        {
            inactiveTerritory.Active__c = true;
        }
        database.update(inactiveTerritories, false);
    }
}