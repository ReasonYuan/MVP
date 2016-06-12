package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class HomeMessageLogic {

	public interface HomeMessageLogicInterface extends FQHttpResponseInterface{
		public void onHomeMessageDataReturn(ArrayList<String> messageList);
		public void onHomeMessageDataError(int responseCode, String msg);
	}
	
	@Weak
	private HomeMessageLogicInterface mInterface;
	
	private ArrayList<String> mMessageList = null;
	
	class HomeMessageLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onHomeMessageDataError(code,e.toString());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				JSONArray mArray = ((JSONObject)results).optJSONArray("messages");
				mMessageList = new ArrayList<String>();
				if (mArray.length() > 0) {
					for (int i = 0; i < mArray.length(); i++) {
						JSONObject mJsonObject = mArray.optJSONObject(i);
						String mMessage = mJsonObject.optString("content");
						mMessageList.add(mMessage);
					}
					mInterface.onHomeMessageDataReturn(mMessageList);
				}else{
					mInterface.onHomeMessageDataReturn(mMessageList);
				}
			}else{
				mInterface.onHomeMessageDataError(responseCode, msg);
			}
		}
		
	}
	
	private HomeMessageLogicHandle mHandle = new HomeMessageLogicHandle();
	
	public HomeMessageLogic(HomeMessageLogicInterface mIn) {
		this.mInterface = mIn;
	}
	
	public void getMessages(){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		JSONObject json = JsonHelper.createJsonForDebug(map);
		
		String url = UriConstants.Conn.URL_PUB + "/record/dynamic_message.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}

}
