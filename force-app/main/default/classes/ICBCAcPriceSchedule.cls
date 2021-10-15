/**
 * @Created
 * @Author Eric
 * @Date 2021-10-14
 * @Function 定时刷新微信AccessToken
 */
global with sharing class ICBCAcPriceSchedule implements Schedulable {

    public final String sch = '0 {0} {1} ? * 1,2,3,4,5,6,7';
    public final Integer fixedMin = 30;

    global void execute(SchedulableContext sc) {
        //周六四点以后到周一早晨八点不读取数据
        Datetime currentTime = Datetime.now();
        Date sunday = Date.today().toStartOfWeek();
        Datetime saturday = Datetime.newInstance(sunday.addDays(-1), Time.newInstance(4, 0, 0, 0));
        Datetime monday = Datetime.newInstance(sunday.addDays(1), Time.newInstance(8, 0, 0, 0));
        
        if(!(currentTime > saturday && currentTime < sunday)) {
            getPrice();
        }
        
        System.abortJob(sc.getTriggerId());
        start();
    }

    /**
     * @Function 立即刷新一次AccessToken
     */
    global static void getPrice() {
        //PMPrice__c pmp = ICBCService.getPrice();
        //ICBCService.sendToWechat(pmp);

        //return pmp;
        ICBCTimedPushQueueable itpq = new ICBCTimedPushQueueable();
        System.enqueueJob(itpq);
    }

    /**
     * @Function 启动计划刷新AccessToken
     */
    global static void start() {
        ICBCAcPriceSchedule icbcp = new ICBCAcPriceSchedule();

        Datetime dt = Datetime.now().addMinutes(icbcp.fixedMin);
        String[] args = new String[]{String.valueOf(dt.minute()), String.valueOf(dt.hour())};
        String nextSch = String.format(icbcp.sch, args);

        System.schedule('ICBC AC Price', nextSch, icbcp);
    }

    /**
     * @Function 启动计划刷新AccessToken，并在当前立即刷新AccessToken 
     */
    global static void refreshAndStart() {
        getPrice();
        start();
    }
}