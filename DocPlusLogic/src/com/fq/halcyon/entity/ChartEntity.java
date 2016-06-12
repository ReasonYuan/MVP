package com.fq.halcyon.entity;

import com.fq.halcyon.entity.practice.PatientAbstract;
import com.fq.halcyon.entity.practice.RecordAbstract;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;

public class ChartEntity extends HalcyonEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	/**
	 * 聊天用户名字
	 */
	private String userName;
	/**
	 * 名片名字
	 */
	private String cardName;
	

	/**
	 * 每个聊天者的userId，可以用于注册IMSDK，唯一
	 */
	private int userId;
	
	/**
	 * 消息的类型 1：基本的文本消息 2：发送病案 3：发送病历 4：图片  5:预约 6:名片 7.临时用来做为加好友消息 8.删除对方为好友时，同时对方删除本地记录和自己的记录
	 */
	private int messageType;
	
	/**
	 * 用户头像id
	 */
	private int userImageId;
	/**
	 * 发送消息的内容
	 */
	private String message;
	
//	/**
//	 * 附带病历或者病案的名字
//	 */
//	private String otherName;
//	
//	/**
//	 * 附带病历或者病案的Id
//	 */
//	private String otherId;
//	
	/**
	 * 发送图片的imageId
	 */
	private int messageImageId;
	
	/**
	 * 发送图片本地的路劲，用于显示自己的UI
	 */
	private String ImagePath;
	
	/**
	 * 发送图片的高
	 */
	private float ImageHeight;
	
	/**
	 * 发送图片的宽
	 */
	private float ImageWidth;
	
	/**
	 * 
	 * 消息发送的时间
	 */
	
	private double mSendTime;
	
	/**属于某个医院**/
	private String hospital;
	
	/**属于某个科室**/
	private String department;
	
	/***********以下为病案特有的字段**********/
	
	/**病案所属者头像id**/
	private int patientHeadId;
	
	/**病案摘要**/
	private String patientContent;
	
	/**病案摘要第一行**/
	private String patientName;
	
	/**病案摘要第二行**/
	private String patientSecond;
	
	/**病案摘要第三行**/
	private String patientThird;
	
	/**该病案下记录条数**/
	private int patientRecordCount;

	/**share_patient_id真正发送的病案id**/
	private int sharePatientId;
	
	/*****病案、记录都需要发送这个参数*****/
	/**share_message_id**/
	private int sharemessageId;
	
	
	/***********以下为记录特有的字段**********/
	
	/**
	 * 记录类型
	 */
	private int recordType;
	/**
	 * 记录时间
	 */
	private String  recordTime;
	
	/**
	 * 记录所属病人的名字
	 */
	private String recordBelongName;
	
	/**
	 * 记录摘要信息
	 */
	private String recordContent;
	
	/***
	 * 
	 *记录id
	 */
	private int shareRecordItemId;
	
	/**
	 * 记录InfoID
	 */
	private int recordInfoId;
	
//	/**
//	 * 记录是否识别
//	 */
//	private int recStatus;
	
	/**
	 * 标记消息是否发送成功
	 */
	private boolean isSendSuccess = true;
	
	/**
	 * 标记每条发送消息的位置
	 */
	private int messageIndex;
	
	/**发送图片的状态 隐藏progressbar  1显示 0隐藏*/
	private int sendImageType;
	
	
	
	public String getCardName() {
		return cardName;
	}

	public void setCardName(String cardName) {
		this.cardName = cardName;
	}

	public int getSendImageType() {
		return sendImageType;
	}

	public void setSendImageType(int sendImageType) {
		this.sendImageType = sendImageType;
	}

	public String getPatientName() {
		return patientName;
	}

	public void setPatientName(String patientName) {
		this.patientName = patientName;
	}

	public String getPatientSecond() {
		return patientSecond;
	}

	public void setPatientSecond(String patientSecond) {
		this.patientSecond = patientSecond;
	}

	public String getPatientThird() {
		return patientThird;
	}

	public void setPatientThird(String patientThird) {
		this.patientThird = patientThird;
	}

	public float getImageHeight() {
		return ImageHeight;
	}

	public void setImageHeight(float imageHeight) {
		ImageHeight = imageHeight;
	}

	public float getImageWidth() {
		return ImageWidth;
	}

	public void setImageWidth(float imageWidth) {
		ImageWidth = imageWidth;
	}

	public String getImagePath() {
		return ImagePath;
	}

	public void setImagePath(String imagePath) {
		ImagePath = imagePath;
	}

	public int getMessageIndex() {
		return messageIndex;
	}

	public void setMessageIndex(int messageIndex) {
		this.messageIndex = messageIndex;
	}

	public boolean isSendSuccess() {
		return isSendSuccess;
	}

	public void setSendSuccess(boolean isSendSuccess) {
		this.isSendSuccess = isSendSuccess;
	}

