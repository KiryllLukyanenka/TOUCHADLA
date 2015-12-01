public with sharing class PremiumCustomersAdoptionReportController {
	public static final String QUARTER_Q1 = 'Q1';
	public static final String QUARTER_Q2 = 'Q2';
	public static final String QUARTER_Q3 = 'Q3';
	public static final String QUARTER_Q4 = 'Q4';
	public String currentQuarterName{get;set;}
	public integer currentYear;
	public integer selectedYear{get;set;}
	public String selectedQuarter{get;set;}
	public Boolean reloadSummary{get;set;}
	private list<SelectOption> quarterSelectOptionsList;
	private list<SelectOption> yearSelectOptionsList;
	public String startDateStr{get;set;}
	public String endDateStr{get;set;}

	public Boolean showDateTimeSelection{get;set;}
	
	public list<SelectOption> getQuarterSelectOptionsList(){
		quarterSelectOptionsList = new list<SelectOption>();
		quarterSelectOptionsList.add(new SelectOption(QUARTER_Q1,QUARTER_Q1));
		quarterSelectOptionsList.add(new SelectOption(QUARTER_Q2,QUARTER_Q2));
		quarterSelectOptionsList.add(new SelectOption(QUARTER_Q3,QUARTER_Q3));
		quarterSelectOptionsList.add(new SelectOption(QUARTER_Q4,QUARTER_Q4));
		return quarterSelectOptionsList;
	}
	public list<SelectOption> getYearSelectOptionsList(){
		yearSelectOptionsList = new list<SelectOption>();
		yearSelectOptionsList.add(new SelectOption(currentYear+'', currentYear+''));
		yearSelectOptionsList.add(new SelectOption((currentYear-1)+'', (currentYear-1)+''));
		yearSelectOptionsList.add(new SelectOption((currentYear-2)+'', (currentYear-2)+''));
		return yearSelectOptionsList;
	}
	
	public map<String, Datetime> quarterStartDateMap{get;set;}
	public map<String, Datetime> quarterEndDateMap{get;set;}
	
	public PremiumCustomersAdoptionReportController(){
		currentYearAndQuarterSelection();
		buildQuarterStartEndMap(currentYear);
		reloadSummary=true;
		
	}
	
	private void currentYearAndQuarterSelection(){
		currentYear = System.now().year();
		integer month = System.now().month();
		if(month==1){
			currentYear = currentYear-1;
		}
		integer currentMonth = System.now().month();
		selectedYear = currentYear;
		selectedQuarter = monthToQuarterMap.get(currentMonth);
	}
	
	private void buildQuarterStartEndMap(integer year){
		quarterStartDateMap = new map<String,Datetime>{
			QUARTER_Q1=>Datetime.newInstance(year,2,1),
			QUARTER_Q2=>Datetime.newInstance(year,5,1),
			QUARTER_Q3=>Datetime.newInstance(year,8,1),
			QUARTER_Q4=>Datetime.newInstance(year,11,1)
		};
		
		quarterEndDateMap = new map<String,Datetime>{
			QUARTER_Q1=>Datetime.newInstance(year,4,30),
			QUARTER_Q2=>Datetime.newInstance(year,7,31),
			QUARTER_Q3=>Datetime.newInstance(year,10,31),
			QUARTER_Q4=>Datetime.newInstance((year+1),1,31)
		};
	}
	
	public PageReference applyDateChange(){
		buildQuarterStartEndMap(selectedYear);
		Datetime startDate = quarterStartDateMap.get(selectedQuarter);
		Datetime endDate = quarterEndDateMap.get(selectedQuarter);
		startDateStr = startDate.format('yyyy-MM-dd');
		endDateStr = endDate.format('yyyy-MM-dd');
		reloadSummary=false;
		reloadSummary=true;
		return null;	
	}
	
	
	
	private static map<Integer, String> monthToQuarterMap =new map<Integer,String> {
															 1 => QUARTER_Q4,
															 2 => QUARTER_Q1,
															 3 => QUARTER_Q1,
															 4 => QUARTER_Q1,
															 5 => QUARTER_Q2,
															 6 => QUARTER_Q2,
															 7 => QUARTER_Q2,
															 8 => QUARTER_Q3,
															 9 => QUARTER_Q3,
															 10 => QUARTER_Q3,
															 11 => QUARTER_Q4,
															 12 => QUARTER_Q4};
}