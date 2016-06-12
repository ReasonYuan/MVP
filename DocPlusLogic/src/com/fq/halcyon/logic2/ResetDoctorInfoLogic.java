package com.fq.halcyon.logic2;

import java.util.HashMap;
import java.util.Map;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.HalcyonUploadLooper;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.FQHttpParams;
import com.fq.http.async.uploadloop.LoopCell;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class ResetDoctorInfoLogic {
	
	public void reqModyHead(int imageId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("head_pic_image_id", imageId);
		requestModifyDoctor(map);
	}
	
	public void reqModyName(String name){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("name", name);
		requestModifyDoctor(map);
	}

	public void reqModyCity(int cityId){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("city_id", cityId);
		requestModifyDoctor(map);
	}
	
	public void reqModyHosp(int cityId,int hosId, String hospName){
		HashMap<String, Object> map = new HashMap<String, Object>();
		if(hosId == 0){
			map.put("hospital_name", hospName);
		}else{
			map.put("hospital_id", hosId);
		}
		if(cityId != 0)map.put("city_id", cityId);
		requestModifyDoctor(map);
	}
	
	public void reqModyDept(int deptId,int secId,String name){
		HashMap<String, Object> map = new HashMap<String, Object>();
		if(deptId != 0){
		map.put("dept_id", deptId);
		}
		map.put("dept_second_name", name);
		if(secId != 0){map.put("dept_second_id", secId);}
		requestModifyDoctor(map);
	}
	
	/**
	 *修改性别
	 *@param gender
	 *    - 男：2， 女：1
	 */
	public void reqModyGender(int gender){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("gender", gender);
		requestModifyDoctor(map);
	}
	
	public void reqModyDes(String des){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("description", des);
		requestModifyDoctor(map);
	}
	
	public void reqModyUniversity(String university){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("university", university);
		requestModifyDoctor(map);
	}
	
	public void reqModyEntranceTime(String entranceTime){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("entrance_time", entranceTime);
		requestModifyDoctor(map);
	}
	
	public void reqModyMajor(String major){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("major", major);
		requestModifyDoctor(map);
	}
	
	public void reqModyTitle(int title){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("title", title);
		requestModifyDoctor(map);
	}
	
	public void reqModyEducation(int education){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("education", education);
		requestModifyDoctor(map);
	}
	
	
	/**
	 *修改医生的个人信息
	 *
	 * @param map ,hospital_name,dept_id,dept_second_name
	 *            需要修改的信息
	 */
	public void requestModifyDoctor(Map<String, Object> map){
		map.put("user_id", Constants.getUser().getUserId());
		FileSystem.getInstance().saveCurrentUser();
		final String url = UriConstants.Conn.URL_PUB+"/doctors/modify_doctor_profile.do";
		final FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		LoopCell cell = new LoopCell(url, params);
		HalcyonUploadLooper.getInstance().push(cell);
	}
	
	public void requestInvient(final InvientCallback callback){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		String url = UriConstants.Conn.URL_PUB+"/users/get_invitation_code.do";
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			public void onError(int code, Throwable e) {
				callback.doInvientBack("");
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if(responseCode == 0 && type == 1){
					JSONObject json = (JSONObject) results;
					callback.doInvientBack(json.optString("invitation_code"));
				}else{
					callback.doInvientBack("");
				}
			}
		});
	}
	
	public interface InvientCallback{
		public void doInvientBack(String invient);
	}
}
