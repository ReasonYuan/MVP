package com.fq.lib.tools;

import java.io.File;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic2.ResetDoctorInfoLogic;
import com.fq.halcyon.logic2.ResetDoctorInfoLogic.InvientCallback;
import com.fq.lib.UploadImageHelper;
import com.fq.lib.json.JSONObject;

public class UserProfileManager {

	private static UserProfileManager mInstance;
	private ResetDoctorInfoLogic resetDoctorInfoLogic;
	private User mUser;
	private String localTempImageFileName = "";

	public static UserProfileManager instance() {
		if (mInstance == null) {
			mInstance = new UserProfileManager();
			mInstance.mUser = Constants.getUser();
			mInstance.resetDoctorInfoLogic = new ResetDoctorInfoLogic();
		}
		return mInstance;
	}

	/**
	 * 返回当前登录的user
	 * @return
	 */
	public User getUser() {
		return mUser;
	}

	/**
	 * 退出时清除数据 
	 */
	public void clear(){
		mInstance.mUser = null;
		mInstance = null;
	}
	
	
	/**
	 * 获取本地temp文件uri
	 * @return
	 */
	public File getLocalTempFileUri() {
		localTempImageFileName = "head" + System.currentTimeMillis();// + ".png"
		File filePath = new File(FileSystem.getInstance().getFriendPath());
		if (!filePath.exists())
			filePath.mkdirs();
		return new File(filePath, localTempImageFileName);
	}
	
	/**
	 * 获取localtempimageFileName
	 */
	public String getlocaltempimageFileName() {
		return localTempImageFileName;
	}
	/**
	 * 获取localtempimageFile绝对路径
	 */
	public String getlocaltempimageFilegetAbsolutePath() {
		File f = new File(FileSystem.getInstance().getFriendPath()
				+ localTempImageFileName);
		return f.getAbsolutePath();
	}


	/**
	 * 获取验证码
	 * 
	 * @param mUser
	 * @param callBack
	 */
	public void getInvient(final User mUser, final OnResultCallBack callBack) {
		if ("".equals(mUser.getInvition())) {
			resetDoctorInfoLogic.requestInvient(new InvientCallback() {
				@Override
				public void doInvientBack(String invient) {
					if ("".equals(invient)) {
						callBack.onResult("获取中");
					} else {
						callBack.onResult(invient);
						mUser.setInvition(invient);
					}
				}
			});
		} else {
			callBack.onResult(mUser.getInvition());
		}
	}

	public interface OnResultCallBack {
		public void onResult(String msg);
	}

	/**
	 * 是否是第一次登陆
	 */
	public boolean isFirstLogin() {
		return "".equals(Constants.getUser().getName())
				|| (Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR && ""
						.equals(Constants.getUser().getDepartment()))
				|| (Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR && ""
						.equals(Constants.getUser().getHospital()))
				|| (Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR && ""
						.equals(Constants.getUser().getTitleStr()))
				|| "".equals(Constants.getUser().getGenderStr());
	}

	/**
	 * 获取职称
	 * 
	 * @param obj
	 * @param mIsDoctor
	 * @return
	 */
	public String getSelectZhiCheng(Object obj, boolean mIsDoctor) {
		int index = (Integer) obj;
		if (mIsDoctor) {
			if (index != mUser.getTitle()) {
				mUser.setTitle(index);
				resetDoctorInfoLogic.reqModyTitle(mUser.getTitle());
				return mUser.getTitleStr();
			}
		} else {
			if (index != mUser.getEducation()) {
				mUser.setEducation(index);
				resetDoctorInfoLogic.reqModyEducation(mUser.getEducation());
				return mUser.getEducationStr();
			}
		}
		return null;
	}

	/**
	 * 上传头像
	 */
	public void upLoadHead(final OnUploadCallBack callBack) {
		final FileSystem fileSys = FileSystem.getInstance();
		UploadImageHelper.upLoadImgUnOCR(fileSys.getUserHeadPath(),
				new HalcyonHttpResponseHandle() {
					@Override
					public void onError(int code, Throwable e) {
						FQLog.i("sendHead", "~~send head falid:code:" + code
								+ " msg:" + e);
						callBack.onError();
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						JSONObject obj = (JSONObject) results;
						int id = obj.optInt("image_id");
						//==YY==imageId(只要imageId)
//						Constants.getUser().setHeadPicPath(
//								fileSys.getUserHeadPath());
//						Constants.getUser().setHeadPicImageId(id);
						Constants.getUser().setImageId(id);
						resetDoctorInfoLogic.reqModyHead(id);
						callBack.onsuccess();
					}
				});
	}
	
	public void upLoadHead(String path,final OnUploadCallBack callBack) {
		final FileSystem fileSys = FileSystem.getInstance();
		UploadImageHelper.upLoadImgUnOCR(path,
				new HalcyonHttpResponseHandle() {
					@Override
					public void onError(int code, Throwable e) {
						FQLog.i("sendHead", "~~send head falid:code:" + code
								+ " msg:" + e);
						callBack.onError();
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						JSONObject obj = (JSONObject) results;
						
						//==YY==imageId(只要imageId)
//						Constants.getUser().setHeadPicPath(fileSys.getUserHeadPath());
//						Constants.getUser().setHeadPicImageId(id);
						int id = 0;
						 if(obj.optInt("image_id") == 0 && obj.optInt("head_pic_image_id") != 0) {
							 id =  obj.optInt("head_pic_image_id");
						 } else{
							 id = obj.optInt("image_id");
						 }
						Constants.getUser().setImageId(id);
						callBack.onsuccess();
						resetDoctorInfoLogic.reqModyHead(id);
						
					}
				});
	}

	/**
	 * 上传头像回调
	 * @author niko
	 *
	 */
	public interface OnUploadCallBack {
		public void onError();
		public void onsuccess();
	}
	
	/**
	 * 修改名字
	 */
	public void reqModyName() {
		resetDoctorInfoLogic.reqModyName(Constants.getUser().getName());
	}
	
	/**
	 * 修改医院
	 */
	public void reqModyHosp(int hosId,String hosName) {
		resetDoctorInfoLogic.reqModyHosp(0,hosId, hosName);
	}

	/**
	 * 修改科室
	 */
	public void reqModyDept(int deptId,int secId,String name) {
		resetDoctorInfoLogic.reqModyDept(deptId, secId, name);
	}
	/**
	 * 修改性别
	 */
	public void reqModyGender() {
		resetDoctorInfoLogic.reqModyGender(Constants.getUser().getGender());
	}
	
	/**
	 * 修改描述
	 */
	public void reqModyDes() {
		resetDoctorInfoLogic.reqModyDes(Constants.getUser()
				.getDescription());
	}
	/**
	 * 修改学校
	 */
	public void reqModyUniversity() {
		resetDoctorInfoLogic.reqModyUniversity(mUser.getUniversity());
	}
	
	
	/**
	 * 修改学校
	 */
	public void reqModyEntranceTime(String time) {
		Constants.getUser().setEntranceTime(time);
		resetDoctorInfoLogic.reqModyEntranceTime(time);
	}
}
