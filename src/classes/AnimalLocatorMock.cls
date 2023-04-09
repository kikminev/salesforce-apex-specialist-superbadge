/**
 * Created by kik on 9.04.23.
 *
 * Hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/apex_integration_services/apex_integration_rest_callouts
 */

@IsTest
public with sharing class AnimalLocatorMock implements HttpCalloutMock{
    public static HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"animal":{"id":2,"name":"bear","eats":"berries, campers, adam seligman","says":"yum yum"}}');

        return response;
    }
}