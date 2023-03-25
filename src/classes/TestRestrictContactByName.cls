/**
 * Created by kik on 25.03.23.
 * Trailhead challenge https://trailhead.salesforce.com/content/learn/modules/apex_testing/apex_testing_triggers
 */

@IsTest
private with sharing class TestRestrictContactByName {
    @IsTest
    private static void testValidRestrictContactByName() {
        Contact validContact = new Contact();

        validContact.FirstName = 'John';
        validContact.LastName = 'Smith';

        Database.SaveResult result = Database.insert(validContact);

        System.assertEquals(true, result.isSuccess());
    }

    @IsTest
    private static void testInvalidUpdateRestrictContactByName() {
        Contact validContact = new Contact();

        validContact.FirstName = 'John';
        validContact.LastName = 'Smith';

        Database.SaveResult result = Database.insert(validContact);
        System.assertEquals(true, result.isSuccess());

        validContact.LastName = 'INVALIDNAME';

        Test.startTest();
        Database.SaveResult updateResult = Database.update(validContact, false);
        Test.stopTest();

        System.assertEquals(true, updateResult.getErrors().size() > 0);
        System.assertEquals(false, updateResult.isSuccess());
        System.assertEquals(true, updateResult.getErrors()[0].getMessage().contains('not allowed for DML'));
    }

    @IsTest
    private static void testInvalidInsertRestrictContactByName() {
        Contact validContact = new Contact();

        validContact.FirstName = 'John';
        validContact.LastName = 'INVALIDNAME';

        Test.startTest();
        Database.SaveResult result = Database.insert(validContact, false);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess());
    }
}
