package com.fq.halcyon.api;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.HalyconOnLineHandle;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.FQHeader;
import com.fq.http.async.FQHttpParams;
import com.fq.http.async.ParamsWrapper.FQDownLoadImageInterface;
import com.fq.http.potocol.FQBinaryResponseHandle;
import com.fq.http.potocol.FQHttpResponseHandle;
import com.fq.http.potocol.FQJsonResponseHandle;
import com.fq.http.potocol.HttpRequestPotocol;
import com.fq.lib.HttpHelper;
import com.fq.lib.callback.ICallback;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.fq.lib.tools.UriConstants;

public class ApiSystem {

	public enum API_TYPE {

		/**
		 * 数据浏览，请求网络（失败则返回本地缓存数据）,成功后把数据给ui层并更新本地数据
		 */
		BROW,

		/**
		 * 首先更改本地数据，后台同步模块再同步到服务器
		 */
		OFFLINE,

		/**
		 * 访问网络成功后修改本地数据，失败返回error
		 */
		ONLINE,

		/**
		 * 直接访问网络，没有本地缓存
		 */
		DIRECT
	}
	
	
	private ArrayList<FQHttpResponseHandle> handles;

	private static ApiSystem instance;
	
	private NotifyOk mNotify;
	
	public interface NotifyOk{
		public void onImageSeted();
	}

	public void setNotify(NotifyOk mNotify) {
		this.mNotify = mNotify;
	}

	public void onDataSet(){
		if (mNotify!= null) {
			mNotify.onImageSeted();
		}
	}
	
	public static ApiSystem getInstance() {
		if (instance == null) {
			instance = new ApiSystem();
		}
		return instance;
	}

	public ApiSystem() {
		handles = new ArrayList<FQHttpResponseHandle>();
	}

	public HttpRequestPotocol require(String url, API_TYPE type, HalcyonHttpResponseHandle handle) throws IllegalArgumentException{
		return require(url, null, type, handle);
	}

	public HttpRequestPotocol require(final String url, final FQHttpParams params, final API_TYPE type, final HalcyonHttpResponseHandle handle) throws IllegalArgumentException{
		if(type == API_TYPE.ONLINE && !(handle instanceof HalyconOnLineHandle)){
			handle.handleError(0,new IllegalArgumentException("handle must be HalyconOnLineHandle for ONLINE type"));
			return null;
		}
		if(type == API_TYPE.OFFLINE){
			//TODO post到循环队列
			return null;
		}else if (type == API_TYPE.DIRECT) {
			return HttpHelper.sendPostRequest(url, params, handle);
		}else {
			handles.add(handle);
			return HttpHelper.sendPostRequest(url, params, new FQJsonResponseHandle() {

				@Override
				public void onError(int code,Throwable e) {
					if (e != null) {
						ApiSystem.this.onError(url, params, type, handle, 0, e.getMessage(),e);
					} else {
						ApiSystem.this.onError(url, params, type, handle, 0, "unknow error",e);
					}
					handles.remove(handle);
				}

				@Override
				public void handleJson(JSONObject json) {
					int responseCode = json.optInt("response_code");
					String msg = json.optString("msg");
					if (responseCode != 0) {
						ApiSystem.this.onError(url, params, type, handle, responseCode, msg,new Throwable("responseCode:"+responseCode+" msg:"+msg));
					} else {
						ApiSystem.this.onSuccess(url, params, type, handle, json);
					}
					handles.remove(handle);
				}

			});
		}
	}

//	private HashMap<String, ICallback> mCurrnetDownUrls = new HashMap<String, ICallback>();
//	private ArrayList<ICallback> callbackList = new ArrayList<ICallback>();
	private HashMap<String, ArrayList<ICallback>> mCurrnetDownUrls = new HashMap<String, ArrayList<ICallback>>();
	private ArrayList<ICallback> callbackList;
	/**
	 * get image use http post
	 * @param photo    	  
	 * @param callback	  成功的callbac，回调是本地图片地址
	 * @param thumbnail   是否是下载缩略图
	 */
	public void getImage(Photo photo, ICallback callback,boolean thumbnail) {
		if(photo.getImageId() == 0) return;
		String localPath = FileSystem.getInstance().getRecordImgPath() + photo.getImageId();
		File localFile = new File(thumbnail?localPath+".thumbnail":localPath+FileSystem.RED_IMG_FT);
		if (localFile.exists()) {
			callback.doCallback(localFile.getAbsolutePath());
		} else {
			String URL = UriConstants.getImageURL();
			JSONObject jsonParams = new JSONObject();
			try {
				jsonParams.put("image_id",  photo.getImageId()==0?20253:photo.getImageId());
				if (UriConstants.Conn.PRODUCTION_ENVIRONMENT) {
					jsonParams.put("style", thumbnail?"@!thumbnail001":"");
				}
			} catch (Exception e) {
			}
			FQHttpParams params = new FQHttpParams(jsonParams);
			String fullUrl = URL+"?image_id="+photo.getImageId()+"&thumbnail="+thumbnail;
			File file  = new File(FileSystem.getInstance().getRecordImgPath());
			if(!file.exists())file.mkdirs();
//			if(mCurrnetDownUrls.get(fullUrl) != null){ //正在下载，替换callback
//				mCurrnetDownUrls.put(fullUrl, callback);
//				return;
//			}
//			mCurrnetDownUrls.put(fullUrl, callback);
			if(mCurrnetDownUrls.get(fullUrl) != null){
				callbackList = mCurrnetDownUrls.get(fullUrl);
				callbackList.add(callback);
				mCurrnetDownUrls.put(fullUrl, callbackList);
				return;
				
			}	
			callbackList = new ArrayList<ICallback>();
			callbackList.add(callback);
			mCurrnetDownUrls.put(fullUrl, callbackList);
			HttpHelper.sendPostRequest(URL, params, getImgaeHandel(localFile, fullUrl));
		}
	}
	
