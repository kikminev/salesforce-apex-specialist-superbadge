/**
 * Created by kik on 12.04.23.
 *
 * Hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/apex_integration_services/apex_integration_soap_callouts
 */

@IsTest
global class ParkServiceMock implements WebServiceMock {
    global void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {

        ParkService.byCountryResponse response1 = new ParkService.byCountryResponse();

        String [] nationalParks = new List<String>();
        nationalParks.add('Hamburg Wadden Sea National Park');
        nationalParks.add('Bavarian Forest National Park');

        response1.return_x = nationalParks;

        response.put('response_x', response1);
    }
}