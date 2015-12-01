public with sharing class PortalLock {
	
	public static boolean acquireLock(){
		String currentLock = activeCurrentLock();
		if(currentLock==null){
			newLock();
			return true;
		}
		return false;
	}
	
	
	public static boolean acquireLockAsync(){
		String currentLock = activeCurrentLock();
		if(currentLock==null){
			storeNewLock();
			return true;
		}
		return false;
	}
	
	@future(callout=true)
	private static void storeNewLock(){
		newLock();
	}
	
	private static String newLock(){
		String timestamp = Datetime.now().getTime()+'';
		EnvironmentSettings.instance.setPropertyValue(EnvironmentSettings.SYNC_KEY, timestamp);
		return timestamp;
	}
	
	public static String activeCurrentLock(){
		String runningKey = EnvironmentSettings.instance.getPropertyValue(EnvironmentSettings.SYNC_KEY);
		return runningKey;
	}
	
	public static void releaseLock(){
		EnvironmentSettings.instance.setPropertyValue(EnvironmentSettings.SYNC_KEY, '');
	}
}