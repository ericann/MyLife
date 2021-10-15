/**
 * @Created
 * @Author Eric
 * @Date 2021-10-15
 * @Function 通过queueable接口以避免在schedulable中触发callout limitation
 */
public class ICBCTimedPushQueueable implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context) {
        PMPrice__c pmp = ICBCService.getPrice();
        ICBCService.sendToWechat(pmp);

        SavePmpQueueable spq = new SavePmpQueueable();
        spq.pmp = pmp;
        System.enqueueJob(spq);
    }

    private class SavePmpQueueable implements Queueable {
        PMPrice__c pmp;
        public void execute(QueueableContext context) {
            insert pmp;
        }
    }
}
