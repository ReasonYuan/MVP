package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 *为某条提醒留言 
 *@create 2014/11/25
 *陪伴是最长情的告白
 */
public class PostRemarkLogic {
	
	
	public interface PostRemarkLogicCallBack{
		public void onErrorCallBack(int code , String msg);
		public void onSuccessCallBack(int code, String msg);
	}

	@Weak
	public PostRemarkLogicCallBack onCallBack;
	
	/**
	 * @param timerId</br>提醒的ID
	 *@param remark</br>留言内容 
	 */
	public PostRemarkLogic(int timerId, String remark, final PostRemarkLogicCallBack onCallBack) {
		this.onCallBack = onCallBack;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("timer_id", timerId);
		map.put("remark", remark);
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/timer/post.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	public class PostRemarkLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			e.printStackTrace();
			onCallBack.onErrorCallBack(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				onCallBack.onSuccessCallBack(responseCode, msg);
			}
		}
	}
	
	public PostRemarkLogicHandle mHandle = new PostRemarkLogicHandle();
}
