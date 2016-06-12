package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.PatientAbstract;
import com.fq.halcyon.entity.practice.RecordAbstract;
import com.fq.halcyon.entity.practice.RecordData;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.StrDataComparator;
import com.fq.lib.tools.TimeFormatUtils;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 用户回收站相关数据的接口<br/>
 * 回收站里的内容分为[病案摘要]和[记录摘要]两种
 * @author reason
 */
public class RecycleLogic {
	
//	/**回收站列表类型：病案*/
//	public static final String CATEGORY_PATIENT = "patient";
//	
//	/**回收站列表类型：病历记录*/
//	public static final String CATEGORY_RECORD = "record";
	
	
	@Weak
	private RecycleCallBack mCallBack;
	
	@Weak
	private Remove2RecycleCallBack mRemoveCallback;
	
	/**
	 * 初始化回收站的接口类，用于得到回收站里的数据，还原、清除回收站里的数据。
	 * @param RecycleCallBack 回收站处理(除了删除到回收站)事件的回调
	 */
	public RecycleLogic(RecycleCallBack callBack) {
		mCallBack = callBack;
	}
	
	/**
	 * 初始化回收站的接口类，只用于删除数据到回收站
	 * @param Remove2RecycleCallBack 回收站处理删除数据到回收站的回调
	 */
	public RecycleLogic(Remove2RecycleCallBack callBack) {
		mRemoveCallback = callBack;
	}
	
	public RecycleLogic(Remove2RecycleCallBack rcallBack, RecycleCallBack callBack) {
		mCallBack = callBack;
		mRemoveCallback = rcallBack;
	}
	
//	/**
//	 * 从服务器得到用户回收站的数据（删除的病案和记录）
//	 * @param page 第多少页数据
//	 * @param pageSize 每页的数据条数，如果传值为0，默认为5条
//	 */
//	public void loadRecyleList(int page,int pageSize){
//		JSONObject params = JsonHelper.createUserIdJson();
//		try{
//			params.put("page", null);
//			params.put("page_size", pageSize==0?PAGE_SIZE:pageSize);
//		}catch(Exception e){
//			e.printStackTrace();
//			FQLog.i("请求搜索病案或病历时,构造参数出错");
//		}
//		
//		String url = UriConstants.Conn.URL_PUB+"/users/select_patients_recorditems.do";
//		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
//
//			@Override
//			public void onError(int code, Throwable e) {
//				mCallBack.recycleError(code, Constants.Msg.NET_ERROR);
//			}
//
//			@Override
//			public void handle(int responseCode, String msg, int type,Object results) {
//				if(responseCode == 0){
//					JSONObject result = (JSONObject)results;
//					
//					ArrayList<String> keys = new ArrayList<String>();//病案和病历记录里所有的时间key
//					
//					//解析分组回收站病案,按时间为组
//					JSONArray patArray = result.optJSONArray("patient_list");
//					HashMap<String, ArrayList<PatientAbstract>> patMap = new HashMap<String, ArrayList<PatientAbstract>>();
//					for(int i = 0; i < patArray.length(); i++){
//						JSONObject json = patArray.optJSONObject(i);
//						PatientAbstract patient = new PatientAbstract();
//						patient.setAtttributeByjson(json);
//						
//						String time = patient.getDeleteTime();
//						ArrayList<PatientAbstract> patients = patMap.get(time);
//						if(patients == null){
//							patients = new ArrayList<PatientAbstract>();
//							patMap.put(time, patients);
//							keys.add(time);
//						}
//						patients.add(patient);
//					}
//					
//					
//					//解析分组回收站病历记录,按时间为组
//					JSONArray redArray = result.optJSONArray("record_item_list");
//					HashMap<String, ArrayList<RecordAbstract>> redMap = new HashMap<String, ArrayList<RecordAbstract>>();
//					for(int i = 0; i < redArray.length(); i++){
//						JSONObject json = redArray.optJSONObject(i);
//						RecordAbstract record = new RecordAbstract();
//						record.setAtttributeByjson(json);
//						
//						String time = record.getDeleteTime();
//						ArrayList<RecordAbstract> records = redMap.get(time);
//						if(records == null){
//							records = new ArrayList<RecordAbstract>();
//							redMap.put(time, records);
//							
//							boolean notHave = true;
//							for(String key:keys){
//								if(key.equals(time)){
//									notHave = false;
//									break;
//								}
//							}
//							if(notHave)keys.add(time);
//						}						
//						records.add(record);
//					}
//					
//					mCallBack.recycleDatas(keys,patMap,redMap);
//				}else{
//					mCallBack.recycleError(responseCode, msg);
//				}
//			}	
//		});
//	}
	
//	/**
//	 * 回收站的假数据
//	 */
//	private RecycleData getJiaShuJu(){
//		Random random = new Random();
//		int category = random.nextInt(2);
//		RecycleData recycle = new RecycleData();
//		recycle.setCategory(category);
//		
//		Calendar cal = Calendar.getInstance();
//		cal.add(Calendar.DAY_OF_YEAR, -random.nextInt(50));
//		recycle.setDeleteTime(TimeFormatUtils.getTimeByFormat(cal.getTimeInMillis(), "yyyyMMdd"));
//		
//		if(category == RecycleData.CATEGORY_PATIENT){
//			recycle.setPatientId(random.nextInt(2000)+1);
//			recycle.setPatientName("好吧，还是假数据");
//			recycle.setRecordCount(random.nextInt(6000));
//			recycle.setUserHeadImage(random.nextInt(1000)+1);
//		}else{
//			recycle.setInfoAbstract("记录的假数据");
//			recycle.setRecStatus(random.nextInt(4));
//			recycle.setRecordType(random.nextInt(4)+1);
//			recycle.setReordItemId(random.nextInt(500));
//			recycle.setRecordItemName("假的呀假的");
//		}
//		return recycle;
//	}
	
