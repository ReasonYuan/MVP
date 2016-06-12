package com.fq.lib.platform;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

public class HMACSHA1 {  
	
	public interface  HMACSHA1Potocol{
		 /** 
	     * 生成签名数据 
	     *  
	     * @param data 待加密的数据 
	     * @param key  加密使用的key 
	     * @return 生成Base64编码的字符串  
	     * @throws InvalidKeyException 
	     * @throws NoSuchAlgorithmException 
	     */  
	    public String getSessionSignature(String accessToken, String userId, String httpMethod, long timestamp, String resource);
	}
  
	private static HMACSHA1Potocol mInstance;
	
	public static void setHMACSHA1(HMACSHA1Potocol hmacsha1){
		mInstance = hmacsha1;
	}
	
	public static String getSessionSignature(String accessToken, String userId, String httpMethod, long timestamp, String resource) {
		if (mInstance != null) {
			return mInstance.getSessionSignature(accessToken, userId, httpMethod, timestamp, resource);
		}
		return	null;
	}
      
}  