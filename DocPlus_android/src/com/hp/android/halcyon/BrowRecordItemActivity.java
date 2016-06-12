package com.hp.android.halcyon;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.BaiduAnalysis;
import com.hp.android.halcyon.adapter.RecordPagerAdapter;
import com.hp.android.halcyon.util.BaiDuTJSDk;

public class BrowRecordItemActivity extends Activity {
	public static final int INTENT_REQ_IMAGE = 220;//到浏览图片界面
	
	private ViewPager mViewPager;
	private RecordPagerAdapter mPagerAdapter;
	private ArrayList<RecordItemSamp> mRecItemList;

	/**是不是查看分享模式*/
	private boolean isShareModel;
	private int mRecordId;
	
	
//	private int mIndex = -1;
	
	/**浏览界面开始时间，用于百度统计分析用户该界面用时*/
	private long activitiStartTime;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_brow_recorditem_detail);

		mRecordId = getIntent().getIntExtra("record_id", 0);
		mRecItemList = (ArrayList<RecordItemSamp>) getIntent().getSerializableExtra("record_type_item");
		int position = getIntent().getIntExtra("clickPosition", 0);
		setTitle(RecordConstants.getTypeNameByRecordType(mRecItemList.get(position).getRecordType()));

		isShareModel = getIntent().getBooleanExtra("isOnlyInfo", false);
		
		mViewPager = (ViewPager) findViewById(R.id.vp_brow_recordItem_content);
		mPagerAdapter = new RecordPagerAdapter(this, mRecItemList, mViewPager);
		mViewPager.setAdapter(mPagerAdapter);
		mViewPager.setCurrentItem(position);

		activitiStartTime = System.currentTimeMillis();
		BaiDuTJSDk.onEvent(BaiduAnalysis.EVENT_BROW_RECORDITEM, BaiduAnalysis.LABEL_NULL);
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
		long time = System.currentTimeMillis() - activitiStartTime;
		BaiDuTJSDk.onEventDuration(BaiduAnalysis.EVENT_BROW_RECORDITEM, BaiduAnalysis.LABEL_NULL,time);
	}
	
	
	public int getRecordId(){
		return mRecordId;
	}
	
	public void setViewPagerScroll(boolean isb) {
		mViewPager.requestDisallowInterceptTouchEvent(!isb);
	}
	
	public boolean isShareModel(){
		return isShareModel;
	}
	
	@Override
	public void onBackPressed() {
		mPagerAdapter.getCurrentView(mViewPager.getCurrentItem()).onBack();
		/*if (mPagerAdapter.getCurrentView(mViewPager.getCurrentItem()).isShowBaseInfo()) {
			mPagerAdapter.getCurrentView(mViewPager.getCurrentItem()).dismissBaseInfo();
			return;
		}
		if(!mPagerAdapter.getCurrentView(mViewPager.getCurrentItem()).isEdit()){
			super.onBackPressed();
		}*/
	}
	
	public ArrayList<RecordItemSamp> getItemSamps(){
		return mRecItemList;
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(requestCode == INTENT_REQ_IMAGE && resultCode == 233){
			int recordInfoId = data.getIntExtra("record_info_id", 0);
			int current = mViewPager.getCurrentItem() ;
			for(int i = 0; i < mRecItemList.size(); i++){
				RecordItemSamp samp = mRecItemList.get(i);
				if(samp.getRecordInfoId() == recordInfoId){
					if(current != i){
						mViewPager.setCurrentItem(i, false);
					}
				}
			}
		}
	}
}
