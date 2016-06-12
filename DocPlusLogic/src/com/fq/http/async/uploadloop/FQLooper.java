package com.fq.http.async.uploadloop;

import java.io.File;
import java.util.ArrayList;

import android.os.Handler;

import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.async.uploadloop.LoopCell.CELL_TYPE;
import com.fq.lib.tools.Constants;



public class FQLooper {

	protected FQLoopQueue<LoopCellHandle> mQueue;
	
	private int mInterval;
	
	private Runnable mWorker;
	
	private Handler mHandler;
	
	private boolean mIsPause;

	public FQLooper() {
		mHandler = new Handler();
		mQueue = new FQLoopQueue<LoopCellHandle>();
		mInterval = 1000;
		mIsPause = false;
		mWorker = new Runnable() {
			
			@Override
			public void run() {
				if(!mIsPause){
					if (!mQueue.isEmpty()) {
						try {
							LoopCellHandle handle = mQueue.getNext();
							if(!handle.isHanlding){
								handle.isHanlding = true;
								handle.onHandle();
							}
						} catch (Exception e) {
							e.printStackTrace();
						}
					}
					mHandler.postDelayed(mWorker, mInterval);
				}
			}
		};
	}
	
	/**
	 * set interval for between two events
	 * @param interval
	 */
	public FQLooper(int interval) {
		this();
		mInterval = interval;
	}

	public synchronized void push(LoopCellHandle  hanlde){
		if(hanlde == null || hanlde.cell == null) return;
		if(mQueue.getAll().contains(hanlde))return;
		for (int i = 0; i < mQueue.getAll().size(); i++) {
			LoopCellHandle handler = mQueue.getAll().get(i);
			if(handler.cell == null || handler.cell.key.equals(hanlde.cell.key)){
				mQueue.remove(handler);
				handler.cell.deletFile();
				break;
			}
		}
		hanlde.setQueue(mQueue);
		mQueue.add(hanlde);
		start();
	}
	
	public synchronized void push(LoopCell cell){
		if(cell == null) return;
		LoopCellHandle handle = new LoopCellHandle(cell);
		push(handle);
	}
	
	public synchronized void stop(){
		mIsPause = true;
//		if(mLooperThread != null && mLooperThread.isAlive()){
//			try {
//				mLooperThread.join();
//			} catch (Exception e) {
//			}
//		}
//		mLooperThread = null;
//		if(mQueue.size() != 0){
//			for (int i = 0; i < mQueue.getAll().size(); i++) {
//				LoopCellHandle handle = mQueue.getAll().get(i);
//				handle.cell.save();
//			}
//		}
//		mQueue.getAll().clear();
	}
	
	
	public synchronized void start(){
		if(Constants.getUser() == null || Constants.getUser().getUserId() == 0){
			return;
		}
		mIsPause = false;
		if(mHandler != null){
			File file = new File(FileSystem.getInstance().getUserLoopPath());
			if(file.exists()){
				File[] list = file.listFiles();
				for (int i = 0; i < list.length; i++) {
					File cellFile = list[i];
					LoopCell cell = LoopCell.load(cellFile.getAbsolutePath());
					LoopCellHandle handle = new LoopCellHandle(cell);
					if(handle.cell == null) {
						cellFile.delete();
						continue;
					}
					boolean contains = false;
					for (int j = 0; j < mQueue.getAll().size(); j++) {
						LoopCellHandle handler = mQueue.getAll().get(j);
						if(handler.cell.key.equals(handle.cell.key)){
							contains = true;
							break;
						}
					}
					if(!contains){
						handle.setQueue(mQueue);
						mQueue.add(handle);
					}
				}
			}
			mHandler.postDelayed(mWorker, mInterval);
		}
	}
	
	public ArrayList<LoopCellHandle> getAll(){
		return mQueue.getAll();
	}
	
	public int getUploadCount(){
		ArrayList<LoopCellHandle> all = mQueue.getAll();
		int count = 0;
		for (int i = 0; i < all.size(); i++) {
			LoopCellHandle handle = all.get(i);
			if(handle.cell != null && handle.cell.getType() == CELL_TYPE.CELL_UPLOAD){
				count ++;
			}
		}
		return count;
	}
	
	public int getUploadUserCount(){
		ArrayList<LoopCellHandle> all = mQueue.getAll();
		int count = 0;
		for (int i = 0; i < all.size(); i++) {
			LoopCellHandle handle = all.get(i);
			if(handle.cell != null && handle.cell.getType() == CELL_TYPE.CELL_OTHER){
				count ++;
			}
		}
		return count;
	}
	
	public ArrayList<LoopCellHandle> getUploadArray(){
		ArrayList<LoopCellHandle> all = mQueue.getAll();
		ArrayList<LoopCellHandle> uploadArray = new ArrayList<LoopCellHandle>();
		for (int i = 0; i < all.size(); i++) {
			LoopCellHandle handle = all.get(i);
			if(handle.cell != null && handle.cell.getType() == CELL_TYPE.CELL_UPLOAD){
				uploadArray.add(all.get(i));
			}
		}
		return uploadArray;
	}
	
	public ArrayList<LoopCellHandle> getUploadCells(int recordId){
		ArrayList<LoopCellHandle> all = mQueue.getAll();
		ArrayList<LoopCellHandle> uploadArray = new ArrayList<LoopCellHandle>();
		for (int i = 0; i < all.size(); i++) {
			LoopCellHandle handle = all.get(i);
			if(handle.cell != null && handle.cell instanceof LoopUpLoadCell){
				uploadArray.add(all.get(i));
			}
		}
		return uploadArray;
	}
	
	public void cancelUploadCell(int recordId,String uuid){
		ArrayList<LoopCellHandle> all = getUploadCells(recordId);
		for (int i = 0; i < all.size(); i++) {
			LoopCellHandle handel = all.get(i);
			if(all.get(i) != null && handel.cell != null && handel.cell instanceof LoopUpLoadCell){
				LoopUpLoadCell cell = (LoopUpLoadCell) handel.cell;
				if(recordId == cell.getRecordId() && cell.uuid.equals(uuid)){
					handel.cancle();
				}
			}
		}
	}
	
}
