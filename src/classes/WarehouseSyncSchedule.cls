global with sharing class WarehouseSyncSchedule implements Schedulable {
    global void execute(SchedulableContext schedulableContext) {
        System.enqueueJob(new WarehouseCalloutService());
    }
}