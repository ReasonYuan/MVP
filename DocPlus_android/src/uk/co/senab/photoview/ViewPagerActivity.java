/*******************************************************************************
 * Copyright 2011, 2012 Chris Banes.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/
package uk.co.senab.photoview;

import java.util.ArrayList;

import android.content.Intent;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.PhotoRecord;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.widgets.PhotoView;

public class ViewPagerActivity extends BaseActivity {

	private ViewPager mViewPager;

	private ArrayList<PhotoRecord> mPhotos;
	
	private String mTitle;
	@Override
	public int getContentId() {
		return 0;
	}

	@Override
	public void init() {
		mTitle = "查看原图";//getIntent().getStringExtra("image_title");
		setTitle(mTitle);
		
		mViewPager = new HackyViewPager(this);
		mContainer.addView(mViewPager);

//		int recordId = getIntent().getIntExtra("record_id", -1);
//		new GetImagePathLogic().getRecordImages(recordId, this);
		
		mViewPager.setOnPageChangeListener(new OnPageChangeListener() {
			public void onPageSelected(int arg0) {}
			public void onPageScrolled(int arg0, float arg1, int arg2) {}
			@Override
			public void onPageScrollStateChanged(int arg0) {
				setTitle(mViewPager.getCurrentItem());
			}
		});
		
		mPhotos = (ArrayList<PhotoRecord>) getIntent().getSerializableExtra("record_images");
		if(mPhotos != null){
			int index = 0;
			int imgId = getIntent().getIntExtra("iamge_id", -1);
			int recordInfoId = getIntent().getIntExtra("record_info_id", -1);
			for(int i = 0; i < mPhotos.size(); i++){
				PhotoRecord photo = mPhotos.get(i);
				if(photo.isShared()){
					if(recordInfoId == photo.getRecordInfoId()){
						index = i;
						break;
					}
				}else if(imgId == photo.getImageId()){
					index = i;
					break;
				}
			}
			if(mPhotos.size() > 0)setTitle(index);
			mViewPager.setAdapter(new SamplePagerAdapter());
			mViewPager.setCurrentItem(index);
		}
	}

	public void setTitle(int option){
		setTitle(mTitle+"("+(option+1)+"/"+mPhotos.size()+")");
	}
	
	@Override
	public void onBackPressed() {
		if(mPhotos != null && mPhotos.size() > 0){
			int id = mViewPager.getCurrentItem();
			Intent intent = new Intent();
			intent.putExtra("record_info_id", mPhotos.get(mViewPager.getCurrentItem()).getRecordInfoId());
			setResult(233,intent);
		}
		super.onBackPressed();
	}
	
	public class SamplePagerAdapter extends PagerAdapter {

		@Override
		public int getCount() {
			return mPhotos.size();
		}

		@Override
		public View instantiateItem(ViewGroup container, int position) {
			PhotoRecord po = mPhotos.get(position);
			View view = null;
			if(po.isShared()){
				view = LayoutInflater.from(ViewPagerActivity.this).inflate(R.layout.view_record_item_share_image, null);
			}else{
				PhotoView photo = new PhotoView(ViewPagerActivity.this);
				photo.loadImageByPhoto(mPhotos.get(position),false,1);
				view = photo;
			}
			
			container.addView(view);
			return view;
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

	/*@Override
	public void callRecrodImages(ArrayList<PhotoRecord> photos) {
		mPhotos = photos;
		int index = 0;
		int imgId = getIntent().getIntExtra("iamge_id", -1);
		int recordInfoId = getIntent().getIntExtra("record_info_id", -1);
		for(int i = 0; i < mPhotos.size(); i++){
			PhotoRecord photo = mPhotos.get(i);
			if(photo.isShared()){
				if(recordInfoId == photo.getRecordInfoId()){
					index = i;
					break;
				}
			}else if(imgId == photo.getImageId()){
				index = i;
				break;
			}
		}
		if(mPhotos.size() > 0)setTitle(index);
		mViewPager.setAdapter(new SamplePagerAdapter());
		mViewPager.setCurrentItem(index);
	}*/
}
