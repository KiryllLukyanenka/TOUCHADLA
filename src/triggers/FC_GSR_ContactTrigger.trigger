trigger FC_GSR_ContactTrigger on Contact (after update) {
	FC_GSR_ScoreReevaluator.requestHandler(trigger.newMap, trigger.oldMap);
}