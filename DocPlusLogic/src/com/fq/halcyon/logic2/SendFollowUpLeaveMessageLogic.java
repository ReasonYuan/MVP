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

public class SendFollowUpLeaveMessageLogic {

	public interface SendFollowUpLeaveMessageLogicInterface extends FQHttpResponseInterface{
		public void onSubmitMessageError(int code,String msg);
		public void onSubmitMessageSuccess();
	}
	
	@Weak
	private SendFollowUpLeaveMessageLogicInterface mInterface;
	
	class SendFollowUpLeaveMessageLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onSubmitMessageError(code, e.toString());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				mInterface.onSubmitMessageSuccess();
			}else{
				mInterface.onSubmitMessageError(responseCode, msg);
			}
		}
		
	}
	
	private SendFollowUpLeaveMessageLogicHandle mHandle = new SendFollowUpLeaveMessageLogicHandle();
	
	public SendFollowUpLeaveMessageLogic(SendFollowUpLeaveMessageLogicInterface mIn) {
		this.mInterface = mIn;
	}

	public void submitMessage(String message,int mTimerId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("timer_id", mTimerId);
		map.put("note", message);
		JSONObject json = JsonHelper.createJsonForDebug(map);
		String url = UriConstants.Conn.URL_PUB + "/timer/add_followup_note.do";

		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
}
