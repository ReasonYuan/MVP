package com.fq.http.async.uploadloop;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic2.RemoveRecordItemLogic;
import com.fq.http.async.ParamsWrapper.FQProcessInterface;
import com.fq.http.potocol.HttpRequestPotocol;
import com.fq.lib.HttpHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.fq.lib.record.RecordUploadNotify;
import com.fq.lib.tools.FQRemoteDebugTool;
import com.fq.lib.tools.UriConstants;

public class LoopCellHandle implements onHandlerCompleteListener {

	protected FQLoopQueue<LoopCellHandle> mQueue;
	
	protected float mProcess = 0;

	/**
	 * 是否正在处理中
	 */
	public boolean isHanlding;
	
	protected onHandlerCompleteListener completeListener;
	
	protected FQProcessInterface processListener;
	
	private HttpRequestPotocol mCurrentRequestHandle;
	
	public LoopCell cell;
	
	/**
	 * 上传文件的path
	 */
	private File path;
	
	/**
	 * 上传文件的photo
	 */
	private Photo pathPhoto;
	
	private Photo photo;
	
	private ArrayList<LoopCellHandle> subHandles;
	
	private LoopCellHandle parent;
	
	public void setProcessListemer(FQProcessInterface process){
		this.processListener = process;
	}
	
	public boolean mIsPause = false;
	
	private boolean mIsFinished = false;
	
	/**上传病历记录图片完成后，回调会获得这份病历记录的recordItemId*/
	private int mRecordItemId;
	
	public void resume(){
		if(mIsPause){
			mIsPause = false;
			isHanlding = false;
		}
	}
	
	public void cancle(){
		remove();
		if(mCurrentRequestHandle != null){
			mCurrentRequestHandle.cancel();
		}
		if(mIsFinished && mRecordItemId != 0){
			RemoveRecordItemLogic logic = new RemoveRecordItemLogic(null);
			logic.removeRecordItem(mRecordItemId);
		}
	}
	
	public void remove(){
		mQueue.remove(this);
		cell.deletFile();
	}
	
	
	public LoopCellHandle(LoopCell cell) {
		this.cell = cell;
		parent = null;
		subHandles = new ArrayList<LoopCellHandle>();
		isHanlding = false;
	}
	
	/**
	 * 添加到循环队列
	 * @param mQueue
	 */
	public void setQueue(FQLoopQueue<LoopCellHandle> mQueue) {
		this.mQueue = mQueue;
		if(cell.records.size() > 0){
			Iterator<Integer> iter = cell.records.keySet().iterator();
			while (iter.hasNext()) {
			    int key = iter.next();
			    ArrayList<ArrayList<Photo>> value = cell.records.get(key);
			    for (int i = 0; i < value.size(); i++) {
			    	ArrayList<Photo> array = value.get(i);
			    	for (int j = 0; j < array.size(); j++) {
			    		if(array.get(j).getImageId() == 0){
				    		LoopCell tmpCell = new LoopCell(cell.url, cell.params);
							LoopCellHandle handle = new LoopCellHandle(tmpCell);
							String filePath =array.get(j).getLocalPath();
							String fileName = filePath.substring(0,filePath.lastIndexOf('/'));
							handle.path = new File(filePath);
							handle.pathPhoto = array.get(j);
							handle.setOnCompleteListener(this);
							handle.parent = this;
							subHandles.add(handle);
				    	}
					}
				}
			}
		}
		cell.save();
	}

