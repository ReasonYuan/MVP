package com.fq.halcyon.entity;

import java.util.ArrayList;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.TimeFormatUtils;

/**
 * 病历记录简介（病历记录的一些简单信息）<br/>
 * 在浏览一个病历下的所有病历记录时需要用到
 * @author reason
 */
public class RecordItemSamp extends HalcyonEntity{
	
	
	/**
	 * 没有数据的状态，只负责UI显示
	 */
	public static final int REC_NONE_DATA = -2;
	/**
	 * 上传阶段
	 */
	public static final int REC_UPLOAD = -1;//
	/**
	 * 正在识别
	 */
	public static final int REC_ING = 1;
	/**
	 * 识别成功
	 */
	public static final int REC_SUCC = 2;
	/**
	 * 识别失败
	 */
	public static final int REC_FAIL = 3;
	
	private static final long serialVersionUID = 1L;
	
	private int recordType;
	/**
	 * 识别状态
	 */
	private int recStatus;
	private int recordItemId;
	private int recordInfoId;
	private int imageCount;
	private String uploadTime;
	private String infoabst;
	private ArrayList<PhotoRecord> mPhotos;
	
	/**是否为分享的病历*/
	private boolean isShared;
	
	/**是否为用户查看分享模式*/
	private boolean isShareModel;
	
	private String uuid;
	
	public String getUuid() {
		return uuid;
	}

	public void setUuid(String uuid) {
		this.uuid = uuid;
	}
	
	public int getRecordType(){
		return recordType;
	}
	
	public void setReocrdType(int type){
		recordType = type;
	}
	
	public void setPhotos(ArrayList<PhotoRecord> photos){
		mPhotos = photos;
	}
	
	public boolean isShared(){
		return isShared;
	}
	
	public void setIsShareModel(boolean isb){
		isShareModel = isb;
	}
	
	public ArrayList<PhotoRecord> getPhotos(){
		////检查的原图在分享状态仍是可看的
		if(recordType != RecordConstants.TYPE_MEDICAL_IMAGING && (isShared || isShareModel)){
			PhotoRecord photo = new PhotoRecord(-1, "");
			photo.setIsShared(true);
			ArrayList<PhotoRecord> ps = new ArrayList<PhotoRecord>();
			ps.add(photo);
			return ps;
		}
		if(mPhotos == null)mPhotos = new ArrayList<PhotoRecord>();
		return mPhotos;
	}
	
	public int getRecStatus() {
		return recStatus;
	}
	public void setRecStatus(int recStatus) {
		this.recStatus = recStatus;
	}
	public int getRecordItemId() {
		return recordItemId;
	}
	public void setRecordItemId(int recordItemId) {
		this.recordItemId = recordItemId;
	}
	public String getUploadTime() {
		return uploadTime;
	}
	public void setUploadTime(String uploadTime) {
		this.uploadTime = uploadTime;
	} 
	public void setImageCount(int count){
		this.imageCount = count;
	}
	public int getImageCount(){
		if(imageCount > 0){
			return imageCount;
		} else if(mPhotos != null){
			//刚拍摄的没有imageCount，所以另行计算
			return mPhotos.size();
		} 
		return 0;
	}
	public void setRecordInfoId(int infoId){
		this.recordInfoId = infoId;
	}
	public int getRecordInfoId(){
		return this.recordInfoId;
	}
	public String getInfoAbstract(){
		return this.infoabst;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		this.recStatus = json.optInt("rec_status");
		this.imageCount = json.optInt("image_count");
		this.recordItemId = json.optInt("record_item_id");
		this.recordInfoId = json.optInt("record_info_id");
		this.infoabst = json.optString("info_abstract");
		this.isShared = json.optBoolean("is_shared");
		
		uploadTime = json.optString("upload_time");
		
		if(!"".equals(uploadTime)){
			long date = TimeFormatUtils.getTimeMillisByDateWithSeconds(uploadTime,"yyyy-MM-dd HH:mm");
			if(date != 0){
				this.uploadTime = TimeFormatUtils.getTimeByFormat(date, "yyyy-MM-dd");
			}
		}
		
		mPhotos = new ArrayList<PhotoRecord>();
		//检查的原图在分享状态仍是可看的
		/*if(recordType != RecordConstants.TYPE_MEDICAL_IMAGING && (isShared||isShareModel)){
			PhotoRecord photo = new PhotoRecord(-1,"");
			photo.setRecordInfoId(recordInfoId);
			photo.setIsShared(true);
			mPhotos.add(photo);
		}else{*/
			JSONArray images = json.optJSONArray("images");
			//有时候服务器在没有图片的情况下未返回images字段，会报nullpointer exception
			if(images != null){
				for(int i = 0; i < images.length(); i++){
					PhotoRecord photo = new PhotoRecord();
					photo.setAtttributeByjson(images.optJSONObject(i));
					photo.setRecordInfoId(recordInfoId);
					mPhotos.add(photo);
				}
			}
//		}
	}
}
