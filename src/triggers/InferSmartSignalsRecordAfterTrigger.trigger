trigger InferSmartSignalsRecordAfterTrigger on Infer_signals__Infer_Smart_Signals_Record__c (after insert, after update) {
    
    Set<String> inferIds = new Set<String>();
    
    for(Infer_signals__Infer_Smart_Signals_Record__c infer : Trigger.new){
        if(!String.isBlank(infer.infer_signals__Field_32__c)
            && (Trigger.isInsert || infer.infer_signals__Field_32__c != Trigger.oldMap.get(infer.Id).infer_signals__Field_32__c)){
            inferIds.add(infer.Id);
        }
    }
    
    if(inferIds.size() > 0){
        Lead[] leads = [select Id from Lead where infer_signals__Infer_Smart_Signals_Record__c in :inferIds];
        for(Lead lead : leads){
            lead.TriggerLeadAssignment__c = true;
        }
        update leads;
    }
}