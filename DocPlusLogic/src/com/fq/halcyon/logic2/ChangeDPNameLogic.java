package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class ChangeDPNameLogic {
	
	public void changeDPName(String name,final ChangeDPNameCallback callback){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("dp_name", name);
		JSONObject json = JsonHelper.createJson(map);
		
		String url = UriConstants.Conn.URL_PUB+"/users/set_dp_name.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				callback.feedChangeDPName(false,"医家号已经存在");
			}

			@Override
			public void handle(int responseCode, String msg, int type,Object results) {
				callback.feedChangeDPName(responseCode==0,msg);
			}
			
		});
		
	}
	
	public interface ChangeDPNameCallback extends FQHttpResponseInterface {
		public void feedChangeDPName(boolean isSuccess,String msg);
	}
}