//	public int getRecStatus() {
//		return recStatus;
//	}
//
//	public void setRecStatus(int recStatus) {
//		this.recStatus = recStatus;
//	}

	public int getRecordInfoId() {
		return recordInfoId;
	}

	public void setRecordInfoId(int recordInfoId) {
		this.recordInfoId = recordInfoId;
	}

	public String getDepartment() {
		return department;
	}

	public void setDepartment(String department) {
		this.department = department;
	}

	public String getHospital() {
		return hospital;
	}

	public void setHospital(String hospital) {
		this.hospital = hospital;
	}

	public double getmSendTime() {
		return mSendTime;
	}

	public void setmSendTime(double mSendTime) {
		this.mSendTime = mSendTime;
	}

	public int getRecordType() {
		return recordType;
	}

	public void setRecordType(int recordType) {
		this.recordType = recordType;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public int getMessageType() {
		return messageType;
	}

	public void setMessageType(int messageType) {
		this.messageType = messageType;
	}

	public int getUserImageId() {
		return userImageId;
	}

	public void setUserImageId(int userImageId) {
		this.userImageId = userImageId;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

//	public String getOtherName() {
//		return otherName;
//	}
//
//	public void setOtherName(String otherName) {
//		this.otherName = otherName;
//	}
//
//	public String getOtherId() {
//		return otherId;
//	}
//
//	public void setOtherId(String otherId) {
//		this.otherId = otherId;
//	}

	public int getMessageImageId() {
		return messageImageId;
	}

	public void setMessageImageId(int messageImageId) {
		this.messageImageId = messageImageId;
	}
	
	
	public int getPatientHeadId() {
		return patientHeadId;
	}

	public void setPatientHeadId(int patientHeadId) {
		this.patientHeadId = patientHeadId;
	}

	public String getPatientContent() {
		return patientContent;
	}

	public void setPatientContent(String patientContent) {
		this.patientContent = patientContent;
	}

	public int getPatientRecordCount() {
		return patientRecordCount;
	}

	public void setPatientRecordCount(int patientRecordCount) {
		this.patientRecordCount = patientRecordCount;
	}

	public int getSharePatientId() {
		return sharePatientId;
	}

	public void setSharePatientId(int sharePatientId) {
		this.sharePatientId = sharePatientId;
	}

	public int getSharemessageId() {
		return sharemessageId;
	}

	public void setSharemessageId(int sharemessageId) {
		this.sharemessageId = sharemessageId;
	}

	public String getRecordTime() {
		if (recordTime.equals("") || recordTime == null) {
			return recordTime;
		}else{
			return "("+recordTime+")";
		}
		
	}

	public void setRecordTime(String recordTime) {
		this.recordTime = recordTime;
	}

	public String getRecordBelongName() {
		return recordBelongName;
	}

	public void setRecordBelongName(String recordBelongName) {
		this.recordBelongName = recordBelongName;
	}

	public String getRecordContent() {
		return recordContent;
	}

	public void setRecordContent(String recordContent) {
		this.recordContent = recordContent;
	}

	public int getShareRecordItemId() {
		return shareRecordItemId;
	}

	public void setShareRecordItemId(int shareRecordItemId) {
		this.shareRecordItemId = shareRecordItemId;
	}

	public void setSharePatientEntity(PatientAbstract patientAbstract,int sharePatientId,int sharemessageId){
		this.sharemessageId = sharemessageId;
		this.sharePatientId = sharePatientId;
		this.messageType = 2;
		this.userImageId = Constants.getUser().getImageId();
		this.userId = Constants.getUser().getUserId();
		this.userName = Constants.getUser().getName();
		this.patientHeadId =  patientAbstract.getUserImageId();
		this.patientName = patientAbstract.getShowName();
		this.patientSecond = patientAbstract.getShowSecond();
		this.patientThird = patientAbstract.getShowThrid();
		this.patientRecordCount = patientAbstract.getRecordCount();
		
	}
	
	public void setShareRecordEntity(RecordAbstract recordAbstract,int shareRecordItemId,int sharemessageId){
		this.sharemessageId = sharemessageId;
		this.shareRecordItemId = shareRecordItemId;
		this.messageType = 3;
		this.userImageId = Constants.getUser().getImageId();
		this.userId = Constants.getUser().getUserId();
		this.userName = Constants.getUser().getName();
		this.recordType = recordAbstract.getRecordType();
		this.recordTime = recordAbstract.getDealTime();
		this.recordBelongName = recordAbstract.getRecordItemName();
		this.recordContent = recordAbstract.getInfoAbstract();
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		this.userName = json.optString("userName");
		this.userId = json.optInt("userId");
		this.messageType = json.optInt("messageType");
		this.userImageId = json.optInt("userImageId");
		this.message = json.optString("message");
//		this.otherId = json.optString("otherId");
//		this.otherName = json.optString("otherName");
		this.messageImageId = json.optInt("messageImageId");
		this.recordType = json.optInt("recordType");
		this.mSendTime = json.optDouble("mSendTime");
		this.hospital = json.optString("hospital");
		this.department = json.optString("department");
		this.patientHeadId = json.optInt("patientHeadId");
		this.patientContent = json.optString("patientContent");
		this.patientRecordCount = json.optInt("patientRecordCount");
		this.sharePatientId = json.optInt("sharePatientId");
		this.sharemessageId = json.optInt("sharemessageId");
		this.recordTime = json.optString("recordTime");
		this.recordBelongName = json.optString("recordBelongName");
		this.recordContent = json.optString("recordContent");
		this.shareRecordItemId = json.optInt("shareRecordItemId");
		this.recordInfoId = json.optInt("recordInfoId");
//		this.recStatus = json.optInt("recStatus");
		this.isSendSuccess = json.optBoolean("isSendSuccess");
		this.messageIndex = json.optInt("messageIndex");
		this.ImagePath = json.optString("ImagePath");
		this.ImageHeight = (float) json.optDouble("ImageHeight");
		this.ImageWidth = (float)json.optDouble("ImageWidth");
		this.patientName = json.optString("patientName");
		this.patientSecond = json.optString("patientSecond");
		this.patientThird = json.optString("patientThird");
		this.sendImageType = json.optInt("sendImageType");
		this.cardName = json.optString("cardName");
		
	}
	
	public void setAtttributeByjsonString(String json){
		try {
			String decode = new String(json.getBytes(), "UTF-8");
			JSONObject jsonObject = new JSONObject(decode);
			setAtttributeByjson(jsonObject);
		} catch (Exception e) {
			try {
				System.out.println(new String(json.getBytes(), "UTF-8"));
			} catch (Exception e2) {
			}
			e.printStackTrace();
		}
	}
	
	@Override
	public String toString() {
		JSONObject json = new JSONObject();
		try {
			json.put("userName", userName);
			json.put("userId", userId);
			json.put("messageType", messageType);
			json.put("userImageId", userImageId);
			json.put("message", message);
			json.put("messageIndex", messageIndex);
			json.put("mSendTime", mSendTime);
			json.put("isSendSuccess", isSendSuccess);
			
			switch (messageType) {
			case 1://普通消息
				
				break;
			case 2://发送病案
				json.put("patientName", patientName);
				json.put("patientSecond", patientSecond);
				json.put("patientThird", patientThird);
				json.put("patientHeadId", patientHeadId);
				json.put("patientContent", patientContent);
				json.put("patientRecordCount", patientRecordCount);
				json.put("sharePatientId", sharePatientId);
				json.put("sharemessageId", sharemessageId);
				break;
			case 3://发送记录
				json.put("recordType", recordType);
				json.put("recordTime", recordTime);
				json.put("recordBelongName", recordBelongName);
				json.put("recordContent", recordContent);
				json.put("shareRecordItemId", shareRecordItemId);
				json.put("recordInfoId",recordInfoId);
				json.put("sharemessageId", sharemessageId);
				break;
			case 4://发送图片
				json.put("messageImageId", messageImageId);
				json.put("ImagePath", ImagePath);
				json.put("ImageHeight", ImageHeight);
				json.put("ImageWidth", ImageWidth);
				json.put("sendImageType", sendImageType);
				break;
			case 6://发送名片
				json.put("cardName", cardName);
				json.put("hospital", hospital);
				json.put("department", department);
				break;
			default:
				break;
			}
	
			return json.toString();
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return json.toString();
	}
}
