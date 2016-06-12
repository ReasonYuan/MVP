package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.FollowUp;
import com.fq.halcyon.entity.OnceFollowUpCycle;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class AddOneFollowUpLogic {

	public interface AddOneFollowUpLogicInterface extends FQHttpResponseInterface{
		public void onAddError(int code,String msg);
		public void onAddSuccess(int timerId);
	}
	
	@Weak
	public AddOneFollowUpLogicInterface mInterface;
	
	private FollowUp mCurrentFollowUp;
	
	private ArrayList<Contacts> mFriendList = new ArrayList<Contacts>();
	
	class AddOneFollowUpLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onAddError(code, e.toString());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				int mTimerId = ((JSONObject)results).optInt("timer_id");
				mInterface.onAddSuccess(mTimerId);
			}else{
				mInterface.onAddError(responseCode, msg);
			}
		}
		
	}
	
	private AddOneFollowUpLogicHandle mHandle = new AddOneFollowUpLogicHandle();
	
	public AddOneFollowUpLogic(AddOneFollowUpLogicInterface mIn,FollowUp mFollowUp) {
		this.mInterface = mIn;
		this.mCurrentFollowUp = mFollowUp;
	}
	
	public void addFollowUp(){
		mFriendList = mCurrentFollowUp.getmFriendsList();
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("followup_name",mCurrentFollowUp.getmFolloUpTempleName());
		
		ArrayList<OnceFollowUpCycle> mArrayList = new ArrayList<OnceFollowUpCycle>();
		mArrayList = mCurrentFollowUp.getmFollowUpItemsList();
		JSONArray mArray = new JSONArray();
		for (int i = 0; i < mArrayList.size(); i++) {
			OnceFollowUpCycle mCycle = mArrayList.get(i);
			JSONObject mJsonObject = new JSONObject();
			try {
				mJsonObject.put("item_name", mCycle.getmItemName());
				mJsonObject.put("timer_date", mCycle.getmTimerDate());
				mArray.put(mJsonObject);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		map.put("followup_template_items", mArray);
		
		ArrayList<Integer>  mMemberList= new ArrayList<Integer>();
		for (int i = 0; i < mFriendList.size(); i++) {
			mMemberList.add(mFriendList.get(i).getUserId());
		}
		
		JSONArray array = new JSONArray(mMemberList);
		map.put("member_id", array);
//		map.put("member_id", mMemberList);
		
		map.put("note", mCurrentFollowUp.getmTips());
		
		JSONObject json = JsonHelper.createJsonForDebug(map);
		String url = UriConstants.Conn.URL_PUB + "/timer/add_followup.do";
		
		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}

}
