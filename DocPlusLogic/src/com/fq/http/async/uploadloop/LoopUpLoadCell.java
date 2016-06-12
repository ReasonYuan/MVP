package com.fq.http.async.uploadloop;

import java.util.ArrayList;
import java.util.Iterator;

import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.halcyon.entity.RecordType;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

/**
 * 上传文件用到的cell,根据不同的type，resetParams执行不的参数重构方法
 * @author liaomin
 *
 */
public class LoopUpLoadCell extends LoopCell {
	
	public interface OnUpLoadStateChangedListener{
		/**
		 * 上传一张图片成功
		 */
		public void onSuccessUpLoadAFile();
		
		/**
		 * 上传一张图片失败
		 */
		public void onFaildUpLoadAFile();
	}

	/**
	 * 
	 */
	private static final long serialVersionUID = 8747510219734880340L;

	
	private OnUpLoadStateChangedListener mUpLoadStateChangedListener;
	
	public void setOnUpLoadStateChangedListener(OnUpLoadStateChangedListener l){
		mUpLoadStateChangedListener = l;
	}
	
	
	public enum UP_TYPE{
		/**
		 * 上传病例
		 */
		UP_TYPE_RECORD,
		
		/**
		 * 上传证件
		 */
		UP_TYPE_Documents
	}
	
	private UP_TYPE mType;
	
	private int recordId;
	
	public LoopUpLoadCell(String url, FQHttpParams params,UP_TYPE type) {
		super(url, params);
		this.mType = type;
	}

	public void onUpLoadError(Photo photo){
		if(mUpLoadStateChangedListener != null) mUpLoadStateChangedListener.onFaildUpLoadAFile();
	}
	
	public void onUpLoadSuccess(Photo photo){
		uploadedFileCount ++;
		if(mUpLoadStateChangedListener != null) mUpLoadStateChangedListener.onSuccessUpLoadAFile();
	}
	
	
	@Override
	public void addPhotos(int type, ArrayList<Photo> photos) {
		super.addPhotos(type, photos);
		
	}
	
	
	/**
	 * 文件上传完成重新设置参数<br>
	 * 上传完成的图片再photos里 
	 */
	public void resetParams(){
		switch (mType) {
		case UP_TYPE_RECORD:
			try {
				JSONObject json = this.params.getJson();
				JSONArray pRecords = new JSONArray();
				json.put("records", pRecords);
				Iterator<Integer> iter = records.keySet().iterator();
				while (iter.hasNext()) {
					JSONObject jsonObject = new JSONObject();
					pRecords.put(jsonObject);
				    int key = iter.next();
				    jsonObject.put("record_type", key);
				    JSONArray records_images = new JSONArray();
				    jsonObject.put("records_images", records_images);
				    ArrayList<ArrayList<Photo>> value = records.get(key);
				    for (int i = 0; i < value.size(); i++) {
				    	ArrayList<Photo> array = value.get(i);
				    	JSONObject phot = new JSONObject();
				    	JSONArray photos = new JSONArray();
				    	for (int j = 0; j < array.size(); j++) {
				    		Photo p = array.get(j);
				    		photos.put(p.getImageId());
						}
				    	phot.put("photo", photos);
				    	records_images.put(phot);
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			break;
		case UP_TYPE_Documents:
			
			break;
		default:
			break;
		}
	}

	public int getRecordId() {
		return recordId;
	}

	public void setRecordId(int recordId) {
		this.recordId = recordId;
	}
	
	public String uuid;
	
	public ArrayList<RecordType> todRecordTypes(){
		ArrayList<RecordType> recordTypes = new ArrayList<RecordType>();
		Iterator<Integer> keys = records.keySet().iterator();
		while (keys.hasNext()) {
			Integer integer = (Integer) keys.next();
			RecordType recordType = new RecordType();
			ArrayList<ArrayList<Photo>> photos= records.get(integer);
			recordType.setRecordType(integer);
			recordTypes.add(recordType);
			ArrayList<RecordItemSamp> itemList = new ArrayList<RecordItemSamp>();
			for (int i = 0; i < photos.size(); i++) {
				RecordItemSamp samp = new RecordItemSamp();
				samp.setUuid(uuid);
				ArrayList<Photo> sampPhotos = photos.get(i);
				ArrayList<PhotoRecord> photoRecords = new ArrayList<PhotoRecord>();
				for (int j = 0; j < sampPhotos.size(); j++) {
					PhotoRecord record = new PhotoRecord();
					Photo photo = sampPhotos.get(j);
					record.setImageId(photo.getImageId());
					record.setLocalPath(photo.getLocalPath());
					photoRecords.add(record);
				}
				samp.setRecStatus(RecordItemSamp.REC_UPLOAD);
				samp.setReocrdType(integer);
				samp.setPhotos(photoRecords);
				itemList.add(samp);
			}
			recordType.setItemList(itemList);
		}
		return recordTypes;
	}
}
