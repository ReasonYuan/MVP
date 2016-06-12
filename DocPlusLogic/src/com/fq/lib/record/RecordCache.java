package com.fq.lib.record;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.entity.RecordItem;
import com.fq.halcyon.uimodels.OneType;

/**
 * 一个病历下所有数据（病历记录samp,病历记录详情）的缓存，使其一份病历记录(在一定时间内)如果之前有下载数据，</br>
 * 那么就不用再次从服务器下载了。</br>
 * 病历记录的数据用于浏览病历记录（界面:BrowRecordItemActivity）
 * @author reason
 */
public class RecordCache {

	private static RecordCache mInstance;
	
	private RecordCache(){}
	
	
	/**
	 * 用于缓存所有的病历记录的数据（使其不用再次下载）
	 */
	private HashMap<Integer,RecordItem> RecordItems;

	/**
	 * 病历的id，用于标识RecordItems是属于哪个病历下的数据
	 */
	private int RecordId = -1;
	
	/**
	 * 病历的类型：住院病历、门诊病历(默认住院病历)
	 */
	private int docType = RecordConstants.RECORD_TYPE_ADMISSION;
	
	/**病历下没有拍了图片但还没有上传的病历*/
	private ArrayList<OneType> mUnUploadTypes;
	
	
	/**
	 * 开始缓存这个病历下下载的（已识别的）病历记录数据，</br>
	 * 这里主要是初始化缓存
	 * @param recordId 需要缓存病历记录（数组）属于哪个病历的[病历Id]
	 */
	public static void initCache(int recordId,int doctype){
		if(mInstance == null){
			mInstance = new RecordCache();
			mInstance.RecordId = recordId;
			mInstance.docType = doctype;
			mInstance.RecordItems = new HashMap<Integer,RecordItem>();
		}
	}
	
	public static void setRecordId(int recordId){
		if(mInstance != null){
			mInstance.RecordId = recordId;
		}
	}
	
	public static RecordCache getInstance(){
		if(mInstance == null){
			try {
				throw new RuntimeException("没有初始化实例");
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return mInstance;
	}
	
	/**
	 * 清除这个病历下的所有缓存的病历记录数据
	 */
	public static void clearCache(){
		mInstance.RecordItems = null;
		mInstance = null;
	}
	
	/***
	 * 得到病历的id
	 */
	public int getRecordId(){
		return RecordId;
	}

	/**
	 * 得到病历的类型：住院病历|门诊病历
	 * @return
	 */
	public int getDocType(){
		return docType;
	}
	
	public ArrayList<OneType> getUnUploadTypes(){
		return mUnUploadTypes;
	}
	
	public void setUnUploadTypes(ArrayList<OneType> types){
		mUnUploadTypes = types;
	}
	
	
	//*****************************************************************
	//*************************病历记录详细信息缓存处理*************************
	//*****************************************************************
	
	/**
	 * 将下载的数据添加到缓存
	 * @param record
	 */
	public void addCache(RecordItem record){
		if(RecordItems == null)return;
		int key = record.getRecordInfoId();
		if(!RecordItems.containsKey(key)){
			RecordItems.put(key, record);
		}
	}
	
	public void removeCache(RecordItem record){
		if(record == null||RecordItems == null)return;
		RecordItems.remove(record);
	}
	
	/**
	 * 得到缓存的病历记录数据
	 * @param recordInfoId key值，病历记录的信息Id
	 * @return 已下载的缓存的病历记录数据,如果没有则返回null
	 */
	public RecordItem getCache(int recordInfoId){
		if(RecordItems == null || RecordItems.get(recordInfoId) == null){
			if(RecordItems == null) RecordItems = new HashMap<Integer,RecordItem>();
			/*String localPath = FileSystem.getInstance().getRecordCachePath() + recordInfoId;
			File file = new File(localPath);
			if(file.exists()){
				String string = FileHelper.readString(localPath,true);
				if(string != null && !string.equals("")){
					try {
						JSONObject json = new JSONObject(string);
						RecordItem item = new RecordItem();
						item.setAtttributeByjson(json);
						RecordItems.put(recordInfoId, item);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}*/
		}
		return RecordItems.get(recordInfoId);
	}
}
