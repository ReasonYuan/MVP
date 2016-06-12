package com.fq.halcyon.practice;

import java.util.ArrayList;

import com.fq.halcyon.entity.practice.PatientAbstract;
import com.fq.halcyon.entity.practice.RecordAbstract;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.FQLog;

/**
 * 用户搜索时的关键字[及结果]历史记录管理
 * @author reason
 */
public class SearchHistoryManager {

	
	/**搜索管理工具的单例*/
	private static SearchHistoryManager mInstance;
	
	/**
	 * 搜索的关键字历史记录:最多10条
	 */
	private ArrayList<String> mSearchKeys;
	
	/**
	 * 搜索到的病案
	 */
	private ArrayList<PatientAbstract> mSearchPatients;
	
	/**
	 * 搜索到的记录
	 */
	private ArrayList<RecordAbstract> mSearchRecords;;
	
	
	/**
	 * 获得搜索历史记录管理工具的单例
	 * @return
	 */
	public static SearchHistoryManager getInstance(){
		if(mInstance == null){
			mInstance = new SearchHistoryManager();
		}
		return mInstance;
	}
	
	/**
	 * 初始化历史搜索的工具类
	 */
	private SearchHistoryManager(){
		mSearchKeys = new ArrayList<String>();
		mSearchPatients = new ArrayList<PatientAbstract>();
		mSearchRecords = new ArrayList<RecordAbstract>();
		
		String txt = FileSystem.getInstance().loadUserSearchHistory();
		if(txt != null && !"".equals(txt)){
			loadSearchHistoryData(txt);
		}
	}
	
	/**
	 * 搜索的关键字的历史记录，最多10条
	 * @return
	 */
	public ArrayList<String> getKeys(){
		return mSearchKeys;
	}
	
	/**
	 * 最新的，搜索后返回的病案结果
	 * @return
	 */
	public ArrayList<PatientAbstract> getSearchPatients(){
		return mSearchPatients;
	}
	
	/**
	 * 最新的，搜索后返回的病历结果
	 * @return
	 */
	public ArrayList<RecordAbstract> getSearchRecords(){
		return mSearchRecords;
	}
	
	
	
	/**
	 * 保存搜索的记录到本地
	 */
	private void saveSearchHistory2Local(){
		final String history = getSearchHistoryJson().toString();
		if(history == null)return;
		new Thread(new Runnable() {
			public void run() {
				FileSystem.getInstance().saveUserSearchHistory(history);
			}
		}).start();
	}
	
	/**
	 * 保存搜索的关键字
	 * @param key 搜索的关键字，最多10个，超出的话会移除最后一个
	 */
	public void addSearchKey(String key){
		for(String ky:mSearchKeys){
			if(ky.equals(key)){
				mSearchKeys.remove(ky);
				mSearchKeys.add(0,key);
				saveSearchHistory2Local();
				return;
			}
		}
		
		if(mSearchKeys.size() == 10){
			mSearchKeys.remove(9);
		}
		mSearchKeys.add(0,key);
		saveSearchHistory2Local();
	}
	
	/**
	 * 保存搜索的返回结果
	 * @param patients 搜索时返回的病案列表
	 * @param records 搜索时返回的病历记录列表
	 */
	public void saveSearchResult(ArrayList<PatientAbstract> patients,ArrayList<RecordAbstract> records){
		if(patients != null)mSearchPatients = patients;
		if(records != null)mSearchRecords = records;
		
		if(patients != null && records != null)
		saveSearchHistory2Local();
	}
	
	/**
	 * 保存搜索的关键字和返回结果
	 * @param key 搜索的关键字，最多10个，超出的话会移除最后一个
	 * @param patients 搜索时返回的病案列表
	 * @param records 搜索时返回的病历记录列表
	 */
	public void saveSearchResult(String key, ArrayList<PatientAbstract> patients,ArrayList<RecordAbstract> records){
		boolean hasSave = false;
		for(String ky:mSearchKeys){
			if(ky.equals(key)){
				mSearchKeys.remove(ky);
				mSearchKeys.add(0,key);
				hasSave = true;
				return;
			}
		}
		if(!hasSave){
			if(mSearchKeys.size() == 10){
				mSearchKeys.remove(9);
			}
			mSearchKeys.add(0,key);
		}
		
		if(patients != null)mSearchPatients = patients;
		if(records != null)mSearchRecords = records;
		
		saveSearchHistory2Local();
	}
	
	
	/**
	 * 加载搜索的历史记录
	 * @param jsonData 历史记录的JSON格式的文本
	 */
	private void loadSearchHistoryData(String jsonData){
		try {
			JSONObject json = new JSONObject(jsonData);
			
			//解析关键字
			JSONArray kys = json.optJSONArray("keys");
			if(kys != null){
				for(int i = 0; i < kys.length(); i++){
					mSearchKeys.add(kys.optString(i));
				}
			}
			
			//解析搜索出的病案列表
			JSONArray pats = json.optJSONArray("patients");
			if(pats != null){
				for(int i = 0; i < pats.length(); i++){
					PatientAbstract patient = new PatientAbstract();
					patient.setAtttributeByjson(pats.optJSONObject(i));
					mSearchPatients.add(patient);
				}
			}
			
			//解析搜索出的记录列表
			JSONArray rds = json.optJSONArray("records");
			if(rds != null){
				for(int i = 0; i < rds.length(); i++){
					RecordAbstract record = new RecordAbstract();
					record.setAtttributeByjson(rds.optJSONObject(i));
					mSearchRecords.add(record);
				}
			}
		} catch (JSONException e) {
			FQLog.i("解析搜索历史记录JSON文本出错");
			e.printStackTrace();
		}
	}
	
	private String getSearchHistoryJson(){
		JSONObject json = new JSONObject();
		
		//json化关键字
		try {
			JSONArray kys = new JSONArray(mSearchKeys);
			json.put("keys", kys);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		//json化病案列表
		try {
			JSONArray pats = new JSONArray();
			json.put("patients", pats);
			
			for(int i = 0; i < mSearchPatients.size(); i++){
				pats.put(mSearchPatients.get(i).getJson());
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		//json化记录列表
		try {
			JSONArray rds = new JSONArray();
			json.put("records", rds);
			
			for(int i = 0; i < mSearchRecords.size(); i++){
				rds.put(mSearchRecords.get(i).getJson());
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		return json.toString();
	}
	
}