	/**
	 * begin handle event
	 */
	public void onHandle(){
		if(subHandles.size() != 0){
			for (int i = 0; i < subHandles.size(); i++) {
				LoopCellHandle handle = subHandles.get(i);
				if(!handle.isHanlding){
					handle.isHanlding = true;
					handle.onHandle();
					return;
				}
			}
		}else {
			if(path != null){
				final long  currnetFileSize  =  path.length();
				if(parent != null){
					parent.cell.nextExceptLength = currnetFileSize + parent.cell.uploadedLength;
					parent.cell.lastLoadedLength = parent.cell.uploadedLength;
				}
				final File filePath = path;
				mCurrentRequestHandle = HttpHelper.upLoadImage(UriConstants.Conn.URL_PUB+"/pub/upload_images.do", path.getAbsolutePath(),true,new HalcyonHttpResponseHandle() {
					
					@Override
					public void onError(int code, Throwable e) {
						if(parent != null && parent.cell instanceof LoopUpLoadCell){
//							((LoopUpLoadCell)parent.cell).onUpLoadError(pathPhoto);
						}
						if(parent != null){
							parent.cell.uploadedLength = parent.cell.lastLoadedLength;
						}
						if(parent != null) {
//							parent.mIsPause = true;
							parent.isHanlding = false;
						}
						isHanlding = false;
						FQRemoteDebugTool.log("上传" + filePath.getAbsolutePath() + "失败，code: " + code, e);
					}
					
					@Override
					public void handle(int responseCode, String msg, int type, Object results) {
						if(responseCode == 0 && type == 1){
							//photo = EntityUtil.FromJson(results.toString(), Photo.class);
							photo = new Photo();
							photo.setAtttributeByjson((JSONObject)results);
							photo.setLocalPath(LoopCellHandle.this.path.getAbsolutePath());
							String filePath = LoopCellHandle.this.path.getAbsolutePath();
							String parentPath = filePath.substring(0, filePath.lastIndexOf('/')+1);
							
							/*if (parentPath.equals(FileSystem.getInstance().getImgTempPath())) {
								File file = new File(filePath);
								File imageCachePath = new File(FileSystem.getInstance().getImgCachePath());
								if(!imageCachePath.exists())imageCachePath.mkdirs();
								File newFile = new File(FileSystem.getInstance().getImgCachePath() + photo.getImage_id());
//								file.renameTo(newFile);
								CreateRecordUILogic.updateLocalPhotoPath(filePath, newFile.getPath());
							}*/
							
							//TODO==YY==图片上传后，复制过去，并删除dcim下的,故注释上方代码
							//TODO==图片拍完后就放在DP目录下，当一张图片上传完时就改变这张图片的名字为id
							if (parentPath.contains(FileSystem.RECORD_FOLDER)) {
								File imageCachePath = new File(FileSystem.getInstance().getRecordImgPath());
								if(!imageCachePath.exists())imageCachePath.mkdirs();
								File oldFile = new File(filePath);
								if(oldFile.exists()){
									String newPath = FileSystem.getInstance().getRecordImgPath() + photo.getImageId()+FileSystem.RED_IMG_FT;
									File newName = new File(newPath);
									oldFile.renameTo(newName);
									
									//通知病历记录下的这张图片，更改名字。
									RecordUploadNotify.getInstance().changePhotoPath(filePath, newPath,photo.getImageId());
									//通知UI层，让系统重新扫描病历文件夹的图片
									if(Platform.getInstance() != null)Platform.getInstance().scanFile(filePath, newPath);
								}
							}
//							if (parentPath.contains("DCIM")) {
//								File imageCachePath = new File(FileSystem.getInstance().getRecordImgPath());
//								if(!imageCachePath.exists())imageCachePath.mkdirs();
//								
//								String newPath = FileSystem.getInstance().getRecordImgPath() + photo.getImageId();
//								FileHelper.copyFile(filePath, newPath);
//							}
							pathPhoto.setImageId(photo.getImageId());
							pathPhoto.setImagePath(photo.getImagePath());
							if(parent != null && parent.cell instanceof LoopUpLoadCell){
								((LoopUpLoadCell)parent.cell).onUpLoadSuccess(pathPhoto);
							}
							if(completeListener != null){
								completeListener.onHandlerComplete(LoopCellHandle.this,type,results);
							}
						} else {
							FQRemoteDebugTool.log(String.format("public void handle(int responseCode, String msg, int type, Object results) error response => responseCode = %d, type = %d", responseCode, type));
						}
						isHanlding = false;
					}
				},new FQProcessInterface() {
					@Override
					public void setProcess(float process) {
						if(parent!= null ){
							long tmp = parent.cell.uploadedLength;
							parent.cell.uploadedLength += (long) (currnetFileSize*process);
							parent.mProcess = parent.cell.uploadedLength/(float)parent.cell.allFileLength;
							if(parent.processListener != null){
								parent.processListener.setProcess(parent.mProcess);
							}
							parent.cell.uploadedLength = tmp;
							if(process == 1){
								parent.cell.uploadedLength = parent.cell.nextExceptLength;
							}
						}
					}
				});
			}else {
				if(cell instanceof LoopUpLoadCell){
					((LoopUpLoadCell)cell).resetParams();
				}
				mCurrentRequestHandle = HttpHelper.sendPostRequest(cell.url, cell.params,new HalcyonHttpResponseHandle() {
					
					@Override
					public void onError(int code, Throwable e) {
						isHanlding = false;
						if(parent != null) parent.isHanlding = false;
					}
					
					@Override
					public void handle(int responseCode, String msg, int type, Object results) {
						mIsFinished = true;
						if(responseCode == 0 && type == 1){
//							int docpatientId = ((JSONObject)results).optInt("doctor_patient_id");
						}
						if (responseCode == 0 && cell.url.equals(UriConstants.Conn.URL_PUB+"/record/item/create.do")) {
							JSONObject json = (JSONObject) results;
							JSONArray array = json.optJSONArray("records");
							JSONObject record = array.optJSONObject(0);
							if(record != null){
								JSONArray ids = record.optJSONArray("record_ids");
								if(ids != null){
									JSONObject item = ids.optJSONObject(0);
									mRecordItemId = item.optInt("recordId",0);
								}
							}
						}
						
						mQueue.remove(LoopCellHandle.this);
						cell.deletFile();
						if(completeListener != null){
							completeListener.onHandlerComplete(LoopCellHandle.this,type,results);
						}
						isHanlding = false;
					}
				});
			}
		}
	};
	
	public onHandlerCompleteListener getCompleteListener() {
		return completeListener;
	}

	public void setOnCompleteListener(onHandlerCompleteListener completeListener) {
		this.completeListener = completeListener;
	}

	@Override
	public void onHandlerComplete(LoopCellHandle cellHanle,int type, Object results) {
		subHandles.remove(cellHanle);
		Iterator<Integer> iter = cell.records.keySet().iterator();
		while (iter.hasNext()) {
		    int key = iter.next();
		    ArrayList<ArrayList<Photo>> value = cell.records.get(key);
		    for (int i = 0; i < value.size(); i++) {
		    	ArrayList<Photo> array = value.get(i);
		    	for (int j = 0; j < array.size(); j++) {
		    		Photo p = array.get(j);
			    	if(p.getLocalPath().equals(cellHanle.photo.getLocalPath())){
			    		array.remove(p);
			    		array.add(cellHanle.photo);
			    	}
				}
			}
		}
//		cell.params.pathParamArray.remove(cellHanle.path);
		cell.save();
		isHanlding = false;
	}

	public double getProcess() {
		return mProcess;
	}
}
