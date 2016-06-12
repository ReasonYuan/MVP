package com.fq.platfrom.android;

import java.util.ArrayList;
import java.util.UUID;

import org.apache.http.Header;
import org.apache.http.HttpStatus;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.message.BasicHeader;

import android.content.Context;
import android.telephony.TelephonyManager;

import com.fq.http.async.FQHeader;
import com.fq.http.async.ParamsWrapper;
import com.fq.http.potocol.FQHttpResponseHandle;
import com.fq.http.potocol.HttpClientPotocol;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.hp.android.halcyon.HalcyonApplication;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestHandle;
import com.loopj.android.http.RequestParams;
import com.loopj.android.http.ResponseHandlerInterface;

public class FQAsyncHttpClient extends HttpClientPotocol{
	
	private AsyncHttpClient mHttpClient;
	
	private static Thread mUIThread;
	
	private static String UUID = null;
	
	/**
	 * 参考: http://114.215.196.3:7080/browse/MVPAN-77
	 */
	private static SecuritySession mSecuritySession;
	
	/**
	 * 第一次登陆、注册后服务器返回accessToken, 客户端保存在内存中，以后访问服务器都带上安全会话签名，参考: http://114.215.196.3:7080/browse/MVPAN-77
	 */
	public static interface SecuritySession {
		public void setAccessToken(String accessToken);
		/**
		 * @param resource
		 * 		- resource表示访问地址，不包括contextPath,比如：http://127.0.0.1:8080/yiyi-webapp/image/view.do 为/image/view.do
		 * @return
		 * 		- 安全会话的headers， 如果null,表示无需安全会话参数
		 */
		public ArrayList<BasicHeader> getSessionHeaders(String resource, String httpMethod);
		
		/**
		 * 注意，如果还未登录时session未建立，则返回null
		 * @return
		 * 		- 根据accessToken返回24位长的3des密钥, 即返回accessToken的前24位
		 */
		public byte[] get3DesKeyBytes();
	}

	/**
	 * call this method when application created
	 */
	public static void setHandler(Thread uiThread) {
		mUIThread = uiThread;
	}
	
	public static void setSession(SecuritySession session) {
		mSecuritySession = session;
	}

	public FQAsyncHttpClient() {
		mInstance = this;
		mHttpClient = new AsyncHttpClient(UriConstants.Conn.DO_NOT_VERIFY_CERTIFICATE, 80, UriConstants.Conn.PUB_PORT);
		mHttpClient.setEnableRedirects(true);
	}

	public FQAsyncHttpClient(AsyncHttpClient client) {
		mInstance = this;
		mHttpClient = client;
		mHttpClient.setEnableRedirects(true);
	}
	
	public void check(){
		if(Thread.currentThread() != mUIThread){
			throw new RuntimeException("you must call this method in uiThread");
		}
	}

	public RequestHandle sendPostRequest(final String url, final FQHttpResponseHandle responseHandle) {
		check();
		return mHttpClient.post(url, getResponseHandler(HttpPost.METHOD_NAME, url, null, responseHandle));
	}

	public RequestHandle sendGetRequest(final String url, final FQHttpResponseHandle responseHandle) {
		check();
		return mHttpClient.get(url, getResponseHandler(HttpGet.METHOD_NAME, url, null, responseHandle));
	}

	public RequestHandle sendPostRequest(final String url, final ParamsWrapper params, final FQHttpResponseHandle responseHandle) {
		check();
		return mHttpClient.post(url, params,getResponseHandler(HttpPost.METHOD_NAME, url, params, responseHandle));
	}

	public RequestHandle sendGetRequest(final String url, final ParamsWrapper params, final FQHttpResponseHandle responseHandle) {
		check();
		return mHttpClient.get(url, params,getResponseHandler(HttpGet.METHOD_NAME, url, params, responseHandle));
	}

	public RequestHandle sendPostRequest(final String url, final ParamsWrapper params, final FQHttpResponseHandle responseHandle, int timeOut) {
		check();
		params.setTimeoutTime(timeOut);
		return mHttpClient.post(url, params,getResponseHandler(HttpPost.METHOD_NAME, url, params, responseHandle));
	}

	public RequestHandle sendGetRequest(final String url, final ParamsWrapper params, final FQHttpResponseHandle responseHandle, int timeOut) {
		check();
		params.setTimeoutTime(timeOut);
		return mHttpClient.get(url, params,getResponseHandler(HttpGet.METHOD_NAME, url, params, responseHandle));
	}

