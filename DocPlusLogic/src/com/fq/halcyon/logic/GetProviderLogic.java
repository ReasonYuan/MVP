package com.fq.halcyon.logic;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.IOS;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.HttpHelper;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class GetProviderLogic {

	@Weak
	public getProviderCallback mInterface;


	public GetProviderLogic(getProviderCallback inf) {
		mInterface = inf;
	}

	public interface getProviderCallback {
		public void getProviderError(int code, String msg);
		public void res(String provider);
	}

	@IOS
	public void getProvider(String invitationCode) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("invitation_code", invitationCode);
		JSONObject json = JsonHelper.createJson(map);
		String url = UriConstants.Conn.URL_PUB
				+ "/users/check_invitation_code.do";
		FQHttpParams params = new FQHttpParams(json);
		HttpHelper.sendPostRequest(url, params,
				new HalcyonHttpResponseHandle() {
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							String name = ((JSONObject) results)
									.optString("invitationCodeProvider");
							if (!"".equals(name)) {
								mInterface.res(name);
								return;
							}
						} else {
							mInterface.getProviderError(responseCode, msg);
						}
					}

					@Override
					public void onError(int code, Throwable e) {
						if (mInterface != null)
							mInterface.getProviderError(-11, e.getMessage());
						// else error(-11, e.getMessage());
					}
				});
	}

}
