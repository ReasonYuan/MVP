package com.fq.halcyon.logic;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class GetImagePathLogic {

	public interface ImagePathCallBack{
		public void doback(ArrayList<PhotoRecord> photos);
	}
	
	private ImagePathCallBack mCallback;
	
	public GetImagePathLogic(){
	}
	
	public GetImagePathLogic(ImagePathCallBack callback){
		mCallback = callback;
	}
	
	public void getImagePath(int recordItemId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_item_id", recordItemId);
		
		String url = UriConstants.Conn.URL_PUB + "/record/item/get_image.do";
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			@Override
			public void onError(int code, Throwable e) {
				mCallback.doback(null);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0 && type == 1){
					JSONObject json = (JSONObject) results;
					try {
						JSONArray array = ((JSONObject) results).getJSONArray("photos");
						ArrayList<PhotoRecord> photos = new ArrayList<PhotoRecord>();
						for(int i = 0; i < array.length(); i++){
							PhotoRecord photo = new PhotoRecord();
							photo.setAtttributeByjson(array.getJSONObject(i));
							photos.add(photo);
						}
						mCallback.doback(photos);
					} catch (JSONException e) {
						e.printStackTrace();
						mCallback.doback(null);
					}
				}else{
					mCallback.doback(null);
				}
			}
		});
	}	
	
	public interface RecordImageCallback{
		public void callRecrodImages(ArrayList<PhotoRecord> photos);
	}
	
	public void getRecordImages(int recordId,final RecordImageCallback callback){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_id", recordId);
		
		String url = UriConstants.Conn.URL_PUB + "/record/get_record_image.do";
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			@Override
			public void onError(int code, Throwable e) {
				callback.callRecrodImages(null);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0 && type == 1){
					JSONObject json = (JSONObject) results;
					try {
						JSONArray array = ((JSONObject) results).getJSONArray("photos");
						ArrayList<PhotoRecord> photos = new ArrayList<PhotoRecord>();
						for(int i = 0; i < array.length(); i++){
							PhotoRecord photo = new PhotoRecord();
							photo.setAtttributeByjson(array.getJSONObject(i));
							photos.add(photo);
						}
						callback.callRecrodImages(photos);
					} catch (JSONException e) {
						e.printStackTrace();
						callback.callRecrodImages(null);
					}
				}else{
					callback.callRecrodImages(null);
				}
			}
		});
	}
}
