/**
 * Created by kik on 19.03.23.
 */

trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
    OpportunityHelper.createFollowUpTaskForClosedWonOpportunities(Trigger.new, Trigger.oldMap);
}