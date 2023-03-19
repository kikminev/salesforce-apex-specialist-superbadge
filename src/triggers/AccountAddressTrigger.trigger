/**
 * Created by kik on 18.03.23.
 */
/*
    Challenge for https://trailhead.salesforce.com/content/learn/modules/apex_triggers/apex_triggers_intro
 */
trigger AccountAddressTrigger on Account (before insert, before update) {

    List<Account> accounts = Trigger.new;

    for (Account account : accounts) {
        if(account.Match_Billing_Address__c == true) {
            account.ShippingPostalCode = account.BillingPostalCode;
        }
    }
}