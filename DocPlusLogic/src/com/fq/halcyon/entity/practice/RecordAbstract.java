package com.fq.halcyon.entity.practice;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.TimeFormatUtils;

/**
 * 病历记录的摘要类，存放一个记录的摘要信息，便于显示及查看
 * @author reason
 *
 */
public class RecordAbstract extends RecordData{

	private static final long serialVersionUID = 1L;

	/**记录的类型，分为一般和体检*/
	private int recordCategory;
	
	/**病历记录的类型*/
	private int recordType;
	
	/**病历记录的摘要信息*/
	private String infoAbstract;
	
	/**病历记录的识别状态*/
	private int recStatus;
	
	/**病历记录的记录详情id*/
	private int recordInfoId;
	
	/**病历记录的id*/
	private int recordItemId;
	
	/**病历记录的识别完成时间*/
	private String dealTime;
	
	/**病历记录归档时间*/
	private String fileTime;
	
	/**病历记录的名字*/
	private String recordItemName;
	
	/**记录显示的类型名字*/
	private String typeName;
	

	
	/**记录所属病案的名称，用于从记录详情返回到病案下所有记录列表*/
	private String patientName;
//	/**病案删除时间，如果该病案被删除，则有此参数*/
//	private String deleteTime;
	
//	/**这份记录是不是选中*/
//	private boolean isSelected;
	
	private ArrayList<Integer> imgIds = new ArrayList<Integer>();
	
	/**记录的附件*/
	private HashMap<String, ArrayList<PhotoRecord>> mAttachmentImageId = new HashMap<String, ArrayList<PhotoRecord>>();
	
	/**是否去身份化，默认不去，用于分享病案时聊天处显示*/
	private boolean isShowIdentity = true;
	
	/**
	 * 病案信息
	 */
	public PatientInfo patientInfo = new PatientInfo();
	
	public PatientInfo getPatientInfo() {
		return patientInfo;
	}

	public void setPatientInfo(PatientInfo patientInfo) {
		this.patientInfo = patientInfo;
	}
	
	public int getRecordType() {
		return recordType;
	}

	public void setRecordType(int recordType) {
		this.recordType = recordType;
	}

	public String getInfoAbstract() {
		return infoAbstract;
	}

	public void setInfoAbstract(String infoAbstract) {
		this.infoAbstract = infoAbstract;
	}

	public int getRecStatus() {
		return recStatus;
	}

	public void setRecStatus(int recStatus) {
		this.recStatus = recStatus;
	}

	public int getRecordInfoId() {
		return recordInfoId;
	}

	public void setRecordInfoId(int itemInfoId) {
		this.recordInfoId = itemInfoId;
	}

	public int getRecordItemId() {
		return recordItemId;
	}

	public void setRecordItemId(int recordItemId) {
		this.recordItemId = recordItemId;
	}
	
	public String getDealTime() {
		return dealTime;
	}

	public void setDealTime(String dealTime) {
		this.dealTime = dealTime;
	}
//	
//	public String getDeleteTime() {
//		return deleteTime;
//	}
//
//	public void setDeleteTime(String deleteTime) {
//		this.deleteTime = deleteTime;
//	}
	
	public String getFileTime() {
		return fileTime;
	}

	public void setFileTime(String filetime) {
		this.fileTime = filetime;
	}

	public void setRecordItemName(String name){
		this.recordItemName = name;
	}
	
	public String getRecordItemName(){
		if(!isShowIdentity){
			return "<去身份化>";
		}
		return recordItemName;
	}
	
	public String getTypeName(){
		return typeName;
	}
	
	public String getPatientName(){
		return patientName;
	}
	
	public void setImgIds(ArrayList<Integer> ids){
		imgIds = ids;
	}
	
	public ArrayList<Integer> getImgIds(){
		return imgIds;
	}
	
	public int getRecordCagegory(){
		return recordCategory;
	}
	
	/**deal的转化形式，用于显示列表item上的记录时间，格式：yyyy年MM月dd日*/
	private String deal2Time;
	public String getDeal2Time(){
		if(deal2Time == null){
			if("".equals(dealTime)){
				deal2Time = "";
			}else{
				deal2Time = TimeFormatUtils.changeDealTime(dealTime);
			}
		}
		return deal2Time;
	}
	
