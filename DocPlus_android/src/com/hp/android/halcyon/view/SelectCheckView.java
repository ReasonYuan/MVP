package com.hp.android.halcyon.view;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.lib.record.RecordConstants;

public class SelectCheckView {

	private int[] mCheckItems;
	
	private View mView;

	private Context mContext;
	
	private SelectCheckItemCallBack mCallback;

	public SelectCheckView(Context context,SelectCheckItemCallBack callback) {
		mContext = context;
		mCallback = callback;
		
		mView = LayoutInflater.from(mContext).inflate(
				R.layout.view_take_photo_select_check, null);

		ListView listView = (ListView) mView
				.findViewById(R.id.lv_select_check_item);
		listView.setAdapter(new CheckItemAdapter());
		listView.setOnItemClickListener(new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				dismiss();
				if(mCallback != null)mCallback.doback(mCheckItems[position]);
			}
		});
		mView.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				dismiss();
			}
		});
	}

	public boolean isShow(){
		return mView.isShown();
	}
	
	public void show(ViewGroup parent) {
		parent.addView(mView);
		AlphaAnimation alphaAnimation = new AlphaAnimation(0, 1);
		alphaAnimation.setDuration(800);
		mView.startAnimation(alphaAnimation);
	}

	public void dismiss() {
		try {
			AlphaAnimation alphaAnimation = new AlphaAnimation(1, 0);
			alphaAnimation.setDuration(800);
			mView.startAnimation(alphaAnimation);
			((ViewGroup) mView.getParent()).removeView(mView);
		} catch (Exception e) {
			((ViewGroup) mView.getParent()).removeView(mView);
		}
	}

	public class CheckItemAdapter extends BaseAdapter {

		public CheckItemAdapter() {
			mCheckItems = RecordConstants.getCheckItemIds();
		}

		@Override
		public int getCount() {
			return mCheckItems.length;
		}

		@Override
		public Object getItem(int position) {
			return null;
		}

		@Override
		public long getItemId(int position) {
			return 0;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(mContext).inflate(
						R.layout.item_check_item_view, null);
			}

			((TextView) convertView.findViewById(R.id.tv_btn_list_text))
					.setText(RecordConstants.getTypeNameByRecordType(mCheckItems[position]));
			return convertView;
		}
	}
	
	public interface SelectCheckItemCallBack{
		public void doback(int type);
	}
}
