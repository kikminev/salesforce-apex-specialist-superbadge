/**
 * Created by kik on 2.04.23.
 *
 * Trailhead challenge - https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex/async_apex_future_methods
 */

public with sharing class AccountProcessor {
    @Future
    public static void countContacts(List<Id> accountIds) {
        List<Account> accounts = [SELECT Id, Number_Of_Contacts__c FROM Account];

        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds];

        Account account1 = [SELECT Id FROM Account WHERE Name = 'John Smith 1' LIMIT 1];
        System.debug(account1.Id);

        List<Contact> contactsDebug = [SELECT Id FROM Contact WHERE AccountId = :account1.Id];
        System.debug('>>>> ' + contactsDebug.size());

        Map<Id, Integer> numberOfContactsByAccountId = new Map<Id, Integer>();
        for (Contact contact : contacts) {
            Id accountId = contact.AccountId;


            if (null == numberOfContactsByAccountId.get(accountId) || 0 == numberOfContactsByAccountId.get(accountId)) {
                numberOfContactsByAccountId.put(accountId, 1);
            } else {
                Integer contactsCount = numberOfContactsByAccountId.get(accountId);
                contactsCount = contactsCount + 1;

                if (account1.Id == accountId) {
                    System.debug(contactsCount);
                }

                numberOfContactsByAccountId.put(accountId, contactsCount);
            }
        }

        for (Account account : accounts) {
            if (null != numberOfContactsByAccountId.get(account.Id)) {
                account.Number_Of_Contacts__c = numberOfContactsByAccountId.get(account.Id);
            }
        }

        update accounts;
    }
}