package com.fq.halcyon.uilogic;

import com.fq.halcyon.entity.CertificationStatus;
import com.fq.lib.tools.Constants;

public class PersonInfoUILogic {

	/**
	 *用于"我"的界面判断用户信息是否完整 
	 */
	public static boolean checkUserInfo(){
		
		String name = Constants.getUser().getName();
		String hospital = Constants.getUser().getHospital();
		String department = Constants.getUser().getDepartment();
	    int gender = Constants.getUser().getGender();
	    String description = Constants.getUser().getDescription();
	    
	  //==YY==imageId(只要imageId)
//	    String headPicPath = Constants.getUser().getHeadPicPath();
	    
	    
		
		if(null == name || "".equals(name)){
			return false;
		}else if(null == hospital || "".equals(hospital)){
			return false;
		}else if(null == department ||"".equals(department)){
			return false;
		}else if(gender != 1 && gender != 2){
			return false;
		}else if(null == description || "".equals(description)){
			return false;
//		}else if(null == headPicPath || "".equals(headPicPath)){
//			return false;
		}else if(!CertificationStatus.getInstance().isHaveAuth()){
			//CertificationStatus.getInstance().getState() != CertificationStatus.CERTIFICATION_PASS){
			return false;
		}else{
			return true;
		}
	}
}
