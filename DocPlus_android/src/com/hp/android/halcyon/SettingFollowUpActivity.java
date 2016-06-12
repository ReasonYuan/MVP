package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.regex.Pattern;

import android.content.Intent;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.AlarmClock;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.FollowUp;
import com.fq.halcyon.entity.FollowUpTemple;
import com.fq.halcyon.entity.OnceFollowUpCycle;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic2.AddOneFollowUpLogic;
import com.fq.halcyon.logic2.AddOneFollowUpLogic.AddOneFollowUpLogicInterface;
import com.fq.halcyon.logic2.SearchFollowUpDetailLogic;
import com.fq.halcyon.logic2.SearchFollowUpDetailLogic.SearchFollowUpDetailLogicInterface;
import com.fq.halcyon.logic2.SearchFollowUpTempleDetailLogic;
import com.fq.halcyon.logic2.SearchFollowUpTempleDetailLogic.SearchFollowUpTempleDetailLogicInterface;
import com.fq.lib.callback.ICallback;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.TimeFormatUtils;
import com.hp.android.halcyon.util.MessageStruct;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.wheel.NumericWheelAdapter;
import com.hp.android.halcyon.wheel.OnWheelChangedListener;
import com.hp.android.halcyon.wheel.OnWheelScrollListener;
import com.hp.android.halcyon.wheel.WheelView;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

public class SettingFollowUpActivity extends BaseActivity implements OnClickListener{

	private TextView mTime;
	private EditText mMessage;
	private Button mFabu;
	private NumericWheelAdapter mYeasrAdapter;
	private NumericWheelAdapter mMonthAdapter;
	private NumericWheelAdapter mDayAdapter;
	protected boolean timeChanged = false;
	private boolean timeScrolled = false;
	private String mCurrentYear;
	private String mCurrentMonth;
	private String mCurrentDay;
	private Button mOk;
	private CustomDialog mCustomDialog;
	private WheelView years;
	private WheelView months;
	private WheelView days;
	private Contacts mPatient;
	private FollowUpTemple mFollowUpTemple;
	private TextView mModifyFollowUpBtn;
	private Button mModifyTimeBtn;
	private ImageView mFriendHead;
	private ArrayList<OnceFollowUpCycle> mCycles = new ArrayList<OnceFollowUpCycle>();
	private ArrayList<Contacts> mPatientList = new ArrayList<Contacts>();
	private FollowUp mCurrentFollowUp;
	private HashMap<Integer, Long> mTimerHashMap;
	private AlarmClock mAlarmClock;
	private LinearLayout mModifyFollowUp;
	private LinearLayout mModifyFollowUpTime;
	private TextView mPatientName;
	/**
	 * 当前随访
	 */
	private FollowUp mFollowUp = new FollowUp();
	
	/**
	 * 过滤输入法有表情的正则表达式
	 */
	private final String reg ="^([a-z]|[A-Z]|[0-9]|[\u2E80-\u9FFF]){3,}|@(?:[\\w](?:[\\w-]*[\\w])?\\.)+[\\w](?:[\\w-]*[\\w])?|[wap.]{4}|[www.]{4}|[blog.]{5}|[bbs.]{4}|[.com]{4}|[.cn]{3}|[.net]{4}|[.org]{4}|[http://]{7}|[ftp://]{6}$";
	
	private Pattern pattern = Pattern.compile(reg);
	 //输入表情前的光标位置
	 private int cursorPos;
	 //输入表情前EditText中的文本
	 private String tmp;
	 //是否重置了EditText的内容
	 private boolean resetText = false;
	 
	@Override
	public int getContentId() {
		return R.layout.activity_setting_follow_up;
	}

	@Override
	public void init() {
		setTopLeftBtnShow(true);
		mPatient = (Contacts) getIntent().getExtras().get("Patient");
		mFollowUpTemple =  (FollowUpTemple) getIntent().getExtras().get("mFollowUpTemple");
		getData();
		initWidget();
		initListener();
		
	}
	
