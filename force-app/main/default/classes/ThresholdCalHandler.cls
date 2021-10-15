/**
 * @Created 
 * @Author Eric
 * @Date 2021-10-15
 * @Function 汇总当天的PMPrice数据计算阈值
 */
public with sharing class ThresholdCalHandler implements TriggerManagement.Handler {

    private final Decimal SILVER_THRESHOLD_VALUE = 0.08;
    private final Decimal GOLD_THRESHOLD_VALUE = 3;
    //private final Decimal THRESHOLD_PERCENT = 0.02;

    public void execute() {

        Datetime baseTime = null;
        PMPrice__c basePmp = null;
        for(PMPrice__c pmp: (List<PMPrice__c>)Trigger.new) {
            Datetime currentDataTime = Datetime.valueOf(pmp.Name);
            //baseTime为空则赋值为当期批次的第一个值
            baseTime = baseTime == null ? currentDataTime : baseTime;
            basePmp = basePmp == null ? pmp : basePmp;
            //baseTime取当前批次的最大值
            baseTime = baseTime > currentDataTime ? baseTime : currentDataTime;
            basePmp = baseTime > currentDataTime ? basePmp : pmp;
        }

        Datetime minTime = baseTime.addDays(-1);
        List<PMPrice__c> pmpL = [SELECT id,Name,GoldMiddlePrice__c,SilverMiddlePrice__c FROM PMPrice__c WHERE CreatedDate>:minTime AND CreatedDate<:baseTime ORDER BY CreatedDate DESC];
        
        String result = Date.today().format() + '预警提示\n';
        Boolean flag = false;
        
        for(PMPrice__c pmp: pmpL) {
            //Math.abs(pmp.GoldMiddlePrice__c - basePmp.GoldMiddlePrice__c) / basePmp.GoldMiddlePrice__c > THRESHOLD_PERCENT
            if(Math.abs(pmp.GoldMiddlePrice__c - basePmp.GoldMiddlePrice__c) > GOLD_THRESHOLD_VALUE) {
                if((pmp.GoldMiddlePrice__c - basePmp.GoldMiddlePrice__c) > GOLD_THRESHOLD_VALUE) {
                    result += Datetime.valueOf(pmp.Name).time() + ' ~ ' + baseTime + '金价降幅达' + (pmp.GoldMiddlePrice__c - basePmp.GoldMiddlePrice__c) + '\n';
                }
                if((basePmp.GoldMiddlePrice__c - pmp.GoldMiddlePrice__c) > GOLD_THRESHOLD_VALUE) {
                    result += Datetime.valueOf(pmp.Name).time() + ' ~ ' + baseTime + '金价涨幅达' + (basePmp.GoldMiddlePrice__c - pmp.GoldMiddlePrice__c) + '\n';
                }
                flag = true;
            }
            if(Math.abs(pmp.SilverMiddlePrice__c - basePmp.SilverMiddlePrice__c) > SILVER_THRESHOLD_VALUE) {
                if((pmp.SilverMiddlePrice__c - basePmp.SilverMiddlePrice__c) > SILVER_THRESHOLD_VALUE) {
                    result += Datetime.valueOf(pmp.Name).time() + ' ~ ' + baseTime + '银价降幅达' + (pmp.SilverMiddlePrice__c - basePmp.SilverMiddlePrice__c) + '\n';
                }
                if((basePmp.SilverMiddlePrice__c - pmp.SilverMiddlePrice__c) > SILVER_THRESHOLD_VALUE) {
                    result += Datetime.valueOf(pmp.Name).time() + ' ~ ' + baseTime + '银价涨幅达' + (basePmp.SilverMiddlePrice__c - pmp.SilverMiddlePrice__c) + '\n';
                }
                flag = true;
            }
        }
        
        if(flag) {
            WechatBasicInfor__c wbi = WechatBasicInfor__c.getInstance('Test');
            WechatMessageService.sendToSingleAsync(wbi.AccessToken__c, wbi.Admins__c, result);
        }
    }
}
