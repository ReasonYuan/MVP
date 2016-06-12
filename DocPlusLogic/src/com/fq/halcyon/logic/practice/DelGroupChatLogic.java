package com.fq.halcyon.logic.practice;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class DelGroupChatLogic {

	public interface DelGroupChatCallBack {
		public void delGroupSuccess();

		public void delGroupError(int code, String msg);
	}

	public void delGroup(String groupId, final DelGroupChatCallBack mCallback) {
		HashMap<String, Object> mMap = new HashMap<String, Object>();
		mMap.put("creater_id", Constants.getUser().getUserId());
		mMap.put("cgroup_id", groupId);

		JSONObject mDelGroupJson = JsonHelper.createJson(mMap);
		FQHttpParams mFqHttpParams = new FQHttpParams(mDelGroupJson);

		ApiSystem.getInstance().require(
				UriConstants.Conn.URL_PUB + "/group/dimiss_group.do",
				mFqHttpParams, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						mCallback.delGroupError(-1, Constants.Msg.NET_ERROR);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							mCallback.delGroupSuccess();

						} else {
							mCallback.delGroupError(responseCode, msg);
						}

					}
				});
	}

}
