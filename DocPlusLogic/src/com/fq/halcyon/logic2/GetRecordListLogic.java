package com.fq.halcyon.logic2;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Record;
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

/**
 * 获取病历列表，得到病案下面病历的集合
 * 
 * @author Chengxu Zhou
 */
public class GetRecordListLogic {

	private ArrayList<Record> mRecordList;
	private GetRecordListCallBack onCallBack;

	public GetRecordListLogic(GetRecordListCallBack onCallBack) {
		this.onCallBack = onCallBack;
		// mRecordList = new ArrayList<Record>();
	}

	/**
	 * 得到病历的集合(分页)
	 * 
	 * @param patientId
	 * @param page
	 * @param pageSize
	 */
	public void getRecordList(int patientId, int page, int pageSize) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_id", patientId);
		map.put("page", page);
		map.put("page_size", pageSize);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/find_record.do";

		GetRecordListHandle mHandle = new GetRecordListHandle(patientId,page);
		if (Platform.isNetWorkConnect) {
			ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
		} else {
			String cache = FileHelper.readString(FileSystem.getInstance().getUserCachePath() + patientId + "records.list", true);
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

	}

	/**
	 * 得到病历的集合(不分页)
	 * 
	 * @param patientId
	 */
	public void getRecordList(int patientId) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_id", patientId);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/find_record.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, new GetRecordListHandle(patientId,1));
	}
	
	/**
	 * 根据关键字得到病历的集合(不分页)
	 * 
	 * @param patientId
	 * @param recordName
	 */
	public void getRecordList(int patientId, String recordName) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		String name = "";
		try {
			name = new String(recordName.getBytes("UTF-8"),"UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		map.put("user_id", Constants.getUser().getUserId());
		map.put("patient_id", patientId);
		map.put("record_name", name);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/find_record.do";

		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, new GetRecordListHandle(patientId,1));
	}

	public interface GetRecordListCallBack {
		public void onGetRecordListError(int code, String msg);

		public void onGetRecordList(ArrayList<Record> mRecordList);
	}

	class GetRecordListHandle extends HalcyonHttpResponseHandle {

		private int mPatientId;

		private int mPage;

		public GetRecordListHandle(int patientId, int page) {
			this.mPatientId = patientId;
			this.mPage = page;
		}

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.onGetRecordListError(code, e.getMessage());
		}

		public void handleCache(int responseCode, String msg, int type, Object results, boolean fromCache) {
			if (responseCode == 0 && type == 2) {
				mRecordList = new ArrayList<Record>();
				JSONArray jsonarr = (JSONArray) results;
				int count = jsonarr.length();
				for (int i = 0; i < count; i++) {
					JSONObject jsonObj = jsonarr.optJSONObject(i);
					Record record = new Record();
					record.setAtttributeByjson(jsonObj);
					mRecordList.add(record);
				}
				onCallBack.onGetRecordList(mRecordList);
				String filePath = FileSystem.getInstance().getUserCachePath() + mPatientId + "records.list";
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
							array.put(jsonarr.optJSONObject(i));
						}
						FileHelper.saveFile(array.toString(), filePath, true);
					} else {
						FileHelper.saveFile(results.toString(), filePath, true);
					}
				}
			} else {
				onCallBack.onGetRecordListError(responseCode, msg);
			}

		}

		@Override
		public void handle(int responseCode, String msg, int type, Object results) {
			handleCache(responseCode, msg, type, results, false);
		}

	}
}
