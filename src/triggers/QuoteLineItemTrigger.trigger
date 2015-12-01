trigger QuoteLineItemTrigger on QuoteLineItem (after insert, after update,
    after delete) {
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      QuoteLineItemTriggerHandler.afterInsert(Trigger.new);
    } else if (Trigger.isUpdate) {
      QuoteLineItemTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isDelete) {
      QuoteLineItemTriggerHandler.afterDelete(Trigger.old);
    }
  }
}