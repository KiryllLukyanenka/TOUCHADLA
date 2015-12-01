/*
 * DataLayerConstants.cls
 *
 * Code Generated on 2011-08-03 21:05:51 GMT
 *
 * 2011-08-05 08:05:51 GMT - Modified to include TransactionID, Stage and Process State fields for License
 * 
 * 2011-08-10 08:53:51 GMT - Modified to include TechOwner related fields for User and Account
 */
public with sharing class DataLayerConstants{

    public static List<SObject> fetch(String objName){
        return Database.query(allFieldsQueryMap.get(objName));  
    }
    
    public static SObject fetchSingle(String objName,String Id){
        List<SObject> sobjList = Database.query(allFieldsQueryMap.get(objName)+ ' WHERE Id=\''+Id+'\'');
        return (sobjList!=null && sobjList.size()>0)?sobjList.get(0):null;
    }
    
    public static SObject fetchSingle(String objName,String whereClauseField, String value){
        List<SObject> sobjList = Database.query(allFieldsQueryMap.get(objName)+ ' WHERE '+whereClauseField+'=\''+value+'\'');
        return (sobjList!=null && sobjList.size()>0)?sobjList.get(0):null;
    }
    
    public static SObject fetchSingle(String objName,String whereClauseField, Boolean value){
        List<SObject> sobjList = Database.query(allFieldsQueryMap.get(objName)+ ' WHERE '+whereClauseField+'='+value+'');
        return (sobjList!=null && sobjList.size()>0)?sobjList.get(0):null;
    }
    
    public static List<SObject> fetchMultiple(String objName,String whereClauseField, String value){
        return Database.query(allFieldsQueryMap.get(objName)+ ' WHERE '+whereClauseField+'=\''+value+'\'');
    }
    
    public static SObject fetchSingleWithWhereClause(String objName,String whereClause){
        String queryStr = allFieldsQueryMap.get(objName)+ whereClause+' limit 1';
        System.debug(queryStr);
        List<SObject> sobjList = Database.query(queryStr);
        if(sobjList!=null && sobjList.size()>0){
            return sobjList.get(0);
        }
        return null;
    }
    
    public static List<SObject> fetchMultiple(String objName,String whereClause){
        String queryStr = allFieldsQueryMap.get(objName)+ whereClause;
        System.debug(queryStr);
        return Database.query(queryStr);
    }
    
    public static List<SObject> fetchMultiple(String objName,String whereClauseField, Boolean value){
        return Database.query(allFieldsQueryMap.get(objName)+ ' WHERE '+whereClauseField+'='+value+'');
    }

    /*public static List<SObject> fetch(String objName, Boolean allFields){
        if(allFields){
            return Database.query(allFieldsQueryMap.get(objName));
        }else{
            return Database.query(mandatoryFieldsQueryMap.get(objName));
        }
    }*/
    
    //public final static Map<String,String> mandatoryFieldsQueryMap = new Map<String,String>();

    public final static Map<String,String> allFieldsQueryMap = new Map<String,String>();

    static{

//Defining Queries for Account --start

        //mandatoryFieldsQueryMap.put('Account','SELECT Id, Name FROM Account');

        allFieldsQueryMap.put('Account','SELECT  RecordType.Name,RecordType.Id,Technical_Account_Manager__c,Technical_Account_Manager__r.Id, Technical_Account_Manager__r.Email, CreatedById, OwnerId,Owner.Name,Owner.Email, Owner.isActive,Type, Id, Name, (Select Id, Account__c,Company_Portal_Id__c from Account_Portal_Company__r) FROM Account');


        //Defining Queries for Account --end


        //Defining Queries for AppDynamics_User_Account__c --start

        //mandatoryFieldsQueryMap.put('AppDynamics_User_Account__c','SELECT Contact__c, Enable_Access__c, Id,  FROM AppDynamics_User_Account__c');

        allFieldsQueryMap.put('AppDynamics_User_Account__c','SELECT Contact__c, Enable_Access__c, Status__c, Accesible_Systems__c, User_Type__c, Id, Name FROM AppDynamics_User_Account__c');

        //Defining Queries for AppDynamics_User_Account__c --end


        //Defining Queries for Contact --start

        //mandatoryFieldsQueryMap.put('Contact','SELECT Enable_Access__c, Registered_Fan_Club__c, HasOptedOutOfEmail, HasOptedOutOfFax, DoNotCall, LastName, Id, Name,  FROM Contact');

        //TODO Review: Why was this needed? Contact__r.Account.RecordType.Name,Contact__r.Account.Name,Contact__r.Account.RecordType.Id,Contact__r.Account.Id,Contact__r.Account.PortalID__c,Contact__r.Name,Contact__r.Description,Contact__r.Needs_Email__c,Contact__r.Email, Contact__r.LastName,Contact__r.Accessible_Systems__c,Contact__r.Account.OwnerId, Contact__r.FirstName,Contact__r.LMS_Portal_User_Contact__c, Contact__r.LMS_Cloned__c
        allFieldsQueryMap.put('Contact','SELECT  No_longer_at_Company__c, Email, LastName, Id, Title, Name, Account.RecordType.Name,Account.Name,Account.RecordType.Id, Account.Id,Account.OwnerId, FirstName,Registered_Fan_Club__c, (Select id,Contact__c,User_Portal_Id__c,Docs__c,Download__c,ZenDesk__c,LMS__c ,ADUAUserDetails__c from Contact_Portal_User__r) FROM Contact');

        //Defining Queries for Contact --end


        //Defining Queries for License_Opportunity__c --start

        //mandatoryFieldsQueryMap.put('License_Opportunity__c','SELECT Id, License__c, Name, Opportunity__c FROM License_Opportunity__c');

        allFieldsQueryMap.put('License_Opportunity__c','SELECT Id, License__c, Name, Opportunity__c FROM License_Opportunity__c');

        //Defining Queries for License_Opportunity__c --end


        //Defining Queries for LicenseDetail__c --start

        //mandatoryFieldsQueryMap.put('LicenseDetail__c','SELECT Id,Is_EUM__c, Is_Split__c, Is_HA__c, License_Expiry_Date__c FROM LicenseDetail__c');

        allFieldsQueryMap.put('LicenseDetail__c','SELECT (Select Id,Agent_Type__c, Count__c,License__c,Licensing_Model__c,Expiration_Date__c,Max_Agents__c,Category__c,Retention_Period__c,Edition__c,Enabled__c from License_Agents__r order by CreatedDate),RUM_Enabled__c,RUM_Account_Name__c,RUM_Access_Key__c,RUM_State__c,CreatedById,Manual_SaaS_Fields__c,SaaS_Access_Key__c,Support__c,Controller_Id__c,HA_Source_License__c,LastOpCode__c,License_Time__c,Last_License_User__c, LastModifiedDate,Account_Manager__c,Technical_Owner__c, Sales_Rep__c, Primary_Contact__c,Additional_Contacts__c, Ad_hoc_Email_Ids__c,Machine_Agents_Rollup__c,PHP_Agents_Rollup__c,Database_Agents_Rollup__c,NodeJs_Agents_Rollup__c,Is_Permanent__c,Is_Perpetual__c,BackendStatus__c, Net_Agents_Rollup__c,Reason__c, Id, Is_EUM__c, Stage__c, Name, License_BackendID__c, Backend_Submit_Status__c, MAC_Address__c, Product_Type__c, Java_Agents_Rollup__c, ProcessState__c, Custom_URL_Name__c, Is_HA__c, Transaction_ID__c, License_Expiry_Date__c,Coradiant_Integration_URL__c,SaaS_Account__c,SaaS_UserName__c,SaaS_Password__c,FailoverBackup__c,(select Access_Key__c, AccountName__c,License__c,RUM_Enabled__c,State__c from License_EUM_Details__r)  FROM LicenseDetail__c');

        //Defining Queries for LicenseDetail__c --end
        
        //Defining Queries for OpportunityContactRole --start
        allFieldsQueryMap.put('OpportunityContactRole', 'select contact.AccountId, ContactId,contact.name, contact.FirstName, contact.LastName, contact.Email, contact.No_longer_at_Company__c from OpportunityContactRole');

        
        //Defining Queries for License_Contacts__c --start
        allFieldsQueryMap.put('License_Contacts__c' , 'Select License__c,Contact__r.Id,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Email,Contact__r.No_longer_at_Company__c,Contact__r.Needs_Email__c,Contact_Type__c,Need_Operations_Email__c,Need_Service_Email__c from License_Contacts__c');
        

        //Defining Queries for Opportunity --start

        //mandatoryFieldsQueryMap.put('Opportunity','SELECT IsClosed, Fiscal, HasOpportunityLineItem, Id, Name, ForecastCategory, CloseDate, StageName, IsPrivate,  FROM Opportunity');


        allFieldsQueryMap.put('Opportunity','SELECT IsClosed,Owner.id,Owner.Name,Owner.Email, Id, Name,  Account.Id,Account.Name FROM Opportunity');/*Partner_Technical_Owner__c, Technical_Owner__c,*/
        allFieldsQueryMap.put('Opportunity_Account_Owner','SELECT account.id,account.name,account.owner.username,account.owner.email,IsClosed, Partner_Technical_Owner__c, Technical_Owner__c, Id, Name, AccountId FROM Opportunity');

        //Defining Queries for Opportunity --end


        //Defining Queries for User --start

        //mandatoryFieldsQueryMap.put('User','SELECT ProfileId, Username, Email, EmailEncodingKey, CommunityNickname, LastName,  Id, IsActive, Name, Alias, ReceivesInfoEmails, LocaleSidKey, TimeZoneSidKey FROM User');

        allFieldsQueryMap.put('User','SELECT ContactId, ProfileId, Username, Email, LastName, Id, IsActive, Name, UserType, FirstName, CompanyName FROM User');

        //Defining Queries for User --end


        //Defining Queries for UserOrganization__c --start

        //mandatoryFieldsQueryMap.put('UserOrganization__c','SELECT Id,  FROM UserOrganization__c');

        allFieldsQueryMap.put('UserOrganization__c','SELECT Id, PortalID__c, Name FROM UserOrganization__c');

        //Defining Queries for UserOrganization__c --end
        
        allFieldsQueryMap.put('DBTuna_License__c','SELECT Id, Name, ExpiryDate__c, LicenseKey__c, Opportunity__c, Server_Name__c FROM DBTuna_License__c');
        
        
        allFieldsQueryMap.put('Opportunity_Partner_DBLicense__c','SELECT Id, Name, DBLicense__c, Opportunity__c FROM Opportunity_Partner_DBLicense__c');

        
        allFieldsQueryMap.put('License_EUM_Details__c','SELECT Id, Import_EUM__c, Access_Key__c, AccountName__c, License__c, RUM_Enabled__c, State__c, (select id, Allow_overages__c, License_EUM_Detail__c, Type__c, Units__c from EUM_Web__r),(select id, Allow_overages__c, License_EUM_Detail__c, Type__c, Units__c from EUM_Mobile__r) FROM License_EUM_Details__c');
    }
}