	/**
	 * 从服务器得到用户回收站的数据（删除的病案和记录）
	 * @param page 第多少页数据
	 * @param pageSize 每页的数据条数，如果传值为0，默认为5条
	 */
	public void loadRecyleList(int page,int pageSize){
		JSONObject params = JsonHelper.createUserIdJson();
		try{
			params.put("page", page);
			params.put("page_size", pageSize==0?5:pageSize);
		}catch(Exception e){
			e.printStackTrace();
			FQLog.i("请求搜索病案或病历时,构造参数出错");
		}
		
		String url = UriConstants.Conn.URL_PUB+"/users/select_patients_recorditems.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mCallBack.recycleError(code, Constants.Msg.NET_ERROR);
			}

			@Override
			public void handle(int responseCode, String msg, int type,Object results) {
				if(responseCode == 0){
					JSONObject result = (JSONObject)results;
					
					ArrayList<String> keys = new ArrayList<String>();//病案和病历记录里所有的时间key
					HashMap<String, ArrayList<RecordData>> recycleMap = new HashMap<String, ArrayList<RecordData>>();
					
					
					//解析分组回收站病案,按时间为组
					JSONArray patArray = result.optJSONArray("patient_list");
					for(int i = 0; i < patArray.length(); i++){
						JSONObject json = patArray.optJSONObject(i);
						RecordData patient = new PatientAbstract();
						patient.setAtttributeByjson(json);
						//RecycleData patient = getJiaShuJu();
						
						String time = patient.getDeleteTime();
						time = TimeFormatUtils.turnTime(time);
						ArrayList<RecordData> recycles = recycleMap.get(time);
						if(recycles == null){
							recycles = new ArrayList<RecordData>();
							recycleMap.put(time, recycles);
							keys.add(time);
						}
						recycles.add(patient);
					}
					
					//解析分组回收站病历记录,按时间为组
					JSONArray redArray = result.optJSONArray("record_item_list");
					for(int i = 0; i < redArray.length(); i++){
						JSONObject json = redArray.optJSONObject(i);
						RecordData record = new RecordAbstract();
						record.setAtttributeByjson(json);
//						RecycleData record = getJiaShuJu();
						
						String time = record.getDeleteTime();
						time = TimeFormatUtils.turnTime(time);
						ArrayList<RecordData> records = recycleMap.get(time);
						if(records == null){
							records = new ArrayList<RecordData>();
							recycleMap.put(time, records);
							keys.add(time);
						}						
						records.add(record);
					}
					
					Collections.sort(keys, new StrDataComparator());
					mCallBack.recycleDatas(keys,recycleMap);
				}else{
					mCallBack.recycleError(responseCode, msg);
				}
			}	
		});
	}
	
	/**
	 * 删除病案到回收站
	 */
	public void removePatientData(ArrayList<PatientAbstract> patientList){
		ArrayList<Integer> patientIds = new ArrayList<Integer>();
		
		for (int i = 0 ; i < patientList.size() ; i++ ){
			patientIds.add(patientList.get(i).getPatientId());
		}
		
		removeData(patientIds,null);
	}
	
	/**
	 * 删除病历记录到回收站
	 */
	public void removeRecordData(ArrayList<RecordAbstract> recordList){
		ArrayList<Integer> recordIds = new ArrayList<Integer>();
		
		for (int i = 0 ; i < recordList.size() ; i++ ){
			recordIds.add(recordList.get(i).getRecordItemId());
			FQLog.i("-----------------" + recordList.get(i).getRecordItemId());
		}
		
		removeData(null,recordIds);
	}
	
	/**
	 * 删除病案、病历记录到回收站
	 */
	public void removeData(ArrayList<Integer> patientIds,ArrayList<Integer> recordIds){
		JSONObject params = createRequestParam(patientIds, recordIds);
		
		String url = UriConstants.Conn.URL_PUB + "/users/delete_patients_recorditems.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mRemoveCallback.removeError(code, Constants.Msg.NET_ERROR);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
					mRemoveCallback.removeSuccess();
				}else{
					mRemoveCallback.removeError(responseCode, msg);
				}
			}
			
		});
	}
	
    
    
    /**
     * 还原回收站里的病案（从回收站恢复数据）
     */
    public void retorePatientData(ArrayList<PatientAbstract> list){
        ArrayList<Integer> patientIds = new ArrayList<Integer>();
        
        for (PatientAbstract data : list) {
            patientIds.add(data.getPatientId());
        }
        
        retoreData(patientIds, null);
    }
    
    
    /**
     * 还原回收站里的病历记录（从回收站恢复数据）
     */
    public void retoreRecordData(ArrayList<RecordAbstract> list){
        ArrayList<Integer> recordIds = new ArrayList<Integer>();
        
        for (RecordAbstract data : list) {
        	recordIds.add(data.getRecordItemId());
        }
        
        retoreData(null, recordIds);
    }
    
    /**
	 * 还原回收站里的病案、病历记录（从回收站恢复数据）
	 */
	public void retoreData(ArrayList<RecordData> list){
		
		ArrayList<Integer> patientIds = new ArrayList<Integer>();
		ArrayList<Integer> recordIds = new ArrayList<Integer>();
		
		for (RecordData data : list) {
			if ( data.getCategory() == RecordData.CATEGORY_PATIENT ) {
				patientIds.add(((PatientAbstract)data).getPatientId());
			}else{
				recordIds.add(((RecordAbstract)data).getRecordItemId());
			}
		}
		
		retoreData(patientIds, recordIds);
	}	
    
    
    
	/**
	 * 私用的抽象出来的方法，还原回收站里的病案、病历记录（从回收站恢复数据）
	 */
	private void retoreData(ArrayList<Integer> patientIds,ArrayList<Integer> recordIds){		
		JSONObject params = createRequestParam(patientIds, recordIds);
		
		String url = UriConstants.Conn.URL_PUB + "/users/restore_patients_recorditems.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mCallBack.recycleError(code, Constants.Msg.NET_ERROR);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
					mCallBack.recycelRestoreDataSuccess();
				}else{
					mCallBack.recycleError(responseCode, msg);
				}
			}
			
		});
	}
	
    
	/**
	 * 清除回收站里的病历记录（彻底删除数据）
	 */
	public void clearRecordData(ArrayList<RecordAbstract> list){
		ArrayList<Integer> recordIds = new ArrayList<Integer>();
		for(RecordAbstract record:list){
			recordIds.add(record.getRecordItemId());
		}
		clearData(null, recordIds);
	}
	
	/**
	 * 清除回收站里的病案（彻底删除数据）
	 */
	public void clearPatientData(ArrayList<PatientAbstract> list){
		ArrayList<Integer> patientIds = new ArrayList<Integer>();
		for(PatientAbstract patient:list){
			patientIds.add(patient.getPatientId());
		}
		
		clearData(patientIds, null);
	}    
    
	/**
	 * 清除回收站里的病案、病历记录（彻底删除数据）
	 */
	public void clearData(ArrayList<RecordData> list){
		
		ArrayList<Integer> patientIds = new ArrayList<Integer>();
		ArrayList<Integer> recordIds = new ArrayList<Integer>();
		
        for (int i = 0; i < list.size(); i++) {
            RecordData recycle = list.get(i);
            int category = recycle.getCategory();
			if (category == RecordData.CATEGORY_PATIENT ) {
				patientIds.add(((PatientAbstract)recycle).getPatientId());
			}else{
				recordIds.add(((RecordAbstract)recycle).getRecordItemId());
			}
		}
        clearData(patientIds, recordIds);
	}
	
	/**
	 * 删除数据时要掉的公用方法
	 * @param params
	 */
	private void clearData(ArrayList<Integer> patientIds,ArrayList<Integer> recordIds){
		JSONObject params = createRequestParam(patientIds, recordIds);
		String url = UriConstants.Conn.URL_PUB + "/users/empty_patients_recorditems.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mCallBack.recycleError(code, Constants.Msg.NET_ERROR);
			}
			
			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
					mCallBack.recycelClearDataSuccess();
				}else{
					mCallBack.recycleError(responseCode, msg);
				}
			}
			
		});
	}
	
	
	/***
	 * 构建回收站事件的请求数据，由于几个事件参数都一样，所以抽象出单独的方法出来
	 * @param patientIds 要处理的病案的id集合
	 * @param recordIds 要处理的病历记录的id集合
	 * @return JSONObject 处理组装好的请求数据
	 */
	private JSONObject createRequestParam(ArrayList<Integer> patientIds,ArrayList<Integer> recordIds){
		JSONObject params = JsonHelper.createUserIdJson();
		try{
			if(patientIds != null){
				JSONArray ids = new JSONArray();
				
				for(int i = 0; i < patientIds.size(); i++){
					ids.put(patientIds.get(i));
				}
				
				params.put("patient_ids", ids);
			}
			
			if(recordIds != null){
				JSONArray rids = new JSONArray();
				
				for(int i = 0; i < recordIds.size(); i++){
					rids.put(recordIds.get(i));
				}
				
				params.put("record_item_ids", rids);
			}
		}catch(Exception e){
			e.printStackTrace();
			FQLog.i("请求删除病案或病理记录时,构造请求参数出错");
		}
		return params;
	}
	
	
	
	/**
	 * 回收站事件处理回调
	 * @author Reason
	 */
	public interface RecycleCallBack {
		
		/**
		 * 请求成功后的返回数据
		 * @param patientMap 删除的病案，按时间分组的合集
		 * @param recordMap 删除的记录，按时间分组的合集
		 * @param keys 病案Map和病历记录Map的删除的时间合集
		 */
//		public void recycleDatas(ArrayList<String> keys,HashMap<String, ArrayList<PatientAbstract>> patientMap,HashMap<String, ArrayList<RecordAbstract>> recordMap);
		public void recycleDatas(ArrayList<String> keys,HashMap<String, ArrayList<RecordData>> recyDataMap);
		
		/**
		 * 从回收站恢复数据成功后的回调方法
		 */
		public void recycelRestoreDataSuccess();
		
		/**
		 * 从回收站清除数据成功后的回调方法
		 */
		public void recycelClearDataSuccess();
		
		/**
		 * 请求错误的回调方法(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void recycleError(int code,String msg);
	}
	
	
	/**
	 * 删除数据（病案、记录详情）到回收站回调
	 * @author Reason
	 */
	public interface Remove2RecycleCallBack {
		
		/**
		 * 删除成功与否的回调
		 * @param isSuccess :boolean类型,true表示删除成功，false表示删除失败
		 */
		public void removeSuccess();
				
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void removeError(int code,String msg);
	}
}
