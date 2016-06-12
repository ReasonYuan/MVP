package com.hp.android.halcyon.adapter;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Typeface;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.HomeData;
import com.fq.halcyon.entity.HomeOneDayData;
import com.fq.halcyon.entity.HomeOneDayData.CurrSate;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic2.DoctorHomeLogic;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.TimeFormatUtils;
import com.hp.android.halcyon.FollowupListActivity;
import com.hp.android.halcyon.LookFollowUpActivity;
import com.hp.android.halcyon.util.BitmapCache;
import com.hp.android.halcyon.util.BitmapManager;
import com.hp.android.halcyon.util.TextFontUtils;
import com.hp.android.halcyon.widgets.RoundedImageView;
import com.hp.halcyon.widgets.home.HomeListView;
import com.hp.halcyon.widgets.home.HomeListViewAdapter;
import com.hp.halcyon.widgets.home.HomeView;
import com.hp.halcyon.widgets.home.HomeView.ItemClickListener;
import com.hp.halcyon.widgets.home.HomeView.ScrollAligment;

public class HomeMainAdapter extends HomeListViewAdapter implements ItemClickListener {
	
	public interface OnMonthViewClickListener{
		public void onMonthTitleClick();
	}

	private BitmapCache mBitmapCache;

	private OnMonthViewClickListener mOnMonthViewClickListener;
	
	private Map<Integer, ArrayList<ImageView>> mCallbackArray;
	
	private Typeface mFont;
	
	private HomeView mObserver;
	
	public int mCurrentDayIndex = -2;
	
	private boolean mIsFrist;
	
	private boolean mShouldScaleInHeadIcon = true;

	public HomeMainAdapter(HomeView view) {
		mObserver = view;
		mBitmapCache = new BitmapCache();
		mCallbackArray = new HashMap<Integer, ArrayList<ImageView>>();
		mFont = TextFontUtils.getTypeface(TextFontUtils.FONT_HIRAGINO_SANS_GB_W3);
	}

	public void setOnMonthViewClickListener(OnMonthViewClickListener l){
		mOnMonthViewClickListener = l;
	}
	
	@Override
	public int getCount() {
		return mDataArray == null ? 0 : mDataArray.size();
	}

	@Override
	public int getItemCount(int position) {
		return mDataArray == null ? 0 : mDataArray.get(position).getDataCount();
	}

