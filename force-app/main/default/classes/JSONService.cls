/**
 * @Created
 * @Author Eric
 * @Date 2021-10-14
 * @Function JSON相关功能的工具类 
 */
public with sharing class JSONService {
    
    public static Map<String, Object> parse(String jsonStr) {
        Map<String, Object> result = JSON.deserializeUntyped(jsonStr);

        return result;
    }
}
