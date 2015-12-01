trigger DBTunaLicenseTracking on DBTuna_License__c (before insert, before update) {
  List<DBTuna_License__c> dbTunaLicenseList = new List<DBTuna_License__c>();
  if (Trigger.isBefore) {
    if (Trigger.isInsert || Trigger.isUpdate) {
      for (DBTuna_License__c db : Trigger.new) {
        db.License_Data__c = 'Server Name:'+db.Server_Name__c+'; Expiry Date:'+db.ExpiryDate__c+'; License Key:'+db.LicenseKey__c;
      }
    }
  }
}