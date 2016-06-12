package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.ScoreDetail;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 *获取积分变动详情的logic 
 */
public class ExpenseDetailLogic {

	
	private List<ScoreDetail> mDetailList = new ArrayList<ScoreDetail>();
	
	public interface ExpenseDetailLogicCallBack{
		public void onErrorCallBack(int code,String msg);
		public void onResultCallBack(int code, List<ScoreDetail> mDetailList);
	}
	
	@Weak
	public ExpenseDetailLogicCallBack onCallBack;
	
	/**
	 *@param page</br>第多少页
	 *@param pageSize</br>每页多少条 
	 */
	public ExpenseDetailLogic(int page, int pageSize, final ExpenseDetailLogicCallBack onCallBack) {
		this.onCallBack = onCallBack;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("doctor_id", Constants.getUser().getDoctorId());
		map.put("page", page);
		map.put("page_size", pageSize);
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/doctors/getDpList.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	public class ExpenseDetailLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.onErrorCallBack(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0 && type == 2){
				JSONArray jsonArray = (JSONArray) results;
				int count = jsonArray.length();
				for (int i = 0; i < count; i++) {
					try {
						ScoreDetail mDetail = new ScoreDetail();
						mDetail.setAtttributeByjson(jsonArray.getJSONObject(i));
						mDetailList.add(mDetail);
					} catch (JSONException e) {
						e.printStackTrace();
					}
				}
				onCallBack.onResultCallBack(responseCode, mDetailList);
			}
		}
	}
	
	public ExpenseDetailLogicHandle mHandle = new ExpenseDetailLogicHandle();
}
