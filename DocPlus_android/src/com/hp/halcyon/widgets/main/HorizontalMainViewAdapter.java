//package com.hp.halcyon.widgets.main;
//
//import java.util.ArrayList;
//import java.util.Collections;
//import java.util.Comparator;
//import java.util.Iterator;
//import java.util.LinkedHashMap;
//
//import android.app.Activity;
//import android.graphics.Typeface;
//import android.view.Gravity;
//import android.view.LayoutInflater;
//import android.view.View;
//import android.view.View.OnClickListener;
//import android.view.ViewGroup;
//import android.widget.BaseAdapter;
//import android.widget.Button;
//import android.widget.FrameLayout.LayoutParams;
//import android.widget.TextView;
//
//import com.fq.android.plus.R;
//import com.fq.halcyon.entity.Patient;
//import com.fq.halcyon.entity.PatientInfo;
//import com.fq.halcyon.entity.PatientInfo.CurrSate;
//import com.fq.halcyon.logic2.DoctorHomeLogic;
//import com.hp.android.halcyon.HomeActivity;
//import com.hp.android.halcyon.util.TextFontUtils;
//import com.hp.halcyon.widgets.main.HorizontalMainItemView.HorizontalMainItemCreater;
//import com.hp.halcyon.widgets.main.HorizontalMainView.MonthAdapter;
//
//
//public class HorizontalMainViewAdapter extends BaseAdapter implements HorizontalMainItemCreater,OnClickListener,MonthAdapter{
//
//	private LinkedHashMap<Integer, ArrayList<PatientInfo>> mPatientInfos;
//	
//	private ArrayList<PatientInfo> mInfoList; 
//	
//	private Activity mContext;
//	
//	public int mCurrentDayIndex;
//	
//	private Typeface mFont;
//	
//	private ArrayList<Integer> mMonth;
//	
//	public HorizontalMainViewAdapter(Activity context){
//		mContext = context;
//		mInfoList = new ArrayList<PatientInfo>();
//		mFont = TextFontUtils.getTypeface(TextFontUtils.FONT_ELLE);
//	}
//	
//	@Override
//	public int getCount() {
//		return mInfoList.size();
//	}
//
//	@Override
//	public Object getItem(int position) {
//		return mInfoList.get(position);
//	}
//
//	@Override
//	public long getItemId(int position) {
//		return position;
//	}
//
//	@Override
//	public View getView(int position, View convertView, ViewGroup parent) {
//		HorizontalMainItemView view = (HorizontalMainItemView) convertView;
//		if(view == null){
//			view = new HorizontalMainItemView(this,mContext);
//		}
//		view.setPatientInfo(mInfoList.get(position));
//		return view;
//	}
//
//	public void setData(ArrayList<PatientInfo> infos) {
//		if(infos == null) return;
//		mInfoList = infos;
//		Collections.sort(mInfoList, new Comparator<PatientInfo>() {
//
//			@Override
//			public int compare(PatientInfo lhs, PatientInfo rhs) {
//				long l = lhs.getDateTime();
//				long r = rhs.getDateTime();
//				if(l > r)return 1;
//				if(l < r)return -1;
//				return 0;
//			}
//		});
//		mCurrentDayIndex = DoctorHomeLogic.getCurrentDayIndex(infos);
//		mPatientInfos = DoctorHomeLogic.getPatientTree(infos);
//		
//		if(mMonth == null) mMonth = new ArrayList<Integer>();
//		mMonth.clear();
//		Iterator<Integer> iterator = mPatientInfos.keySet().iterator();
//		while (iterator.hasNext()) {
//			mMonth.add(iterator.next());
//		}
//		
//		//有没有未读事项
//		int index = findUnreaderIndex();
////		((HomeActivity)mContext).setUnReadVisibility(index == -1?View.GONE:View.VISIBLE);
//		notifyDataSetChanged();
////		if(mCurrentDayIndex > 0 && !mIsFrist){
////			mIsFrist = true;
////			((MainView2)mObserver).selected(mCurrentDayIndex);
////		}
//	}
//
//	public int findUnreaderIndex(){
//		int currentIndex = DoctorHomeLogic.getCurrentDayIndex(mInfoList);
//		if(currentIndex == -1){//今天不在列表
//			for(int i = mInfoList.size()-1; i > -1; i--){
//				PatientInfo info = mInfoList.get(i);
//				if(info.isRecordUnRead() || info.isTimerUnRead()){//
//					return i;
//				}
//			}
//			return -1;
//		}else{//今天在列表
//			for(int i = mInfoList.size()-1; i > -1; i--){//未来未读信息
//				PatientInfo info = mInfoList.get(i);
//				if(info.isRecordUnRead() || info.isTimerUnRead()){
//					return i;
//				}
//			}
//			return -1;
//		}
//	}
//	
//	@Override
//	public View getItemView(Patient patient, int position, View converView) {
//		View itemView = converView;
//		if (itemView == null) {
//			itemView = mContext.getLayoutInflater().inflate(R.layout.item_home_name, null);
//		}
//		String fullName = patient.name;
//		String name = "".equals(fullName)?fullName:fullName.substring(0, 1);
//		((Button)itemView.findViewById(R.id.btn_home_name)).setText(name);
//		itemView.findViewById(R.id.iv_home_name_unread).setVisibility(patient.mIsRecordUnread?View.VISIBLE:View.GONE);
////		if(patient.getId() == mSelectedPatientId){
////			view.setSelected(true);
////		}else {
////			view.setSelected(false);
////		}
//		itemView.setId(1);
//		itemView.setOnClickListener(this);
//		return itemView;
//	}
//
//	@Override
//	public View getHeaderView(PatientInfo info, View converView) {
//		View headerView = converView;
//		if (headerView == null) {
//			headerView = mContext.getLayoutInflater().inflate(R.layout.item_home_header, null);
//			TextView m = (TextView)headerView.findViewById(R.id.tv_home_header_week);
//			TextView d = (TextView)headerView.findViewById(R.id.tv_home_header_day);
//			m.setTypeface(mFont);
//			d.setTypeface(mFont);
//		}
//		
//		TextView month = (TextView)headerView.findViewById(R.id.tv_home_header_week);
//		TextView day = (TextView)headerView.findViewById(R.id.tv_home_header_day);
//		month.setText(info.getDayOfWeek());
//		day.setText(info.getDayofMonth()+"");
//		if(info.getCurrentSate() == CurrSate.AFTER){
//			month.setEnabled(false);
//			day.setEnabled(false);
//		}else{
//			month.setEnabled(true);
//			day.setEnabled(true);
//			if(info.getCurrentSate()== CurrSate.CURR){
//				month.setTextSize(18);
//				day.setTextSize(16);
//			}else{
//				month.setTextSize(16);
//				day.setTextSize(14);
//			}
//		}
//		
//		View unread = headerView.findViewById(R.id.v_home_header_unreader);
//		View current = headerView.findViewById(R.id.v_home_header_current);
//		
//		if(info.isRecordUnRead()){
//			unread.setVisibility(View.VISIBLE);
//			LayoutParams params = (LayoutParams)unread.getLayoutParams();
//			if(info.getCurrentSate()== CurrSate.CURR){
//				params.gravity = Gravity.CENTER_HORIZONTAL|Gravity.BOTTOM;
//			}else{
//				params.gravity = Gravity.CENTER_HORIZONTAL|Gravity.TOP;
//			}
//		}else{
//			unread.setVisibility(View.GONE);
//		}
//		
//		if(info.getCurrentSate() == CurrSate.CURR){
//			current.setVisibility(View.VISIBLE);
//			//测试使用((LayoutParams)unread.getLayoutParams()).gravity = Gravity.CENTER_HORIZONTAL|Gravity.BOTTOM;
//		}else{
//			current.setVisibility(View.GONE);
//		}
//		
////		headerView.setOnClickListener(new FQOnClickListener() {
////			//点击事件
////			@Override
////			public void onLongPress(FQView v) {
////				
////			};
////			
////			@Override
////			public void onClick(FQView v) {
////				Intent intent = new Intent(mContext, SelectDayContentActivity.class);
////				mCurrPatients = getPatientInfo(monthPosition, dayPosition).getPatient();
////				intent.putExtra("select_date", patient.getDate());
////				mContext.startActivity(intent);
////			}
////		});
//		
//		return headerView;
//	}
//
//	@Override
//	public View getMoreView(PatientInfo info, View converView) {
//		View mView = converView;
//		if (mView == null) {
//			mView = LayoutInflater.from(mContext).inflate(R.layout.item_home_more, null);
//		}
//		mView.setId(2);
//		mView.setOnClickListener(this);
//		mView.setTag(info);
//		return mView;
//	}
//
//	@Override
//	public View getTView(PatientInfo info, View converView) {
//		View tView = converView;
//		if (tView == null) {
//			tView = mContext.getLayoutInflater().inflate(R.layout.item_home_timer, null);
//		}
//		if(info.getCurrentSate() == CurrSate.AFTER){
//			tView.findViewById(R.id.btn_home_timer).setBackgroundResource(R.drawable.selector_btn_home_timer_future_bg);
//		}else{
//			tView.findViewById(R.id.btn_home_timer).setBackgroundResource(R.drawable.selector_btn_home_timer_bg);
//		}
//		
//		if(info.isTimerUnRead()){
//			tView.findViewById(R.id.iv_home_timer_popu).setVisibility(View.VISIBLE);
//		}else{
//			tView.findViewById(R.id.iv_home_timer_popu).setVisibility(View.GONE);
//		}
//		
//		boolean isOnly = info.getPatient().size() < 1;
//		tView.findViewById(R.id.v_home_timer_line).setVisibility(isOnly?View.GONE:View.VISIBLE);
//		
//		tView.setOnClickListener(this);
//		tView.setId(3);
//		tView.setTag(info);
//		return tView;
//	}
//
//	@Override
//	public void onClick(View v) {
//		// TODO Auto-generated method stub
//		
//	}
//
//	@Override
//	public int getCountOfMonth() {
//		return mPatientInfos == null? 0 : mPatientInfos.size();
//	}
//
//	@Override
//	public int getCountOfDay(int position) {
//		return mPatientInfos.get(mMonth.get(position)).size();
//	}
//
//	@Override
//	public int getMonthIndex(int position) {
//		return mMonth.get(position)+1;
//	}
//}
//
