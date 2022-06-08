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
    private static void OrderUpdate_UnitTest() {
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

    @IsTest
    private static void OrderExtension_UnitTest() {
        PageReference pageRef = Page.OrderEdit;
        Test.setCurrentPage(pageRef);
        insert TestDataFactory.ConstructProducts(5);
        Test.startTest();
        Order order = [SELECT Id, Status FROM Order LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(order);
        OrderExtension ext = new OrderExtension(sc);
        System.assertEquals(Constants.DEFAULT_ROWS, ext.orderItemList.size());
        ext.GetFamilyOptions();
        ext.selectedFamily = Constants.SELECT_ONE;
        ext.SelectFamily();
        ext.Next();
        ext.GetHasPrevious();
        ext.GetHasNext();
        ext.GetTotalPages();
        ext.GetPageNumber();
        ext.Previous();
        ext.Last();
        ext.First();
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        ext.orderItemMap.get(prod.Id).Quantity = 2;
        ext.OnFieldChange();
        ext.selectedFamily = 'Dessert';
        ext.SelectFamily();
        ext.Save();
        Test.stopTest();
    }
}