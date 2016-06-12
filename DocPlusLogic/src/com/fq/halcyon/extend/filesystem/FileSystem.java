package com.fq.halcyon.extend.filesystem;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;

import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.halcyon.entity.User;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.FileHelper;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.DES3Utils;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.Encryption;
import com.fq.lib.tools.MD5;
import com.fq.lib.tools.Tool;

/**
 * 
 * @author liaomin
 * 
 */
public class FileSystem {

	// private static final String COMMON_DIR = "/common";

	private static final String USER_DIR = "gfa/";

	private static FileSystem instance;

	/** 病历图片的格式 .png */
	public static String RED_IMG_FT = ".jpg";

	/** 病历图片所放目录 */
	public static String RECORD_FOLDER = "医加/";

	// private ConcurrentHashMap<String, String> mMap;

	private String mPhoneRootPath;

	private String mSDCardRootPath;

	private String mImageRootPath;

	private FileSystem() {
		mPhoneRootPath = null;
		// mMap = new ConcurrentHashMap<String, String>();
	}

	public static FileSystem getInstance() {
		if (instance == null) {
			throw new RuntimeException("FileSystem root not set!");
		}
		return instance;
	}

	public static void initWithRootPath(String phoenRootPath, String sdCardRootPath) {
		instance = new FileSystem();
		instance.mPhoneRootPath = phoenRootPath;
		instance.mSDCardRootPath = sdCardRootPath;
		instance.mImageRootPath = instance.mSDCardRootPath + "images/";

		if (instance.mPhoneRootPath != null) {
			File file = new File(instance.mPhoneRootPath);
			if (!file.exists())
				file.mkdirs();
		} else {
			throw new RuntimeException("FileSystem root not set!");
		}
	}

	/** 用户手机硬盘下的医加的根目录 */
	public String getPhoneRootPath() {
		return mPhoneRootPath;
	}

	/** 用户sdcard下的根目录 */
	public String getSDCardRootPath() {
		return mSDCardRootPath;
	}

	/** 用户sdcard下的图片根目录 */
	public String getSDCImgRootPath() {
		return mImageRootPath;
	}

	/**
	 * 得到用户的MD5加密的Id
	 * 
	 * @return 用md5加密的id
	 */
	public String getMD5UserId(String userId) {
		return MD5.Md5(userId);
	}

	/**
	 * 得到当前用户用md5加密的id
	 * 
	 * @return
	 */
	public String getCurrentMD5Id() {
		return getMD5UserId(Constants.getUser().getUserId() + "");
	}

	/**
	 * 获得当前用户的目录
	 * 
	 * @param id
	 * @return
	 */
	public String getUserPath() {
        int user_id = Constants.getUser().getUserId();
		return instance.mPhoneRootPath + USER_DIR + getMD5UserId("" + user_id) + "/";
	}

	public String getUserPatientsPath() {
		return instance.mPhoneRootPath + USER_DIR + getMD5UserId("" + Constants.getUser().getUserId()) + "/patients/";
	}

	/**
	 * 获得用户的目录
	 * 
	 * @param 用户的id
	 * @return
	 */
	public String getUserPath(String id) {
		return instance.mPhoneRootPath + USER_DIR + getMD5UserId(id) + "/";
	}

	/**
	 * 获得联系人头像的路径
	 * 
	 * @return
	 */
	public String getFriendPath() {
		return mImageRootPath + "head/";
	}

	/**
	 * 获得某个联系人的头像
	 * 
	 * @param imageId
	 *            联系人头像的id
	 * @return
	 */
	public String getFriendPathWithImageId(int imageId) {
		return mImageRootPath + "head/" + imageId;
	}

	/**
	 * 获得其他文件的目录
	 * 
	 * @return
	 */
	public String getOthersPath() {
		return instance.mSDCardRootPath + "others/";
	}

	/**
	 * 获得应用缓存的路径
	 * 
	 * @return
	 */
	public String getImgTempPath() {
		String path = mImageRootPath + "tmp/";
		File file = new File(path);
		if (!file.exists())
			file.mkdirs();
		return mImageRootPath + "tmp/";
	}

	/**
	 * 获得病历图片的路径
	 * 
	 * @return
	 */
	public String getRecordImgPath() {
		return mImageRootPath + RECORD_FOLDER;
	}

	/**
	 * 保存当前用户信息并记录到最近用户（pre.dp）文件
	 * 
	 * @param user
	 */
	public void saveUser(User user) {
		if (user != null && user.getUserId() == 0)
			return;
		encryptUserInfo(user);
	}

