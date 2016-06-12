package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.RecordType;
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
 * 得到病历下面，病历记录（简介）的集合
 * @author reason
 */
public class GetRecordTypeListLogic {

	private ArrayList<RecordType> mResultList;
	private LoadRecordTypesCallBack onCallBack;
	
	public GetRecordTypeListLogic(LoadRecordTypesCallBack onCallBack){
		this.onCallBack = onCallBack;
//		mResultList = new ArrayList<RecordItemType>();
	}
	
	/**
	 * 得到病历记录(简介)的集合
	 * @param recordId
	 */
	public void loadRecordTypes(int recordId,boolean isShareModel){
		HashMap< String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_id", recordId);
		JSONObject json = JsonHelper.createJson(map);
		String uri = UriConstants.Conn.URL_PUB + "/record/item/get_record_item.do";
		 GetRecordItemHandle mHandle = new GetRecordItemHandle(recordId,isShareModel);
		if(Platform.isNetWorkConnect){
			ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
		}else{
			String cache = FileHelper.readString( FileSystem.getInstance().getUserCachePath()+recordId+"record.item", true);
			if(cache != null && !cache.equals("")){
				try {
					mHandle.handle(0, cache, 2, new JSONArray(cache));
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}else {
				ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
			}
		}

	}
	
	public interface LoadRecordTypesCallBack{
		public void loadRecordTypesError(int code, String msg);
		public void loadRecordTypesResult(int code,ArrayList<RecordType> mResultList);
	}
	
	class GetRecordItemHandle extends HalcyonHttpResponseHandle{

		private int mRecordId;
		
		private boolean isShareModel;
		
		public GetRecordItemHandle(int recordId,boolean isShareModel){
			this.mRecordId = recordId;
			this.isShareModel = isShareModel;
		}
		
		@Override
		public void onError(int code, Throwable e) {
			onCallBack.loadRecordTypesError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0 && type == 2){
				mResultList = new ArrayList<RecordType>();
				JSONArray jsonArr = (JSONArray) results;
				int count = jsonArr.length();
				for (int i = 0; i < count; i++) {
					JSONObject json = jsonArr.optJSONObject(i);
					RecordType item = new RecordType();
					item.setIsShareModel(isShareModel);
					item.setAtttributeByjson(json);
					mResultList.add(item);
				}
				FileHelper.saveFile(results.toString(), FileSystem.getInstance().getUserCachePath()+mRecordId+"record.item", true);
				onCallBack.loadRecordTypesResult(responseCode, mResultList);
			}else{
				onCallBack.loadRecordTypesError(responseCode, msg);
			}
		}
	}
}
