/*
 * Input class to hold data for Portal Lead convertion flows
 *
 */
public class PortalLeadToLicenseManagerInput{
	public String leadId{get;set;}
    public String leadSource{get;set;}
    public String email{get;set;}
	public Boolean converted{get;set;}
	public String convertedAccountId {get;set;}
    public String convertedContactId {get;set;}
    public String convertedOpportunityId {get;set;}
    public String systemName {get;set;}
    public Boolean selfServiceBuy{get;set;}
    public String accountName{get;set;}
    public String leadOwnerId{get;set;}
    public String status{get;set;}
    public PortalDataType.License[] licenses{get;set;}
    public String licenseId {get;set;}
    
    public static map<String,String> systemNameFromLeadSourceMap = new map<String,String>{'MICROSOFT WINDOWS AZURE STORE'=>'MICROSOFT WINDOWS AZURE STORE',
																		'Website'=>'Sales-Led'};
	
	
	public static PortalLeadToLicenseManagerInput newInstance(String leadId,String leadSource){
		PortalLeadToLicenseManagerInput input = new PortalLeadToLicenseManagerInput();
		input.leadId = leadId;
		input.leadSource = leadSource;
		input.converted = false;
		input.systemName = systemNameFromLeadSourceMap.get(leadSource);
		input.accountName = input.systemName;
	    return input;
	}
	    
	public static PortalLeadToLicenseManagerInput newInstance(String convertedCtId,String accId,String oppId,String leadSource){
		PortalLeadToLicenseManagerInput input = new PortalLeadToLicenseManagerInput();
		input.convertedContactId= convertedCtId;
		input.convertedAccountId= accId;
        input.convertedOpportunityId=oppId;
		input.converted=true;
		input.leadSource = leadSource;
		input.systemName = leadSource;
		input.accountName = leadSource;
		return input;
	}
	
	public static PortalLeadToLicenseManagerInput newInstance(String leadId, 
	String email,String leadSource, Boolean selfServiceBuy, Boolean converted, String convertedCtId, String convertedAccountId, String convertedOpportunityId){
		PortalLeadToLicenseManagerInput input = new PortalLeadToLicenseManagerInput();
		input.leadId= leadId;
		input.leadSource = leadSource;
		input.email = email;
		input.selfServiceBuy=selfServiceBuy;
		if(selfServiceBuy){
			input.accountName='SS_Buy_'+email;
		}
		input.converted=converted;
		input.convertedContactId = convertedCtId;
		input.convertedAccountId = convertedAccountId;
		input.convertedOpportunityId = convertedOpportunityId;
		return input;
	}
	
	public static PortalLeadToLicenseManagerInput newInstance(String leadId, 
	String email,String leadSource, Boolean selfServiceBuy, Boolean converted, String convertedCtId, String convertedAccountId, String convertedOpportunityId, PortalDataType.License[] licenses){
		PortalLeadToLicenseManagerInput input = new PortalLeadToLicenseManagerInput();
		input.leadId= leadId;
		input.leadSource = leadSource;
		input.email = email;
		input.selfServiceBuy=selfServiceBuy;
		if(selfServiceBuy){
			input.accountName='SS_Buy_'+email;
		}
		input.converted=converted;
		input.convertedContactId = convertedCtId;
		input.convertedAccountId = convertedAccountId;
		input.convertedOpportunityId = convertedOpportunityId;
		input.licenses = licenses; 
		return input;
	}
	
	public static testMethod void testPortalLeadToLicenseManagerInput(){
		PortalLeadToLicenseManagerInput plmi1 = PortalLeadToLicenseManagerInput.newInstance('123wsd','MICROSOFT WINDOWS AZURE STORE');
		PortalLeadToLicenseManagerInput plmi2 = PortalLeadToLicenseManagerInput.newInstance('123wsd','123wsd','123wsd','Website');
	}
}