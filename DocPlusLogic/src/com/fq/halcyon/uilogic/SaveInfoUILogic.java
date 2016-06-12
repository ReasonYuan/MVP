package com.fq.halcyon.uilogic;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic2.ResetDoctorInfoLogic;
import com.fq.lib.HttpHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.UriConstants;

public class SaveInfoUILogic {

	/**
	 *注册成功后调用此方法，用于保存用户信息<br/>
	 *发现注册时调用后在设置用户信息界面，如果用户不设置完信息而退出会有bug。
	 *@param phoneNumber
	 *@param password
	 *@param userId
	 *@param user  
	 *          -User的实体类 
	 */
	public static void saveInfo(String phoneNumber, String password, int userId, User user){
		FileSystem.getInstance().saveLoginUser(phoneNumber, password,userId);
//		FileSystem.getInstance().saveLoginList(phoneNumber, userId+"");
		FileSystem.getInstance().saveUser(user);
	}
	
	/**
	 * 用户注册成功并完成个人信息后，保存该用户的登录信息<br/>
	 * 在退出设置用户信息界面时使用
	 */
	public static void saveUserLogicInfo(){
		User user = Constants.getUser();
		FileSystem.getInstance().saveLoginUser(user.getPhoneNumber(), user.getPassword(), user.getUserId());
//		FileSystem.getInstance().saveLoginList(user.getPhoneNumber(), user.getUserId()+"");
	}
	
	/**
	 *修改手机号成功后调用此方法，用于保存用户信息
	 *@param phone
	 *@param password
	 *@param userId
	 */
	public static void saveInfo(String phone, String password, int userId){
		FileSystem fileSys = FileSystem.getInstance();
//		fileSys.delLoginInList();
		fileSys.saveLoginUser(phone,password,userId);
//		fileSys.saveLoginList(phone, userId);
		fileSys.saveCurrentUser();
	}
	
	/**
	 *找回密码和修改密码成功后调用此方法，用于保存用户信息
	 *@param phoneNumber
	 *@param password
	 *@param user  
	 *          -User的实体类 
	 */
	public static void saveInfo(String phoneNumber, String password,User user){
		FileSystem.getInstance().saveLoginUser(phoneNumber, password,user.getUserId());
		FileSystem.getInstance().saveUser(user);
	}
	
	public void uploadUserHeadPath(String path){
//		FileSystem fileSys = FileSystem.getInstance();
		HttpHelper.upLoadImage(UriConstants.Conn.URL_PUB+"/pub/upload_images.do", path, false, new HalcyonHttpResponseHandle() {

			public void onError(int code,Throwable e) {
				FQLog.i("sendHead", "~~send head falid: msg:" + (e==null?"":e.getCause()));
			}

			public void handle(int responseCode, String msg, int type,
					Object results) {
				JSONObject obj = (JSONObject) results;
				int id = obj.optInt("image_id");
				
				//==YY==imageId(只要imageId)
//				Constants.getUser().setHeadPicPath(obj.optString("uri"));
//				Constants.getUser().setHeadPicImageId(id);
				
				Constants.getUser().setImageId(id);
				FileSystem.getInstance().saveCurrentUser();
				new ResetDoctorInfoLogic().reqModyHead(id);
				FQLog.i("sendHead", "~~send head success:" + ((JSONObject) results).toString());
				
			}
		} , null);
	
	}
}
