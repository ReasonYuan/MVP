package com.hp.android.halcyon.tag;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

import com.fq.android.plus.R;

/**
 * 用户创建的Tag 
 */
@SuppressLint("NewApi")
public class MyTagView extends TagView{

	
	private Button mBtnTag;
	
	public MyTagView(Context mContext) {
		super(mContext);
		initWidgets();
	}

	@Override
	public int getViewId() {
		return R.layout.view_my_tag;
	}

	private void initWidgets() {
		mBtnTag = (Button) mView.findViewById(R.id.view_my_tag_text);
		
		mBtnTag.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				if(mBtnTag.isSelected()){
					mBtnTag.setSelected(false);
					statusChanged.isChanged(false);
				}else{
					mBtnTag.setSelected(true);
					statusChanged.isChanged(true);
				}
			}
		});
	}
	
	@Override
	public void setTagText(final String str, final TagStatusChangedListener statusChanged) {
		this.statusChanged = statusChanged;
		((Activity)mContext).runOnUiThread(new Runnable() {
			public void run() {
				mBtnTag.setText(str);
				mView.setTag(str);
			}
		});
	}

	@Override
	public void setTagText(final String str, final int colorType, final TagStatusChangedListener statusChanged) {
		this.statusChanged = statusChanged;
		((Activity)mContext).runOnUiThread(new Runnable() {
			public void run() {
				mBtnTag.setText(str);
				mView.setTag(str);
			}
		});
	}

	/**设置标签的选中状态*/
	public void setSelected(boolean b){
		mBtnTag.setSelected(b);
	}
}
