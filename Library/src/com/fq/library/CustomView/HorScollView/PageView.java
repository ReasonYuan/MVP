package com.fq.library.CustomView.HorScollView;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.fq.android.library.R;

public class PageView extends FrameLayout{

	private Context mContext;
	private CustomListView mHorizontalListView;
	private ArrayList<ArrayList<String>> mCurrentDatas = new ArrayList<ArrayList<String>>();
	private int dataSize;
	private DynamicConvertView mConvertView;
	
	public PageView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		this.mContext = context;
		initView();
	}

	public PageView(Context context, AttributeSet attrs) {
		super(context, attrs);
		this.mContext = context;
		initView();
	}

	public PageView(Context context) {
		super(context);
		this.mContext = context;
		initView();
	}

	public void initView(){
		View mView = LayoutInflater.from(mContext).inflate(R.layout.view_hor_scroll_layout, null);
		mHorizontalListView = (CustomListView) mView.findViewById(R.id.listview);
		addView(mView);
	}
	
	public void initData(ArrayList<ArrayList<String>> datas){
		mCurrentDatas.clear();
		mCurrentDatas = datas;
		dataSize = mCurrentDatas.get(0).size();
		MyListViewAdapter adapter = new MyListViewAdapter();
		mHorizontalListView.setAdapter(adapter);
	}
	
	private class MyListViewAdapter extends BaseAdapter{

		@Override
		public int getCount() {
			return mCurrentDatas.size();
		}

		@Override
		public Object getItem(int position) {
			return mCurrentDatas.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				mConvertView = new DynamicConvertView(mContext);
				mConvertView.initView(dataSize);
				convertView = mConvertView;
			}
			if (position == 0) {
				convertView.setBackgroundColor(0xfff5f7f6);
			}else{
				convertView.setBackgroundColor(Color.TRANSPARENT);
			}
				for (int i = 0; i < dataSize; i++) {
					TextView textView = (TextView)((LinearLayout)convertView).getChildAt(i);
					if (position == 0) {
						textView.setTextColor(0xff000000);
						textView.setTextSize(16);
					}else{
						textView.setTextColor(0xff9a9a9a);
						textView.setTextSize(12);
					}
					textView.setText(mCurrentDatas.get(position).get(i));
					/*textView.setOnClickListener(new OnClickListener() {
						public void onClick(View v) {
						}
					});*/
				}
				
			return convertView;
		}
	}
	
}
