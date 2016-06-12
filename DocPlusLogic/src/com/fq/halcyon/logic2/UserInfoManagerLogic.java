package com.fq.halcyon.logic2;

import java.util.HashMap;
import java.util.Map;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.HalyconOnLineHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class UserInfoManagerLogic {

	/**
	 *修改密码 
	 *@param oldPassword    旧密码
	 *@param newPassword  新密码
	 *@param successCallBack 成功的回调函数，为空时表示不进行回调
	 *@param failCallBack   失败的回调函数，为空时表示不进行回调
	 */
	public void changePassword(String oldPassword, String newPassword, final SuccessCallBack successCallBack, final FailCallBack failCallBack){
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("username", Constants.getUser().getPhoneNumber());
		map.put("pass_word", oldPassword);
		map.put("new_pass_word", newPassword);
		map.put("role_type", Constants.ClientConstants.ROLE_TYPE);
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
//		String url = UriConstants.Conn.URL_PUB+"/users/change_passwd.do";
		String url = UriConstants.Conn.URL_PUB+"/users/reset_password.do";
		ApiSystem.getInstance().require(url, params, API_TYPE.ONLINE, new HalyconOnLineHandle() {
			
			@Override
			public void onError(int code,Throwable e) {
				if(failCallBack != null){
					failCallBack.onFail(code, e.getMessage());
				}
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode != 0){
					if(failCallBack != null){
						failCallBack.onFail(responseCode, msg);
					}
				}else{
					if(successCallBack != null){
						successCallBack.onSuccess(responseCode, msg, type, results);
					}
				}
			}
			
			@Override
			public void saveData(boolean success) {
				// TODO Auto-generated method stub
				
			}
		});
	}
	
	/**
	 *重置密码 
	 *@param phoneNumber  用户需要重置密码的手机号
	 *@param vertification   验证码
	 *@param password       重置的密码
	 *@param successCallBack 成功的回调函数，为空时表示不进行回调
	 *@param failCallBack   失败的回调函数，为空时表示不进行回调
	 */
	public void resetPassword(String phoneNumber, String vertification, String password, final SuccessCallBack successCallBack, final FailCallBack failCallBack){
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("phone_number", phoneNumber);
		map.put("vertification", vertification);
		map.put("pass_word", password);
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		String url = UriConstants.Conn.URL_PUB+"/users/reset_password.do";
		ApiSystem.getInstance().require(url, params, API_TYPE.ONLINE, new HalyconOnLineHandle() {
			
			@Override
			public void onError(int code,Throwable e) {
				if(failCallBack != null){
					failCallBack.onFail(code, e.getMessage());
				}
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode != 0){
					if(failCallBack != null){
						failCallBack.onFail(responseCode, msg);
					}
				}else{
					if(successCallBack != null){
						successCallBack.onSuccess(responseCode, msg, type, results);
					}
				}
			}
			
			@Override
			public void saveData(boolean success) {
				// TODO Auto-generated method stub
				
			}
		});
	}
	
	/**
	 *变更手机号 
	 *@param phoneNumber  变更成为的手机号码
	 *@param vertification      验证码
	 *@param password          密码
	 *@param successCallBack 成功的回调函数，为空时表示不进行回调
	 *@param failCallBack   失败的回调函数，为空时表示不进行回调
	 */
	public void changeMobile(String phoneNumber, String vertification, String password, final SuccessCallBack successCallBack, final FailCallBack failCallBack){
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("user_id",Constants.getUser().getUserId());
		map.put("username", Constants.getUser().getPhoneNumber());
		map.put("phone_number", phoneNumber);
		map.put("vertification", vertification);
		map.put("pass_word", password);
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		String url = UriConstants.Conn.URL_PUB+"/users/change_mobile.do";
		ApiSystem.getInstance().require(url, params, API_TYPE.ONLINE, new HalyconOnLineHandle() {
			
			@Override
			public void onError(int code,Throwable e) {
				if(failCallBack != null){
					failCallBack.onFail(code, e.getMessage());
				}
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode != 0){
					if(failCallBack != null){
						failCallBack.onFail(responseCode, msg);
					}
				}else{
					if(successCallBack != null){
						successCallBack.onSuccess(responseCode, msg, type, results);
					}
				}
			}
			
			@Override
			public void saveData(boolean success) {
				// TODO Auto-generated method stub
				
			}
		});
	}
	
	/**
	 *验证手机号码是否已经被注册过了
	 *@param  phoneNumber    需要验证的手机号码
	 *@param isPhoneExistCallBack  判断手机是否已经注册的回调函数，为空时表示不进行回调
	 *@param errorCallBack 请求失败的回调函数，为空时表示不进行回调
	 */
	public void isPhoneExist(String phoneNumber, final IsPhoneExistCallBack isPhoneExistCallBack, final ErrorCallBack errorCallBack) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("phone_number", phoneNumber);
		map.put("role_type", Constants.ClientConstants.ROLE_TYPE);
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		String url = UriConstants.Conn.URL_PUB+"/users/check_mobile.do";
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code,Throwable e) {
				if(errorCallBack != null){
					errorCallBack.error(-11, e.getMessage());
				}
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				// TODO Auto-generated method stub
				if (responseCode == 0) {
					if(isPhoneExistCallBack != null){
						isPhoneExistCallBack.isPhoneExist(false);
					}
					return;
				}
				JSONObject obj = (JSONObject) results;
				if(isPhoneExistCallBack != null){
					isPhoneExistCallBack.isPhoneExist(obj.optBoolean("phone_number_exists", true));
				}
				
				
			}
		});
	}
	
	//判断手机号是否存在的回调函数
	public interface IsPhoneExistCallBack{
		public void isPhoneExist(boolean isExist);
	}
	//判断手机号请求失败的回调函数
	public interface ErrorCallBack{
		public void error(int code, String msg);
	}
	//成功的回调函数
	public interface SuccessCallBack{
		public void onSuccess(int responseCode, String msg, int type, Object results);
	}
	//失败的回调函数
	public interface FailCallBack{
		public void onFail(int code, String msg);
	};
}
