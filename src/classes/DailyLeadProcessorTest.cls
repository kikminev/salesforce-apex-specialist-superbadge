/**
 * Created by kik on 8.04.23.
 *
 * Hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex/async_apex_scheduled
 */

@IsTest
public with sharing class DailyLeadProcessorTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2042';

    @TestSetup
    private static void testSetup() {
        List<Lead> leadsToInsert = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            Lead lead = new Lead();
            lead.FirstName = 'John ' + i;
            lead.LastName = 'Smith ' + i;
            lead.Company = 'Acme Corp';

            leadsToInsert.add(lead);
        }

        insert leadsToInsert;
    }

    @IsTest
    private static void testExecute() {
        List<Lead> leadsWithoutSource = [SELECT Id, LeadSource FROM Lead WHERE LeadSource = NULL];

        Test.startTest();
        System.assertEquals(200, leadsWithoutSource.size());
        System.schedule('UpdateOpportunities', CRON_EXP, new DailyLeadProcessor());
        Test.stopTest();

        List<Lead> leadsWithSource = [SELECT Id, LeadSource FROM Lead WHERE LeadSource = 'Dreamforce'];

        System.assertEquals(200, leadsWithSource.size());
    }
}