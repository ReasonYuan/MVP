package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Contacts;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class GetAddingFriendsListLogic {
	public interface GetAddingFriendsListLogicInterface extends FQHttpResponseInterface{
		public void onDataReturn(ArrayList<Contacts> mFriendsListReq,ArrayList<Contacts> mFriendsListRsp);
		public void onError(int code, Throwable e);
	}
	
	@Weak
	public GetAddingFriendsListLogicInterface mInterface;
	private ArrayList<Contacts> mFriendsListReq;
	private ArrayList<Contacts> mFriendsListRsp;
	
	public class GetAddingFriendsListLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onError(code, e);
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			mFriendsListReq = new ArrayList<Contacts>();
			mFriendsListRsp = new ArrayList<Contacts>();
			JSONArray mArrayReq = ((JSONObject)results).optJSONArray("req");
			JSONArray mArrayRsp = ((JSONObject)results).optJSONArray("resp");
			if(responseCode == 0 && type == 1){
				for(int i =0;i<mArrayReq.length();i++ ){
					Contacts mUser = new Contacts();
					JSONObject mJsonObject = mArrayReq.optJSONObject(i);
					mUser.setAtttributeByjson(mJsonObject);
					mFriendsListReq.add(mUser);
				}
				for(int i =0;i<mArrayRsp.length();i++ ){
					Contacts mUser = new Contacts();
					JSONObject mJsonObject = mArrayRsp.optJSONObject(i);
					mUser.setAtttributeByjson(mJsonObject);
					mFriendsListRsp.add(mUser);
				}
				mInterface.onDataReturn(mFriendsListReq,mFriendsListRsp);
			}else{
				mInterface.onError(responseCode, new Throwable(msg));
			}
		}
		
	}
	
	public GetAddingFriendsListLogicHandle mHandle = new GetAddingFriendsListLogicHandle();
	
	public GetAddingFriendsListLogic(GetAddingFriendsListLogicInterface mIn,int userId){
		this.mInterface = mIn;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", userId);
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/users/friends/adding_status/list.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
}
