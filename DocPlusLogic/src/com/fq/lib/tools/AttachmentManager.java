package com.fq.lib.tools;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.entity.practice.ModifyObject;
import com.fq.halcyon.entity.practice.UpLoadObject;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.FQHttpParams;
import com.fq.http.async.ParamsWrapper.FQUpLoadImageInterface;
import com.fq.lib.HttpHelper;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.google.j2objc.annotations.Weak;


/**
 * 记录附件的接口工具类
 */
public class AttachmentManager implements FQUpLoadImageInterface {
	
	public interface AddAttachmentLogicInterface{
		public void onUpLoadingError(int recordItemId,String imageName);
		public void onUpLoadingSuccess(int recordItemId,int imageId,String imageName);
		public void onModifyError(int recordItemId,int imageId);
		public void onModifySuccess(int recordItemId,int imageId);
		public void onCancleUpLoading(int recordItemId,String imageName);
		public void onCancleModifying(int recordItemId,int imageId);
		
		public void onRemoveError(int code,String msg,int recordItemId,int imageId);
		public void onRemoveSuccess(ArrayList<PhotoRecord> photos,int reocordItemId,int imageId);
		
	}
	
	public interface AddAttachmentUpLoadingInterface {
		public void upLoadProgress(float progress,String imageName, Object obj);
	}
	
	@Weak
	public AddAttachmentLogicInterface mInterface;
	
	@Weak   
	public AddAttachmentUpLoadingInterface mUpLoadInterface;
	 
	
	class AddAttachmentLogicHandle extends HalcyonHttpResponseHandle{
		
		@Override
		public void onError(int code, Throwable e) {
			ModifyObject tag = ((ModifyObject)mParams.getTag());
			String message = e.getMessage();
			if(message.contains("-999")) { 
				mInterface.onCancleModifying(tag.getRecordItemId(), tag.getImageId());
			}else{
				mInterface.onModifyError(tag.getRecordItemId(), tag.getImageId());
			}
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			ModifyObject tag = ((ModifyObject)mParams.getTag());
			if (responseCode == 0) {
				mInterface.onModifySuccess(tag.getRecordItemId(), tag.getImageId());
			}else{
				mInterface.onModifyError(tag.getRecordItemId(), tag.getImageId());
			}
		}
		
	}
	private AddAttachmentLogicHandle mHandle;
	
	private  AttachmentManager() {
		
	}
	private static HashMap<Integer, AttachmentManager> map = null;
	public static AttachmentManager getInstance(int recordItemId){
		if(map == null) {
			map = new HashMap<Integer, AttachmentManager>();
		}
		if(map.get(recordItemId) == null) {
			map.put(recordItemId, new AttachmentManager());
		}
		return map.get(recordItemId);
	}
		