	/**
	 * get image use http post
	 * @param photo    	  
	 * @param callback	  成功的callbac，回调是本地图片地址
	 * @param thumbnail   是否是下载缩略图
	 * @param downLoadInterface   下载进度
	 */
	public void getImage(Photo photo, ICallback callback,boolean thumbnail,FQDownLoadImageInterface downLoadInterface,Object obj) {
		if(photo.getImageId() == 0) return;
		String localPath = FileSystem.getInstance().getRecordImgPath() + photo.getImageId();
		File localFile = new File(thumbnail?localPath+".thumbnail":localPath+FileSystem.RED_IMG_FT);
		if (localFile.exists()) {
			callback.doCallback(localFile.getAbsolutePath());
		} else {
			String URL = UriConstants.getImageURL();
			JSONObject jsonParams = new JSONObject();
			try {
				jsonParams.put("image_id",  photo.getImageId()==0?20253:photo.getImageId());
				if (UriConstants.Conn.PRODUCTION_ENVIRONMENT) {
					jsonParams.put("style", thumbnail?"@!thumbnail001":"");
				}
//				jsonParams.put("progressview", obj);
			} catch (Exception e) {
			}
			
			FQHttpParams params = new FQHttpParams(jsonParams);
			if(params != null) {
				params.setDownLoadProgress(downLoadInterface);
				params.setTag(obj);
			}
			
			String fullUrl = URL+"?image_id="+photo.getImageId()+"&thumbnail="+thumbnail;
			File file  = new File(FileSystem.getInstance().getRecordImgPath());
			if(!file.exists())file.mkdirs();
//			if(mCurrnetDownUrls.get(fullUrl) != null){ //正在下载，替换callback
//				mCurrnetDownUrls.put(fullUrl, callback);
//				return;
//			}
//			mCurrnetDownUrls.put(fullUrl, callback);
			if(mCurrnetDownUrls.get(fullUrl) != null){
				callbackList = mCurrnetDownUrls.get(fullUrl);
				callbackList.add(callback);
				mCurrnetDownUrls.put(fullUrl, callbackList);
				return;
				
			}	
			callbackList = new ArrayList<ICallback>();
			callbackList.add(callback);
			mCurrnetDownUrls.put(fullUrl, callbackList);
			HttpHelper.sendPostRequest(URL, params, getImgaeHandel(localFile, fullUrl));
		}
	}
	
	
	
