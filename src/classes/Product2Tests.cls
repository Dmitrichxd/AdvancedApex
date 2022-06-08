@IsTest
private class Product2Tests {

    @TestSetup
    static void setupTestData() {
        Pricebook2 pricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        update pricebook;
        TestDataFactory.InsertTestData(1);
    }

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @IsTest
    private static void Product2Extension_UnitTest() {
        PageReference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Product2 product = new Product2();
        ApexPages.StandardController sc = new ApexPages.StandardController(product);
        Product2Extension ext = new Product2Extension(sc);
        ext.getFamilyOptions();
        System.assert(ext.productsToInsert.size() == Constants.DEFAULT_ROWS);
        ext.addRows();
        System.assert(ext.productsToInsert.size() == Constants.DEFAULT_ROWS * 2);
        ext.getInventory();
        ext.productsToInsert[0].productRecord.Name = 'Product1';
        ext.productsToInsert[0].productRecord.Initial_Inventory__c = 2;
        ext.productsToInsert[0].productRecord.IsActive = true;
        ext.productsToInsert[0].pricebookEntryRecord.UnitPrice = 100;
        ext.save();
        Test.stopTest();

        List<Product2> products = [SELECT Id FROM Product2];
        System.assertEquals(2, products.size());
    }

    @IsTest
    private static void Product2Trigger_UnitTest() {
        Test.startTest();
        Product2 product = [SELECT Name, Family, IsActive, Quantity_Ordered__c, Initial_Inventory__c FROM Product2 LIMIT 1];
        product.Quantity_Ordered__c = 5;
        update product;
        Test.stopTest();
    }
}