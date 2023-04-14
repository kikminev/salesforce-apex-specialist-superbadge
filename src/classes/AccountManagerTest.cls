/**
 * Created by kik on 14.04.23.
 *
 * Apex hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/apex_integration_services/apex_integration_webservices
 */

@IsTest
public with sharing class AccountManagerTest {
    @TestSetup
    private static void testSetup() {
        Account account = new Account();
        account.Name = 'John Smith 1';

        insert account;

        Contact contact1 = new Contact();
        contact1.FirstName = 'John';
        contact1.LastName = 'Smith1';
        contact1.AccountId = account.Id;

        Contact contact2 = new Contact();
        contact2.FirstName = 'John';
        contact2.LastName = 'Smith2';
        contact2.AccountId = account.Id;

        insert contact1;
        insert contact2;
    }

    @IsTest
    private static void testGetAccount() {

        Account account = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = 'https://mindful-panda-ms4w5w-dev-ed.lightning.force.com/services/apexrest/Accounts/' + account.Id + '/contacts';

        request.httpMethod = 'GET';
        RestContext.request = request;

        Account accountFromREST = AccountManager.getAccount();
        System.assertEquals(account.Name, accountFromREST.Name);
        System.assertEquals(2, accountFromREST.Contacts.size());
        Test.stopTest();
    }
}