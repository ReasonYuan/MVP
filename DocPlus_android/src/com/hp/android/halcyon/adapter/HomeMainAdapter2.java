package com.hp.android.halcyon.adapter;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.NotifyOk;
import com.fq.halcyon.entity.HomeData;
import com.fq.halcyon.entity.HomeOneDayData;
import com.fq.halcyon.entity.HomeOneDayData.CurrSate;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic2.DoctorHomeLogic;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.TimeFormatUtils;
import com.hp.android.halcyon.FollowupListActivity;
import com.hp.android.halcyon.HomeActivity;
import com.hp.android.halcyon.LookFollowUpActivity;
import com.hp.android.halcyon.util.BitmapCache;
import com.hp.android.halcyon.util.BitmapManager;
import com.hp.android.halcyon.util.TextFontUtils;
import com.hp.android.halcyon.widgets.RoundedImageView;
import com.hp.halcyon.widgets.main.FQAndroidView;
import com.hp.halcyon.widgets.main.FQView;
import com.hp.halcyon.widgets.main.MainView2;
import com.hp.halcyon.widgets.main.MainViewAdapter2;

public class HomeMainAdapter2 extends MainViewAdapter2 implements OnClickListener, NotifyOk{

	private LinkedHashMap<Integer, ArrayList<HomeOneDayData>> mOneDayDataMap;
	private ArrayList<HomeOneDayData> mOneDayDataList; 
	
	private int mSelectedPatientId = -1;
	
	private ArrayList<Integer> mMonth;
	
	private Activity mContext;
	
	public int mCurrentDayIndex = -2;
	
	private boolean mIsFrist;
	
	private Typeface mFont;
	
	public static ArrayList<HomeOneDayData> mOneDayDatas;
	
	private boolean mShouldScaleInHeadIcon = true;
	
	private Calendar mSelectedCal;
	
	private BitmapCache mBitmapCache;
	
	private Map<Integer,ArrayList<ImageView>> mCallbackArray;
//	private ImageLoader mImageLoader;
	
	public HomeMainAdapter2(Activity context){
		mContext = context;
		mFont = TextFontUtils.getTypeface(TextFontUtils.FONT_HIRAGINO_SANS_GB_W3);
//		mImageLoader = ImageLoader.getInstance(3, Type.LIFO);
		mBitmapCache = new BitmapCache();
		mCallbackArray = new HashMap<Integer, ArrayList<ImageView>>();
	}
	
	public boolean isShouldScaleInHeadIcon() {
		return mShouldScaleInHeadIcon;
	}

	public void setShouldScaleInHeadIcon(boolean mShouldScaleInHeadIcon) {
		this.mShouldScaleInHeadIcon = mShouldScaleInHeadIcon;
	}

	@Override
	public int getCurrentDayIndex() {
		return mCurrentDayIndex;
	}
	
	@Override
	public int getCountOfMonth() {
		return mOneDayDataMap == null? 0 : mOneDayDataMap.size();
	}

	@Override
	public int getCountOfDay(int monthPosition) {
		if(mOneDayDataMap == null)return 0;
		return mOneDayDataMap.get(mMonth.get(monthPosition)).size();
	}

	public HomeOneDayData getOneData(int monthPosition,int dayPosition){
		return mOneDayDataMap.get(mMonth.get(monthPosition)).get(dayPosition);
	}
	
	@Override
	public int getCount(int monthPosition, int dayPosition) {
		if(mOneDayDataMap == null)return 0;
		int count = getOneData(monthPosition, dayPosition).getDataCount();
		return  count > 5 ? 6 : count;
	}
	
	public int getCount(){
		return mOneDayDataList == null?0:mOneDayDataList.size();
	}

	@Override
	public boolean isT(int monthPosition, int dayPosition) {
//		return getPatientInfo(monthPosition, dayPosition).isIshaveTimer();
		return false;
	}
	
	@Override
	public FQView getMoreView(int monthPosition, int dayPosition,
			FQView convertView) {
		FQAndroidView mView = (FQAndroidView) convertView;
		if(mView == null){
			mView = new FQAndroidView(mContext);
		}
		View view = mView.getView();
		if (view == null) {
			view = LayoutInflater.from(mContext).inflate(R.layout.item_home_more, null);
			mView.setView(view);
		}
		
		view.setId(2);
		view.setOnClickListener(this);
		view.setTag(getOneData(monthPosition, dayPosition));
		
		return mView;
	}
	
