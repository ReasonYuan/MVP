package com.hp.android.halcyon;

import java.util.Calendar;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;

import com.fq.android.plus.R;
import com.hp.android.halcyon.wheel.NumericWheelAdapter;
import com.hp.android.halcyon.wheel.OnWheelChangedListener;
import com.hp.android.halcyon.wheel.OnWheelScrollListener;
import com.hp.android.halcyon.wheel.WheelView;

public class TimeActivity extends Activity {

	public static final int TIME_RESULT_CODE = 1017;
	public static final String EXRT_SELECT_TIME = "select_time";
	
	protected boolean timeChanged = false;
	private boolean timeScrolled = false;
	
	private NumericWheelAdapter mHourAdapter;
	private NumericWheelAdapter mMinAdapter;
	private ImageView mImageClose;
	private String mCurrentYear;
	private String mCurrentMonth;
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_select_time);
	
		mImageClose = (ImageView) findViewById(R.id.close);
		
		Calendar c = Calendar.getInstance();
		int month  = c.get(Calendar.MONTH);
		int year = c.get(Calendar.YEAR);
		
		final WheelView years = (WheelView) findViewById(R.id.year);
		mHourAdapter = new NumericWheelAdapter(1974, year);
		years.setAdapter(mHourAdapter);
		years.setTextLocation(40);
		years.setCyclic(true);
		years.setCurrentItem(year-1974); 
	
		final WheelView months = (WheelView) findViewById(R.id.month);
		mMinAdapter = new NumericWheelAdapter(1, 12, "%02d");
		months.setAdapter(mMinAdapter);
		months.setTextLocation(-40);
		months.setCyclic(true);
		months.setCurrentItem(month);
	
		// add listeners
		addChangingListener(months, "min");
		addChangingListener(years, "hour");
	
		OnWheelChangedListener wheelListener = new OnWheelChangedListener() {
			public void onChanged(WheelView wheel, int oldValue, int newValue) {
				if (!timeScrolled) {
					timeChanged = true;
					timeChanged = false;
				}
			}
		};

		years.addChangingListener(wheelListener);
		months.addChangingListener(wheelListener);

		OnWheelScrollListener scrollListener = new OnWheelScrollListener() {
			public void onScrollingStarted(WheelView wheel) {
				timeScrolled = true;
			}
			public void onScrollingFinished(WheelView wheel) {
				timeScrolled = false;
				timeChanged = true;
				timeChanged = false;
				mCurrentYear = mHourAdapter.getItem(years.getCurrentItem());
				mCurrentMonth = mMinAdapter.getItem(months.getCurrentItem());
			}
		};
		
		years.addScrollingListener(scrollListener);
		months.addScrollingListener(scrollListener);
		
		mImageClose.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				mCurrentYear = mHourAdapter.getItem(years.getCurrentItem());
				mCurrentMonth = mMinAdapter.getItem(months.getCurrentItem());
				
				Intent intent = new Intent();
				intent.putExtra(EXRT_SELECT_TIME, mCurrentYear+"-"+mCurrentMonth);
				setResult(TIME_RESULT_CODE, intent);
				finish();
				//Toast.makeText(TimeActivity.this, "--"+mCurrentYear+"--" +mCurrentMonth, Toast.LENGTH_SHORT).show();
			}
		});
	}

	/**
	 * Adds changing listener for wheel that updates the wheel label
	 * @param wheel the wheel
	 * @param label the wheel label
	 */
	private void addChangingListener(final WheelView wheel, final String label) {
		wheel.addChangingListener(new OnWheelChangedListener() {
			public void onChanged(WheelView wheel, int oldValue, int newValue) {
				wheel.setLabel(newValue != 1 ? label + "s" : label);
			}
		});
	}
}
