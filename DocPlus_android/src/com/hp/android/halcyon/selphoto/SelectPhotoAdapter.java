package com.hp.android.halcyon.selphoto;

import java.util.ArrayList;
import java.util.List;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.fq.android.plus.R;
import com.fq.lib.tools.FQLog;
import com.hp.android.halcyon.SelectPhotoActivity;
import com.hp.android.halcyon.selphoto.BitmapCache.ImageCallback;

public class SelectPhotoAdapter extends BaseAdapter implements OnClickListener{
	
	SelectPhotoActivity mSelectActivty;
	
//	ArrayList<File> mFiles = new ArrayList<File>();
//	ArrayList<String> mFileNames = new ArrayList<String>();
	
	private BitmapCache cache;
	
//	private ArrayList<String> mSelectNames = new ArrayList<String>();
	
//	private static HashMap<String, String> mSelectNameMap = new HashMap<String, String>();
	
	private List<ImageItem> mImgList;
	
	private boolean mIsSingle;
	
	ImageCallback callback = new ImageCallback() {
		@Override
		public void imageLoad(ImageView imageView, Bitmap bitmap,
				Object... params) {
			if (imageView != null && bitmap != null) {
				String url = (String) params[0];
				if (url != null && url.equals((String) imageView.getTag())) {
					imageView.setImageBitmap(bitmap);
				} else {
					FQLog.e("Select photo adapter", "callback, bmp not match");
				}
			} else {
				FQLog.e("Select photo adapter", "callback, bmp null");
			}
		}
	};
	
	public SelectPhotoAdapter(SelectPhotoActivity activity,boolean isb){
		mIsSingle = isb;
		mSelectActivty = activity;
		mImgList = new ArrayList<ImageItem>();
		cache = new BitmapCache();
	}
	
	public void notifyData(List<ImageItem> items){
		mImgList = items;
		if(mImgList == null)mImgList = new ArrayList<ImageItem>();
		notifyDataSetChanged();
	}
	
	public void notifyData(ImageBucket bucket){
		mImgList = bucket.imageList;
		notifyDataSetChanged();
//		mImgList.clear();
//		List<ImageBucket> list = mSelectActivty.dataList;
//		for(ImageBucket buck : list){
//			/*if("Camera".equals(buck.bucketName)){// || "Halcyon".equals(buck.bucketName)){
//				mImgList.addAll(buck.imageList);
//				break;
//			}*/
//			if("Camera".equals(buck.bucketName)){
//				mImgList.addAll(0,buck.imageList);
//			}else{
//				mImgList.addAll(buck.imageList);
//			}
//		}
	}
	
	@Override
	public int getCount() {
		return mImgList.size();
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
		final ImageItem item = mImgList.get(position);
		ImageView imgView = null;
		if (convertView == null) {
			convertView = LayoutInflater.from(mSelectActivty).inflate(R.layout.item_select_photo, null);
		}
		float wid = parent.getWidth()/3.0f;
		View view = convertView.findViewById(R.id.fl_photo_content);
		view.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, (int)wid));
		
		 /*if(position == 0){
			convertView.findViewById(R.id.fl_photo_pic).setVisibility(View.GONE);
			View phview = convertView.findViewById(R.id.fl_photo_text);
			phview.setVisibility(View.VISIBLE);
			
			phview.setOnClickListener(new OnClickListener() {
				public void onClick(View v) {
					Intent intent = new Intent("android.media.action.IMAGE_CAPTURE");
					mSelectActivty.mPhotoName = FileManager.getInstance().getBackupPhotoPath(System.currentTimeMillis()+"b.jpg");
					File file = new File(mSelectActivty.mPhotoName);
					intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(file));
					mSelectActivty.startActivityForResult(intent, SelectPhotoActivity.TO_CAMERA_RESULT);
				}
			});
		}else{
			convertView.findViewById(R.id.fl_photo_pic).setVisibility(View.VISIBLE);
			convertView.findViewById(R.id.fl_photo_text).setVisibility(View.GONE);*/

			imgView = (ImageView) convertView.findViewById(R.id.iv_photo);
			imgView.setTag(item.imagePath);
			
			Drawable d = imgView.getDrawable();  
			if (d != null) d.setCallback(null);  
			imgView.setImageDrawable(null);  
			
			cache.displayBmp(imgView, item.thumbnailPath, item.imagePath,callback);
			
			convertView.setTag(item);
			convertView.setOnClickListener(this);
			if(!mIsSingle){
//				setSelected(convertView, item);
				if(item.isSelected){
					convertView.findViewById(R.id.fl_select_photo_state).setSelected(true);
					convertView.findViewById(R.id.fl_select_photo_check_state).setVisibility(View.VISIBLE);
				}else{
					convertView.findViewById(R.id.fl_select_photo_state).setSelected(false);
					convertView.findViewById(R.id.fl_select_photo_check_state).setVisibility(View.GONE);
				}
				
			}
