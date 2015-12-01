trigger FC_FOR_OwnerRoleSetterTrigger on CampaignMember (before insert, before update) {
	FC_FOR_OwnerRoleSetter.requestHandler(trigger.newMap, trigger.oldMap, trigger.isInsert);
}