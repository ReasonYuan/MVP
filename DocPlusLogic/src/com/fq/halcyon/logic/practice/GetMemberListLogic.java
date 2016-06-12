package com.fq.halcyon.logic.practice;

import java.util.ArrayList;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.MyRelationship;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class GetMemberListLogic {

	@Weak
	private GetMemberListCallBack mCallBack;
	
	private ArrayList<MyRelationship> memberList;
	
	public interface GetMemberListCallBack {
		public void getMemberListSuccess(ArrayList<MyRelationship> memberList);
		public void getMemberListError(int errorCode,String msg);
	}
	
	public GetMemberListLogic(GetMemberListCallBack callBack) {
		this.mCallBack = callBack;
		memberList = new ArrayList<MyRelationship>();
	}
	
	public void getMemberList(int userId){
		String url = UriConstants.Conn.URL_PUB + "/home/get_profile_member.do";
		JSONObject params = new JSONObject();
		try {
			params.put("user_id", userId);
		} catch (JSONException e) {
			FQLog.i("构建含有用户id的json数据时出错");
			e.printStackTrace();
		}
		ApiSystem.getInstance().require(url, new FQHttpParams(params),  API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				mCallBack.getMemberListError(code, e.getMessage());
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0 && type == 2){
					JSONArray jsonArray = (JSONArray) results;
					int count = jsonArray.length();
					for (int i = 0; i < count; i++) {
						JSONObject json = jsonArray.optJSONObject(i);
						MyRelationship item = new MyRelationship();
						item.setAtttributeByjson(json);
						memberList.add(item);
					}
					mCallBack.getMemberListSuccess(memberList);
				}else{
					mCallBack.getMemberListError(responseCode, msg);
				}
			}
		});
	}
}
