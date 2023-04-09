/**
 * Created by kik on 9.04.23.
 *
 * Hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/apex_integration_services/apex_integration_rest_callouts
 */

@IsTest
public with sharing class AnimalLocatorTest {
    @IsTest
    private static void testGetAnimalNameById() {
        AnimalLocatorMock animalNameHttpCalloutMock = new AnimalLocatorMock();
        Test.setMock(HttpCalloutMock.class, animalNameHttpCalloutMock);

        String animalName = AnimalLocator.getAnimalNameById(2);

        System.assertEquals('bear', animalName);
    }
}