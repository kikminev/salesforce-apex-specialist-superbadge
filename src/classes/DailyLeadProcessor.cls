/**
 * Created by kik on 8.04.23.
 *
 * Hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex/async_apex_scheduled
 */

public with sharing class DailyLeadProcessor implements Schedulable {

    public static void execute(SchedulableContext schedulableContext) {
        List<Lead> leadsWithoutSource = [SELECT Id, LeadSource FROM Lead WHERE LeadSource = NULL ORDER BY CreatedDate ASC ];

        for (Lead lead : leadsWithoutSource) {
            lead.LeadSource = 'Dreamforce';
        }

        update leadsWithoutSource;
    }
}
