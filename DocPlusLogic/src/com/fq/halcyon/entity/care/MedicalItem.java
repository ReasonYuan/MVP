package com.fq.halcyon.entity.care;

import java.util.ArrayList;

import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;

/***
 * 用户一份体检报告中的某一项体检项目
 * @author reason
 */
public class MedicalItem extends HalcyonEntity{
	
	private static final long serialVersionUID = 1L;

	/**体检项目的infoId*/
	private int infoId;
	
	/**体检项目原图的id集合*/
	private ArrayList<PhotoRecord> imgPhotos = new ArrayList<PhotoRecord>();
	
	/**体检项目的显示名称*/
	private String typeName;
	
	/**体检项目的检查得分*/
	private String checkScore;
	
	/**体检项目所检查的部分*/
	private String checkPosition;

	public int getInfoId() {
		return infoId;
	}

	public void setInfoId(int infoId) {
		this.infoId = infoId;
	}

	public ArrayList<PhotoRecord> getPhotos() {
		return imgPhotos;
	}

	public void setPhotos(ArrayList<PhotoRecord> imgIds) {
		this.imgPhotos = imgIds;
	}
	
	public String getTypeName() {
		return typeName;
	}

	public void setTypeName(String typeName) {
		this.typeName = typeName;
	}

	public String getCheckScore() {
		return checkScore;
	}

	public void setCheckScore(String checkScore) {
		this.checkScore = checkScore;
	}

	public String getCheckPosition() {
		return checkPosition;
	}

	public void setCheckPosition(String checkPosition) {
		this.checkPosition = checkPosition;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
//		super.setAtttributeByjson(json);
		this.infoId = json.optInt("info_id");
		this.typeName = checkNull(json.optString("type_name"));
		this.checkScore = checkNull(json.optString("check_score"));
		this.checkPosition = checkNull(json.optString("check_position"));
		
		JSONArray array = json.optJSONArray("images");
        if(array != null){
        	imgPhotos.clear();
            for(int i = 0; i < array.length(); i++){
                try {
                	PhotoRecord photo = new PhotoRecord();
                	photo.setImageId(array.getInt(i));
                	imgPhotos.add(photo);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }
	}
	
}
