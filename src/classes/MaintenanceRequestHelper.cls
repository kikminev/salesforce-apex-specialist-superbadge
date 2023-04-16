public with sharing class MaintenanceRequestHelper {

    public final static String CASE_STATUS_CLOSED = 'Closed';

    public final static String CASE_TYPE_REPAIR = 'Repair',
            CASE_TYPE_ROUTINE_MAINTENANCE = 'Routine Maintenance';

    public static void createFutureRepairChecks(List<Case> requestsAfterUpdate, Map<Id, Case> maintenanceRequestBeforeUpdate) {
        Set<Id> closedRequestIds = new Set<Id>();

        for (Case maintenanceRequest : requestsAfterUpdate) {
            if (maintenanceRequest.Status == CASE_STATUS_CLOSED && maintenanceRequestBeforeUpdate.get(maintenanceRequest.Id).Status != CASE_STATUS_CLOSED
                    && (maintenanceRequest.Type == CASE_TYPE_REPAIR || maintenanceRequest.Type == CASE_TYPE_ROUTINE_MAINTENANCE)
                    ) {
                closedRequestIds.add(maintenanceRequest.Id);
            }
        }

        if (closedRequestIds.size() == 0) {
            return;
        }

        Map<Id, List<Equipment_Maintenance_Item__c>> equipmentMaintenanceItemsByRequestId = getEquipmentMaintenanceItemsByRequestsIds(closedRequestIds);
        Map<Id, Product2> equipmentById = getEquipment(closedRequestIds);

        List<Case> futureRoutineCheckupForCreation = new List<Case>();
        List<Equipment_Maintenance_Item__c> equipmentMaintenanceItemsForDuplication = new List<Equipment_Maintenance_Item__c>();
        Map<String, Id> vehicleToMaintenanceRequestId = new Map<String, Id>();

        for (Case maintenanceRequest : requestsAfterUpdate) {
            if (!closedRequestIds.contains(maintenanceRequest.Id)) {
                continue;
            }

            // get all equipment Maintenance Items connected to single Maintenance Request
            List<Equipment_Maintenance_Item__c> equipmentMaintenanceItems = equipmentMaintenanceItemsByRequestId.get(maintenanceRequest.Id);

            Integer shortestMaintenanceCycle = 0;
            for (Equipment_Maintenance_Item__c item : equipmentMaintenanceItems) {
                Product2 equipment = equipmentById.get(item.Equipment__c);
                if (equipment.Maintenance_Cycle__c < shortestMaintenanceCycle || shortestMaintenanceCycle == 0) {
                    shortestMaintenanceCycle = (Integer) equipment.Maintenance_Cycle__c;
                }
            }

            Case futureRoutineCheckup = new Case();
            futureRoutineCheckup.Subject = 'Automatically Scheduled Routine Maintenance';
            futureRoutineCheckup.Type = CASE_TYPE_ROUTINE_MAINTENANCE;
            futureRoutineCheckup.Vehicle__c = maintenanceRequest.Vehicle__c;
            futureRoutineCheckup.Date_Reported__c = System.today();
            futureRoutineCheckup.Date_Due__c = System.today().addDays(shortestMaintenanceCycle);

            futureRoutineCheckupForCreation.add(futureRoutineCheckup);
            vehicleToMaintenanceRequestId.put(maintenanceRequest.Vehicle__c, maintenanceRequest.Id);
        }

        insert futureRoutineCheckupForCreation;

        for (Case futureRoutineCheckup : futureRoutineCheckupForCreation) {
            List<Equipment_Maintenance_Item__c> equipmentMaintenanceItems = equipmentMaintenanceItemsByRequestId.get(vehicleToMaintenanceRequestId.get(futureRoutineCheckup.Vehicle__c));


            for (Equipment_Maintenance_Item__c item : equipmentMaintenanceItems) {
                Equipment_Maintenance_Item__c duplicatedItem = item.clone();
                duplicatedItem.Maintenance_Request__c = futureRoutineCheckup.Id;
                equipmentMaintenanceItemsForDuplication.add(duplicatedItem);
            }
        }

        insert equipmentMaintenanceItemsForDuplication;
    }

    /*
        This method will return all 'Equipment Maintenance Item' related to 'Maintenance Requests'
        ordered by Maintenance Requests Id
     */
    private static Map<Id, List<Equipment_Maintenance_Item__c>> getEquipmentMaintenanceItemsByRequestsIds(Set<Id> maintenanceRequestsIds) {
        List<Equipment_Maintenance_Item__c> equipmentMaintenanceItems = [SELECT Id, Maintenance_Request__c, Quantity__c, Equipment__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :maintenanceRequestsIds];

        if (equipmentMaintenanceItems.size() == 0) {

            return null;
        }

        // create a map of lists of Equipment Maintenance Items by Request Id
        Map<Id, List<Equipment_Maintenance_Item__c>> equipmentItemsByMaintenanceRequestId = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        for (Equipment_Maintenance_Item__c item : equipmentMaintenanceItems) {
            Id maintenanceRequestId = item.Maintenance_Request__c;

            List<Equipment_Maintenance_Item__c> equipmentMaintenanceItemsInMR = null != equipmentItemsByMaintenanceRequestId.get(maintenanceRequestId) ? equipmentItemsByMaintenanceRequestId.get(maintenanceRequestId) : new List<Equipment_Maintenance_Item__c>();
            equipmentMaintenanceItemsInMR.add(item);

            equipmentItemsByMaintenanceRequestId.put(item.Maintenance_Request__c, equipmentMaintenanceItemsInMR);
        }

        return equipmentItemsByMaintenanceRequestId;
    }

    private static Map<Id, Product2> getEquipment(Set<Id> maintenanceRequestsIds) {
        List<Equipment_Maintenance_Item__c> equipmentMaintenanceItems = [SELECT Id, Equipment__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :maintenanceRequestsIds];

        if (equipmentMaintenanceItems.size() == 0) {
            return null;
        }

        Set<Id> equipmentIds = new Set<Id>();
        for (Equipment_Maintenance_Item__c item : equipmentMaintenanceItems) {
            equipmentIds.add(item.Equipment__c);
        }

        Map<Id, Product2> allEquipmentById = new Map<Id, Product2>([SELECT Id, Maintenance_Cycle__c FROM Product2 WHERE Id IN :equipmentIds]);

        return allEquipmentById;
    }
}
