/**
 * Created by kik on 12.04.23.
 *
 * Hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/apex_integration_services/apex_integration_soap_callouts
 */

@IsTest
public with sharing class ParkLocatorTest {
    @IsTest
    public static void testGetParksByCountry() {
        Test.setMock(WebServiceMock.class, new ParkServiceMock());

        ParkService.ParksImplPort parksImplPort = new ParkService.ParksImplPort();

        System.debug(parksImplPort.byCountry('Germany'));

        String[] parks = ParkLocator.country('Germany');
        System.assertEquals(2, parks.size());

        System.assertEquals(true, parks[0].contains('Hamburg Wadden Sea National Park'));
        System.assertEquals(true, parks[1].contains('Bavarian Forest National Park'));
    }
}
