package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.FollowUp;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class SearchFollowUpDetailLogic {

	public interface SearchFollowUpDetailLogicInterface extends FQHttpResponseInterface {
		public void onSearchError(int code, String msg);

		public void onSearchSuccess(FollowUp mFollowUp);
	}

	@Weak
	private SearchFollowUpDetailLogicInterface mInterface;

	class SearchFollowUpDetailLogicHandle extends HalcyonHttpResponseHandle {

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onSearchError(code, e.toString());
		}

		@Override
		public void handle(int responseCode, String msg, int type, Object results) {
			if (responseCode == 0) {
				JSONArray mArray = ((JSONObject) results).optJSONArray("templates");
				FollowUp mFollowUp = null;
				for (int i = 0; i < mArray.length(); i++) {
					// 此处由于返回的时是jsonarray 但一个timerId只应该对应一个随访 因此没有用list装起来
					mFollowUp = new FollowUp();
					JSONObject mJsonObject = mArray.optJSONObject(i);
					mFollowUp.setAtttributeByjson(mJsonObject);
				}
				if (mInterface != null)
					mInterface.onSearchSuccess(mFollowUp);
			} else {
				if (mInterface != null)
					mInterface.onSearchError(responseCode, msg);
			}
		}

	}

	private SearchFollowUpDetailLogicHandle mHandle = new SearchFollowUpDetailLogicHandle();

	public SearchFollowUpDetailLogic(SearchFollowUpDetailLogicInterface mIn) {
		this.mInterface = mIn;
	}

	public void searchFollowUpDetail(int mTimerId) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("timer_id", mTimerId);
		JSONObject json = JsonHelper.createJsonForDebug(map);
		String url = UriConstants.Conn.URL_PUB + "/timer/view_followup_detail.do";

		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
}
