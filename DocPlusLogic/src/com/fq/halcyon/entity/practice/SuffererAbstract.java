package com.fq.halcyon.entity.practice;

import com.fq.halcyon.entity.User;
import com.fq.lib.json.JSONObject;

/**
 * 患者的实体类，医生可以通过患者查看他的体检报告和病历报告
 * @author reason
 */
public class SuffererAbstract extends RecordData{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**患者的userId*/
	private int suffererId;
	
	/**患者的头像图片Id*/
	private int headImgId;
	
	/**患者姓名*/
	private String suffererName;
	
	/**患者性别*/
	private String gender;
	
	/**患者家庭成员数*/
	private int memberNumber;
	
	/**患者更新的时间，格式为：yyyyMMdd*/
	private String updateTime;
	
	/**患者与医生的关系id*/
	private int relationId;
	
	public String getSuffererName() {
		return suffererName;
	}

	public void setSuffererName(String suffererName) {
		this.suffererName = suffererName;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	public int getMemberNumber() {
		return memberNumber;
	}

	public void setMemberNumber(int memberNumber) {
		this.memberNumber = memberNumber;
	}

	public int getHeadImgId(){
		return headImgId;
	}
	
	public int getSuffererId(){
		return suffererId;
	}
	
	public void setSuffererId(int id){
		this.suffererId = id;
	}
	
	public String getUpdateTime(){
		return updateTime;
	}
	
	public int getRelationId(){
		return relationId;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		//super.setAtttributeByjson(json);
		relationId = json.optInt("user_doctor_relation_id");
		suffererId = json.optInt("user_id");
		headImgId = json.optInt("image_id");
		memberNumber = json.optInt("member_number");
		suffererName = checkNull(json.optString("name"));
		gender = User.getGender(json.optInt("gender"));
		updateTime = checkNull(json.optString("update_time"));
	}
}
