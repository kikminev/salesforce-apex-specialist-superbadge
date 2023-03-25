/**
 * Created by kik on 25.03.23.
 * Trailhead challenge https://trailhead.salesforce.com/content/learn/modules/apex_testing/apex_testing_triggers
 */

trigger RestrictContactByName on Contact (before insert, before update) {

    //check contacts prior to insert or update for invalid data
    for (Contact c : Trigger.new) {
        if(c.LastName == 'INVALIDNAME') {	//invalidname is invalid
            c.addError('The Last Name "'+c.LastName+'" is not allowed for DML');
        }
    }
}