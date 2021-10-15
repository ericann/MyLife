/**
 * @Created
 * @Author Eric
 * @Date 2021-10-15
 * @Function 异步发送信息
 */
public class WechatMessagesQueueable implements Queueable, Database.AllowsCallouts {

    private String accessToken;
    private String openId;
    private String message;

    public WechatMessagesQueueable(String accessToken, String openId, String message) {
        this.accessToken = accessToken;
        this.openId = openId;
        this.message = message;
    }
    
    public void execute(QueueableContext context) {
        WechatMessageService.sendToSingle(this.accessToken, this.openId, this.message);
    }
}
