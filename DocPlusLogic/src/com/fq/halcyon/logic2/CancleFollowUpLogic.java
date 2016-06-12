package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class CancleFollowUpLogic {

	public interface CancleFollowUpLogicInterface extends FQHttpResponseInterface{
		public void onCancleError(int code,String msg);
		public void onCancleSuccess();
	}
	@Weak
	private CancleFollowUpLogicInterface mInterface;
	
	class CancleFollowUpLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onCancleError(code, e.toString());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				mInterface.onCancleSuccess();
			}else{
				mInterface.onCancleError(responseCode, msg);
			}
		}
		
	}
	
	private CancleFollowUpLogicHandle mHandle = new CancleFollowUpLogicHandle();
	
	public CancleFollowUpLogic(CancleFollowUpLogicInterface mIn) {
		mInterface = mIn;
	}

	public void cancleOneFollowUp(int mItemId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("item_id", mItemId);
		JSONObject json = JsonHelper.createJsonForDebug(map);
		String url = UriConstants.Conn.URL_PUB + "/timer/cancel_followup_item.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	public void cancleAllFollowUp(int mTimerId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("timer_id", mTimerId);
		JSONObject json = JsonHelper.createJsonForDebug(map);
		String url = UriConstants.Conn.URL_PUB + "/timer/cancel_followup.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
}
