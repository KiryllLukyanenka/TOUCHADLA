trigger Managername on Opportunity (after update) { 
    OpportunityUtil.sendEmailToOpportunityOwnersManager( trigger.oldMap, trigger.new );
}