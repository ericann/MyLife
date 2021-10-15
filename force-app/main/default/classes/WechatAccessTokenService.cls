/**
 * @Created
 * @Author Eric
 * @Date 2021-10-14
 * @Function 获取微信Access Token
 */
public with sharing class WechatAccessTokenService {
    public WechatAccessTokenService() {

    }

    public static Map<String, String> refreshAllTokens() {
        Map<String, WechatBasicInfor__c> wbis = WechatBasicInfor__c.getAll();
        Map<String, String> result = new Map<String, String>();

        for(WechatBasicInfor__c wbi: wbis.values()) {
            if(!wbi.Refresh__c) {
                continue;
            }

            String response = getAccessToken(wbi.AppId__c, wbi.AppSecret__c);
            Map<String, Object> resObj = (Map<String, Object>)JSON.deserializeUntyped(response);
            wbi.AccessToken__c = (String)resObj.get('access_token');
            
            result.put(wbi.ID, response);
        }

        update wbis.values();

        return result;
    }

    public static String refreshToken(String name) {
        WechatBasicInfor__c wbi = WechatBasicInfor__c.getValues(name);
        String response = getAccessToken(wbi.AppId__c, wbi.AppSecret__c);
        
        Map<String, Object> resObj = (Map<String, Object>)JSON.deserializeUntyped(response);
        wbi.AccessToken__c = (String)resObj.get('access_token');

        update wbi;

        return response;
    }
    
    /**
     * officialAccountId - 公众号Id
     */
    private static String getAccessToken(String appId, String appSecret) {
        String url = 'https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={0}&secret={1}';
        HttpResponse response = HttpService.get(url.replace('{0}', appId).replace('{1}', appSecret));

        System.debug('-- response: ' + response.getBody());
        return response.getBody();
    }
}