	/**得到记录下的图片*/
	public ArrayList<PhotoRecord> getImgPhotos(){
		ArrayList<PhotoRecord> photos = new ArrayList<PhotoRecord>();
		if(imgIds == null || imgIds.size() == 0)return photos;
		
		for(int i = 0; i < imgIds.size(); i++){
        	PhotoRecord photo = new PhotoRecord();
        	photo.setImageId(imgIds.get(i));
        	photos.add(photo);
        }
		return photos;
	}
	
	
	/**
	 * 得到记录图片附件的ids的map 
	 * @return
	 */
	public HashMap<String, ArrayList<PhotoRecord>> getAttachImgIdsMap(){
		return mAttachmentImageId;
	}
	
	public void setAttachImgIdsMap(HashMap<String, ArrayList<PhotoRecord>> map){
		mAttachmentImageId = map;
	}
	
	/**
	 * 设置该病案是否去身份化
	 * isb:true不去身份化； false:去身份化
	 */
	public void setIsShowIdentity(boolean isb){
		isShowIdentity = isb;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		
		recordCategory = json.optInt("record_category", RecordConstants.PATIENT_CATEGORY_NORMAL);
		recordType = json.optInt("record_type");
		recordItemName = json.optString("record_item_name");
		infoAbstract = json.optString("info_abstract", "");
		recStatus = json.optInt("rec_status");
		recordInfoId = json.optInt("record_info_id");	
		recordItemId = json.optInt("record_item_id");
		fileTime = json.optString("file_time");
		deleteTime = json.optString("deleted_at");
		dealTime = json.optString("deal_time");
		patientName = json.optString("patient_name");
		typeName = json.optString("type_name");
		if("".equals(typeName) || "null".equals(typeName)){
			typeName = RecordConstants.getTypeNameByRecordType(recordType);
		}
        JSONObject jsonObj1 = json.optJSONObject("patient_info");
        if(jsonObj1 != null){
            this.patientInfo.setAtttributeByjson(jsonObj1);
        }
		
		//将“null”转为""
		infoAbstract = checkNull(infoAbstract);
		deleteTime = checkNull(deleteTime);
		fileTime = checkNull(fileTime);
		deleteTime = checkNull(deleteTime);
		dealTime = checkNull(dealTime);
		patientName = checkNull(patientName);
		recordItemName = checkNull(recordItemName);
		
		JSONArray imgs = json.optJSONArray("images");
		if(imgs != null){
            imgIds.clear();
			for(int i = 0; i < imgs.length(); i++){
				imgIds.add(imgs.optInt(i));
			}
		}
		
		//解析记录的附件图片Id
		JSONArray attachmetns = json.optJSONArray("images_attachment");
		if (attachmetns != null){
			for(int i = 0; i < attachmetns.length(); i++){
				try {
					JSONObject item = attachmetns.getJSONObject(i);
					String date = item.optString("created_at");
					
					ArrayList<PhotoRecord> imageIds = mAttachmentImageId.get(date);
					if(imageIds == null){
						imageIds = new ArrayList<PhotoRecord>();
						mAttachmentImageId.put(date, imageIds);
					}
					
					JSONArray ids = item.optJSONArray("images");
					for(int j = 0; j < ids.length(); j++){
						PhotoRecord photo = new PhotoRecord();
						photo.setImageId(ids.optInt(j));
						imageIds.add(photo);
					}
				} catch (Exception e) {
				}
			}
		}
	}
	
	@Override
	public JSONObject getJson() {
		JSONObject json = new JSONObject();
		try{
			json.put("record_category", recordCategory);
			json.put("record_type", recordType);
			json.put("record_item_name", recordItemName);
			json.put("info_abstract", infoAbstract);
			json.put("rec_status", recStatus);
			json.put("record_info_id", recordInfoId);
			json.put("record_item_id", recordItemId);
			json.put("file_time", fileTime);
			json.put("deal_time", dealTime);
			json.put("type_name", typeName);
			json.put("patient_name", patientName);
			if(imgIds != null){
				JSONArray imgs = new JSONArray(imgIds);
				json.put("images", imgs);
			}
		}catch(Exception e){
			FQLog.i("构建病历记录json数据出错");
			e.printStackTrace();
		}
		return json;
	}
	
