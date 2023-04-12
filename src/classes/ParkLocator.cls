/**
 * Created by kik on 12.04.23.
 *
 * Hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/apex_integration_services/apex_integration_soap_callouts
 */

public with sharing class ParkLocator {
    public static String[] country(String countryName) {
        ParkService.ParksImplPort parksImplPort = new ParkService.ParksImplPort();

        return parksImplPort.byCountry(countryName);
    }
}