//			if(mIsSingle){
////				convertView.findViewById(R.id.ckb_photo_selecter).setVisibility(View.GONE);
//				convertView.findViewById(R.id.fl_select_photo_state).setVisibility(View.GONE);
//				convertView.setTag(item);
//				convertView.setOnClickListener(this);
//			}else{
//				CheckBox ckb = (CheckBox) convertView.findViewById(R.id.ckb_photo_selecter);
//				ckb.setChecked(item.isSelected);
//				ckb.setOnClickListener(new OnClickListener() {
//					public void onClick(View v) {
//						item.isSelected = !item.isSelected;
//						String name = item.imagePath;//file.getAbsolutePath();
//						if(item.isSelected){
//							mSelectNames.add(name);
//						}else{
//							mSelectNames.remove(name);
//						}
//					}
//				});
//			}
//		}
		
		return convertView;
	}

	public void send(){
		mSelectActivty.mPhotoName = "";
		cache = null;
		if(!SelectPhotoActivity.isSelectEmpty()){
			ArrayList<String> names = SelectPhotoActivity.getSelectPaths();
			Intent intent = new Intent();
			intent.putExtra(SelectPhotoActivity.EXTRA_PHOTO_NAMES, names);
			mSelectActivty.setResult(SelectPhotoActivity.TO_ALBUM_RESULT, intent);
		}else{
			Intent intent = new Intent();
			mSelectActivty.setResult(501, intent);
		}
		mSelectActivty.finish();
//		SelectPhotoActivity.clear();
	}
	
	@Override
	public void onClick(View v) {
		ImageItem item = (ImageItem) v.getTag();
		if(mIsSingle){
			String path = item.imagePath;
			Intent intent = new Intent();
			intent.putExtra(SelectPhotoActivity.EXTRA_PHOTO_NAMES, path);
			mSelectActivty.setResult(SelectPhotoActivity.TO_ALBUM_RESULT, intent);
			cache = null;
			mSelectActivty.finish();
		}else{
			item.isSelected = !item.isSelected;
			setSelected(v,item);
			/*if(item.isSelected){
				SelectPhotoActivity.addPath(item.imagePath);
				v.findViewById(R.id.fl_select_photo_state).setSelected(true);
				v.findViewById(R.id.fl_select_photo_check_state).setVisibility(View.VISIBLE);
			}else{
				SelectPhotoActivity.removePath(item.imagePath);
				v.findViewById(R.id.fl_select_photo_state).setSelected(false);
				v.findViewById(R.id.fl_select_photo_check_state).setVisibility(View.GONE);
			}*/
		}
	}
	
	public void setSelected(View v,ImageItem item){
		if(item.isSelected){
			SelectPhotoActivity.addPath(item.imagePath);
			v.findViewById(R.id.fl_select_photo_state).setSelected(true);
			v.findViewById(R.id.fl_select_photo_check_state).setVisibility(View.VISIBLE);
		}else{
			SelectPhotoActivity.removePath(item.imagePath);
			v.findViewById(R.id.fl_select_photo_state).setSelected(false);
			v.findViewById(R.id.fl_select_photo_check_state).setVisibility(View.GONE);
		}
	}
}