package com.hp.halcyon.widgets.main;

import android.view.View;

public abstract class MainViewAdapter{
	
	public interface MainViewAdapterObserver{
		public void onDataSetChanged();
	}
	
	private MainViewAdapterObserver mObserver;
	
	public void registerObserver(MainViewAdapterObserver o){
		mObserver = o;
	}
	
	public void notifyDataSetChanged(){
		if (mObserver != null) {
			mObserver.onDataSetChanged();
		}
	}
	
	public abstract int getColumnCount();
	
	public abstract int getCount(int column);

	public abstract View getView(int column, int position, View convertView);
	
	public abstract View getHeaderView(int column,View convertView);

}
