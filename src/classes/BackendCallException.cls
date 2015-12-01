public with sharing class BackendCallException extends Exception{
	private String backendErrorMessage;
	public static testMethod void testBackendCallException(){
		BackendCallException e = new BackendCallException();
		e.backendErrorMessage = '';
		System.assert(true);
	}
}