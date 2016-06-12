package com.fq.halcyon.entity.practice;

import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.lib.json.JSONObject;

/**
 * 病案和记录 摘要(目录)的基类<br/>
 * 即:PatientAbstract和RecordAbstract都继承于该类<br/>
 * 这样实现，主要是用于回收站数据的分组显示
 * @author reason
 */
public abstract class RecordData extends HalcyonEntity{

	public static final int CATEGORY_PATIENT = 0;
	public static final int CATEGORY_RECORD = 1;
	
	private static final long serialVersionUID = 1L;

	/**删除的数据类型*/
	protected int category;
	
	/**删除数据的时间，如果该病*被删除，则有此参数*/
	protected String deleteTime;
	
	/**是否被选中的状态*/
	private boolean isSelected;
	
//	/**病案id*/
//	private int patientId;
//	/**病案名字*/
//	private String patientName;
//	/**病案内含有记录数量*/
//	private int recordCount;
//	/**分享着的头像id*/
//	private int userHeadImgId;
//	
//	/**记录的摘要*/
//	private String recordInfoAbs;
//	/**记录的识别状态*/
//	private int recordRecStatus;
//	/**记录的类型*/
//	private int recordType;
//	/**记录的itemId*/
//	private int recordItemId;
//	/**记录的名字*/
//	private String recordItemName;
	
//	private RecordAbstract recordAbstract;
//	
//	private PatientAbstract patientAbstract;

	public int getCategory() {
		return category;
	}

	public void setCategory(int category) {
		this.category = category;
	}

	public String getDeleteTime() {
		return deleteTime;
	}

	public void setDeleteTime(String deleteTime) {
		this.deleteTime = deleteTime;
	}
	
	public boolean isSelected() {
		return isSelected;
	}

	public void setSelected(boolean isSelected) {
		this.isSelected = isSelected;
	}
//	public int getPatientId() {
//		return patientId;
//	}
//
//	public void setPatientId(int patientId) {
//		this.patientId = patientId;
//	}
//
//	public String getPatientName() {
//		return patientName;
//	}
//
//	public void setPatientName(String patientName) {
//		this.patientName = patientName;
//	}
//
//	public int getRecordCount() {
//		return recordCount;
//	}
//
//	public void setRecordCount(int recordCount) {
//		this.recordCount = recordCount;
//	}
//
//	public int getUserHeadImage() {
//		return userHeadImgId;
//	}
//
//	public void setUserHeadImage(int userHeadImage) {
//		this.userHeadImgId = userHeadImage;
//	}
//
//	public String getInfoAbstract() {
//		return recordInfoAbs;
//	}
//
//	public void setInfoAbstract(String infoAbstract) {
//		this.recordInfoAbs = infoAbstract;
//	}
//
//	public int getRecStatus() {
//		return recordRecStatus;
//	}
//
//	public void setRecStatus(int recStatus) {
//		this.recordRecStatus = recStatus;
//	}
//
//	public int getRecordType() {
//		return recordType;
//	}
//
//	public void setRecordType(int recordType) {
//		this.recordType = recordType;
//	}
//
//	public int getReordItemId() {
//		return recordItemId;
//	}
//
//	public void setReordItemId(int reordItemId) {
//		this.recordItemId = reordItemId;
//	}
//
//	public String getRecordItemName() {
//		return recordItemName;
//	}
//
//	public void setRecordItemName(String recordItemName) {
//		this.recordItemName = recordItemName;
//	}
//
//
//	String recordDealTime;
//	
//	
//	private String secondName;
//	private String diagnose;
//	
//	
//	public PatientAbstract getPatient(){
//		if(patientAbstract == null){
//			patientAbstract = new PatientAbstract();
//			patientAbstract.setPatientId(patientId);
//			patientAbstract.setPatientName(patientName);
//			patientAbstract.setRecordCount(recordCount);
//			patientAbstract.setUserImageId(userHeadImgId);
//			patientAbstract.setSecondName(secondName);
//			patientAbstract.setDiagnose(diagnose);
//		}
//		return patientAbstract;
//	}
//	
//	public RecordAbstract getRecordItem(){
//		if(recordAbstract == null){
//			recordAbstract = new RecordAbstract();
//			recordAbstract.setInfoAbstract(recordInfoAbs);
//			recordAbstract.setRecStatus(recordRecStatus);
//			recordAbstract.setRecordItemId(recordItemId);
//			recordAbstract.setRecordItemName(recordItemName);
//			recordAbstract.setDealTime(recordDealTime);
//		}
//		return recordAbstract;
//	}
	public void setAtttributeByjson(JSONObject json) {
	
		category = json.optInt("record_category");
		deleteTime = json.optString("deleted_at");
		
		deleteTime = checkNull(deleteTime);
		
//		if(category == CATEGORY_PATIENT){
//			patientId = json.optInt("patient_id");
//			patientName = json.optString("name");
//			recordCount = json.optInt("record_item_count");
//			userHeadImgId = json.optInt("share_user_image");
//			diagnose = json.optString("diagnose");
//			
//			patientName = checkNull(patientName);
//			diagnose = checkNull(diagnose);
//			
//			String bname = json.optString("patient_name");//患者的名字，并不是病案的名字
//			String gender = json.optString("gender");
//			String birth = json.optString("birth_year");
//			
//			ArrayList<String> cells = new ArrayList<String>();
//			if(!"".equals(bname))cells.add(bname);
//			if(!"".equals(gender))cells.add(gender);
//			if(!"".equals(birth))cells.add(birth);
//			int size = cells.size();
//			if(size == 3)secondName = bname+"-"+gender+"-"+birth;
//			else if(size == 2)secondName = cells.get(0)+"-"+cells.get(1);
//			else if(size == 1)secondName = cells.get(0);
//			else secondName = "";
//		}else{
//			
//			recordInfoAbs = json.optString("info_abstract");
//			recordRecStatus = json.optInt("rec_status");
//			recordType = json.optInt("record_type");
//			recordItemId = json.optInt("record_item_id");
//			recordItemName = json.optString("record_item_name");
//			recordDealTime = json.optString("deal_time");
//			
//			recordInfoAbs = checkNull(recordInfoAbs);
//			recordItemName = checkNull(recordItemName);
//			recordDealTime = checkNull(deleteTime);
//		}
	}
	
	@Override
	public JSONObject getJson() {
		return null;
	}
}
