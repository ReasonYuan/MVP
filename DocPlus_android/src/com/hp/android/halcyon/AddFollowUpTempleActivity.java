package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.Calendar;

import android.annotation.SuppressLint;
import android.graphics.Color;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.FollowUpTemple;
import com.fq.halcyon.entity.OnceFollowUpCycle;
import com.fq.halcyon.logic2.OperateFollowUpTempleLogic;
import com.fq.halcyon.logic2.OperateFollowUpTempleLogic.OperateFollowUpTempleLogicInterface;
import com.fq.lib.json.JSONObject;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.wheel.ArrayWheelAdapter;
import com.hp.android.halcyon.wheel.NumericWheelAdapter;
import com.hp.android.halcyon.wheel.OnWheelChangedListener;
import com.hp.android.halcyon.wheel.OnWheelScrollListener;
import com.hp.android.halcyon.wheel.WheelView;
import com.hp.android.halcyon.widgets.CustomDialog;

@SuppressLint("NewApi")
public class AddFollowUpTempleActivity extends BaseActivity implements
		OnClickListener {
	private NumericWheelAdapter mYeasrAdapter;
	private ArrayWheelAdapter<String> mMonthAdapter;
	protected boolean timeChanged = false;
	private boolean timeScrolled = false;
	private String mCurrentYear;
	private String mCurrentMonth;
	private CustomDialog mCustomDialog;
	private WheelView years;
	private WheelView months;
	private Button mOk;
	private EditText mTempleNameEt;
	private FollowUpTemple mFollowUpTemple = new FollowUpTemple();
	private ArrayList<OnceFollowUpCycle> mList = new ArrayList<OnceFollowUpCycle>();
	private Button mLast;
	private Button mNext;
	private TextView mSelectWeeklyCount;
	private int mCurrentIndex = 1;
	private TextView mSettingTime;
	private OnceFollowUpCycle mCurrentOnceFollowUpCycle;
	private OnceFollowUpCycle mTmpOnceFollowUpCycle;
	private EditText mEditText;
	private Button mDeleteItem;
	private View mLine;
	private ImageView mLastImage;
	private Button mSave;
	
	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.ok:
			mCurrentYear = mYeasrAdapter.getItem(years.getCurrentItem());
			mCurrentMonth = mMonthAdapter.getItem(months.getCurrentItem());
			if (mCurrentIndex <= mList.size()) {
				mTmpOnceFollowUpCycle  = mList.get(mCurrentIndex-1);
				mTmpOnceFollowUpCycle.setmItentValue(mCurrentYear);
				mTmpOnceFollowUpCycle.setmItemUnit(mCurrentMonth);
			}
			if(mCurrentOnceFollowUpCycle.getmItentValue() == null || parseStrData(mCurrentOnceFollowUpCycle.getmItemUnit()) == null){
				mSettingTime.setText("距上次");
			}else{
				mSettingTime.setText("距上次"+ mCurrentOnceFollowUpCycle.getmItentValue() + parseStrData(mCurrentOnceFollowUpCycle.getmItemUnit()));
			}
//			mSettingTime.setText("距上次"+ mCurrentOnceFollowUpCycle.getmItentValue() + parseStrData(mCurrentOnceFollowUpCycle.getmItemUnit()));
			mCustomDialog.dismiss();
			break;
		case R.id.last:
			mCurrentIndex--;
			if (mCurrentIndex == 1) {
				mLast.setEnabled(false);
				mLast.setVisibility(View.INVISIBLE);
				mLastImage.setVisibility(View.INVISIBLE);
				mLine.setVisibility(View.INVISIBLE);
				mSettingTime.setTextColor(Color.GRAY);
				mSettingTime.setAlpha((float) 0.8);
			}
			updateUI();
			break;
		case R.id.next:
			mCurrentIndex++;
			if (mCurrentIndex > 1) {
				mLast.setEnabled(true);
				mLast.setVisibility(View.VISIBLE);
				mLastImage.setVisibility(View.VISIBLE);
				mLine.setVisibility(View.VISIBLE);
				mSettingTime.setTextColor(getResources().getColor(R.color.app_emerald));
			}
			
			if (mCurrentIndex == mList.size()+1) {
				OnceFollowUpCycle mCycle = new OnceFollowUpCycle();
				mCycle.setAtttributeByjson(new JSONObject());
				mCurrentOnceFollowUpCycle = mCycle;
				mList.add(mCycle);
				initTimeDialog();
			}
			updateUI();
			break;
		case R.id.setting_time:
			if (mCurrentIndex != 1) {
				initTimeDialog();
			}
			
			break;
		case R.id.delete_item:
			final CustomDialog dialog = new CustomDialog(AddFollowUpTempleActivity.this);
			View delView = LayoutInflater.from(AddFollowUpTempleActivity.this).inflate(R.layout.view_delete_item, null);
			dialog.setOnlyContainer(delView);
			dialog.setCanceledOnTouchOutside(false);
			TextView mTittle = (TextView) delView.findViewById(R.id.view_delete_item_title);
			mTittle.setText("确定删除?");
			Button btnSure = (Button) delView.findViewById(R.id.btn_delete_item_sure);
			Button btnCancel = (Button) delView.findViewById(R.id.btn_delete_item_cancel);
			btnSure.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					if (mCurrentIndex == 1) {
						UITools.showToast("首次随访不能删除");
					}else{
						mList.remove(mCurrentIndex-1);
						if (mCurrentIndex < mList.size() + 1) {
							
						}else{
							mCurrentIndex--;
							if (mCurrentIndex == 1) {
								mLast.setEnabled(false);
								mLast.setVisibility(View.INVISIBLE);
								mLastImage.setVisibility(View.INVISIBLE);
								mSettingTime.setTextColor(Color.GRAY);
								mSettingTime.setAlpha((float) 0.8);
							}
						}
						updateUI();
					}
					dialog.dismiss();
				}
			});
			
			btnCancel.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					dialog.dismiss();
				}
			});
		
			break;
		case R.id.btn_save:
			Log.e("保存", "保存");
			String str = mTempleNameEt.getText().toString().trim();
			if (str.equals("")) {
				UITools.showToast("请先填写模板名称");
				return;
			}else{
				mFollowUpTemple.setTempleName(str);
				mFollowUpTemple.setmArrayList(mList);
				OperateFollowUpTempleLogic mOperateFollowUpTempleLogic = new OperateFollowUpTempleLogic(new OperateFollowUpTempleLogicInterface() {
					
					@Override
					public void onError(int code, Throwable error) {
						UITools.showToast("新增模板失败");
					}
					
					@Override
					public void onDataReturn() {
						UITools.showToast("新增模板成功");
						finish();
					}
					
					@Override
					public void onDataError(int code, String msg) {
						UITools.showToast("新增模板失败");
					}
				}, mFollowUpTemple);
				mOperateFollowUpTempleLogic.CreateFollowUPTemple();
			}
			
			break;
		default:
			break;
		}

	}
	
	public void updateUI(){
		mEditText.setText("");
		mCurrentOnceFollowUpCycle = mList.get(mCurrentIndex-1);
		if (mCurrentIndex == 1) {
			mSettingTime.setText("首次随访时间");
		}else{
			if(mCurrentOnceFollowUpCycle.getmItentValue() == null || parseStrData(mCurrentOnceFollowUpCycle.getmItemUnit()) == null){
				mSettingTime.setText("距上次");
			}else{
				mSettingTime.setText("距上次"+ mCurrentOnceFollowUpCycle.getmItentValue() + parseStrData(mCurrentOnceFollowUpCycle.getmItemUnit()));
			}
//			mSettingTime.setText("距上次"+ mCurrentOnceFollowUpCycle.getmItentValue() + parseStrData(mCurrentOnceFollowUpCycle.getmItemUnit()));
		}
		
		mSelectWeeklyCount.setText(mCurrentIndex+"/"+ mList.size());
		mEditText.setText(mCurrentOnceFollowUpCycle.getmItemName());
	}
	
	public String parseStrData(String str){
		String tmp = null;
		if (str.equals("day")) {
			tmp = "天";
		}else if (str.equals("week")) {
			tmp = "周";
		}else if (str.equals("month")) {
			tmp = "月";
		}else if (str.equals("year")) {
			tmp = "年";
		}
		return tmp;
	}

	public long setTime(long time,String str,int addcount){
		Calendar mCalendar =Calendar.getInstance();
		mCalendar.setTimeInMillis(time);
		if (str.equals("天")) {
			mCalendar.add(Calendar.DAY_OF_MONTH, addcount);
		}else if (str.equals("周")) {
			mCalendar.add(Calendar.DAY_OF_MONTH, addcount*7);
		}else if (str.equals("月")) {
			mCalendar.add(Calendar.MONTH, addcount);
		}else if (str.equals("年")) {
			mCalendar.add(Calendar.YEAR, addcount);
		}
		return mCalendar.getTime().getTime();
	}
	
	@Override
	public int getContentId() {
		return R.layout.acitivity_add_follow_up_temple;
	}

	@Override
	public void init() {
		setTopLeftImgShow(true);
		setTitle("新增模板");
		initWidget();
		
	}

	public void initWidget() {
		mLastImage = (ImageView) findViewById(R.id.last_image);
		mLastImage.setVisibility(View.INVISIBLE);
		mLast = (Button) findViewById(R.id.last);
		mLast.setOnClickListener(this);
		mLast.setVisibility(View.INVISIBLE);
		mLast.setEnabled(false);
		
		mLine = findViewById(R.id.line);
		
		mSave = (Button) findViewById(R.id.btn_save);
		mSave.setOnClickListener(this);
		
		mNext = (Button) findViewById(R.id.next);
		mNext.setOnClickListener(this);
		
		mDeleteItem = (Button) findViewById(R.id.delete_item);
		mDeleteItem.setOnClickListener(this);
		
		mSettingTime = (TextView) findViewById(R.id.setting_time);
		mSettingTime.setOnClickListener(this);
		mTempleNameEt = (EditText) findViewById(R.id.temple_name_et);
		mSelectWeeklyCount = (TextView) findViewById(R.id.select_weekly_count);
		mSelectWeeklyCount.setText(mCurrentIndex+"/"+ 1);
		mEditText  = (EditText) findViewById(R.id.first_content);
		mEditText.addTextChangedListener(new TextWatcher() {
			
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				
			}
			
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				
			}
			
			@Override
			public void afterTextChanged(Editable s) {
				if (!s.toString().equals("")) {
					mList.get(mCurrentIndex-1).setmItemName(s.toString());
				}
			}
		});
		initFirstTimeFollowUp();
	}
	
	public void initFirstTimeFollowUp(){
		OnceFollowUpCycle mCycle = new OnceFollowUpCycle();
		mCycle.setAtttributeByjson(new JSONObject());
		mCurrentOnceFollowUpCycle = mCycle;
		mList.add(mCycle);
	}

	public void initTimeDialog() {

		mCustomDialog = new CustomDialog(this);
		mCustomDialog.setCanceledOnTouchOutside(false);
		View mView = LayoutInflater.from(this).inflate(
				R.layout.dialog_weekly_select_view, null);
		mOk = (Button) mView.findViewById(R.id.ok);
		mOk.setOnClickListener(this);
		mCustomDialog.setContainer(mView);

		years = (WheelView) mView.findViewById(R.id.year);
		mYeasrAdapter = new NumericWheelAdapter(1, 31);
		years.setAdapter(mYeasrAdapter);
		years.setVisibleItems(3);
		years.setCyclic(true);
		years.setCurrentItem(0);

		months = (WheelView) mView.findViewById(R.id.month);
		String items[] = { "天", "周", "月", "年" };
		mMonthAdapter = new ArrayWheelAdapter<String>(items, 4);
		months.setAdapter(mMonthAdapter);
		months.setVisibleItems(3);
		months.setCyclic(true);
		months.setCurrentItem(0);

		// add listeners
		addChangingListener(months, "");
		addChangingListener(years, "");

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
				mCurrentYear = mYeasrAdapter.getItem(years.getCurrentItem());
				mCurrentMonth = mMonthAdapter.getItem(months.getCurrentItem());
			}
		};

		years.addScrollingListener(scrollListener);
		months.addScrollingListener(scrollListener);

	}

	/**
	 * Adds changing listener for wheel that updates the wheel label
	 * 
	 * @param wheel
	 *            the wheel
	 * @param label
	 *            the wheel label
	 */
	private void addChangingListener(final WheelView wheel, final String label) {
		wheel.addChangingListener(new OnWheelChangedListener() {
			public void onChanged(WheelView wheel, int oldValue, int newValue) {
				wheel.setLabel(newValue != 1 ? label + "s" : label);
			}
		});
	}

}
