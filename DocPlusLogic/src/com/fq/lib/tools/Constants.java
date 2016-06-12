package com.fq.lib.tools;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.entity.AlarmClock;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Tag;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.extend.filesystem.FileSystem;

public class Constants {
	
	/**客户端类型*/
	public class ClientConstants {
		
		/**客户端的类型*/
		public static final int CLIENT_TYPE = Constants.CLIENT_HEALTH_IOS;
		
		/**客户端用户的类型*/
		public static final int ROLE_TYPE = Constants.ROLE_DOCTOR;
	}
	
	
	public static boolean TARGET_FOR_IOS = false;
	
	/**
	 * 是否是debug模式
	 */
	public static boolean DEBUG = UriConstants.Conn.DEBUG_MODE;
	
	/**是否为inhouse版本，主要涉及到第三方库appKey的改变:true为是，false为不是*/
	public static boolean isInhouse = true;
	
	/**用户是不是体验模式登录*/
	public static boolean isVisitor = false;
	
	
	public static final int MALE = 2;//男
	public static final int FEMALE = 1;//女

	public static final int ROLE_DOCTOR = 1; //医生
	public static final int ROLE_DOCTOR_STUDENT = 2;//医学生
	public static final int ROLE_PATIENT = 3;//病人
	
	
	/**行医助手_android*/
	public static final int CLIENT_DOCTOR_ANDORID = 1;
	/**行医助手_ios*/
	public static final int CLIENT_DOCTOR_IOS = 2;
	/**健康助手_android*/
	public static final int CLIENT_HEALTH_ANDORID = 3;
	/**健康助手_ios*/
	public static final int CLIENT_HEALTH_IOS = 4;
	
	/**分享类型：病案*/
	public static final int SHARE_TYPE_PATIENT = 2;
	/**分享类型：记录*/
	public static final int SHARE_TYPE_RECORD = 3;
	
	
	/**
	 * 对于以前注册时候没有本地加密key的用一个默认的key加密
	 */
	public static byte[] KEY_STRING = "GY380qSEn1jzE80Uai3346HX".getBytes();
	/**
	 * 给用户信息加密key
	 */
	public static String KEY_CTS = "GY380qSEn1jzE80Uai3346HX";
	
    private static User mUser;
    
    /**
     * 游客模式登录手机号
     */
//	public static String ExperienceModePhoneNumber = "18602106473";
	
    public static void setUser(User user){
    	mUser = user;
    }
    
    public static User getUser(){
    	if(mUser == null || mUser.getUserId() == 0){
    		mUser = FileSystem.getInstance().loadCurrentUser();
    	}
    	return mUser;
    }
    
    public static boolean isLogined(){
    	return mUser != null;
    }
    
    /**设置是否为游客模式，true为是，false为不是*/
    public static void setIsVisitor(boolean isb){
    	isVisitor = isb;
    }
    
	public static ArrayList<Tag> tagList;
	
	public static HashMap<Integer, ArrayList<Contacts>> contactsMap;
	
	public static ArrayList<Contacts> contactsList;
	
	public static HashMap<String, ArrayList<Contacts>> contactsDepartmentMap;
	
	public static ArrayList<Contacts> contactsDoctorList;
	
	public static ArrayList<Contacts> contactsPatientList;

	public static ArrayList<AlarmClock> alarms;
	
//	public static ArrayList<PatientAbstract> patietnList;
	
//	public static final String KEY_MSG_NUM = "message_number";

	/**
	 * 获取分享社区的文字说明
	 * @param type 1短信、微博  2微信朋友圈    3微信好友
	 * @return
	 */
	public static String getShareText(int type){
		switch (type) {
		case 1:
			return "医加，助力好医生。轻松地积累病历，高效地管理患者，为医生自由助力。下载地址：";
		case 2:
			return "HiTales Practice致力于整合医疗数据，提升医生临床和研究效率，为病人提供更好的治疗。";
		case 3:	
		default:
			return "HiTales Practice致力于整合医疗数据，提升医生临床和研究效率，为病人提供更好的治疗。";
		}
	}
	
	/**
	 * 获得分享社区微信好友的分享标题
	 * @return
	 */
	public static String getShareTitle(){
		return "HiTales Practice--Date Driven Health";
	}
	
	
	
	public class Msg{
		/**网络异常，请稍后再试*/
		public static final String NET_ERROR = "网络异常，请稍后再试";
	}

}
