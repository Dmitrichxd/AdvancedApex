public with sharing class TestDataFactory {

    public static CollaborationGroup ConstructCollaborationGroup(){
        CollaborationGroup chatterGroup = new CollaborationGroup(
                Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS,
                CollaborationType = 'Public'
        );
        return chatterGroup;
    }

    public static List<Product2> ConstructProducts(Integer cnt){
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < cnt ; i++) {
            Product2 prod = new Product2(
                    Name = 'Product' + i,
                    Initial_Inventory__c = 10,
                    IsActive = true,
                    Family = Constants.PRODUCT_FAMILY.get(Math.mod(i,4)).getValue());
            products.add(prod);
        }
        return products;
    }

    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (Product2 prod : prods) {
            PricebookEntry entry = new PricebookEntry();
            entry.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            entry.Product2Id = prod.Id;
            entry.UnitPrice = 100;
            entry.IsActive = true;
            entries.add(entry);
        }
        return entries;
    }

    public static List<Account> ConstructAccounts(Integer cnt){
        List<Account> accounts = new List<Account>();
        for (Integer i = 0 ; i < cnt; i++) {
            Account acc = new Account( Name = 'Account' + i);
            accounts.add(acc);
        }
        return accounts;
    }

    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < cnt; i++) {
            Integer index = Math.mod(i, accts.size());
            Contact con = new Contact();
            con.LastName = 'TestContact' + i;
            con.AccountId = accts.get(index).Id;
            contacts.add(con);
        }
        return contacts;
    }

    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        List<Order> orders = new List<Order>();
        for (Integer i=0; i < cnt ; i++) {
            Order ord = new Order();
            ord.AccountId = accts.get(Math.mod(i, accts.size())).Id;
            ord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            ord.Status = 'Draft';
            ord.EffectiveDate = System.today();
            orders.add(ord);
        }
        return orders;
    }

    public static  List<OrderItem> ConstructOrderItems(Integer cnt, List<PricebookEntry> pbes, List<Order> ords){
        List<OrderItem> items = new List<OrderItem>();
        for (Integer i = 0; i < cnt; i++) {
            OrderItem ord = new OrderItem();
            ord.PricebookEntryId = pbes.get(Math.mod(i, pbes.size())).Id;
            ord.OrderId = ords.get(Math.mod(i, ords.size())).Id;
            ord.Quantity = Constants.DEFAULT_ROWS;
            ord.UnitPrice = 250;
            items.add(ord);
        }

        return items;
    }

    public static void InsertTestData(Integer cnt){
        CollaborationGroup groups = TestDataFactory.ConstructCollaborationGroup();
        insert groups;

        List<Product2>  products= TestDataFactory.ConstructProducts(cnt);
        insert products;

        List<PricebookEntry> entries = TestDataFactory.ConstructPricebookEntries(products);
        insert entries;

        List<Account> accts = TestDataFactory.ConstructAccounts(cnt);
        insert accts;

        List<Contact> contacts = TestDataFactory.ConstructContacts(cnt,accts);
        insert contacts;

        List<Order> orders = TestDataFactory.ConstructOrders( cnt,  accts);
        insert orders;

        List<OrderItem> items = TestDataFactory.ConstructOrderItems(cnt, entries, orders);
        insert items;

    }

    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
        System.assertEquals((updatedProduct.Quantity_Ordered__c - originalProduct.Quantity_Ordered__c), qtyOrdered);
    }
}