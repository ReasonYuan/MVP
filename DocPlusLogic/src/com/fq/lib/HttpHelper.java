package com.fq.lib;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.http.async.FQHttpParams;
import com.fq.http.async.ParamsWrapper.FQProcessInterface;
import com.fq.http.async.ParamsWrapper.FQUpLoadImageInterface;
import com.fq.http.potocol.FQBinaryResponseHandle;
import com.fq.http.potocol.FQHttpResponseHandle;
import com.fq.http.potocol.HttpClientPotocol;
import com.fq.http.potocol.HttpRequestPotocol;
import com.fq.lib.callback.ICallback;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;

public class HttpHelper {

	private static HttpClientPotocol mClient;
	
	public static void  setHttpClient(HttpClientPotocol client){
		mClient = client;
	}

	public static HttpRequestPotocol sendGetRequest(String url, FQHttpResponseHandle handle) {
		return mClient.sendGetRequest(url, handle);
	}

	public static HttpRequestPotocol sendGetRequest(String url, FQHttpParams params, FQHttpResponseHandle handle) {
		return mClient.sendGetRequest(url, params, handle);
	}

	public static HttpRequestPotocol sendPostRequest(String url, FQHttpResponseHandle handle) {
		return mClient.sendPostRequest(url, handle);
	}

	public static HttpRequestPotocol sendPostRequest(String url, FQHttpParams params, FQHttpResponseHandle handle) {
		return mClient.sendPostRequest(url, params, handle);
	}
	
