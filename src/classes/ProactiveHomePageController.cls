public with sharing class ProactiveHomePageController {
    
    public ProactiveHomePageController(ApexPages.StandardController stdController){
        metric='ACCOUNT_STATS';
    }
    public String accountID {get;set;}
    public Account accountObj {get;set;}
    public String metric {get;set;}
    public String filterByColumnNames{get;set;}
    public String title{get;set;}
    
    public list<Contact> contacts {get;set;}
    public list<Opportunity> opportunities {get;set;}
    
    public String healthSummary{get;set;}
    public Integer healthScore{get;set;}
    
    public PortalGenericMapList ruleSummaryList {get;set;}
    
    private ProactiveStatsController summaryController;
    
    public virtual void initAction(){
        accountID = '';
        try{
            accountId = ApexPages.currentPage().getParameters().get('account_id');
            accountObj =  [Select ID, Name, Owner.Id, Owner.Name, Owner.Email, Technical_Account_Manager__r.Id, Technical_Account_Manager__r.Name, Technical_Account_Manager__r.Email from Account where ID=:accountId];
            accountId = accountObj.ID;
            if(ApexPages.currentPage().getParameters().get('metric')!=null){
                metric = ApexPages.currentPage().getParameters().get('metric');
            }
            if(metric=='ACCOUNT_STATS'){
                filterByColumnNames='Controller URL,Account Name,Application';
                title='Account Stats Report';
            }else if(metric=='LOGIN_STATS'){
                filterByColumnNames='Controller URL,Account';
                title='Login Report for all the controller accounts of customer in Last 30 Days';
            }
            readContacts();
            readOpportunities();
            readLicenses();
            
            summaryController = new ProactiveStatsController();
            summaryController.accountId = accountObj.Id;
            summaryController.metric = 'SUMMARY';
            summaryController.invokeProactive();
            healthSummary = summaryController.getHealthSummary();
            healthScore = summaryController.getHealthScore();
            
        }catch(Exception e){
            String errorMessage = 'Error while retrieving the account from the page url param: account_id\n';
            if(e!=null){
                errorMessage+=e.getMessage()+'\nStack:'+e.getStackTraceString();
            }
            showErrorMessage(errorMessage);
        }
    }
    
    public void readContacts(){
        try{
            contacts = [Select ID,Name,Email, (Select License__c from License_Contacts__r) from Contact where AccountID=:accountId];
        }catch(Exception e){
            String errorMessage = 'Error while retrieving the contacts for account:'+accountId;
            if(e!=null){
                errorMessage+=e.getMessage()+'\nStack:'+e.getStackTraceString();
            }
            showErrorMessage(errorMessage);
        }
    }
    
    private void readOpportunities(){
        try{
            opportunities = [SELECT ID, (SELECT Opportunity__c,Name,License__c FROM Licenses__r) FROM Opportunity where AccountID=:accountId];
        }catch(Exception e){
            String errorMessage = 'Error while retrieving the opportunities for account:'+accountId;
            if(e!=null){
                errorMessage+=e.getMessage()+'\nStack:'+e.getStackTraceString();
            }
            showErrorMessage(errorMessage);
        }
        
    }
    
    public list<LicenseDetail__c> licenses{get;set;}
    map<String,LicenseDetail__c> licenseIDValueMap;
    private void readLicenses(){
        set<String> licenseIds = new set<String>();
        for(Opportunity opp:opportunities){
            if(opp.Licenses__r!=null){
                for(License_Opportunity__c licOpp:opp.Licenses__r){
                    if(!licenseIds.contains(licOpp.License__c)){
                        licenseIds.add(licOpp.License__c);
                    }   
                }
            }
        }
        
        for(Contact ct:contacts){
            if(ct.License_Contacts__r!=null){
                for(License_Contacts__c licCt:ct.License_Contacts__r){
                    if(!licenseIds.contains(licCt.License__c)){
                        licenseIds.add(licCt.License__c);
                    }   
                }
            }
        }
        try{
            licenses = [Select ID,Stage__c, License_Expiry_Date__c, Product_Type__c,License_BackendID__c,Custom_URL_Name__c from LicenseDetail__c where Stage__c IN('TRIAL','PAID_TEMP','PAID_PERMANENT','DISABLED','PAID_TEMP_EXPIRED','PAID_PERMANENT_EXPIRED','TRIAL_EXPIRED') and id in:licenseIds];
        }catch(Exception e){
            String errorMessage = 'Error while retrieving the licenses for account:'+accountId;
            if(e!=null){
                errorMessage+=e.getMessage()+'\nStack:'+e.getStackTraceString();
            }
            showErrorMessage(errorMessage);
        }
        if(licenses!=null){
        	paidSAASLicenses = new list<LicenseDetail__c>();
        	for(LicenseDetail__c lic:licenses){
	        	if(AppDConstants.LICENSE_PRODUCT_TYPE_SAAS.equals(lic.Product_Type__c) && 'PAID_PERMANENT'.equals(lic.Stage__c)){
        			paidSAASLicenses.add(lic);
        		}
        	}
        }
    }
    
    public list<LicenseDetail__c> paidSAASLicenses{get;set;}
	 
    
    /*
     * Common Helper method to show Error message on the VisualForce Page
     */
    public void showErrorMessage(String message){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,message);
        ApexPages.addMessage(myMsg);
    }
}