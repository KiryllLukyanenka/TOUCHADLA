@isTest
public class InferSmartSignalsRecordTriggerTest{
    
    @isTest static void testInferSmartSignalsRecordTrigger(){
        Infer_signals__Infer_Smart_Signals_Record__c infer = new Infer_signals__Infer_Smart_Signals_Record__c();
        infer.infer_signals__Field_32__c = 'test';
        insert infer;
    }
}