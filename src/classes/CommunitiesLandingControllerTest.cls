/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@isTest 
public class CommunitiesLandingControllerTest {
	
    @isTest static void testCommunitiesLandingController(){
        CommunitiesLandingController controller = new CommunitiesLandingController();
        controller.forwardToStartPage();
    }
}