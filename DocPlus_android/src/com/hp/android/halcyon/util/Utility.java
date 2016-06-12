package com.hp.android.halcyon.util;

import android.content.Context;
import android.support.v4.view.ViewPager;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.View.MeasureSpec;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.ViewTreeObserver;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.RelativeLayout;

import com.hp.android.halcyon.HalcyonApplication;

public class Utility {
	public static int setListViewHeightBasedOnChildren(ListView listView) {

		// 获取ListView对应的Adapter
		ListAdapter listAdapter = listView.getAdapter();
		if (listAdapter == null) {
			// pre-condition
			return 0;
		}
		DisplayMetrics dm = new DisplayMetrics();
		WindowManager wm = (WindowManager) HalcyonApplication.getAppContext().getSystemService(Context.WINDOW_SERVICE);
		wm.getDefaultDisplay().getMetrics(dm);
		int screenWidth = dm.widthPixels;
		int screenHeigh = dm.heightPixels;
		ViewGroup.LayoutParams params = listView.getLayoutParams();
		int listWidth = screenWidth;
		if (params instanceof RelativeLayout.LayoutParams) {
			RelativeLayout.LayoutParams p = (RelativeLayout.LayoutParams) params;
			listWidth = screenWidth - p.leftMargin - p.rightMargin;
		}
		int totalHeight = 0;
		for (int i = 0, len = listAdapter.getCount(); i < len; i++) { // listAdapter.getCount()返回数据项的数目
			View listItem = listAdapter.getView(i, null, listView);
			listItem.measure(MeasureSpec.makeMeasureSpec(listWidth,
					MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(
					0, MeasureSpec.UNSPECIFIED)); // 计算子项View 的宽高
			totalHeight += listItem.getMeasuredHeight(); // 统计所有子项的总高度
//			Log.e("", "~~~~~~~~~~~~~~"+listWidth+"   "+ listItem.getMeasuredHeight() + "       " + listItem.getMeasuredWidth());
		}

		params.height = totalHeight
				+ (listView.getDividerHeight() * (listAdapter.getCount() - 1));
		// listView.getDividerHeight()获取子项间分隔符占用的高度
		// params.height最后得到整个ListView完整显示需要的高度
		listView.setLayoutParams(params);
		return totalHeight;
	}

	public static void setViewpagerHeight(final ViewPager pager) {
		final int w = View.MeasureSpec.makeMeasureSpec(0,
				View.MeasureSpec.UNSPECIFIED);
		final int h = View.MeasureSpec.makeMeasureSpec(0,
				View.MeasureSpec.UNSPECIFIED);
		ViewTreeObserver vto = pager.getViewTreeObserver();
		vto.addOnGlobalLayoutListener(new OnGlobalLayoutListener() {

			public void onGlobalLayout() {
				pager.getViewTreeObserver().removeGlobalOnLayoutListener(this);
				View view = pager.getChildAt(pager.getCurrentItem());
				view.measure(w, h);
				ViewGroup.LayoutParams params = pager.getLayoutParams();
				params.height = view.getMeasuredHeight();
				pager.setLayoutParams(params);
			}
		});
	}

	public static void setViewpagerHeight(final ViewPager pager,
			final int height) {
		final int w = View.MeasureSpec.makeMeasureSpec(0,
				View.MeasureSpec.UNSPECIFIED);
		final int h = View.MeasureSpec.makeMeasureSpec(0,
				View.MeasureSpec.UNSPECIFIED);
		ViewTreeObserver vto = pager.getViewTreeObserver();
		vto.addOnGlobalLayoutListener(new OnGlobalLayoutListener() {

			public void onGlobalLayout() {
				pager.getViewTreeObserver().removeGlobalOnLayoutListener(this);
				View view = pager.getChildAt(pager.getCurrentItem());
				view.measure(w, h);
				ViewGroup.LayoutParams params = pager.getLayoutParams();
				params.height = height;
				pager.setLayoutParams(params);
			}
		});
	}
	
	public static void setFrameLayoutHeight(final FrameLayout frame,
			final int height){
		LayoutParams params = frame.getLayoutParams();
		params.height = height;
		frame.setLayoutParams(params);
	}
}