	/**
	 * 上传图片附件到记录，分为两步：<br/>
	 * 1.上传图片到服务器（阿里云）；<br/>
	 * 2.通过得到的iamgeId,作为附件上传给记录。
	 */
	public void upLoading(final PhotoRecord pRecord,final int recordItemId,Object object){
		HttpHelper.upLoadImage(UriConstants.Conn.URL_PUB + "/pub/upload_images.do", pRecord, false ,new HalcyonHttpResponseHandle() {
			@Override
			public void onError(int code, Throwable e) {
				UpLoadObject tag = ((UpLoadObject)mParams.getTag());
				String message = e.getMessage();
				if(message.contains("-999")) {
					mInterface.onCancleUpLoading(tag.getRecordItemId(), tag.getImageName());
				}else{
					mInterface.onUpLoadingError(tag.getRecordItemId(), tag.getImageName());
				}
			}

			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
                UpLoadObject tag = ((UpLoadObject)mParams.getTag());
				try {
					if (responseCode == 0 && type == 1) {
						String oldPath =  pRecord.getLocalPath();
                        File oldFile = new File(oldPath);
                        pRecord.setAtttributeByjson((JSONObject)results);
                        pRecord.setLocalPath(path);
                        
						File imageCachePath = new File(FileSystem.getInstance().getRecordImgPath());
						if (!imageCachePath.exists())
							imageCachePath.mkdirs();
						if (oldFile.exists()) {
							String newPath = FileSystem.getInstance().getRecordImgPath() + pRecord.getImageId() + FileSystem.RED_IMG_FT;
							File newName = new File(newPath);
							oldFile.renameTo(newName);
						}
						
						mInterface.onUpLoadingSuccess(tag.getRecordItemId(), pRecord.getImageId(),tag.getImageName());
						uploadAttach(pRecord,recordItemId);
					}else{
						mInterface.onUpLoadingError(tag.getRecordItemId(), tag.getImageName());
					}
				} catch (Exception e) {
                    e.printStackTrace();
                    mInterface.onUpLoadingError(tag.getRecordItemId(), tag.getImageName());
				}
			}
		},this, object);
		map.remove(this);
		if(map.isEmpty()) {
		map = null;
		}
	}
	
	public void checkProgress(AddAttachmentUpLoadingInterface mIn){
		this.mUpLoadInterface = mIn;
	}
	
	public void clearCheckProgress(){
		this.mUpLoadInterface = null;
	}
	
	public void checkupLoading(AddAttachmentLogicInterface mIn){
		mInterface = mIn;
	}
	
	/**
	 * 通过imageId上传图片附件到记录
	 * @param imageId
	 */
	private void uploadAttach(PhotoRecord photo,int recordItemId){
		JSONArray jsonArr = new JSONArray();
		jsonArr.put(photo.getImageId());
		JSONObject json = JsonHelper.createUserIdJson();
		try {
			json.put("record_item_id", recordItemId);
			json.put("images_attachment",jsonArr);
		} catch (JSONException e) {
			e.printStackTrace();
			FQLog.i("构造上传记录附件图片iamgeId的参数失败");
		}
		String url = UriConstants.Conn.URL_PUB + "/record/item/add_attachment.do";
		ModifyObject obj = new ModifyObject(recordItemId, photo.getImageId());
		FQHttpParams param = new FQHttpParams(json);
		param.setTag(obj);
		param.setFilePath(photo.getPath());
		mHandle = new AddAttachmentLogicHandle();
		ApiSystem.getInstance().require(url, param, API_TYPE.DIRECT, mHandle);
	}
	
	/**
	 * 得到附件Map里的时间数组，并排序
	 * @param map
	 * @return
	 */
	public ArrayList<String> getDates(HashMap<String, Object> map){
		Iterator<String> itor = map.keySet().iterator();
		ArrayList<String> dates = new ArrayList<String>();
		while(itor.hasNext()){
			String key = itor.next();
			dates.add(key);
		}
		
		//按时间排序
		Collections.sort(dates, new StrDataComparator());
		return dates;
	}
	
	/**
	 * 获取附件所有的图片ids
	 */
	public ArrayList<PhotoRecord> getAllImageIds(HashMap<String, Object> map,HashMap<String, ArrayList<PhotoRecord>> tmpMap){
		ArrayList<PhotoRecord> imageIds = new ArrayList<PhotoRecord>();
		ArrayList<String> tittles = getDates(map);
		for (int i = 0; i < tittles.size(); i++) {
			String tittle = tittles.get(i);
			imageIds.addAll(tmpMap.get(tittle));
		}
		return imageIds;
	}
	
	
	public void removeAttachment(int recordItemId,final ArrayList<PhotoRecord> photos){
		JSONObject json = JsonHelper.createUserIdJson();
		
		try {
			json.put("record_item_id", recordItemId);
			JSONArray array = new JSONArray();
			for(int i = 0; i < photos.size(); i++){
				array.put(photos.get(i).getImageId());
			}
			json.put("images_attachment", array);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB + "/record/item/remove_attachment.do";
		ModifyObject obj = new ModifyObject(recordItemId, photos.get(0).getImageId());
		FQHttpParams param = new FQHttpParams(json);
		param.setTag(obj);
		
		ApiSystem.getInstance().require(url,param,API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			
			public void onError(int code, Throwable e) {
				ModifyObject tag = ((ModifyObject)mParams.getTag());
				mInterface.onRemoveError(code, Constants.Msg.NET_ERROR,tag.getRecordItemId(),tag.getImageId());
			}
			
			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				ModifyObject tag = ((ModifyObject)mParams.getTag());
				if(responseCode == 0){
					mInterface.onRemoveSuccess(photos,tag.getRecordItemId(),tag.getImageId());
				}else{
					mInterface.onRemoveError(responseCode, msg,tag.getRecordItemId(),tag.getImageId());
				}
			}
		});
	}
	
	@Override
	public void upLoadProgress(float progress, String imageName, Object obj) {
		if(this.mUpLoadInterface != null) {
			this.mUpLoadInterface.upLoadProgress(progress, imageName, obj);
		}
	}
	
}
