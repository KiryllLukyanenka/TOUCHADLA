public with sharing class ZoneSetupPageController {
	public ZoneSetupPageController(ApexPages.StandardController stdController){
		
	}
	
	public PageReference createZones(){
		List<Zone__c> zones = Database.query('SELECT ID FROM ZONE__c');
		if(zones!=null && zones.size()>0){
			delete zones;
		} 
		CommonUtil.addZones();
		return null;
	}
	
	public static void zoneSetupTest(){
		ZoneSetupPageController controller = new ZoneSetupPageController(new ApexPages.Standardcontroller(new Zone__c()));
		controller.createZones();
	}
}