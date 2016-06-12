package com.fq.halcyon.practice;

import java.util.ArrayList;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

 public class GetChartLogic {

	public interface GetSexChartInterface {
		public void onGetSexError(int code, String msg);
		public void onGetSexSuccess(int totalCount, ArrayList<String> titles, ArrayList<Integer> values);
	}


	private GetSexChartInterface sexChartInterface;
	/**
	 * 获取性别图表分布
	 * 
	 * @param conditions
	 */
	public void getSexChart(ArrayList<Integer> patientIds,boolean isFromHome,GetSexChartInterface mIn) {
		this.sexChartInterface = mIn;
		JSONObject params = new JSONObject();
		try {
			params.put("user_id", Constants.getUser().getUserId());
			if (!isFromHome) {
				JSONArray array = new JSONArray(patientIds);
				params.put("patient_ids", array);
			}
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		String url = UriConstants.Conn.URL_PUB
				+ "/home/get_patient_gender_count.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(params),
				API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						sexChartInterface.onGetSexError(code, e.getMessage());
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							try {
								JSONObject obj = new JSONObject(results
										.toString());
								int patientCount = obj
										.optInt("total_patient_count");
								JSONArray array = obj
										.optJSONArray("gender_scope_count");
								
								
								ArrayList<String> titles = new ArrayList<String>();
								ArrayList<Integer> values = new ArrayList<Integer>();
								for (int i = 0 ; i < array.length() ; i++) {
									JSONObject mObj = array.getJSONObject(i);
									String title = mObj.keys().next().toString();
									titles.add(title);
									values.add(mObj.optInt(title));
								}

								sexChartInterface.onGetSexSuccess(patientCount, titles, values);
							} catch (JSONException e) {
								e.printStackTrace();
							}

						} else {
							sexChartInterface.onGetSexError(responseCode, msg);
						}
					}
				});
	}

}
