package com.hp.halcyon.widgets.main;


public abstract class MainViewAdapter2{
	
	public interface MainViewAdapterObserver{
		public void onDataSetChanged();
	}
	
	protected MainViewAdapterObserver mObserver;
	
	public void registerObserver(MainViewAdapterObserver o){
		mObserver = o;
	}
	
	public void notifyDataSetChanged(){
		if (mObserver != null) {
			mObserver.onDataSetChanged();
		}
	}
	
	/**
	 * 
	 * @return
	 */
	public abstract int getCountOfMonth();
	
	/**
	 * 有几天
	 * @param monthPosition  
	 * @return
	 */
	public abstract int getCountOfDay(int monthPosition);
	
	public abstract int getCount(int monthPosition, int dayPosition);

	public abstract FQView getItemView(int monthPosition, int dayPosition,int position, FQView convertView);
	
	public abstract void resetItemView(int monthPosition, int dayPosition,int position, FQView convertView);
	
	public abstract FQView getHeaderView(int monthPosition, int dayPosition, FQView convertView);
	
	/**
	 * @return 1- 12
	 */
	public abstract int getMonthIndex(int monthPosition);
	
	public abstract boolean isT(int monthPosition,int dayPosition);
	
	public abstract FQView getTView(int monthPosition, int dayPosition, FQView convertView);
	
	public abstract FQView getMoreView(int monthPosition, int dayPosition, FQView convertView);
	
	public abstract int getCurrentDayIndex();
	
	public abstract long getFirstDate();
	
	public abstract long getLastDate();
}
