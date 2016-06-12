//package com.hp.halcyon.widgets.main;
//
//import java.util.ArrayList;
//import java.util.LinkedList;
//import java.util.Queue;
//
//import android.content.Context;
//import android.graphics.Color;
//import android.view.Gravity;
//import android.view.View;
//import android.widget.LinearLayout;
//
//import com.fq.halcyon.entity.Patient;
//import com.fq.halcyon.entity.PatientInfo;
//
//public class HorizontalMainItemView extends LinearLayout{
//
//	public interface HorizontalMainItemCreater{
//		public View getItemView(Patient patient,int position,View converView);
//		public View getHeaderView(PatientInfo info,View converView);
//		public View getMoreView(PatientInfo info,View converView);
//		public View getTView(PatientInfo info,View converView);
//	}
//	
//	
//	private View mHeaderView;
//	
//	private View mMoreView;
//	
//	private View mTView;
//	
//	protected Queue<View> mItemQueue;
//	
//	protected Queue<View> mBlankViews;
//	
//	private PatientInfo mPatientInfo;
//	
//	private HorizontalMainItemCreater mCreater;
//	
//	public HorizontalMainItemView(HorizontalMainItemCreater creater,Context context) {
//		super(context);
//		mItemQueue = new LinkedList<View>();
//		mBlankViews = new LinkedList<View>();
//		mCreater = creater;
//	}
//	
//	@Override
//	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
//		int heightMode = MeasureSpec.getMode(heightMeasureSpec);
//		int height = MeasureSpec.getSize(heightMeasureSpec);
//		super.onMeasure(widthMeasureSpec, MeasureSpec.makeMeasureSpec(height- HorizontalMainView.mMouthTitleHeight, heightMode));
//		int count  = getChildCount();
//		for (int i = 0; i < count; i++) {
//			View chidView = getChildAt(i);
//			chidView.measure(widthMeasureSpec, widthMeasureSpec);
//		}
//	}
//	
//	@Override
//	protected void onLayout(boolean changed, int l, int t, int r, int b) {
//		super.onLayout(changed, l, t, r, b);
//		int width = getMeasuredWidth();
//		int count  = getChildCount();
//		int top = getMeasuredHeight() - width;
//		for (int i = 0; i < count; i++) {
//			View child = getChildAt(i);
//			 child.layout(0, top,width, top + width);
//			 top -= width;
//		}
//	}
//	
//	public void setPatientInfo(PatientInfo info){
//		removeAllViews();
//		mPatientInfo = info;
//		mHeaderView = mCreater.getHeaderView(mPatientInfo, mHeaderView);
//		addView(mHeaderView, getChildLayoutParams());
//		ArrayList<Patient> patients = mPatientInfo.getPatient();
//		ArrayList<View> tmp = new ArrayList<View>();
//		for (int i = 0; i < patients.size(); i++) {
//			if(i == 5 ){
//				mMoreView = mCreater.getMoreView(mPatientInfo, mMoreView);
//				addView(mMoreView, getChildLayoutParams());
//				break;
//			}
//			View item = mCreater.getItemView(patients.get(i), i, mItemQueue.poll());
//			tmp.add(item);
//			addView(item, getChildLayoutParams());
//		}
//		mItemQueue.addAll(tmp);
//		if(mPatientInfo.isIshaveTimer()){
//			mTView = mCreater.getTView(mPatientInfo, mTView);
//			addView(mTView, getChildLayoutParams());
//		}
//	}
//	
//	private LinearLayout.LayoutParams getChildLayoutParams(){
//		LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT,1.f);
//		return params;
//	}
//}
