trigger FC_GSR_LeadTrigger on Lead (after update) {
	FC_GSR_ScoreReevaluator.requestHandler(trigger.newMap, trigger.oldMap);
}