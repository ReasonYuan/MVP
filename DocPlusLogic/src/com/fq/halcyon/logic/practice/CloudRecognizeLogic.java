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
 * 云识别相关的接口
 * @author reason
 */
public class CloudRecognizeLogic {

	@Weak
	private ApplyRecognizeCallBack mApplyCallback;
	
	public CloudRecognizeLogic(ApplyRecognizeCallBack callback){
		mApplyCallback = callback;
	}
	
	/**
	 * 请求服务器对病历记录进行云识别
	 */
	public void applyRecognize(int recordItemId){
		JSONObject params = JsonHelper.createUserIdJson();
		
		try {
			params.put("record_item_id", recordItemId);
		} catch (JSONException e) {
			FQLog.i("构建对病历记录云识别的请求参数出错");
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB + "/record/item/get_anticipate_time.do";
		FQLog.i("====接口:申请对病历进行云识别，请求url:"+url);
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mApplyCallback.applyError(code, Constants.Msg.NET_ERROR);
			}

			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
					mApplyCallback.applyRecognizeSuccess();
				}else{
					mApplyCallback.applyError(responseCode, msg);
				}
			}
		});
	}
	
	public interface ApplyRecognizeCallBack{
		/**
		 * 接口访问成功的回调方法。
		 * @param keys 列表以时间为参照组装成的Map的所有key的集合。
		 * @param map 列表以时间为参照组装成的Map。
		 */
		public void applyRecognizeSuccess();
		
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void applyError(int code,String msg);
	}
	
	public interface CloudRecognizeCallBack{
		/**
		 * 接口访问成功的回调方法。
		 * @param keys 列表以时间为参照组装成的Map的所有key的集合。
		 * @param map 列表以时间为参照组装成的Map。
		 */
		public void applyRecognizeSuccess();
		
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void applyError(int code,String msg);
	}
	
}
