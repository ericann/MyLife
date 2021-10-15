/**
*@Created
*@Author: Eric
*@Date: 2021.10.13
*@Function: wechat rest interface, root file at main org
*/

@RestResource(urlMapping='/wechat/*')
global class WechatListener {
    
    /**
     * 微信公众号基本配置认证方式
     */
    @HttpGet
    global static void doGet() {
        List<String> validate = new List<String>();
        
        String signature = RestContext.request.params.get('signature');
        String timestamp = RestContext.request.params.get('timestamp');
        String nonce = RestContext.request.params.get('nonce');
        String echostr = RestContext.request.params.get('echostr');
        
        //token mapping
        validate.add('Alfred');
        validate.add(timestamp);
        validate.add(nonce);
        
        validate.sort();
        
        String validateStr = '';
        
        for(String s : validate) {
            validateStr += s;
        }
        
        Blob returnValue = Crypto.generateDigest('SHA1',Blob.valueOf(validateStr));
        String signatureMatch = EncodingUtil.convertToHex(returnValue);
        
        system.debug('----signature returnValue:'+signatureMatch == signature);
        system.debug('----request:'+RestContext.request);
        system.debug('----returnValue:'+returnValue);
        system.debug('----returnValue:'+String.valueOf(returnValue));
        RestContext.response.responseBody = Blob.valueOf(echostr);
    }
    
    @HttpPost
    global static void doPost() {
        system.debug(RestContext.request);
        
        String toUserName = '';
        String fromUserName = '';
        String msgType = '';
        String content = '';
        //获取XML数据包
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        string strMsg = req.requestBody.toString();  
        XmlStreamReader reader = new XmlStreamReader(strMsg);

        //解析XML数据包，Force.com这块的处理能力并不强，简单的结构也需要较多代码来解析
         while(reader.hasNext()){
            if(reader.getLocalName() == 'ToUserName'){
                reader.next();
                if(String.isNotBlank(reader.getText())){
                    toUserName = reader.getText();
                }
            }
            else if(reader.getLocalName() == 'FromUserName'){
                reader.next();
                if(String.isNotBlank(reader.getText())){
                    fromUserName = reader.getText();
                }
            }
            else if(reader.getLocalName() == 'MsgType'){
                reader.next();
                if(String.isNotBlank(reader.getText())){
                    msgType = reader.getText();
                }
            }
            else if(reader.getLocalName() == 'Content'){
                reader.next();
                if(String.isNotBlank(reader.getText())){
                    content = reader.getText();
                }
            }
            reader.next();
        }
        
        system.debug('---content:'+content);
        
        String replyMSG = '<xml><ToUserName><![CDATA[{0}]]></ToUserName><FromUserName><![CDATA[{1}]]></FromUserName><CreateTime>12345678</CreateTime><MsgType><![CDATA[text]]></MsgType><Content><![CDATA[{2}]]></Content></xml>';
        
        if(content.contains('plan') || content.contains('计划'))
            content = 'https://we-chat-developer-edition.ap2.force.com/PlanIndex';
        if(content.contains('77'))
            content = 'https://we-chat-developer-edition.ap2.force.com/SevenSevenGame';
        if(content.contains('eric'))
            content = 'https://we-chat-developer-edition.ap2.force.com/MoneyIndex';
        if(content.contains('index'))
            content = 'https://we-chat-developer-edition.ap2.force.com/index';
        String[] arguments = new String[]{fromUserName, toUserName, content};
        
        system.debug('----fromUserName:'+fromUserName);
        system.debug('----toUserName:'+toUserName);
        
        String formattedReplyMSG = String.format(replyMSG, arguments);
        
        RestContext.response.addHeader('Content-Type', 'text/plain');
        RestContext.response.responseBody = Blob.valueOf(formattedReplyMSG);
    }
}