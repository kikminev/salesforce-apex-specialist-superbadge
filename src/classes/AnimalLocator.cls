/**
 * Created by kik on 9.04.23.
 *
 * Hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/apex_integration_services/apex_integration_rest_callouts
 */

public with sharing class AnimalLocator {
    public static String getAnimalNameById(Integer Id) {

        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
        httpRequest.setMethod('GET');
        httpRequest.setEndpoint('http://th-apex-http-callout.herokuapp.com/animals/' + Id);

        HttpResponse response = http.send(httpRequest);

        Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        Map<String, Object> properties = (Map<String, Object>) responseObj.get('animal');

        return (String) properties.get('name');
    }
}