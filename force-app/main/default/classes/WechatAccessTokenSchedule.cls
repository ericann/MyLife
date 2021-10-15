/**
 * @Created
 * @Author Eric
 * @Date 2021-10-14
 * @Function 定时刷新微信AccessToken
 */
global with sharing class WechatAccessTokenSchedule implements Schedulable {

    public final String sch = '0 {0} {1} ? * 1,2,3,4,5,6,7';
    public final Integer fixedMin = 100;

    global void execute(SchedulableContext sc) {
        refresh();
        System.abortJob(sc.getTriggerId());
        start();
    }

    /**
     * @Function 立即刷新一次AccessToken
     */
    global static void refresh() {
        WechatAccessTokenQueueable watq = new WechatAccessTokenQueueable();
        System.enqueueJob(watq);
    }

    /**
     * @Function 启动计划刷新AccessToken
     */
    global static void start() {
        WechatAccessTokenSchedule wats = new WechatAccessTokenSchedule();

        Datetime dt = Datetime.now().addMinutes(wats.fixedMin);
        String[] args = new String[]{String.valueOf(dt.minute()), String.valueOf(dt.hour())};
        String nextSch = String.format(wats.sch, args);

        System.schedule('Wechat AccessToken Refresh', nextSch, wats);
    }

    /**
     * @Function 启动计划刷新AccessToken，并在当前立即刷新AccessToken 
     */
    global static void refreshAndStart() {
        refresh();
        start();
    }
}
