package com.hp.android.halcyon.util;

import java.io.File;
import java.util.ArrayList;

import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.widget.ImageView;

import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.callback.ICallback;

public class UIRecordImageTool {

	/**
	 * 浏览病历时的图片装载
	 * 
	 * @param uiThreadId
	 * @param images
	 * @param position
	 * @param iv
	 */
	public static void loadImage(final long uiThreadId, final ArrayList<Photo> images, final int position, final ImageView iv) {
		iv.setTag(images.get(position));
		ICallback setBitmapCallback = new ICallback() {
			@Override
			public void doCallback(Object obj) {
				Bitmap bitmap = (Bitmap) obj;
				// 由于用户不断拉动，可能iv已经重用，所以必须判断一下
				if (iv.getTag() == images.get(position)) {
					iv.setImageBitmap(bitmap);
				}

			}
		};
		String path = images.get(position).getLocalPath();
		Bitmap bitmap;
		File localFile = (path == null ? null : new File(path));
		if (localFile != null && localFile.exists()) {
			bitmap = BitmapCache.getInstance().getBitmapFromMemCache(path);
			if(bitmap != null){
				setBitmapCallback.doCallback(bitmap);
				bitmap = null;
			}else {
				new GetBitmapTask(path, setBitmapCallback).execute();
			}
		} else {
			path = FileSystem.getInstance().getRecordImgPath() + "/" + images.get(position).getImageId()+FileSystem.RED_IMG_FT;
			localFile = new File(path);
			if (localFile.exists()) {
				bitmap = BitmapCache.getInstance().getBitmapFromMemCache(path);
				if(bitmap != null){
					setBitmapCallback.doCallback(bitmap);
					bitmap = null;
				}else {
					new GetBitmapTask(path, setBitmapCallback).execute();
				}
			} else {
				Photo photo = new Photo();
				photo.setImageId(images.get(position).getImageId());
				photo.setImagePath(images.get(position).getImagePath());
				// 如果是第二次重复请求相同url且上次图片正在请求中，则底层不会调用上次callback，而是调用该次的callback
				ApiSystem.getInstance().getImage(photo, new ICallback() {
					@Override
					public void doCallback(Object obj) {
						String path = (String) obj;
						ICallback setBitmapCallback = new ICallback() {
							@Override
							public void doCallback(Object obj) {
								Bitmap bitmap = (Bitmap) obj;
								// 由于用户不断拉动，可能iv已经重用，所以必须判断一下
								if (iv.getTag() == images.get(position)) {
									iv.setImageBitmap(bitmap);
								}
							}
						};
						Bitmap bitmap = BitmapCache.getInstance().getBitmapFromMemCache(path);
						if(bitmap != null){
							setBitmapCallback.doCallback(bitmap);
							bitmap = null;
						}else {
							new GetBitmapTask(path, setBitmapCallback).execute();
						}
					}
				});
			}
		}
	}

}



class GetBitmapTask extends AsyncTask<Void, Void, Void> {

	private String mFilepath;

	private ICallback mCallback;
	private Bitmap mBitmap;

	public GetBitmapTask(String path, ICallback callback) {
		mFilepath = path;
		mCallback = callback;
	}

	@Override
	protected Void doInBackground(Void... params) {
		mBitmap = BitmapCache.getInstance().getBitmapFromMemCache(mFilepath);
		if(mBitmap == null){
			mBitmap = BitmapManager.decodeBitmap2Scale(mFilepath, 100);
		}
		return null;
	}

	@Override
	protected void onPostExecute(Void result) {
		mCallback.doCallback(mBitmap);
		BitmapCache.getInstance().addBitmapToMemoryCache(mFilepath, mBitmap);
		mBitmap = null;
		super.onPostExecute(result);
	}
}