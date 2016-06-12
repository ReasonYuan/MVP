package com.fq.lib.record;

import java.util.ArrayList;
import java.util.List;

import com.fq.halcyon.entity.PhotoRecord;

/**
 * 因为上传完病历图片后需要将本地图片的名字改为网络上图片的Id<br/>
 * 而浏览病历界面的图片却仍然指向本地的地址（改之前的），从而导致无法查看图片<br/> 
 * 此通知类便用于在图片上传完成改名字后，通知本地的这个病历记录，将其里面的路径改为新的。
 * @author reason
 * @version 2015-04-08 v3.02
 */
public class RecordUploadNotify {
	
	private static RecordUploadNotify mInstance;
	
	/**正在上传的病历记录的图片的集合*/
	private ArrayList<PhotoRecord> mPhotos;
	
	private RecordUploadNotify(){}
	
	/**
	 * 初始化数据，只有进入浏览病历界面时调用（一次）
	 */
	public static void inistance(){
		if(mInstance == null){
			mInstance = new RecordUploadNotify();
			mInstance.mPhotos = new ArrayList<PhotoRecord>();
		}
	}
	
	public static RecordUploadNotify getInstance(){
		return mInstance;
	}
	
	/**
	 * 清空数据
	 */
	public void clear(){
		mInstance.mPhotos = null;
		mInstance = null;
	}
	
	public void addItem(PhotoRecord photo){
		mPhotos.add(photo);
	}
	
	/**
	 * 添加正在上传的图片用于以后的通知监听<br/>
	 * 进入浏览病历界面时和拍照返回时会调用
	 * @param photos
	 */
	public void addItems(List<PhotoRecord> photos){
		mPhotos.addAll(photos);
	}
	
	public void changePhotoPath(String oldPath,String newPath,int imgId){
		if(mPhotos == null)return;
		synchronized (mPhotos) {
			for(PhotoRecord photo:mPhotos){
				if(oldPath.equals(photo.getPath())){
					photo.setLocalPath(newPath);
					photo.setImageId(imgId);
					mPhotos.remove(photo);
					break;
				}
			}
		}
	}
}
