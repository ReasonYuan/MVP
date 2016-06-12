
package com.fq.halcyon.practice;

import java.io.File;
import java.util.ArrayList;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.FileHelper;
import com.fq.lib.HttpHelper;
import com.fq.lib.callback.ICallback;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.fq.lib.platform.Platform.onNetworkChangeListener;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 拍照的图片管理
 * 
 * @author liaomin
 * 
 */
public class PhotosManager implements onNetworkChangeListener {

	private static PhotosManager mInstance;
	
	public static String KEY_UPLOAD_NO_WIFI = "UPDATENOWIFI";

	private ArrayList<ArrayList<PhotoRecord>> mPhotoRecords;

	public boolean isGetStatus = false;
	
	@Weak
	public ICallback onStatueChangeCallback;
	
	private boolean isUploadPhoto = false;

	private PhotosManager() {
		mInstance = this;
		Platform.getInstance().addOnNetworkChangeListener(this);
		mPhotoRecords = new ArrayList<ArrayList<PhotoRecord>>();
		String localPath = getLocalFilePath();
		String localString = FileHelper.readString(localPath, true);
		if (localString != null && !localString.equals("")) {
			try {
				JSONArray photos = new JSONArray(localString);
				for (int i = 0; i < photos.length(); i++) {
					ArrayList<PhotoRecord> gArrayList = new ArrayList<PhotoRecord>();
					JSONArray group = photos.optJSONArray(i);
					for (int j = 0; j < group.length(); j++) {
						PhotoRecord record = new PhotoRecord();
						record.setAtttributeByjson(group.optJSONObject(j));
						gArrayList.add(record);
					}
					mPhotoRecords.add(gArrayList);
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		checkLoading();
		getStatus(null);
	}
	
	public static  void DestoryInstance(){
		mInstance = null;
	}

	public static PhotosManager getInstance() {
		if (mInstance == null) {
			mInstance = new PhotosManager();
		}
		return mInstance;
	}

	public int groupCount() {
		return mPhotoRecords.size();
	}

	/**
	 * @return 保存到本地的路径
	 */
	private String getLocalFilePath() {
        int user_id = Constants.getUser().getUserId();
		return FileSystem.getInstance().getUserCachePath() + "PhotosManager";
	}

	/**
	 * 转化成json并保存到本地
	 */
	private void save() {
		JSONArray potos = new JSONArray();
		for (int i = 0; i < mPhotoRecords.size(); i++) {
			JSONArray groupArray = new JSONArray();
			ArrayList<PhotoRecord> group = mPhotoRecords.get(i);
			for (int j = 0; j < group.size(); j++) {
				groupArray.put(group.get(j).getJson());
			}
			potos.put(groupArray);
		}
		String json = potos.toString();
		FileHelper.saveFile(json, getLocalFilePath(), true);
	}

	/**
	 * /* 照片组合并
	 * 
	 * @param desIndex
	 *            合并到的照片组
	 * @param srcIndexs
	 *            被合并的照片组
	 * @return 是否合并成功
	 */
	public boolean merger(int desIndex, int... srcIndexs) {
		do {
			boolean wrongArgs = false;
			for (int i = 0; i < srcIndexs.length; i++) { // 判断是否越界
				int index = srcIndexs[i];
				if (index < 0 || index >= mPhotoRecords.size()) {
					wrongArgs = true;
					break;
				}
			}
			if (wrongArgs)
				break;
			if (desIndex < mPhotoRecords.size()) { // 判断是否越界
				ArrayList<ArrayList<PhotoRecord>> tmpArrayList = new ArrayList<ArrayList<PhotoRecord>>();
				ArrayList<PhotoRecord> des = mPhotoRecords.get(desIndex);
				for (int i = 0; i < srcIndexs.length; i++) {
					ArrayList<PhotoRecord> src = mPhotoRecords.get(srcIndexs[i]);
					tmpArrayList.add(src);
					des.addAll(src);
				}
				mPhotoRecords.removeAll(tmpArrayList);
				save();
				return true;
			}
		} while (false);
		System.out.println("array index out of bounds!数组下标越界");
		return false;
	}

	public void addPhoto(String localPath) {
		PhotoRecord pRecord = new PhotoRecord(localPath);
		ArrayList<PhotoRecord> records = new ArrayList<PhotoRecord>();
		records.add(pRecord);
		mPhotoRecords.add(records);
		save();
		checkLoading();
	}
	
	public void addPhoto(PhotoRecord item) {
		ArrayList<PhotoRecord> records = new ArrayList<PhotoRecord>();
		records.add(item);
		mPhotoRecords.add(records);
		for (int i = 0; i < mPhotoRecords.size(); ) {
			ArrayList<PhotoRecord> tmp = mPhotoRecords.get(i);
			if(tmp.size() == 0) {
				mPhotoRecords.remove(tmp);
				continue;
			}
			i++;
		}
		save();
	}

	public boolean haseUpLoadingPicture() {
		for (int i = 0; i < mPhotoRecords.size(); i++) {
			ArrayList<PhotoRecord> group = mPhotoRecords.get(i);
			for (int j = 0; j < group.size(); j++) {
				PhotoRecord record = group.get(j);
				if(record.getImageId() == 0){
					return true;
				}
			}
		}
		return false;
	}
	
	public void checkLoading() {
		if(!canUpload() || isUploadPhoto) return;
		for (int i = 0; i < mPhotoRecords.size(); i++) {
			ArrayList<PhotoRecord> group = mPhotoRecords.get(i);
			for (int j = 0; j < group.size(); j++) {
				final PhotoRecord record = group.get(j);
				if (record.getImageId() == 0 && record.isLoading == false && record.getLocalPath()!=null && !record.getLocalPath().equals("")) {// 需要上传
					isUploadPhoto = true;
					record.isLoading = true;
					if(onStatueChangeCallback != null) onStatueChangeCallback.doCallback(true);
					HttpHelper.upLoadImage(UriConstants.Conn.URL_PUB + "/pub/upload_images.do", record.getLocalPath(), true,new HalcyonHttpResponseHandle() {

						@Override
						public void onError(int code, Throwable e) {
							isUploadPhoto = false;
							record.isLoading = false;
							checkLoading();
						}

						@Override
						public void handle(int responseCode, String msg, int type, Object results) {
							isUploadPhoto = false;
							record.isLoading = false;
							try {
								if (responseCode == 0 && type == 1) {
									String oldPath =  record.getLocalPath();
                                    File oldFile = new File(oldPath);
									record.setAtttributeByjson((JSONObject) results);
									File imageCachePath = new File(FileSystem.getInstance().getRecordImgPath());
									if (!imageCachePath.exists())
										imageCachePath.mkdirs();
									if (oldFile.exists()) {
										String newPath = FileSystem.getInstance().getRecordImgPath() + record.getImageId() + FileSystem.RED_IMG_FT;
										File newName = new File(newPath);
										oldFile.renameTo(newName);
										save();
										if(onStatueChangeCallback != null) onStatueChangeCallback.doCallback(true);
									}
								}
							} catch (Exception e) {
                                e.printStackTrace();
							}
							checkLoading();
						}
					});
					return;
				}
			}
		}
	}

	/**
	 * @return 所有的图片是否已经识别
	 */
	public boolean isAllPhotoComplete() {
		for (int i = 0; i < mPhotoRecords.size(); i++) {
			ArrayList<PhotoRecord> group = mPhotoRecords.get(i);
			for (int j = 0; j < group.size(); j++) {
				PhotoRecord record = group.get(j);
				if(record.getState() != PhotoRecord.OCR_STATE_COMPLETE) return false;
			}
		}
		return true;
	}
	
	public void moveTo(int oldIndex, int newIndex) {
		PhotosManager.moveTo(mPhotoRecords, oldIndex, newIndex);
	}
	
	public void swap(int oldIndex, int newIndex) {
		PhotosManager.swap(mPhotoRecords, oldIndex, newIndex);
	}
	
	
	public void delete(int ...ary){
		ArrayList<ArrayList<PhotoRecord>> tmp = new ArrayList<ArrayList<PhotoRecord>>();
		for (int i = 0; i < ary.length; i++) {
			ArrayList<PhotoRecord> removeArray =  mPhotoRecords.get(ary[i]);
			tmp.add(removeArray);
			for (PhotoRecord photoRecord : removeArray) {
				photoRecord.deleteCache();
			}
		}
		mPhotoRecords.removeAll(tmp);
		save();
	}
    
    public void removeAll(){
    	ArrayList<ArrayList<PhotoRecord>> tmp = new ArrayList<ArrayList<PhotoRecord>>();
		for (int i = 0; i < mPhotoRecords.size(); i++) {
			ArrayList<PhotoRecord> removeArray =  mPhotoRecords.get(i);
			tmp.add(removeArray);
			for (PhotoRecord photoRecord : removeArray) {
				photoRecord.deleteCache();
			}
		}
		mPhotoRecords.removeAll(tmp);
		save();
    }
	
	public static void moveTo(ArrayList array, int oldIndex, int newIndex) {
		if (oldIndex < 0 && oldIndex >= array.size()) {
			return;
		}
		if (newIndex < 0 && newIndex >= array.size()) {
			return;
		}
		Object old = array.get(oldIndex);
		array.remove(oldIndex);
		array.add(newIndex, old);
	}
	
	public static void swap(ArrayList array, int index1, int index2) {
		if (index1 < 0 && index1 >= array.size()) {
			return;
		}
		if (index2 < 0 && index2 >= array.size()) {
			return;
		}
		Object data1 = array.get(index1);
		Object data2 = array.get(index2);
		array.set(index2, data1);
		array.set(index1, data2);
	}

	public ArrayList<PhotoRecord> getGroup(int index) {
		if (index >= 0 && index < mPhotoRecords.size()) {
			return mPhotoRecords.get(index);
		}
		return null;
	}

	@Override
	protected void finalize() throws Throwable {
		System.out.println("Destory:  PhotosManager");
		save();
		super.finalize();
	}

	/**
	 * 
	 * @param callback
	 *            成功获取状态后的回调
	 */
	public void getStatus(final ICallback callback) {
		JSONObject pJsonObject = new JSONObject();
		JSONArray ids = new JSONArray();

		for (int i = 0; i < mPhotoRecords.size(); i++) {
			ArrayList<PhotoRecord> group = mPhotoRecords.get(i);
			for (int j = 0; j < group.size(); j++) {
				PhotoRecord photo = group.get(j);
				if (photo.getImageId() != 0)
					ids.put(photo.getImageId());
			}
		}

		try {
			pJsonObject.put("image_ids", ids);
			// pJsonObject.put("user_id", Constants.getUser().getUserId());
			System.out.println(pJsonObject);
		} catch (JSONException e1) {
			e1.printStackTrace();
		}
		if (ids.length() > 0) {
			ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/image/get_status_list.do", new FQHttpParams(pJsonObject), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

				@Override
				public void onError(int code, Throwable e) {

				}

				@Override
				public void handle(int responseCode, String msg, int type, Object results) {
					if (responseCode == 0 && type == 2) {
						JSONArray array = (JSONArray) results;
						for (int o = 0; o < array.length(); o++) {
							JSONObject attr = array.optJSONObject(o);
							int id = attr.optInt("id");
							if (id != 0) {
								for (int i = 0; i < mPhotoRecords.size(); i++) {
									ArrayList<PhotoRecord> group = mPhotoRecords.get(i);
									for (int j = 0; j < group.size(); j++) {
										PhotoRecord photo = group.get(j);
										if (photo.getImageId() == id) {
											photo.setState(attr.optInt("status"));
											photo.setProcessTime(attr.optLong("process_time"));
											break;
										}
									}
								}
							}

						}
					}
					isGetStatus = true;
					if (callback != null)
						callback.doCallback(true);
				}
			});
		}
	}

	public void getRecordText(PhotoRecord record, final ICallback callback) {
		if (callback == null)
			return;
		JSONObject p = new JSONObject();
		if (record.getImageId() == 0) {
			callback.doCallback("");
			return;
		}
		try {
			p.put("image_id",record.getImageId());
		} catch (JSONException e) {
			e.printStackTrace();
		}
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/image/view_txt.do", new FQHttpParams(p),API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				callback.doCallback(e.getMessage());
			}

			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if (responseCode == 0 && type == 1) {
					JSONObject json = (JSONObject) results;
					callback.doCallback(json.opt("image_txt"));
				}
			}
		});
	}
	
	public ArrayList<PhotoRecord> getAllPhotos(){
		ArrayList<PhotoRecord> all = new ArrayList<PhotoRecord>();
		for (int i = 0; i < mPhotoRecords.size(); i++) {
			ArrayList<PhotoRecord> group = mPhotoRecords.get(i);
			for (int j = 0; j < group.size(); j++) {
				PhotoRecord photo = group.get(j);
				all.add(photo);
			}
		}
	
		return all;
	}
	
	public ArrayList<ArrayList<PhotoRecord>> getSelectList(int...ary){
		ArrayList<ArrayList<PhotoRecord>> array = new ArrayList<ArrayList<PhotoRecord>>();
		for (int i = 0; i < ary.length; i++) {
			array.add(mPhotoRecords.get(ary[i]));
		}
		return array;
	}
	
	private boolean canUpload(){
		int state = Platform.getInstance().getNetworkState();
		if(Platform.getInstance().getNetworkState() == Platform.NETWORKSATE_WIFI){//wifi true
			return true;
		}
		if(state == Platform.NETWORKSATE_NO){ //没网 false
			return false; 
		}
		if(Constants.getUser().isOnlyWifi()){ //其他网络。开启流量提醒
			return false;
		}
		return true;
	}

	@Override
	public void onNetworkChanged(int state) {
		checkLoading();
	}
}
