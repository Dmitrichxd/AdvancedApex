public without sharing class ChartHelper {

    @AuraEnabled
    public static List<ChartData> getInventory(){
        List<ChartData> cht = new List<ChartData>();
        for (AggregateResult groupResult : [
                SELECT SUM(Quantity_Remaining__c)summary, Family
                FROM Product2
                GROUP BY Family
        ]) {
            cht.add(new ChartData(
                    (String) groupResult.get('Family'),
                    (Decimal) groupResult.get('summary')
            ));
        }
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}