public without sharing class OrderTriggerHandler {

    public static void recalculateQuantity(Map<Id, Order> ordersNewMap) {
        List<OrderItem> orderItems = [
                SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity, OrderId, Order.Status
                FROM OrderItem
                WHERE OrderId IN :ordersNewMap.keySet()];

        Map<Id, List<OrderItem>> productIdToOrderItems = new Map<Id, List<OrderItem>>();
        for (OrderItem item : orderItems) {
            if (productIdToOrderItems.get(item.Product2Id) != null) {
                productIdToOrderItems.get(item.Product2Id).add(item);
            } else {
                productIdToOrderItems.put(item.Product2Id, new List<OrderItem>{item});
            }
        }

        List<Product2> products = [SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id IN: productIdToOrderItems.keySet()];
        for (Product2 product : products) {
            Decimal ordered = 0;
            for (OrderItem item : productIdToOrderItems.get(product.Id)) {
                if (item.Order.Status != 'Draft') {
                    ordered += item.Quantity;
                }
            }
            product.Quantity_Ordered__c += ordered;
        }
        update products;
    }
}