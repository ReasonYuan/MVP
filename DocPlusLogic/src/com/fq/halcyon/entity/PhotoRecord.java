package com.fq.halcyon.entity;

import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;

/**
 * 病历记录的图片,继承至{@link Photo}
 * @author reason
 *
 */
public class PhotoRecord extends Photo{

	/**
	 * 识别状态：识别成功
	 */
	public static final int REC_STATE_SUCC = 0;
	/**
	 * 识别状态：无法识别
	 */
	public static final int REC_STATE_FAIL = 2;
	/**
	 * 识别状态：删除
	 */
	public static final int REC_STATE_DEL = 3;
	
	
	/**
	 * OCR识别状态：识别完成
	 */
	public static final int OCR_STATE_COMPLETE = 2;
	
	/**
	 * 识别状态：识别中
	 */
	public static final int OCR_STATE_PROCESSING = 1;
	
	private static final long serialVersionUID = 1L;
	
	/**
	 * 这张图片与它所在病历的id
	 */
	private int recordInfoId; 
	
	/**
	 * 这张图片的识别状态
	 */
	private int state = -1;
	
	/**是不是分享的图片*/
	private boolean isShared;
	
	private int recordType;
	
	/**
	 * 本地的状态，是否正在上传
	 */
	public boolean isLoading = false; 
	
	private long processTime;
	
	private String correctPercent; 
	
	
	public String getCorrectPercent() {
		return correctPercent;
	}

	public void setCorrectPercent(String correctPercent) {
		this.correctPercent = correctPercent;
	}

	public PhotoRecord(int id, String uri){
		this.imageId = id;
		this.imagePath = uri;
	}
	
	public PhotoRecord() {
	}
	
	public PhotoRecord(String localPath){
		this.localPath = localPath;
	}

	public void setRecordType(int type){
		recordType = type;
	}
	
	public int getRecordType(){
		return recordType;
	}
	
	public int getRecordInfoId(){
		return this.recordInfoId;
	}
	
	public void setRecordInfoId(int recordInfoId){
		this.recordInfoId = recordInfoId;
	}
	
	public void setState(int st){
		this.state = st;
	}
	
	public int getState(){
		return state;
	}
	
	public boolean isShared(){
		return isShared;
	}
	
	public void setIsShared(boolean shared){
		isShared = shared;
	}
	
	
	
	public long getProcessTime() {
		return processTime;
	}

	public void setProcessTime(long processTime) {
		this.processTime = processTime;
	}

	@Override
	public void setAtttributeByjson(JSONObject json){
		super.setAtttributeByjson(json);
		this.recordInfoId = json.optInt("record_info_id");
		this.state = json.optInt("status");
		this.isShared = json.optBoolean("is_shared");
		this.recordType = json.optInt("record_type");
		this.processTime = json.optLong("process_time");
	}

	public JSONObject getJson(){
		JSONObject json = super.getJson();
		try {
			json.put("record_info_id", recordInfoId);
			json.put("status", state);
			json.put("is_shared", isShared);
			json.put("record_type", recordType);
			json.put("process_time", processTime);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return json;
	}
}