	/**
	 * get head image use http post
	 * @param photo    	  
	 * @param callback	  成功的callbac，回调是本地图片地址
	 * @param thumbnail   是否是下载缩略图
	 * @param Type	  	1代表user的头像  2代表用户的朋友头像 3病历图片 4user的验证图片路径 (3暂时不用使用getImage方法)
	 */
	public void getHeadImage(Photo photo, ICallback callback,boolean thumbnail,int Type) {
		if(photo.getImageId() == 0) return;
		String localPath = "";
		switch (Type) {
		case 1:
			localPath = FileSystem.getInstance().getUserHeadPath();
			break;
		case 2:
			localPath =  FileSystem.getInstance().getFriendPathWithImageId(photo.getImageId()==0?20253:photo.getImageId());
			break;
		case 3:
			localPath =  FileSystem.getInstance().getRecordImgPath()+ photo.getImageId();
			break;
		case 4:
			localPath  = FileSystem.getInstance().getAuthImgPathByType(1);
		default:
			break;
		}
	
		File localFile = new File(thumbnail?localPath+".thumbnail":localPath);
		File parentFile = localFile.getParentFile();
		if (parentFile != null) {
			if (!parentFile.exists()) {
				parentFile.mkdirs();
			}
		}
	
		if (localFile.exists()) {
			callback.doCallback(localFile.getAbsolutePath());
		} else {
			String URL = UriConstants.getImageURL();
			JSONObject jsonParams = new JSONObject();
			try {
				jsonParams.put("image_id", photo.getImageId()==0?20253:photo.getImageId());
//				jsonParams.put("style", thumbnail?"@!thumbnail001":"");
			} catch (Exception e) {
			}
			FQHttpParams params = new FQHttpParams(jsonParams);
			String fullUrl = URL+"?image_id="+photo.getImageId()+"&thumbnail="+thumbnail;
//			if(mCurrnetDownUrls.get(fullUrl) != null){ //正在下载，替换callback
//				mCurrnetDownUrls.put(fullUrl, callback);
//				return;
//			}
//			mCurrnetDownUrls.put(fullUrl, callback);
			if(mCurrnetDownUrls.get(fullUrl) != null){
				callbackList = mCurrnetDownUrls.get(fullUrl);
				callbackList.add(callback);
				mCurrnetDownUrls.put(fullUrl, callbackList);
				return;
				
			}	
			callbackList = new ArrayList<ICallback>();
			callbackList.add(callback);
			mCurrnetDownUrls.put(fullUrl, callbackList);
			HttpHelper.sendPostRequest(URL, params, getImgaeHandel(localFile, fullUrl));
//			HttpHelper.sendPostRequest(URL, params, getImgaeHandel(localFile, fullUrl));
		}
	}
	
	/**
	 * get image use http post,{@link #getImage(Photo, ICallback, boolean)}
	 */
	public void getImage(PhotoRecord image, ICallback callback,boolean thumbnail) {
		Photo photo = new Photo();
		photo.setImageId(image.getImageId());
		photo.setImagePath(image.getImagePath());
		getImage(photo, callback,thumbnail);
	}
	
	/**
	 * this method used httpget to download image, {@link #getImage(PhotoRecord, ICallback, boolean)} replaced
	 */
	@Deprecated
	public void getImage(PhotoRecord image, ICallback callback) {
		Photo photo = new Photo();
		photo.setImageId(image.getImageId());
		photo.setImagePath(image.getImagePath());
		getImage(photo, callback);
	}
	
