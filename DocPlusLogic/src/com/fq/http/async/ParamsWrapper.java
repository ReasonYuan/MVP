package com.fq.http.async;

import java.util.Iterator;

import com.google.j2objc.annotations.Weak;
import com.loopj.android.http.RequestParams;

public class ParamsWrapper extends RequestParams {
	private static final long serialVersionUID = 1L;
	
	public Object tag;
	
	public String filePath;//图片路径用于标记handle cancel request
	
	public Object getTag() {
		return tag;
	}

	public void setTag(Object tag) {
		this.tag = tag;
	}

	public String getFilePath() {
		return filePath;
	}

	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}


	public static interface FQProcessInterface {
		/**
		 * @param process the process value between 0-1
		 */
		public void setProcess(float process);
	}

	@Weak
	private FQProcessInterface upLoadProcess;
	
	
	public static interface FQDownLoadImageInterface {
		public void downLoadProgress(float progress,int imageId,Object obj);
	}

	@Weak
	private FQDownLoadImageInterface downLoadProgress;
	
	
	public static interface FQUpLoadImageInterface {
		public void upLoadProgress(float progress,String imageName,Object obj);
	}
	
	@Weak
	private FQUpLoadImageInterface upLoadProgress;
	
	public FQUpLoadImageInterface getUpLoadProgress() {
		return upLoadProgress;
	}

	public void setUpLoadProgress(FQUpLoadImageInterface upLoadProgress) {
		this.upLoadProgress = upLoadProgress;
	}

	public FQDownLoadImageInterface getDownLoadProgress() {
		return downLoadProgress;
	}

	public void setDownLoadProgress(FQDownLoadImageInterface downLoadProgress) {
		this.downLoadProgress = downLoadProgress;
	}


	private int timeOutTime = 10000;

	public void setTimeoutTime(int timeOut) {
		this.timeOutTime = timeOut;
	}

	public int getTimeoutTime() {
//		if(Constants.DEBUG)return 30000;
		return this.timeOutTime;
	}

	public FQProcessInterface getUpLoadProcess() {
		return upLoadProcess;
	}

	public void setUpLoadProcess(FQProcessInterface upLoadProcess) {
		this.upLoadProcess = upLoadProcess;
	}

	public String getStringParams() {
		StringBuilder params = new StringBuilder();
		Iterator<String> iterator = urlParams.keySet().iterator();
		boolean first = true;
		while (iterator.hasNext()) {
			String key = iterator.next();
			if(first){
				params.append("?");
				first = false;
			}
			params.append(key+"="+urlParams.get(key)+"&");
		}
		return params.toString();
	}

	
	public boolean isJsonParams() {
		return false;
	}

}
