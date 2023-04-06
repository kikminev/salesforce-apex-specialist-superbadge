/**
 * Created by kik on 6.04.23.
 *
 * hands-on challenge https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex/async_apex_queueable
 */

@IsTest
public with sharing class AddPrimaryContactTest {
    @TestSetup
    private static void testSetup() {
        List<Account> accountsToInsert = new List<Account>();

        for (Integer i = 0; i < 100; i++) {
            Account account = new Account();
            account.Name = 'John Smith ' + i;
            account.BillingState = i < 50 ? 'CA' : 'NY';
            accountsToInsert.add(account);
        }

        insert accountsToInsert;
    }

    @IsTest
    private static void testExecute() {
        List<Account> accountsNY = [SELECT Id FROM Account WHERE BillingState = 'NY'];
        System.assertEquals(50, accountsNY.size());
        Set<Id> accountsNyIds = (new Map<Id, Account>(accountsNY).keySet());

        List<Account> accountsCA = [SELECT Id FROM Account WHERE BillingState = 'CA'];
        System.assertEquals(50, accountsCA.size());
        Set<Id> accountsCaIds = (new Map<Id, Account>(accountsCA).keySet());

        Contact primaryContact = new Contact();
        primaryContact.FirstName = 'Primary John';
        primaryContact.LastName = 'Smith';

        Test.startTest();

        AddPrimaryContact addPrimaryContactNy = new AddPrimaryContact(primaryContact, 'NY');
        AddPrimaryContact addPrimaryContactCa = new AddPrimaryContact(primaryContact, 'CA');
        System.enqueueJob(addPrimaryContactNy);
        System.enqueueJob(addPrimaryContactCa);

        Test.stopTest();

        List<Contact> contactsNY = [SELECT Id FROM Contact WHERE AccountId IN :accountsNyIds];
        System.assertEquals(50, contactsNY.size());

        List<Contact> contactsCa = [SELECT Id FROM Contact WHERE AccountId IN :accountsCaIds];
        System.assertEquals(50, contactsCa.size());
    }
}