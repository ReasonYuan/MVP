package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.HashMap;

import android.content.Intent;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.logic2.BrowsePicLogic;
import com.fq.halcyon.logic2.BrowsePicLogic.BrowsePicCallBack;
import com.fq.lib.callback.ICallback;
import com.hp.android.halcyon.util.BitmapCache;
import com.hp.android.halcyon.util.BitmapManager;

public class BrowseRecordPicActivity extends BaseActivity{

	private ArrayList<HashMap<String, Object>> mPicList = new ArrayList<HashMap<String, Object>>();
//	private ArrayList<String> mPicPathList = new ArrayList<String>();
	/**图片的网络地址*/
	 ArrayList<PhotoRecord> mImageList = new ArrayList<PhotoRecord>();
	/**图片的本地地址*/
	private ArrayList<String> mLocalPath = new ArrayList<String>();
	BitmapCache mBitmapCache = new BitmapCache();
	private GridView mPicGrid;
	private BrowseRecordPicAdapter mAdapter;
	
	@Override
	public int getContentId() {
		return R.layout.activity_browse_record_pic;
	}

	@Override
	public void init() {
		setTitle("附图");
		initWidgets();
		initData();
	}

	private void initWidgets(){
		mPicGrid = (GridView) findViewById(R.id.grid_browse_record_pic);
		mAdapter = new BrowseRecordPicAdapter();
		mPicGrid.setAdapter(mAdapter);
		mPicGrid.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int position,
					long arg3) {
				//ArrayList<OneType> mTypes = new ArrayList<OneType>();
				Intent intent = new Intent(BrowseRecordPicActivity.this, BrowTakePhotoActivity.class);
				intent.putExtra(BrowTakePhotoActivity.EXTRA_BROW_NAMES, mLocalPath);
				intent.putExtra(BrowTakePhotoActivity.EXTRA_BROW_UPLOAD, true);
				BrowseRecordPicActivity.this.startActivity(intent);
			}
		});
	}
	
	private void initData(){
		int recordId = getIntent().getIntExtra("recordId", 0);
		BrowsePicLogic  logic = new BrowsePicLogic(recordId, new BrowsePicCallBack() {
			
			@Override
			public void onResultCallBack(ArrayList<HashMap<String, Object>> picList) {
				mPicList.addAll(picList);
				for (int i = 0; i < mPicList.size(); i++) {
					PhotoRecord hayImage = new PhotoRecord();
					hayImage.setImageId(Integer.parseInt(picList.get(i).get("image_id").toString()));
					hayImage.setImagePath(picList.get(i).get("image_path").toString());
					mImageList.add(hayImage);
				}
				mAdapter.notifyDataSetChanged();
			}
			
			@Override
			public void onErrorCallBack(int code, String msg) {
				// TODO Auto-generated method stub
				
			}
		});
	}
	
	public class BrowseRecordPicAdapter extends BaseAdapter{

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
		public View getView(int position, View convertView, ViewGroup parent) {
			if(convertView == null){
				convertView = LayoutInflater.from(BrowseRecordPicActivity.this).inflate(R.layout.item_browse_record_pic, null);
			}
			final ImageView picView = (ImageView) convertView.findViewById(R.id.img_item_browse_pic);
			ApiSystem.getInstance().getImage(mImageList.get(position), new ICallback() {
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
					if(bmp!=null)picView.setImageBitmap(bmp);
				}
			});
			return convertView;
		}
	}
}
