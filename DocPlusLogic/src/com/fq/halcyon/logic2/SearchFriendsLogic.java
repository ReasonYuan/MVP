package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Contacts;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class SearchFriendsLogic {
	
	private List<Contacts> mUserList = new ArrayList<Contacts>();
	
	public interface SearchFriendsLogicInterface extends FQHttpResponseInterface{
		public void onDataReturn(List<Contacts> mUserList);
		public void onError(int code, Throwable e);
	}
	
	@Weak
	public SearchFriendsLogicInterface mInterface;
	
	public class SearchFriendsLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onError(code, e);
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				JSONArray jsonArray = (JSONArray) results;
				int count = jsonArray.length();
				for(int i = 0; i < count ; i++){
					JSONObject jsonObj;
					try {
						jsonObj = jsonArray.getJSONObject(i);
						Contacts user = new Contacts();
						user.setAtttributeByjson(jsonObj);
						mUserList.add(user);
					} catch (JSONException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
				mInterface.onDataReturn(mUserList);
			}
		}
		
	}
	
	public SearchFriendsLogicHandle mHandle = new SearchFriendsLogicHandle();
	
	public SearchFriendsLogic(SearchFriendsLogicInterface mIn,int userId,String keyWords,int page,int pagesize,boolean isNewFriend){
		this.mInterface = mIn;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", userId);
		map.put("key_words", keyWords);
		map.put("page", page);
		map.put("page_size", pagesize);
		JSONObject json = JsonHelper.createJson(map);
		if(isNewFriend){
			ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/users/doctor_search_friends.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
		}else{
			ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/users/doctor_search_infriends_list.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
		}
	}
}
