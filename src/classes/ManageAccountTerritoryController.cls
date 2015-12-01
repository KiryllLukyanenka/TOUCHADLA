public class ManageAccountTerritoryController{
    /*Initializing private variables. This variables has ID type, it means
      that the should contains ID of some records. In our case it's a record type ID
      See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_access_modifiers.htm
                  https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_primitives.htm
    */
    private Id territoryGeoRecordTypeId;
    private Id territoryFieldCriteriaId;
    /*Constructor of our class
      See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_constructors.htm?search_text=constructor*/
    public ManageAccountTerritoryController(){
        /*Initializing List of Strings
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_list.htm
        */
        errorMessages = new List<String>();
        /*Initializing List of User objects*/
        users = new List<User>();

        territory = new Territory_AppD__c();
        /*Initializing List of Territory_Geography__c objects*/
        newTerritoryGeos = new List<Territory_Geography__c>();
        /*In this loop we add to "newTerritoryGeos" instances of "Territory_Geography__c" object */
        for(Integer i = 0; i < 5; i++){
            newTerritoryGeos.add(new Territory_Geography__c());
        }
        /*Call "setTerritories" method*/
        setTerritories();
        /*At this 2 rows we make SOQL query to "RecordType" object where we specify "SobjectType" field like sObject API name(in our case it's
        Territory_Geography__c and Territory_Field_Criteria__c). Also we specify "Name" like "Account". You can see "LIMIT 1" 
        keyword, it's means, that only one result should be received. Then, after construction [SELECT...FROM...WHERE...AND] we use ".ID", 
        it's the way to immediately get "ID" value and set it to variable
        See more at https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_recordtype.htm
                    https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/
        */
        territoryGeoRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_Geography__c' and Name = 'Account' limit 1].Id;
        territoryFieldCriteriaId = [select Id from RecordType where SobjectType = 'Territory_Field_Criteria__c' and Name = 'Account' limit 1].Id;
    }
    /*This block it's a block of variables, lists and object's instaces with geters and seters.
      See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_properties.htm 
    */
    public List<User> users { get; set; }
    public String userinfo { get; set; }
    public List<Territory_Geography__c> newTerritoryGeos { get; set; }
    public String AssignmentsCSV { get; set; }
    public List<String> errorMessages { get; set; }
    public List<Territory_AppD__c> territories { get; set; }
    public Territory_AppD__c territory { get; set; }
    public String jsonCriteria { get; set; }
    public String removedId { get; set; }
    public String removedType { get; set; }
    public String territoryOrder { get; set; }
    public String currentTerritoryId { get; set; }
    public Lead leadObject { get; set; }
    public Territory_Setup__c setup { get; set; }
    
       
    /**
     * Public methods ------->
     */
     /*This method has annotation "@RemoteAction" this annotation provides support for Apex methods used in Visualforce t
     o be called via JavaScript
      See more about using Remote Actions at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_RemoteAction.htm
     */
    
    @RemoteAction
    public static void setupStatus(String status){
        for(Territory_Setup__c item : [select Id, Next_Mass_Update_Date__c, Status__c from Territory_Setup__c where Type__c = 'Account/Contact' order by LastModifiedDate desc limit 1]){
            item.Status__c = status;
            update item;
            /*Creating List of "CronJobDetail" objects. This objects contains details about the associated scheduled job, 
            such as the job’s name and type
            See more at https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_cronjobdetail.htm
            */
            List<CronJobDetail> jobDetails = [select Id from  CronJobDetail where name = 'Mass Update Accounts' or Name = 'Mass Update Yesterday Account Territories'];
            /*Creating List of "CronTrigger" objects, which contains schedule information for a scheduled job 
              See more at https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_crontrigger.htm
            */
            List<CronTrigger> conTriggers = [select Id from CronTrigger where CronJobDetailId in :jobDetails];
            /*At this row we create query to get Job and then delete this Job with "database.delete()" method.
              It's a DML operation like simple "delete", but has some differences
              See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_database.htm#apex_System_Database_delete_2 
            */
            database.delete([select Job_ID__c from UpdateAccountJOBID__c where Job_ID__c != null limit 1]);
            for(CronTrigger conTrigger : conTriggers)
            {
                System.abortJob(conTrigger.Id); 
            }
            if(status == 'On')
            {
                if(item.Next_Mass_Update_Date__c != null)
                {
                    Date massUpdateDate = item.Next_Mass_Update_Date__c;
                    /*At this row we use "String.valueOf()" method to fetch String from "massUpdateDate.year()", because
                      "massUpdateDate.year()" has "Date" type, but we need a String
                      See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_string.htm#apex_System_String_valueOf
                    */
                    String year = string.valueOf(massUpdateDate.year());
                    String month = string.valueOf(massUpdateDate.month());
                    String day = string.valueOf(massUpdateDate.day());
                    /*Creating instance of "assignAccountToTerritoriesScheudle" class which implements "Schedulable" interface 
                    (you can find him in list of org classes)
                    See more about "Scheduler" at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_scheduler.htm
                     */
                    assignAccountToTerritoriesScheudle m = new assignAccountToTerritoriesScheudle();
                    /*Creating String for Scheduler which contains date and time, when Scheduler should run*/
                    String sch = '0 0 1 ' + day + ' ' + month + ' ? ' + year;
                    /*At this row we execute Sheduler*/
                    String jobID = system.schedule('Mass Update Accounts', sch, m);
                    /*Creating new instance of UpdateAccountJOBID__c custom object and specify "Name" and "Job_ID__c"
                      fields
                    */
                    UpdateAccountJOBID__c newJob = new UpdateAccountJOBID__c(Name = 'account JOB', Job_ID__c = jobID);
                    insert newJob;
                }
                yesterdayAccountsToTerritoriesSchedule yesterJob = new yesterdayAccountsToTerritoriesSchedule();
                String sch2 = '0 0 1 * * ?';
                String yesterJobId = system.schedule('Mass Update Yesterday Account Territories', sch2, yesterJob);
            }
        }
    }
    /*This method has annotation "@RemoteAction" this annotation provides support for Apex methods used in Visualforce t
     o be called via JavaScript.
      See more about using Remote Actions at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_RemoteAction.htm
     */
    @RemoteAction
    public static String getFieldCriteriaOption(String fieldName){
        String result = '';
        /*At this two rows we use DescribeFieldResult class and SObjectField class to get describe of object field
          and then get values from picklist (if "IF condition" evluates to true)
          See more about DescribeFieldResult class at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_fields_describe.htm
          See more about SObjectField class at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Schema_SObjectField.htm
        */
        Schema.SObjectField sobjectField = Account.SObjectType.getDescribe().Fields.getMap().get(fieldName);
        Schema.DescribeFieldResult fieldDes = sobjectField.getDescribe();
        /*At this row we check for type of field, if it's "picklist" (we using Schema.DisplayType.PICKLIST wich returns 
          enum value, in our case it's picklist)
         See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_enum_Schema_DisplayType.htm
        */
        if(fieldDes.getType() == Schema.DisplayType.PICKLIST){
            /*We iterate over PicklistEntry objects ("fieldDes.getPicklistValues()" returns they) and checking
             for active status ("entry.isActive()" method returns true if this item must be displayed in the 
             drop-down list for the picklist field in the user interface, false otherwise.)
            */
            for(Schema.PicklistEntry entry : fieldDes.getPicklistValues()){
                if(entry.isActive()){
                    /*Create string with picklist's values ( method "getValue()" seturns the value of this item in the picklist)
                      See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Schema_PicklistEntry.htm#apex_Schema_PicklistEntry_getValue
                    */
                    result += entry.getValue() + '[;]';
                }
            }
        }
        return result;
    }
    
    public PageReference saveMassUpdatedDate(){
        if(setup.Next_Mass_Update_Date__c == null){
            errorMessages.add('Please entry the updated date');
            return null;
        }
        /*This row used to create your own transaction control. For this reason we create "savepoint"
          with method "Database.savepoint()" which is used to define a point which can be roll back to. 
          If any error occurs during a transaction, that contains many statements, the application will 
          roll back to the most recent savepoint and the entire transaction will not be aborted"
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_database.htm#apex_System_Database_setSavepoint
        */
        System.savePoint savepoint = Database.setSavePoint();
        try{
            update setup;
            
            List<UpdateAccountJOBID__c> jobs = [select Job_ID__c from UpdateAccountJOBID__c where Job_ID__c != null limit 1];
            if(jobs.size() > 0)
            {
                System.abortJob(jobs[0].Job_ID__c); 
                delete jobs;
            }
            Date massUpdateDate = [select Next_Mass_Update_Date__c from Territory_Setup__c where Id = :setup.Id].Next_Mass_Update_Date__c;
            String year = string.valueOf(massUpdateDate.year());
            String month = string.valueOf(massUpdateDate.month());
            String day = string.valueOf(massUpdateDate.day());
            assignAccountToTerritoriesScheudle m = new assignAccountToTerritoriesScheudle();
            String sch = '0 0 1 ' + day + ' ' + month + ' ? ' + year;
            String jobID = system.schedule('Mass Update Accounts', sch, m);
            UpdateAccountJOBID__c newJob = new UpdateAccountJOBID__c(Name = 'account JOB', Job_ID__c = jobID);
            insert newJob;
        }
        catch(Exception ex){
            errorMessages.add(ex.getMessage());
            /* "Database.rollback" will  restore the database to that point( our "savepoint")
                See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_database.htm#apex_System_Database_rollback
            */
            Database.rollBack(savepoint);
        }
        return null;
    }
    
    public PageReference toggleTerritoryActive(){
        /*At this row we set value to "tid" variable. For this reason we use "ApexPages" class and
         methods "currentPage() (returns the current page's PageReference)", "getParameters() (map of parameters that are 
         included in the page URL)" and "get('tid') (get the value of parameter with name "tid")" For example:
         https://example.com/test/somePage?tid=2&name=test&surname=test. If in "get('tid')" we change "tid" 
         to "name" our "tid" variable will has value 'test'
         See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_System_PageReference_getParameters.htm
                     https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/apex_System_ApexPages_methods.htm
        */
        String tid = ApexPages.currentPage().getParameters().get('tid');
        for(Territory_AppD__c item : territories){
            if(item.Id == tid){
                item.Active__c = !item.Active__c;
                update item;
            }
        }
        PageReference retPage = new PageReference('/apex/ManageAccountTerritory');
        retPage.setRedirect(true);
        return retPage;
    }
    
    public PageReference massupdateTerritoriesImmed()
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
        /*Create instance of "ReassignAccountsBatch" class which implements Database.Batchable<sObject> interface
          and on next row we submits a batch Apex job for execution with "Database.execute()" method
          See more about Batch at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_batch_interface.htm
        */
        ReassignAccountsBatch reassignAcctBatchJob = new ReassignAccountsBatch(strQuery);
        /*See more abou execution at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_database.htm#apex_System_Database_executeBatch_2*/
        Database.executeBatch(reassignAcctBatchJob, 1);
        /*A PageReference is a reference to an instantiation of a page. Among other attributes, PageReferences 
        consist of a URL and a set of query parameter names and values(in our case it's only URL "/apex/ManageAccountTerritory") 
        See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_system_pagereference.htm
        */
        pageReference retPage = new PageReference('/apex/ManageAccountTerritory');
        /*Method "setRedirect" used to redirect. In our case it sets to true and redirect is performed through a client side redirect.
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_System_PageReference_setRedirect.htm
        */
        retPage.setRedirect(true);
        return retPage;
    }
    
    public void addMoreterritoryGeos(){
        for(Integer i = 0; i < 5; i++){
            newTerritoryGeos.add(new Territory_Geography__c());
        }    
    }
    
    public void insertNewTerritoryGeos()
    {
        List<Territory_Geography__c> needToInsertTerritoryGeos = new List<Territory_Geography__c>();
        /*At this loop we iterate over "newTerritoryGeos" List. Accsess to each element of the list occurs by
            "newterritoryGeo" variable. Our List is the List of Objects and we can accsess to fields of "Territory_Geography__c"
            via "newLeadTerritoryGeo.[fieldName]" like "newLeadTerritoryGeo.Territory__c" in our case.
            See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_loops_for_lists.htm

        */
        for(Territory_Geography__c newterritoryGeo : newTerritoryGeos)
        {   /*Call "validGeographicCriteria" method with "newterritoryGeo" parameter. This method returns a Boolean
               value to "IF condition"
            */
            if(validGeographicCriteria(newterritoryGeo))
            {
                if(CurrentTerritoryId != null && CurrentTerritoryId != '')
                {   /*Assigning to field "Territory__c" value of "CurrentTerritoryId" variable */
                    newterritoryGeo.Territory__c = CurrentTerritoryId;
                    newterritoryGeo.RecordTypeId = territoryGeoRecordTypeId;
                    /*Add our "Territory_Geography__c" with changed "Territory__c" and "RecordTypeId" fields to 
                    List "needToInsertTerritoryGeos" */
                    needToInsertTerritoryGeos.add(newterritoryGeo);
                }
            }
        }
        /*Checking, if our List "needToInsertTerritoryGeos" size >0 (it means, that we have some records)*/
        if(needToInsertTerritoryGeos.size() > 0)
        {    /*Insert List of "Territory_Geography__c" objects*/
            insert needToInsertTerritoryGeos;
            setTerritories();
        }
        newTerritoryGeos = new List<Territory_Geography__c>();
        for(Integer i = 0; i < 5; i++)
        {
            newTerritoryGeos.add(new Territory_Geography__c());
        }
        errorMessages.clear();
    }
    
    public void insertNewTerritoryGeosByCSV()
    {
        List<Territory_Geography__c> csvAssignments = analyseCSVString(AssignmentsCSV);
        List<Territory_Geography__c> needToInsertTerritoryGeos = new List<Territory_Geography__c>();
        for(Territory_Geography__c newterritoryGeo : csvAssignments)
        {    /*Call "validGeographicCriteria" method with "newLeadTerritoryGeo" parameter. This method returns a Boolean
               value
             */
            if(validGeographicCriteria(newterritoryGeo))
            {
                if(CurrentTerritoryId != null && CurrentTerritoryId != '')
                {
                    newterritoryGeo.Territory__c = CurrentTerritoryId;
                    newterritoryGeo.RecordTypeId = territoryGeoRecordTypeId;
                    needToInsertTerritoryGeos.add(newterritoryGeo);
                }
            }
        }
        if(needToInsertTerritoryGeos.size() > 0)
        {
            insert needToInsertTerritoryGeos;
            setTerritories();
            AssignmentsCSV = '';
        }
        /*Clearing the "errorMessages" list
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_list.htm#apex_System_List_methods
        */
        errorMessages.clear();
    }
    /*Method which returns "List<SelectOption>". Used on ManageAccountTerritoryPage page*/
    public List<SelectOption> getObjectFields(){
        /*Initialize "List<Selectoptions>"
          See more at https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/apex_pages_selectoption.htm 
        */
        List<SelectOption> result = new List<SelectOption>();
        /*Add value to our list(methods are the same with typical Lists)*/
        result.add(new SelectOption('', '--None--'));
        /*Initialize Map
          https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_map.htm
        */
        /*At this row we use Schema.sObjectField object to get all fields of "Lead" object
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Schema_SObjectField.htm#apex_Schema_SObjectField_getDescribe
                      https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_describe_objects_understanding.htm
                      https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_field_tokens.htm
        */
        Map<String, Schema.SObjectField> fieldMap = Account.SObjectType.getDescribe().Fields.getMap();
        
        List<String> fieldLabels = new List<String>();
        Map<String, String> fieldNames = new Map<String, String>();
        /*In this loop we fill our "fieldNames" Map and "fieldLabels" List. We iterate over "fieldMap" values (method ".values()") 
          To "fieldLabels" we add label of Lead object field and to "fieldNames" we put pair of key(field label, using ".getLabel()") 
          and value(field name, using ".getName()"). Keep in mind, that field Name and Label can be different.
          More about Map methods at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_map.htm#apex_System_Map_methods
        */
        for (Schema.SObjectField field: fieldMap.values()){
            Schema.DescribeFieldResult fieldDes = field.getDescribe();
            fieldLabels.add(fieldDes.getLabel());
            fieldNames.put(fieldDes.getLabel(), fieldDes.getName());
        }
         /*Sorting "fieldLabels" list. See "sort()" method in List methods*/
        fieldLabels.sort();
        
        for (String label: fieldLabels){
            result.add(new SelectOption(fieldNames.get(label), label));
        }
        /*Return of List <Selectoption>*/
        return result;
    }
     /*This metod invokes from ManageAccountTerritoryPage. Use search by method name on the page. 
      See more about pageReference type at https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_quick_start_controller_navigation_methods.htm
    */
    public pageReference createTerritory(){
        if(!validTerritory(territory)){
            return null;
        }
        /*Creating new instance of "Territory_AppD__c" object by cloning "leadTerritory" object(it's instance
            of "Territory_AppD__c" object too)
        See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_sobject.htm#apex_System_SObject_clone
         */
        Territory_AppD__c newTerritory = territory.clone();
        newTerritory.RecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Account'].Id;
        if(territories.isEmpty()){
            newTerritory.Order__c = 1;
        }
        else{
            /*Assigning value to "Order__c" field. Accsess to element of "leadTerritories" by index which consist of the difference between size of 
            "leadTerritories" (we remember, that is the Integer value) and "1". */
            newTerritory.Order__c = territories[territories.size() - 1].Order__c + 1;
        }
        /*Try-catch block used to handle exceptions. In "try" we put a block of code, which will be executed and exception
        can occur. "catch" identifies a block of code that handles a particular type of exception. In a brackets you can see a 
        type of exception that will be handled.
        See more https://developer.salesforce.com/docs/atlas.en-us.apex_workbook.meta/apex_workbook/apex7_2.htm
        */
        try{
            insert newTerritory;
            territories.add(newTerritory);
            setTerritories();
            territory = new Territory_AppD__c();
        }
        catch(Exception ex){
            errorMessages.add(ex.getMessage());
        }
        return null;
    }
    
    public pageReference editTerritory(){
         /*At this row we set value to "territoryId" variable. For this reason we use "ApexPages" class and
         methods "currentPage() (returns the current page's PageReference)", "getParameters() (map of parameters that are 
         included in the page URL)" and "get('territoryId') (get the value of parameter with name "territoryId")" For example:
         https://example.com/test/somePage?territoryId=2&name=test&surname=test. If in "get('territoryId')" we change "territoryId" 
         to "name" our "territoryId" variable will has value 'test'
         See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_System_PageReference_getParameters.htm
                     https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/apex_System_ApexPages_methods.htm
        */
        String territoryId = ApexPages.currentPage().getParameters().get('territoryId');
        for(Territory_AppD__c territory : territories){
            if(territory.Id == territoryId){
                if(!validTerritory(territory)){
                    return null;
                }
                try{
                    update territory;
                    setTerritories();
                }
                catch(Exception ex){
                    errorMessages.add(ex.getMessage());
                }
                return null;
            }
        }
        return null;
    }
    
    public pageReference createGeographicCriteria(){
        /*At this row we create an instance of "Territory_Geography__c" object using casting result of "JSON.deserializeStrict" 
        to "Territory_Geography__c"
        See more about casting https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_casting.htm
        Method "JSON.deserializeStrict" deserializes the specified JSON string into an Apex object of the specified type
        (Territory_Geography__c.class in our case). Parameter "jsonCriteria" taken from ManageLeadTerritoryPage (variable "jsonCriteria" with
        geter and seter) and contains JSON.
        See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_System_Json.htm#apex_System_Json_deserializeStrict
                    http://www.w3schools.com/js/js_json.asp
        */
        Territory_Geography__c criteria = (Territory_Geography__c)JSON.deserializeStrict(jsonCriteria, Territory_Geography__c.class);
        criteria.RecordTypeId = territoryGeoRecordTypeId;
        
        if(!validGeographicCriteria(criteria)){
            return null;
        }
        
        try{
            upsert criteria;
            system.debug('###' + criteria);
            setTerritories();
        }
        catch(Exception ex){system.debug('###' + ex.getMessage());
            errorMessages.add(ex.getMessage());
        }
        return null;
    }
    /*You can see, that the logic of this method is similar with previous "createGeographicCriteria" */
    public pageReference createLeadFieldCriteria(){
        Territory_Field_Criteria__c criteria = (Territory_Field_Criteria__c)JSON.deserializeStrict(jsonCriteria, Territory_Field_Criteria__c.class);
        criteria.RecordTypeId = territoryFieldCriteriaId;
        
        if(!validLeadFieldCriteria(criteria)){
            return null;
        }
        
        try{
            upsert criteria;
            setTerritories();
        }
        catch(Exception ex){
            errorMessages.add(ex.getMessage());
        }
        return null;
    }
    /*At this method that invokes from ManageLeadTerritoryPage we specify, which object's record should be
      deleted. For this, we assigning to "ID" field value of variable "removedId" and use DML operation "delete"
      */
    public pageReference remove(){
        if(removedType == 'territory'){
            delete new Territory_AppD__c(Id = removedId);
        }
        else if(removedType == 'geography'){
            delete new Territory_Geography__c(Id = removedId);
        }
        else if(removedType == 'leadField'){
            delete new Territory_Field_Criteria__c(Id = removedId);
        }
        setTerritories();
        return null;
    }
    /*At this method we assigning new values to "Order__c" field of "Territory_AppD__c" object and
    then update him*/
    public pageReference saveOrder(){
        Integer index = 1;
    /*At this loop we iterate over collection of Strings. But variable it's a simple string "territoryOrder".
          How it works? "territoryOrder" it's a String with mask [String1_orderString2_orderString3_order]. Method "split()"
          returns a list that contains each substring of the String that is terminated by either the end of the String.
          Result of this method will be [String1, String2, String3].
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_string.htm#apex_System_String_split
    */
        for(String orderId : territoryOrder.split('_order')){
            for(Territory_AppD__c territory : territories){
                if(territory.Id == orderId){
                    territory.Order__c = index;
                    break;
                }
            }
            index++;
        }
        update territories;
        setTerritories();
        return null;
    }
    /*This method used to find Users with criteria*/
    public pageReference searchUser(){
        if(userinfo.length() > 1){
             /*We assign a value to "searchValue" variable with wildcards "%" for using "LIKE" operator
              See more at https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_comparisonoperators.htm
            */
            String searchValue = '%' + userinfo + '%';
            users = [select Name, Title, Email, Phone, UserRole.Name from User 
                    where Name like :searchValue or Phone = :userinfo or Email = :userinfo
                    order by Name limit 15];
        }
        return null;
    }
    
    
    /**
     * Private methods ------->
     */
     /*Method which returns Boolean value*/
    private Boolean validTerritory(Territory_AppD__c territory){
        errorMessages = new List<String>();
        if(String.isBlank(territory.Name)){
            errorMessages.add('Account Territory Name is required');
        }
        if(territory.Effective_Date__c == null){
            errorMessages.add('Effective Date is required');
        }
        if(String.isBlank(territory.Assigned_To__c)){
            errorMessages.add('Assign To is required');
        }
        if(errorMessages.isEmpty()){
            return true;
        }
        return false;
    }
    
    private Boolean validGeographicCriteria(Territory_Geography__c geographicCriteria){
        errorMessages = new List<String>();
        /*At this if condition we check "geographicCriteria.Country__c" with method ".isBlank()", this method
          returns true if the specified String is white space, empty (''), or null; otherwise, returns false.
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_string.htm
         */
        if(String.isBlank(geographicCriteria.Country__c)){
            errorMessages.add('Geographic Criteria: Country is required');
        }
        if(!String.isBlank(geographicCriteria.Zip_Start__c) && String.isBlank(geographicCriteria.Zip_End__c)){
            errorMessages.add('Geographic Criteria: Postal End is required');
        }
        if(!String.isBlank(geographicCriteria.Zip_End__c) && String.isBlank(geographicCriteria.Zip_Start__c)){
            errorMessages.add('Geographic Criteria: Postal Start is required');
        }
        if(errorMessages.isEmpty()){
            return true;
        }
        return false;
    }
    /*Method which returns Boolean value. Similar with previous "validGeographicCriteria"*/
    private Boolean validLeadFieldCriteria(Territory_Field_Criteria__c leadFieldCriteria){
        errorMessages = new List<String>();
        if(String.isBlank(leadFieldCriteria.Field__c)){
            errorMessages.add('Field Criteria: Field is required');
        }
        /*At this "IF condition" we use logical operator || (OR). If are both false ("leadFieldCriteria.Operator__c" not equal to "--None--") and
        "leadFieldCriteria.Operator__c" is not blank then the expression evaluates to false.Otherwise the expression evaluates to true
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_expressions_operators_understanding.htm
        */
        if(leadFieldCriteria.Operator__c == '--None--' || String.isBlank(leadFieldCriteria.Operator__c)){
            errorMessages.add('Field Criteria: Operator is required');
        }
        if(leadFieldCriteria.Value__c == '--None--'){
            leadFieldCriteria.Value__c = null;
        }
        if(errorMessages.isEmpty()){
            return true;
        }
        return false;
    }
    /*This method used to fill List of "Territory_AppD__c" objects */
    private void setTerritories(){
        /*Pay attention to SOQL query. We have two subquerys to related objects "Territory_Geographies__r" 
          and "Territory_Field_Criteria__r". Keep in mind, tha we use "__r" when creating subquery to related object. 
          About this and other joins you can read at 
          https://developer.salesforce.com/page/A_Deeper_look_at_SOQL_and_Relationship_Queries_on_Force.com
        */
        territories = [select Id, Name, Type__c, Geo__c, Region__c, Active__c, Assigned_To_Type__c, Assigned_To_ID__c, Assigned_To__c, Order__c, Effective_Date__c,of_Field_Criteria__c,of_Geographic_Criteria__c,
            (select Territory__c, Country__c, State__c, Zip_End__c, Zip_Start__c from Territory_Geographies__r order by CreatedDate desc),
            (select Territory__c, Field__c, Operator__c, Value__c from territory_Field_Criteria__r order by CreatedDate desc)
            from Territory_AppD__c where RecordType.Name = 'Account' order by Order__c];
        
        for(Territory_Setup__c item : [select Next_Mass_Update_Date__c, Status__c from Territory_Setup__c 
                                        where Type__c = 'Account/Contact' order by CreatedDate desc limit 1]){
            setup = item;
        }
    }
    /*This method returns List of "Territory_Geography__c" objects*/
    private List<Territory_Geography__c> analyseCSVString(String assignmentCsv)
    {
        List<Territory_Geography__c> assignmentDetails = new List<Territory_Geography__c>();
        if(assignmentCsv != null && assignmentCsv != '')
        {   /*Creating list of Strings from "assignmentCsv" String with method "split()" ('/n' it's new line) */              
            String[] csvLines = assignmentCsv.split('\n');
            /*In this loop we creating new instance of "Territory_Geography__c" object
              and specifying fields of this object with values, which geting from "fieldValues"
              list. We access to each element by his index(For example "fieldValues[0]" - first value from List)
            */
            for(String csvLine : csvLines)
            {
                List<String> fieldValues = analyseCsvLine(csvLine);
                Territory_Geography__c detail = new Territory_Geography__c();
                detail.Country__c = fieldValues[0];
                detail.State__c = fieldValues[1];
                detail.zip_Start__c = fieldValues[2];
                detail.zip_End__c = fieldValues[3];
                assignmentDetails.add(detail);
            }
        }
        return assignmentDetails;
    }
    
    // This method will analyse the csv line.
    private List<String> analyseCsvLine(String cvsLine)
    {
        List<String> analyseResults = new List<String>();
        if(cvsLine != null)
        {   /*You can see "trim()" method, which returns a copy of the string that no longer contains any leading or 
              trailing white space characters*/
            cvsLine = cvsLine.trim() + ',';
            /*Creating instance of "Pattern" object wit method "compile()", that compiles the regular expression into a 
            Pattern object.
            More about pattern at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_pattern_and_matcher_pattern_methods.htm
            See more about RegExp  at https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
            You can try to write some regular expressions at this site https://regex101.com/
            */
            Pattern cvsPattern = Pattern.compile('("[^"]*("{2})*[^"]*")*[^,]*,'); 
            /*Creating instance of "Matcher" object with method "matcher()"(it's method relates to "Pattern" object!) with parameter "cvsLine" (it's our String,
             where we want to find matches), that creates a Matcher object that matches the input string regExp against this Pattern object.
             See more about Matcher https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_pattern_and_matcher_matcher_methods.htm 
            Pattern object.*/
            Matcher cvsMatcher = cvsPattern.matcher(cvsLine);
            String tempCell ;
            /*Loop with "find()" method. This method attempts to find the next subsequence of the input sequence that matches the pattern. 
              This method returns true if a subsequence of the input sequence matches this Matcher object's pattern.*/
            while(cvsMatcher.find())
            {   /*Method "group()" returns the input subsequence returned by the previous match*/
                tempCell = cvsMatcher.group();
                /*Call to "replaceDoubleQuotationMarks" method */
                tempCell = replaceDoubleQuotationMarks(tempCell);
                analyseResults.add(tempCell);
            }
        }
        return analyseResults;
    }
     /*This method return incoming String in a modified form */
    private String replaceDoubleQuotationMarks(String input)
    {
        if(input != null && input != '')
        {
            input = input.trim();
            /*We using "startsWith()" method to check, our input String begins with the specified prefix or not*/
            if(input.startsWith('"'))
            {   // The string is contained  double quotation marks.
                /*Method "replaceAll()" replaces each substring of a string that matches the regular expression regExp(or simple String) 
                with the replacement sequence replacement. In our case("input = input.replaceAll('""', '"');") for example, we replace
                all "" symbols to " .
                */
                input = input.replaceAll('^"', '');
                input = input.replaceAll('",$', '');    
                input = input.replaceAll('""', '"');
            }
            else
            {
                input = input.replaceAll(',$','' );
            }
                return input;
        }
        return '';
    }
}