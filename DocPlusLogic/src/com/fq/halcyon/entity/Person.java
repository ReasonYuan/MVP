package com.fq.halcyon.entity;

import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;

public class Person extends HalcyonEntity{
	private static final long serialVersionUID = 1L;

	@Override
	public void test() {}

	protected String username; // 姓名
	protected String phone_number;
	protected String nickname;
	protected String description;
	protected int gender;
	protected int user_id;
	protected int role_type;
	protected int image_id;
	protected int age; // 年龄
	protected String dp_name;// 医家号
	
	//==YY==imageId(只要imageId)
//	protected int head_pic_image_id;
//	protected String head_pic;
	
	protected int doctor_id;
	protected String city;
	protected String hospital;
	protected String department;
	
	protected int title;// 职称
	protected String university;// 学校
	protected String major;// 专业
	protected int education;// 学历
	protected String entrance_time;// 入学时间
	
	/**
	 * 随访中使用的病案Id
	 */
	protected int patient_id;
	
	public int getPatient_id() {
		return patient_id;
	}

	public void setPatient_id(int patient_id) {
		this.patient_id = patient_id;
	}

	/*public int getHeadPicImageId() {
		return head_pic_image_id;
	}
	public void setHeadPicImageId(int head_pic_image_id) {
		this.head_pic_image_id = head_pic_image_id;
	}*/

	
	public void setImageId(int image_id) {
		this.image_id = image_id;
	}

	public int getImageId() {
		return image_id;
	}

	//==YY==imageId(只要imageId)
	/*public void setHeadPicPath(String head_pic) {
		this.head_pic = head_pic;
	}
	public String getHeadPicPath() {
		return head_pic == null ? "" : head_pic;
	}*/

	public void setDPName(String name) {
		this.dp_name = name;
	}

	public String getDPName() {
		if (dp_name == null)
			dp_name = "";
		return dp_name;
	}
	
	public String getPhoneNumber() {
		return phone_number;
	}

	public void setPhone_number(String phone_number) {
		this.phone_number = phone_number;
	}

	public String getNickname() {
		return nickname == null ? "" : nickname;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public String getDescription() {
		return description == null ? "" : description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public int getDoctorId() {
		return doctor_id;
	}

	public void setDoctorId(int id) {
		this.doctor_id = id;
	}

	public String getGenderStr() {
		return getGender(gender);
	}

	public int getGender() {
		return gender;
	}

	public void setGender(int gender) {
		this.gender = gender;
	}

	public int getUserId() {
		return user_id;
	}

	public void setUserId(int user_id) {
		this.user_id = user_id;
	}

	public int getRole_type() {
		return role_type;
	}

	public void setRole_type(int role_type) {
		this.role_type = role_type;
	}

	public String getCity() {
		return city == null ? "" : city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getHospital() {
		return hospital == null ? "" : hospital;
	}

	public void setHospital(String hospital) {
		this.hospital = hospital;
	}

	public String getDepartment() {
		return department == null ? "" : department;
	}

	public void setDepartment(String department) {
		this.department = department;
	}
	
	public int getTitle() {
		return title;
	}

	public void setTitle(int title) {
		this.title = title;
	}

	public String getUniversity() {
		return university;
	}

	public void setUniversity(String university) {
		this.university = university;
	}

	public String getMajor() {
		return major;
	}

	public void setMajor(String major) {
		this.major = major;
	}

	public int getEducation() {
		return education;
	}

	public void setEducation(int education) {
		this.education = education;
	}

	public String getEntranceTime() {
		return entrance_time;
	}

	public void setEntranceTime(String entranceTime) {
		this.entrance_time = entranceTime;
	}

	public String getUsername() {
		return this.username;
	}
	
	public int getAge() {
		return age;
	}

	public void setAge(int age) {
		this.age = age;
	}
	
	public String getTitleStr() {
		return getTitle(title);
	}

	public String getEducationStr() {
		return getEducation(education);
	}
	
	public String getRole(){
		return getRole(role_type);
	}

	public static String getRole(int type){
		switch (type) {
		case Constants.ROLE_DOCTOR:
			return "医生";
		case Constants.ROLE_DOCTOR_STUDENT:
			return "医学生";
		case Constants.ROLE_PATIENT:
			return "患者";	
		}
		return "";
	}
	
	public static String getEducation(int education){
		switch (education) {
		case 1:
			return "本科";
		case 2:
			return "硕士";
		case 3:
			return "博士";
		}
		return "";
	}
	
	public static String getTitle(int title) {
		switch (title) {
		case 1:
			return "实习医生";
		case 2:
			return "住院医师";
		case 3:
			return "主治医师";
		case 4:
			return "副主任医师";
		case 5:
			return "主任医师";
		}
		return "";
	}
	
	public static String getGender(int gender){
		if (gender == Constants.FEMALE){
			return "女";
		}else if (gender == Constants.MALE){
			return "男";
		}
		return "";
	}

	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		this.phone_number = json.optString("phone_number");
		this.nickname = json.optString("nickname");
		this.username = json.optString("name");
		this.description = json.optString("description");
		this.gender = json.optInt("gender");
		this.user_id = json.optInt("user_id");
		this.role_type = json.optInt("role_type");
//		this.head_pic_image_id = json.optInt("head_pic_image_id");
//		this.head_pic = json.optString("head_pic");
		 if(json.optInt("image_id") == 0 && json.optInt("head_pic_image_id") != 0 ){
			 this.image_id =  json.optInt("head_pic_image_id");
		 }else{
			 this.image_id = json.optInt("image_id");
		 }
		
		this.city = json.optString("city");
		this.hospital = json.optString("hospital");
		this.department = json.optString("department");
		this.university = json.optString("university");
		this.major = json.optString("major");
		this.entrance_time = json.optString("entrance_time");
		this.title = json.optInt("title");
		this.education = json.optInt("education");
		this.doctor_id = json.optInt("doctor_id");
		this.dp_name = json.optString("dp_name");
	}

	@Override
	public JSONObject getJson() {
		JSONObject json = new JSONObject();
		try {
			json.put("name", name);

			json.put("phone_number", phone_number);
			json.put("nickname", nickname);
			json.put("username", username);
			json.put("description", description);
			json.put("gender", gender);
			json.put("user_id", user_id);
			json.put("role_type", role_type);
//			json.put("head_pic_image_id", head_pic_image_id);
//			json.put("head_pic", head_pic);
			json.put("city", city);
			json.put("hospital", hospital);
			json.put("department", department);
			json.put("university", university);
			json.put("major", major);
			json.put("entrance_time", entrance_time);
			json.put("title", title);
			json.put("education", education);
			json.put("doctor_id", doctor_id);
			json.put("dp_name", dp_name);
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return json;
	}
	
}