	/**
	 * 保存当前用户信息
	 */
	public void saveCurrentUser() {
		User user = Constants.getUser();
		if (user != null && user.getUserId() != 0) {
			encryptUserInfo(user);
		}
	}

	/**
	 * 对用户信息pre.dp进行加密
	 */
	public void encryptUserInfo(User user) {
		FileInputStream fileInputStream = null;
		try {
			File file = new File(instance.getUserPath());
			if (!file.exists()) {
				file.mkdirs();
			}

			byte[] buffer = user.getJson().toString().getBytes();
			
			String str = new String(buffer, "UTF-8");
			String miwen = new String(DES3Utils.encryptMode(str.getBytes(), Constants.KEY_STRING));
			FileHelper.saveFile(miwen, instance.getUserPath(), "pre.dp",false);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (fileInputStream != null) {
				try {
					fileInputStream.close();
					fileInputStream = null;
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}
	
	
	/**
	 * 对数据进行加密
	 */
	public void encryptInfo(String data) {
		FileInputStream fileInputStream = null;
		try {
			File file = new File(instance.getUserPath());
			if (!file.exists()) {
				file.mkdirs();
			}

			byte[] buffer = data.getBytes();
			
			String str = new String(buffer, "UTF-8");
			String miwen = new String(DES3Utils.encryptMode(str.getBytes(), Constants.KEY_STRING));
			FileHelper.saveFile(miwen, instance.getUserPath(), "pre.dp",false);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (fileInputStream != null) {
				try {
					fileInputStream.close();
					fileInputStream = null;
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}
	

	/**
	 * 对profile.json进行解密
	 */
	public String deEncryptUserInfo(String str) {
		// FileInputStream fileInputStream = new FileInputStream(new File(
		// instance.getUserPath() + "profile.json"));
		// int lenght = fileInputStream.available();
		// // 创建byte数组
		// byte[] buffer = new byte[lenght];
		// // 将文件中的数据读到byte数组中
		// fileInputStream.read(buffer);
		// String str = new String(buffer, "UTF-8");
		String minwenStr = new String(DES3Utils.decryptMode(str.getBytes(), Constants.KEY_STRING));
		// JSONObject obj = new JSONObject(minwenStr);
		// Constants.getUser().setAtttributeByjson(obj);
		return minwenStr;

	}

	/**
	 * 得到当前登录的User
	 */
	public User loadCurrentUser() {
		ArrayList<String> keyPwd = loadLoginUser();
		if (keyPwd == null) {
			return new User();
		} else {
			try {
				String id = keyPwd.get(2);
				if (!"".equals(id))
					return loadUser(id);
				return new User();
			} catch (Exception e) {
				return new User();
			}
		}
	}

	/**
	 * 通过Id得到用户信息
	 * 
	 * @return
	 */
	public User loadUser(String id) {
		try {
			if (id != null && !id.equals("")) {
				String userJsonString = FileHelper.readString(instance.getUserPath(id), "pre.dp",false);

				if (userJsonString != null && !"".equals(userJsonString.trim())) {
					User user = new User();
					user.setAtttributeByjson(new JSONObject(deEncryptUserInfo(userJsonString)));
					return user;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new User();
	}

	/**
	 * 保存成功登录的用户的登录信息到最近登录文件
	 */
	public void saveLoginUser(String phone, String pwd, int id) {
		try {
			JSONObject object = new JSONObject();
			object.put("dph", phone);
			object.put("dpp", pwd);
			object.put("dpi", id + "");
			FileHelper.saveFile(Encryption.encryption(object.toString(), Constants.KEY_CTS), mPhoneRootPath, "cts.dp",false);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 得到最近登录用户的登录信息<br/>
	 * 第一位是手机号，第二位是密码，第三位是id
	 */
	public ArrayList<String> loadLoginUser() {
		try {
			String current = FileHelper.readString(mPhoneRootPath, "cts.dp",false);
			if (current != null && !current.equals("")) {
				JSONObject object = new JSONObject(Encryption.dencryption(current, Constants.KEY_CTS));
				String phone = object.optString("dph");
				String pwd = object.optString("dpp");
				String id = object.optString("dpi");
				ArrayList<String> info = new ArrayList<String>();
				info.add(phone);
				info.add(pwd);
				info.add(id);
				return info;
			}
			return null;
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 密文保存历史浏览记录到本地
	 * @param data 历史浏览数据的JOSN文本
	 */
	public void saveUserReadHistory(String data){
		FileHelper.saveFile(Encryption.encryption(data, Constants.KEY_CTS), getUserPath(),"rds.png",false);
	}
	
	/**
	 * 得到历史浏览记录的明文JSON文本
	 */
	public String loadUserReadHistory(){
		String historyMi = FileHelper.readString(getUserPath(), "rds.png",false);
		return Encryption.dencryption(historyMi, Constants.KEY_CTS);
	}
	
	/**
	 * 密文保存历史搜索记录到本地
	 * @param data 历史浏览数据的JOSN文本
	 */
	public void saveUserSearchHistory(String data){
		FileHelper.saveFile(Encryption.encryption(data, Constants.KEY_CTS), getUserPath(),"sed.png",false);
	}
	
	/**
	 * 得到历史搜索记录的明文JSON文本
	 */
	public String loadUserSearchHistory(){
		String historyMi = FileHelper.readString(getUserPath(), "sed.png",false);
		return Encryption.dencryption(historyMi, Constants.KEY_CTS);
	}
	
	
	/**
	 * 将当期登录信息保存到登录列表<br/>
	 * 用于离线登录
	 * 
	 * @param phoneNumber
	 *            登录的手机号
	 * @param id
	 *            登录用户的id(因为离线登录，所以需要保存id，以便离线时查询这个的密码是否正确)
	 */
	/*
	 * public void saveLoginList(String phoneNumber, String id) { try {
	 * JSONObject obj = null; String str = FileHelper.readString(mPhoneRootPath,
	 * "login_list.json"); if ("".equals(str)) { obj = new JSONObject(); } else
	 * { obj = new JSONObject(str); } obj.put(phoneNumber, id);
	 * FileHelper.saveFile(obj.toString(), mPhoneRootPath, "login_list.json"); }
	 * catch (JSONException e) { e.printStackTrace(); } }
	 */

	/**
	 * 将当前用户的登录信息从登录列表中移除<br/>
	 * 当用户注销退出应用是需要调用
	 */
	/*
	 * public void delLoginInList() { try { JSONObject object = new
	 * JSONObject(FileHelper.readString( mPhoneRootPath, "login_list.json"));
	 * object.remove(Constants.getUser().getPhoneNumber());
	 * FileHelper.saveFile(object.toString(), mPhoneRootPath,
	 * "login_list.json"); } catch (JSONException e) { e.printStackTrace(); } }
	 */

	/**
	 * 离线登录时，通过用户输入的手机号找到这个用户的id，从而通过id查询到本地的密码
	 * 
	 * @param phoneNumber
	 *            用户输入的手机号
	 * @return 用户的id
	 */
	/*
	 * public String loadIdByPhone(String phoneNumber) { try { JSONObject object
	 * = new JSONObject(FileHelper.readString( mPhoneRootPath,
	 * "login_list.json")); return object.optString(phoneNumber, ""); } catch
	 * (JSONException e) { e.printStackTrace(); return ""; } }
	 */

	/**
	 * 加载用户的认证信息，因为考虑到离线状态，所以需要保存到本地
	 * 
	 * @return
	 */
	public JSONObject loadUserAuthState() {
		try {
			JSONObject object = new JSONObject(FileHelper.readString(instance.getUserPath(), "certification.json",false));
			return object;
		} catch (JSONException e) {
			e.printStackTrace();
			return null;
		}
	}

	/**
	 * 保存实例
	 */
	public void saveEntity(HalcyonEntity entity) {
		try {
			if (entity == null)
				return;// EntityUtil.GetJsonString(entity)
			FileHelper.saveFile(entity.getJson().toString(), instance.getUserPath(), entity.getClass().getSimpleName(),false);
		} catch (Exception e) {
		}
	}

	public boolean comparePassword(String phoneNumber, String password) {
		String path = mPhoneRootPath + USER_DIR + phoneNumber;
		File file = new File(path);
		if (file.exists()) {
			try {
				JSONObject object = new JSONObject(FileHelper.readString(path, "pre.dp",false));
				// User user = EntityUtil.FromJson(object, User.class);
				User user = new User();
				user.setAtttributeByjson(object);
				if (user.getPassword().equals(password)) {
					return true;
				}
			} catch (Exception e) {
			}
		}
		return false;
	}

	/**
	 * 获得用户图片的路径
	 * 
	 * @return
	 */
	public String getUserImagePath() {
		return mPhoneRootPath + USER_DIR + getMD5UserId("" + Constants.getUser().getUserId()) + "/img/";
	}

	/**
	 * 用户访问服务器返回api的文件目录
	 * 
	 * @return
	 */
	public String getUserApiPath() {
		return mPhoneRootPath + USER_DIR + getMD5UserId("" + Constants.getUser().getUserId()) + "/api";
	}

	/**
	 * 用户访问服务器返回病历信息
	 * 
	 * @return
	 */
	public String getRecordCachePath() {
		String path = getUserPath() + "ds/";
		File file = new File(path);
		if (!file.exists()) {
			file.mkdirs();
		}
		return path;
	}
	
	/**
	 * 返回用户缓存目录，主要保存病历列表
	 * @return
	 */
	public String getUserCachePath(){
		String path = getUserPath() + MD5.Md5("cache")+"/";
		File file = new File(path);
		if (!file.exists()) {
			file.mkdirs();
		}
		return path;
	}

	/**
	 * 后台同步的目录，不为空表示有后台同步
	 * 
	 * @return
	 */
	public String getUserLoopPath() {
		return mPhoneRootPath + USER_DIR + getMD5UserId("" + Constants.getUser().getUserId()) + "/loop";
	}

	/**
	 * 获得用户头像名称
	 * 
	 * @return
	 */
	public String getUserHeadName() {
		return "head"+Constants.getUser().getImageId();// + getMD5UserId(""+Constants.getUser().getUserId());
	}

	/**
	 * 获得用户头像路径
	 * 
	 * @return
	 */
	public String getUserHeadPath() {
		return FileSystem.getInstance().getUserImagePath() + FileSystem.getInstance().getUserHeadName();
	}

	/**
	 * 医生认证图片名称
	 * 
	 * @param type
	 *            照片类型 1资格证 2身份证正 3身份证反
	 */
	public String getAuthImgNameByType(int type) {
		return "auth" + type;// + "_" +
								// getMD5UserId(""+Constants.getUser().getUserId());
	}

	/**
	 * 医生认证图片路径
	 * 
	 * @param type
	 *            照片类型 1资格证 2身份证正 3身份证反
	 */
	public String getAuthImgPathByType(int type) {
		return FileSystem.getInstance().getUserImagePath() + getAuthImgNameByType(type);
	}

	/** 获得用户动作记录的文件路径 */
	public String getUserActionPath() {
		return getUserPath() + "acts";
	}

	/**
	 * 获得缓存图片的的容量大小,返回单位M、K、B
	 * 
	 * @return 如果没有则为0B
	 */
	public String getCacheSize() {
		long size = 0;
		File file = new File(FileSystem.getInstance().getRecordImgPath());
		if (file.exists()) {
			size = FileHelper.getFileSize(file);
			return "" + Tool.getSize(size);
		} else {
			return "0B";
		}
	}

	/**
	 * 清除缓存图片,这里为清除本地的病历图片
	 * 
	 * @return
	 */
	public String clearCache() {
		final File file = new File(FileSystem.getInstance().getRecordImgPath());
		new Thread(new Runnable() {
			@Override
			public void run() {
				FileHelper.deleteFile(file, false);
			}
		}).start();
		return "0B";
	}

	/*
	 * //获取认证行医资格证书的图片名字 public String getCertificationImageName(){ return
	 * "certification"+Constants.getUser().getUserId()+".jpg"; }
	 * 
	 * //获取认证行医资格证书的图片路径 public String getCertificationImagePath(){ return
	 * getUserImagePath()+"/"+ getCertificationImageName(); }
	 * 
	 * //获取身份证正面的图片名字 public String getCardZhengImageName(){ return
	 * "cardzheng"+Constants.getUser().getUserId()+".jpg"; }
	 * 
	 * //获取身份证正面的图片路径 public String getCardZhengImagePath(){ return
	 * getUserImagePath()+"/" + getCardZhengImageName(); }
	 * 
	 * //获取身份证反面的图片名字 public String getCardFanImageName(){ return
	 * "cardfan"+Constants.getUser().getUserId()+".jpg"; }
	 * 
	 * //获取身份证反面的图片路径 public String getCardFanImagePath(){ return
	 * getUserImagePath()+"/"+ getCardFanImageName(); }
	 */

	/**
	 * 获取本地缓存的数据
	 * 
	 * @param url
	 * @param params
	 * @return 如果是api接口直接返回String数据，如果是图片这返回本地地址
	 */
//	public String getLocalCacheData(String url, FQHttpParams params) {
//		String localPath = getLocalPath(url, params);
//		if (localPath.equals(RecordDatabaseHelper.DB_NAME)) {// 数据库文件
//			RecordDB record = RecordDatabaseHelper.get(params.getJson().optJSONObject("record").optInt("record_id"));
//			return record.getBody();
//		}
//		boolean isApiType = isApiUrl(url);
//		if (isApiType) {
//			String fileDataString = FileHelper.readString(localPath,false);
//			if (fileDataString == null || fileDataString.equals("")) {
//				return null;
//			} else {
//				if (url.equals(PathUrlMap.ALLURL[PathUrlMap.EXAM_ITEMS])) { // 化验变动
//					try {
//						JSONArray items = new JSONArray(fileDataString);
//						String itemName = params.getJson().optJSONObject("record").optString("item_name");
//						if (itemName == null || itemName.equals("")) {
//							return items.toString();
//						}
//						for (int i = 0; i < items.length(); i++) {
//							JSONObject item = items.optJSONObject(i);
//							if (!item.optString("item_name", "").equals(itemName)) {
//								items.remove(i);
//							}
//						}
//						return items.toString();
//					} catch (Exception e) {
//					}
//
//				}
//				return fileDataString;
//			}
//		}
//		return localPath;
//	}
//
//	public void setLocalCacheData(String url, FQHttpParams params, String data, String extra) {
//		String localPath = getLocalPath(url, params);
//		if (localPath.equals(RecordDatabaseHelper.DB_NAME)) {// 数据库文件
//			RecordDB record = new RecordDB();
//			record.setId(params.getJson().optJSONObject("record").optInt("record_id"));
//			record.setBody(data);
//			int doctorPatientId = 0;
//			try {
//				doctorPatientId = Integer.valueOf(extra);
//			} catch (Exception e) {
//				// TODO: handle exception
//			}
//			record.setDoctor_patient_id(doctorPatientId);
//			RecordDatabaseHelper.update(record);
//			return;
//		}
//		boolean isApiType = isApiUrl(url);
//		if (isApiType) {
//			if (url.equals(PathUrlMap.ALLURL[PathUrlMap.EXAM_ITEMS])) {// 化验变动
//				try {
//					JSONArray items;
//					String fileDataString = FileHelper.readString(localPath,false);
//					File file = new File(localPath);
//					if (file.exists()) {
//						items = new JSONArray(fileDataString);
//					} else {
//						items = new JSONArray();
//					}
//					JSONArray saveitems = new JSONObject(data).optJSONArray("results");
//					for (int i = 0; i < saveitems.length(); i++) {
//						JSONObject item = saveitems.optJSONObject(i);
//						for (int j = 0; j < items.length(); j++) {
//							if (items.optJSONObject(j).optString("item_name").equals(item.optString("item_name"))) {
//								items.remove(j);
//								break;
//							}
//						}
//						items.put(item);
//					}
//					FileHelper.saveFile(items.toString(), localPath,false);
//					return;
//				} catch (Exception e) {
//				}
//
//			}
//			FileHelper.saveFile(data, localPath,false);
//		} else {
//			// TODO 保存图片
//		}
//	}

	private boolean isApiUrl(String url) {
		return !url.endsWith(".png") || !url.endsWith(".jpg");
	}

	private String getLocalPath(String url, FQHttpParams params) {
		String localPath = null;
		localPath = PathUrlMap.getLocalPath(url, params);
		if (localPath != null)
			return localPath;
		String realUrl = url;
		boolean isApiType = isApiUrl(url);
		if (params != null) {
			try {
				Object version = params.getJson().remove("version");
				if (params.getJson().length() != 0) {
					realUrl += params.getStringParams();
				}
				if (version != null) {
					try {
						params.getJson().put("version", version);
					} catch (JSONException e) {
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		if (isApiType) {
			String apiPath = getUserApiPath() + "/";
			return apiPath + MD5.Md5(realUrl);
		} else {
			// TODO 如果是图片
			return FileSystem.getInstance().getRecordImgPath();
		}
	}

	/** 保存病历图片 */
	public void saveRecordImg(byte[] bys, String name) {
		FileHelper.saveFile(bys, getRecordImgPath(), name);
	}
	
	/***
	 * 初始化message数据库路径
	 */
	public void initMessageRootPath(String path){
		File file = new File(path);
		if(!file.exists()){
			file.mkdirs();
		}
	}
}
