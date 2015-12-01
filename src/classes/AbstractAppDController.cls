/*
 * Base AppDController and gives default implementation for all lifecycle methods.
 */
public virtual class AbstractAppDController extends AppDController{
	public AbstractAppDController(){
		super();
	}
	
	/*
	 * Overriding constructor so that StandardController object is passed to base class
	 */
	public AbstractAppDController(ApexPages.standardController stdController){
		super(stdController);
	}
	
	public override virtual Boolean doPreSave(){
		/*
		 * Providing a dummy implementation to return true so that any child class which
		 * doesnot need any functionality here can skip overriding this. While the AppDController 
		 * workflow goes fine with assertion that doPreSave succesfully completed.
		 */
		return true;
	}
	
	public override virtual PageReference doPostSave(){
		/*
		 * Providing a dummy implementation to return true so that any child class which
		 * doesnot need any functionality here can skip overriding this. While the AppDController 
		 * workflow goes fine with assertion that doPostSave succesfully completed.
		 * Returning default value of null would result in page refreshing and staying at 
		 * same page without any redirections.
		 */
		return null;
	}
	
	public override virtual void setupBackend(){
		/*
		 * Providing a dummy implementation to return true so that any child class which
		 * doesnot need any functionality here can skip overriding this. While the AppDController 
		 * workflow goes fine with assertion that setupBackend succesfully completed.
		 */
	}
	
	public override virtual Boolean validateObject(){
		/*
		 * Providing a dummy implementation to return true so that any child class which
		 * doesnot need any functionality here can skip overriding this. While the AppDController 
		 * workflow goes fine with assertion that validateObject succesfully completed.
		 */
		return true;
	}
	
	public override virtual Boolean doPreDelete(){
		/*
		 * Providing a dummy implementation to return true so that any child class which
		 * doesnot need any functionality here can skip overriding this. While the AppDController 
		 * workflow goes fine with assertion that doPreDelete succesfully completed.
		 */
		return true;
	}
	
	public override virtual PageReference doPostDelete(){
		/*
		 * Providing a dummy implementation to return true so that any child class which
		 * doesnot need any functionality here can skip overriding this. While the AppDController 
		 * workflow goes fine with assertion that doPostDelete succesfully completed.
		 * Returning default value of null would result in page refreshing and staying at 
		 * same page without any redirections after delete operation is completed.
		 */
		return null;
	}
	
	public override virtual PageReference doCancel(){
		/*
		 * Providing a dummy implementation to return true so that any child class which
		 * doesnot need any functionality here can skip overriding this. While the AppDController 
		 * workflow goes fine with assertion that doCancel succesfully completed.
		 * Returning default value of null would result in page refreshing and staying at 
		 * same page without any redirections after cancel operation is completed.
		 */
		return null;
	}
	
	/**
	 * Test Case method for the abstract controller methods. 
	 * Providing mock test methods to ensure the coverage of the abstract class methods. 
	 * No funcational testing is done here.
	 */
	public static testMethod void testInvocation(){
		AbstractAppDController appD = new AbstractAppDController();
		appD.validateObject();
		appD.setupBackend();
		appD.doPreSave();
		appD.doPostSave();
		appD.doPreDelete();
		appD.doPostDelete();
		appD.doCancel();
	} 
}