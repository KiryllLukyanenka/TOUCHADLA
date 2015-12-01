trigger FC_ResponseReanimatorTrigger on CampaignMember (after insert) {
	FC_ResponseReanimator.requestHandler(trigger.newMap);
}