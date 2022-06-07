public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void addRows(){
        for ( Integer i = 0; i < Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add(new ProductWrapper());
        }
    }

    public List<ChartHelper.ChartData> getInventory(){
        return ChartHelper.getInventory();
    }

    public PageReference save(){
        Savepoint sp = Database.setSavepoint();
        try {
            Map<Integer, Product2> products = new Map<Integer, Product2>();
            Map<Integer, PricebookEntry> priceBookEntries = new Map<Integer, PricebookEntry>();
            Integer index = 0;
            for(ProductWrapper prdWrapper : productsToInsert) {
                if(String.isNotBlank(prdWrapper.productRecord.Name) && prdWrapper.pricebookEntryRecord.UnitPrice != null &&
                        prdWrapper.productRecord.Initial_Inventory__c != null && prdWrapper.productRecord.IsActive &&
                        prdWrapper.productRecord.Initial_Inventory__c != 0 && prdWrapper.pricebookEntryRecord.UnitPrice != 0){

                    products.put(index,prdWrapper.productRecord);
                    priceBookEntries.put(index,prdWrapper.pricebookEntryRecord);
                    index ++;
                }
            }
            insert products.values();

            List<PricebookEntry> PBEntries = new List<PricebookEntry>();
            for(Integer mapIndex : products.keySet()) {
                PricebookEntry PBEntry = priceBookEntries.get(mapIndex);
                if (products.get(mapIndex).Id != null) {
                    PBEntry.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                    PBEntry.Product2Id = products.get(mapIndex).Id;
                    PBEntry.IsActive = true;
                    PBEntries.add(PBEntry);
                }

            }
            insert PBEntries;

            //If successful clear the list and display an informational message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
            Database.rollback(sp);
        }
        return null;
    }

    public List<SelectOption> getFamilyOptions() {
        List<SelectOption> familyOptions = new List<SelectOption>();
        familyOptions.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
        for ( Integer i = 0; i < Constants.PRODUCT_FAMILY.size(); i++) {
            familyOptions.add(new SelectOption(
                    Constants.PRODUCT_FAMILY[i].getValue(),
                    Constants.PRODUCT_FAMILY[i].getLabel()
            ));
        }
        return familyOptions;
    }

    public class ProductWrapper {
        public Product2 productRecord {get;set;}
        public PricebookEntry pricebookEntryRecord {get;set;}

        public ProductWrapper() {
            productRecord = new Product2(Initial_Inventory__c = 0);
            pricebookEntryRecord = new PricebookEntry(UnitPrice = 0.0);
        }
    }
}