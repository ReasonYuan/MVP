package com.hp.android.halcyon;

import java.util.ArrayList;

import com.fq.android.plus.R;
import com.hp.android.halcyon.wheel2.ArrayWheelAdapter;
import com.hp.android.halcyon.wheel2.WheelView;


public class SelectActivity extends BaseActivity {
	
	protected WheelView mWheelView;
	
	protected ArrayList<String> mValues;
	
	protected ArrayWheelAdapter<String> mWheelAdapter;
	
	@Override
	public int getContentId() {
		return R.layout.activity_select_value;
	}

	@Override
	public void init() {
		mWheelView = (WheelView) findViewById(R.id.context_whell_view);
		if(mValues == null) return;
		String[] items = (String[]) mValues.toArray();
		mWheelAdapter = new ArrayWheelAdapter<String>(this,items);
		mWheelView.setViewAdapter(mWheelAdapter);
		mWheelView.setCyclic(true);
		mWheelView.setCurrentItem(0);
	}
	
	public void setWheelCyclie(boolean isCyclie){
		mWheelView.setCyclic(isCyclie);
	}
	
	public void setWheelCurrenItem(int curren){
		mWheelView.setCurrentItem(curren);
	}
}
