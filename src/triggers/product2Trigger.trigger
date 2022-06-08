trigger product2Trigger on Product2 (after update) {
    try {
        Product2Helper.AfterUpdate(Trigger.new);
    } catch ( Exception e ){
        System.debug(e.getMessage());
    }
}