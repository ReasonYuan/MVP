package com.hp.android.halcyon.util;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.support.v4.util.LruCache;

public class BitmapCache {

	public static BitmapCache mInstance;
	
	private LruCache<String, Bitmap> mMemoryCache;

	public static BitmapCache getInstance(){
		if(mInstance == null){
			mInstance = new BitmapCache();
		}
		return mInstance;
	}
	
	public static void clean(){
		mInstance = null;
	}
	
	
	public BitmapCache() {
		int maxMemory = (int) (Runtime.getRuntime().maxMemory() / 1024);
		// 使用最大可用内存值的1/8作为缓存的大小。
		int cacheSize = maxMemory / 8;
		mMemoryCache = new LruCache<String, Bitmap>(cacheSize) {
			@SuppressLint("NewApi")
			@Override
			protected int sizeOf(String key, Bitmap bitmap) {
				// 重写此方法来衡量每张图片的大小，默认返回图片数量。
				return bitmap.getByteCount() / 1024;
			}
		};
	}

	public void addBitmapToMemoryCache(String key, Bitmap bitmap) {
		if(key == null || "".equals(key) || bitmap == null)return;
		if (getBitmapFromMemCache(key) == null) {
			mMemoryCache.put(key, bitmap);
		}
	}

	public Bitmap getBitmapFromMemCache(String key) {
		if(key == null)return null;
		return mMemoryCache.get(key);
	}

}