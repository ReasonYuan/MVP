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
import com.google.j2objc.annotations.Weak;

public class AnnualFreeLogic {
	
	public interface AnnualFreeLogicInterface extends FQHttpResponseInterface{
		public void onDataReturn(int responseCode, String msg);
		public void onError(int code, Throwable e);
	}
	
	@Weak
	public AnnualFreeLogicInterface mInterface;
	
	public class AnnualFreeLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onError(code, e);
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				//JSONObject mObject = (JSONObject)results;
//				Object result = results;
				mInterface.onDataReturn(responseCode,msg);
			}
		}

	}
	
	public AnnualFreeLogicHandle mHandle = new AnnualFreeLogicHandle();
	
	public AnnualFreeLogic(AnnualFreeLogicInterface mIn,int price){
		this.mInterface = mIn;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("annual_fee", price);
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/users/set_annual_fee.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
}
