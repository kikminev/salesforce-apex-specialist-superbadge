/**
 * Created by kik on 6.04.23.
 *
 * hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex/async_apex_batch
 */

@IsTest
public with sharing class LeadProcessorTest {

    @TestSetup
    private static void testSetup() {
        List<Lead> leadsToInsert = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            Lead lead = new Lead();
            lead.FirstName = 'John ' + i;
            lead.LastName = 'Smith ' + i;
            lead.Company = 'Salesforce Devs';
            leadsToInsert.add(lead);
        }

        insert leadsToInsert;
    }

    @IsTest
    private static void testExecure() {
        Test.startTest();
        LeadProcessor leadProcessor = new LeadProcessor();
        Database.executeBatch(leadProcessor);
        Test.stopTest();

        List<Lead> leads = [SELECT Id, LeadSource FROM Lead WHERE LeadSource = 'Dreamforce'];

        System.assertEquals(200, leads.size());
    }
}
