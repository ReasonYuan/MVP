package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Contacts;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class ContactLogic {
	
	public interface ContactLogicInterface extends FQHttpResponseInterface{
		public void onDataReturn(HashMap<String, ArrayList<Contacts>> mHashPeerList);
		public void onError(int code, Throwable e);
	}
	
	@Weak
	public ContactLogicInterface mInterface;
	private ArrayList<Contacts> mStuList;
	private ArrayList<Contacts> mPatientList;
	private HashMap<String, ArrayList<Contacts>> mHashPeerList;
	private ArrayList<Contacts> mPeerlist;
	private ArrayList<Contacts> mPeerListAll;
	
	public class ContactLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			if(Constants.contactsMap == null){
				Constants.contactsList = new ArrayList<Contacts>();
				Constants.contactsMap = new HashMap<Integer, ArrayList<Contacts>>();
				Constants.contactsMap.put(Constants.ROLE_DOCTOR, new ArrayList<Contacts>());
				Constants.contactsMap.put(Constants.ROLE_DOCTOR_STUDENT, new ArrayList<Contacts>());
				Constants.contactsMap.put(Constants.ROLE_PATIENT, new ArrayList<Contacts>());
			}
			if(Constants.contactsDepartmentMap == null){
				Constants.contactsDepartmentMap = new HashMap<String, ArrayList<Contacts>>();
			}else{
				Constants.contactsDepartmentMap.clear();
			}
			if(mInterface != null)mInterface.onError(code, e);
			
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
		
			if(responseCode == 0){
				mStuList = new ArrayList<Contacts>();
				mPatientList = new ArrayList<Contacts>();
				mPeerListAll = new ArrayList<Contacts>();
				mHashPeerList = new HashMap<String, ArrayList<Contacts>>();
				
				if(Constants.contactsList == null){
						Constants.contactsList = new ArrayList<Contacts>();
				}else{
					Constants.contactsList.clear();
				}
				if(Constants.contactsDoctorList == null){
					Constants.contactsDoctorList = new ArrayList<Contacts>();
				}else{
					Constants.contactsDoctorList.clear();
				}
				if(Constants.contactsPatientList == null){
					Constants.contactsPatientList = new ArrayList<Contacts>();
				}else{
					Constants.contactsPatientList.clear();
				}
				if(Constants.contactsMap == null){
					Constants.contactsMap = new HashMap<Integer, ArrayList<Contacts>>();
				}else{
					Constants.contactsMap.clear();
				}
				if(Constants.contactsDepartmentMap == null){
					Constants.contactsDepartmentMap = new HashMap<String, ArrayList<Contacts>>();
				}else{
					Constants.contactsDepartmentMap.clear();
				}
				Constants.contactsMap.put(Constants.ROLE_DOCTOR, mPeerListAll);
				Constants.contactsMap.put(Constants.ROLE_DOCTOR_STUDENT, mStuList);
				Constants.contactsMap.put(Constants.ROLE_PATIENT, mPatientList);
				
				JSONArray mArrayStu = ((JSONObject)results).optJSONArray("students");
				JSONArray mArrayPatient = ((JSONObject)results).optJSONArray("patients");
				JSONArray mArrayPeer = ((JSONObject)results).optJSONArray("peers");
				
				for (int i = 0; i < mArrayPeer.length(); i++) {
					JSONObject object = mArrayPeer.optJSONObject(i);
					Iterator<String> keys = object.keys();
					while(keys.hasNext()){
						 String key = keys.next();
						 JSONArray peersArray = object.optJSONArray(key);
						 if(peersArray != null){
							 mPeerlist = new ArrayList<Contacts>();
							 for(int j = 0;j< peersArray.length();j++){
								 Contacts mUser = new Contacts();
								JSONObject mJsonObject = peersArray.optJSONObject(j);
								mUser.setAtttributeByjson(mJsonObject);
								mPeerlist.add(mUser);
								mPeerListAll.add(mUser);
								Constants.contactsDoctorList.add(mUser);
								Constants.contactsList.add(mUser);
							 }
							 mHashPeerList.put(key, mPeerlist);
							 Constants.contactsDepartmentMap.put(key, mPeerlist);
						 }
					}
					
				}
				
				if(mArrayStu != null){
					for(int i =0;i <  mArrayStu.length();i++){
						Contacts mUser = new Contacts();
						mUser.setAtttributeByjson(mArrayStu.optJSONObject(i));
						mStuList.add(mUser);
						Constants.contactsList.add(mUser);
					}
				}
				
				for(int i = 0;i< mArrayPatient.length();i++){
					Contacts mUser = new Contacts();
					mUser.setAtttributeByjson(mArrayPatient.optJSONObject(i));
					mPatientList.add(mUser);
					Constants.contactsPatientList.add(mUser);
					Constants.contactsList.add(mUser);
				}
				
				if(mInterface != null)mInterface.onDataReturn(mHashPeerList);
			}else{
				if(Constants.contactsMap == null){
					
					Constants.contactsList = new ArrayList<Contacts>();
					Constants.contactsMap = new HashMap<Integer, ArrayList<Contacts>>();
					Constants.contactsMap.put(Constants.ROLE_DOCTOR, new ArrayList<Contacts>());
					Constants.contactsMap.put(Constants.ROLE_DOCTOR_STUDENT, new ArrayList<Contacts>());
					Constants.contactsMap.put(Constants.ROLE_PATIENT, new ArrayList<Contacts>());
				}
				
				if(mInterface != null)mInterface.onError(responseCode, new Throwable(msg));
			}
		}
	}
	
	public ContactLogicHandle mHandle = new ContactLogicHandle();
	
	public ContactLogic(ContactLogicInterface mIn,int userId){
		this.mInterface = mIn;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", userId);
		JSONObject json = JsonHelper.createJson(map);
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/users/doctor_friends_list.do", new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}
}
