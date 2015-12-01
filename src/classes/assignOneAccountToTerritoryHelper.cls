public class assignOneAccountToTerritoryHelper
{
    public static void assignTerritory(String accountQuery)
    {
        List<Account> accts = (List<Account>)database.query(accountQuery);
        system.debug('###' + accts);
        Id accountTerritoryRecordTypeId = [select Id from RecordType where SobjectType = 'Territory_AppD__c' and Name = 'Account' limit 1].Id;
        //List<Territory_AppD__c> allAccountTerritories = c];
        Account thisAcct = accts[0];
        for(Territory_AppD__c acctTerritory : [select Id, Name, Type__c,  Assigned_To__c, Assigned_To_ID__c, Assigned_To_Type__c, Order__c, 
            (select Territory__c, Country__c, State__c, Zip_End__c, Zip_Start__c from Territory_Geographies__r order by Country__c, State__c),
            (select Territory__c, Field__c, Operator__c, Value__c from Territory_Field_Criteria__r order by Field__c )
            from Territory_AppD__c where RecordTypeId = :accountTerritoryRecordTypeId and Active__c = true and Effective_Date__c <= :Date.today() order by Order__c])
        {
            if( acctTerritory.Territory_Geographies__r.size() > 0 || acctTerritory.Territory_Field_Criteria__r.size() > 0 )
            {
                Boolean isMatchTerField = false;
                Boolean isFindTerritory = false;
                if(acctTerritory.Territory_Geographies__r.size() == 0)
                {
                    isFindTerritory = true;
                }
                else
                {
                    String country = thisAcct.BillingCountry != null ? thisAcct.BillingCountry.toLowerCase() : '';
                    String state = thisAcct.BillingState != null ? thisAcct.BillingState.toLowerCase() : '';
                    String postalCode = thisAcct.BillingPostalCode != null ? thisAcct.BillingPostalCode.toLowerCase() : '';
                    String countryState = country + '/' + state;
                    String justCountry = country + '/';
                    map<String, List<Territory_Geography__c>> countryStateToGeosMap = new map<String, List<Territory_Geography__c>>();
                    Boolean justCountryGeo = false;
                    for(Territory_Geography__c acctgeo : acctTerritory.Territory_Geographies__r)
                    {
                        String theCountryState = (acctgeo.Country__c != null ? acctgeo.Country__c.toLowerCase() : '') + '/' + (acctgeo.State__c != null?acctgeo.State__c.toLowerCase():'');
                        if(countryStateToGeosMap.containsKey(theCountryState))
                        {
                            countryStateToGeosMap.get(theCountryState).add(acctgeo);
                        }
                        else
                        {
                            countryStateToGeosMap.put(theCountryState, new List<Territory_Geography__c> {acctgeo});
                        }
                    }
                    system.debug('###' + countryStateToGeosMap);
                    system.debug('###' + countryState);
                    system.debug('###' + justCountry);
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
                            if(isInPostalRange(thisAcct.BillingPostalCode, theCountryStateGeo.Zip_Start__c, theCountryStateGeo.Zip_End__c))
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
                    if(acctTerritory.Territory_Field_Criteria__r.size() == 0)
                    {
                        isMatchTerField = true;
                    }
                    else
                    {
                        Boolean isPassTheFieldCriteria = true;
                        for(Territory_Field_Criteria__c criteria: acctTerritory.Territory_Field_Criteria__r)
                        {
                            String thisFieldName = criteria.Field__c; 
                            //STring thisFieldValue = thisLead.get(thisFieldName);
                            Schema.DisplayType type = GlobalVariables.AccountFieldTypeMap.get(thisFieldName);
                            if(type == Schema.DisplayType.Boolean)
                            {
                                Boolean criteriaValue = criteria.Value__c == null || criteria.Value__c.toLowerCase() == 'false' ? false : true;
                                Boolean fieldValue = Boolean.valueOf(thisAcct.get(thisFieldName));
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
                                    Decimal fieldValue = thisAcct.get(thisFieldName) == null ? null : Decimal.valueOf(Double.valueOf(thisAcct.get(thisFieldName)));
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
                                DateTime fieldValue = thisAcct.get(thisFieldName) == null ? null : DateTime.valueOf(thisAcct.get(thisFieldName));
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
                                Date fieldValue = thisAcct.get(thisFieldName) == null ? null : Date.valueOf(thisAcct.get(thisFieldName));
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
                                String fieldValue = thisAcct.get(thisFieldName) == null ? '' : String.valueOf(thisAcct.get(thisFieldName)).trim().toLowerCase();
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
                            }
                            system.debug('###' + isPassTheFieldCriteria);
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
                    thisAcct.Territory_AppD__c = acctTerritory.Id;
                    Id acctNewOwnerId = acctTerritory.Assigned_To_ID__c;                   
                    thisAcct.OwnerId = acctNewOwnerId;
                    update thisAcct;
                    for(Contact ct : thisAcct.Contacts)
                    {
                        ct.OwnerId = acctNewOwnerId;
                    }
                    update thisAcct.Contacts;
                    break;
                }
            }            
        }
    }
    
    private static Boolean isInPostalRange(String postalCode, String postalStart, String postalEnd)
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