	/**
	 * 病案info的实体类
	 */
	public class PatientInfo extends HalcyonEntity{

		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;
		/**
		 * 病案ID
		 */
		private int patientId;
		/**
		 * 病案名称
		 */
		private String patientName;
		public int getPatientId() {
			return patientId;
		}

		public void setPatientId(int patientId) {
			this.patientId = patientId;
		}

		public String getPatientName() {
			return patientName;
		}

		public void setPatientName(String patientName) {
			this.patientName = patientName;
		}

		public String getHometown() {
			return hometown;
		}

		public void setHometown(String hometown) {
			this.hometown = hometown;
		}

		public int getAge() {
			return age;
		}

		public void setAge(int age) {
			this.age = age;
		}

		public String getName() {
			return name;
		}

		public void setName(String name) {
			this.name = name;
		}

		public String getGender() {
			return gender;
		}

		public void setGender(String gender) {
			this.gender = gender;
		}

		public String getDiagnose() {
			return diagnose;
		}

		public void setDiagnose(String diagnose) {
			this.diagnose = diagnose;
		}
		/**
		 * 病案分享者的头像的imageId
		 */
		private int mUserImageId;
		/**
		 * 家
		 */
		private String hometown;
		/**
		 * 年龄
		 */
		private int age;
		/**
		 * 姓名
		 */
		private String name;
		/**
		 * 性别
		 */
		private String gender;
		/**
		 * 诊断
		 */
		private String diagnose;
		private String showSecond;
		private String showThrid;
		private String showName;
		private String birth;//出生年月
		public String getBirth() {
			return birth;
		}

		public void setBirth(String birth) {
			this.birth = birth;
		}
		@Override
		public void setAtttributeByjson(JSONObject json) {
			this.hometown = json.optString("home_town");
			this.patientName = json.optString("patient_name");
			this.age = json.optInt("age");
			this.name = json.optString("name");
			this.gender = json.optString("gender");
			this.patientId = json.optInt("patient_id");
			this.diagnose = json.optString("diagnose");
			this.birth = json.optString("birth_year");
			this.mUserImageId = json.optInt("share_user_image");
			setShowSecond("");
			setShowThrid("");
			patientName = checkNull(patientName);
			diagnose = checkNull(diagnose);
			if("".equals(diagnose))diagnose="<诊断>";
			gender = checkNull(gender);
			birth = checkNull(birth);
			if("".equals(patientName))patientName="<姓名>";
			if("".equals(gender))gender="<性别>";
			if("".equals(birth))birth="<出生年>";
			String secondName = createSenondName();
			if(!"".equals(secondName)){
				setShowName(secondName);
			}else{
				setShowName(patientName);
			}
			
			showSecond = "";
			showThrid = "";
			do{
	            String[] dias = diagnose.split("\n");
	            if(dias.length == 0) break;
	            showSecond = dias[0];
	             if(dias.length == 1) break;
	             showThrid = dias[1];
	        }while (false);

		}

		
		@Override
		public void test() {
			
		}

		public String getShowThrid() {
			return showThrid;
		}

		public void setShowThrid(String showThrid) {
			this.showThrid = showThrid;
		}

		public String getShowSecond() {
			return showSecond;
		}

		public void setShowSecond(String showSecond) {
			this.showSecond = showSecond;
		}	
		
		//获得病案显示的第二名称（patientName为第一名称，第二名称规则：姓名+性别+出生年月）
		public String createSenondName(){
			String secondName = null;
			
			ArrayList<String> cells = new ArrayList<String>();
			if(!"".equals(patientName))cells.add(patientName);
			if(!"".equals(gender))cells.add(gender);
			if(!"".equals(birth))cells.add(birth);
			int size = cells.size();
			if(size == 3)secondName = patientName+"-"+gender+"-"+ birth;
			else if(size == 2)secondName = cells.get(0)+"-"+cells.get(1);
			else if(size == 1)secondName = cells.get(0);
			else secondName = "";
			
			return secondName;
		}

		public String getShowName() {
			return showName;
		}

		public void setShowName(String showName) {
			this.showName = showName;
		}

		public int getmUserImageId() {
			return mUserImageId;
		}

		public void setmUserImageId(int mUserImageId) {
			this.mUserImageId = mUserImageId;
		}
	}
	
}
