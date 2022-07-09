public with sharing class MaintenanceRequestHelper {

    public final static String CASE_STATUS_CLOSED = 'Closed';

    public final static String CASE_TYPE_REPAIR = 'Repair',
            CASE_TYPE_ROUTINE_MAINTENANCE = 'Routine Maintenance';

    public static void createFutureRepairChecks(List<Case> maintenanceRequestAfterUpdate, Map<Id, Case> maintenanceRquestBeforeUpdate) {

        Set<Id> closedRequestIds = new Set<Id>();
        for (Case maintenanceRequest : maintenanceRequestAfterUpdate) {
            if (maintenanceRequest.Status == CASE_STATUS_CLOSED && maintenanceRquestBeforeUpdate.get(maintenanceRequest.Id).Status != CASE_STATUS_CLOSED
                    && (maintenanceRequest.Type == CASE_TYPE_REPAIR || maintenanceRequest.Type == CASE_TYPE_ROUTINE_MAINTENANCE)
                    ) {
                closedRequestIds.add(maintenanceRequest.Id);
            }
        }

        if (closedRequestIds.size() == 0) {
            return;
        }

        List<Equipment_Maintenance_Item__c> equipmentMaintenanceItemsAttachedToMaintenanceRequest = [SELECT Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :closedRequestIds];
        Map<Id, List<Equipment_Maintenance_Item__c>> equipmentMaintenanceItemsByMaintenanceRequestId = new Map<Id, List<Equipment_Maintenance_Item__c>>();

        for (Equipment_Maintenance_Item__c equipmentMaintenanceItem : equipmentMaintenanceItemsAttachedToMaintenanceRequest) {
            Id maintenanceRequestId = equipmentMaintenanceItem.Maintenance_Request__c;

            List<Equipment_Maintenance_Item__c> equipmentMaintenanceItemsInMR = null != equipmentMaintenanceItemsByMaintenanceRequestId.get(maintenanceRequestId) ? equipmentMaintenanceItemsByMaintenanceRequestId.get(maintenanceRequestId) : new List<Equipment_Maintenance_Item__c>();
            equipmentMaintenanceItemsInMR.add(equipmentMaintenanceItem);

            equipmentMaintenanceItemsByMaintenanceRequestId.put(equipmentMaintenanceItem.Maintenance_Request__c, equipmentMaintenanceItemsInMR);
        }

        for (Case maintenanceRequest : maintenanceRequestAfterUpdate) {
            if (!closedRequestIds.contains(maintenanceRequest.Id)) {
                continue;
            }

            Case futureRoutineCheckup = new Case();
            futureRoutineCheckup.Subject = 'Automatically Scheduled Routine Maintenance';
            futureRoutineCheckup.Type = CASE_TYPE_ROUTINE_MAINTENANCE;
            futureRoutineCheckup.Vehicle__c = maintenanceRequest.Vehicle__c;

            insert futureRoutineCheckup;

            if (null != equipmentMaintenanceItemsByMaintenanceRequestId.get(maintenanceRequest.Id)) {
                List<Equipment_Maintenance_Item__c> equipmentMaintenanceItemsToDuplicate = new List<Equipment_Maintenance_Item__c>();
                List<Equipment_Maintenance_Item__c> equipmentMaintenanceItems = equipmentMaintenanceItemsByMaintenanceRequestId.get(maintenanceRequest.Id);
                for (Equipment_Maintenance_Item__c equipmentMaintenanceItem : equipmentMaintenanceItems) {
                    equipmentMaintenanceItem.Id = null;
                    equipmentMaintenanceItem.Maintenance_Request__c = futureRoutineCheckup.Id;

                    equipmentMaintenanceItemsToDuplicate.add(equipmentMaintenanceItem);
                }

                insert equipmentMaintenanceItemsToDuplicate;
            }
        }
    }
}
