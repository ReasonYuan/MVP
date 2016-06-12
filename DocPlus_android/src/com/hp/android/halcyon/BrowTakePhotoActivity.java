package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.BaseAdapter;
import android.widget.Gallery;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.uimodels.OneCopy;
import com.fq.halcyon.uimodels.OneType;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.record.SnapPhotoManager;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.PhotoView;


public class BrowTakePhotoActivity extends BaseActivity{

	public static final int RESULT_CODE_BROW_TAKE_PHOTO = 998;
	public static final int RESULT_CODE_BROW_UPLOAD = 979;
	public static final String EXTRA_BROW_UPLOAD = "is_brow_upload";
	public static final String EXTRA_BROW_NAMES = "brow_list_paths";
	public static final String EXTRA_BROW_TYPES = "brow_photo_types";
	
	private Gallery mImgGallery;
	
//	private int mRecordId;
	private ArrayList<OneType> mTypes;
	private ArrayList<PhotoRecord> mPhotos;
	
	private GalleryAdapter mAdapter;
	private int mCurrentIndex;
	private CustomDialog customDialog;
	
	@Override
	public int getContentId() {
		return R.layout.activity_brow_take_photo;
	}
	
	@Override
	public void onBackPressed() {
		Intent intent = new Intent();
		setResult(RESULT_CODE_BROW_TAKE_PHOTO, intent);
		finish();
		return;
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode == 998 && data != null){
			setResult(333, data);
			finish();
		}else if(resultCode == 777 && data != null){
			setResult(RESULT_CODE_BROW_UPLOAD, data);
			finish();
		}
	}
	
	public void onDeleteClick(View v){
		if(mCurrentIndex < 0)return;
		mCurrentIndex = mImgGallery.getSelectedItemPosition();
		final int index = mCurrentIndex%mPhotos.size();
		customDialog = new CustomDialog(this);
		customDialog.setMessage("是否删除这张照片?");
		customDialog.setNegativeButton(R.string.btn_cancel, new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				customDialog.dismiss();
				customDialog = null;
			}
		});
		customDialog.setPositiveListener(R.string.btn_sure_ren, new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				customDialog.dismiss();
				customDialog = null;
				
				PhotoRecord photo = mPhotos.get(index);
				mPhotos.remove(photo);
				
				for(int i = 0; i < mTypes.size(); i++){
					OneType type = mTypes.get(i);
					OneCopy copy = type.getCopyById(0);
					if(copy.getPhotos().contains(photo)){
						copy.getPhotos().remove(photo);
						if(copy.getPhotos().size() == 0){
							mTypes.remove(type);
						}
						int count = mPhotos.size();
						if(count == 0){
							mCurrentIndex = -1;
							setTitle("");
						}else{
							setTitle((index+1)+"/"+count);
						}
						mAdapter.notifyDataSetChanged();
						if(mCurrentIndex>-1)mImgGallery.setSelection(mPhotos.size()*30000+index);
						return;
					}
				}
			}
		});
		customDialog.show();
	}
	
	public void onUploadClick(View v){
		if(mPhotos.size() > 0){
			if(Constants.getUser().isOnlyWifi() && !UITools.isWifiConnected(BrowTakePhotoActivity.this)){
				settingWifiDialog();
				return;
			}
			SnapPhotoManager snap = SnapPhotoManager.getInstance();
			if(snap.getRecordId() == 0){
				customDialog = new CustomDialog(this);
				customDialog.setMessage("上传病历出现失败！");
				customDialog.setPositiveListener(R.string.btn_sure_ren, new View.OnClickListener() {
					
					@Override
					public void onClick(View arg0) {
						customDialog.dismiss();
						customDialog = null;
						
					}
				} );
				customDialog.setPositiveBackground(R.drawable.selector_btn_dialog);
				customDialog.show();
				return;
			}
//			new UploadRecordLogic().upLoad("", snap.getRecordId(), mTypes);//统一改在浏览界面上传
			Intent intent = new Intent();
			setResult(RESULT_CODE_BROW_UPLOAD, intent);
			finish();
		}else{
			customDialog = new CustomDialog(this);
			customDialog.setMessage("请选择至少一张病历图片上传");
			customDialog.setPositiveListener(R.string.btn_sure_ren, new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					customDialog.dismiss();
					customDialog = null;
					
				}
			} );
			customDialog.setPositiveBackground(R.drawable.selector_btn_dialog);
			customDialog.show();
		}
	}
	
	// 提示是否设置Wifi的dialog
	private void settingWifiDialog() {
		final CustomDialog dialog = new CustomDialog(this);
		dialog.setMessage("您的wifi处于关闭状态，是否要打开wifi？");

		dialog.setPositiveListener(R.string.btn_sure_ren,
				new View.OnClickListener() {

					@Override
					public void onClick(View arg0) {
						// TODO Auto-generated method stub
						dialog.dismiss();
						Intent wifiSettingsIntent = new Intent(
								"android.settings.WIFI_SETTINGS");
						startActivity(wifiSettingsIntent);
					}
				});
		dialog.setNegativeButton(R.string.btn_cancel,
				new View.OnClickListener() {
					@Override
					public void onClick(View arg0) {
						dialog.dismiss();

					}
				});
		dialog.show();
	}
	
	@Override
	public void init() {
		setTopRightImgSrc(R.drawable.btn_menu);
		
		mPhotos = new ArrayList<PhotoRecord>();
		mTypes = SnapPhotoManager.getInstance().getTypes();
		for(int i = 0; i < mTypes.size(); i++){
			mPhotos.addAll(mTypes.get(i).getCopyById(0).getPhotos());
		}
		
		if(mPhotos == null)mPhotos = new ArrayList<PhotoRecord>();
		mImgGallery = (Gallery) findViewById(R.id.gallery_takephoto);
		
		mImgGallery.setOnItemSelectedListener(new OnItemSelectedListener() {
			public void onItemSelected(AdapterView<?> parent, View view,int position, long id) {
				int count = mPhotos.size();
				mCurrentIndex = position;
				setTitle((position%count+1)+"/"+count);
			}

			public void onNothingSelected(AdapterView<?> parent) {}
		});
		
		if(mPhotos.size() > 1)mImgGallery.setSelection(mPhotos.size()*30000);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		if(mAdapter == null){
			mAdapter = new GalleryAdapter(this);
			mImgGallery.setAdapter(mAdapter);
			setTitle(1+"/"+mPhotos.size());
		}else{
			mPhotos.clear();
			for(int i = 0; i < mTypes.size(); i++){
				mPhotos.addAll(mTypes.get(i).getAllPhotos());
			}
			int count = mPhotos.size();
			if(count == 0){
				mCurrentIndex = -1;
				setTitle("");
				mImgGallery.setVisibility(View.INVISIBLE);
				return;
			}
			if(mCurrentIndex >= count){
				mCurrentIndex = 0;
				mImgGallery.setSelection(mCurrentIndex);
				setTitle(1+"/"+mPhotos.size());
			}else{
				setTitle((mCurrentIndex%count+1)+"/"+count);
				mAdapter.notifyDataSetChanged();
			}
		}
	}
	
	@Override
	public void onTopRightBtnClick(View view) {
		Intent intent = new Intent(this, AllRecordPhotoActivity.class);
		startActivityForResult(intent, 111);
	}
	
	
	class GalleryAdapter extends BaseAdapter{

		private Context mContext;
		
		public GalleryAdapter(Context context) {
			mContext = context;
		}
		
		@Override
		public int getCount() {
			if(mPhotos.size() < 2)return mPhotos.size();
			return Integer.MAX_VALUE;
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
			if(convertView == null){
				convertView = LayoutInflater.from(mContext).inflate(R.layout.view_brow_photo, null);
				convertView.setLayoutParams(new Gallery.LayoutParams(Gallery.LayoutParams.MATCH_PARENT, Gallery.LayoutParams.MATCH_PARENT)); 
//				ImageView imageView = new ImageView(mContext); 
//				//设置布局图片以105*150显示 （简单解释——设置数字不一样，图片的显示大小不一样）
//				imageView.setLayoutParams(new Gallery.LayoutParams(Gallery.LayoutParams.MATCH_PARENT, Gallery.LayoutParams.MATCH_PARENT)); 
//				imageView.setScaleType(ImageView.ScaleType.FIT_CENTER); 
//				convertView = imageView;
			}
			PhotoView photoView = (PhotoView) convertView.findViewById(R.id.iv_brow_photo);
			photoView.setScale(false);
			int index = position%mPhotos.size();
			String path = mPhotos.get(index).getLocalPath();

			View des = convertView.findViewById(R.id.tv_brow_photo_des);
			if(path == null){
				des.setVisibility(View.VISIBLE);
				photoView.setVisibility(View.GONE);
			}else{
				photoView.clear();
				photoView.loadImageByLocalPath(path);
				des.setVisibility(View.GONE);
				photoView.setVisibility(View.VISIBLE);
			}
			
			TextView text = (TextView) convertView.findViewById(R.id.tv_brow_photo_type);
			text.setText(RecordConstants.getTypeNameByRecordType(mPhotos.get(index).getRecordType()));
			/*if(mTypes != null){
				boolean have = false;
				for(int i = 0; i < mTypes.size(); i++){
					OneType type = mTypes.get(i);
					if(path == null || type.isHavaPhotoByUrl(path)){
						text.setText(RecordConstants.getTypeNameByRecordType(type.getType()));
						have = true;
						break;
					}
				}
				text.setVisibility(have?View.VISIBLE:View.GONE);
			}else{
				text.setVisibility(View.GONE);
			}*/
			 return convertView; 
		}
	}
}
