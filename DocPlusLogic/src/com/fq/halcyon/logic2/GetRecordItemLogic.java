package com.fq.halcyon.logic2;

import java.util.HashMap;
import java.util.Iterator;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.RecordItem;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 得到病历记录的详细信息
 * @author reason
 */
public class GetRecordItemLogic {

	@Weak
	private RecordItemCallBack mCallback;
	
	RecordItemHandle mHandle;
	
	public GetRecordItemLogic(){
	}
	
	public GetRecordItemLogic(RecordItemCallBack callback){
		mCallback = callback;
		mHandle = new RecordItemHandle();
	}
	
	/**通过离线数据*/
	public void offlineHandle(String str){
		try {
			mHandle.handleJson(new JSONObject(str));
		} catch (JSONException e) {
			e.printStackTrace();
			mCallback.doRecordItemBack(null);
		}
	}
	
	/**
	 * 获得病历记录（即病历记录的详细信息）
	 * @param recordInfoId 病历记录的数据id(区别于recordItemId)
	 */
	public void loadRecordItem(final int recordInfoId,final boolean isSharedModel){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_info_id", recordInfoId);
		
		String url = UriConstants.Conn.URL_PUB + "/record/item/get_item_info.do";
//		mHandle.setInfoId(recordInfoId);
//		mHandle = new RecordItemHandle(recordInfoId);
		/*HalcyonHttpResponseHandle  mHandle = new HalcyonHttpResponseHandle() {
			@Override
			public void onError(int code, Throwable e) {
				mCallback.doRecordItemBack(null);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type,final Object results) {
				if(responseCode == 0 && type == 1){
					final RecordItem item = new RecordItem();
					item.setShareModel(isSharedModel);
                    
                    JSONObject json = (JSONObject) results;
					item.setAtttributeByjson(json);
                    
					mCallback.doRecordItemBack(item);
					
					new Thread(new Runnable() {
						public void run() {
							String localPath = FileSystem.getInstance().getRecordCachePath() + recordInfoId;
							FileHelper.saveFile(item.getJson().toString(), localPath,true);//保存解密后的数据
//							FileHelper.saveFile(results.toString(), localPath,true);//
						}
					}).start();
					
				}else{
					mCallback.doRecordItemBack(null);
				}
			}
		};*/
		
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
//		//不论有没有网络，预先尝试加载本地缓存
//		String cache = FileHelper.readString(FileSystem.getInstance().getRecordCachePath() + recordInfoId, true);
//		if (cache != null && !cache.equals("")) {
//			try {
//				FQLog.i("~~~记录详情：有缓存数据");
//				mHandle.handle(0, cache, 1, new JSONObject(cache));
//			} catch (JSONException e) {
//				FQLog.i("~~~记录详情：缓存数据格式不对，挂了");
//				e.printStackTrace();
//			}
//		}
		mHandle.setId("get_item_info.do"+"_"+Constants.getUser().getUserId()+"_"+recordInfoId, false);
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, mHandle);
	}
	
	public interface RecordItemCallBack{
		/**
		 * 加载病历记录数据的回调
		 * @param recordItem 返回加载到的病历记录，如果没有则返回null
		 */
		public void doRecordItemBack(RecordItem recordItem);
	}
	
	/**
	 * 修改病历记录信息
	 * @param recordInfoId
	 * @param type 1表示基本信息  2表示详细信息  3表示化验信息
	 * @param obj 修改后的数据  type为1、2时为String，为3时为jsonarray
	 */
	public void modifyRecordItem(int recordInfoId,HashMap<String, String> modifyInfoMap,final ModifyItemCallBack callback){
		JSONObject json = JsonHelper.createUserIdJson();
		try{
			json.put("record_info_id", recordInfoId);
			Iterator<String> itor = modifyInfoMap.keySet().iterator();
			while (itor.hasNext()) {
				String type = itor.next();
				json.put(type, modifyInfoMap.get(type));
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB + "/record/item/modify_item_info.do";
		FQHttpParams params = new FQHttpParams(json);
		
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			public void onError(int code, Throwable e) {
				callback.doBack(false);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				callback.doBack(responseCode == 0);
			}
		});
	}
	
	/**
	 * 修改病历记录接口
	 * @author reason
	 */
	public interface ModifyItemCallBack{
		public void doBack(boolean isb);
	}
	
	
	
	class RecordItemHandle extends HalcyonHttpResponseHandle {
		
//		private int infoId;
//		
//		public void  setInfoId(int recordInfoId){
//			infoId = recordInfoId;
//		}
		
		@Override
		public void onError(int code, Throwable e) {
			mCallback.doRecordItemBack(null);
		}
		
		@Override
		public void handle(int responseCode, String msg, int type,final Object results) {
			if(responseCode == 0 && type == 1){
				final RecordItem item = new RecordItem();
				item.setShareModel(false);
                
                JSONObject json = (JSONObject) results;
				item.setAtttributeByjson(json);
                
				mCallback.doRecordItemBack(item);
				
//				new Thread(new Runnable() {
//					public void run() {
//						String localPath = FileSystem.getInstance().getRecordCachePath() + infoId;
//						FileHelper.saveFile(item.getJson().toString(), localPath,true);//保存解密后的数据
////						FileHelper.saveFile(results.toString(), localPath,true);//
//					}
//				}).start();
				
			}else{
				mCallback.doRecordItemBack(null);
			}
		}
	};
	
}
