public virtual class DBTunaBackend extends Backend{
	public DBTuna_License__c license{get;set;}
	
	public DBTunaBackend(DBTuna_License__c license){
		super(license,BackendConstants.OPCODE_DBTUNA_PROVISION);
        this.license=license;
        this.opCode = BackendConstants.OPCODE_DBTUNA_PROVISION;
        
        setupInputParameters();
	}
	
	public virtual override void setupInputParameters(){
		setParameters(new List<BackendLayer.BackendParameter>());
		BackendLayer.BackendParameter param = null;
        String expiryDate = String.valueOf(license.ExpiryDate__c);
        String serverName = license.Server_Name__c;
        
        param = new BackendLayer.BackendParameter('expiry_date',expiryDate);
        getParameters().add(param);
        param = new BackendLayer.BackendParameter('environment',serverName);
        getParameters().add(param);
	}
	
}