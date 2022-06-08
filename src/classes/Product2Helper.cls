public class Product2Helper {

    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name =: Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];

    public static void AfterUpdate(List<Product2> newProducts){
        List<Product2> needsAnnouncement = new List<Product2>();
        Map<String, Inventory_Setting__mdt> familyNameToRecord = new Map<String, Inventory_Setting__mdt>();
        for (Inventory_Setting__mdt setting : [SELECT Label, Low_Quantity_Alert__c FROM Inventory_Setting__mdt]) {
            familyNameToRecord.put(setting.Label, setting);
        }
        for (Product2 product : newProducts) {
            if (product.Quantity_Remaining__c < familyNameToRecord.get(product.Family).Low_Quantity_Alert__c) {
                needsAnnouncement.add(product);
            }
        }
        if (!needsAnnouncement.isEmpty()) {
            PostAlerts(needsAnnouncement);
        }
    }

    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            ConnectApi.MessageBodyInput bodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
            textInput.text = p.Name + ' ' + Constants.INVENTORY_LEVEL_LOW;
            bodyInput.messageSegments = new List<ConnectApi.TextSegmentInput>();
            bodyInput.messageSegments.add(textInput);

            ConnectApi.AnnouncementInput anInput = new ConnectApi.AnnouncementInput();
            anInput.expirationDate = Date.today().addDays(1);
            anInput.sendEmails = false;
            anInput.parentId = COLLABORATION_GROUP[0].Id;
            anInput.body = bodyInput;
            toPost.add(anInput);
        }
        AnnouncementQueueable annQueueable = new AnnouncementQueueable();
        annQueueable.toPost = toPost;
        System.enqueueJob(annQueueable);
    }
}