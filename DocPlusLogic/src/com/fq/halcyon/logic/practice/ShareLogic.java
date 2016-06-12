package com.fq.halcyon.logic.practice;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 相关分享的接口类。处理分享病案、记录，以及把别人分享的数据保存为自己的
 * @author reason
 */
public class ShareLogic {


	@Weak
	private ShareSavePatientCallBack mSvaePatientCallback;
	
	@Weak
	private ShareSaveRecordCallBack mSaveRecordCallback;
	
	/**
	 * 初始化接口逻辑
	 * @param callBack 保存分享的病案的回调
	 */
	public ShareLogic(ShareSavePatientCallBack callBack){
		mSvaePatientCallback = callBack;
	}
	
	/**
	 * 初始化接口逻辑
	 * @param callBack 保存分享的记录的回调
	 */
	public ShareLogic(ShareSaveRecordCallBack callBack){
		mSaveRecordCallback = callBack;
	}
	
	
	/**
	 * 保存别人分享过来的病案
	 * @param shareMsgId 分享的这条信息的标识id
	 * @param patientId 分享的病案的id
	 */
	public void saveSharedPatient(int shareMsgId, int patientId){
		JSONObject paramas = new JSONObject();
		try {
			paramas.put("user_id", Constants.getUser().getUserId());
			paramas.put("share_message_id", shareMsgId);
			paramas.put("share_patient_id", patientId);
		} catch (JSONException e) {
			FQLog.i("构造保存分享的病案请求参数出错");
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB + "/group/view_share_message_patient.do";
		FQHttpParams pars = new FQHttpParams(paramas);
		pars.setTimeoutTime(60000);
			
		ApiSystem.getInstance().require(url, pars, API_TYPE.DIRECT, new HalcyonHttpResponseHandle(){

			@Override
			public void onError(int code, Throwable e) {
				mSvaePatientCallback.shareError(code, Constants.Msg.NET_ERROR);
			}

			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
					JSONObject json = (JSONObject) results;
					mSvaePatientCallback.shareSavePatientSuccess(json.optInt("new_patient_id"));
				}else{
					mSvaePatientCallback.shareError(responseCode, msg);
				}
			}
			
		});
	}
	
	
	/**
	 * 保存别人分享过来的病历记录
	 * @param shareMsgId 分享的这条信息的标识id
	 * @param patientId 分享的病历记录的id
	 */
	public void saveSharedRecord(int shareMsgId, int recordId){
		JSONObject paramas = JsonHelper.createUserIdJson();
		try {
			paramas.put("share_message_id", shareMsgId);
			paramas.put("share_record_item_id", recordId);
		} catch (JSONException e) {
			FQLog.i("构造保存分享的病案请求参数出错");
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB + "/group/view_share_message_item.do";
		FQHttpParams pars = new FQHttpParams(paramas);
		pars.setTimeoutTime(60000);
				
		ApiSystem.getInstance().require(url, pars, API_TYPE.DIRECT, new HalcyonHttpResponseHandle(){

			@Override
			public void onError(int code, Throwable e) {
				mSaveRecordCallback.shareError(code, Constants.Msg.NET_ERROR);
			}

			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
					JSONObject json = (JSONObject) results;
					//TODO==YY==需要增加一个新的itemId的字段
					mSaveRecordCallback.shareSaveRecordSuccess(json.optInt("new_record_id"));
				}else{
					mSaveRecordCallback.shareError(responseCode, msg);
				}
			}
		});
	}
	
	
	//===========================================回调===============================================
	
	/**
	 * 保存分享的病案的回调
	 * @author reason
	 *
	 */
	public interface ShareSavePatientCallBack{
		
		/**
		 * 保存分享的病案成功
		 */
		public void shareSavePatientSuccess(int newPatientId);
		
		
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void shareError(int code,String msg);
	}
	
	/**
	 * 保存分享的病历记录的回调
	 * @author reason
	 *
	 */
	public interface ShareSaveRecordCallBack{
		/**
		 * 保存分享的病历记录成功
		 */
		public void shareSaveRecordSuccess(int newRecordId);
		
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void shareError(int code,String msg);
	}
	
}
