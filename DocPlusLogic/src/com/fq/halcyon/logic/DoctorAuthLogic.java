package com.fq.halcyon.logic;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.HalyconOnLineHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.CertificationStatus;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.HttpHelper;
import com.fq.lib.JsonHelper;
import com.fq.lib.UploadImageHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class DoctorAuthLogic {

	private class AuthImgType{
		int type;
		int id;
		
		public AuthImgType(int type,int id){
			this.type = type;
			this.id = id;
		}
	}
	
	private ArrayList<AuthImgType> mAuthImgsTypes;
	
	@Weak
	private OnRequestAuthCallback mAuthCallback;
	private UploadAuthImageHandle[] mUploadImgHandlers;
	private ModifyProfileHandle mProfileHandle;
	private ApplyAuthHandle mApplyHandle;
	private ArrayList<Integer> mTypes;
	private boolean mAuthError;
	private int mCount;
	
	/**
	 * 申请认证
	 */
	public void applyAuth(ArrayList<Integer> types,OnRequestAuthCallback callback){
		//CertificationStatus.getInstance().setState(CertificationStatus.CERTIFICATION_APPROVING);
		mTypes = types;
		if(mTypes.size() == 0)return;
		mAuthCallback = callback;
		upLoadAuthImgs();
	}

	/**
	 * 上传医生认证照片
	 */
	private void upLoadAuthImgs(){
		mCount = 0;
		mAuthError = false;
		mAuthImgsTypes = new ArrayList<AuthImgType>(mTypes.size());
		mUploadImgHandlers = new UploadAuthImageHandle[mTypes.size()];
		FileSystem filsys = FileSystem.getInstance();
		for(int i = 0; i < mTypes.size(); i++){
			mUploadImgHandlers[i] = new UploadAuthImageHandle(mTypes.get(i));
			String name = filsys.getAuthImgNameByType(mTypes.get(i));
			String path = filsys.getUserImagePath()+name;
			if(new File(path).exists()){
				UploadImageHelper.upLoadImgUnOCR(path, mUploadImgHandlers[i]);
			}else{
				mAuthCallback.onFileLost();
				mAuthError = true;
				break;
			}
		}
	}
	
	public interface OnRequestAuthCallback{
		public void onFileLost();
		public void onAuthFail(int code,String msg);
		public void onAuthSuccess();
	}
	
	public interface OnRequestAuthStateCallback{
		public void feedRequest(CertificationStatus certif);
	}
	
	/**
	 *上传医生认证照片回调
	 */
	public class UploadAuthImageHandle extends HalcyonHttpResponseHandle{
		int mType;
		public UploadAuthImageHandle(int type){
			mType = type;
		}
		
		@Override
		public void handle(int responseCode, String msg, int type,Object results) {
			if(responseCode == 0 && type == 1){
				int id = ((JSONObject)results).optInt("image_id");
				if(id != 0){
					AuthImgType imgs = new AuthImgType(mType,id);
					mAuthImgsTypes.add(imgs);
				}
			}
			mCount++;
			if(!mAuthError&&mCount == mTypes.size())modifyProfile();
		}
		
		@Override
		public void onError(int code,Throwable e) {
			if(mCount != 10){
				mCount = 10;
				//CertificationStatus.getInstance().setState(CertificationStatus.CERTIFICATION_NOT_PASS);
				mAuthCallback.onAuthFail(2,"上传图片失败，网络未连接或网络不稳定");
			}
		}
	}
	
	/**
	 * 上传图片完成后，修改医生信息
	 */
	private void modifyProfile(){
		if(mCount != mTypes.size())return;
		if(mAuthImgsTypes.size() < mTypes.size()){
			CertificationStatus.getInstance().setState(CertificationStatus.CERTIFICATION_NOT_PASS);
			mAuthCallback.onAuthFail(2,"上传认证图片失败");
			return;
		}
		
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		
		JSONArray cerArray = new JSONArray();
		
		for(int i = 0; i < mAuthImgsTypes.size(); i++){
			AuthImgType imgType = mAuthImgsTypes.get(i);
			JSONObject json = new JSONObject();
			try {
				/*AuthImage img = CertificationStatus.getInstance().getAuthImageByType(imgType.type);
				if(img != null && img.doctorCertiId != 0){
					json.put("doctor_certi_id", img.doctorCertiId);
				}*/
				json.put("image_id", imgType.id);
				json.put("certi_type", imgType.type);
				cerArray.put(json);
			} catch (JSONException e) {
				e.printStackTrace();
			}	
		}	
		
		map.put("certis", cerArray);
		
		mProfileHandle = new ModifyProfileHandle();
		String url = UriConstants.Conn.URL_PUB+"/doctors/modify_doctor_profile.do";
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
			
		HttpHelper.sendPostRequest(url, params, mProfileHandle);
	}
	
	public class ModifyProfileHandle extends HalcyonHttpResponseHandle{

		@Override
		public void handle(int responseCode, String msg, int type,Object results) {
			if(responseCode == 0){
				applyAuth();
			}else{
				CertificationStatus.getInstance().setState(CertificationStatus.CERTIFICATION_NOT_PASS);
				mAuthCallback.onAuthFail(2,"申请认证失败");
			}
		}

		@Override
		public void onError(int code,Throwable e) {
			CertificationStatus.getInstance().setState(CertificationStatus.CERTIFICATION_NOT_PASS);
			mAuthCallback.onAuthFail(2,"申请认证失败");
		}
	}
	
	/**
	 * 修改所有认证信息完成，申请医生认证
	 */
	private void applyAuth(){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		
		String url = UriConstants.Conn.URL_PUB+"/doctors/apply_auth.do";
		if(Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR_STUDENT){
			url = UriConstants.Conn.URL_PUB+"/doctors/app_doctor_student_auth.do";
		}
		
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		mApplyHandle = new ApplyAuthHandle();
		ApiSystem.getInstance().require(url, params, API_TYPE.ONLINE, mApplyHandle);
	}
	
	public class ApplyAuthHandle extends HalyconOnLineHandle{
		@Override
		public void saveData(boolean success) {
			//先进入handle 再进入 这个方法
		}

		@Override
		public void handle(int responseCode, String msg, int type,Object results){
			if(responseCode == 0 && type == 1){
				int te = ((JSONObject)results).optInt("auth_status");
				CertificationStatus.getInstance().setState(te);
				mAuthCallback.onAuthSuccess();
			}else{
				mAuthCallback.onAuthFail(2,"申请认证失败");
			}
		}

		@Override
		public void onError(int code,Throwable e) {
			if(code == 1){
				//CertificationStatus.getInstance().setState(CertificationStatus.CERTIFICATION_APPROVING);
				mAuthCallback.onAuthFail(1,"申请认证失败");
			}else{
				//CertificationStatus.getInstance().setState(CertificationStatus.CERTIFICATION_NOT_PASS);
				mAuthCallback.onAuthFail(2,"申请认证失败");
			}
		}
	}
	
	/*private void applyAuthFail(String msg){
		CertificationStatus.getInstance().setState(CertificationStatus.CERTIFICATION_NOT_PASS);
		mAuthCallback.onAuthFail(2, msg);
	}*/
	
	/**
	 * 请求医生认证状态
	 * @param callback
	 */
	public void requestAuthState(final OnRequestAuthStateCallback callback){
		//mFeedRequestInf = inf;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		JSONObject json = JsonHelper.createJson(map);
		String url = UriConstants.Conn.URL_PUB+"/doctors/get_doctor_auth.do";
		if(Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR_STUDENT)url = UriConstants.Conn.URL_PUB+"/doctors/get_doctor_student_auth.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(json),API_TYPE.BROW, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code,Throwable e) {
				FQLog.i("~~~","error:"+e);
				callback.feedRequest(null);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode != 0){
					callback.feedRequest(null);
				}else{
					callback.feedRequest(CertificationStatus.initByJson((JSONObject) results));
				}
			}
		});
	}
}