	@Override
	public FQView getTView(int monthPosition, int dayPosition,
			FQView convertView) {
		return null;
//		PatientInfo info = getPatientInfo(monthPosition, dayPosition);
//		FQAndroidView tView = (FQAndroidView) convertView;
//		if(tView == null){
//			tView = new FQAndroidView(mContext);
//		}
//		View view = tView.getView();
//		if (view == null) {
//			view = mContext.getLayoutInflater().inflate(R.layout.item_home_timer, null);
//			tView.setView(view);
//		}
//		
//		if(info.getCurrentSate() == CurrSate.AFTER){
//			view.findViewById(R.id.btn_home_timer).setBackgroundResource(R.drawable.selector_btn_home_timer_future_bg);
//		}else{
//			view.findViewById(R.id.btn_home_timer).setBackgroundResource(R.drawable.selector_btn_home_timer_bg);
//		}
//		
//		if(info.isTimerUnRead()){
//			view.findViewById(R.id.iv_home_timer_popu).setVisibility(View.VISIBLE);
//		}else{
//			view.findViewById(R.id.iv_home_timer_popu).setVisibility(View.GONE);
//		}
//		
//		boolean isOnly = info.getPatient().size() < 1;
//		view.findViewById(R.id.v_home_timer_line).setVisibility(isOnly?View.GONE:View.VISIBLE);
//		
//		view.setOnClickListener(this);
//		view.setId(3);
//		view.setTag(info);
//		
//		return tView;
	}
	
	@Override
	public void resetItemView(int monthPosition, int dayPosition,int position, FQView convertView){
		if(convertView != null && convertView instanceof FQAndroidView){
			View view = ((FQAndroidView)convertView).getView();
			if(view != null){
				ImageView imageView = (ImageView) view.findViewById(R.id.img_heard);
				imageView.setImageBitmap(null);
				imageView.setTag(null);
			}
		}
	}
	
	@Override
	public FQView getItemView(int monthPosition, int dayPosition, int position, FQView convertView) {
		HomeData data = getOneData(monthPosition, dayPosition).getData(position);
		FQAndroidView itemView = (FQAndroidView) convertView;
		if (itemView == null) {
			itemView = new FQAndroidView(mContext);
		}
		View view = itemView.getView();
		if (view == null) {
			view = mContext.getLayoutInflater().inflate(R.layout.item_home_name, null);
			itemView.setView(view);
		}
		final RoundedImageView imageView = (RoundedImageView) view.findViewById(R.id.img_heard);
		final Photo photo = new Photo();
		photo.setImageId(data.getmImgID());
		photo.setImagePath(data.getmImgPath());
		imageView.setTag(photo.getImageId());
		Bitmap heard = mBitmapCache.getBitmapFromMemCache(String.valueOf(photo.getImageId()));
		if(heard != null){
			imageView.setImageBitmap(heard);
		}else{
			ArrayList<ImageView> callbacks = mCallbackArray.get(photo.getImageId());
			if(callbacks == null){
				callbacks = new ArrayList<ImageView>();
				mCallbackArray.put(photo.getImageId(), callbacks);
			}
			callbacks.add(imageView);
			ApiSystem.getInstance().setNotify(this);
			ApiSystem.getInstance().getHeadImage(photo, new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					if(obj instanceof String){
						String ss = ""+obj;
						Bitmap heard = BitmapManager.decodeBitmap2ScaleTo((String)obj, imageView.getWidth());
						mBitmapCache.addBitmapToMemoryCache(String.valueOf(photo.getImageId()), heard);
						ArrayList<ImageView> callbacks = mCallbackArray.get(photo.getImageId());
						for (int i = 0; i < callbacks.size(); i++) {
							try {
								ImageView tmpImageView = callbacks.get(i);
								if(tmpImageView.getTag() != null && tmpImageView.getTag().equals(photo.getImageId())){
									tmpImageView.setImageBitmap(heard);
								}
							} catch (Exception e) {
								e.printStackTrace();
							}
						}
						ApiSystem.getInstance().onDataSet();
						callbacks.clear();
					}
				}
					
			}, false,2);
		}
		
		setViewRead(view, data.isRead());
