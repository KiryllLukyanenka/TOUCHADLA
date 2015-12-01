@isTest
public class testReAssignLeadsBatch
{
    @isTest
    static void testBatch()
    {
        Id leadTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Lead' limit 1].Id;
        Territory_AppD__c testLt = new Territory_AppD__c(Name = 'Acme', Type__c = 'Geography', Assigned_To_Type__c = 'User', Assigned_To_ID__c = Userinfo.getUserId(), Assigned_To__c = userinfo.getUserName(), Order__c = 1, RecordTypeId = leadTerritoryRecordTypeId);
        insert testLt;
        //AnnualRevenue
        Territory_Field_Criteria__c testLeadFIeldCriteria1 = new Territory_Field_Criteria__c(Field__c = 'AppJam_Presenter__c', Value__c = 'true', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria2 = new Territory_Field_Criteria__c(Field__c = 'Deal_Stage__c', Value__c = 'Qualified', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria3 = new Territory_Field_Criteria__c(Field__c = 'AnnualRevenue', Value__c = '100000', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria4 = new Territory_Field_Criteria__c(Field__c = 'App_Map_First_Visit__c', Value__c = '9/8/2014', Operator__c = 'equals', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria5 = new Territory_Field_Criteria__c(Field__c = 'Estimated_Close_Date__c', Value__c = '9/8/2014', Operator__c = 'equals', Territory__c = testLt.Id);
        
        insert new List<Territory_Field_Criteria__c> {testLeadFIeldCriteria1, testLeadFIeldCriteria2, testLeadFIeldCriteria3, testLeadFIeldCriteria4, testLeadFIeldCriteria5};
        String theDate = '9/8/2014';
        String[] dates = theDate.split('/');
        DateTime criteriaValue = DateTime.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
        Date dealDate = Date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
        Territory_Geography__c testLeadGeo = new Territory_Geography__c(Territory__c = testLt.Id, Country__c = 'United States', State__c = 'ca', Zip_Start__c = '1000', Zip_End__c = '2000');
        insert testLeadGeo;
        Lead testLead = new Lead(LastName = 'acme', Status = 'open', Company = 'acme', COuntry = 'USA', State = 'CA', PostalCode = '1500', Deal_Stage__c = 'Qualified', AppJam_Presenter__c = true, AnnualRevenue = 100000, App_Map_First_Visit__c = criteriaValue, Estimated_Close_Date__c = dealDate);
        insert testLead;
        String strFields = '';
        for(String strField : Schema.SObjectType.Lead.fields.getMap().keySet())
        {
            strFields += strField + ', ';
        }
        String m_strAllLeadFields = strFields.substring(0, strFields.length()-2);
        String strFilterInQuery = 'where Id in (';
        strFilterInQuery += '\'' + testLt.Id + '\', ';
        strFilterInQuery = strFilterInQuery.substring(0, strFilterInQuery.length()-2);
        strFilterInQuery += ')';
        String strQuery = 'select ' + m_strAllLeadFields + ' from Lead ' + strFilterInQuery;
        ReassignLeadsBatch reassignLeadBatchJob = new ReassignLeadsBatch(strQuery);
        Database.executeBatch(reassignLeadBatchJob, 1);
    }
    
    @isTest
    static void testBatch2()
    {
        Id leadTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Lead' limit 1].Id;
        Territory_AppD__c testLt = new Territory_AppD__c(Name = 'Acme', Type__c = 'Geography', Assigned_To_Type__c = 'User', Assigned_To_ID__c = Userinfo.getUserId(), Assigned_To__c = userinfo.getUserName(), Order__c = 1, RecordTypeId = leadTerritoryRecordTypeId);
        insert testLt;
        //AnnualRevenue
        Territory_Field_Criteria__c testLeadFIeldCriteria1 = new Territory_Field_Criteria__c(Field__c = 'AppJam_Presenter__c', Value__c = 'true', Operator__c = 'not equal to', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria2 = new Territory_Field_Criteria__c(Field__c = 'Deal_Stage__c', Value__c = 'Qualified', Operator__c = 'not equal to', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria3 = new Territory_Field_Criteria__c(Field__c = 'AnnualRevenue', Value__c = '100000', Operator__c = 'not equal to', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria4 = new Territory_Field_Criteria__c(Field__c = 'App_Map_First_Visit__c', Value__c = '9/8/2014', Operator__c = 'not equal to', Territory__c = testLt.Id);
        Territory_Field_Criteria__c testLeadFIeldCriteria5 = new Territory_Field_Criteria__c(Field__c = 'Estimated_Close_Date__c', Value__c = '9/8/2014', Operator__c = 'not equal to', Territory__c = testLt.Id);
        
        insert new List<Territory_Field_Criteria__c> {testLeadFIeldCriteria1, testLeadFIeldCriteria2, testLeadFIeldCriteria3, testLeadFIeldCriteria4, testLeadFIeldCriteria5};
        String theDate = '9/8/2014';
        String[] dates = theDate.split('/');
        DateTime criteriaValue = DateTime.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
        Date dealDate = Date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
        Territory_Geography__c testLeadGeo = new Territory_Geography__c(Territory__c = testLt.Id, Country__c = 'United States', State__c = 'ca', Zip_Start__c = '1000', Zip_End__c = '2000');
        insert testLeadGeo;
        Lead testLead = new Lead(LastName = 'acme', Status = 'open', Company = 'acme', COuntry = 'USA', State = 'CA', PostalCode = '1500', Deal_Stage__c = 'Qualified', AppJam_Presenter__c = true, AnnualRevenue = 100000, App_Map_First_Visit__c = criteriaValue, Estimated_Close_Date__c = dealDate);
        insert testLead;
        String strFields = '';
        for(String strField : Schema.SObjectType.Lead.fields.getMap().keySet())
        {
            strFields += strField + ', ';
        }
        String m_strAllLeadFields = strFields.substring(0, strFields.length()-2);
        String strFilterInQuery = 'where Id in (';
        strFilterInQuery += '\'' + testLt.Id + '\', ';
        strFilterInQuery = strFilterInQuery.substring(0, strFilterInQuery.length()-2);
        strFilterInQuery += ')';
        String strQuery = 'select ' + m_strAllLeadFields + ' from Lead ' + strFilterInQuery;
        ReassignLeadsBatch reassignLeadBatchJob = new ReassignLeadsBatch(strQuery);
        Database.executeBatch(reassignLeadBatchJob, 1);
    }
    
    @isTest
    static void testBatch3()
    {
        Id leadTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Lead' limit 1].Id;
        Territory_AppD__c testLt = new Territory_AppD__c(Name = 'Acme', Type__c = 'Geography', Assigned_To_Type__c = 'User', Assigned_To_ID__c = Userinfo.getUserId(), Assigned_To__c = userinfo.getUserName(), Order__c = 1, RecordTypeId = leadTerritoryRecordTypeId);
        insert testLt;
        //AnnualRevenue
        Territory_Field_Criteria__c testLeadFIeldCriteria1 = new Territory_Field_Criteria__c(Field__c = 'App_Map_First_Visit__c', Value__c = '9/8/2014', Operator__c = 'not equal to', Territory__c = testLt.Id);
        
        insert new List<Territory_Field_Criteria__c> {testLeadFIeldCriteria1};
        String theDate = '9/8/2014';
        String[] dates = theDate.split('/');
        DateTime criteriaValue = DateTime.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
        Territory_Geography__c testLeadGeo = new Territory_Geography__c(Territory__c = testLt.Id, Country__c = 'United States', State__c = 'ca', Zip_Start__c = '1000', Zip_End__c = '2000');
        insert testLeadGeo;
        Lead testLead = new Lead(LastName = 'acme', Status = 'open', Company = 'acme', COuntry = 'USA', State = 'CA', PostalCode = '1500', Deal_Stage__c = 'Qualified', AppJam_Presenter__c = true, AnnualRevenue = 100000, App_Map_First_Visit__c = criteriaValue);
        insert testLead;
        String strFields = '';
        for(String strField : Schema.SObjectType.Lead.fields.getMap().keySet())
        {
            strFields += strField + ', ';
        }
        String m_strAllLeadFields = strFields.substring(0, strFields.length()-2);
        String strFilterInQuery = 'where Id in (';
        strFilterInQuery += '\'' + testLt.Id + '\', ';
        strFilterInQuery = strFilterInQuery.substring(0, strFilterInQuery.length()-2);
        strFilterInQuery += ')';
        String strQuery = 'select ' + m_strAllLeadFields + ' from Lead ' + strFilterInQuery;
        ReassignLeadsBatch reassignLeadBatchJob = new ReassignLeadsBatch(strQuery);
        Database.executeBatch(reassignLeadBatchJob, 1);
    }
    
    @isTest
    static void testBatch4()
    {
        Id leadTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Lead' limit 1].Id;
        Territory_AppD__c testLt = new Territory_AppD__c(Name = 'Acme', Type__c = 'Geography', Assigned_To_Type__c = 'User', Assigned_To_ID__c = Userinfo.getUserId(), Assigned_To__c = userinfo.getUserName(), Order__c = 1, RecordTypeId = leadTerritoryRecordTypeId);
        insert testLt;
        //AnnualRevenue
        Territory_Field_Criteria__c testLeadFIeldCriteria1 = new Territory_Field_Criteria__c(Field__c = 'Estimated_Close_Date__c', Value__c = '9/8/2014', Operator__c = 'not equal to', Territory__c = testLt.Id);        
        insert new List<Territory_Field_Criteria__c> {testLeadFIeldCriteria1};
        String theDate = '9/8/2014';
        String[] dates = theDate.split('/');
        Date dealDate = Date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
        Territory_Geography__c testLeadGeo = new Territory_Geography__c(Territory__c = testLt.Id, Country__c = 'United States', State__c = 'ca', Zip_Start__c = '1000', Zip_End__c = '2000');
        insert testLeadGeo;
        Lead testLead = new Lead(LastName = 'acme', Status = 'open', Company = 'acme', COuntry = 'USA', State = 'CA', PostalCode = '1500', Deal_Stage__c = 'Qualified', AppJam_Presenter__c = true, AnnualRevenue = 100000, Estimated_Close_Date__c = dealDate);
        insert testLead;
        String strFields = '';
        for(String strField : Schema.SObjectType.Lead.fields.getMap().keySet())
        {
            strFields += strField + ', ';
        }
        String m_strAllLeadFields = strFields.substring(0, strFields.length()-2);
        String strFilterInQuery = 'where Id in (';
        strFilterInQuery += '\'' + testLt.Id + '\', ';
        strFilterInQuery = strFilterInQuery.substring(0, strFilterInQuery.length()-2);
        strFilterInQuery += ')';
        String strQuery = 'select ' + m_strAllLeadFields + ' from Lead ' + strFilterInQuery;
        ReassignLeadsBatch reassignLeadBatchJob = new ReassignLeadsBatch(strQuery);
        Database.executeBatch(reassignLeadBatchJob, 1);
    }
}