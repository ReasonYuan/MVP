package com.hp.android.halcyon;

import java.util.ArrayList;

import uk.co.senab.photoview.HackyViewPager;
import android.app.Activity;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.logic.GetImagePathLogic;
import com.fq.halcyon.logic.GetImagePathLogic.ImagePathCallBack;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.PhotoView;

public class BrowImageActivity extends Activity implements ImagePathCallBack{

	private ArrayList<PhotoRecord> mPhotos;
	
	private TextView mTitleText;
	private String mTitle;
	private HackyViewPager mViewPager;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		mTitle = getIntent().getStringExtra("image_title");
		if(mTitle == null)mTitle="";
		mPhotos =  (ArrayList<PhotoRecord>)getIntent().getSerializableExtra("photo_array");

		setContentView(R.layout.activity_brow_image);
		mTitleText = (TextView) findViewById(R.id.tv_brow_takephoto_page);
		FrameLayout fl = (FrameLayout) findViewById(R.id.hvp_takephoto);
		mViewPager = new HackyViewPager(this);
		fl.addView(mViewPager);
		
		if(mPhotos == null){
//			mPhotos = new ArrayList<PhotoRecord>();
			int itemId = getIntent().getIntExtra("record_item_id", 0);
			if(itemId != 0){
				GetImagePathLogic logic = new GetImagePathLogic(this);
				logic.getImagePath(itemId);
			}
			mTitleText.setText(mTitle);
		}else{
			mViewPager.setAdapter(new SamplePagerAdapter());
			setTitle();
		}
		
		mViewPager.setOnPageChangeListener(new OnPageChangeListener() {
			public void onPageSelected(int arg0) {}
			public void onPageScrolled(int arg0, float arg1, int arg2) {}
			public void onPageScrollStateChanged(int arg0) {
				setTitle();
			}
		});
	}
	
	private void setTitle(){
		if(mPhotos.size() < 1){
			mTitleText.setText(mTitle);
		}else{
			int page = mViewPager.getCurrentItem()+1;
			mTitleText.setText(mTitle+"("+page+"/"+mPhotos.size()+")");
		}
	}
	
	public void onTopLeftBtnClick(View v){
		super.onBackPressed();
	}
	
	public class SamplePagerAdapter extends PagerAdapter {

		@Override
		public int getCount() {
			return mPhotos.size();
		}

		@Override
		public View instantiateItem(ViewGroup container, int position) {
			PhotoView photo = new PhotoView(BrowImageActivity.this);
			
			PhotoRecord ph = mPhotos.get(position);
			String localPath = ph.getLocalPath();
			if(localPath != null){
				photo.loadImageByLocalPath(localPath,2);
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
		mViewPager.setAdapter(new SamplePagerAdapter());
//		mAdapter.notifyDataSetChanged();
		setTitle();
	}
}
