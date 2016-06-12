package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.http.async.ParamsWrapper.FQProcessInterface;
import com.fq.lib.HttpHelper;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class UpLoadChatImageManager implements FQProcessInterface {

	public static final String IMAGE_SEND_SUCCESS = "IMAGE_SEND_SUCCESS";
	public static final String IMAGE_SEND_FAILD = "IMAGE_SEND_FAILD";
	
	class UploadAble{
		public String path;
		public int messageIndex;
		public String customId;
		public int type;//1发送给群 还是2单人 因为发消息的api不一样
		public int toUserImageId;
		public String toUserName;
		public UploadAble(String path,int messageIndex,String customId,int type,int toUserImageId,String toUserName){
			this.path = path;
			this.messageIndex = messageIndex;
			this.customId = customId;
			this.type = type;
			this.toUserImageId = toUserImageId;
			this.toUserName = toUserName;
		}
	}
	 
	@Weak
	public UpLoadChatImageManagerCallBack callback;

	private static HashMap<String, UpLoadChatImageManager> managerMap = null;
	private ArrayList<UploadAble> imageListMap = new ArrayList<UploadAble>();
	private UploadAble currnetUpload;
	public static UpLoadChatImageManager getInstance(String customId) {
		if (managerMap == null)
			managerMap = new HashMap<String, UpLoadChatImageManager>();
		if (managerMap.get(customId) == null) {
			managerMap.put(customId, new UpLoadChatImageManager());
		}
		return managerMap.get(customId);
	}

	/**
	 * 上传图片
	 * 
	 * @param path
	 *            图片路径
	 * @param messageIndex
	 *            该条消息对应的消息列表的位置
	 */
	public void upLoadImage(String path, int messageIndex,UpLoadChatImageManagerCallBack callback,String customId,int type,int toUserImageId,String toUserName) {
		imageListMap.add(new UploadAble(path, messageIndex,customId,type,toUserImageId,toUserName));
		check(callback);
	}

	/**
	 * 检查图片是否上传完成
	 */
	public void check(final UpLoadChatImageManagerCallBack mCallback) {
		this.callback =  mCallback;
		if(currnetUpload == null && !imageListMap.isEmpty()){
			currnetUpload = imageListMap.remove(0);
			HttpHelper.upLoadImage(UriConstants.Conn.URL_PUB + "/pub/upload_images.do", currnetUpload.path, false,new HalcyonHttpResponseHandle() {
				
				@Override
				public void onError(int code, Throwable e) {
					
					JSONObject info = new JSONObject();
					try {
                        if(currnetUpload != null) {
                            info.put("messageIndex", currnetUpload.messageIndex);
                            info.put("customId", currnetUpload.customId);
                            info.put("type", currnetUpload.type);
                        }
                    } catch (JSONException e1) {
						e1.printStackTrace();
					}
					Platform.getInstance().sendNotification(IMAGE_SEND_FAILD, info.toString());
                    currnetUpload = null;
//					if(callback != null) callback.onUpLoadChatImageFailed(code,e.getLocalizedMessage(),currnetUpload.messageIndex);
				}
				
				@Override
				public void handle(int responseCode, String msg, int type, Object results) {
					if(responseCode ==0 && type == 1){
						JSONObject json = (JSONObject)results;
						int imageId = json.optInt("image_id");
						if(imageId == 0){
							imageId = json.optInt("id");
						}
						JSONObject info = new JSONObject();
						try {
							info.put("imageId", imageId);
							info.put("messageIndex", currnetUpload.messageIndex);
							info.put("customId", currnetUpload.customId);
							info.put("type", currnetUpload.type);
							info.put("toUserImageId", currnetUpload.toUserImageId);
							info.put("toUserName", currnetUpload.toUserName);
						} catch (JSONException e) {
							e.printStackTrace();
						}
						Platform.getInstance().sendNotification(IMAGE_SEND_SUCCESS, info.toString());
//						if(callback != null) callback.onUpLoadChatImageSuccess(imageId, currnetUpload.messageIndex);
					}else{
						onError(0, new Exception("发送图片失败"));
					}
					currnetUpload = null;
					UpLoadChatImageManager.this.check(callback);
				}
			}, UpLoadChatImageManager.this);
		}
		
			
		
		if (managerMap != null) {
			if (imageListMap.isEmpty()) {
				managerMap.remove(this);
			}
			if (managerMap.isEmpty()) {
				managerMap = null;
			}
		}
	}

	/**
	 * 上传图片的回调接口
	 * 
	 * @author niko
	 * 
	 */
	public interface UpLoadChatImageManagerCallBack {
		public void onUpLoadChatImageSuccess(int imageId,int messageIndex);

		public void onUpLoadChatImageFailed(int errorCode, String msg,int messageIndex);

		public void onProcess(float process,int messageIndex);
	}

	@Override
	public void setProcess(float process) {
		if(callback != null) callback.onProcess(process,currnetUpload.messageIndex);
		
	}
}
