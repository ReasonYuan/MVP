package com.hp.android.halcyon.widgets;

import uk.co.senab.photoview.PhotoImageView;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Photo;
import com.fq.lib.callback.ICallback;
import com.fq.library.imageutils.ImageLoader;
import com.hp.android.halcyon.util.BitmapCache;
import com.hp.android.halcyon.util.BitmapManager;
import com.hp.android.halcyon.view.LoadingView;

/**
 * 加载图片空间，可加载本地图片也可加载网络图片
 * 
 * @author reason
 * 
 */
public class PhotoView extends FrameLayout {

	private ImageView mImageView;

	/**
	 * 加载网络图片时，需要显示一个progressBar
	 */
	private LoadingView mProgressBar;

	/**
	 * 要显示的图片Photo
	 */
//	private Photo mPhoto;

	public PhotoView(Context context) {
		super(context);
		init();
	}

	public PhotoView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public PhotoView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	public void init() {
		View v = LayoutInflater.from(getContext()).inflate(
				R.layout.widget_photo_image, null);
		addView(v);

		mImageView = (PhotoImageView) findViewById(R.id.iv_widget_photo);
		mProgressBar = (LoadingView) findViewById(R.id.pb_widget_photo);
	}

	/*public void setPhoto(Photo photo) {
		mPhoto = photo;
	}*/

	public void setScale(boolean isScale){
		if(!isScale){
			findViewById(R.id.iv_widget_photo).setVisibility(View.GONE);
			mImageView = (ImageView) findViewById(R.id.iv_photo);
			mImageView.setVisibility(View.VISIBLE);
		}
	}
	
	public void setScaleType(ScaleType type) {
		mImageView.setScaleType(type);
	}

	public void setProgressBarVisible(final int visible) {
		if(visible == View.GONE){
			mProgressBar.stopAnim();
			mProgressBar.setVisibility(visible);
		}else{
			mProgressBar.startAnim();
			mProgressBar.setVisibility(visible);
		}
//		mProgressBar.setVisibility(visible);
	}

	/**
	 * 清楚控件之前加载的图片，防止内存溢出
	 */
	public void clear() {
		Drawable d = mImageView.getDrawable();
		if (d != null)
			d.setCallback(null);
		mImageView.setImageDrawable(null);
		setProgressBarVisible(View.GONE);
	}

	/**
	 * 设置图片给控件显示
	 */
	public void setImageBitmap(Bitmap bitmap) {
		mImageView.setImageBitmap(bitmap);
	}

	/**
	 * 通过本地路径加载图片，并将图片缓存到内存当中方便以后使用
	 * 
	 * @param localPath
	 *            图片的本地路径
	 */
	public void loadImageByLocalPath(String localPath) {
		Bitmap bmp = BitmapCache.getInstance().getBitmapFromMemCache(localPath);
		
		if (bmp == null) {
			bmp = BitmapManager.decodeBitmap2Scale(localPath);
			if(bmp != null)BitmapCache.getInstance().addBitmapToMemoryCache(localPath, bmp);
		}
		
		if (bmp != null) mImageView.setImageBitmap(bmp);
	}
	
	public void loadImageByLocalPath(String localPath,int size) {
		Bitmap bmp = BitmapCache.getInstance().getBitmapFromMemCache(localPath);
		if (bmp == null) {
			bmp = BitmapManager.decodeSampledBitmapFromFile(localPath,size);
		}
		if (bmp != null) {
			BitmapCache.getInstance().addBitmapToMemoryCache(localPath, bmp);
			mImageView.setImageBitmap(bmp);
		}
	}

	/**
	 * 通过Photo实例加载图片
	 * 
	 * @param photo
	 *            一个图片的实例
	 */
	public void loadImageByPhoto(Photo photo) {
		loadImage(photo, false,true);
	}

	/**
	 * 通过Photo实例加载图片
	 * 
	 * @param photo
	 *            一个图片的实例
	 * @param isScale
	 *            是否加载缩略图
	 */
	public void loadImageByPhoto(Photo photo, boolean isThumb,int size) {
		loadImage(photo, isThumb,true);
	}
	
	public void loadImageThumbByPhoto(Photo photo) {
		loadImage(photo, true,false);
	}
	
	/**
	 * 通过Photo实例加载图片，图片没加载出来之前显示缩略图
	 * 
	 * @param photo
	 *            一个图片的实例
	 * @param thumbnail
	 *            图片的缩略图
	 */
	public void loadImageByPhoto(Photo photo, Bitmap thumbnail,int size) {
		mImageView.setImageBitmap(thumbnail);
		loadImage(photo, false,true);
	}

	/**
	 * 加载图片，根据图片的网络路径生成本地路径。先从本地查询图片，如果本地没有则从网络加载图片
	 * 
	 * @param photo一个图片的实例
	 */
	private void loadImage(Photo photo, final boolean isThumb, boolean isShowLoading) {
		if (isShowLoading) {
			setProgressBarVisible(View.VISIBLE);
			mImageView.setImageResource(android.R.color.transparent);
		}else{
			mImageView.setImageResource(R.drawable.btn_record_album);
		}
		ApiSystem.getInstance().getImage(photo, new ICallback() {
			public void doCallback(Object obj) {
				final String path = (String) obj;
				post(new Runnable() {
					public void run() {
						setProgressBarVisible(View.GONE);
						if (path != null && !"".equals(path)) {
							ImageLoader.getInstance().loadImage(path, mImageView, false);
						}
					}
				});	
			}
		}, isThumb);
	}

}
