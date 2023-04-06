/**
 * Created by kik on 6.04.23.
 *
 * hands-on challenge https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex/async_apex_queueable
 */

public class AddPrimaryContact implements Queueable {

    private Contact contact;
    private String state;

    public AddPrimaryContact(Contact contact, String state) {
        this.contact = contact;
        this.state = state;
    }
    public void execute(QueueableContext context) {
        List<Account> accounts = [SELECT Id FROM Account WHERE BillingState = :state];

        List<Contact> contactsToInsert = new List<Contact>();
        for (Account account : accounts) {
            Contact clonedContact = this.contact.clone();
            clonedContact.AccountId = account.Id;

            contactsToInsert.add(clonedContact);
        }

        insert contactsToInsert;
    }
}