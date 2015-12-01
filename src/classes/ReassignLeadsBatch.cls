global class ReassignLeadsBatch implements Database.Batchable<sObject>
{
    String query;
    List<Territory_AppD__c> allLeadTerritories; 
    Map<String, String> fieldLabelToNameMap ;
    Id leadTerritoryRecordTypeId = null;
    Map<Id, List<Territory_Geography__c>> leadGeosMap = new Map<Id, List<Territory_Geography__c>>();
    Map<Id, List<Territory_Field_Criteria__c>> leadFieldsMap = new Map<Id, List<Territory_Field_Criteria__c>>();
    
    public ReassignLeadsBatch(String query)
    {
        leadTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Lead' limit 1].Id;
        this.query = query;
        fieldLabelToNameMap = GlobalVariables.fieldLabelToNameMap;
        //(select Territory__c, Country__c, State__c, Zip_End__c, Zip_Start__c from Territory_Geographies__r order by Country__c, State__c),
        //(select Territory__c, Field__c, Operator__c, Value__c from Territory_Field_Criteria__r order by Field__c)
        allLeadTerritories = [select Id, Name, Type__c,  Assigned_To__c, Assigned_To_ID__c, Assigned_To_Type__c, Order__c                         
            from Territory_AppD__c where RecordTypeId = :leadTerritoryRecordTypeId order by Order__c];
        for(Territory_Geography__c geo : [select Id, Territory__c, Country__c, State__c, Zip_End__c, Zip_Start__c from Territory_Geography__c where Territory__c in :allLeadTerritories order by Country__c, State__c ])
        {
            if(leadGeosMap.containskey(geo.Territory__c))
            {
                leadGeosMap.get(geo.Territory__c).add(geo);
            }
            else
            {
                leadGeosMap.put(geo.Territory__c, new List<Territory_Geography__c> {geo});
            }
        }
        for(Territory_Field_Criteria__c fieldCri : [select Id, Territory__c, Field__c, Operator__c, Value__c from Territory_Field_Criteria__c where Territory__c in :allLeadTerritories order by Field__c])
        {
            if(leadFieldsMap.containskey(fieldCri.Territory__c))
            {
                leadFieldsMap.get(fieldCri.Territory__c).add(fieldCri);
            }
            else
            {
                leadFieldsMap.put(fieldCri.Territory__c, new List<Territory_Field_Criteria__c> {fieldCri});
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        List<Lead> leads = (List<Lead>)scope;
        Lead thisLead = leads[0];system.debug('###' + thisLead);
        for(Territory_AppD__c leadTerritory : allLeadTerritories)
        {
            List<Territory_Geography__c> thisLeadGeos = leadGeosMap.get(leadTerritory.Id);
            List<Territory_Field_Criteria__c> thisLeadFields = leadFieldsMap.get(leadTerritory.Id);
            if((thisLeadGeos != null && thisLeadGeos.size() > 0) || (thisLeadFields != null && thisLeadFields.size() > 0) )
            {
                Boolean isMatchTerField = false;
                Boolean isFindTerritory = false;
                if(thisLeadGeos == null || (thisLeadGeos != null && thisLeadGeos.size() == 0))
                {
                    isFindTerritory = true;
                }
                else
                {
                    String country = thisLead.Routing_Country__c != null ? thisLead.Routing_Country__c.toLowerCase() : '';
                    String state = thisLead.Routing_State_Province__c != null ? thisLead.Routing_State_Province__c.toLowerCase() : '';
                    String postalCode = thisLead.Routing_Postal_Code__c != null ? thisLead.Routing_Postal_Code__c.toLowerCase() : '';
                    String countryState = country + '/' + state;
                    String justCountry = country + '/';
                    map<String, List<Territory_Geography__c>> countryStateToGeosMap = new map<String, List<Territory_Geography__c>>();
                    Boolean justCountryGeo = false;
                    for(Territory_Geography__c leadgeo : thisLeadGeos)
                    {
                        String theCountryState = (leadgeo.Country__c != null ? leadgeo.Country__c.toLowerCase() : '') + '/' + (leadgeo.State__c != null?leadgeo.State__c.toLowerCase():'');
                        if(countryStateToGeosMap.containsKey(theCountryState))
                        {
                            countryStateToGeosMap.get(theCountryState).add(leadgeo);
                        }
                        else
                        {
                            countryStateToGeosMap.put(theCountryState, new List<Territory_Geography__c> {leadgeo});
                        }
                    }
                    String theMapKey = countryState;
                    if(countryStateToGeosMap.containsKey(justCountry))
                    {
                        theMapKey = justCountry;
                    }
                    List<Territory_Geography__c> theCountryStateGeos = countryStateToGeosMap.get(theMapKey);
                    system.debug('###' + theCountryStateGeos);
                    if(theCountryStateGeos != null && theCountryStateGeos.size() > 0)
                    {
                        for(Territory_Geography__c theCountryStateGeo : theCountryStateGeos)
                        {
                            if(isInPostalRange(thisLead.Routing_Postal_Code__c, theCountryStateGeo.Zip_Start__c, theCountryStateGeo.Zip_End__c))
                            {
                                isFindTerritory = true;
                                break;
                            }
                        }
                    }
                }
                system.debug('###' + isFindTerritory);
                if(isFindTerritory)
                {
                    if(thisLeadFields == null || (thisLeadFields!= null && thisLeadFields.size() == 0))
                    {
                        isMatchTerField = true;
                    }
                    else
                    {
                        Boolean isPassTheFieldCriteria = true;
                        for(Territory_Field_Criteria__c criteria: thisLeadFields)
                        {
                            String thisFieldName = criteria.Field__c; 
                            //STring thisFieldValue = thisLead.get(thisFieldName);
                            Schema.DisplayType type = GlobalVariables.FieldTypeMap.get(thisFieldName);
                            if(type == Schema.DisplayType.Boolean)
                            {
                                Boolean criteriaValue = criteria.Value__c == null || criteria.Value__c.toLowerCase() == 'false' ? false : true;
                                Boolean fieldValue = Boolean.valueOf(thisLead.get(thisFieldName));
                                if(criteria.Operator__c.toLowerCase() == 'equals' && fieldValue != criteriaValue)
                                {
                                    isPassTheFieldCriteria = false;
                                }
                                else if(criteria.Operator__c.toLowerCase() == 'not equal to' && fieldValue == criteriaValue)
                                {
                                    isPassTheFieldCriteria = false;
                                }
                            }
                            else if(type == Schema.DisplayType.Currency || type == Schema.DisplayType.Integer || type == Schema.DisplayType.Percent || type == Schema.DisplayType.Double)
                            {
                                try
                                {
                                    Decimal criteriaValue = criteria.Value__c == null ? null : Decimal.valueOf(criteria.Value__c);
                                    Decimal fieldValue = thisLead.get(thisFieldName) == null ? null : Decimal.valueOf(Double.valueOf(thisLead.get(thisFieldName)));
                                    if(criteria.Operator__c.toLowerCase() == 'equals' && fieldValue != criteriaValue)
                                    {
                                        isPassTheFieldCriteria = false;
                                    }
                                    else if(criteria.Operator__c.toLowerCase() == 'not equal to' && fieldValue == criteriaValue)
                                    {
                                        isPassTheFieldCriteria = false;
                                    }
                                    else
                                    {} 
                                }
                                catch(Exception ex)
                                {
                                    isPassTheFieldCriteria = false;
                                }
                            }
                            else if(type == Schema.DisplayType.DateTime)
                            {
                                 DateTime criteriaValue = null;
                                if(criteria.Value__c != null)
                                {
                                    String[] dates = criteria.Value__c.split('/');
                                    criteriaValue = DateTime.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
                                }
                                DateTime fieldValue = thisLead.get(thisFieldName) == null ? null : DateTime.valueOf(thisLead.get(thisFieldName));
                                if(criteria.Operator__c.toLowerCase() == 'equals' && fieldValue != criteriaValue)
                                {
                                    isPassTheFieldCriteria = false;
                                }
                                else if(criteria.Operator__c.toLowerCase() == 'not equal to' && fieldValue == criteriaValue)
                                {
                                    isPassTheFieldCriteria = false;
                                }                                
                                else
                                {} 
                            }
                            else if(type == Schema.DisplayType.Date)
                            {
                                Date criteriaValue = null;
                                if(criteria.Value__c != null)
                                {
                                    String[] dates = criteria.Value__c.split('/');
                                    criteriaValue = Date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[0]), Integer.valueOf(dates[1]));
                                }
                                Date fieldValue = thisLead.get(thisFieldName) == null ? null : Date.valueOf(thisLead.get(thisFieldName));
                                if(criteria.Operator__c.toLowerCase() == 'equals' && fieldValue != criteriaValue)
                                {
                                    isPassTheFieldCriteria = false;
                                }
                                else if(criteria.Operator__c.toLowerCase() == 'not equal to' && fieldValue == criteriaValue)
                                {
                                    isPassTheFieldCriteria = false;
                                }
                                else
                                {
                                }
                            }
                            else
                            {
                                String criteriaValue = criteria.Value__c == null ? '' : criteria.Value__c.trim().toLowerCase();
                                String fieldValue = thisLead.get(thisFieldName) == null ? '' : String.valueOf(thisLead.get(thisFieldName)).trim().toLowerCase();
                                Set<String> values = new Set<String>();
                                
                                for(String value : criteriaValue.split(','))
                                {
                                    //if(value.trim().toLowerCase() != '')
                                    //{
                                        values.add(value.trim().toLowerCase());
                                    //}  
                                }
                                system.debug('###1' + fieldValue);
                                system.debug('###2' + values);
                                if(criteria.Operator__c.toLowerCase() == 'equals' && !values.contains(fieldValue))
                                {
                                    isPassTheFieldCriteria = false;
                                }
                                else if(criteria.Operator__c.toLowerCase() == 'not equal to' && values.contains(fieldValue))
                                {
                                    isPassTheFieldCriteria = false;
                                }
                                else
                                {
                                }
                            }
                            if(!isPassTheFieldCriteria)
                            {
                                break;
                            }
                        }
                        isMatchTerField = isPassTheFieldCriteria;
                    }
                }
                if(isMatchTerField && isFindTerritory )
                {
                    thisLead.Territory__c = leadTerritory.Id;
                    //Assigned_To__c, Assigned_To_Type__c
                    thisLead.Lead_Territory__c = leadTerritory.Id;
                    Id leadNewOwnerId = leadTerritory.Assigned_To_ID__c;                   
                    thisLead.OwnerId = leadNewOwnerId;
                    update thisLead;
                    break;
                }
            }            
        }
    }
    
     global void finish(Database.BatchableContext bc)
    {

    }
    
    private Boolean isInPostalRange(String postalCode, String postalStart, String postalEnd)
    {
        if(postalStart == null && postalEnd == null)
        {
            return true;
        }
        // When PostalCode is NULL, and PostalStart or PostalEnd is NOT NULL.
        if(postalCode == null)
        {
            return false;
        }            
        
        if(postalStart != null && postalEnd != null)
        {
            return (postalCode.compareTo(postalStart) >= 0 && postalCode.compareTo(postalEnd) <= 0); 
        }
        return false;        
    }
}