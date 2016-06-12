package com.fq.halcyon.logic;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.IOS;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.UserAction;
import com.fq.http.async.FQHeader;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.HttpHelper;
import com.fq.lib.JsonHelper;
import com.fq.lib.UserActionManger;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.DES3Utils;
import com.fq.lib.tools.AeSimpleSHA1;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public abstract class RegisterLogic {
	
	@IOS
	public interface RegisterLogicListener{
		public void returnData(int responseCode, JSONObject results);
		public void error(int code, String msg);
		public void isPhoneExist(boolean isExist);
	}
	
	@IOS
	@Weak
	public RegisterLogicListener mListener;
	
	@IOS
	public void setListener(RegisterLogicListener l){
		this.mListener = l;
	}
	
	public RegisterLogic() {
	}
	
	
	/**
	 * 用户注册时传入参数注册
	 * @param roleType  用户类型：医生 或 大众
	 * @param mPhoneNumber 注册手机号
	 * @param mPassword 注册密码
	 * @param vertification 注册验证码
	 * @param invite 注册邀请码
	 */
	@IOS
	public void register( int roleType,String mPhoneNumber, String mPassword,String vertification,String invite, final String clientVersion, final String clientType) {
		String key =DES3Utils.randomString(24);
		Constants.KEY_STRING = key.getBytes();
		
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("role_type",roleType);
		map.put("phone_number", mPhoneNumber);
		map.put("pass_word", AeSimpleSHA1.repeat20TimesAndSHA1(mPassword));
		map.put("vertification", vertification);
		map.put("client_salt",key);
		if(!"".equals(invite))map.put("invitation_code", invite);
		
		JSONObject mRegisterJson = JsonHelper.createJson(map);
		
		register(mRegisterJson, clientVersion, clientType);
	}

	public void register(JSONObject mRegisterJson, final String clientVersion, final String clientType) {
		FQHttpParams mFqHttpParams = new FQHttpParams(mRegisterJson);
		
		String url = UriConstants.Conn.URL_PUB+"/users/register.do";
		ApiSystem.getInstance().require(url, mFqHttpParams, API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			@Override
			public FQHeader[] getRequestHeaders() {
				FQHeader[] fqHeaders = new FQHeader[2];
				fqHeaders[0] = new FQHeader("client_type", clientType);
				fqHeaders[1] = new FQHeader("client_version", clientVersion);
				return fqHeaders;
			}
			public void onError(int code,Throwable e) {
				if(mListener != null)mListener.error(code, e.getMessage());
				//else error(code, e.getMessage());
			}

			public void handle(int responseCode, String msg, int type,
					Object results) {
				if (responseCode != 0) {
					if(mListener != null)mListener.error(responseCode, msg);
					return;
				}
				if(mListener != null) mListener.returnData(responseCode, (JSONObject) results);

				UserAction action = new UserAction(System.currentTimeMillis(),UserAction.ACTION_REGIST,"开始医加...");
				UserActionManger.getInstance().addAction(action);
			}
		});
	}

	public void isPhoneExist(String phoneNumber) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("phone_number", phoneNumber);
		map.put("role_type", Constants.ClientConstants.ROLE_TYPE);
		JSONObject json = JsonHelper.createJson(map);
        String url = UriConstants.Conn.URL_PUB + "/users/check_mobile.do";
        FQHttpParams params = new FQHttpParams(json);
		HttpHelper.sendPostRequest(url,params, new HalcyonHttpResponseHandle() {
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if (responseCode != 0) {
					if(mListener != null)mListener.isPhoneExist(true);
//					else {
//						isPhoneExist(true);
//					}
					
					return;
				}
				JSONObject obj = (JSONObject) results;
				if(mListener != null)
                {
                    mListener.isPhoneExist(obj.optBoolean("phone_number_exists", true));
                }
//				else {
//					isPhoneExist(obj.optBoolean("phone_number_exists", true));
//				}
			}

			@Override
			public void onError(int code,Throwable e) {
				if(mListener != null)mListener.error(-11, e.getMessage());
				//else error(-11, e.getMessage());
			}
		});
	}

//	public HashMap<String, Object> creatJsonMap() {
//		HashMap<String, Object> mMap = new HashMap<String, Object>();
//		mMap.put("username", mPhoneNumber);
//		mMap.put("pass_word", mPassword);
//		mMap.put("nickname", "");
//		mMap.put("name", name);
//		mMap.put("phone_number", mPhoneNumber);
//		mMap.put("role_type", roleType);
//		mMap.put("department_id", departmentId);
//		mMap.put("create_type", create_type);
//		mMap.put("description", description);
//		mMap.put("gender", gender);
//		mMap.put("hospital_id", mHospital.getHospitalId());
//		mMap.put("department_name", mDepartment.getName());
//		return mMap;
//	}

//	public abstract void returnData(int responseCode, JSONObject results);
//
//	public abstract void error(int code, String msg);
//
//	public abstract void isPhoneExist(boolean isExist);
}
