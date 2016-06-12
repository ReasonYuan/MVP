/**
  * 获取手机验证码逻辑
  * @author reason
  */
package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;
import com.google.j2objc.annotations.WeakOuter;

public class ResquestIdentfyLogic {
	
	@Weak
	public ResIdentfyCallback mInterface;
	
	public IndentHandle mHandle;
	
	public ResquestIdentfyLogic(ResIdentfyCallback inf){
		mInterface = inf;
		mHandle = new IndentHandle();
	}
	
	/**
	 * 获取手机验证码
	 * @param phoneNumber 手机号码
	 * @param type  验证码用途：1注册，2重置密码，3变更手机号
	 */
	public void reqIdentfy(String phoneNumber,int type){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("phone_number", phoneNumber);
		map.put("vertification_type", type);
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		
		String url = UriConstants.Conn.URL_PUB+"/users/get_verification_code.do";
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, mHandle);
	}
	
	@WeakOuter
	public class IndentHandle extends HalcyonHttpResponseHandle{

		@Override
		public void handle(int responseCode, String msg, int type,Object results) {
			if(responseCode == 0 && type == 1){
				String ver = ((JSONObject)results).optString("vertification");
				if(!"".equals(ver)){
					mInterface.resIdentfy(ver);
					return;
				}
			}
			mInterface.resIdentError(responseCode, msg);
		}

		@Override
		public void onError(int code,Throwable e) {
			mInterface.resIdentError(code, e.getMessage());
		}
	}
	
	public interface ResIdentfyCallback{
		public void resIdentError(int code,String msg);
		public void resIdentfy(String identfy);
	}
}
