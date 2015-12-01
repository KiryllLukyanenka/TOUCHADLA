trigger OpportunityAutoRenew_AfterUpdate on Opportunity (after update) {
   List<String> BookedOppIds = new List<String>();
   
   for (Opportunity o : Trigger.new) {
      if (o.Booked_Date__c != NULL && o.Booked_Email_Sent__c == FALSE) { BookedOppIds.add(o.Id); }
   }   // end main for loop
   
   if (BookedOppIds.size() > 0) {
      Boolean success = false;
      try { OpportunityAutoRenew.CloneOpps(BookedOppIds); }
      catch (Exception e) {
         System.debug('+++ Opportunity clone failed');
         System.debug(e);
      }  // end try/catch block
   }     // end if
}