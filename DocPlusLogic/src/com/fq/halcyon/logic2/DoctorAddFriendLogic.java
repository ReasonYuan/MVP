package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class DoctorAddFriendLogic {
	
	public static final int FRIEND_FROM_NORMAL = 1;//账号添加
	
	public static final int FRIEND_FROM_ZXING = 2;//二维码添加
	
	public interface DoctorAddFriendLogicInterface extends FQHttpResponseInterface{
		public void onDataReturn();
		public void onError(int code, Throwable e);
	}
	
	@Weak
	public DoctorAddFriendLogicInterface mInterface;
	
	public class DoctorAddFriendLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onError(code, e);
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				mInterface.onDataReturn();
			}else {
				mInterface.onError(responseCode, new Throwable(msg));
			}
			
		}
		
	}
	
	public DoctorAddFriendLogicHandle mHandle = new DoctorAddFriendLogicHandle();
	
//	public DoctorAddFriendLogic(DoctorAddFriendLogicInterface mIn,int userId,int friendId,int type){
//		this.mInterface = mIn;
//		HashMap<String, Object> map = new HashMap<String, Object>();
//		map.put("user_id", userId);
//		map.put("friend_id_to_add", friendId);
//		map.put("type", type);
//		JSONObject json = JsonHelper.createJson(map);
//		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/users/doctor_add_friend.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
//	}
	
	public DoctorAddFriendLogic(DoctorAddFriendLogicInterface mIn,int userId,int friendId,int type,String requestMessage){
		this.mInterface = mIn;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", userId);
		map.put("friend_id_to_add", friendId);
		map.put("type", type);
		map.put("request_message", requestMessage);
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/users/doctor_add_friend.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
}
