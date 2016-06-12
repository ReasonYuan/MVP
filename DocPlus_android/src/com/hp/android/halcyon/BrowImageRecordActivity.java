package com.hp.android.halcyon;

import java.util.ArrayList;

import uk.co.senab.photoview.HackyViewPager;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.halcyon.logic.GetImagePathLogic;
import com.fq.halcyon.logic.GetImagePathLogic.ImagePathCallBack;
import com.fq.halcyon.logic2.RemoveRecordItemLogic;
import com.fq.halcyon.logic2.RemoveRecordItemLogic.RemoveItemCallBack;
import com.hp.android.halcyon.util.BitmapManager;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.PhotoView;

public class BrowImageRecordActivity extends Activity implements ImagePathCallBack,RemoveItemCallBack{

	private ArrayList<PhotoRecord> mPhotos;

	private TextView mTitleText;
	private SamplePagerAdapter mAdapter;

	private RecordItemSamp mItem;

	private RemoveRecordItemLogic mRemoveLogic;
	
	private HackyViewPager mViewPager;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		setContentView(R.layout.activity_brow_image_recorditem_unindefy);

		mItem =  (RecordItemSamp) getIntent().getSerializableExtra("record_type_item");
		if (mItem == null)return;
		mPhotos = mItem.getPhotos();

		mTitleText = (TextView) findViewById(R.id.tv_brow_takephoto_page);
		FrameLayout fl = (FrameLayout) findViewById(R.id.gallery_takephoto);
		mViewPager = new HackyViewPager(this);
		fl.addView(mViewPager);
		
		if(mPhotos == null||mPhotos.size()==0){
			GetImagePathLogic logic = new GetImagePathLogic(this);
			logic.getImagePath(mItem.getRecordItemId());
			mTitleText.setText("无法识别");
		}else{
			mAdapter = new SamplePagerAdapter();
			mViewPager.setAdapter(mAdapter);
			setTitle();
		}
		
		setTitle();
		
		mViewPager.setOnPageChangeListener(new OnPageChangeListener() {
			public void onPageSelected(int arg0) {}
			public void onPageScrolled(int arg0, float arg1, int arg2) {}
			public void onPageScrollStateChanged(int arg0) {
				setTitle();
			}
		});
	}

	private void setTitle() {
		if (mPhotos.size() < 1) {
			mTitleText.setText("无法识别");
		} else {
			int page = mViewPager.getCurrentItem()+1;
			mTitleText.setText("无法识别("+page + "/" + mPhotos.size()+")");
		}
	}

	public void onTopLeftBtnClick(View v) {
		super.onBackPressed();
	}

	public void onReCatch(View v) {
		if(mRemoveLogic == null){
			mRemoveLogic = new RemoveRecordItemLogic(this);
		}
		mRemoveLogic.removeRecordItem(mItem.getRecordItemId());
		
		Intent intent = new Intent(this, SnapPicActivity.class);
		intent.putExtra("itemType", mItem.getRecordType());
		startActivityForResult(intent, 100);
		finish();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		/*if(resultCode == SnapPicActivity.ON_PHOTO_SELECTED){
			for(int i = 0; i < mPhotos.size(); i++){
				OnePhoto photo = mPhotos.get(i);
				if(photo.indefyState == -2){
					photo.indefyState = 0;
				}
			}
			mAdapter.notifyDataSetChanged();
		}*/
	}
	
	public void onDelete(View v) {
		int position = mViewPager.getCurrentItem();//mImgGallery.getSelectedItemPosition() % mPhotos.size();
		mPhotos.remove(position);
		mAdapter.notifyDataSetChanged();
		if(mPhotos.size() <= 0){
			findViewById(R.id.rl_brow_photo_btn).setVisibility(View.GONE);
		}
		
		setTitle();
	}

	public class SamplePagerAdapter extends PagerAdapter {

		@Override
		public int getCount() {
			return mPhotos.size();
		}

		@Override
		public View instantiateItem(ViewGroup container, int position) {
			PhotoView photo = new PhotoView(BrowImageRecordActivity.this);
			
			PhotoRecord ph = mPhotos.get(position);
			String localPath = ph.getLocalPath();
			if(localPath != null){
				Bitmap bmp = BitmapManager.decodeSampledBitmapFromFile(ph.getLocalPath(), 2);
				photo.setImageBitmap(bmp);
			}else{
				photo.loadImageByPhoto(ph);
			}
			
			container.addView(photo);
			return photo;
		}

		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			container.removeView((View) object);
			object = null;
		}

		@Override
		public boolean isViewFromObject(View view, Object object) {
			return view == object;
		}
	}

	@Override
	public void doback(ArrayList<PhotoRecord> photos) {
		if(photos == null){
			UITools.showToast("没有可供浏览的图片");
			return;
		}
		mPhotos = photos;
		mAdapter = new SamplePagerAdapter();
		mViewPager.setAdapter(mAdapter);
		setTitle();
	}

	@Override
	public void doRemoveback(int recordItemId, boolean isSuccess) {
		
	}
}
