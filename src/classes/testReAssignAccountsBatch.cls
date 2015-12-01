@isTest
public class testReAssignAccountsBatch
{
    @isTest
    static void testBatch()
    {
        Territory_Setup__c accountTerrSetup = new Territory_Setup__c(Type__c = 'Account/Contact', Status__c = 'On', Next_Mass_Update_Date__c = date.today().addMonths(1));
        insert accountTerrSetup;
        Id acctTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Account' limit 1].Id;
        Territory_AppD__c testLt = new Territory_AppD__c(Name = 'Acme', Type__c = 'Geography', Assigned_To_Type__c = 'User', Assigned_To_ID__c = Userinfo.getUserId(), Assigned_To__c = userinfo.getUserName(), Order__c = 1, RecordTypeId = acctTerritoryRecordTypeId, Active__c = true, Effective_Date__c = date.today().addDays(-10));
        insert testLt;
        //AnnualRevenue
        Territory_Field_Criteria__c testLeadFIeldCriteria1 = new Territory_Field_Criteria__c(Field__c = 'Industry', Value__c = 'Education', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria2 = new Territory_Field_Criteria__c(Field__c = 'X500K_Email_Sent__c', Value__c = 'true', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria3 = new Territory_Field_Criteria__c(Field__c = 'Account_Balance__c', Value__c = '100000', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria4 = new Territory_Field_Criteria__c(Field__c = 'Last_Deployment_Status_Check__c', Value__c = '9/8/2014', Operator__c = 'equals', Territory__c = testLt.Id);
        
        insert new List<Territory_Field_Criteria__c> {testLeadFIeldCriteria1, testLeadFIeldCriteria2, testLeadFIeldCriteria3, testLeadFIeldCriteria4};
        String theDate = '9/8/2014';
        String[] dates = theDate.split('/');
        DateTime criteriaValue = DateTime.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
        Date dealDate = Date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
        Territory_Geography__c testLeadGeo = new Territory_Geography__c(Territory__c = testLt.Id, Country__c = 'usa', State__c = 'ca', Zip_Start__c = '1000', Zip_End__c = '2000');
        insert testLeadGeo;
         Id standardAccountRecordTypeId = [select Id from RecordType where SobjectType = 'Account' and Name = 'Standard Account' limit 1].Id;
        Account testAccount = new Account(name = 'acme', Industry='Education', BillingCOuntry = 'USA', X500K_Email_Sent__c = true, Account_Balance__c = 100000, Last_Deployment_Status_Check__c = dealDate, BillingState = 'CA', BillingPostalCode = '1500', RecordTypeId = standardAccountRecordTypeId);
        insert testAccount;
        String strFields = '';
        for(String strField : Schema.SObjectType.Account.fields.getMap().keySet())
        {
            strFields += strField + ', ';
        }
        String m_strAllLeadFields = strFields.substring(0, strFields.length()-2);
        String strFilterInQuery = 'where Id in (';
        strFilterInQuery += '\'' + testAccount.Id + '\', ';
        strFilterInQuery = strFilterInQuery.substring(0, strFilterInQuery.length()-2);
        strFilterInQuery += ')';
        String strQuery = 'select ' + m_strAllLeadFields + ' from Account ' + strFilterInQuery;
        ReassignAccountsBatch reassignAccountBatchJob = new ReassignAccountsBatch(strQuery);
        Database.executeBatch(reassignAccountBatchJob, 1);
    }
}