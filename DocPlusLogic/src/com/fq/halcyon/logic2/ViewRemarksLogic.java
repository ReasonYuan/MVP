package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Remark;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 查看某条提醒的留言记录
 * */
public class ViewRemarksLogic {

	
	private List<Remark> mRemarkList = new ArrayList<Remark>();
	
	public interface ViewRemarksLogicCallBack{
		public void onErrorCallBack(int code , String msg);
		public void onSuccessCallBack(int code, List<Remark> mRemarkList);
	}
	
	@Weak
	public ViewRemarksLogicCallBack onCallBack;
	
	/**
	 *@param  timerId</br>
	 *                    -- 提醒的id
	 */
	public ViewRemarksLogic(int timerId, final ViewRemarksLogicCallBack onCallBack) {
		this.onCallBack = onCallBack;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("timer_id", timerId);
		map.put("user_id", Constants.getUser().getUserId());
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/timer/view_remarks.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
	
	public class ViewRemarksLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			e.printStackTrace();
			onCallBack.onErrorCallBack(code, e.getMessage());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if(responseCode == 0){
				JSONObject jsonObj = (JSONObject) results;
				try {
					JSONArray jsonArray = jsonObj.getJSONArray("timers");
					int count = jsonArray.length();
					for (int i = 0; i < count; i++) {
						Remark mRemark = new Remark();
						JSONObject item = (JSONObject) jsonArray.get(i);
						mRemark.setAtttributeByjson(item);
						mRemarkList.add(mRemark);
					}
					onCallBack.onSuccessCallBack(responseCode, mRemarkList);
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}
	
	public ViewRemarksLogicHandle mHandle = new ViewRemarksLogicHandle();
}
