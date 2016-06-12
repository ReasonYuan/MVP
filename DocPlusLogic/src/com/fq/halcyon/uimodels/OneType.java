package com.fq.halcyon.uimodels;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.UUID;

import com.fq.halcyon.entity.PhotoRecord;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;

/**
	 * 一种类型， 比如入院、出院、化验等
	 */
	public class OneType implements Serializable{
		
	private static final long serialVersionUID = 1L;

		/**
		 * 病历类型的type
		 */
		private int type = 0;
		
		ArrayList<OneCopy> copies = new ArrayList<OneCopy>();
		
		public OneType(int type){
			this.type = type;
		}
		
		public void AddOneCopy(OneCopy oneCopy){
			copies.add(oneCopy);
		}
		
		public final String uuid = UUID.randomUUID().toString();
		
		public void addOneCopys(ArrayList<OneCopy> copies){
			for(int i = 0; i < copies.size(); i++){
				OneCopy copy = copies.get(i);
				if(copy.getPhotos().size() > 0){
					this.copies.add(copy);
				}
			}
		}

		public int getType(){
			return type;
		}
		
		public int getUITypeIndex() {
			return type;
		}

		public void setUITypeIndex(int typeIndex) {
			type = typeIndex;
		}
		
		public OneCopy getCopyById(int index){
			return copies.get(index);
		}
		
		public ArrayList<OneCopy> getAllCopies(){
			return copies;
		}
		
		public OneCopy lastCopy(){
			if (copies.size() > 0) {
				return copies.get(copies.size() - 1);
			} else {
				return null;
			}
		}
		
		/**
		 * @return
		 * 		- 对应的服务器病历类型
		 */
//		public int getType(){
//			return Constants.TYPES[type];
//		}
		
		public JSONObject getJsonObj(){
			JSONObject json = new JSONObject();
			JSONArray jsonArray = new JSONArray();
			for(int i = 0; i < copies.size(); i++){
				OneCopy copy = copies.get(i);
				jsonArray.put(copy.getJsonObj());
			}
			try {
				json.put("uiTypeIndex", type);
				json.put("copies", jsonArray);
			} catch (JSONException e) {
				e.printStackTrace();
			}
			return json;
		}
		
		public void setAtttributeByjson(JSONObject json){
			try{
				type = json.getInt("uiTypeIndex");
				JSONArray array = json.optJSONArray("copies");
				if(array.length() < 1)return;
				for(int i = 0; i < array.length(); i++){
					OneCopy copy = new OneCopy(type);
					copy.setAtttributeByjson(array.getJSONObject(i));
					copies.add(copy);
				}
			}catch(Exception e){
				e.printStackTrace();
				return;
			}
		}	
		
		public ArrayList<PhotoRecord> getAllPhotos(){
			ArrayList<PhotoRecord> photos = new ArrayList<PhotoRecord>();
			for(int i = 0; i < copies.size(); i++){
				OneCopy copy = copies.get(i);
				photos.addAll(copy.getPhotos());
			}
			return photos;
		}
		
		public boolean isHavaPhotoById(int id){
			for(int i = 0; i < copies.size(); i++){
				if(copies.get(i).isHavePhotoById(id)){
					return true;
				}
			}
			return false;
		}
		
		public boolean isHavaPhotoByUrl(String url){
			for(int i = 0; i < copies.size(); i++){
				if(copies.get(i).isHavePhotoByUrl(url)){
					return true;
				}
			}
			return false;
		}
		
		public int getPhotoCounter(){
			int cnt = 0;
			for (int i = 0; i < copies.size(); i++) {
				cnt += copies.get(i).getPhotos().size();
			}
			return cnt;
		}
	}