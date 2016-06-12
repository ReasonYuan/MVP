package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class EditOneExamItemLogic {

	@Weak
	public EditOneExamItemCallBack onCallBack;
	public EditOneExamItemHandle mHandle;
	
	public interface EditOneExamItemCallBack{
		public void EditOneExamItemError(int code, String msg);
		public void EditOneExamItemResult(String msg);
	};
	
	public EditOneExamItemLogic(final EditOneExamItemCallBack onCallBack) {
		this.onCallBack = onCallBack;
		mHandle = new EditOneExamItemHandle();
	}
	
	public void EditOneExamItem(int examId,String itemName,String itemValue,String itemUnit){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("exam_id", examId);
		map.put("item_name", itemName);
		map.put("exam_value", itemValue);
		map.put("item_unit", itemUnit);
		JSONObject json = JsonHelper.createJson(map);
		System.out.println("=========================" + json);
		String uri = UriConstants.Conn.URL_PUB + "/record/item/modify_item_exam.do";
		
		ApiSystem.getInstance().require(uri, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	};
	
	class EditOneExamItemHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			onCallBack.EditOneExamItemError(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
					onCallBack.EditOneExamItemResult(msg);
			}else{
				onCallBack.EditOneExamItemError(responseCode, msg);
			}
		}
		
	}
}