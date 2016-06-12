package com.fq.halcyon.entity.practice;

import java.util.ArrayList;
import java.util.Calendar;

import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.TimeFormatUtils;

/**
 * 病案信息，一份病案的基本内容<br/>
 * 病案只有名字没有摘要
 * @author reason
 *
 */
public class PatientAbstract extends RecordData{

	private static final long serialVersionUID = 1L;

	/**
	 * 病案阅读(访问)的时间
	 */
	private Calendar mReadCalender;

	/**
	 * 病案分享者的头像的imageId
	 */
	private int mUserImageId;
	
	/**
	 * 这个病案里面含有的记录数
	 */
	private int mRecordCount;
	
	/**
	 * 病案的id
	 */
	private int mPatientId;
	
	/**分享者的id*/
	private int shareUserId;
	
	/**
	 * 这份病案是否是别人分享的
	 */
	private boolean isShared;
	
	/**病案的名字*/
	private String patientName;
	
	/**病案删除时间，如果该病案被删除，则有此参数*/
	private String deleteTime;
	
	private String updateTime;
	
	/**是否去身份化，默认不去，用于分享病案时聊天处显示*/
	private boolean isShowIdentity = true;
	
	//用于病案名称的显示
	private String bname;
	public String getBname() {
		return bname;
	}

	public void setBname(String bname) {
		this.bname = bname;
	}

	private String gender;
	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	private String birth;//出生年月
	public String getBirth() {
		return birth;
	}

	public void setBirth(String birth) {
		this.birth = birth;
	}

	private String diagnose;
//	private String secondName;
	
	
	private String showName;
	public void setShowName(String showName) {
		this.showName = showName;
	}

	private String showSecond;
	private String showThrid;
	
	public Calendar getReadCalender() {
		return mReadCalender;
	}

	public void setReadCalender(Calendar mCalender) {
		this.mReadCalender = mCalender;
	}

	public int getUserImageId() {
		return mUserImageId;
	}

	public void setUserImageId(int mUserImageId) {
		this.mUserImageId = mUserImageId;
	}
	
	public int getShareUserId(){
		return shareUserId;
	}

	public int getRecordCount() {
		return mRecordCount;
	}

	public void setRecordCount(int mRecordCount) {
		this.mRecordCount = mRecordCount;
	}

	public int getPatientId() {
		return mPatientId;
	}

	public void setPatientId(int mPatientId) {
		this.mPatientId = mPatientId;
	}

	public boolean isShared() {
		return isShared;
	}

	public void setShared(boolean isShared) {
		this.isShared = isShared;
	}
	
	public void setPatientName(String name){
		this.patientName = name;
	}
	
	public String getPatientName(){
		return patientName;
	}
	
	public String getDeleteTime(){
		return deleteTime;
	}
	
	public void setUpdateTime(String time){
		updateTime = time;
	}
	
	public String getUpdateTime(){
		return updateTime;
	}
	

	public String getDiagnose(){
		return diagnose;
	}
	
	public void setDiagnose(String dis){
		diagnose = dis;
	}
	
	public String getShowName(){
		if(!isShowIdentity && !showName.contains("<去身份化>")){
			if(showName.contains(patientName)){
				showName = showName.replace(patientName, "<去身份化>");
			}else{
                StringBuffer str = new StringBuffer("<去身份化>");
                if(!"".equals(gender))str.append("-"+gender);
                if(!"".equals(birth))str.append("-"+birth);
                showName = str.toString();
			}
		}
		return showName;
	}
	
	public void setShowSecond(String showSecond) {
		this.showSecond = showSecond;
	}

	public void setShowThrid(String showThrid) {
		this.showThrid = showThrid;
	}

	public String getShowSecond(){
		return showSecond;
	}
	
	public String getShowThrid(){
		return showThrid;
	}
	
	//获得病案显示的第二名称（patientName为第一名称，第二名称规则：姓名+性别+出生年月）
	public String createSenondName(){
		String secondName = null;
		
		ArrayList<String> cells = new ArrayList<String>();
		if(!"".equals(bname))cells.add(bname);
		if(!"".equals(gender))cells.add(gender);
		if(!"".equals(birth))cells.add(birth);
		
		int size = cells.size();
		if(size == 3)secondName = bname+"-"+gender+"-"+birth;
		else if(size == 2)secondName = cells.get(0)+"-"+cells.get(1);
		else if(size == 1)secondName = cells.get(0);
		else secondName = "";
		
		return secondName;
	}
	
	/**
	 * 设置该病案是否去身份化
	 * isb:true不去身份化； false:去身份化
	 */
	public void setIsShowIdentity(boolean isb){
		isShowIdentity = isb;
	}
	
//	public void setSecondName(String secdName){
//		secondName = secdName;
//	}
	
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.mPatientId = json.optInt("patient_id");
		this.shareUserId = json.optInt("share_user_id");
		this.patientName = json.optString("name");
		this.deleteTime = json.optString("deleted_at");
		this.mRecordCount = json.optInt("record_item_count");
		this.mUserImageId = json.optInt("share_user_image");	
		this.updateTime = json.optString("updated_at");
		this.diagnose = json.optString("diagnose");
		
		
		
		patientName = checkNull(patientName);
		deleteTime = checkNull(deleteTime);
		updateTime = checkNull(updateTime);
		diagnose = checkNull(diagnose);
		if("".equals(diagnose))diagnose="<诊断>";
		
		String readTime = json.optString("read_time");
		if(!"".equals(readTime) && !"null".equals(readTime)){
			this.mReadCalender = TimeFormatUtils.getCalendar4Str(readTime, "yyyy-MM-dd HH:mm:ss");
		}
		
		
		//病案显示的名字
		this.bname = json.optString("patient_name");//患者的名字，并不是病案的名字
		this.gender = json.optString("gender");
		this.birth = json.optString("birth_year");
		bname = checkNull(bname);
		gender = checkNull(gender);
		birth = checkNull(birth);
		if("".equals(bname))bname="<姓名>";
		if("".equals(gender))gender="<性别>";
		if("".equals(birth))birth="<出生年>";
		
		String secondName = createSenondName();
		if(!"".equals(secondName)){
			showName = secondName;
		}else{
			showName = patientName;
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
	public JSONObject getJson() {
		JSONObject json = null;
		try {
			json = new JSONObject();
			json.put("patient_id", mPatientId);
			json.put("share_user_id", shareUserId);
			
			json.put("name", patientName);
			json.put("deleted_at", deleteTime);
			json.put("record_item_count", mRecordCount);
			json.put("share_user_image", mUserImageId);
			json.put("updated_at", updateTime);
			
			json.put("name", bname);
			json.put("gender", gender);
			json.put("birth_year", birth);
			json.put("diagnose", diagnose);
			
			if(mReadCalender != null){
				json.put("read_time", TimeFormatUtils.getTimeByFormat(mReadCalender.getTimeInMillis(),"yyyy-MM-dd HH:mm:ss"));
			}
		} catch (Exception e) {
			FQLog.i("构建PatientAbstract数据出错");
			e.printStackTrace();
		}
		return json;
	}
}
