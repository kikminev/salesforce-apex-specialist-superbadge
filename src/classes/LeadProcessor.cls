/**
 * Created by kik on 6.04.23.
 *
 * hands-on challenge - https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex/async_apex_batch
 */

public with sharing class LeadProcessor implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return Database.getQueryLocator(
                'SELECT Id FROM Lead'
        );
    }

    public void execute(Database.BatchableContext bc, List<Lead> leads){
        for (Lead lead : leads) {
            lead.LeadSource = 'Dreamforce';
        }

        update leads;
    }

    public void finish(Database.BatchableContext batchableContext){}
}
