package com.fq.platfrom.android;

import java.net.URLEncoder;
import java.util.ArrayList;

import org.apache.http.message.BasicHeader;

import com.fq.lib.platform.HMACSHA1;
import com.fq.lib.tools.Constants;
import com.fq.platfrom.android.FQAsyncHttpClient.SecuritySession;
import com.gotye.api.utils.Log;

public class FQSecuritySession implements SecuritySession {
	
	private static FQSecuritySession _instance;
	
	private String mAccessToken = null;
	
	private byte[] mSecuriy3DesKey = null;
	
	public static FQSecuritySession getInstance(){
		if (_instance == null) {
			_instance = new FQSecuritySession();
		}
		return _instance;
	}
	
	private FQSecuritySession(){
	}

	@Override
	public void setAccessToken(String accessToken) {
		mAccessToken = accessToken;
		if(accessToken == null){
			mSecuriy3DesKey = null;
		} else {
			byte[] data = accessToken.getBytes();
			mSecuriy3DesKey = new byte[24];
			System.arraycopy(data, 0, mSecuriy3DesKey, 0, mSecuriy3DesKey.length);
		}
	}

	@Override
	public ArrayList<BasicHeader> getSessionHeaders(String resource, String method) {
		if(mAccessToken == null || Constants.getUser().getUserId() == 0){
			return null;
		}
		long timestamp = System.currentTimeMillis();
		String signature = HMACSHA1.getSessionSignature(mAccessToken, "" + Constants.getUser().getUserId(), method, timestamp, resource);
		ArrayList<BasicHeader> headers = new ArrayList<BasicHeader>();
		headers.add(new BasicHeader("Expires", "" + timestamp));
		headers.add(new BasicHeader("userid", "" + Constants.getUser().getUserId()));
		//signature需要做url encode
		try {
			headers.add(new BasicHeader("Authorization", URLEncoder.encode(signature, "utf-8")));
		} catch (Exception e) {
			Log.e("", "", e);
		}
		return headers;
	}

	@Override
	public byte[] get3DesKeyBytes() {
		return mSecuriy3DesKey;
	}

}
