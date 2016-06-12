package com.fq.halcyon.entity;

import java.io.File;
import java.util.ArrayList;

import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic.DoctorAuthLogic;
import com.fq.halcyon.logic.DoctorAuthLogic.OnRequestAuthStateCallback;
import com.fq.lib.callback.ICallback;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;

public class CertificationStatus extends HalcyonEntity{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**
	 * 未认证
	 */
	public static final int CERTIFICATION_INITIALIZE = 0;
	/**
	 * 正在认证
	 */
	public static final int CERTIFICATION_APPROVING = 1;
	/**
	 * 认证失败
	 */
	public static final int CERTIFICATION_NOT_PASS = 2;
	/**
	 * 认证成功
	 */
	public static final int CERTIFICATION_PASS = 3;
	
	/**
	 * 待认证
	 */
	public static final int CERTIFICATION_WAIT = 4;
	
	private int auth_status = CERTIFICATION_INITIALIZE;
	
	private int certi_id;
	
	private ArrayList<AuthImage> authImages;
	
	private boolean isHaveApply;
	
	private static CertificationStatus _instance;
	
	public void clear(){
		_instance = null;
	}
	
		public static void initCertification(){
			initDoctorAuth2Net();
			//_instance = FileSystem.getInstance().loadEntity(CertificationStatus.class);
			
			/*JSONObject json = FileSystem.getInstance().loadUserAuthState();
			if(json == null){
				
			}else{
				initByJson(json);
				if(_instance == null){
					initDoctorAuth2Net();
				}
			}*/
		}
		
		public static CertificationStatus getInstance(){
				if (_instance == null) {
					_instance = new CertificationStatus();
				}
				return _instance;
		}

	
		public static void initDoctorAuth2Net(){
			new DoctorAuthLogic().requestAuthState(new OnRequestAuthStateCallback() {
				public void feedRequest(CertificationStatus certif) {
					_instance = certif;
					if(_instance != null){
						FileSystem filSys = FileSystem.getInstance();
						String path = filSys.getRecordImgPath();
						//TODO 以前是4，后面不要身份证了
						for(int i = 1; i < 2; i++){
							File file = new File(path);
							if(!file.exists())file.mkdirs();
							String name = filSys.getAuthImgNameByType(i);
							file = new File(path+"/"+name);
							if(file.exists())continue;
							AuthImage img = _instance.getAuthImageByType(i);
							if(img != null && img.hayImage.getImageId() != 0){
								int imageId = img.hayImage.getImageId();
//								String path = filSys.getUserImagePath();
//								String name = filSys.getAuthImgNameByType(img.certType);
//								filSys.saveBitmap2Local(imageId,path,name,true);
								Photo photo = new Photo();
								photo.setImageId(imageId);
								photo.setImagePath(FileSystem.getInstance().getAuthImgPathByType(i));
								ApiSystem.getInstance().getHeadImage(photo, new ICallback() {
									
									@Override
									public void doCallback(Object obj) {
										
									}
										
								}, false,4);
							}
						}
					}
				}
			});
		}
		
		public static CertificationStatus initByJson(JSONObject json){
			try{
				CertificationStatus certif = new CertificationStatus();

				int state = 0;
				if(Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR){
					state = json.optInt("auth_status");
				}else if(Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR_STUDENT){
					state = json.optInt("auth_student_status");
				}
				certif.auth_status = state == CERTIFICATION_WAIT?CERTIFICATION_APPROVING:state;
				JSONArray array = json.optJSONArray("certi_list");
				certif.authImages = new ArrayList<CertificationStatus.AuthImage>();
				if(certif.auth_status != CERTIFICATION_INITIALIZE)certif.isHaveApply = true;
				if(!certif.isHaveApply && array.length() > 0)certif.isHaveApply = true;
				for(int i = 0; i < array.length(); i++){
					JSONObject obj = array.optJSONObject(i);
					//JSONObject imgObj = obj.optJSONObject("image");
					int docerId = obj.optInt("doctor_certi_id");
					PhotoRecord img = new PhotoRecord(obj.optInt("image_id"),obj.optString("uri"));
					AuthImage authImg = new AuthImage(docerId,obj.optInt("certi_type"),img);
					certif.authImages.add(authImg);
			    }
			return certif;
			}catch (Exception e){
				return null;
			}
		}
		
		public boolean isHaveAuth(){
			return isHaveApply;
		}
		
		public void setHaveAuth(boolean isb){
			isHaveApply = isb;
		}
		
		public void setState(int type){
			auth_status = type;
		}
		
		public int getState(){
			return auth_status;
		}
		
		public int getId(){
			return certi_id;
		}
		
		public ArrayList<AuthImage> getImgs(){
			if(authImages == null)authImages = new ArrayList<CertificationStatus.AuthImage>();
			return authImages;
		}
		
		public AuthImage getAuthImageByType(int type){
			if(authImages == null || authImages.size() == 0)return null;
			for(int i = 0; i < authImages.size(); i++){
				AuthImage img = authImages.get(i);
				if(img.certType == type && img.doctorCertiId != 0 && img.hayImage.getImageId() != 0){
					return img;
				}
			}
			return null;
		}
		
		public boolean isImgExitByType(int type){
			String imgName  = FileSystem.getInstance().getAuthImgPathByType(type);
			File file = new File(imgName);
			return file.exists();
		}
		
		/**
		 * @param isHead 是否在头像页面
		 * @return
		 */
		public String getStateStr(boolean isHead){
			switch (auth_status) {
			case CertificationStatus.CERTIFICATION_INITIALIZE:
				return isHead?"初始":"";
			case CertificationStatus.CERTIFICATION_APPROVING:
				return "审核中";
			case CertificationStatus.CERTIFICATION_NOT_PASS:
				return "未通过";
			case CertificationStatus.CERTIFICATION_PASS:
				return "通过";
			default:
				return "";
			}
		}
		
		public static class AuthImage{
			public static final int CERTYPE_DOCTOR = 1;
			public static final int CERTYPE_CARD_Z = 2;
			public static final int CERTYPE_CARD_F = 3;
			
			public int certType;
			public int doctorCertiId;
			public PhotoRecord hayImage;
			
			public AuthImage(int docCerId, int type, PhotoRecord img){
				doctorCertiId = docCerId;
				certType = type;
				hayImage = img;
			}
		}

		@Override
		public void test() {
			// TODO Auto-generated method stub
			
		}
		
		@Override
		public void setAtttributeByjson(JSONObject json){
			this.auth_status = json.optInt("auth_status");
			this.certi_id = json.optInt("certi_id");
			JSONArray authImagesaArray = json.optJSONArray("authImages");
			if(authImagesaArray != null)
			{
			}
		}
}
