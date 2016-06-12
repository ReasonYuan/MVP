package com.hp.halcyon.widgets.main;


public abstract class FQBaseViewAdapter{
	
	public interface FQBaseViewAdapterObserver{
		public void onDataSetChanged();
	}
	
	private FQBaseViewAdapterObserver mObserver;
	
	public void registerObserver(FQBaseViewAdapterObserver o){
		mObserver = o;
	}
	
	public void notifyDataSetChanged(){
		if (mObserver != null) {
			mObserver.onDataSetChanged();
		}
	}
	
	public abstract int getCount();

	/**
	 * 必须设置childVIew的宽高
	 * @param position
	 * @param convertView
	 * @param parentWidth
	 * @param parentHeight
	 * @return 
	 */
	public abstract FQView getView(int position, FQView convertView,int parentWidth,int parentHeight);

}
