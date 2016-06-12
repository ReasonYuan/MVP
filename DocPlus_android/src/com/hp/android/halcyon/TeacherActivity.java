package com.hp.android.halcyon;

import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.fq.android.plus.R;
import com.fq.lib.tools.BaiduAnalysis;
import com.hp.android.halcyon.util.BaiDuTJSDk;
import com.hp.android.halcyon.util.BitmapManager;

public class TeacherActivity extends Activity{

	private int[] mImageIds = {R.drawable.teacher_0,R.drawable.teacher_1,R.drawable.teacher_2,R.drawable.teacher_3,
			R.drawable.teacher_4,R.drawable.teacher_5,R.drawable.teacher_6,R.drawable.teacher_7,
			R.drawable.teacher_8,R.drawable.teacher_9,R.drawable.teacher_10,R.drawable.teacher_11,
			R.drawable.teacher_12,R.drawable.teacher_13,R.drawable.teacher_14,R.drawable.teacher_15,
			R.drawable.teacher_16,R.drawable.teacher_17,R.drawable.teacher_18,R.drawable.teacher_19,
			R.drawable.teacher_20,R.drawable.teacher_21,};

	private ViewPager mViewPager;
	
	private long mStayTime;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_teacher);
		
		mViewPager = (ViewPager) findViewById(R.id.vp_teacher_page);
		mViewPager.setAdapter(new TeacherAdapter());
		
		mStayTime = System.currentTimeMillis();
	}

	@Override
	protected void onResume() {
		super.onResume();
		BaiDuTJSDk.onResume(this);
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		BaiDuTJSDk.onPause(this);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		BaiDuTJSDk.onEventDuration(BaiduAnalysis.TIME_DOCTOR_CUIDE, BaiduAnalysis.LABEL_NULL, System.currentTimeMillis() - mStayTime);
	}
	
	class TeacherAdapter extends PagerAdapter{

		@Override
		public int getCount() {
			return mImageIds.length;
		}

		@Override
		public boolean isViewFromObject(View arg0, Object arg1) {
			return arg0 == arg1;
		}
		
		@Override
		public Object instantiateItem(ViewGroup container, int position) {
			View v = LayoutInflater.from(TeacherActivity.this).inflate(R.layout.view_teacher_layout, null);
			ImageView img = (ImageView) v.findViewById(R.id.im_teacher_item);
			Bitmap bmp = BitmapManager.decodeSampledBitmapFromFile(mImageIds[position], 2);
			img.setImageBitmap(bmp);
			
			container.addView(v);
			return v;
		}
		
		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			View v = (View) object;
			container.removeView(v);
			v = null;
		}
	}
}
