package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Medicine;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class RequestMedicineLogic {

	private ArrayList<Medicine> mMedicines;// 药物列表

	public void requestMedicine(final RequetMedicineInf inf, String keywords) {
		if (mMedicines == null || mMedicines.size() == 0 || keywords.equals("")) {
			String url = UriConstants.Conn.URL_PUB
					+ "/medicine/search_medicine.do";
			JSONObject json = null;
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("user_id", Constants.getUser().getUserId());
			map.put("key_words", keywords);
			json = JsonHelper.createJson(map);

			ApiSystem.getInstance().require(url, new FQHttpParams(json),
					API_TYPE.BROW, new HalcyonHttpResponseHandle() {
						public void onError(int code, Throwable e) {
							inf.onError(code, e);
						}

						public void handle(int responseCode, String msg,
								int type, Object results) {
							if (responseCode == 0 && type == 2) {
								JSONArray array = (JSONArray) results;
								if (array == null)
									inf.onError(responseCode,
											new Throwable(msg));

								mMedicines = new ArrayList<Medicine>();
								for (int i = 0; i < array.length(); i++) {
									try {
										Medicine med = new Medicine();
										med.setAtttributeByjson(array
												.getJSONObject(i));
										mMedicines.add(med);
									} catch (Exception e) {
										e.printStackTrace();
									}
								}
								inf.feedMedicine(mMedicines);
							} else {
								inf.onError(responseCode, new Throwable(msg));
							}
						}
					});
		} else {
			return;
		}
	}

	public interface RequetMedicineInf extends FQHttpResponseInterface {
		public void feedMedicine(ArrayList<Medicine> medicine);
	}
}
