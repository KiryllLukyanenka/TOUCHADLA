/*
    Purpose      : Utility Class used in Opportunity Trigger managerName
    Author       : Rashmi K
    Created Date : June 14 2013
*/
public with sharing Class OpportunityUtil{

    public static void sendEmailToOpportunityOwnersManager( Map<Id, Opportunity> oldOppsMap, List<Opportunity> newOpps ){
        Map<Id, List<Opportunity>> ownerIdToOpportunities = new Map<Id, List<Opportunity>> ();
        for( Opportunity opp : newOpps ){
            Opportunity oldOpp = oldOppsMap.get( opp.Id );
            if( ( opp.StageName != oldOpp.StageName && opp.StageName=='W10 - Closed/Won' ) 
                && opp.Amount_USD__c >= 100000 ){
                if( ownerIdToOpportunities.containsKey( opp.ownerId ) ) {
                    ownerIdToOpportunities.get( opp.ownerId ).add( opp) ;
                } else{
                    ownerIdToOpportunities.put( opp.ownerId, new List<Opportunity> { opp } );
                }
            }
        }
        if( !ownerIdToOpportunities.isEmpty() ){
            List<User> owners = [SELECT Id, managerid, manager.Name, manager.Email FROM User WHERE ID IN :ownerIdToOpportunities.keySet() ];
            if( owners!= null && !owners.isEmpty() ){
                // sendEmails( owners, ownerIdToOpportunities );
            }
        }
    }
    
    public static void sendEmails( List<User> owners, Map<Id, List<Opportunity>> ownerIdToOpportunities ){
        EmailTemplate emailTemp = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Manager_Email_Alert_for_100K_Opportunity'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Contact c = [select id, Email from Contact where email <> null limit 1]; 
        for( User o : owners ){
            for( Opportunity opp : ownerIdToOpportunities.get( o.Id ) ){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId( c.Id );
                mail.setTemplateId( emailTemp.id );
                mail.setWhatId( opp.Id );
                mail.setSaveAsActivity( false );
                mail.setToAddresses( new String[]{ o.manager.Email } );
                emails.add( mail );
            }
        }
        if( !emails.isEmpty() ){
            Savepoint sp = Database.setSavepoint();  
                Messaging.sendEmail( emails );
            Database.rollback(sp);
            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its 21
            // contents to a new SingleEmailMessage. Then send those new messages. 
            List <Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
            for ( Messaging.SingleEmailMessage email : emails ) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(email.getToAddresses()); 
                emailToSend.setPlainTextBody(email.getPlainTextBody()); 
                emailToSend.setHTMLBody(email.getHTMLBody()); 
                emailToSend.setSubject(email.getSubject()); 
                lstMsgsToSend.add(emailToSend); 
            } 
            Messaging.sendEmail(lstMsgsToSend); 
        }

    } 
}