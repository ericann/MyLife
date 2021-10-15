/**
 * @Created
 * @Author Eric
 * @Date 2021-10-14
 * @Function 获取ICBC账户贵金属价格，并存储到SFDC中
 */
public with sharing class ICBCService {
    
    public static PMPrice__c getPrice() {
        String url = 'https://mybank.icbc.com.cn/servlet/AsynGetDataServlet?Area_code=0602&trademode=1&proIdsIn=130060000043|130060000044&isFirstTime=0&tranCode=A00462';
        HttpResponse response = HttpService.get(url);

        Map<String, Object> obj = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        String sysDatetime = (String)obj.get('sysdate');
        List<Object> objArr = (List<Object>)obj.get('market');

        PMPrice__c pmp = new PMPrice__c();

        for(Object o: objArr) {
            Map<String, Object> temp = (Map<String, Object>)o;
            String type = (String)temp.get('prodcode');

            //黄金
            if('130060000043'.equals(type)) {
                pmp.GoldMiddlePrice__c = Decimal.valueOf((String)temp.get('middleprice'));
            }

            //白银
            if('130060000044'.equals(type)) {
                pmp.SilverMiddlePrice__c = Decimal.valueOf((String)temp.get('middleprice'));
            }
        }
        pmp.Name = sysDatetime;

        //insert pmp;

        return pmp;
    }

    public static void sendToWechat(PMPrice__c pmp) {
        Decimal gold = 0.4;
        Decimal silver = 0.015;
        String message = '半小时价格推送服务' + 
            '\n黄金买入价 ' + (pmp.GoldMiddlePrice__c - gold) + 
            '\n黄金卖出价 ' + (pmp.GoldMiddlePrice__c + gold) +
            '\n白银买入价 ' + (pmp.SilverMiddlePrice__c - silver) + 
            '\n白银卖出价' + (pmp.SilverMiddlePrice__c + silver) +
            '\n系统时间 ' + pmp.Name;
        
        WechatBasicInfor__c wbi = WechatBasicInfor__c.getInstance('Test');
        WechatMessageService.sendToSingle(wbi.AccessToken__c, wbi.Admins__c, message);
    }

}

