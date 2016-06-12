package com.fq.halcyon.extend.filesystem;

import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.UriConstants;

public class PathUrlMap {
	
	static{
//		map.put(CITY_LIST,"%scities.json"); //城市列表
//		map.put(Constants.Conn.URL_PUB+"/records/list_records.do","%s%d/header_%d.json");
//		map.put(Constants.Conn.URL_PUB+"/records/get_admission_single.do","%srecords/%d.json");
//		map.put(Constants.Conn.URL_PUB+"/records/get_exam_single.do","%srecords/%d.json");
//		map.put(Constants.Conn.URL_PUB+"/records/get_discharge_single.do","%srecords/%d.json");
//		map.put(Constants.Conn.URL_PUB+"/records/list_all_images.do","%srecords/%d.json");
//		map.put(Constants.Conn.URL_PUB+"/records/get_sugery_single.do","%srecords/%d.json");
//		map.put(Constants.Conn.URL_PUB+"/records/get_ext_single.do","%srecords/%d.json");
	}
	
	public static final int CITY_LIST = 0;         //城市列表        
	public static final int LIST_RECORDS = 1;      //请求header
	public static final int ADMISSION_SINGLE = 2;  // 入院记录
	public static final int EXAM_SINGLE = 3;       // 化验单
	public static final int DISCHARGE_SINGLE = 4;  //出院 
	public static final int ALL_IMAGE = 5;         //影像
	public static final int SUGERY_SINGLE = 6;     //手术
	public static final int EXT_SINGLE = 7;        //其他记录
	public static final int HOSPITA_LIST = 8;      //医院列表
	public static final int DEPARTMENT_LIST = 9;    //科室列表
	public static final int RECONGNITION_LIST = 10;  //云识别列表
	public static final int PATIENT_LIST = 11;  //病历列表
	public static final int DELETE_PATIENT = 12;  //删除病历
	public static final int MODIFY_ADMISSION_SINGLE = 13;  //病例入院修改
	public static final int MODIFY_SUGERY_SINGLE = 14;  //病例手术修改
	public static final int MODIFY_DISCHARGE_SINGLE = 15;  //病例出院修改
	public static final int MODIFY_EXT_SINGLE = 16;  //病例其他修改
	public static final int EXAM_ITEMS = 17;  //病例其他修改
	public static final int DOCTOR_AUTH = 18; // 医生认证
	public static final int TAGS = 19; //标签列表
	
	public static String[] ALLURL = {
		UriConstants.Conn.URL_PUB+"/pub/list_cities.do",            //城市列表               0
		UriConstants.Conn.URL_PUB+"/records/list_records.do",       //请求header  1
		UriConstants.Conn.URL_PUB+"/records/get_admission_single.do",  // 入院记录    2
		UriConstants.Conn.URL_PUB+"/records/get_exam_single.do",     // 化验单             3
		UriConstants.Conn.URL_PUB+"/records/get_discharge_single.do", //出院                 4
		UriConstants.Conn.URL_PUB+"/records/list_all_images.do",       //影像              5
		UriConstants.Conn.URL_PUB+"/records/get_sugery_single.do",     //手术             6
		UriConstants.Conn.URL_PUB+"/records/get_ext_single.do",        //其他记录     7
		UriConstants.Conn.URL_PUB+"/pub/list_hospitals.do",           //医院列表       8
		UriConstants.Conn.URL_PUB+"/pub/list_departments.do",         //科室列表       9
		UriConstants.Conn.URL_PUB+"/records/list_recognition.do",      //云识别列表       10
		UriConstants.Conn.URL_PUB+"/records/list_patients.do",      //病历列表  11
		UriConstants.Conn.URL_PUB+"/records/delete_records.do",      //删除病历  12 
		UriConstants.Conn.URL_PUB+"/records/modify_admission_single.do", //病例入院修改 13 
		UriConstants.Conn.URL_PUB+"/records/modify_sugery_single.do", //病例手术修改 14 
		UriConstants.Conn.URL_PUB+"/records/modify_discharge_single.do", //病例出院修改 15
		UriConstants.Conn.URL_PUB+"/records/modify_ext_single.do",    //病例其他修改 16
		UriConstants.Conn.URL_PUB+"/records/list_exam_items.do",    //化验指标变动明细 17
		UriConstants.Conn.URL_PUB+"/doctors/get_doctor_auth.do",    //医生认证 18
		UriConstants.Conn.URL_PUB+"/tags/list_all_tags.do",    //标签列表 19
	}; 
	
	
	private static int getIndex(String url){
		for (int i = 0; i < ALLURL.length; i++) {
			if(ALLURL[i].equals(url)) return i;
		}
		return -1;
	}
	
	public static String getLocalPath(String url,FQHttpParams params) {
		int index = getIndex(url);
		if(index > 0){
			FileSystem fileSystem  = FileSystem.getInstance();
			JSONObject record = null;
			String localPath = null;
			if(params != null){
				record = params.getJson().optJSONObject("record");
			}
			switch (index) {
			case CITY_LIST:
				localPath = String.format("%scities.json", fileSystem.getOthersPath());
				break;
			case LIST_RECORDS:
				localPath = String.format("%s%d/header_type%d.json", fileSystem.getUserPatientsPath(),record.optInt("doctor_patient_id"),record.optInt("record_type"));
				break;
			case ADMISSION_SINGLE:
			case EXAM_SINGLE:
			case DISCHARGE_SINGLE:
			case ALL_IMAGE:
			case SUGERY_SINGLE:
			case EXT_SINGLE:
//				localPath = String.format("%srecords/%d.json", fileSystem.getUserPath(),record.optInt("record_id"));
//				localPath = RecordDatabaseHelper.DB_NAME;
				break;
			case HOSPITA_LIST:
				localPath = String.format("%shospital.json", fileSystem.getUserPath());
				break;
			case DEPARTMENT_LIST:
				localPath = String.format("%sdepartment.json", fileSystem.getUserPath());
				break;
			case PATIENT_LIST:
			case DELETE_PATIENT:
				localPath = String.format("%spatients.json", fileSystem.getUserPath());
				break;
			case MODIFY_ADMISSION_SINGLE:
			case MODIFY_SUGERY_SINGLE:
			case MODIFY_DISCHARGE_SINGLE:
			case MODIFY_EXT_SINGLE:
//				localPath = RecordDatabaseHelper.DB_NAME;
				break;
			case EXAM_ITEMS:
				localPath = String.format("%s%d/exams.json", fileSystem.getUserPatientsPath(),record.optInt("doctor_patient_id"));
				break;
			case DOCTOR_AUTH:
				localPath = fileSystem.getUserApiPath()+"/"+"auth.json";
				break;
			case TAGS:
				localPath = fileSystem.getUserPath()+"tags.json";
				break;
			default:
				break;
			}
			return localPath;
		}else {
			return null;
		}
	}

}
