package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class RemoveRecordItemLogic {
	
	private RemoveItemCallBack mCallback;
	
	public RemoveRecordItemLogic(RemoveItemCallBack callback){
		mCallback = callback;
	}
	
	public void removeRecordItem(int itemId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("record_item_id", itemId);
		
		String url = UriConstants.Conn.URL_PUB + "/record/item/delete.do";
		FQHttpParams params = new FQHttpParams(JsonHelper.createJsonForDebug(map));
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, new RemoveItemHandler(itemId));
	}
	
	class RemoveItemHandler extends HalcyonHttpResponseHandle{
		private int itemId;
		
		public RemoveItemHandler(int id){
			itemId = id;
		}
		
		@Override
		public void onError(int code, Throwable e) {
			if(mCallback != null) mCallback.doRemoveback(itemId, false);
		}

		@Override
		public void handle(int responseCode, String msg, int type,Object results) {
			if(mCallback != null) mCallback.doRemoveback(itemId,responseCode == 0);
		}
	}
	
	public interface RemoveItemCallBack{
		/**
		 * 删除病历记录后回调
		 * @param recordItemId 删除的病历记录的Id
		 * @param isSuccess 是否删除成功，true删除成功，false删除失败
		 */
		public void doRemoveback(int recordItemId,boolean isSuccess);
	}
	
}
