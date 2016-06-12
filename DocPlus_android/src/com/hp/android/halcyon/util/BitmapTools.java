package com.hp.android.halcyon.util;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.widget.ImageView;

import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.http.potocol.FQBinaryResponseHandle;
import com.fq.lib.HttpHelper;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.MD5;

public class BitmapTools {
	
	
	public static void displayImage(final String url,final ImageView imageView,int res){
		if(imageView != null && !url.equals("")){
			Bitmap bitmap = null;
			if(bitmap != null){
				imageView.setImageBitmap(bitmap);
			}
			if(res != 0)imageView.setImageResource(res);
			imageView.setTag(url);
			getImage(url,new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					if(imageView.getTag() != null && imageView.getTag().equals(url)){
						imageView.setImageBitmap((Bitmap)obj);
					}
				}
			});
		}
	}
	
	private static String getLocalFilePath(String url){
		return FileSystem.getInstance().getImgTempPath() + "/" + MD5.Md5(url);
	}
	
	private static HashMap<String, ArrayList<ICallback>> mCurrnetDownUrls = new HashMap<String, ArrayList<ICallback>>();
	
	public static void getImage(final String url, ICallback callback) {
		if(url == null || url.equals("")) return;
		final File localFile = new File(getLocalFilePath(url));
		if (localFile.exists()) {
			ArrayList<ICallback> callbacks = new ArrayList<ICallback>();
			callbacks.add(callback);
			new DecodeBitmapTask(localFile.getAbsolutePath(), callbacks).execute();
		} else {
			File file  = new File(FileSystem.getInstance().getImgTempPath());
			if(!file.exists())file.mkdirs();
			ArrayList<ICallback> callbacks = mCurrnetDownUrls.get(url);
			if(callbacks == null){ 
				callbacks =  new ArrayList();
				mCurrnetDownUrls.put(url, callbacks);
				callbacks.add(callback);
			}else{
				callbacks.add(callback);
				return;
			}
			HttpHelper.sendGetRequest(url, new FQBinaryResponseHandle() {
				
				@Override
				public void onError(int code,Throwable e) {
					mCurrnetDownUrls.remove(url);
				}
				
				@Override
				public void handleBinaryData(byte[] data) {
					ArrayList<ICallback> callbacks = mCurrnetDownUrls.get(url);
					mCurrnetDownUrls.remove(url);
					FileOutputStream mFileOutputStream = null;
					try {
						 mFileOutputStream = new FileOutputStream(localFile);
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
					new DecodeBitmapTask(url, callbacks).execute();
				}
			});
		}
	}
}

class DecodeBitmapTask extends AsyncTask<Void, Void, Void> {

	private String mFilepath;

	private ArrayList<ICallback> mCallbacks;
	private Bitmap mBitmap;

	public DecodeBitmapTask(String path, ArrayList<ICallback> callbacks) {
		mFilepath = path;
		mCallbacks = callbacks;
	}

	@Override
	protected Void doInBackground(Void... params) {
		mBitmap = BitmapManager.decodeBitmap2Scale(mFilepath, 100);
		return null;
	}

	@Override
	protected void onPostExecute(Void result) {
		for (int i = 0; i < mCallbacks.size(); i++) {
			mCallbacks.get(i).doCallback(mBitmap);
		}
		mBitmap = null;
		super.onPostExecute(result);
	}
}
