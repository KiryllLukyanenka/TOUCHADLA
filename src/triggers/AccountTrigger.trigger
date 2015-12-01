// Enhancement - 

trigger AccountTrigger on Account (after update) 
{
    AccountTriggerHandler handler = new AccountTriggerHandler();
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        handler.onAfterUpdate(trigger.oldMap,trigger.newMap);
    }
}