	public void initWidget(){
		mTime = (TextView) findViewById(R.id.time);
		mMessage = (EditText) findViewById(R.id.message);
		mFabu = (Button) findViewById(R.id.fabu);
		mModifyFollowUpBtn = (TextView) findViewById(R.id.follow_up_modify_btn);
		mModifyFollowUp = (LinearLayout) findViewById(R.id.linearlayout_modify_follow_up);
		mModifyFollowUp.setOnClickListener(this);
		mModifyFollowUpBtn.setOnClickListener(this);
		mModifyFollowUpBtn.setText(mFollowUpTemple.getTempleName());
		
		mModifyFollowUpTime = (LinearLayout) findViewById(R.id.linearlayout_mofify_time);
		mModifyFollowUpTime.setOnClickListener(this);
		
		mModifyTimeBtn = (Button) findViewById(R.id.time_modify_btn);
		mModifyTimeBtn.setOnClickListener(this);
		mModifyTimeBtn.setText(TimeFormatUtils.getTimeByFormat(System.currentTimeMillis(), "yyyy-MM-dd"));
		
		mFriendHead = (ImageView) findViewById(R.id.friend_head);
		mFriendHead.setOnClickListener(this);
		int mImageId = 0;
		
		//==YY==imageId(只要imageId)
//		if (mPatient.getHeadPicImageId() != 0) {
//			mImageId = mPatient.getHeadPicImageId();
//		}else if (mPatient.getImageId() != 0) {
//			mImageId = mPatient.getImageId();
//		}		
		mImageId = mPatient.getImageId();
		
		ApiSystem.getInstance().getHeadImage(new Photo(mImageId, ""), new ICallback() {
			
			@Override
			public void doCallback(Object obj) {
				mFriendHead.setImageBitmap(UITools.getBitmapWithPath(""+obj));
			}
		}, false, 2);
		
		mMessage.addTextChangedListener(new TextWatcher() {
			
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				if(!resetText){
					    if(count >=2){//表情符号的字符长度最小为3
					     //提取输入的长度大于3的文本
					     CharSequence input = s.subSequence(cursorPos, s.length());
					     //正则匹配是否是表情符号
//					     Matcher matcher = pattern.matcher(input.toString());
					 boolean mIs =  containsEmoji(input.toString());
//						     if(!matcher.matches()){
						     if(mIs){
							      resetText = true;
							      //是表情符号就将文本还原为输入表情符号之前的内容
							      mMessage.setText(tmp);
							      mMessage.invalidate();
						      }
					    }
				   }else{
					   	resetText = false;
				   }
			}
			
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				 if(!resetText){
					    cursorPos = mMessage.getSelectionEnd();
					    tmp = s.toString();//这里用s.toString()而不直接用s是因为如果用s，那么，tmp和s在内存中指向的是同一个地址，s改变了，tmp也就改变了，那么表情过滤就失败了
					   }
			}
			
			@Override
			public void afterTextChanged(Editable s) {
				if (s.toString()!= null && !s.toString().equals("")) {
					mFollowUp.setmTips(s.toString());
				}
			}
		});
		
		mPatientList.add(mPatient);
		mFollowUp.setmFriendsList(mPatientList);
		
		mPatientName = (TextView) findViewById(R.id.patient_name);
		mPatientName.setText(mPatient.getName());
	}
	
	/** * 检测是否有emoji表情
	 * 
	 *  * @param source
	 *  * @return 
	 *  */ 
	public static boolean containsEmoji(String source) {
		int len = source.length();
		for (int i = 0; i < len; i++) {
			char codePoint = source.charAt(i);
			if (!isEmojiCharacter(codePoint)) {
				//如果不能匹配,则该字符是Emoji表情 
				return true;
				} 
			} 
		return false;
	}
	
	/**
	 * * 判断是否是Emoji *
	 *  @param codePoint 比较的单个字符 * 
	 *  @return
	 */
	private static boolean isEmojiCharacter(char codePoint) {
		return (codePoint == 0x0) || (codePoint == 0x9) || (codePoint == 0xA)
				|| (codePoint == 0xD)
				|| ((codePoint >= 0x20) && (codePoint <= 0xD7FF))
				|| ((codePoint >= 0xE000) && (codePoint <= 0xFFFD))
				|| ((codePoint >= 0x10000) && (codePoint <= 0x10FFFF));
	}

	public void initListener(){
		mTime.setOnClickListener(this);
		mFabu.setOnClickListener(this);
	}
	
	/**
	 * 获取模板详细内容
	 */
	public void getData(){
		SearchFollowUpTempleDetailLogic mDetailLogic = new SearchFollowUpTempleDetailLogic(new SearchFollowUpTempleDetailLogicInterface() {
			
			@Override
			public void onError(int code, Throwable error) {
				UITools.showToast("获取数据失败！");
			}
			
			@Override
			public void onSearchSuccess(FollowUpTemple followUpTemple) {
				mFollowUpTemple = followUpTemple;
				mCycles = mFollowUpTemple.getmArrayList();
				mCycles.get(0).setmTimerDate(TimeFormatUtils.getTimeByFormat(System.currentTimeMillis(), "yyyy-MM-dd"));
				mFollowUp.setmFolloUpTempleName(mFollowUpTemple.getTempleName());
				mFollowUp.setmDoctorId(Constants.getUser().getUserId());
			}
			
			@Override
			public void onSearchError(int errCode, String msg) {
				UITools.showToast("获取数据失败！");
			}
		}, mFollowUpTemple.getmTempleId());
		   mDetailLogic.getTempleDetail();
	}
	
	/**
	 * 计算所有随访的随访时间
	 * @param mCycles
	 * @return
	 */
	public ArrayList<OnceFollowUpCycle> calculationAllTime(ArrayList<OnceFollowUpCycle> mCycles){
		mCycles.get(0).setmTimerDate(mModifyTimeBtn.getText().toString().trim());
		for (int i = 0; i < mCycles.size()-1; i++) {
			OnceFollowUpCycle mCurrentCycle = mCycles.get(i);
			OnceFollowUpCycle mNextCycle = mCycles.get(i+1);
			if (!mNextCycle.getmItentValue().equals("") &&  !mNextCycle.getmItemUnit().equals("")) {
				String date = calculationNextTime(mCurrentCycle.getmTimerDate(), Integer.parseInt(mNextCycle.getmItentValue()), mNextCycle.getmItemUnit());
				mCycles.get(i+1).setmTimerDate(date);
				System.out.println("time_date~~~~~~~~~"+date);
			}
		}
		return mCycles;
	}
	
	/**
	 * 计算下一次随访的随访时间
	 * @param mTmpDate 上一次随访的时间
	 * @param addCount 时间大小
	 * @param mUnit  时间单位
	 * @return
	 */
	public String calculationNextTime(String mTmpDate,int addCount,String mUnit){
		long time = TimeFormatUtils.getTimeMillisByDate(mTmpDate);
		String date = setTime(time, mUnit, addCount);
		return date;
	}
	
	
	/**
	 * 设置计算闹钟时间
	 * @param time
	 * @param str
	 * @param addcount
	 * @return
	 */
	public String setTime(long time,String str,int addcount){
		Calendar mCalendar = Calendar.getInstance();
		mCalendar.setTimeInMillis(time);
		if (str.equals("day")) {
			mCalendar.add(Calendar.DAY_OF_MONTH, addcount);
		}else if (str.equals("week")) {
			mCalendar.add(Calendar.DAY_OF_MONTH, addcount*7);
		}else if (str.equals("month")) {
			mCalendar.add(Calendar.MONTH, addcount);
		}else if (str.equals("year")) {
			mCalendar.add(Calendar.YEAR, addcount);
		}
		
		String date = TimeFormatUtils.getTimeByFormat(mCalendar.getTime().getTime(), "yyyy-MM-dd");
		return date;
	}
	
	/**
	 * 计算每次闹钟的时间 返回类型为long
	 * @param time
	 * @return
	 */
	public long calculationOnceAlarmLongTime(long time){
		Calendar mCalendar = Calendar.getInstance();
		mCalendar.setTimeInMillis(time);
		mCalendar.add(Calendar.HOUR_OF_DAY, -12);
		long mTime = mCalendar.getTime().getTime();
		String date = TimeFormatUtils.getTimeByFormat(mTime, "yyyy-MM-dd HH:mm:ss");
		return mTime;
	}
	
	/**
	 * 计算闹钟提醒列表
	 * @param mCycles
	 * @return 
	 */
	public void calculationAlarmLongTime(ArrayList<OnceFollowUpCycle> mCycles,int mTimerId){
		getDetail(mCycles,mTimerId);
	}
	
	public void addFollowUp(){
		final CustomProgressDialog mCustomProgressDialog = new CustomProgressDialog(SettingFollowUpActivity.this);
		ArrayList<OnceFollowUpCycle> mTmpCycle =  calculationAllTime(mCycles);
		mFollowUp.setmFollowUpItemsList(mTmpCycle);
		AddOneFollowUpLogic mAddOneFollowUpLogic = new AddOneFollowUpLogic(new AddOneFollowUpLogicInterface() {
			
			@Override
			public void onError(int code, Throwable error) {
				UITools.showToast("设置随访失败");
				mCustomProgressDialog.dismiss();
			}
			
			@Override
			public void onAddSuccess(int timerId) {
				mCustomProgressDialog.dismiss();
				calculationAlarmLongTime(mCycles,timerId);
				
			}
			
			@Override
			public void onAddError(int code, String msg) {
				mCustomProgressDialog.dismiss();
				UITools.showToast("设置随访失败");
			}
		}, mFollowUp);
		mAddOneFollowUpLogic.addFollowUp();
	}
	
	public void getDetail(final ArrayList<OnceFollowUpCycle> mCycles ,final int mTimerId){
		mTimerHashMap = new HashMap<Integer, Long>();
		SearchFollowUpDetailLogic mDetailLogic = new SearchFollowUpDetailLogic(new SearchFollowUpDetailLogicInterface() {
			
			@Override
			public void onError(int code, Throwable error) {
				UITools.showToast("获取数据失败！");
			}
			
			@Override
			public void onSearchSuccess(FollowUp mFollowUp) {
				mCurrentFollowUp = mFollowUp;
				ArrayList<OnceFollowUpCycle> mTmpCycles =   mCurrentFollowUp.getmFollowUpItemsList();
				ArrayList<Long> mTimerList = new ArrayList<Long>();
				for (int i = 0; i < mCycles.size(); i++) {
					OnceFollowUpCycle mCycle = mCycles.get(i);
					int mItemId = mTmpCycles.get(i).getmItemtId();
					long time = TimeFormatUtils.getTimeMillisByDate(mCycle.getmTimerDate());
					long alarmTiem = calculationOnceAlarmLongTime(time);
					mTimerList.add(alarmTiem);
					mTimerHashMap.put(mItemId, alarmTiem);
				}
				mAlarmClock = new AlarmClock();
				mAlarmClock.setTimerList(mTimerList);
				mAlarmClock.setUserId(mPatient.getUserId());
				mAlarmClock.setTimerId(mTimerId);
				mAlarmClock.setmTimeHashMap(mTimerHashMap);
				sendMessage();
				Intent intent = new Intent();
				intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
				intent.setClass(SettingFollowUpActivity.this, HomeActivity.class);
				startActivity(intent);
				finish();
			}
			
			@Override
			public void onSearchError(int code, String msg) {
				UITools.showToast("获取数据失败！");
			}
		});
		mDetailLogic.searchFollowUpDetail(mTimerId);
	}
	
	/**
	 * 通知病人客户端设置随访的闹钟
	 */
	public void sendMessage(){
		JSONObject mJsonObject = new JSONObject();
		Iterator mIterator  = mTimerHashMap.keySet().iterator();
		while (mIterator.hasNext()) {
			int itemId = (Integer) mIterator.next();
			try {
				mJsonObject.put(String.valueOf(itemId), mTimerHashMap.get(itemId)/1000);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		HalcyonApplication.getInstance().sendMessage(MessageStruct.MESSAGE_TYPE_NEW_FOLLOW_UP, "新的随访", mPatient.getUserId(),mJsonObject);
	}
	
	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.follow_up_modify_btn:
			Log.e("标题", "标题");
			Intent mIntent = new Intent();
			mIntent.putExtra("mFollowUpTempleId", mFollowUpTemple.getmTempleId());
			mIntent.putExtra("IsFromSendFollowUp", true);
			mIntent.setClass(this, ModifyFollowUpTempleAcitivity.class);
			startActivityForResult(mIntent, 1);
			break;
		case R.id.time_modify_btn:
			Log.e("首次随访时间", "首次随访时间");
			initTimeDialog();
			break;
		case R.id.fabu:
			Log.e("发布", "发布");
			addFollowUp();
			break;
		case R.id.ok:
			Log.e("完成", "完成");
			mCurrentYear = mYeasrAdapter.getItem(years.getCurrentItem());
			mCurrentMonth = mMonthAdapter.getItem(months.getCurrentItem());
			mCurrentDay = mDayAdapter.getItem(days.getCurrentItem());
			String date  = mCurrentYear +"-" + mCurrentMonth +"-" + mCurrentDay;
			mModifyTimeBtn.setText(date);
			mCustomDialog.dismiss();
			break;
		case R.id.friend_head:
			Intent mIntent1 = new Intent();
			mIntent1.putExtra("patient_friend_id", mPatient.getUserId());
			mIntent1.setClass(SettingFollowUpActivity.this, PatientDetailActivity.class);
			startActivity(mIntent1);
			break;
		default:
			break;
		}
	}
	
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode == RESULT_OK) {
			mFollowUpTemple = (FollowUpTemple) data.getExtras().get("mCurrentTemple");
			mCycles = mFollowUpTemple.getmArrayList();
		}
		
	}
	
	public void initTimeDialog(){

		mCustomDialog = new CustomDialog(this);
//		mCustomDialog.setCanceledOnTouchOutside(false);
		View mView = LayoutInflater.from(this).inflate(R.layout.dialog_time_select_view, null);
		mOk = (Button) mView.findViewById(R.id.ok);
		mOk.setOnClickListener(this);
		mCustomDialog.setOnlyContainer(mView);
		
		Calendar c = Calendar.getInstance();
		int month  = c.get(Calendar.MONTH);
		int year = c.get(Calendar.YEAR);
		int day = c.get(Calendar.DAY_OF_MONTH);
		
		years = (WheelView) mView.findViewById(R.id.year);
		mYeasrAdapter = new NumericWheelAdapter(1974, year);
		years.setAdapter(mYeasrAdapter);
		years.setVisibleItems(3);
		years.setCyclic(true);
		years.setCurrentItem(year-1974); 
	
		months = (WheelView) mView.findViewById(R.id.month);
		mMonthAdapter = new NumericWheelAdapter(1, 12, "%02d");
		months.setVisibleItems(3);
		months.setAdapter(mMonthAdapter);
		months.setCyclic(true);
		months.setCurrentItem(month);
	
		days = (WheelView) mView.findViewById(R.id.day);
		mDayAdapter = new NumericWheelAdapter(1, 31, "%02d");
		days.setVisibleItems(3);
		days.setAdapter(mDayAdapter);
		days.setCyclic(true);
		days.setCurrentItem(day);
		// add listeners
		addChangingListener(months, "");
		addChangingListener(years, "");
		addChangingListener(days, "");
		
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
		days.addChangingListener(wheelListener);

		
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
				mCurrentDay = mDayAdapter.getItem(days.getCurrentItem());
			}
		};
		
		years.addScrollingListener(scrollListener);
		months.addScrollingListener(scrollListener);
		days.addScrollingListener(scrollListener);

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