	/**
	 * 取消请求  上传图片参数传 图片路径 filepath   其他请求暂时未做处理
	 * @param paramsString
	 */
	public static void cancle(String paramsString){
		 mClient.cancle(paramsString);
	}
	
	
	/**
	 * 针对附件上传的方法
	 * @param key    
	 * @param value    imageName
	 * @param fielPath imagePath
	 * @param isOCR 上传的图片是否需要自动OCR。如果需要则为true，不需要则为false（默认不需要）。
	 * @param handle
	 * @param process  process of upload file
	 */
	public static HttpRequestPotocol upLoadImage(String url,String key,PhotoRecord photoRecord,boolean isOCR,FQHttpResponseHandle handle,FQUpLoadImageInterface process,Object objec){
		FQHttpParams params = null;
		JSONObject arg = new JSONObject();
		if(!isOCR){//如果不需要OCR,则进入里面的代码
			try {
				arg.put("is_attachment", 1);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		params = new FQHttpParams(arg);
		params.setTimeoutTime(600000);
		File file = new File(photoRecord.getLocalPath());
		if(!file.exists()){
			System.out.println("本地文件不存在！");
			return null;
		}
		try {
			params.put(key, file);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		if(process != null){
			params.setUpLoadProgress(process);
			params.setTag(objec);
		}
		params.setFilePath(photoRecord.getPath());
		return mClient.sendPostRequest(url, params, handle);
	}
	
	
	
	
	/**
	 * 
	 * @param key    
	 * @param value    imageName
	 * @param fielPath imagePath
	 * @param isOCR 上传的图片是否需要自动OCR。如果需要则为true，不需要则为false（默认不需要）。
	 * @param handle
	 * @param process  process of upload file
	 */
	public static HttpRequestPotocol upLoadImage(String url,String key,String fielPath,boolean isOCR,FQHttpResponseHandle handle,FQProcessInterface process){
		FQHttpParams params = null;
		JSONObject arg = new JSONObject();
		if(!isOCR){//如果不需要OCR,则进入里面的代码
			try {
				arg.put("is_attachment", 1);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		params = new FQHttpParams(arg);
		params.setTimeoutTime(600000);
		File file = new File(fielPath);
		if(!file.exists()){
			System.out.println("本地文件不存在！");
			return null;
		}
		try {
			params.put(key, file);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		if(process != null){
			params.setUpLoadProcess(process);
		}
//		params.setFilePath(fielPath);
		return mClient.sendPostRequest(url, params, handle);
	}
	
	/**
	 * 
	 * @param key    
	 * @param value    imageName
	 * @param fielPath imagePath
	 * @param isOCR 上传的图片是否需要自动OCR。如果需要则为true，不需要则为false（默认不需要）。
	 * @param handle
	 * @param process  process of upload file
	 */
	public static HttpRequestPotocol upLoadImage(String url,String key,String fielPath,boolean isOCR,FQHttpResponseHandle handle,FQUpLoadImageInterface process,Object objec){
		FQHttpParams params = null;
		JSONObject arg = new JSONObject();
		if(!isOCR){//如果不需要OCR,则进入里面的代码
			try {
				arg.put("is_attachment", 1);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		params = new FQHttpParams(arg);
		params.setTimeoutTime(600000);
		File file = new File(fielPath);
		if(!file.exists()){
			System.out.println("本地文件不存在！");
			return null;
		}
		try {
			params.put(key, file);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		if(process != null){
			params.setUpLoadProgress(process);
			params.setTag(objec);
		}

		return mClient.sendPostRequest(url, params, handle);
	}
	
	public static HttpRequestPotocol upLoadImage(String url,String fielPath,boolean isUnOCR,FQHttpResponseHandle handle){
		return upLoadImage(url,"file",fielPath,isUnOCR,handle,new FQProcessInterface() {
			
			@Override
			public void setProcess(float process) {
				
			}
		});
	}
	
	public static HttpRequestPotocol upLoadImage(String url,String fielPath,boolean isUnOCR,FQHttpResponseHandle handle,FQProcessInterface process){
		return upLoadImage(url,"file",fielPath,isUnOCR,handle,process);
	}
	
	public static HttpRequestPotocol upLoadImage(String url,String fielPath,boolean isUnOCR,FQHttpResponseHandle handle,FQUpLoadImageInterface process,Object object){
		return upLoadImage(url,"file",fielPath,isUnOCR,handle,process,object);
	}
	
	/**
	 * 针对上传附件需要取消请求写的一个特殊的上传
	 * @param url
	 * @param fielPath
	 * @param isUnOCR
	 * @param handle
	 * @param process
	 * @param object
	 * @return
	 */
	public static HttpRequestPotocol upLoadImage(String url,PhotoRecord photoRecord,boolean isUnOCR,FQHttpResponseHandle handle,FQUpLoadImageInterface process,Object object){
		return upLoadImage(url,"file",photoRecord,isUnOCR,handle,process,object);
	}
	
	/**
	 * 
	 * @param url
	 * @param params
	 * @param loadCache
	 *            是否在缓存在本地，如果本地有缓存则马上返回本地数据，再请求网络
	 * @param path
	 *            缓存目录
	 * @param handle
	 */
	public static HttpRequestPotocol sendGetRequest(String url, FQHttpParams params, boolean loadCache, String path, HalcyonHttpResponseHandle handle) {
		return mClient.sendGetRequest(url, params, handle);

	}

	/**
	 * 
	 * @param url
	 * @param params
	 * @param loadCache
	 *            是否在缓存在本地，如果本地有缓存则马上返回本地数据，再请求网络
	 * @param path
	 *            缓存目录
	 * @param handle
	 */
	public static HttpRequestPotocol sendPostRequest(String url, FQHttpParams params, boolean loadCache, String path, HalcyonHttpResponseHandle handle) {
		return mClient.sendPostRequest(url, params, handle);
	}

	/**
	 * 
	 * @param url
	 * @param params
	 * @param loadCache
	 *            是否在缓存在本地，如果本地有缓存则马上返回本地数据，再请求网络
	 * @param path
	 *            缓存目录
	 * @param handle
	 */
	public static HttpRequestPotocol sendPostRequest(String url, boolean loadCache, String path, HalcyonHttpResponseHandle handle) {
		return mClient.sendPostRequest(url, handle);
	}

	/**
	 * 
	 * @param url
	 * @param params
	 * @param loadCache
	 *            是否在缓存在本地，如果本地有缓存则马上返回本地数据，再请求网络
	 * @param path
	 *            缓存目录
	 * @param unique
	 *            唯一码，有些数据url地址是一样的，post的数据不一样，用缓存是可以用唯一码来区分
	 * @param handle
	 */
	public static HttpRequestPotocol sendGetRequest(String url, FQHttpParams params, boolean loadCache, String path, String unique, HalcyonHttpResponseHandle handle) {
		return mClient.sendGetRequest(url, params, handle);

	}

	/**
	 * 
	 * @param url
	 * @param params
	 * @param loadCache
	 *            是否在缓存在本地，如果本地有缓存则马上返回本地数据，再请求网络
	 * @param path
	 *            缓存目录
	 * @param unique
	 *            唯一码，有些数据url地址是一样的，post的数据不一样，用缓存是可以用唯一码来区分
	 * @param handle
	 */
	public static HttpRequestPotocol sendPostRequest(String url, FQHttpParams params, boolean loadCache, String path, String unique, HalcyonHttpResponseHandle handle) {
		return mClient.sendPostRequest(url, params, handle);
	}
	
	/**
	 * 下载网络图片并保存在手机sd卡上
	 * @param mImageUrl
	 * @param path
	 */
	public static void sendGetRequestImage(final String mImageUrl,final String path,final ICallback callback){
		int indexEnd = mImageUrl.lastIndexOf('?');
		int indexStart = mImageUrl.lastIndexOf('/')+1;
		final String mImageName = mImageUrl.substring(indexStart, indexEnd);
		File mFile = new File(path);
		if(!mFile.exists()){
			mFile.mkdirs();
		}
		final File mImage = new File(path+"/"+ mImageName);
		if(!mImage.exists()){//文件不存在，从网上下载
			try {
				mImage.createNewFile();
				mClient.sendGetRequest(mImageUrl,new FQBinaryResponseHandle() {
					@Override
					public void onError(int code,Throwable error) {
						
					}
					@Override
					public void handleBinaryData(byte[] data) {
						
						
						FileOutputStream mFileOutputStream = null;
						try {
							 mFileOutputStream = new FileOutputStream(mImage);
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
						callback.doCallback(null);
					}
				});
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		
		
	}

}
