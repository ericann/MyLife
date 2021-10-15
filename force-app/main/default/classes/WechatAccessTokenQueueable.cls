/**
 * @Created
 * @Author Eric
 * @Date 2021-10-15
 * @Function 通过queueable接口以避免在schedule中触发callout limitation
 */
public class WechatAccessTokenQueueable implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context) {
        WechatAccessTokenService.refreshAllTokens();
    }
}
