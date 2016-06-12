package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.FollowUpTemple;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class FollowUpTempleListLogic {

	public interface FollowUpTempleListLogicInterface{
		public  void onDataError(int code,String msg);
		public void onDataReturn(ArrayList<FollowUpTemple> mTempleList);
		public void onError(int code,Throwable error);
	}
	
	@Weak
	private FollowUpTempleListLogicInterface mInterface;
	private ArrayList<FollowUpTemple> mTempleList = new ArrayList<FollowUpTemple>();
	
	class FollowUpTempleListLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onDataError(code,e.toString());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				JSONObject mJsonObject = (JSONObject)results;
				JSONArray mTempleArrary = mJsonObject.optJSONArray("templates");
				mTempleList.clear();
				for (int i = 0; i < mTempleArrary.length(); i++) {
					FollowUpTemple mFollowUpTemple = new FollowUpTemple();
					mFollowUpTemple.setAtttributeByjson(mTempleArrary.optJSONObject(i));
					mTempleList.add(mFollowUpTemple);
				}
				mInterface.onDataReturn(mTempleList);
			}else{
				mInterface.onDataError(responseCode, msg);
			}
		}
		
	}
	
	private FollowUpTempleListLogicHandle mHandle = new FollowUpTempleListLogicHandle();
	
	public void getTempleList(){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		JSONObject json = JsonHelper.createJsonForDebug(map);
		String url = UriConstants.Conn.URL_PUB + "/timer/search_followup_template.do";
		
		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	public FollowUpTempleListLogic(FollowUpTempleListLogicInterface mIn) {
		this.mInterface = mIn;
	}

	
}
