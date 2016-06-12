package com.hp.android.halcyon.tag;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;

/**
 * 已经和某个人绑定的tag 
 */
public class PersonTagView extends TagView{
	
	/**标签内容*/
	private TextView mTextTag;
	/**删除标签的按钮*/
	private FrameLayout mDelTag;
	
	public PersonTagView(Context mContext) {
		super(mContext);
		initWidgets();
	}
	
	@Override
	public int getViewId() {
		return R.layout.view_person_tag;
	}
	
	private void initWidgets() {
		mTextTag = (TextView) mView.findViewById(R.id.view_person_tag_text);
		mDelTag = (FrameLayout) mView.findViewById(R.id.view_person_tag_del);
		
		mTextTag.setOnClickListener(new OnClickListener() {
			//标签内容的点击事件
			@Override
			public void onClick(View v) {
				if(mDelTag.getVisibility() == View.GONE){
					mDelTag.setVisibility(View.VISIBLE);
					statusChanged.onClick(mView);
				}else{
					mDelTag.setVisibility(View.GONE);
				}
			}
		});
		
		mDelTag.setOnClickListener(new OnClickListener() {
			//删除标签的按钮点击事件
			@Override
			public void onClick(View view) {
				removeView();
				statusChanged.isChanged(true);
			}
		});
	}
	
	/**
	 * 设置标签内容
	 * @param str  标签的显示内容
	 */
	public void setTagText(final String str, final TagStatusChangedListener statusChanged){
		this.statusChanged = statusChanged;
		((Activity)mContext).runOnUiThread(new Runnable() {
			public void run() {
				mTextTag.setText(str);
				mView.setTag(str);
			}
		});
	}
	
	/**
	 * 设置删除键为不可见状态
	 */
	public void setDelTagGone(){
		mDelTag.setVisibility(View.GONE);
	}
	
	/**
	 * 设置删除键为不可见状态
	 */
	public void setDelTagVisible(){
		mDelTag.setVisibility(View.VISIBLE);
	}
	
	/**
	 * 设置标签内容
	 * @param str  标签的显示内容
	 * @param colorType   奇数：显示green，偶数：显示pink
	 */
	public void setTagText(final String str, final int colorType , final TagStatusChangedListener statusChanged){
		this.statusChanged  = statusChanged;
		((Activity)mContext).runOnUiThread(new Runnable() {
			public void run() {
				mTextTag.setText(str);
				if(colorType % 2 == 0){
					mTextTag.setBackgroundColor(mContext.getResources().getColor(R.color.app_pink));
				}else{
					mTextTag.setBackgroundColor(mContext.getResources().getColor(R.color.app_green));
				}
				mView.setTag(str);
			}
		});
	}

	/**将View从父控件中移除*/
	public void removeView(){
		if(getView().getParent() != null){
			((ViewGroup)getView().getParent()).removeView(getView());
			mDelTag.setVisibility(View.GONE);
		}
	}
	
}
