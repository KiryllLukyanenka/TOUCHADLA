trigger AssignToAccountTerritory on Account (after insert, after update) 
{
    Set<Id> needToAssAccountIds = new Set<Id>();
    Id standardAccountRecordTypeId = [select Id from RecordType where SobjectType = 'Account' and Name = 'Standard Account' limit 1].Id;
    for(account acct : trigger.New)
    {system.debug('@@@' + trigger.New);
        if(acct.No_Territory_Assignment__c != true && acct.RecordTypeId == standardAccountRecordTypeId)
        {            
            if(Trigger.isInsert)
            {
                needToAssAccountIds.add(acct.id);
            }
            else if(Trigger.isUpdate)
            {
                Account oldAcct = trigger.oldMap.get(acct.Id);
                if(acct.DoAssignTerritory__c != oldAcct.DoAssignTerritory__c)
                {
                    needToAssAccountIds.add(acct.id);
                }
            }
        }
    }
    if(needToAssAccountIds.size() > 0)
    {
        List<Territory_Setup__c> setups = [select Id, Status__c from Territory_Setup__c where Type__c = 'Account/Contact' and Status__c = 'On' order by LastModifiedDate desc limit 1];
        if(setups.size() > 0)
        {
            String strFields = '';
            for(String strField : Schema.SObjectType.Account.fields.getMap().keySet())
            {
                strFields += strField + ', ';
            }
            String m_strAllAccountFields = strFields.substring(0, strFields.length()-2);
            String strFilterInQuery = 'where No_Territory_Assignment__c != true and Id in (';
            for(Id acctId : needToAssAccountIds)
            {
                strFilterInQuery += '\'' + acctId + '\', ';
            }
            strFilterInQuery = strFilterInQuery.substring(0, strFilterInQuery.length()-2);
            strFilterInQuery += ')';
            String strQuery = 'select ' + m_strAllAccountFields + ', (select Id, OwnerId from Contacts) from Account ' + strFilterInQuery;
            system.debug('###' + strQuery);
            if(needToAssAccountIds.size() > 1)
            {
                ReassignAccountsBatch reassignAcctBatchJob = new ReassignAccountsBatch(strQuery);
                Database.executeBatch(reassignAcctBatchJob, 1);
            }
            else
            {
                assignOneAccountToTerritoryHelper.assignTerritory(strQuery);
            }
        }
    }
}