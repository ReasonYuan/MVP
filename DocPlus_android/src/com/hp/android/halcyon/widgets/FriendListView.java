package com.hp.android.halcyon.widgets;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ListView;

import com.fq.android.plus.R;

public class FriendListView {
	
	//private int mRoleType;
	private Context mContext;
	
	private View mView;
	
	public View getView(){
		return mView;
	}
	
	public FriendListView(Context context,int type){
		//mRoleType = type;
		mContext = context;
		mView = LayoutInflater.from(context).inflate(R.layout.view_friend_list, null);
		mView.setBackgroundColor(0xff3344);
		ListView listView = (ListView) mView.findViewById(R.id.lv_friend_list);
		listView.setAdapter(new FriendListAdapter());
	}
	
	
	
	
	class FriendListAdapter extends BaseAdapter{

		@Override
		public int getCount() {
			return 10;
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
			if(convertView == null){
				convertView = LayoutInflater.from(mContext).inflate(R.layout.item_friend_list, null);
			}
			return convertView;
		}
	}
}

