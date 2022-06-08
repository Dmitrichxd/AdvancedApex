@IsTest
private class OrderTests {
    @TestSetup
    static void setupTestData() {
        Pricebook2 pricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        update pricebook;
        TestDataFactory.InsertTestData(5);
    }

    @IsTest
    private static void TriggerAndHelperTest() {
        List<Order> orders = [SELECT Id, Status FROM Order WHERE Status = 'Draft'];
        for (Order order : orders) {
            order.Status = Constants.ACTIVATED_ORDER_STATUS;
        }
        Product2 originalProduct = [SELECT Id, Quantity_Ordered__c FROM Product2 LIMIT 1];
        Test.startTest();
        update orders;
        Test.stopTest();
        Product2 updatedProduct = [SELECT Id, Quantity_Ordered__c FROM Product2 LIMIT 1];
        TestDataFactory.VerifyQuantityOrdered(originalProduct, updatedProduct, Constants.DEFAULT_ROWS);
    }
}