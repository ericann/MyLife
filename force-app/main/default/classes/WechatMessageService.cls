/**
 * @Created
 * @Author Eric
 * @Date 2021-10-14
 * @Function 微信信息管理，向用户推送消息
 */
public with sharing class WechatMessageService {
    
    public static void sendToSingle(String accessToken, String openId, String message) {
        String url = 'https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token={0}';
        String text = '{"touser":"{0}","msgtype":"text","text":{"content":"{1}"}}';
        HttpResponse response = HttpService.post(url.replace('{0}', accessToken), text.replace('{0}', openId).replace('{1}', message));
        System.debug('-- WechatMessageService sendToSingle response: ' + response.getBody());
    }

    public static void sendToSingleAsync(String accessToken, String openId, String message) {
        //WechatBasicInfor__c wbi = WechatBasicInfor__c.getInstance('Test');
        WechatMessagesQueueable wmq = new WechatMessagesQueueable(accessToken, openId, message);
        System.enqueueJob(wmq);
    }

    public static void test() {
        WechatBasicInfor__c wbi = WechatBasicInfor__c.getInstance('Test');
        sendToSingle(wbi.AccessToken__c, wbi.Admins__c, '银价搞的劳资心态崩了！！！');
    }
}
