package com.fq.halcyon.logic;

import java.util.HashMap;

import android.util.Log;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.FQHeader;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;


public abstract class LoginLogic{
	private String mUserName;
	private String mPassWord;

	public interface LoginLogicInterface{
		public void onDataReturn(int code,String msg);
		public void onDataError(int code,String msg);
	}

	@Weak
	public LoginLogicInterface mInterface;
	/*@IOS
	public void iosLogin(LoginLogicInterface mIn,final String name,final String password){
		mInterface = mIn;
		HashMap<String, Object> mMap = new HashMap<String, Object>();
		mMap.put("username", name);
		mMap.put("pass_word", password);
		
		JSONObject mRegisterJson = JsonHelper.createJson(mMap);
		FQHttpParams mFqHttpParams = new FQHttpParams(mRegisterJson);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB +"/users/login.do",mFqHttpParams,API_TYPE.DIRECT, 
				 new HalcyonHttpResponseHandle() {
					@Override
					public void onError(int code, Throwable e) {
						mInterface.onDataError(code, e.getMessage());
					}

					@Override
					public void handle(int responseCode, final String msg,
							int type, Object results) {
						if (responseCode != 0) {
							mInterface.onDataError(responseCode, msg);
							return;
						}
						JSONObject mJsonObject = (JSONObject) results;
						
						String id = FileSystem.getInstance().loadIdByPhone(name);
						Constants.setUser(new User());//EntityUtil.FromJson(mJsonObject, User.class);
						Constants.getUser().setAtttributeByjson(mJsonObject);
						Constants.getUser().setPassword(password);
						FileSystem.getInstance().saveUser(Constants.getUser());
						
						if(Constants.getUser()  == null){
							Constants.setUser(FileSystem.getInstance().loadUser(id));
						}
					
						String mid = Constants.getUser().getUserId()+"";
						FileSystem.getInstance().saveLoginUser(Constants.getUser().getPhoneNumber(), Constants.getUser().getPassword());
						FileSystem.getInstance().saveLoginList(Constants.getUser().getPhoneNumber(), mid);
						mInterface.onDataReturn(responseCode, msg);
					}
				});
	}*/
	
	public void autoLogin(final String name,final String password, final String clientVersion, final String clientType) {
		
		HashMap<String, Object> mMap = new HashMap<String, Object>();
		mMap.put("username", name);
		mMap.put("pass_word", password);
		mMap.put("role_type", Constants.ClientConstants.ROLE_TYPE);
		
		JSONObject mRegisterJson = JsonHelper.createJson(mMap);
		FQHttpParams mFqHttpParams = new FQHttpParams(mRegisterJson);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB +"/users/login.do",mFqHttpParams,API_TYPE.DIRECT, 
				 new HalcyonHttpResponseHandle() {
			
					@Override
					public FQHeader[] getRequestHeaders() {
						FQHeader[] fqHeaders = new FQHeader[2];
						fqHeaders[0] = new FQHeader("client_type", clientType);
						fqHeaders[1] = new FQHeader("client_version", clientVersion);
						return fqHeaders;
					}
			
					@Override
					public void onError(int code, Throwable e) {
						returnError(code,"网络错误");
					}

					@Override
					public void handle(int responseCode, final String msg,
							int type, Object results) {
						if (responseCode != 0) {
							returnError(responseCode, msg);
							return;
						}
						
						JSONObject mJsonObject = (JSONObject) results;
						String mKey = mJsonObject.optString("client_salt");
						if (!mKey.equals("")) {
							Constants.KEY_STRING = mKey.getBytes();
						}
						
//						String id = FileSystem.getInstance().loadIdByPhone(name);
						
						User user = new User();
						user.setAtttributeByjson(mJsonObject);
						user.setPassword(password);
						Constants.setUser(user);
						
						if (!Constants.isVisitor) {
							FileSystem.getInstance().saveUser(user);
							
							//如果登录成功，是不会出现为空的这种情况
//							if(Constants.getUser()  == null){
//								Constants.setUser(FileSystem.getInstance().loadUser(id));
//							}
						
							int id = Constants.getUser().getUserId();
							FileSystem.getInstance().saveLoginUser(Constants.getUser().getPhoneNumber(), Constants.getUser().getPassword(),id);
//							FileSystem.getInstance().saveLoginList(Constants.getUser().getPhoneNumber(), mid); 不需要离线机制
							Log.e("~~~user_id", id+"");
						}
						
						loginSucess();
					}
				});
	}

	public HashMap<String, Object> creatJsonMap() {
		HashMap<String, Object> mMap = new HashMap<String, Object>();
		mMap.put("username", mUserName);
		mMap.put("pass_word", mPassWord);
		return mMap;
	}

	public abstract void loginSucess();
	public abstract void returnError(int code, String msg);
}
