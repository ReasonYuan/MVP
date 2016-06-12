package com.hp.android.halcyon.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.lib.callback.ICallback;
import com.hp.android.halcyon.util.BitmapCache;
import com.hp.android.halcyon.util.BitmapManager;

/**
 * 显示 影像缩略图的Adapter
 */
public class YingXiangAdapter extends BaseAdapter{

	private Context mContext;
	/**图片的网络地址*/
	 ArrayList<PhotoRecord> mImageList = new ArrayList<PhotoRecord>();
	/**图片的本地地址*/
	private ArrayList<String> mLocalPath = new ArrayList<String>();
	
	
	BitmapCache mBitmapCache = new BitmapCache();
	
	public YingXiangAdapter(Context mContext) {
		this.mContext = mContext;
	}
	
	public void addList( ArrayList<PhotoRecord> imageList) {
		this.mImageList.clear();
		this.mLocalPath.clear();
		this.mImageList = imageList;
		notifyDataSetChanged();
	}
	
	@Override
	public int getCount() {
		return mImageList.size();
	}

	@Override
	public PhotoRecord getItem(int position) {
		return mImageList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View view, ViewGroup group) {
		if(view == null){
			view = LayoutInflater.from(mContext).inflate(R.layout.item_ying_xiang, null);
		}
		
		PhotoRecord img = mImageList.get(position);
		final ImageView imgPic = (ImageView) view.findViewById(R.id.img_ying_xiang);
		
		ApiSystem.getInstance().getImage(img, new ICallback() {
			@Override
			public void doCallback(Object obj) {
				String path = (String) obj;
				if(!mLocalPath.contains(path)){
					mLocalPath.add(path);
				}
				Bitmap bmp = mBitmapCache.getBitmapFromMemCache(path);
				if(bmp == null){
					bmp = BitmapManager.decodeBitmap2Scale(path);
					if(bmp!=null)mBitmapCache.addBitmapToMemoryCache(path, bmp);
				}
				if(bmp!=null)imgPic.setImageBitmap(bmp);
			}
		});
		return view;
	}

	/**获取图片的本地路径*/
	public ArrayList<String> getImgLocalPath(){
		return mLocalPath;
	}
}
