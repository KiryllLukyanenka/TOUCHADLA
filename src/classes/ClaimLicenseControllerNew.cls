public with sharing class ClaimLicenseControllerNew extends AbstractAppDController {
    public Integer currentView{get;set;}
    public static final Integer SELECT_CONTACTS = 0;  
    public static final Integer GET_LICENSES = 1;  
    
    public List<ContactWrapper> contactsList{get;set;}
    private MAP<String,Contact> emailCtMAP = new MAP<String,Contact>();
    public Opportunity opportunityObj{get;set;}
    public PortalLicenseSynch portalLicSynch{get;set;}
    public PortalDataType.User_License[] userLicenses{get;set;}
    public List<LicenseWrapper> licenseWrappers{get;set;}
    

    public ClaimLicenseControllerNew(ApexPages.StandardController stdController){
        super(stdController);
    }

    public virtual override void init(){
        super.init();
        opportunityObj = (Opportunity) stdController.getRecord();
        
		getContacts();
    }
    
    public PageReference getContacts() {
        opportunityObj = (Opportunity) DataLayerConstants.fetchSingle('Opportunity',opportunityObj.Id);
        List<Contact> accContacts = CommonUtil.getAccountContactsToAddToBackend(opportunityObj);
        contactsList = new List<ContactWrapper>();
        for(Contact accContact:accContacts){
            ContactWrapper ctWrapper = new ContactWrapper();
            ctWrapper.contactObj=accContact;
            ctWrapper.selected=true;
            contactsList.add(ctWrapper);
            emailCtMAP.put(accContact.Email,accContact);
            currentView = ClaimLicenseControllerNew.SELECT_CONTACTS;
        }
    	
    	return null;
    }
    
    
    public PageReference getLicenses() {
    	portalLicSynch = new PortalLicenseSynch();
    	List<String> emails = new List<String>();
    	for(ContactWrapper con : contactsList) {
    		if(con.selected) {
	    		emails.add(con.contactObj.Email);
    		}
    		
    	}
    	
    	portalLicSynch.emailIds = emails;
    	System.debug('emails claim lic : ' + emails);
    	portalLicSynch.accountIdForLeadConvert = opportunityObj.AccountId;
    	portalLicSynch.action = PortalLicenseSynch.ACTION_PULL;
    	portalLicSynch.synch();
    	
    	userLicenses = portalLicSynch.userLicenses;
    	convertToLicenseWrapper(userLicenses);
    	
        currentView = ClaimLicenseControllerNew.GET_LICENSES;
    	
    	return null;
    }	
    
    
    public PageReference claimLicense() {
 		Map<String, PortalDataType.User_License> licMap = new Map<String, PortalDataType.User_License>();
 		PortalDataType.User_License[] licenses = new List<PortalDataType.User_License>();
 		System.debug('licenseWrappers size : ' + licenseWrappers.size());
 		for(LicenseWrapper licWrapper : licenseWrappers) {
 			if(licWrapper.selected) {
 				PortalDataType.User_License licForEmail = licMap.get(licWrapper.contactEmail);
 				System.debug('licWrapper.contactEmail : ' + licWrapper.contactEmail); 
 				if(licForEmail == null) {
 					licForEmail = new PortalDataType.User_License();
 					licMap.put(licWrapper.contactEmail, licForEmail);
 					licForEmail.email = licWrapper.contactEmail;
 					PortalDataType.License[] listOfLicForEmail = new List<PortalDataType.License>();
 					licForEmail.licenses = listOfLicForEmail;
 					licenses.add(licForEmail);
 				}
 				licForEmail.licenses.add(licWrapper.licenseObj);
 			}
 		}
 		
 		try {
	 		portalLicSynch.userLicenses = licenses; 
	    	portalLicSynch.action = PortalLicenseSynch.ACTION_STORE_LICENSES;
	    	portalLicSynch.opportunityId = opportunityObj.Id;
	    	portalLicSynch.synch();
 		}
    	catch(Exception e) {
    		System.debug('Claim lic Stacktrace : ' + e.getStackTraceString());
    		System.debug('Claim lic Message : ' + e.getMessage());
    	}
    	finally {
        	System.debug('claim After sync ...');
			PortalLock.releaseLock();
    	}
 		
    	PageReference page = new PAgeReference('/'+opportunityObj.Id);
    	
    	return page;
    }
    
    public class LicenseWrapper{
        public PortalDataType.License licenseObj{get;set;}
        public String contactEmail{get;set;}
        public Boolean selected{get;set;}
    }
    
    
    private void convertToLicenseWrapper(PortalDataType.User_License[] userLicenses) {
    	licenseWrappers = new List<LicenseWrapper>(); 
    	
    	for(PortalDataType.User_License userLic : userLicenses) {
    		System.debug('userLic email : ' + userLic.email);
    		for(PortalDataType.License lic : userLic.licenses) {
    			System.debug('lic details : ' + lic);
    			LicenseWrapper licWrapper = new LicenseWrapper();
    			licWrapper.licenseObj = lic; 
    			licWrapper.contactEmail = getPrimaryContact(lic);
    			licWrapper.selected = true;
    			licenseWrappers.add(licWrapper);
    		}
    	}
    }

    public virtual override PageReference doCancel(){
        PageReference page = new PAgeReference('/'+opportunityObj.Id);
        return page;
    }
    
   	private String getPrimaryContact(PortalDataType.License lic) {
    	for(PortalDataType.PortalContact contact : lic.contacts) {
    		if(contact.user_type == 'PRIMARY') {
    			return contact.email;
    		}
    	}
    	
    	return '';
    }
}