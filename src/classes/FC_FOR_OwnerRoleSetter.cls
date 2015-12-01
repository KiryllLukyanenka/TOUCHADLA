public with sharing class FC_FOR_OwnerRoleSetter {

	public static void requestHandler(Map<Id, CampaignMember> newMap, Map<Id, CampaignMember> oldMap, Boolean isInsert)
	{
		system.debug('isInsert: ' + isInsert);
		if (newMap == null) return;
			
		Set<Id> ownerUserIds = new Set<Id>();		
        for (CampaignMember cm : newMap.values())
        {      
        	if (cm.FCRM__FCR_First_Owner_Assigned__c != null) ownerUserIds.add(cm.FCRM__FCR_First_Owner_Assigned__c); 
        	if (cm.FCRM__FCR_First_Owner_Worked__c != null) ownerUserIds.add(cm.FCRM__FCR_First_Owner_Worked__c);
        	if (cm.FCRM__FCR_SAR_Owner__c != null) ownerUserIds.add(cm.FCRM__FCR_SAR_Owner__c);
        }
        
        if (ownerUserIds.size() == 0) return;
		
		Map<Id, UserRole> userRolesById = new Map<Id, UserRole>([Select Id, Name From UserRole]);
		List<User> owners = [Select Id, UserRoleId From User Where Id IN :ownerUserIds];	
		Map<Id, Id> userRoleIdByUserId = new Map<Id, Id>();
		for (User u : owners) if (userRolesById.get(u.UserRoleId) != null) userRoleIdByUserId.put(u.Id, userRolesById.get(u.UserRoleId).Id);
		
		if (userRolesById.size() == 0) return;
		
		Map<Id, String> userRoleNameByUserId = new Map<Id, String>();
		for (User u : owners) if (userRoleIdByUserId.get(u.Id) != null && userRolesById.get(userRoleIdByUserId.get(u.Id)) != null) userRoleNameByUserId.put(u.Id, userRolesById.get(userRoleIdByUserId.get(u.Id)).Name);
		
		if (userRoleNameByUserId.size() == 0) return;
		
		List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        for (CampaignMember cm : newMap.values())
        {               
        	// Current values
            Id foAssignedCV = cm.FCRM__FCR_First_Owner_Assigned__c;
            Id foWorkedCV = cm.FCRM__FCR_First_Owner_Worked__c;
            Id saroCV = cm.FCRM__FCR_SAR_Owner__c;
            system.debug('Current Values: foAssignedCV - ' + foAssignedCV + ' foWorkedCV - ' + foWorkedCV + ' saroCV - ' + saroCV );
            
            if (isInsert)
            {
            	if (foAssignedCV != null) cm.CFCR_First_Owner_Assigned_Role__c = userRoleNameByUserId.get(foAssignedCV); 
            	if (foWorkedCV != null) cm.CFCR_First_Owner_Worked_Role__c = userRoleNameByUserId.get(foWorkedCV);
            	if (saroCV != null) cm.CFCR_SAL_Owner_Role__c = userRoleNameByUserId.get(saroCV);                	 
            }
            else
            {
            	CampaignMember oldCm = oldMap.get(cm.Id);
            	// Old values
                Id foAssignedOV = oldCm.FCRM__FCR_First_Owner_Assigned__c;
                Id foWorkedOV = oldCm.FCRM__FCR_First_Owner_Worked__c;
                Id saroOV = oldCm.FCRM__FCR_SAR_Owner__c;
                system.debug('Old Values: foAssignedOV - ' + foAssignedOV + ' foWorkedOV - ' + foWorkedOV + ' saroOV - ' + saroOV );  
                
            	if (foAssignedCV != null && foAssignedCV != foAssignedOV) cm.CFCR_First_Owner_Assigned_Role__c = userRoleNameByUserId.get(foAssignedCV);
            	if (foWorkedCV != null && foWorkedCV != foWorkedOV) cm.CFCR_First_Owner_Worked_Role__c = userRoleNameByUserId.get(foWorkedCV);
            	if (saroCV != null && saroCV != saroOV) cm.CFCR_SAL_Owner_Role__c = userRoleNameByUserId.get(saroCV);                	
            }
        }             		
	}

}