	/**
	 * this method used httpget to download image, {@link #getImage(Photo, ICallback, boolean)} replaced
	 */
	@Deprecated
	public void getImage(Photo photo, ICallback callback) {
		getImage(photo, callback,false);
	}

	
	private FQBinaryResponseHandle getImgaeHandel(final File localFile,final String url){
		return new FQBinaryResponseHandle() {
			
			@Override
			public void onError(int code,Throwable e) {
//				ICallback callback = mCurrnetDownUrls.get(url);
//				callback.doCallback("");
				ArrayList<ICallback> callbackList =  mCurrnetDownUrls.get(url);
				for (int i = 0; i < callbackList.size(); i++) {
					callbackList.get(i).doCallback("");
				}
				mCurrnetDownUrls.remove(url);
			}
			
			@Override
			public void handleBinaryData(byte[] data) {
				FQHttpResponseHandle handle = new FQHttpResponseHandle() {
					
					@Override
					public void onError(int code, Throwable e) {
//						ICallback callback = mCurrnetDownUrls.get(url);
//						callback.doCallback("");
						ArrayList<ICallback> callbackList =  mCurrnetDownUrls.get(url);
						for (int i = 0; i < callbackList.size(); i++) {
							callbackList.get(i).doCallback("");
						}
						mCurrnetDownUrls.remove(url);
					}
					
					@Override
					public void handleResponse(byte[] data) {
//						ICallback callback = mCurrnetDownUrls.get(url);
						ArrayList<ICallback> callbackList =  mCurrnetDownUrls.get(url);
						
						mCurrnetDownUrls.remove(url);
						FileOutputStream mFileOutputStream = null;
						
						//如果图片是病历的原图，需要通知系统扫描文件，更新相册
						String path = localFile.getAbsolutePath();
						if(path.contains(FileSystem.RECORD_FOLDER)){
							if(Platform.getInstance()!=null)Platform.getInstance().scanFile(path);
						}
						
						try {
							 mFileOutputStream = new FileOutputStream(localFile);
							try {
								mFileOutputStream.write(data);
								mFileOutputStream.flush();
							} catch (IOException e) {
								e.printStackTrace();
							}
						} catch (FileNotFoundException e) {
							e.printStackTrace();
						}finally{
							if(mFileOutputStream!=null){
								try {
									mFileOutputStream.close();
								} catch (IOException e) {
									e.printStackTrace();
								}
							}
						}
//						callback.doCallback(path);
						for (int i = 0; i < callbackList.size(); i++) {
							callbackList.get(i).doCallback(path);
						}
//						onDataSet();
					}

					@Override
					public FQHeader[] getRequestHeaders() {
						// TODO Auto-generated method stub
						return null;
					}

					@Override
					public void setRequestHeaders(FQHeader[] headers) {
						// TODO Auto-generated method stub
						
					}
				};
				if(Platform.getInstance().getTargetPlatform() == Platform.PLANTFORM_ANDROID){
					String imageUrl = new String(data);
					HttpHelper.sendGetRequest(imageUrl, handle);
				}else{
					handle.handleResponse(data);
				}
				
			}

			@Override
			public FQHeader[] getRequestHeaders() {
				return null;
			}

			@Override
			public void setRequestHeaders(FQHeader[] headers) {
			}
		};
		
	}

	private void onError(String url, FQHttpParams params, API_TYPE type, HalcyonHttpResponseHandle handle, int code, String msg,Throwable e) {
		switch (type) {
		case BROW:
			// 返回本地数据
			handle.handleError(code, e);;
//			String localData = FileSystem.getInstance().getLocalCacheData(url, params);
//			if (localData == null) {
//				handle.onError(code,e==null?new Throwable("network error and load local cache failed"):e);
//			} else {
//				do {
//					if(localData.trim().startsWith("{")){
//						try {
//							JSONObject json = new JSONObject(localData);
//							handle.handleJson(json, false);
//							break;
//						} catch (Exception error) {
//							e.printStackTrace();
//						}
//					}
//					try {
//						JSONArray json = new JSONArray(localData);
//						handle.handle(0,"",2,json);
//					} catch (Exception error) {
//						e.printStackTrace();
//					}
//				} while (false);
//			}
			break;
		case OFFLINE:

			break;
		case ONLINE:
			// 返回error
			handle.handleError(code,e==null?new Throwable("responseCode:"+code+" msg:"+msg):e);
			break;
		default:
			break;
		}
	}

	private void onSuccess(String url, FQHttpParams params, API_TYPE type, HalcyonHttpResponseHandle handle, JSONObject result) {
		switch (type) {
		case BROW:
			// 返回网络数据，并修改本地数据
			String doctorPatientId = "";
			try {
				doctorPatientId = result.optJSONObject("results").optString("doctor_patient_id");
				int returnVersion = result.optJSONObject("results").optInt("version");
				int localversion = params.getJson().optInt("version",-1);
				if(localversion == returnVersion){
					try {
//						handle.handleJson(new JSONObject(FileSystem.getInstance().getLocalCacheData(url, params)), true);
						return;
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			} catch (Exception e) {
			}
//			FileSystem.getInstance().setLocalCacheData(url, params, result.toString(),doctorPatientId);
			handle.handleJson(result, true);
			break;
		case OFFLINE:

			break;
		case ONLINE:
			// 放回网络数据
			handle.handleJson(result, true);
			// 数据缓存到本地
			int responseCode = result.optInt("response_code");
			if(handle instanceof HalyconOnLineHandle){
				if(responseCode == 0)((HalyconOnLineHandle)handle).saveData(true);
				else ((HalyconOnLineHandle)handle).saveData(false);
			}
			break;
		default:
			break;
		}
	}

}
