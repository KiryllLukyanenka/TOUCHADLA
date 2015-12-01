trigger QuoteTrigger on Quote (after insert, after update) {
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      QuoteTriggerHandler.afterInsert(Trigger.new);
    } else if (Trigger.isUpdate) {
      QuoteTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
  }
}