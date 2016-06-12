package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Patient;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.FileHelper;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 查询病案
 */
public class SearchPatientLogic {

	private ArrayList<Patient> medicalList;
	@Weak
	public SearchMedicalCallBack onCallBack;

	public interface SearchMedicalCallBack {
		public void onSearchMedicalError(int code, String msg);

		public void onSearchMedicalResult(ArrayList<Patient> medicalList);
	};

	public SearchPatientLogic(SearchMedicalCallBack onCallBack) {
		this.onCallBack = onCallBack;
		medicalList = new ArrayList<Patient>();
	}

	/**
	 * 
	 * @param patientKey
	 * @param page
	 * @param pageSize
	 */
	public void searchMedical(String patientKey, int page, int pageSize) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_name", patientKey);
		map.put("page", page);
		map.put("page_size", pageSize);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/patient/search.do";
		SearchMedicalHandle mHandle = new SearchMedicalHandle(page);
		//以前的缓存代码
		if (Platform.isNetWorkConnect) {
			ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
		} else {
			String cache = FileHelper.readString(FileSystem.getInstance().getUserCachePath() + "search.list", true);
			if (cache != null && !cache.equals("")) {
				try {
					mHandle.handleCache(0, cache, 2, new JSONArray(cache),true);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			} else {
				ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
			}
		}
	};
	

	public void searchMedical(String patientKey) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_name", patientKey);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/patient/search.do";
		SearchMedicalHandle mHandle = new SearchMedicalHandle(1);
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	};

	class SearchMedicalHandle extends HalcyonHttpResponseHandle {

		private int mPage;

		public SearchMedicalHandle(int page) {
			this.mPage = page;
		}

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.onSearchMedicalError(code, e.getMessage());
		}

		public void handleCache(int responseCode, String msg, int type, Object results, boolean fromCache) {
			if (responseCode == 0 && type == 2) {

				JSONArray jsonArr = (JSONArray) results;
				int count = jsonArr.length();
				for (int i = 0; i < count; i++) {
					JSONObject obj = jsonArr.optJSONObject(i);
					Patient medical = new Patient();
					medical.setAtttributeByjson(obj);
					medicalList.add(medical);
				}
				onCallBack.onSearchMedicalResult(medicalList);
				String filePath = FileSystem.getInstance().getUserCachePath() + "search.list";
				if (!fromCache) {
					if (mPage != 1) {
						String cache = FileHelper.readString(filePath, true);
						JSONArray array = null;
						if (cache != null && !cache.equals("")) {
							try {
								array = new JSONArray(cache);
							} catch (JSONException e) {
								e.printStackTrace();
							}
						} else {
							array = new JSONArray();
						}
						for (int i = 0; i < count; i++) {
							array.put(jsonArr.optJSONObject(i));
						}
						FileHelper.saveFile(array.toString(), filePath, true);
					} else {
						FileHelper.saveFile(results.toString(), filePath, true);
					}
				}
			} else {
				onCallBack.onSearchMedicalError(responseCode, msg);
			}
		}

		@Override
		public void handle(int responseCode, String msg, int type, Object results) {
			handleCache(responseCode, msg, type, results, false);
		}
	}

}
