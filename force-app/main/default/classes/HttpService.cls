/**
 * @Created 
 * @Author Eric
 * @Date 2021-10-14
 * @Function Http相关功能的工具类
 */
public with sharing class HttpService {
    public HttpService() {

    }

    public static HttpResponse get(String url) {
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(url);
        request.setMethod('GET');

        return h.send(request);
    }

    public static HttpResponse post(String url, String body) {
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setBody(body);

        return h.send(request);
    }
}
