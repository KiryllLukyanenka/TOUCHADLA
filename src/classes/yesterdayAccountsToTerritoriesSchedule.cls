global class yesterdayAccountsToTerritoriesSchedule implements Schedulable
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
        //2015-04-14T00:00:00Z
        Datetime today = datetime.newInstance(date.today().year(), date.today().month(), date.today().day(), 0, 0, 0);
        Datetime yesterday = today.addDays(-1);
        String dateFilter = ' LastModifiedDate > ' + yesterday.format('yyyy-MM-dd hh:mm:ss').replace(' ', 'T') + 'Z and LastModifiedDate < ' + today.format('yyyy-MM-dd hh:mm:ss').replace(' ', 'T') + 'Z';
system.debug(dateFilter);
        String strFilterInQuery = 'where No_Territory_Assignment__c != true and ' + dateFilter + ' and RecordTypeId = \'' + standardAccountRecordTypeId + '\'';
        String strQuery = 'select ' + m_strAllAccountFields + ' from Account ' + strFilterInQuery;
        ReassignAccountsBatch reassignAcctBatchJob = new ReassignAccountsBatch(strQuery);
        Database.executeBatch(reassignAcctBatchJob, 1);
    }
}