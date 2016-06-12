package com.fq.platfrom.android;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import com.loopj.android.http.Base64;

import com.fq.lib.platform.HMACSHA1.HMACSHA1Potocol;

public class HMACSHA1_Android implements HMACSHA1Potocol {

	private static final String HMAC_SHA1 = "HmacSHA1";

	/**
	 * 生成签名数据
	 * 
	 * @param data
	 *            待加密的数据
	 * @param key
	 *            加密使用的key
	 * @return 生成Base64编码的字符串
	 * @throws InvalidKeyException
	 * @throws NoSuchAlgorithmException
	 */
	private String getSignature(byte[] data, byte[] key) throws InvalidKeyException, NoSuchAlgorithmException {
		SecretKeySpec signingKey = new SecretKeySpec(key, HMAC_SHA1);
		Mac mac = Mac.getInstance(HMAC_SHA1);
		mac.init(signingKey);
		byte[] rawHmac = mac.doFinal(data);
		return Base64.encodeToString(rawHmac, Base64.DEFAULT);
		
		// Do MD5?
	}

	/**
	 * 参考: http://114.215.196.3:7080/browse/MVPAN-77
	 * 
	 * @param accessToken
	 *            - 登陆或注册成功后服务器返回的token, 用于安全会话保持
	 * @param userId
	 *            - user id
	 * @param httpMethod
	 *            - post, get, delete, or put
	 * @param timestamp
	 *            - time stamp
	 * @param resource
	 *            - resource表示访问地址，不包括contextPath,比如：http://127.0.0.1:8080/yiyi-
	 *            webapp/image/view.do 为/image/view.do
	 * @return
	 */
	public String getSessionSignature(String accessToken, String userId, String httpMethod, long timestamp, String resource) {
		// accessToken作为hmac1_sha1的密钥
		String VERB = httpMethod;
		String CONTENT_MD5 = "";// 参照jira说明
		String CONTENT_TYPE = "application/json";
		String DATE = "" + timestamp;
		String CanonicalizedHeaders = "";// 参照jira说明
		String CanonicalizedResource = resource;
		String data = VERB + "\n" + CONTENT_MD5 + "\n" + CONTENT_TYPE + "\n" + DATE + "\n" + CanonicalizedHeaders + "\n" + CanonicalizedResource;
		try {
			byte[] tokenAsKey = accessToken.getBytes(); 
			String signature = getSignature(data.getBytes(), tokenAsKey);
			return "YIYI" + userId + ":" + signature;
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
}
