trigger AssignToLeadTerritory on Lead (after update) 
{
    Boolean needToRunBatch = false;
    for(Lead ld : trigger.New)
    {
        Lead oldLed = Trigger.oldmap.get(ld.Id);
        if(ld.NoTerritoryAssignment__c != true && ld.TriggerLeadAssignment__c == true && oldLed.TriggerLeadAssignment__c != true)
        {
            needToRunBatch = true;
            break;
        }
    }
    if(needToRunBatch)
    {
        String strFields = '';
        for(String strField : Schema.SObjectType.Lead.fields.getMap().keySet())
        {
            strFields += strField + ', ';
        }
        String m_strAllLeadFields = strFields.substring(0, strFields.length()-2);
        String strFilterInQuery = 'where NoTerritoryAssignment__c != true and Id in (';
        for(Lead ld : trigger.New)
        {
            strFilterInQuery += '\'' + ld.Id + '\', ';
        }
        strFilterInQuery = strFilterInQuery.substring(0, strFilterInQuery.length()-2);
        strFilterInQuery += ')';
        String strQuery = 'select ' + m_strAllLeadFields + ' from Lead ' + strFilterInQuery;
        ReassignLeadsBatch reassignLeadBatchJob = new ReassignLeadsBatch(strQuery);
        Database.executeBatch(reassignLeadBatchJob, 1);
    }
}