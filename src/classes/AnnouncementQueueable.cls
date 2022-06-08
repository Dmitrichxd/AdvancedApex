public class AnnouncementQueueable implements Queueable{

    public List<ConnectApi.AnnouncementInput> toPost;

    public void execute(QueueableContext context) {
        PostAnnouncements(toPost);
    }

    public static void PostAnnouncements(List<ConnectApi.AnnouncementInput> announcements){
        while ( announcements.size() > 0 ){
            if ( Limits.getDmlStatements() < Limits.getLimitDmlStatements() && !Test.isRunningTest() ){
                ConnectApi.AnnouncementInput a = announcements.remove(0);
                ConnectApi.Announcements.postAnnouncement('Internal', a);
            } else {
                break;
            }
        }
        if ( announcements.size() > 0 && !Test.isRunningTest() ){
            AnnouncementQueueable q = new AnnouncementQueueable();
            q.toPost = announcements;
            System.enqueueJob(q);
        }
    }

}