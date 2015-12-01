global class GlobalVariables 
{
    global static Map<String, Schema.DisplayType> FieldTypeMap = new Map<String, Schema.DisplayType>();
    global static Map<String, Schema.DisplayType> AccountFieldTypeMap = new Map<String, Schema.DisplayType>();
    global static Map<String, String> fieldLabelToNameMap = new Map<String, String>();
    global static Map<String, Schema.DescribeFieldResult> descirbeFieldResultMap = new Map<String, Schema.DescribeFieldResult>();

    static
    {
        Map<String, Schema.sObjectField> fieldMap = Schema.SObjectType.Lead.fields.getMap();
        for(String field : fieldMap.keySet())
        {
            Schema.DescribeFieldResult fieldResult = fieldMap.get(field).getDescribe();
            FieldTypeMap.put(fieldResult.getName(), fieldResult.getType());  
            fieldLabelToNameMap.put(fieldResult.getLabel(), fieldResult.getName()); 
        }
        
        Map<String, Schema.sObjectField> acctFieldMap = Schema.SObjectType.Account.fields.getMap();
        for(String field : acctFieldMap.keySet())
        {
            Schema.DescribeFieldResult fieldResult = acctFieldMap.get(field).getDescribe();
            AccountFieldTypeMap.put(fieldResult.getName(), fieldResult.getType());  
        }
        
        Map<String, Schema.sObjectField> leadFieldMap = Schema.SObjectType.Lead.fields.getMap();
        for(String field : leadFieldMap.keySet())
        {
            Schema.DescribeFieldResult fieldResult = leadFieldMap.get(field).getDescribe();
            GlobalVariables.descirbeFieldResultMap.put(fieldResult.getLabel(), fieldResult);  
        }
    }
}