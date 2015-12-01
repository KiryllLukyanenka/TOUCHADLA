/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest (SeeAllData=true)
private class PremiumAdoptionSummaryTests {

    public static testmethod void testPremiumCustomersSummaryCurrentYearAll(){
		PremiumCustomersSummaryController ctl = new PremiumCustomersSummaryController();
		ctl.setCurrentYear(true);
		ctl.setDuration(PremiumCustomersSummaryController.ALL);
		ctl.setRefreshData(true);
		ctl.getRefreshData();
		ctl.getCurrentYear();
		ctl.getDuration();
		ctl.getAdoptionLevelsSupported();
		ctl.getSupportLevelAdoptionLevelCountMap();
		ctl.getPremiumLevelsSupported();
		ctl.getAdoptionChartData();
	}
	
	public static testmethod void testPremiumCustomersSummaryCurrentYearLast3(){
		PremiumCustomersSummaryController ctl = new PremiumCustomersSummaryController();
		ctl.setCurrentYear(true);
		ctl.setDuration(PremiumCustomersSummaryController.LAST3);
		ctl.setRefreshData(true);
	}
	
	public static testmethod void testPremiumCustomersSummaryCurrentYearBeforeLast3(){
		PremiumCustomersSummaryController ctl = new PremiumCustomersSummaryController();
		ctl.setCurrentYear(true);
		ctl.setDuration(PremiumCustomersSummaryController.LAST6);
		ctl.setRefreshData(true);
	}
	
	public static testmethod void testPremiumCustomersSummaryAll(){
		PremiumCustomersSummaryController ctl = new PremiumCustomersSummaryController();
		ctl.setCurrentYear(false);
		ctl.setDuration(PremiumCustomersSummaryController.ALL);
		ctl.setRefreshData(true);
	}
	
	public static testmethod void testPremiumCustomersSummaryLast3(){
		PremiumCustomersSummaryController ctl = new PremiumCustomersSummaryController();
		ctl.setDuration(PremiumCustomersSummaryController.LAST3);
		ctl.setCurrentYear(false);
		ctl.setRefreshData(true);
	}
	
	public static testmethod void testPremiumCustomersSummaryBeforeLast3(){
		PremiumCustomersSummaryController ctl = new PremiumCustomersSummaryController();
		ctl.setDuration(PremiumCustomersSummaryController.LAST6);
		ctl.setCurrentYear(false);
		ctl.setRefreshData(true);
	}
	
	public static testmethod void testPremiumCustomersSummaryError(){
		PremiumCustomersSummaryController ctl = new PremiumCustomersSummaryController();
		ctl.setDuration('ERROR');
		ctl.setCurrentYear(false);
		ctl.setRefreshData(true);
	}
	
	
	public static testmethod void testDataViewController1(){
		DataViewController ctl = new DataViewController();
		ctl.soql='SELECT Date_TAM_Assigned_to_Account__c,Support_Level__c,Adoption_Score__c,Name,Technical_Account_Manager__r.Name from Account  WHERE Adoption_Score__c!=null and Adoption_Score__c!=0 and Support_Level__c!=null and USD_SUM_Amount__c>=250000.00 and Technical_Account_Manager__c!=null and Adoption_Score__c!=null';
		ctl.setRefreshData(true);
		ctl.getRefreshData();
	}
	
	public static testmethod void testDataViewController2(){
		DataViewController ctl = new DataViewController();
		ctl.soql='SELECT Date_TAM_Assigned_to_Account__c,Support_Level__c,Adoption_Score__c,Name,Technical_Account_Manager__r.Name from Account WHERE  Adoption_Score__c!=null and Adoption_Score__c!=0 and Support_Level__c!=null and Date_TAM_Assigned_to_Account__c=THIS_FISCAL_YEAR and Technical_Account_Manager__c!=null and Adoption_Score__c!=null';
		ctl.setRefreshData(true);
		ctl.getRefreshData();
		ctl.getValue(null,null);
		ctl.getValue(new Account(Name='TestAccount'),'Name');
	}
	
	public static testmethod void testDataViewControllerFail1(){
		DataViewController ctl = new DataViewController();
		ctl.soql='SELECT Date_TAM_Assigned_to_Account__c,Support_Level__c,Adoption_Score__c,Name,Technical_Account_Manager__r.Name from Account  WHERE Adoption_Score__c!=null and Adoption_Score__c!=0 and Support_Level__c!=null and USD_SUM_Amount__c>=250000.00 and Technical_Account_Manager__c!=null and Adoption_Score__c!=null';
		ctl.setRefreshData(true);
		ctl.getRefreshData();
	}
	
	public static testmethod void testDataViewControllerFail21(){
		DataViewController ctl = new DataViewController();
		ctl.soql='SELECT Date_TAM_Assigned_to_Account_Srinidhi_WILL_DEFINITELYFAIL__c,Support_Level__c,Adoption_Score__c,Name,Technical_Account_Manager__r.Name from Account  WHERE Adoption_Score__c!=null and Adoption_Score__c!=0 and Support_Level__c!=null and USD_SUM_Amount__c>=250000.00 and Technical_Account_Manager__c!=null and Adoption_Score__c!=null';
		ctl.setRefreshData(true);
		ctl.getRefreshData();
	}

	public static testmethod void testPremiumCustomersSummaryReportCtrl1(){
		PremiumCustomersAdoptionReportController ctl = new PremiumCustomersAdoptionReportController();
		ctl.selectedYear=2014;
		ctl.selectedQuarter = 'Q1';
		ctl.applyDateChange();
		ctl.getQuarterSelectOptionsList();
		ctl.getYearSelectOptionsList();
	}
}