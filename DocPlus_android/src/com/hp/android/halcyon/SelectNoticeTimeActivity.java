package com.hp.android.halcyon;

import java.text.SimpleDateFormat;
import java.util.Date;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.hp.android.halcyon.util.UITools;
import com.hp.halcyon.widgets.main.DateViewGroup.OnChangeListener;
import com.hp.halcyon.widgets.main.SelectNoticeTimeView;


public class SelectNoticeTimeActivity extends Activity implements OnChangeListener {

	public static final int SELECT_TIME_SUCCESS = 0xf2;
	
	private SelectNoticeTimeView mTimePicker;
	
	private TextView mDateTextView;
	
	private SimpleDateFormat mDateFormat;
	
	@Override
	protected void onCreate(Bundle savedInstansceState) {
		super.onCreate(savedInstansceState);
		setContentView( R.layout.activity_select_notice_time);
		mDateFormat = new SimpleDateFormat("yyyy年MM月dd日  HH:mm");
		mTimePicker = (SelectNoticeTimeView) findViewById(R.id.snt_time);
		mTimePicker.setOnChangeListener(this);
		mDateTextView = (TextView) findViewById(R.id.tx_date);
		mDateTextView.setText(mDateFormat.format(new Date()));
		initWidgets();
	}
	
	/**
	 *初始化控件 
	 */
	private void initWidgets() {
//		Typeface mFont = Typeface.createFromAsset(getAssets(),
//				"lantingchuheijian.TTF");
//		((TextView) findViewById(R.id.tv_select_notice_time_title)).setTextColor(Color
//				.parseColor("#535353"));
//		((TextView) findViewById(R.id.tv_select_notice_time_title)).setTypeface(mFont);
	}

	@Override
	public void onDateChanged() {
		mDateTextView.setText(mDateFormat.format(mTimePicker.getSelectDate()));
	}

	public void sure(View v){
		Date date = mTimePicker.getSelectDate();
		if(date.getTime() < System.currentTimeMillis()){
			UITools.showToast("时间已过期，请重设");
			return;
		}
		Intent intent = new Intent();
		intent.putExtra("date",date);
		setResult(SELECT_TIME_SUCCESS, intent);
		finish();
	}
	
	public void cancle(View v){
		onBackPressed();
	}
	
}
