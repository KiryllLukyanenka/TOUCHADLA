public class EditLeadTerritoryController{

    private static final Integer PAGE_SIZE = 100; 
    private String leadTerritoryID = ApexPages.currentPage().getParameters().get('id');
    private Id leadTerritoryRecordTypeId = null;
    private Id leadTerritoryGeoRecordTypeId = null;
    private Id leadTerritoryFieldCriteriaId = null;
    
    public EditLeadTerritoryController(){
        errorMessages = new List<String>();
        setRecordTypeIds();
        setLeadTerritory();
        
        newLeadTerritoryGeos = new List<Territory_Geography__c>();
        for(Integer i = 0; i < 5; i++)
        {
            newLeadTerritoryGeos.add(new Territory_Geography__c(Territory__c = leadTerritoryID, RecordTypeId = leadTerritoryGeoRecordTypeId));
        }  
        users = new List<User>();
        initLeadFieldsAndOperators();
        searchType = leadTerritory.Assigned_To_Type__c;
    }
    
    public List<Territory_Geography__c> currentGeos { get; set; }
    public ApexPages.StandardSetController SSC { get; set; }
    public Integer TotalPageNumber{get;set;}      //total pages
    public Integer CurrentPageNumber {get;set;}   //current pages
    public Integer TotalRecordNumber { get; set; }
    
    public void first()
    {
        ssc.first();  
        CurrentPageNumber = SSC.getPageNumber();
        currentGeos = SSC.getRecords();
    }
    
    public void next()
    {
        SSC.next();    
        CurrentPageNumber = SSC.getPageNumber();
        currentGeos = SSC.getRecords();
    }
    
    public void previous()
    {
        SSC.previous();
        CurrentPageNumber = SSC.getPageNumber();
        currentGeos = SSC.getRecords();
    }
    public void last()
    {
        SSC.last();
        CurrentPageNumber = SSC.getPageNumber();
        currentGeos = SSC.getRecords();
    }
    
    public void getThePageRecords()
    {
        ssc.setPageNumber(CurrentPageNumber);
        currentGeos = SSC.getRecords();
    }
    
    public Boolean hasNext 
    {
        get 
        {
            return SSC<>null? SSC.getHasNext() : false;
        }
        set;
    }

    public Boolean hasPrevious 
    {
        get 
        {
            return SSC <> null ? SSC.getHasPrevious() : false;
        }
        set;
    }
    
    public Boolean hasFirst 
    {
        get 
        {
            return SSC<>null && SSC.getPageNumber() > 1 ? true : false;
        }
        set;
    }
    
    public Boolean hasLast 
    {
        get 
        {
            return ssc<>null && ssc.getPageNumber() < TotalPageNumber? true : false;
        }
        set;
    }
    
    public Boolean hasData
    {
        get
        {
            return ssc <> null?ssc.getResultSize()>0:false;
        }
        set;
    }
    
    private void setRecordTypeIds()
    {
        leadTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Lead' limit 1].Id;
        leadTerritoryGeoRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_Geography__c' and Name = 'Lead' limit 1].Id;
        leadTerritoryFieldCriteriaId = [select Id from RecordType where SobjectType = 'Territory_Field_Criteria__c' and Name = 'Lead' limit 1].Id;
    }
    
    public List<User> users { get; set; }
    public String userinfo { get; set; }
    public String searchType { get; set; }
    public List<Group> LeadQueues { get; set; }
      
    public Territory_AppD__c leadTerritory { get; set; }
    public List<String> errorMessages { get; set; }
    public String jsonCriteria { get; set; }
    public String removedId { get; set; }
    public String removedType { get; set; }
    public List<Territory_Geography__c> newLeadTerritoryGeos { get; set; }
    public String AssignmentsCSV { get; set; }
    public Lead leadObject { get; set; }
    
    public List<SelectOption> LeadFieldOptions { get; set; }
    
    public pageReference searchUser(){
        if(userinfo.length() > 1){
          String searchValue = '%' + userinfo + '%';
          users = [select Name, Title, Email, Phone, UserRole.Name from User 
              where Name like :searchValue
              or Phone = :userinfo
              or Email = :userinfo limit 15];
              
              LeadQueues = [select Id, Name from Group where Type = 'Queue' and Name like :searchValue limit 15];
        }
        return null;
    }
  
    public void addMoreLeadTerritoryGeos()
    {
        for(Integer i = 0; i < 5; i++)
        {
            newLeadTerritoryGeos.add(new Territory_Geography__c(Territory__c = leadTerritoryID, RecordTypeId = leadTerritoryGeoRecordTypeId));
        }    
    }
    
    public void insertNewLeadTerritoryGeos()
    {
        List<Territory_Geography__c> needToInsertTerritoryGeos = new List<Territory_Geography__c>();
         for(Territory_Geography__c newLeadTerritoryGeo : newLeadTerritoryGeos)
        {    
            if(!(String.isBlank(newLeadTerritoryGeo.Country__c) && String.isBlank(newLeadTerritoryGeo.State__c) && String.isBlank(newLeadTerritoryGeo.Zip_Start__c) && String.isBlank(newLeadTerritoryGeo.Zip_End__c)))
            {
                needToInsertTerritoryGeos.add(newLeadTerritoryGeo);
            }
        }
        if(needToInsertTerritoryGeos.size() > 0)
        {
            insert needToInsertTerritoryGeos;
            setLeadTerritory();
        }
        newLeadTerritoryGeos = new List<Territory_Geography__c>();
        for(Integer i = 0; i < 5; i++)
        {
            newLeadTerritoryGeos.add(new Territory_Geography__c(Territory__c = leadTerritoryID, RecordTypeId = leadTerritoryGeoRecordTypeId));
        }     
    }
    
    public void insertNewLeadTerritoryGeosByCSV()
    {
        List<Territory_Geography__c> csvAssignments = analyseCSVString(AssignmentsCSV);
        List<Territory_Geography__c> needToInsertTerritoryGeos = new List<Territory_Geography__c>();
         for(Territory_Geography__c newLeadTerritoryGeo : csvAssignments)
        {    
            if(!(String.isBlank(newLeadTerritoryGeo.Country__c) && String.isBlank(newLeadTerritoryGeo.State__c) && String.isBlank(newLeadTerritoryGeo.Zip_Start__c) && String.isBlank(newLeadTerritoryGeo.Zip_End__c)))
            {
                needToInsertTerritoryGeos.add(newLeadTerritoryGeo);
            }
        }
        if(needToInsertTerritoryGeos.size() > 0)
        {
            insert needToInsertTerritoryGeos;
            setLeadTerritory();
        }
    }
    
    public List<SelectOption> getLeadFields()
    {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '--None--'));
        
        Map<String, Schema.SObjectField> fieldMap = Lead.SObjectType.getDescribe().Fields.getMap();
        
        List<String> fieldLabels = new List<String>();
        Map<String, String> fieldNames = new Map<String, String>();
        for (Schema.SObjectField field: fieldMap.values())
        {
            Schema.DescribeFieldResult fieldDes = field.getDescribe();
            fieldLabels.add(fieldDes.getLabel());
            fieldNames.put(fieldDes.getLabel(), fieldDes.getName());
        }
        fieldLabels.sort();
        
        for (String label: fieldLabels) 
        {
            result.add(new SelectOption(fieldNames.get(label), label));
        }
        
        return result;
    }
    
    public pageReference saveLeadTerritory(){
        if(!validLeadTerritory(leadTerritory)){
            return null;
        }
        try{
            update leadTerritory;
            setLeadTerritory();
        }
        catch(Exception ex){
            errorMessages.add(ex.getMessage());
        }
        return null;
    }
    
    public pageReference createGeographicCriteria(){
        Territory_Geography__c criteria = (Territory_Geography__c)JSON.deserializeStrict(jsonCriteria, Territory_Geography__c.class);
        
        if(!validGeographicCriteria(criteria)){
            return null;
        }
        
        try{
            criteria.RecordTypeId = leadTerritoryGeoRecordTypeId;
            upsert criteria;
            setLeadTerritory();
        }
        catch(Exception ex){
            errorMessages.add(ex.getMessage());
        }
        return null;
    }
    
    public pageReference createLeadFieldCriteria(){
        Territory_Field_Criteria__c criteria = (Territory_Field_Criteria__c)JSON.deserializeStrict(
            jsonCriteria, Territory_Field_Criteria__c.class);
        if(!validLeadFieldCriteria(criteria)){
            return null;
        }
        
        try{
            criteria.RecordTypeId = leadTerritoryFieldCriteriaId;
            upsert criteria;
            setLeadTerritory();
        }
        catch(Exception ex){
            errorMessages.add(ex.getMessage());
        }
        return null;
    }
    
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
        setLeadTerritory();
        return null;
    }
    
    
    /**
     * Private methods ------->
     */
    private Boolean validLeadTerritory(Territory_AppD__c leadTerritory){
        errorMessages = new List<String>();
        if(String.isBlank(leadTerritory.Name)){
            errorMessages.add('Lead Territory Name is required');
        }
        if(leadTerritory.Type__c == null){
            errorMessages.add('Type is required');
        }
        if(errorMessages.isEmpty()){
            return true;
        }
        return false;
    }
    
    private Boolean validGeographicCriteria(Territory_Geography__c geographicCriteria){
        errorMessages = new List<String>();
        if(String.isBlank(geographicCriteria.Country__c)){
            errorMessages.add('Geographic Criteria: Country is required');
        }/*
        if(String.isBlank(geographicCriteria.State__c)){
            errorMessages.add('Geographic Criteria: State is required');
        }
        if(String.isBlank(geographicCriteria.Zip_Start__c)){
            errorMessages.add('Geographic Criteria: Postal Start is required');
        }
        if(String.isBlank(geographicCriteria.Zip_End__c)){
            errorMessages.add('Geographic Criteria: Postal End is required');
        }*/
        if(errorMessages.isEmpty()){
            return true;
        }
        return false;
    }
    
    private Boolean validLeadFieldCriteria(Territory_Field_Criteria__c leadFieldCriteria){
        errorMessages = new List<String>();
        if(String.isBlank(leadFieldCriteria.Field__c)){
            errorMessages.add('Geographic Criteria: Field is required');
        }
        if(String.isBlank(leadFieldCriteria.Operator__c)){
            errorMessages.add('Geographic Criteria: Operator is required');
        }
        if(String.isBlank(leadFieldCriteria.Value__c)){
            errorMessages.add('Geographic Criteria: Value is required');
        }
        if(errorMessages.isEmpty()){
            return true;
        }
        return false;
    }
    
    private void setLeadTerritory(){//Assigned_To_User__c, Assigned_To_User__r.Name,
        leadTerritory = [select Id, Name, Type__c,  Assigned_To__c, Assigned_To_ID__c, Assigned_To_Type__c, Order__c, 
            (select Territory__c, Country__c, State__c, Zip_End__c, Zip_Start__c from Territory_Geographies__r order by Country__c, State__c),
            (select Territory__c, Field__c, Operator__c, Value__c from Territory_Field_Criteria__r order by Field__c)
            from Territory_AppD__c where Id = :leadTerritoryID];
            
            SSC = new ApexPages.StandardSetController(Database.getQueryLocator([select Territory__c, Country__c, State__c, Zip_End__c, Zip_Start__c from Territory_Geography__c where Territory__c =:leadTerritoryID order by Country__c, State__c ]));
            if(SSC != null)
            {
                TotalRecordNumber = SSC.getResultSize();
                SSC.setPageSize(PAGE_SIZE);
                TotalPageNumber = SSC.getResultSize() / PAGE_SIZE + (Math.mod(SSC.getResultSize(), PAGE_SIZE) == 0 ? 0 : 1);
                CurrentPageNumber = ssc.getPageNumber();
                currentGeos = SSC.getRecords();
            } 
    }
    
    // This method will analyse the  csv line.
    private List<String> analyseCsvLine(String cvsLine)
    {
        List<String> analyseResults = new List<String>();
        if(cvsLine != null)
        {
            cvsLine = cvsLine.trim() + ',';
            Pattern cvsPattern = Pattern.compile('("[^"]*("{2})*[^"]*")*[^,]*,'); 
            Matcher cvsMatcher = cvsPattern.matcher(cvsLine);
            String tempCell ;
            while(cvsMatcher.find())
            {
                tempCell = cvsMatcher.group();
                tempCell = replaceDoubleQuotationMarks(tempCell);
                analyseResults.add(tempCell);
            }
        }
        return analyseResults;
    }

    private String replaceDoubleQuotationMarks(String input)
    {
        if(input != null && input != '')
        {
            input = input.trim();
            if(input.startsWith('"'))
            {   // The string is contained  double quotation marks.
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
    
    private void initLeadFieldsAndOperators()
    {
        LeadFieldOptions = new List<SelectOption>();
        List<String> fieldLabels = new List<String>();
        for(String key : GlobalVariables.descirbeFieldResultMap.keySet())
        {
            fieldLabels.add(key);
        }
        fieldLabels.sort();
        for(String fieldLabel : fieldLabels)
        {
            Schema.DescribeFieldResult result = GlobalVariables.descirbeFieldResultMap.get(fieldLabel);
            LeadFieldOptions.add(new SelectOption(result.getName(), fieldLabel));
        }
    }
    
    private List<Territory_Geography__c> analyseCSVString(String assignmentCsv)
    {
        List<Territory_Geography__c> assignmentDetails = new List<Territory_Geography__c>();
        if(assignmentCsv != null && assignmentCsv != '')
        {              
            String[] csvLines = assignmentCsv.split('\n');
            for(String csvLine : csvLines)
            {
                List<String> fieldValues = analyseCsvLine(csvLine);
                Territory_Geography__c detail = new Territory_Geography__c(Territory__c = leadTerritoryID);
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
}