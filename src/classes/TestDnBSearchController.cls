@isTest
private class TestDnBSearchController {
    
    @isTest static void testDnBSearch(){
    	Test.setMock(HttpCalloutMock.class, new MockDnBHttpResponse());
    	ApexPages.currentPage().getParameters().put('term', 'meginfo');
    	DnbSearchController ctrl = new DnbSearchController();
        String result = ctrl.SearchResult;
        
		DnbSearchController controller = new DnbSearchController();
		String errorResult = controller.SearchResult;
    }
}