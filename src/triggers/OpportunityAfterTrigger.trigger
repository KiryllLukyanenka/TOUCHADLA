trigger OpportunityAfterTrigger on Opportunity (after insert, after update) {
    // Added by eric@touchpointcrm.com on 2014-6-11
    
    // Create the map from the opportunity to their primary contact
    Map<String, String> primaryContactIds = new Map<String, String>();
    for(Opportunity oppt : Trigger.new){
        if(oppt.Primary_Contact__c != null && (Trigger.isInsert || Trigger.oldMap.get(oppt.Id).Primary_Contact__c == null)){
            primaryContactIds.put(oppt.Id, oppt.Primary_Contact__c);
        }
    }  
    
    // Creates the map from the contact to their user
    Map<String, String> users = new Map<String, String>();
    for(User user : [select Id, ContactId from User where ContactId in :primaryContactIds.values() and IsActive = true and IsPortalEnabled = true]){
        users.put(user.ContactId, user.Id);
    }
    
    // Finds the existing opportunity team members.
    Set<String> existingMemberIndexes = new Set<String>();
    for(OpportunityTeamMember item : [select OpportunityId, User.ContactId from OpportunityTeamMember 
        where OpportunityId in :primaryContactIds.keySet() and UserId in :users.values()]){
        existingMemberIndexes.add(item.OpportunityId + '' + item.User.ContactId);
    }
    
    List<OpportunityTeamMember> teamMembers = new List<OpportunityTeamMember>();
    for(String opptId : primaryContactIds.keySet()){
		String contactId = primaryContactIds.get(opptId);
		String userId = users.get(contactId);
        if(!existingMemberIndexes.contains(opptId + contactId) && userId != null){
        	teamMembers.add(new OpportunityTeamMember(UserId = userId, OpportunityId = opptId, TeamMemberRole = 'Partner'));
        }
    }
    
    if(teamMembers.size() > 0){
    	insert teamMembers;
    }
}