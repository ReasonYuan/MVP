package com.fq.http.async.uploadloop;

import java.io.File;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.FileHelper;
import com.fq.lib.platform.Platform;
import com.fq.lib.tools.MD5;
import com.loopj.android.http.RequestParams.FileWrapper;

public class LoopCell implements Serializable {
	
	public enum CELL_TYPE{
		
		/**
		 * 上传病例等
		 */
		CELL_UPLOAD,
		
		/**
		 * 下载病例等
		 */
		CELL_DOWNLOAD,
		
		/**
		 * 其他情况，比如数据同步 （默认）
		 */
		CELL_OTHER,
	}

	private CELL_TYPE mType;
	
	private static final long serialVersionUID = 1L;
	
	public String name;

	public String key;

	public String url;

	public FQHttpParams params;
	
	public long uploadedLength,nextExceptLength,lastLoadedLength;
	
	public long allFileLength;
	
	public int allFileCount = 0;
	
	public int uploadedFileCount = 0;
	
	public HashMap<Integer, ArrayList<ArrayList<Photo>>> records; 
	
	public void addPhotos(int type, ArrayList<Photo> photos){
		if(photos == null || photos.size() == 0) return;
		ArrayList<ArrayList<Photo>> photosArray =  records.get(type);
		if(photosArray == null){
			photosArray = new ArrayList<ArrayList<Photo>>();
			photosArray.add(photos);
			records.put(type, photosArray);
		}else {
			photosArray.add(photos);
		}
		for (int i = 0; i < photos.size(); i++) {
			File file = new File(photos.get(i).getLocalPath());
			allFileLength += file.length();
			key += file.getPath();
			allFileCount ++;
		}
		if(records.size() > 1){
			throw new RuntimeException("a cell  not support different type now!");
		}
		key = MD5.Md5(key);
	}
	
	public LoopCell(String url,FQHttpParams params) {
		mType = CELL_TYPE.CELL_OTHER;
		name = "";
		this.url = url;
		this.params = params;
		allFileLength = 0;
		String tmpKey = url;
		records = new HashMap<Integer, ArrayList<ArrayList<Photo>>>();
		if(params != null){
			tmpKey += params.getStringParams();
			if(!params.fileParams.isEmpty()){
				Iterator<String> iterator =  params.fileParams.keySet().iterator();
				while (iterator.hasNext()) {
					String key = iterator.next();
					FileWrapper fileWrapper = params.fileParams.get(key);
					File file = fileWrapper.file;
					if(file.exists()){
						allFileLength += file.length();
					}
					tmpKey += file.getPath();

				}
			}
		}
		key = MD5.Md5(tmpKey);
	}

	public void save(){
		if(Platform.getInstance().getTargetPlatform() == Platform.PLANTFORM_ANDROID){
			FileHelper.saveSerializableObject(this, FileSystem.getInstance().getUserLoopPath()+"/"+key);
		}else{
			
		}
	}
	
	public static LoopCell load(String path){
		Object data = FileHelper.loadSerializableObject(path);
		if(data != null && data instanceof LoopCell){
			return (LoopCell)data;
		}
		return null;
	}
	
	public void deletFile(){
		File file = new File(FileSystem.getInstance().getUserLoopPath()+"/"+key);
		if(file.exists())file.delete();
	}
	
	public void setType(CELL_TYPE type) {
		this.mType = type;
	}
	
	public CELL_TYPE getType() {
		return this.mType;
	}
}
