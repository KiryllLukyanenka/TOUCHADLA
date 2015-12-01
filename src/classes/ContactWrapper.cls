public with sharing class ContactWrapper implements Comparable{
    public Contact contactObj{get;set;}
    public transient LicenseDetail__c licenseObj{get;set;}
    public transient DBTuna_License__c dblicenseObj{get;set;}
    public Account accountObj;
    public Opportunity opportunityObj;
    public Boolean selected{get;set;}
    private Boolean isPrimary;
    
    public Boolean getIsPrimary(){
        if(licContact!=null){
            return 'PRIMARY'.equals(licContact.Contact_Type__c);
        }
        if(dbLicContact!=null){
            return 'PRIMARY'.equals(dbLicContact.Contact_Type__c);
        }
        return isPrimary;
    }
    public void setIsPrimary(Boolean isPrimary){
        this.isPrimary = isPrimary;
    }
    public Boolean isSelfService{get;set;}
    public License_Contacts__c licContact{get;set;}
    public DBLicense_Contacts__c dbLicContact{get;set;}
    public ADUAUI aduaUIObj {get;set;}
    
    public ContactWrapper(){
    }
    
    public ContactWrapper(License_Contacts__c licCt,Contact ct,LicenseDetail__c lic){
        this.contactObj = ct;
        this.licenseObj=lic;
        this.licContact = licCt;
    }
    
    public ContactWrapper(Contact contactObj,LicenseDetail__c lic,Boolean selected){
        this.contactObj = contactObj;
        this.licenseObj=lic;
        this.selected=selected;
    }
    
    public ContactWrapper(Contact contactObj,DBTuna_License__c lic,Boolean selected){
        this.contactObj = contactObj;
        this.dblicenseObj=lic;
        this.selected=selected;
    }
    
     public ContactWrapper(Contact contactObj,DBTuna_License__c lic, DBLicense_Contacts__c dbLicContact){
        this.contactObj = contactObj;
        this.dblicenseObj=lic;
        this.dbLicContact = dbLicContact;
    }
    
    public ContactWrapper(Contact contactObj,DBTuna_License__c lic){
        this.contactObj = contactObj;
        this.dblicenseObj=lic;
        this.dbLicContact = dbLicContact;
    }

	public Integer compareTo(Object compareTo) {
        ContactWrapper ctWrapper = (ContactWrapper) compareTo;
        if('PRIMARY'.equals(licContact.Contact_Type__c)){
            return 1;
        }else if('PRIMARY'.equals(ctWrapper.licContact.Contact_Type__c)){
            return -1;
        }
        return 0;
    }
}