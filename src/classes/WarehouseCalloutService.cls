public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public static void syncDataFromWareHouse() {
        Http httpClient = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(WAREHOUSE_URL);
        req.setMethod('GET');

        HttpResponse res = httpClient.send(req);

        JSONParser parser = JSON.createParser(res.getBody());
        List<Product2> equipmentItemsForUpsert = new List<Product2>();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        EquipmentItem warehouseEquipmentItem = (EquipmentItem) parser.readValueAs(EquipmentItem.class);
                        Product2 equipment = new Product2();

                        equipment.Warehouse_SKU__c = warehouseEquipmentItem.sku;
                        equipment.Cost__c = Decimal.valueOf(warehouseEquipmentItem.cost);
//                        equipment.Lifespan_Months__c = Decimal.valueOf(warehouseEquipmentItem.lifespan);
                        equipment.Lifespan_Months__c = 17;
                        equipment.Maintenance_Cycle__c = Decimal.valueOf(warehouseEquipmentItem.maintenanceperiod);
                        equipment.Name = warehouseEquipmentItem.name;
                        equipment.Replacement_Part__c = Boolean.valueOf(warehouseEquipmentItem.replacement);
                        equipment.External_Id__c = warehouseEquipmentItem.sku;

                        equipmentItemsForUpsert.add(equipment);
                    }
                }
            }
        }

        upsert equipmentItemsForUpsert;
    }

    public class EquipmentItem {
        public String sku;
        public String cost;
        public String lifespan;
        public String maintenanceperiod;
        public String name;
        public String quantity;
        public String replacement;
    }
}

