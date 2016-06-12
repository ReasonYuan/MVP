package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.FollowUpTemple;
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

public class OperateFollowUpTempleLogic {
	private FollowUpTemple mFollowUpTemple;
	
	public interface OperateFollowUpTempleLogicInterface extends FQHttpResponseInterface{
		public  void onDataError(int code,String msg);
		public void onDataReturn();
	}
	
	@Weak
	private OperateFollowUpTempleLogicInterface mInterface;
	class OperateFollowUpTempleLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onDataError(code, e.toString());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				mInterface.onDataReturn();
			}else{
				mInterface.onDataError(responseCode, msg);
			}
		}
		
	}
	
	private OperateFollowUpTempleLogicHandle mHandle = new OperateFollowUpTempleLogicHandle();
	
	public OperateFollowUpTempleLogic(OperateFollowUpTempleLogicInterface mIn,FollowUpTemple followUpTemple) {
		this.mInterface = mIn;
		this.mFollowUpTemple =  followUpTemple;
	}

	public void CreateFollowUPTemple(){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("followup_template_name", mFollowUpTemple.getTempleName());
		ArrayList<OnceFollowUpCycle> mArrayList = new ArrayList<OnceFollowUpCycle>();
		mArrayList = mFollowUpTemple.getmArrayList();
		JSONArray mArray = new JSONArray();
		for (int i = 0; i < mArrayList.size(); i++) {
			OnceFollowUpCycle mCycle = mArrayList.get(i);
			JSONObject mJsonObject = new JSONObject();
			try {
				mJsonObject.put("item_name", mCycle.getmItemName());
				mJsonObject.put("item_value", mCycle.getmItentValue());
				mJsonObject.put("item_unit", mCycle.getmItemUnit());
				mArray.put(mJsonObject);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		map.put("followup_template_items", mArray);
		JSONObject json = JsonHelper.createJsonForDebug(map);
		System.out.println("----------------"+json.toString());
		String url = UriConstants.Conn.URL_PUB + "/timer/add_followup_template.do";

		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	public void ModifyFollowUpTemple(){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("followup_template_name", mFollowUpTemple.getTempleName());
		map.put("followup_template_id", mFollowUpTemple.getmTempleId());
		ArrayList<OnceFollowUpCycle> mArrayList = new ArrayList<OnceFollowUpCycle>();
		mArrayList = mFollowUpTemple.getmArrayList();
		JSONArray mArray = new JSONArray();
		for (int i = 0; i < mArrayList.size(); i++) {
			OnceFollowUpCycle mCycle = mArrayList.get(i);
			JSONObject mJsonObject = new JSONObject();
			try {
				mJsonObject.put("item_name", mCycle.getmItemName());
				mJsonObject.put("item_value", mCycle.getmItentValue());
				mJsonObject.put("item_unit", mCycle.getmItemUnit());
				//没有itemId表示新增
				if (mCycle.getmItemtId() != 0) {
					mJsonObject.put("item_id", mCycle.getmItemtId());
				}
				
				mArray.put(mJsonObject);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		map.put("followup_template_items", mArray);
		JSONObject json = JsonHelper.createJsonForDebug(map);
		System.out.println("----------------"+json.toString());
		String url = UriConstants.Conn.URL_PUB + "/timer/modify_followup_template.do";
		
		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
}
