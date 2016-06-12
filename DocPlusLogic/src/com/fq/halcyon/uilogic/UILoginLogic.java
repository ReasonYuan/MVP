package com.fq.halcyon.uilogic;

import java.io.File;
import java.util.HashMap;

import android.util.Log;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.HalcyonUploadLooper;
import com.fq.halcyon.IOS;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic.LoginLogic;
import com.fq.halcyon.logic2.ResetDoctorInfoLogic;
import com.fq.halcyon.logic2.ResetDoctorInfoLogic.InvientCallback;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.HttpHelper;
import com.fq.lib.JsonHelper;
import com.fq.lib.callback.ICallback;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class UILoginLogic {
	private static final String TAG = UILoginLogic.class.getSimpleName();
	private LoginLogic mLoginLogic;
//	private AlarmClockLogic mAlarmClockLogic;
	
	private UILogicCallback mCallback;
	private String mPhoneNumber;
	private String mPwd;
	//private boolean mIsNetOK;
	public UILoginLogic(UILogicCallback callback){
		mCallback = callback;
	}
	public void login(boolean isHaveNet, String phoneNumber,String pwd, String clientVersion, String clientType){
		mPhoneNumber = phoneNumber;
		mPwd = pwd;
		//mIsNetOK = isHaveNet;
		if (mLoginLogic == null) {
			mLoginLogic = new LoginLogic() {
				@Override
				public void returnError(int code, String msg) {
					if (code <= 0) { // 网络错误
						mLoginLogic = null;
						mCallback.logicBack(0, 0, msg);
						//TODO 以前的离线登录机制，先注销掉
						/*String id = FileSystem.getInstance().loadIdByPhone(mPhoneNumber);
						User user = FileSystem.getInstance().loadUser(id);
						if(user.getUserId() == 0 || !mPwd.equals(user.getPassword())){
							int recode = user.getUserId() == 0?0:1;//0网络错误，1密码或用户名错误
							mLoginLogic = null;
							mCallback.logicBack(0, recode, msg);
							return;
						}
						
						Constants.setUser(FileSystem.getInstance().loadUser(id));
						Log.i(TAG, "login failed with user id: " + id + ", use user data which last login success!");
									
						FileSystem.getInstance().saveLoginUser(Constants.getUser().getPhoneNumber(), Constants.getUser().getPassword());
						checkUser();
						HalcyonUploadLooper.getInstance().stop();
						HalcyonUploadLooper.getInstance().start();
						mCallback.logicBack(1, 2, msg);*/
					} else {
						mLoginLogic = null;
						mCallback.logicBack(0, 1, msg);
						/*Intent mIntent = new Intent();
						setResult(1, mIntent);
						LoadingActivity.this.finish();*/
					}
				}

				@Override
				public void loginSucess() {
//						String id = FileSystem.getInstance().loadIdByPhone(mUserName);
//						Constants.getUser()  = null;
//						
//						Constants.getUser() = EntityUtil.FromJson(results, User.class);
//						Constants.getUser().setPassword(mPassWord);
//						FileSystem.getInstance().saveUser(Constants.getUser());
//						
//						if(Constants.getUser()  == null){
//							Constants.getUser() = FileSystem.getInstance().loadUser(id);
//						}
//					
//						String mid = Constants.getUser().getUserId()+"";
//						FileSystem.getInstance().saveLoginUser(Constants.getUser().getPhoneNumber(), Constants.getUser().getPassword());
//						FileSystem.getInstance().saveLoginList(Constants.getUser().getPhoneNumber(), mid);
						
					/*Intent mIntent = new Intent(LoadingActivity.this,MyTabActivity.class);
						startActivity(mIntent);
						HalcyonService.sendLoginMsg(Constants.getUser().getUserId());
						
						LoadingActivity.this.finish();
						if (LoginActivity.mIntance != null) {
							LoginActivity.mIntance.finish();
						}*/
						checkUser();
						HalcyonUploadLooper.getInstance().start();
						mCallback.logicBack(1, 3, "success");
						Log.e(TAG, String.format("login success with user id: %d, doctor_id: %d", Constants.getUser().getUserId(), Constants.getUser().getDoctorId()));
						
						//practice版本没有闹钟功能
//						mAlarmClockLogic = new AlarmClockLogic(new AlarmClockLogicCallBack() {
//							public void onResultCallBack(int code) {
//								mCallback.onAlarmCallback();
//							}
//							public void onErrorCallBack(int code, String msg) {}
//						});
				}
			};
		}
		mLoginLogic.autoLogin(mPhoneNumber, mPwd, clientVersion, clientType);
	}
	
	@IOS
	public interface LoginLogicListener {

		public void error(int code, String msg);
		public void isPhoneExist(boolean isExist);
	}
	
	@IOS
	@Weak
	public LoginLogicListener mListener;

	@IOS
	public void setListener(LoginLogicListener l) {
		this.mListener = l;
	}
	
	public void isPhoneExist(String phoneNumber) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("phone_number", phoneNumber);
		map.put("role_type", Constants.ClientConstants.ROLE_TYPE);
		JSONObject json = JsonHelper.createJson(map);
		String url = UriConstants.Conn.URL_PUB + "/users/check_mobile.do";
		FQHttpParams params = new FQHttpParams(json);
		HttpHelper.sendPostRequest(url, params,
				new HalcyonHttpResponseHandle() {
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode != 0) {
							if (mListener != null)
								mListener.isPhoneExist(true);
							// else {
							// isPhoneExist(true);
							// }

							return;
						}
						JSONObject obj = (JSONObject) results;
						if (mListener != null) {
							mListener.isPhoneExist(obj.optBoolean(
									"phone_number_exists", true));
						}
						// else {
						// isPhoneExist(obj.optBoolean("phone_number_exists",
						// true));
						// }
					}

					@Override
					public void onError(int code, Throwable e) {
						if (mListener != null)
							mListener.error(-11, e.getMessage());
						// else error(-11, e.getMessage());
					}
				});
	}
	
	public void checkUser(){
//		loopSwitch();
//		new TagLogic().getListAllTags(null);
		initUserHead();
//		initInvient();
		//practice版本没有医生认证功能
//		CertificationStatus.initCertification();
	}
	
	public void initInvient(){
		new ResetDoctorInfoLogic().requestInvient(new InvientCallback() {
			@Override
			public void doInvientBack(String invient) {
				Constants.getUser().setInvition(invient);
			}
		});
	}
	
	/*private void loopSwitch(){ 
        if(mIsNetOK) {
        	HalcyonUploadLooper.getInstance().start();
        }else {
        	HalcyonUploadLooper.getInstance().stop();
		}
    }*/
	
	public void initUserHead(){
		File file = new File(FileSystem.getInstance().getUserHeadPath());
		if(file.exists())return;
		User user = Constants.getUser();
		
		//==YY==imageId(只要imageId)
//		if(user == null || user.getHeadPicImageId() == 0)return;
		
		if(user == null || user.getImageId() == 0)return;
//		FileSystem filSys = FileSystem.getInstance();
//		filSys.saveBitmap2Local(user.getHeadPicImageId(), filSys.getImgCachePath(), filSys.getUserHeadName(), true);
		
		
		
//		filSys.saveBitmap2Local(Constants.getUser().getHeadPicPath(),filSys.getUserImagePath(),filSys.getUserHeadName(),false);
		Photo photo = new Photo();
		photo.setImageId(Constants.getUser().getImageId());
		//==YY==imageId(只要imageId)
//		photo.setImageId(Constants.getUser().getHeadPicImageId());
//		photo.setImagePath(Constants.getUser().getHeadPicPath());
		ApiSystem.getInstance().getHeadImage(photo, new ICallback() {
			
			@Override
			public void doCallback(Object obj) {
				System.out.println(""+obj);
				
			}
				
		}, false,1);
	}
	
	public interface UILogicCallback{
		/**
		 * @param type 0：登录失败  1：登录成功
		 * @param code 返回状态 0:网络错误  1：密码用户名错误  2：离线登录  3：在线登录
		 * @param msg  返回信息
		 */
		public void logicBack(int type,int code,String msg);
		public void onAlarmCallback();
	}
}
