package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.List;

import android.content.Intent;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.hp.android.halcyon.selphoto.AlbumHelper;
import com.hp.android.halcyon.selphoto.ImageBucket;
import com.hp.android.halcyon.selphoto.ImageItem;
import com.hp.android.halcyon.util.BitmapManager;

public class SelectPhotoBucketListActivity extends BaseActivity{

	public static final int TO_ALBUM_RESULT = 1766;
	
	public static final String EXTRA_PHOTO_NAMES = "photo_names";
	
	public static final String EXTRA_IMAGE_LIST = "imagelist";
	
	private PhotoBucketAdapter mAdapter;
	
	public String mPhotoName;
	
	private ListView mListView;

	private static List<ImageBucket> dataList;
	
	public static boolean mIsSingle;
	
	private AlbumHelper helper;
	
	@Override
	public int getContentId() {
		return R.layout.activity_photo_bucket_list;
	}

	@Override
	public void init() {
		mIsSingle = getIntent().getBooleanExtra("is_single_slection", false);
		setTitle("相册");
		mListView = (ListView) findViewById(R.id.lv_photo_bucket_list);
		mListView.setOnItemClickListener(new OnItemClickListener() {
			
			public void onItemClick(AdapterView<?> parent, View view,int position, long id) {
				String buckName = dataList.get(position).bucketName;
				Intent intent = new Intent(SelectPhotoBucketListActivity.this, SelectPhotoActivity.class);
				intent.putExtra("bucket_name", buckName);
				startActivityForResult(intent,121);
			}
		});
		
		mAdapter = new PhotoBucketAdapter();
		mListView.setAdapter(mAdapter);
		
		helper = AlbumHelper.getHelper();
		helper.init(HalcyonApplication.getAppContext());
		initData();
		
		Intent intent = new Intent(this, SelectPhotoActivity.class);
		intent.putExtra("bucket_name", "最近照片");//最近照片
		startActivityForResult(intent,121);
	}
	
	public static void initData(){
		dataList = AlbumHelper.getHelper().getAllImagesList();
	}
	
	/*public static void addBucket(ImageBucket bucket){
		if(dataList == null)return;
		for(int i = 0; i < dataList.size(); i++){
			ImageBucket bt = dataList.get(i);
			if(bucket.bucketName.equals(bt.bucketName)){
				dataList.remove(bt);
				dataList.add(i,bucket);
				return;
			}
		}
		dataList.add(bucket);
	}
	
	public static void removeBucket(ImageBucket bucket){
		if(dataList == null)return;
		for(ImageBucket bt:dataList){
			if(bucket.bucketName.equals(bt.bucketName)){
				dataList.remove(bt);
				break;
			}
		}
	}*/
	
	public static ImageBucket getBucketByName(String name){
		for(ImageBucket bucket:dataList){
			if(name.equals(bucket.bucketName)){
				return bucket;
			}
		}
		return new ImageBucket();
	}
	
	
	@Override
	protected void onRestart() {
		super.onRestart();
		mAdapter.notifyDataSetChanged();
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		dataList = null;
		mIsSingle = false;
		helper.clear();
		SelectPhotoActivity.clear();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode == 501){//什么也没选择时
			finish();
		}else if(resultCode != 515){
			ArrayList<String> photoFiles = data
					.getStringArrayListExtra(SelectPhotoActivity.EXTRA_PHOTO_NAMES);
			setResult(resultCode, data);
			finish();
		}
	}
	
	public class PhotoBucketAdapter extends BaseAdapter{

		@Override
		public int getCount() {
			if(dataList == null)return 0;
			return dataList.size();
		}

		@Override
		public Object getItem(int position) {
			return null;
		}

		@Override
		public long getItemId(int position) {
			return 0;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
//			UITools.showToast("sss");
			ImageBucket bucket = dataList.get(position);
			
			if(convertView == null){
				convertView = LayoutInflater.from(SelectPhotoBucketListActivity.this).inflate(R.layout.item_photo_bucket_item, null);
			}
			
			ImageItem item = bucket.imageList.get(0);
			
			ImageView iv = (ImageView) convertView.findViewById(R.id.iv_photo_bucket_img);
			Bitmap bmp = BitmapManager.decodeSampledBitmapFromFile(item.thumbnailPath, 2);
			if(bmp == null)bmp = BitmapManager.decodeBitmap2ScaleTo(item.imagePath,80);
			if(bmp != null)iv.setImageBitmap(bmp);
			
			TextView tv = (TextView) convertView.findViewById(R.id.tv_photo_bucket_name);
			tv.setText(bucket.bucketName+"("+bucket.imageList.size()+")");
			
			return convertView;
		}
	}
}
