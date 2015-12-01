global class assignAccountToTerritoriesScheudle implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {
        Id standardAccountRecordTypeId = [select Id from RecordType where SobjectType = 'Account' and Name = 'Standard Account' limit 1].Id;
        String strFields = '';
        for(String strField : Schema.SObjectType.Account.fields.getMap().keySet())
        {
            strFields += strField + ', ';
        }
        String m_strAllAccountFields = strFields.substring(0, strFields.length()-2);
        String strFilterInQuery = 'where No_Territory_Assignment__c != true and RecordTypeId = \'' + standardAccountRecordTypeId + '\'';
        String strQuery = 'select ' + m_strAllAccountFields + ' from Account ' + strFilterInQuery;
        ReassignAccountsBatch reassignAcctBatchJob = new ReassignAccountsBatch(strQuery);
        Database.executeBatch(reassignAcctBatchJob, 1);
    }
}