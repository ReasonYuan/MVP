package com.hp.android.halcyon;

import java.io.File;
import java.util.ArrayList;

import android.content.Intent;
import android.view.View;
import android.widget.GridView;

import com.fq.android.plus.R;
import com.hp.android.halcyon.selphoto.SelectPhotoAdapter;

public class SelectPhotoActivity extends BaseActivity{

	public static final int TO_ALBUM_RESULT = 1766;
	
	public static final String EXTRA_PHOTO_NAMES = "photo_names";
	
	public static final String EXTRA_IMAGE_LIST = "imagelist";
	
	private SelectPhotoAdapter mAdapter;
	
	public String mPhotoName;
	
	private String mBuckkeName;
	
	private static ArrayList<String> mSelectNames;
	
	@Override
	public int getContentId() {
		return R.layout.activity_select_photo;
	}

	@Override
	public void init() {
		//getIntent().getBooleanExtra("is_single_slection", false);
		boolean isb = SelectPhotoBucketListActivity.mIsSingle;
		
		mBuckkeName = getIntent().getStringExtra("bucket_name");
		if(mBuckkeName == null){
			mBuckkeName = "最近照片";
		}
		setTitle(mBuckkeName);
		
		if(!isb)setTopRightText(R.string.btn_done);
		
		mAdapter = new SelectPhotoAdapter(this,isb);
		GridView grid = (GridView) findViewById(R.id.gd_photo);
		grid.setAdapter(mAdapter);
		
		if(mSelectNames == null){
			mSelectNames = new ArrayList<String>();
		}
		mAdapter.notifyData(SelectPhotoBucketListActivity.getBucketByName(mBuckkeName));
	}
	
	@Override
	protected void onRestart() {
		super.onRestart();
		new Thread(new Runnable() {
			public void run() {
				SelectPhotoBucketListActivity.initData();
				fileExists();
				runOnUiThread(new Runnable() {
					public void run() {
						mAdapter.notifyData(SelectPhotoBucketListActivity.getBucketByName(mBuckkeName));
					}
				});
			}
		}).start();
	}
	
	public static void fileExists(){
		for(int i = 0; i < mSelectNames.size(); i++){
			String path = mSelectNames.get(i);
			File file = new File(path);
			if(!file.exists()){
				mSelectNames.remove(path);
				i--;
			}
		}
	}
	
	@Override
	public void onTopRightBtnClick(View view) {
		mAdapter.send();
	}
	
	/*@Override
	public void onTopLeftBtnClick(View view) {
		Intent intent = new Intent();
		setResult(515, intent);
		finish();
	}*/
	
	@Override
	public void onBackPressed() {
		Intent intent = new Intent();
		setResult(515, intent);
		super.onBackPressed();
	}
	
	/*@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		//super.onActivityResult(requestCode, resultCode, data);
		if(requestCode == TO_ALBUM_RESULT && !"".equals(mPhotoName)){
			Intent intent = new Intent();
			ArrayList<String> list = new ArrayList<String>();
			list.add(mPhotoName);
			intent.putExtra(EXTRA_PHOTO_NAMES, list);
			setResult(TO_ALBUM_RESULT, intent);
			mPhotoName = "";
			list = null;
			finish();
		}else{
			if(data == null)return;
		}
	}*/
	
	public static ArrayList<String> getSelectPaths(){
		return mSelectNames;
	}
	
	public static void addPath(String path){
		mSelectNames.add(path);
	}
	
	public static void removePath(String path){
		mSelectNames.remove(path);
	}
	
	public static boolean contains(String path){
		return mSelectNames.contains(path);
	}
	
	public static boolean isSelectEmpty(){
		return mSelectNames.isEmpty();
	}
	
	public static void clear(){
		if(mSelectNames != null){
			mSelectNames.clear();
			mSelectNames = null;
		}
	}
}
