package com.fq.halcyon.entity;

import java.io.File;

import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;

/**
 * 图片实例，包含图片的一些基本信息
 * @author reason
 *
 */
public class Photo extends HalcyonEntity{

	private static final long serialVersionUID = 1L;

	/**
	 * 图片的id<br>
	 * 可以根据id得到图片的本地路径:cache/images/img_cache/id
	 */
	protected int imageId = 0;
	
	/**
	 * 图片的网络路径（即imagePath）
	 */
	protected String imagePath;

	/**
	 * 图像资料的类型
	 */
	protected String localPath;
	
	public Photo(){};
	
	public Photo(int id,String uri){
		this.imageId = id;
		this.imagePath = uri;
	}
	
	public int getImageId() {
		return imageId;
	}

	public void setImageId(int image_id) {
		this.imageId = image_id;
	}

	/**
	 * @return 图片的网络路径（同imagePath）
	 */
	public String getImagePath() {
		return imagePath;
	}

	/**
	 * 设置图片的网络路径（同imagePath）
	 */
	public void setImagePath(String uri) {
		this.imagePath = uri;
	}

	/**
	 * 通过id计算得到图片的本地路径
	 * @return 图片的本地路径
	 */
	public String getLocalPath() {
		String path = localPath;
		if (fileExists(path)) {
			return path;
		} else {
			if(imageId != 0){
				path = FileSystem.getInstance().getRecordImgPath() + imageId +FileSystem.RED_IMG_FT;
				if(fileExists(path)) return path;
			} 
			if(localPath != null && !localPath.equals("") && Platform.getInstance().getTargetPlatform() == Platform.PLANTFORM_IOS){
				path = FileSystem.getInstance().getRecordCachePath()+localPath;
				if(fileExists(path)) return path;
			}
		}
		return null;
	}
	
	private boolean	 fileExists(String filePath) {
		File localFile = (filePath == null ? null : new File(filePath));
		if(localFile != null && localFile.isDirectory()) return false;
		if (localFile != null && localFile.exists()) {
			return true;
		} 
		return false;
	}
	
	/**
	 * 得到图判断的路径
	 * @return
	 */
	public String getPath(){
		return localPath;
	}

	public void setLocalPath(String localPath) {
		this.localPath = localPath;
	}
	
	public boolean deleteCache() {
		String path = getLocalPath();
		if(fileExists(path)){
			File file = new File(path);
			return file.delete();
		}
		return false;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json){
		super.setAtttributeByjson(json);
		this.imagePath = json.optString("uri");
		if(this.imagePath.equals("")){
			this.imagePath = json.optString("image_path");
		}
		this.imageId = json.optInt("image_id");
		if(this.imageId == 0){
			this.imageId = json.optInt("id");
		}
		this.localPath = json.optString("local_path");
	}
	
	@Override
	public JSONObject getJson(){
		JSONObject json = new JSONObject();
		try {
			if(imageId != 0)json.put("image_id", imageId);
			json.put("uri", imagePath);
			json.put("local_path", localPath);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return json;
	}
}
