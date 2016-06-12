package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.RecordItem;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class GetRecordInfoByItemLogic {
	
	@Weak
	private GetRecordInfoByItemCallBack mCallback;
	
	public GetRecordInfoByItemLogic(){
	}
	
	public GetRecordInfoByItemLogic(GetRecordInfoByItemCallBack callback){
		mCallback = callback;
	}
	
	/**
	 * 获得病历记录（即病历记录的详细信息）
	 * @param recordInfoId 病历记录的数据id(区别于recordItemId)
	 */
	public void loadRecordItem(final int examId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("exam_id", examId);
		
		String url = UriConstants.Conn.URL_PUB + "/record/item/get_item_info_by_exam.do";
		
		HalcyonHttpResponseHandle  mHandle = new HalcyonHttpResponseHandle() {
			@Override
			public void onError(int code, Throwable e) {
				mCallback.doRecordItemBack(null);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type,final Object results) {
				if(responseCode == 0 && type == 1){
					final RecordItem item = new RecordItem();
                    
                    JSONObject json = (JSONObject) results;
					item.setAtttributeByjson(json);
                    
					mCallback.doRecordItemBack(item);
					
					new Thread(new Runnable() {
						public void run() {
//							String localPath = FileSystem.getInstance().getRecordCachePath() + recordInfoId;
//							FileHelper.saveFile(item.getJson().toString(), localPath,true);//保存解密后的数据
						}
					}).start();
					
				}else{
					mCallback.doRecordItemBack(null);
				}
			}
		};
		
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		//不论有没有网络，预先尝试加载本地缓存
//		String cache = FileHelper.readString(FileSystem.getInstance().getRecordCachePath() + recordInfoId, true);
//		if (cache != null && !cache.equals("")) {
//			try {
//				mHandle.handle(0, cache, 1, new JSONObject(cache));
//			} catch (JSONException e) {
//				e.printStackTrace();
//			}
//		}
		if (Platform.isNetWorkConnect) {
			ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, mHandle);
		}
	}
	
	public interface GetRecordInfoByItemCallBack{
		public void doRecordItemBack(RecordItem recordItem);
	}
}
