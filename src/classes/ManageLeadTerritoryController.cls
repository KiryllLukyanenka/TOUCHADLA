public class ManageLeadTerritoryController {
    /*Initializing private variables with NULL value. This variables has ID type, it means
      that the should contains ID of some records. In our case it's a record type ID
      See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_access_modifiers.htm
                  https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_primitives.htm

    */
    private Id leadTerritoryRecordTypeId = null;
    private Id leadTerritoryGeoRecordTypeId = null;
    private Id leadTerritoryFieldCriteriaId = null;
    /*Constructor of our class
      See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_constructors.htm?search_text=constructor*/
    public ManageLeadTerritoryController(){
        /*Call "setRecordTypeIds" method*/
        setRecordTypeIds();
        /*Initializing List of Strings
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_list.htm
        */
        errorMessages = new List<String>();
        /*Creating instance of "Territory_AppD__c" object and assigning to "RecordTypeId" value of variable "leadTerritoryRecordTypeId"
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_SObjects.htm?search_text=sobject
         */
        leadTerritory = new Territory_AppD__c( RecordTypeId = leadTerritoryRecordTypeId);
        /*Initializing List of User objects*/
        users = new List<User>();
        /*Initializing List of Territory_Geography__c objects*/
        newLeadTerritoryGeos = new List<Territory_Geography__c>();
        /*In this loop we add to "newLeadTerritoryGeos" instances of "Territory_Geography__c" object and specify value of a 
           "RecordTypeId" field
         */
        for(Integer i = 0; i < 5; i++){
            newLeadTerritoryGeos.add(new Territory_Geography__c(RecordTypeId = leadTerritoryGeoRecordTypeId));
        }  
        /*Call "setLeadTerritories" method*/
        setLeadTerritories();
    }
    /*Method which set values to variables*/
    private void setRecordTypeIds()
    {   /*At this 3 rows we make SOQL query to "RecordType" object where we specify "SobjectType" field like sObject API name(in our case it's
        Territory_AppD__c, Territory_Geography__c and Territory_Field_Criteria__c). Also we specify "Name" like "Lead". You can see "LIMIT 1" 
        keyword, it's means, that only one result should be received. Then, after construction [SELECT...FROM...WHERE...AND] we use ".ID", 
        it's the way to immediately get "ID" value and set it to variable
        See more at https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_recordtype.htm
                    https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/
        */
        leadTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Lead' limit 1].Id;
        leadTerritoryGeoRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_Geography__c' and Name = 'Lead' limit 1].Id;
        leadTerritoryFieldCriteriaId = [select Id from RecordType where SobjectType = 'Territory_Field_Criteria__c' and Name = 'Lead' limit 1].Id;
    }
    /*This block it's a block of variables, lists and object's instaces with getters and setters.
      See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_properties.htm 
     */
    public List<User> users { get; set; }
    public List<Group> LeadQueues { get; set; }
    public String userinfo { get; set; }
    public String searchType { get; set; }
    public List<Territory_Geography__c> newLeadTerritoryGeos { get; set; }
    public String AssignmentsCSV { get; set; }
    
    public List<String> errorMessages { get; set; }
    public Territory_AppD__c leadTerritory { get; set; }
    public String jsonCriteria { get; set; }
    public String removedId { get; set; }
    public String removedType { get; set; }
    public String territoryOrder { get; set; }
    public String CurrentTerritoryId { get; set; }
    public Lead leadObject { get; set; }
    
    public List<Territory_AppD__c> leadTerritories { get; set; }
    
       
    /**
     * Public methods ------->
     */
    public void addMoreLeadTerritoryGeos()
    {
         /*In this loop we add  instances of "Territory_Geography__c" object to "newLeadTerritoryGeos" and specify value of a 
           "RecordTypeId" field
         */
        for(Integer i = 0; i < 5; i++)
        {
            newLeadTerritoryGeos.add(new Territory_Geography__c(RecordTypeId = leadTerritoryGeoRecordTypeId));
        }    
    }
    
    public void insertNewLeadTerritoryGeos()
    {
        List<Territory_Geography__c> needToInsertTerritoryGeos = new List<Territory_Geography__c>();
        /*At this loop we iterate over "newLeadTerritoryGeos" List. Accsess to each element of the list occurs by
            "newLeadTerritoryGeo" variable. Our List is the List of Objects and we can accsess to fields of "Territory_Geography__c"
            via "newLeadTerritoryGeo.[fieldName]" like "newLeadTerritoryGeo.Territory__c" in our case.
            See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_loops_for_lists.htm

        */
        for(Territory_Geography__c newLeadTerritoryGeo : newLeadTerritoryGeos)
        {     /*Call "validGeographicCriteria" method with "newLeadTerritoryGeo" parameter. This method returns a Boolean
               value to "IF condition"
            */
            if(validGeographicCriteria(newLeadTerritoryGeo))
            {
                if(CurrentTerritoryId != null && CurrentTerritoryId != '')
                {   /*Assigning to field "Territory__c" value of "CurrentTerritoryId" variable */
                    newLeadTerritoryGeo.Territory__c = CurrentTerritoryId;
                    /*Add our "Territory_Geography__c" with changed "Territory__c" field to List "needToInsertTerritoryGeos" */
                    needToInsertTerritoryGeos.add(newLeadTerritoryGeo);
                }
            }
        }
        /*Checking, if our List "needToInsertTerritoryGeos" size >0 (it means, that we have some records)*/
        if(needToInsertTerritoryGeos.size() > 0)
        {   /*Insert List of "Territory_Geography__c" objects
            See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_section.htm
            */
            insert needToInsertTerritoryGeos;
            /*Call "setLeadTerritories" method*/
            setLeadTerritories();
        }
        newLeadTerritoryGeos = new List<Territory_Geography__c>();
        for(Integer i = 0; i < 5; i++)
        {
            newLeadTerritoryGeos.add(new Territory_Geography__c(RecordTypeId = leadTerritoryGeoRecordTypeId));
        }
        errorMessages.clear();
    }
    
    public void insertNewLeadTerritoryGeosByCSV()
    {
        /* We call analyseCSVString where we convert AssignmentsCSV String to List of Territory_Geography__c objects.
        Use search by method name 'analyseCSVString' to learn how it is implemented.*/
        List<Territory_Geography__c> csvAssignments = analyseCSVString(AssignmentsCSV);
        List<Territory_Geography__c> needToInsertTerritoryGeos = new List<Territory_Geography__c>();
        for(Territory_Geography__c newLeadTerritoryGeo : csvAssignments)
        {  /*Call "validGeographicCriteria" method with "newLeadTerritoryGeo" parameter. This method returns a Boolean
               value
         */
            if(validGeographicCriteria(newLeadTerritoryGeo))
            {
                if(CurrentTerritoryId != null && CurrentTerritoryId != '')
                {
                    newLeadTerritoryGeo.Territory__c = CurrentTerritoryId;
                    newLeadTerritoryGeo.RecordTypeId = leadTerritoryGeoRecordTypeId;
                    needToInsertTerritoryGeos.add(newLeadTerritoryGeo);
                }
            }
        }
        if(needToInsertTerritoryGeos.size() > 0)
        {
            insert needToInsertTerritoryGeos;
            setLeadTerritories();
            AssignmentsCSV = '';
        }
        /*Clearing the "errorMessages" list
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_list.htm#apex_System_List_methods
        */
        errorMessages.clear();
    }
    /*Method which returns "List<SelectOption>". Used on ManageLeadTerritoryPage page*/
    public List<SelectOption> getLeadFields()
    {   /*Initialize "List<Selectoptions>"
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
        Map<String, Schema.SObjectField> fieldMap = Lead.SObjectType.getDescribe().Fields.getMap();
        
        List<String> fieldLabels = new List<String>();
        Map<String, String> fieldNames = new Map<String, String>();
        /*In this loop we fill our "fieldNames" Map and "fieldLabels" List. We iterate over "fieldMap" values (method ".values()") 
          To "fieldLabels" we add label of Lead object field and to "fieldNames" we put pair of key(field label, using ".getLabel()") 
          and value(field name, using ".getName()"). Keep in mind, that field Name and Label can be different.
          More about Map methods at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_map.htm#apex_System_Map_methods
        */
        for (Schema.SObjectField field: fieldMap.values())
        {
            Schema.DescribeFieldResult fieldDes = field.getDescribe();
            fieldLabels.add(fieldDes.getLabel());
            fieldNames.put(fieldDes.getLabel(), fieldDes.getName());
        }
        /*Sorting "fieldLabels" list. See "sort()" method in List methods*/
        fieldLabels.sort();
        for (String label: fieldLabels) 
        {
            result.add(new SelectOption(fieldNames.get(label), label));
        }
        /*Return of List <Selectoption>*/
        return result;
    }
    /*This metod invokes from ManageLeadTerritoryPage. Use search by method name on the page. 
      See more about pageReference type at https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_quick_start_controller_navigation_methods.htm
    */
    public pageReference createLeadTerritory(){
        if(!validLeadTerritory(leadTerritory)){
            return null;
        }
        /*Creating new instance of "Territory_AppD__c" object by cloning "leadTerritory" object(it's instance
            of "Territory_AppD__c" object too)
        See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_sobject.htm#apex_System_SObject_clone
         */
        Territory_AppD__c newTerritory = leadTerritory.clone();
        if(leadTerritories.isEmpty()){
            newTerritory.Order__c = 1;
        }
        else{
            /*Assigning value to "Order__c" field. Accsess to element of "leadTerritories" by index which consist of the difference between size of 
            "leadTerritories" (we remember, that is the Integer value) and "1". */
            newTerritory.Order__c = leadTerritories[leadTerritories.size() - 1].Order__c + 1;
        }
        /*Try-catch block used to handle exceptions. In "try" we put a block of code, which will be executed and exception
        can occur. "catch" identifies a block of code that handles a particular type of exception. In a brackets you can see a 
        type of exception that will be handled.
        See more https://developer.salesforce.com/docs/atlas.en-us.apex_workbook.meta/apex_workbook/apex7_2.htm
        */
        try{
            insert newTerritory;
            leadTerritories.add(newTerritory);
            setLeadTerritories();
            leadTerritory = new Territory_AppD__c(RecordTypeId = leadTerritoryRecordTypeId);
        }
        catch(Exception ex){
            errorMessages.add(ex.getMessage());
        }
        return null;
    }
    
    public pageReference editLeadTerritory(){
        /*At this row we set value to "territoryId" variable. For this reason we use "ApexPages" class and
         methods "currentPage() (returns the current page's PageReference)", "getParameters() (map of parameters that are 
         included in the page URL)" and "get('id') (get the value of parameter with name "id")" For example:
         https://example.com/test/somePage?id=2&name=test&surname=test. If in "get('id')" we change "id" to "name" our
         "territoryId" variable will has value 'test'
         See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_System_PageReference_getParameters.htm
                     https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/apex_System_ApexPages_methods.htm
        */
        String territoryId = ApexPages.currentPage().getParameters().get('id');
        for(Territory_AppD__c territory : leadTerritories){
            if(territory.Id == territoryId){
                if(!validLeadTerritory(territory)){
                    return null;
                }
                try{
                    update territory;
                    setLeadTerritories();
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
        
        if(!validGeographicCriteria(criteria)){
            return null;
        }
        try{
            criteria.RecordTypeId =leadTerritoryGeoRecordTypeId;
            upsert criteria;
            setLeadTerritories();
        }
        catch(Exception ex){
            errorMessages.add(ex.getMessage());
        }
        return null;
    }
    /*You can see, that the logic of this method is similar with previous "createGeographicCriteria" */
    public pageReference createLeadFieldCriteria(){
        Territory_Field_Criteria__c criteria = (Territory_Field_Criteria__c)JSON.deserializeStrict(
            jsonCriteria, Territory_Field_Criteria__c.class);
        if(!validLeadFieldCriteria(criteria)){
            return null;
        }
        
        try{
            criteria.RecordTypeId = leadTerritoryFieldCriteriaId;
            upsert criteria;
            setLeadTerritories();
        }
        catch(Exception ex){
            errorMessages.add(ex.getMessage());
        }
        return null;
    }
    /*At this method that is invoked from ManageLeadTerritoryPage we specify, which object's record should be
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
        setLeadTerritories();
        return null;
    }
    /*At this method we assigning new values to "Order__c" field of "Territory_AppD__c" object and
    then update him*/
    public pageReference saveOrder(){
        Integer index = 1;
        /*At this loop we iterate over collection of Strings. But variable it's a simple string "territoryOrder".
          How it works? "territoryOrder" is a String with mask [String1_orderString2_orderString3_order]. Method "split()"
          returns a list that contains each substring of the String that is terminated by either the end of the String or '_order' substring.
          Result of this method is an array [String1, String2, String3].
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_string.htm#apex_System_String_split
        */
        for(String orderId : territoryOrder.split('_order')){
            for(Territory_AppD__c territory : leadTerritories){
                if(territory.Id == orderId){
                    territory.Order__c = index;
                    break;
                }
            }
            index++;
        }
        update leadTerritories;
        setLeadTerritories();
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
                    where Name like :searchValue
                    or Phone = :userinfo
                    or Email = :userinfo limit 15];
            LeadQueues = [select Id, Name from Group where Type = 'Queue' and Name like :searchValue limit 15];
        }
        return null;
    }
    
    
    /**
     * Private methods ------->
     */
     /*Method which returns Boolean value*/
    private Boolean validLeadTerritory(Territory_AppD__c leadTerritory){
        errorMessages = new List<String>();
        /*At this if condition we check "leadTerritory.Name" with method ".isBlank()", this method
          returns true if the specified String is white space, empty (''), or null; otherwise, returns false.
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_string.htm
         */
        if(String.isBlank(leadTerritory.Name)){
            errorMessages.add('Lead Territory Name is required');
        }
        if(leadTerritory.Type__c == null){
            errorMessages.add('Type is required');
        }
        if(String.isBlank(leadTerritory.Assigned_To__c)){
            errorMessages.add('Assign To is required');
        }
        if(errorMessages.isEmpty()){
            return true;
        }
        return false;
    }
     /*Method which returns Boolean value. Similar with previous "validLeadTerritory"*/
    private Boolean validGeographicCriteria(Territory_Geography__c geographicCriteria){
        errorMessages = new List<String>();
        if(String.isBlank(geographicCriteria.Country__c)){
            errorMessages.add('Geographic Criteria: Country is required');
        }
        /*At this "IF condition" we use logical operator && (AND) If are both true then the expression evaluates to true. 
        Otherwise the expression evaluates to false.Pay attention to logical complement "!" ("!String.isBlank(geographicCriteria.Zip_Start__c").
        This operator inverts the value of a Boolean, so that true becomes false, and false becomes true.
        See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_expressions_operators_understanding.htm
        */
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
    /*Method which returns Boolean value. Similar with previous "validLeadTerritory" method*/
    private Boolean validLeadFieldCriteria(Territory_Field_Criteria__c leadFieldCriteria){
        errorMessages = new List<String>();
        if(String.isBlank(leadFieldCriteria.Field__c)){
            errorMessages.add('Lead Field Criteria: Field is required');
        }
        /*At this "IF condition" we use logical operator || (OR). If are both false ("leadFieldCriteria.Operator__c" not equal to "--None--") and
        "leadFieldCriteria.Operator__c" is not blank then the expression evaluates to false.Otherwise the expression evaluates to true
          See more at https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_expressions_operators_understanding.htm
        */
        if(leadFieldCriteria.Operator__c == '--None--' || String.isBlank(leadFieldCriteria.Operator__c)){
            errorMessages.add('Lead Field Criteria: Operator is required');
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
    private void setLeadTerritories(){//Assigned_To_User__c, Assigned_To_User__r.Name, 
        /*Pay attention to SOQL query. We have two subquerys to related objects "Territory_Geographies__r" 
          and "Territory_Field_Criteria__r". Keep in mind, tha we use "__r" when creating subquery to related object. 
          About this and other joins you can read at 
          https://developer.salesforce.com/page/A_Deeper_look_at_SOQL_and_Relationship_Queries_on_Force.com
        */
        leadTerritories = [select Id, Name, Type__c,  Assigned_To_Type__c, Assigned_To_ID__c, Assigned_To__c, Order__c, of_Field_Criteria__c, of_Geographic_Criteria__c,
            (select Territory__c, Country__c, State__c, Zip_End__c, Zip_Start__c from Territory_Geographies__r order by CreatedDate desc),
            (select Territory__c, Field__c, Operator__c, Value__c from territory_Field_Criteria__r order by CreatedDate desc)
            from Territory_AppD__c where RecordTypeId = :leadTerritoryRecordTypeId order by Order__c];
    }
    /*This method returns List of "Territory_Geography__c" objects*/
    private List<Territory_Geography__c> analyseCSVString(String assignmentCsv)
    {
        List<Territory_Geography__c> assignmentDetails = new List<Territory_Geography__c>();
        if(assignmentCsv != null && assignmentCsv != '')
        {    
            /*Creating list of Strings from "assignmentCsv" String with method "split()" */          
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
                detail.RecordTypeId = leadTerritoryGeoRecordTypeId;
                assignmentDetails.add(detail);
            }
        }
        return assignmentDetails;
    }
    
    // This method will analyse the  csv line.
    private List<String> analyseCsvLine(String cvsLine)
    {
        List<String> analyseResults = new List<String>();
        if(cvsLine != null)
        {
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