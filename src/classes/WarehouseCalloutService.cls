global with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    global void execute(QueueableContext context) {
        runWarehouseEquipmentSync();
    }

    public static void runWarehouseEquipmentSync() {
        Http httpClient = new Http();

        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = httpClient.send(request);

        JSONParser parser = JSON.createParser(response.getBody());
        List<Product2> equipmentItemsForUpsert = new List<Product2>();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        EquipmentItem warehouseEquipmentItem = (EquipmentItem) parser.readValueAs(EquipmentItem.class);
                        Product2 equipment = new Product2();

                        equipment.Warehouse_SKU__c = warehouseEquipmentItem.sku;
                        equipment.Cost__c = Decimal.valueOf(warehouseEquipmentItem.cost);
                        equipment.Lifespan_Months__c = Decimal.valueOf(warehouseEquipmentItem.lifespan);
                        equipment.Maintenance_Cycle__c = Decimal.valueOf(warehouseEquipmentItem.maintenanceperiod);
                        equipment.Name = warehouseEquipmentItem.name;
                        equipment.Replacement_Part__c = Boolean.valueOf(warehouseEquipmentItem.replacement);

                        equipmentItemsForUpsert.add(equipment);
                    }
                }
            }
        }

        upsert equipmentItemsForUpsert Warehouse_SKU__c;
    }

    public class EquipmentItem {
        public String sku;
        public String cost;
        public String lifespan;
        public String maintenanceperiod;
        public String name;
        public String replacement;
    }
}

