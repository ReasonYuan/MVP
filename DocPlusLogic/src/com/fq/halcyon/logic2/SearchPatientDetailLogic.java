package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.PatientFriend;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class SearchPatientDetailLogic {
  
	public interface SearchPatientDetailLogicInterface extends FQHttpResponseInterface{
		public void onSearchPatientErrorDetail(int code,String msg);
		public void onSearchPatientDetailSuccess(PatientFriend mFriend);
	}
	
	@Weak
	public SearchPatientDetailLogicInterface mInterface;
	
	class SearchPatientDetailLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onSearchPatientErrorDetail(code,e.toString());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				PatientFriend mFriend = new PatientFriend();
				JSONObject mJsonObject = (JSONObject)results;
				mFriend.setAtttributeByjson(mJsonObject);
				mInterface.onSearchPatientDetailSuccess(mFriend);
			}else{
				mInterface.onSearchPatientErrorDetail(responseCode, msg);
			}
		}
		
	}
	private SearchPatientDetailLogicHandle mHandle = new SearchPatientDetailLogicHandle();
	
	public SearchPatientDetailLogic(SearchPatientDetailLogicInterface mIn) {
		mInterface = mIn;
	}

	public void searchPatientDetail(int friendId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("friend_id", friendId);
		JSONObject json = JsonHelper.createJsonForDebug(map);
		String url = UriConstants.Conn.URL_PUB + "/users/view_friend_patient.do";

		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
}