//		View readbg = view.findViewById(R.id.v_home_item_unread_bg);
		/*if(data.isRead()){
			imageView.setSelected(false);
			readbg.setVisibility(View.GONE);
		}else{
			imageView.setSelected(true);
			readbg.setVisibility(View.VISIBLE);
		}*/
		
		view.setOnClickListener(this);
		view.setId(1);
		view.setTag(data);
		return itemView;
	}

	@Override
	public FQView getHeaderView(final int monthPosition, final int dayPosition, FQView convertView) {
		final HomeOneDayData oneDayData = getOneData(monthPosition, dayPosition);
		FQAndroidView headerView = (FQAndroidView) convertView;
		TextView weekday = null;
		TextView monthday = null;
		if (headerView == null) {
			headerView = new FQAndroidView(mContext);
			headerView.setView(mContext.getLayoutInflater().inflate(R.layout.item_home_header, null));
			weekday = (TextView)headerView.findViewById(R.id.tv_home_header_week);
			monthday = (TextView)headerView.findViewById(R.id.tv_home_header_day);
//			View l = headerView.findViewById(R.id.v_home_header_background);
			weekday.setTypeface(mFont);
			monthday.setTypeface(mFont);
		}
		
		if(weekday == null)weekday = (TextView)headerView.findViewById(R.id.tv_home_header_week);
		if(monthday == null)monthday = (TextView)headerView.findViewById(R.id.tv_home_header_day);
//		int index = oneDayData.getDayOfWeek();
		weekday.setText(TimeFormatUtils.getdayOfWeek(oneDayData.getDayOfWeek()));
		monthday.setText(oneDayData.getDayOfMonth()+"");
		if(oneDayData.getCurrentSate() == CurrSate.AFTER){
			weekday.setEnabled(false);
			monthday.setEnabled(false);
		}else{
			weekday.setEnabled(true);
			monthday.setEnabled(true);
			if(oneDayData.getCurrentSate()== CurrSate.CURR){
				weekday.setTextSize(14);
				monthday.setTextSize(16);
			}else{
				weekday.setTextSize(14);
				monthday.setTextSize(16);
			}
		}
		
//		View unread = headerView.findViewById(R.id.v_home_header_unreader);
//		View current = headerView.findViewById(R.id.v_home_header_current);
//		
		/*if(oneDayData.isHaveUnReadData()){
			unread.setVisibility(View.VISIBLE);
			LayoutParams params = (LayoutParams)unread.getLayoutParams();
			if(oneDayData.getCurrentSate()== CurrSate.CURR){
				params.gravity = Gravity.CENTER_HORIZONTAL|Gravity.BOTTOM;
			}else{
				params.gravity = Gravity.CENTER_HORIZONTAL|Gravity.TOP;
			}
		}else{
			unread.setVisibility(View.GONE);
		}*/
		
		View l = headerView.findViewById(R.id.v_home_header_background);
		if(oneDayData.getCurrentSate() == CurrSate.CURR){
//			current.setVisibility(View.VISIBLE);
			l.setBackgroundResource(R.drawable.home_today_background);
		}else{
//			current.setVisibility(View.GONE);
			l.setBackgroundColor(Color.TRANSPARENT);
		}
		
		/*headerView.setOnClickListener(new FQOnClickListener() {
			//点击事件
			@Override
			public void onLongPress(FQView v) {
			};
			
			@Override
			public void onClick(FQView v) {
				Intent intent = new Intent(mContext, SelectDayContentActivity.class);
				mOneDayDatas = getPatientInfo(monthPosition, dayPosition).getPatient();
				intent.putExtra("select_date", patient.getDate());
				mContext.startActivity(intent);
			}
		});*/
		
		return headerView;
	}

	@Override
	public int getMonthIndex(int monthPosition) {
		return mMonth.get(monthPosition)+1;
	}

	public void appendData(ArrayList<HomeOneDayData> dayData){
		if(dayData == null) return;
		if(mOneDayDataList == null) mOneDayDataList = new ArrayList<HomeOneDayData>();
		boolean addLast = dayData.get(0).getTimeMillis() < getFirstDate();
		mOneDayDataList.addAll(dayData);
		setData(mOneDayDataList);
		if(addLast)((MainView2)mObserver).scrollToFirst(dayData.size(), false);
	}
	
	public void setData(ArrayList<HomeOneDayData> dayDatas) {
		if(dayDatas == null) return;
		mOneDayDataList = dayDatas;
		Collections.sort(mOneDayDataList, new Comparator<HomeOneDayData>() {

			@Override
			public int compare(HomeOneDayData lhs, HomeOneDayData rhs) {
				long l = lhs.getTimeMillis();
				long r = rhs.getTimeMillis();
				if(l > r)return 1;
				if(l < r)return -1;
				return 0;
			}
		});
		mCurrentDayIndex = DoctorHomeLogic.getCurrentDayIndex(dayDatas);
		mOneDayDataMap = DoctorHomeLogic.getPatientTree(dayDatas);
		
		if(mMonth == null) mMonth = new ArrayList<Integer>();
		mMonth.clear();
		Iterator<Integer> iterator = mOneDayDataMap.keySet().iterator();
		while (iterator.hasNext()) {
			mMonth.add(iterator.next());
		}
		
		//有没有未读事项
		int index = findUnreaderIndex();
		((HomeActivity)mContext).setUnReadVisibility(index != -1?View.VISIBLE:View.GONE);
		
		notifyDataSetChanged();
		if(mSelectedCal != null){
			int id = getFirstDayIndexInMonth(mSelectedCal);
			if(id != -1){
				scrollToIndexFirst(id);
				return;
			}
		} 
		if(mCurrentDayIndex > 0 && !mIsFrist){
			mIsFrist = true;
			((MainView2)mObserver).selected(mCurrentDayIndex);
		}
	}

	public int getCurrendIndex(){
		return ((MainView2)mObserver).getCurrentIndex();
	}
	
	public void setViewRead(View view,boolean isb){
		RoundedImageView imageView = (RoundedImageView) view.findViewById(R.id.img_heard);
		View readbg = view.findViewById(R.id.v_home_item_unread_bg);
		if(isb){
			imageView.setSelected(false);
			readbg.setVisibility(View.GONE);
		}else{
			imageView.setSelected(true);
			readbg.setVisibility(View.VISIBLE);
		}
	}
	
	@Override
	public void onClick(View v) {
		Intent intent = new Intent();
		
		switch (v.getId()) {
		case 1:
			HomeData data = (HomeData) v.getTag();
			if(!data.isRead()){
				data.setRead(HomeData.READ_STATE_YES);
				setViewRead(v, true);
			}
			
			intent.putExtra("timerId", data.getmFollowUpId());
			intent.setClass(mContext, LookFollowUpActivity.class);
			break;
		case 2:
			HomeOneDayData mData = (HomeOneDayData) v.getTag();
			intent.putExtra("time", mData.getTimeMillis());
			intent.setClass(mContext, FollowupListActivity.class);
			break;
		}
		mContext.startActivity(intent);
		
		
//		Intent intent = new Intent();
//		switch (v.getId()) {
//		case 1:
//			intent.setClass(mContext, SelectDayPatientsActivity.class);
//			Patient patient = new Patient();
//			ArrayList<Patient> patientList = new ArrayList<Patient>();
//			HashMap<Patient, ArrayList<Patient>> dayMap = (HashMap<Patient, ArrayList<Patient>>) v.getTag();
//			Iterator<Patient> iter = dayMap.keySet().iterator();
//			while (iter.hasNext()) {
//				patient = iter.next();
//				patientList = dayMap.get(patient);
//			}
//			int position = patientList.indexOf(patient);
//			if(position == -1){
//				position = 0;
//			}
//			mOneDayDatas = patientList;
//			intent.putExtra("position", position);
//			UserActionManger.getInstance().addViewPatientAction(patient.getName());
//			break;
//		case 2:
//			intent.setClass(mContext, SelectDayPatientsActivity.class);
//			PatientInfo info = (PatientInfo) v.getTag();
//			mOneDayDatas = info.getPatient();
//			break;
//		case 3:
//			PatientInfo info2 = (PatientInfo) v.getTag();
//			intent.setClass(mContext, RemindDetailActivity.class);
//			intent.putExtra("timer_date", info2.getDateTime());
//			info2.setIsTimerUnRead(false);
//			break;
//		}
//		mContext.startActivity(intent);
	}
	
	public void selectItems(int patientId) {
		mSelectedPatientId = patientId;
		notifyDataSetChanged();
	}
	
	public void findNextUnReadInfo(){
//		int index = findUnreaderIndex();
//		if(index == -1){
//			UITools.showToast("当前没有未读信息");
//		}else{
//			((MainView2)mObserver).scrollTo(index,true);
//		}
//		
//		int currentIndex = DoctorHomeLogic.getCurrentDayIndex(mOneDayDataList);
//		if(currentIndex == -1){//今天不在列表里面
//			for(int i = mOneDayDataList.size()-1; i > -1; i--){
//				PatientInfo info = mOneDayDataList.get(i);
//				if(info.isRecordUnRead() || info.isTimerUnRead()){
//					((MainView2)mObserver).scrollTo(i,true);
//					break;
//				}
//				if(i == 0){
//					UITools.showToast("当前没有未读信息");
//				}
//			}
//		}else{//今天在列表里面
//			for(int i = currentIndex; i > -1; i--){
//				PatientInfo info = mOneDayDataList.get(i);
//				if(info.isRecordUnRead() || info.isTimerUnRead()){//
//					((MainView2)mObserver).scrollTo(i,true);
//					break;
//				}
//				if(i == 0){
//					UITools.showToast("当前没有未读信息");
//				}
//			}
//		}
	}
	
	public int findUnreaderIndex(){
		int currentIndex = DoctorHomeLogic.getCurrentDayIndex(mOneDayDataList);
		if(currentIndex == -1){//今天不在列表
			for(int i = mOneDayDataList.size()-1; i > -1; i--){
				HomeOneDayData info = mOneDayDataList.get(i);
				if(info.isHaveUnReadData()){
					return i;
				}
			}
			return -1;
		}else{//今天在列表
			for(int i = mOneDayDataList.size()-1; i > -1; i--){//未来未读信息
				HomeOneDayData info = mOneDayDataList.get(i);
				if(info.isHaveUnReadData()){
					return i;
				}
			}
//			
//			for(int i = currentIndex; i > -1; i--){//过去未读信息
//				PatientInfo info = mOneDayDataList.get(i);
//				if(info.isRecordUnRead() || info.isTimerUnRead()){
//					return i;
//				}
//			}
			return -1;
		}
	}
	
	
	public void scrollToIndex(int index){
		((MainView2)mObserver).scrollTo(index,true);
	}
	
	public void scrollToIndexFirst(int index){
		((MainView2)mObserver).scrollToFirst(index,true);
		mSelectedCal = null;
	}
	
	public void clearItemSelect(){
		if(mSelectedPatientId != -1){
			mSelectedPatientId = -1;
			notifyDataSetChanged();
		}
	}
	
	public void setSelectCal(Calendar cal){
		mSelectedCal = cal;
	}
	
	public int getFirstDayIndexInMonth(Calendar cal){
		if(mSelectedCal == null)return -1;
		
		int year = cal.get(Calendar.YEAR);
		int month = cal.get(Calendar.MONDAY);
		
		for(int i = 0; i < mMonth.size(); i++){
			int m = mMonth.get(i);
			ArrayList<HomeOneDayData> info = mOneDayDataMap.get(m);
			if(m == month && year == info.get(0).getCalendar().get(Calendar.YEAR)){
				if(info.get(0).getDayOfMonth() == 1){
					return mOneDayDataList.indexOf(info.get(0));
				}
			}
		}
		return -1;
	}

	@Override
	public long getFirstDate() {
		try {
			return mOneDayDataList.get(0).getTimeMillis();
		} catch (Exception e) {
		}
		return 0;
	}

	@Override
	public long getLastDate() {
		try {
			return mOneDayDataList.get(mOneDayDataList.size() - 1).getTimeMillis();
		} catch (Exception e) {
		}
		return 0;
	}

	@Override
	public void onImageSeted() {
		((MainView2)mObserver).invalidate();
		
	}
	
	public int[] getMainBoardList(){
		int[] result = null;
		if (mOneDayDataList == null) {
			result = new int[0];
		}else{
			result = new int[mOneDayDataList.size()];
			for (int i = 0; i < mOneDayDataList.size(); i++) {
				HomeOneDayData oneDayData = mOneDayDataList.get(i);
				result[i] = oneDayData.getmRecRecongnizedNum();
			}
		}
		return result;
	}
}
