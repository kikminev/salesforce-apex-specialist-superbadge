/**
 * Created by kik on 25.03.23.
 *
 * Apex Testing Data Challenge
 * https://trailhead.salesforce.com/content/learn/modules/apex_testing/apex_testing_data
 */

public with sharing class RandomContactFactory {
    public static List<Contact> generateRandomContacts(Integer numberOfContacts, String lastName) {
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < numberOfContacts; i++) {
            Contact contact = new Contact();
            contact.FirstName = 'John ' + i;
            contact.LastName = lastName;

            contacts.add(contact);
        }

        insert contacts;

        return contacts;
    }
}