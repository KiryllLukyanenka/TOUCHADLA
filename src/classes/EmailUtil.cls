public with sharing class EmailUtil {
    public static void sendDBTunaLicenseEmail(DBTuna_License__c license,Opportunity myOpportunity, Contact primaryContact, User salesRep, String additionalEmails){
        try{
            String templateName = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.DBTUNA_TEMPLATE_NAME);
            String[] bccAddress = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.DBTUNA_BCC).split(',');
            EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Name =:templateName];
            String subject = emailTemplate.Subject;
            subject = subject.replace('{account.name}',myOpportunity.Account.name);
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{Name}', primaryContact.Name);
            htmlBody = htmlBody.replace('{Expiry Date}', license.ExpiryDate__c+'');
            htmlBody = htmlBody.replace('{Expiry key}', license.LicenseKey__c);
            htmlBody = htmlBody.replace('{Server Name}', license.Server_Name__c);
              
            Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
            email.setToAddresses(New String[] {primaryContact.Email});
            email.setBccAddresses(bccAddress);
            email.setCcAddresses(additionalEmails.split(','));
            email.setSaveAsActivity(true);
            email.setSubject(subject);
            email.setHtmlBody(htmlBody);
            
            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
        
    }
    
    public static void sendLMSUserRegistrationEmail(String userId,String name,String emailId){
        String templateName = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.LMS_USER_REG_TEMPLATE_NAME);
        String[] toAddress = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.LMS_USER_REG_TO).split(',');
        String[] ccAddress = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.LMS_USER_CC).split(',');//new String[]{'portal-team@appdynamics.com','csouza@appdynamics.com','hshafique@appdynamics.com','apatel@appdynamics.com','mkataoka@appdynamics.com'};
        EmailTemplate template = [Select Id,Subject,HtmlValue,Name from EmailTemplate where Name=:templateName limit 1];
        String subject = template.Subject;
        String htmlBody = template.HtmlValue;
        htmlBody = htmlBody.replace('{!User.Username}', name);
        htmlBody = htmlBody.replace('{!User.Id}', userId);
        htmlBody = htmlBody.replace('{!User.Email}', emailId);
        
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setReplyTo('portal-team@appdynamics.com');
        email.setToAddresses(toaddress);
        email.setCcAddresses(ccAddress);
        email.setSaveAsActivity(true);
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});  
    }
   
    /*public static void notifyAccountOwner(String message,String emailString){
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setReplyTo(EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.APPDYNAMICS_NOTIFY_ADDRESS));//EnvironmentSettings.instance.APPDYNAMICS_NOTIFY_ADDRESS
        email.setToAddresses(emailString.split(','));
        email.setCcAddresses(new String[]{EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.APPDYNAMICS_NOTIFY_ADDRESS)});
        email.setSaveAsActivity(true);
        email.setSubject('Disable User');
        email.setHtmlBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
    }*/
    
    public static void notifyError(String errorMessage, String subject){
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        email.setReplyTo(EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.APPDYNAMICS_NOTIFY_ADDRESS));
        email.setToAddresses(new String[]{EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.APPDYNAMICS_NOTIFY_ADDRESS)});
        email.setSaveAsActivity(true);
        email.setSubject(EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.SALESFORCE_ERROR_MESSAGE_SUBJECT) +' - '+ subject);
        email.setHtmlBody(errorMessage);
        try{
        	Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
        }catch(Exception e){
        	System.debug(e);
        }
    }
    
    public static void notifyError(Exception ex, SObject obj){
    	String exceptionMessage = ex.getMessage();
    	
    	String subject = '';
    	if(exceptionMessage!=null && exceptionMessage.length()>150){
    		subject = exceptionMessage.substring(0, 150);
    	}else{
    		subject = exceptionMessage;
    	}
    	
    	String objName;
    	if(obj!=null){
    		objName = obj.getSObjectType().getDescribe().getName();
    	}
    	String errorMessage = '';
    	String pageUrl = URL.getCurrentRequestUrl().toExternalForm();
    	String queryString = URL.getCurrentRequestUrl().getQuery();
		errorMessage +='<br/><b>User details:</b><br/>';
		errorMessage +='User Id: '+UserInfo.getUserId()+'<br/>';
		errorMessage +='User Name: '+UserInfo.getUserName()+'<br/>';
		errorMessage += pageUrl!=null?'<br/><b>Page URL: </b>'+pageUrl+'<br/> <b>Query string:</b> '+queryString+' <br/>':'';
		errorMessage += objName!=null?'<b>Object Name:<b>'+objName+'<br/>':'';
		errorMessage +='<br/><b>Error message:</b>'+ex.getMessage()+'<br/>  '+'<br/><b>Error stack:</b><br/>'+ex.getStackTraceString();
		try{
        	EmailUtil.notifyError(errorMessage,subject);
		}catch(Exception e){
			System.debug(e);
		}
    }   
}