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

public class AddOrRefuseFriendLogic {
	public interface AddOrRefuseFriendLogicInterface extends FQHttpResponseInterface{
		public void onDataReturn();
		public void onError(int code, Throwable e);
	}
	
	@Weak
	public AddOrRefuseFriendLogicInterface mInterface;
	
	public class AddOrRefuseFriendLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onError(code, e);
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				mInterface.onDataReturn();
			}else{
				mInterface.onError(responseCode,new Throwable(msg));
			}
		}
	}
	
	public AddOrRefuseFriendLogicHandle mHandle = new AddOrRefuseFriendLogicHandle();
	
	/**
	 *@param friendstatus:</br>
	 *0 等待处理</br>
	 *1 表示同意医生/医学生 与 医生/医学生间的关系</br>
	 *2 表示同意 医生与患者免费的朋友关系；</br>        
	 *3 表示同意 医生与患者收费的朋友关系</br>
	 *4 拒绝
	 * @param mIn                回调
	 * @param userId             
	 * @param friendId				
	 * @param friend_roteType	 朋友的类型
	 * @param agreed			 是否同意
	 * @param isFree             如果是病人，是否免费
	 */
	public AddOrRefuseFriendLogic(AddOrRefuseFriendLogicInterface mIn,int userId,int friendId,int friend_roteType,int relationId,boolean agreed,boolean isFree,boolean isDel){
		this.mInterface = mIn;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", userId);
		map.put("friend_id_to_add", friendId);
		map.put("user_doctor_relation_id", relationId);
		if(agreed){
			switch (friend_roteType) {
			case 1://医生
			case 2://医学生
				map.put("friendstatus", 1);
				break;
			case 3://病人
				if(isFree){
					map.put("friendstatus", 2);
				}else {
					map.put("friendstatus", 3);
				}
				break;
			default:
				break;
			}
		}else {
			if(isDel){
				map.put("friendstatus", 11);
			}else {
				map.put("friendstatus", 4);
			}
		}
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/users/doctor_agree_add_friend.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
}
