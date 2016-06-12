package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class DeleteFollowUpTempleLogic {

	public interface DeleteFollowUpTempleLogicInterface extends FQHttpResponseInterface{
		public void onDeleteError(int code,String msg);
		public void onDeleteSuccessful();
	}
	
	public DeleteFollowUpTempleLogicInterface mInterface;
	public int mTempleId;
	
	class DeleteFollowUpTempleLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onDeleteError(code, e.toString());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				mInterface.onDeleteSuccessful();
			}else{
				mInterface.onDeleteError(responseCode, msg);
			}
		}
		
	}
	
	public DeleteFollowUpTempleLogicHandle mHandle = new DeleteFollowUpTempleLogicHandle();
	
	public DeleteFollowUpTempleLogic(DeleteFollowUpTempleLogicInterface mIn,int templeId) {
		this.mInterface = mIn;
		mTempleId = templeId;
	}

	public void deleteTemple(){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("followup_template_id", mTempleId);
		JSONObject json = JsonHelper.createJsonForDebug(map);
		String url = UriConstants.Conn.URL_PUB + "/timer/delete_followup_template.do";

		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
}
