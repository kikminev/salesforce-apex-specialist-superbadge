/**
 * Created by kik on 19.03.23.
 */

public with sharing class OpportunityHelper {
    public final static String OPPORTUNITY_STAGE_NAME_CLOSED_WON = 'Closed Won';

    public static void createFollowUpTaskForClosedWonOpportunities(List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {

        List<Task> tasksToInsert = new List<Task>();
        for (Opportunity opportunity : opportunities) {

            Opportunity opportunityBeforeUpdate = oldMap != null && oldMap.get(opportunity.Id) != null ? oldMap.get(opportunity.Id) : null;

            if (opportunity.StageName == OPPORTUNITY_STAGE_NAME_CLOSED_WON && null != opportunityBeforeUpdate && opportunityBeforeUpdate.StageName != OPPORTUNITY_STAGE_NAME_CLOSED_WON) {
                Task task = new Task();
                task.Subject = 'Follow Up Test Task';
                task.WhatId = opportunity.Id;

                tasksToInsert.add(task);
            }
        }

        if (tasksToInsert.size() > 0) {
            insert tasksToInsert;
        }
    }
}