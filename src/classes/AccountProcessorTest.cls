/**
 * Created by kik on 2.04.23.
 *
 * Trailhead challenge - https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex/async_apex_future_methods
 */

@IsTest
public with sharing class AccountProcessorTest {
    @TestSetup
    private static void testSetup() {
        Account account1 = new Account();
        account1.Name = 'John Smith 1';

        insert account1;

        Contact contact1 = new Contact();
        contact1.FirstName = 'John';
        contact1.LastName = 'Smith1';
        contact1.AccountId = account1.Id;

        Contact contact2 = new Contact();
        contact2.FirstName = 'John';
        contact2.LastName = 'Smith2';
        contact2.AccountId = account1.Id;

        insert contact1;
        insert contact2;

        Account account2 = new Account();
        account2.Name = 'John Smith 2';

        insert account2;

        Account account3 = new Account();
        account3.Name = 'John Smith 3';

        insert account3;

        Contact contact3 = new Contact();
        contact3.FirstName = 'John';
        contact3.LastName = 'Smith3';
        contact3.AccountId = account3.Id;

        insert contact3;
    }

    @IsTest
    private static void testCountContacts() {

        List<Id> accountIds = new List<Id>();

        for (Account account : [SELECT Id FROM Account]) {
            accountIds.add(account.Id);
        }

        Test.startTest();
            AccountProcessor.countContacts(accountIds);
        Test.stopTest();

        Account account1 = [SELECT Id, Number_Of_Contacts__c FROM Account WHERE Name = 'John Smith 1'];
        System.assertEquals(2, account1.Number_Of_Contacts__c);

        Account account2 = [SELECT Id, Number_Of_Contacts__c FROM Account WHERE Name = 'John Smith 2'];
        System.assertEquals(null, account2.Number_Of_Contacts__c);

        Account account3 = [SELECT Id, Number_Of_Contacts__c FROM Account WHERE Name = 'John Smith 3'];
        System.assertEquals(1, account3.Number_Of_Contacts__c);
    }
}