package com.hp.android.halcyon.widgets;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.fq.android.plus.R;


/**
 * 自定义对话框
 */
@SuppressLint("NewApi")
public class CustomDialog {
	Context mContext;
	android.app.AlertDialog mAlertDialog;
	TextView mTitleView;
	TextView mMsgView;
	LinearLayout mButtonLayout;
	Button mBtnSure;
	Button mBtnCancel;
	FrameLayout mFlContainer;
	FrameLayout mOnlyContainer;
	LinearLayout mAllContent;
	public CustomDialog(Context context) {
		// TODO Auto-generated constructor stub
		this.mContext=context;
		mAlertDialog=new android.app.AlertDialog.Builder(context,R.style.DialogFullScreen).create();
		mAlertDialog.show();
		
		//关键在下面的两行,使用window.setContentView,替换整个对话框窗口的布局
		Window window = mAlertDialog.getWindow();
		window.setContentView(R.layout.dialog_layout);
		window.clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);//不隐藏键盘
		
		//titleView=(TextView)window.findViewById(R.id.dialog_msg);
		initUI(window);
	}
	
	private void initUI(Window window){
		mMsgView=(TextView)window.findViewById(R.id.dialog_msg);
		mTitleView = (TextView)window.findViewById(R.id.tv_dialog_title);
		//buttonLayout=(LinearLayout)window.findViewById(R.id.dialog_btn_linear);
		mBtnSure = (Button) window.findViewById(R.id.btn_dialog_sure);
		mBtnCancel = (Button) window.findViewById(R.id.btn_dialog_cancel);
		mFlContainer = (FrameLayout) window.findViewById(R.id.fl_dialog_container);
		mOnlyContainer = (FrameLayout) window.findViewById(R.id.fl_only_dialog_container);
		mAllContent = (LinearLayout) window.findViewById(R.id.ll_dialog_content);
	}
	
	public void setCanceledOnTouchOutside(boolean cancel){
		mAlertDialog.setCanceledOnTouchOutside(cancel);
	}
	
	public void setCancelable(boolean flag){
		mAlertDialog.setCancelable(flag);
	}
	
	public void setTitle(int resId)
	{
		mTitleView.setText(resId);
		mTitleView.setVisibility(View.VISIBLE);
	}
	public void setTitle(String title) {
		mTitleView.setText(title);
		mTitleView.setVisibility(View.VISIBLE);
	}
	public void setMessage(int resId) {
		mMsgView.setText(resId);
	}
 
	public void setMessage(String message)
	{
		mMsgView.setText(message);
	}
	
	/**
	 * 消极按钮
	 * @param text
	 * @param listener
	 */
	public void setNegativeButton(int btnId,final View.OnClickListener listener){
		 mBtnCancel.setText(btnId);
		 mBtnCancel.setVisibility(View.VISIBLE);
		 mBtnCancel.setOnClickListener(listener);
	}
	
	/**
	 * 积极按钮
	 * @param text
	 * @param listener
	 */
	public void setPositiveListener(int btnId,View.OnClickListener listener){
		mBtnSure.setText(btnId);
		mBtnSure.setVisibility(View.VISIBLE);
		mBtnSure.setOnClickListener(listener);
	}
	
	public void setPositiveBtnSignle(int btnId,View.OnClickListener listener){
		mBtnSure.setText(btnId);
		mBtnSure.setVisibility(View.VISIBLE);
		mBtnSure.setOnClickListener(listener);
		mBtnSure.setBackgroundResource(R.drawable.selector_btn_dialog);
	}

	public void setPositiveBackground(int resid){
		mBtnSure.setBackgroundResource(resid);
	}
	
	
	public void setContainer(View view){
		mFlContainer.setVisibility(View.VISIBLE);
		mFlContainer.addView(view);
	}
	
	/**
	 * 创建自定义布局
	 */
	public void setOnlyContainer(View view){
		mOnlyContainer.setVisibility(View.VISIBLE);
		mOnlyContainer.addView(view);
		mAllContent.setVisibility(View.GONE);
	}
	
	public void setView(int resId){
		mAlertDialog.getWindow().setContentView(resId);
	}
	/**
	 * 关闭对话框
	 */
	public void dismiss() {
		mAlertDialog.dismiss();
	}
 
	public void show(){
		mAlertDialog.show();
	}
}
