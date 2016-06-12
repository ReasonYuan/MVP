package com.fq.halcyon.uimodels;

import java.io.Serializable;
import java.util.ArrayList;

import com.fq.halcyon.entity.PhotoRecord;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
	/**
	 * 一份病历
	 */
	public class OneCopy implements Serializable{

		private static final long serialVersionUID = 1L;

		private int recordId;
		
//		private OneType parent;

		private int indefyState;
		
		private int recordItemType;
		
		public OneCopy(int type) {
			this.recordItemType = type;
		}

		public ArrayList<PhotoRecord> photos = new ArrayList<PhotoRecord>();

		public void addPhoto(PhotoRecord photo) {
//			photo.index = photos.size();
			photos.add(photo);
		}

		/**
		 * @return - 病历记录的类型
		 */
		public int getType() {
			return recordItemType;
		}
		
		public void setType(int type){
			this.recordItemType = type;
		}
		
		public ArrayList<PhotoRecord> getPhotos(){
			return photos;
		}
		
		public void setRecrodId(int id){
			recordId = id;
		}
		
		public int getRecordId(){
			return recordId;
		}
		
		public void addPhotos(ArrayList<PhotoRecord> photos){
			photos.addAll(photos);
		}
		
		public void setIndefyState(int state){
			indefyState = state;
		}
		
		public int getIndefySate(){
			return indefyState;
		}
		
		public JSONObject getJsonObj(){
			JSONObject json = new JSONObject();
			JSONArray jsonArray = new JSONArray();
			for(int i = 0; i < photos.size(); i++){
				jsonArray.put(photos.get(i).getJson());
			}
			try {
				if(recordId != 0)json.put("record_id", recordId);
				json.put("photos", jsonArray);
			} catch (JSONException e) {
				e.printStackTrace();
			}
			return json;
		}
		
		public void setAtttributeByjson(JSONObject json){
			try{
				recordId = json.optInt("record_id");
				JSONArray array = json.optJSONArray("photos");
				if(array.length() < 1)return;
				for(int i = 0; i < array.length(); i++){
					PhotoRecord photo = new PhotoRecord();
					photo.setAtttributeByjson(array.getJSONObject(i));
					photos.add(photo);
				}
			}catch(Exception e){
				e.printStackTrace();
			}
		}	
		
		public int getOnePhotoId(){
			return photos.get(0).getImageId();
		}
		
		public boolean isHavePhotoById(int id){
			for(int i = 0; i < photos.size(); i++){
				if(id == photos.get(i).getImageId()){
					return true;
				}
			}
			return false;
		}
		
		public boolean isHavePhotoByUrl(String url){
			for(int i = 0; i < photos.size(); i++){
				if(url.equals(photos.get(i).getLocalPath())){
					return true;
				}
			}
			return false;
		}
}