	@Override
	public View getMoreView(int position, View converView, ViewGroup parent) {
		if (converView == null) {
			converView = ((LayoutInflater) parent.getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(R.layout.item_home_more, null);
		}
		converView.setTag(mDataArray.get(position));
		return converView;
	}

	@Override
	public View getItemView(int position, int column, View converView, ViewGroup parent) {
		if (converView == null) {
			converView = ((LayoutInflater) parent.getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(R.layout.item_home_name, null);
		}
		HomeData data = mDataArray.get(position).getData(column);
		View view = converView;
		final RoundedImageView imageView = (RoundedImageView) view.findViewById(R.id.img_heard);
		final Photo photo = new Photo();
		photo.setImageId(data.getmImgID());
		photo.setImagePath(data.getmImgPath());
		imageView.setTag(photo.getImageId());
		Bitmap heard = mBitmapCache.getBitmapFromMemCache(String.valueOf(photo.getImageId()));
		if (heard != null) {
			imageView.setImageBitmap(heard);
		} else {
			ArrayList<ImageView> callbacks = mCallbackArray.get(photo.getImageId());
			if (callbacks == null) {
				callbacks = new ArrayList<ImageView>();
				mCallbackArray.put(photo.getImageId(), callbacks);
			}
			callbacks.add(imageView);
			ApiSystem.getInstance().getHeadImage(photo, new ICallback() {

				@Override
				public void doCallback(Object obj) {
					if (obj instanceof String) {
						int width = imageView.getWidth() == 0 ? HomeListView.getItemWith() : imageView.getWidth();
						String path = (String) obj;
						Bitmap heard = null;
						if(path == null || path.equals("")){
							heard = BitmapFactory.decodeResource(imageView.getResources(), R.drawable.app_icon);
						}else{
							heard = BitmapManager.decodeBitmap2ScaleTo((String) obj, width);
						}
						mBitmapCache.addBitmapToMemoryCache(String.valueOf(photo.getImageId()), heard);
						ArrayList<ImageView> callbacks = mCallbackArray.get(photo.getImageId());
						for (int i = 0; i < callbacks.size(); i++) {
							try {
								ImageView tmpImageView = callbacks.get(i);
								if (tmpImageView.getTag() != null && tmpImageView.getTag().equals(photo.getImageId())) {
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

			}, false, 2);
		}
		setViewRead(view, data.isRead());
		startAnimation(view);
		return converView;
	}

	@Override
	public View getHeaderView(int position, View converView, ViewGroup parent) {
		final HomeOneDayData oneDayData = mDataArray.get(position);
		View headerView = converView;
		TextView weekday = null;
		TextView monthday = null;
		if (headerView == null) {
			headerView = converView = ((LayoutInflater) parent.getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(R.layout.item_home_header, null);
			weekday = (TextView) headerView.findViewById(R.id.tv_home_header_week);
			monthday = (TextView) headerView.findViewById(R.id.tv_home_header_day);
			weekday.setTypeface(mFont);
			monthday.setTypeface(mFont);
		}

		if (weekday == null)
			weekday = (TextView) headerView.findViewById(R.id.tv_home_header_week);
		if (monthday == null)
			monthday = (TextView) headerView.findViewById(R.id.tv_home_header_day);
		weekday.setText(TimeFormatUtils.getdayOfWeek(oneDayData.getDayOfWeek()));
		monthday.setText(oneDayData.getDayOfMonth() + "");
		if (oneDayData.getCurrentSate() == CurrSate.AFTER) {
			weekday.setEnabled(false);
			monthday.setEnabled(false);
		} else {
			weekday.setEnabled(true);
			monthday.setEnabled(true);
			if (oneDayData.getCurrentSate() == CurrSate.CURR) {
				weekday.setTextSize(14);
				monthday.setTextSize(16);
			} else {
				weekday.setTextSize(14);
				monthday.setTextSize(16);
			}
		}

		View l = headerView.findViewById(R.id.v_home_header_background);
		if (oneDayData.getCurrentSate() == CurrSate.CURR) {
			l.setBackgroundResource(R.drawable.home_today_background);
		} else {
			l.setBackgroundColor(Color.TRANSPARENT);
		}
		return converView;
	}
	
	public void appendData(ArrayList<HomeOneDayData> dayData){
		if(dayData == null) return;
		if(mDataArray == null) mDataArray = new ArrayList<HomeOneDayData>();
//		boolean addLast = dayData.get(0).getTimeMillis() < getFirstDate();
//		mDataArray.addAll(dayData);
//		setData(mDataArray);
		int lastSize = mDataArray.size();
		boolean addLast = dayData.get(0).getTimeMillis() < getFirstDate();
		mDataArray.addAll(dayData);
		if(addLast){
			mObserver.scrollTo(dayData.size(),ScrollAligment.Right,false);
		}else {
			mObserver.scrollTo(lastSize,ScrollAligment.Right,false);
		}
		setData(mDataArray);
	}

	public void setData(ArrayList<HomeOneDayData> array) {
		if (array != null) {
			mDataArray = array;
			mData = DoctorHomeLogic.sortAndGroup(mDataArray);
			notifyDataSetChanged();
			mCurrentDayIndex = DoctorHomeLogic.getCurrentDayIndex(mDataArray);
			if(mCurrentDayIndex > 0 && !mIsFrist){
				mIsFrist = true;
				mObserver.scrollTo(mCurrentDayIndex,false);
			}
		}
	}
	
	@Override
	public View getMonthView(int group, View converView, ViewGroup parent) {
		if (converView == null) {
			converView = ((LayoutInflater) parent.getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE)).inflate(R.layout.item_home_month, null);
			TextView textView = (TextView) converView.findViewById(R.id.text_content_value);
			TextFontUtils.setFont(textView, TextFontUtils.FONT_ELLE_BOL);
			textView = (TextView) converView.findViewById(R.id.text_content_number);
			TextFontUtils.setFont(textView, TextFontUtils.FONT_HIRAGINO_SANS_GB_W3);
		}
		TextView textView = (TextView) converView.findViewById(R.id.text_content_value);
		int monthIndex = mData.get(group).get(0).getMonth();
		textView.setText(TimeFormatUtils.MONTH_US[monthIndex]);
		textView = (TextView) converView.findViewById(R.id.text_content_number);
		textView.setText((monthIndex + 1 ) + "");
		return converView;
	}

	@Override
	public int getGroupCount() {
		return mData == null ? 0 : mData.size();
	}

	@Override
	public int getMonthViewWidth(int group) {
		int width = 0;
		if (mData != null) {
			width = mData.get(group).size() * HomeListView.getItemWith();
		}
		return width;
	}

	public void setViewRead(View view, boolean isb) {
		RoundedImageView imageView = (RoundedImageView) view.findViewById(R.id.img_heard);
		View readbg = view.findViewById(R.id.v_home_item_unread_bg);
		if (isb) {
			imageView.setSelected(false);
			readbg.setVisibility(View.GONE);
		} else {
			imageView.setSelected(true);
			readbg.setVisibility(View.VISIBLE);
		}
	}
	
	public long getFirstDate() {
		try {
			return mDataArray.get(0).getTimeMillis();
		} catch (Exception e) {
		}
		return 0;
	}
	
	public long getLastDate() {
		try {
			return mDataArray.get(mDataArray.size() - 1).getTimeMillis();
		} catch (Exception e) {
		}
		return 0;
	}

	@Override
	public void onItemViewClick(int position, int column, View v) {
		Intent intent = new Intent();
		Context mContext = v.getContext();
		HomeData data = mDataArray.get(position).getData(column);
		if (!data.isRead()) {
			data.setRead(HomeData.READ_STATE_YES);
			setViewRead(v, true);
		}

		intent.putExtra("timerId", data.getmFollowUpId());
		intent.setClass(mContext, LookFollowUpActivity.class);
		mContext.startActivity(intent);
	}
	
	public void setShouldScaleInHeadIcon(boolean mShouldScaleInHeadIcon) {
		this.mShouldScaleInHeadIcon = mShouldScaleInHeadIcon;
	}
	
	@Override
	public void onMoreViewClick(int position, View v) {
		Intent intent = new Intent();
		Context mContext = v.getContext();
		HomeOneDayData mData = mDataArray.get(position);
		intent.putExtra("time", mData.getTimeMillis());
		intent.setClass(mContext, FollowupListActivity.class);
		mContext.startActivity(intent);
	}

	@Override
	public void onHeaderViewClick(int position, View view) {
		Log.e("", "------->onHeaderViewClick  position:" + position);
	}

	@Override
	public void onMonthViewClick(int group, View view) {
//		int month = mData.get(group).get(0).getMonth() +1;
//		Log.e("", "------->onMonthViewClick  month:" + month);
		if(mOnMonthViewClickListener != null){
			mOnMonthViewClickListener.onMonthTitleClick();
		}
	}

	public int getCurrentDayIndex() {
		return mCurrentDayIndex;
	}
	
	public int getCurrendIndex(){
		return mObserver.getCurrentIndex();
	}
	
	@Override
	public int[] getMainBoardList(){
		int[] result = null;
		if (mDataArray == null) {
			result = new int[0];
		}else{
			result = new int[mDataArray.size()];
			for (int i = 0; i < mDataArray.size(); i++) {
				HomeOneDayData oneDayData = mDataArray.get(i);
				result[i] = oneDayData.getmRecRecongnizedNum();
			}
		}
		return result;
	}
	
	public int getFirstDayIndexInMonth(Calendar cal){
		int year = cal.get(Calendar.YEAR);
		int month = cal.get(Calendar.MONDAY);
		
		int index = 0;
		for(int i = 0; i < mData.size(); i++){
			HomeOneDayData oneDayData = mData.get(i).get(0);
			Calendar c = oneDayData.getCalendar();
			int m = c.get(Calendar.MONTH);
			int y = c.get(Calendar.YEAR);
			if(year == y && m == month){
				if(c.get(Calendar.DAY_OF_MONTH)== 1){
					return index;
				}
			}
			index += mData.get(i).size();
		}
		return -1;
	}
	
	
	private void startAnimation(View view){
		if(mShouldScaleInHeadIcon){
			view.startAnimation(AnimationUtils.loadAnimation(view.getContext(),R.anim.scale_alpha_in));
		}
	}
}