	private ResponseHandlerInterface getResponseHandler(final String method, final String url, final ParamsWrapper params, final FQHttpResponseHandle handle) {
		if(params != null){
			mHttpClient.setTimeout(params.getTimeoutTime());
		}
		AsyncHttpResponseHandler handler = new AsyncHttpResponseHandler() {
			
			private boolean writeFinished = false;
			
			@Override
			public void onProgress(int bytesWritten, int totalSize) {
				if (params != null && params.getUpLoadProcess() != null) {
					float process = totalSize == 1 ?  1 : bytesWritten / (float) totalSize;
					if(process >= 1) process = 1;
					if(process == 1){
						if(!writeFinished){
							writeFinished = true;
							params.getUpLoadProcess().setProcess(process);
						}
					}else {
						params.getUpLoadProcess().setProcess(process);
					}
				}
			}

			@Override
			public void onSuccess(int statusCode, Header[] headers, byte[] binaryData) {
				try {
					boolean foundAccessToken = false;
					if (headers != null) {
						for (int i = 0; i < headers.length; i++) {
							if (headers[i].getName().equals("accessToken")) {
								mSecuritySession.setAccessToken(headers[i].getValue());
								foundAccessToken = true;
								break;
							}
						}	
					}
					/*TODO 处理服务器无accessToken返回的情况
					if(url.endsWith("users/login.do") || url.endsWith("users/register.do")){
						if(!foundAccessToken){
							//登陆注册必须返回accessToken
							binaryData = "{\"response_code\":\"1\",\"msg\":\"服务器错误, 需要返回安全会话数据!\"}".getBytes("utf-8");
						}
					}
					*/
					handle.handleResponse(binaryData);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}

			@Override
			public void onFailure(final int statusCode, final Header[] headers, byte[] binaryData, final Throwable error) {
				try {
					 if (statusCode == HttpStatus.SC_MOVED_TEMPORARILY
								|| statusCode == HttpStatus.SC_MOVED_PERMANENTLY) {
							if(headers!=null && headers.length>0){
								for (int i = 0; i < headers.length; i++) {
									String redirectUrl = headers[i].getValue();
									if (redirectUrl.contains("http")) {
										redirectUrl = redirectUrl.replace(" ", "%20");
										handle.handleResponse(redirectUrl.getBytes());
										break;
									}
								}
							}
						}else{
							handle.onError(0,error);
						}
					
				} catch (Exception e) {
					e.printStackTrace();
				}
			
			}
			
		};
		ArrayList<Header> allHeader = new ArrayList<Header>();
		//组合本身handler的headers
		FQHeader[] fqHeaders = handle.getRequestHeaders();
		if(fqHeaders != null){
			Header[] headers = new Header[fqHeaders.length];
			for (int i = 0; i < headers.length; i++) {
				allHeader.add(new BasicHeader(fqHeaders[i].key, fqHeaders[i].value));
			}
		}

		boolean addJsonHeader = false;
		if(params == null || params.fileParams.size() == 0){
			addJsonHeader = true;
		}
		if(addJsonHeader){
			Header jsonHeader = new BasicHeader(AsyncHttpClient.HEADER_CONTENT_TYPE,RequestParams.APPLICATION_JSON);
			allHeader.add(jsonHeader);
		}
		
//		Log.i("", "url: " + url + ", ");
		//有token时添加签名、timestamp、和 userid, 并且startsWith URL_PUB(因为访问阿里云时不时URL_PUB开头的)
		if (url.startsWith(UriConstants.Conn.URL_PUB) && mSecuritySession != null) {
			ArrayList<BasicHeader> mSecurityHeaders = mSecuritySession.getSessionHeaders(url.substring(UriConstants.Conn.URL_PUB.length()), method);
			if (mSecuritySession != null && mSecurityHeaders != null) {
				for (int i = 0; i < mSecurityHeaders.size(); i++) {
					allHeader.add(mSecurityHeaders.get(i));
//					Log.i("", mSecurityHeaders.get(i).getName() + ": " + mSecurityHeaders.get(i).getValue());
				}
			}
		}
//		if(params instanceof FQHttpParams){
//			Log.i("", "json: " + ((FQHttpParams)params).getStringParams());
//		}
		
		//为了支持多点登陆，需要把设备的uuid告诉服务器, 且需要user id
		//以下4中uri不需要userid
		final String[] noUserIDUris = {"/users/register.do", "/users/login.do", "/users/get_verification_code.do", "/users/reset_password.do"};
		allHeader.add(new BasicHeader("uuid", getMyUUID()));
		boolean isNeedUserId = true;
		for (int i = 0; i < noUserIDUris.length; i++) {
			if (url.indexOf(noUserIDUris[i]) != -1) {
				isNeedUserId = false;
				break;
			}
		}
//		if (isNeedUserId) {
//			allHeader.add(new BasicHeader("userId", "" + Constants.getUser().getUserId()));
//		}
		
		if(allHeader.size() > 0){
			Header[] headers = new Header[allHeader.size()];
			allHeader.toArray(headers);
			handler.setRequestHeaders(headers);
		}
		return handler;
	}
	
	private String getMyUUID() {
		if(UUID == null){
			final TelephonyManager tm = (TelephonyManager) HalcyonApplication.getAppContext().getSystemService(Context.TELEPHONY_SERVICE);
			final String tmDevice, tmSerial, androidId;
			tmDevice = "" + tm.getDeviceId();
			tmSerial = "" + tm.getSimSerialNumber();
			androidId = "" + android.provider.Settings.Secure.getString(HalcyonApplication.getAppContext().getContentResolver(), android.provider.Settings.Secure.ANDROID_ID);
			UUID deviceUuid = new UUID(androidId.hashCode(), ((long) tmDevice.hashCode() << 32) | tmSerial.hashCode());
			String uniqueId = deviceUuid.toString();
			UUID = uniqueId;
		}
		return UUID;
	}

	@Override
	public String encode(String value) {
		return value;
	}

	@Override
	public String decode(String value) {
		return value;
	}

}
