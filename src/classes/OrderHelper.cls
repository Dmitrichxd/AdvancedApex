public without sharing class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i = 0; i < newList.size(); i++ ){
            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status != Constants.ACTIVATED_ORDER_STATUS ){
                orderIds.add(newList[i].Id);
            }
        }
        RollUpOrderItems(orderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        for (OrderItem item : [
                SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity, OrderId
                FROM OrderItem
                WHERE OrderId IN :activatedOrderIds
        ]) {
            productMap.put(item.Product2Id, item.Product2);
        }
        for (AggregateResult orderResult : [
                SELECT Product2Id, SUM(Quantity)
                FROM OrderItem
                WHERE Product2Id IN :productMap.keySet()
                GROUP BY Product2Id
        ]) {
            Id productId = (Id) orderResult.get('Product2Id');
            productMap.get(productId).Quantity_Ordered__c = (Decimal) orderResult.get('expr0');
        }
        update productMap.values();
    }

}