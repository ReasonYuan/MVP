package com.fq.halcyon.logic;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Version;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;

public class CheckVersionLogic {

	
	/**
	 * 
	 * @param type 客户端类型 1:行医助手_andorid;2:行医助手_ios;3:健康助手_andorid;4:健康助手_ios
	 * @param currVersionCode  当前客户端版本号
	 * @param callback  访问成功后回调
	 */
	
	
	public void checkVersion(int type , final VersionCallback callback){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("client_type", type);
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		String url = UriConstants.Conn.URL_PUB+"/users/check_client_version.do";
//		String url = "http://115.29.232.44:8080/yiyiuat/users/check_client_version.do"; 测试环境
		
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			public void onError(int code, Throwable e) {
				callback.call(null);
			}
			
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0 && type == 1){
					Version version = new Version();
					version.setAtttributeByjson((JSONObject)results);
					if(version.getVersionCode() > 0){
						callback.call(version);
						return;
					}
				}
				callback.call(null);
			}
		});
	}
	
	public interface VersionCallback{
		public void call(Version version);
	}
}
