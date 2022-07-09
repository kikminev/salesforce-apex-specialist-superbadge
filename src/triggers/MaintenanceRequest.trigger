trigger MaintenanceRequest on Case (after update) {
    List<Case> casesAfterUpdate = Trigger.new;
    Map<Id, Case> casesBeforeUpdate = Trigger.oldMap;

    MaintenanceRequestHelper.createFutureRepairChecks(casesAfterUpdate, casesBeforeUpdate);
}