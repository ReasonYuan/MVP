package com.hp.android.halcyon.widgets;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnKeyListener;
import android.view.KeyEvent;
import android.view.Window;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.hp.android.halcyon.view.LoadingView;


/**
 * 自定义对话框
 */
public class CustomProgressDialog {
	Context mContext;
	android.app.AlertDialog mAlertDialog;
	TextView mMsgView;
	LinearLayout mButtonLayout;
	Button mBtnSure;
	Button mBtnCancel;
	FrameLayout mFlContainer;
	private LoadingView mLoadingView;
	
	@SuppressLint("NewApi")
	public CustomProgressDialog(Context context) {
		// TODO Auto-generated constructor stub
		this.mContext=context;
		mAlertDialog=new android.app.AlertDialog.Builder(context).create();//R.style.DialogFullScreen
		mAlertDialog.show();
		//关键在下面的两行,使用window.setContentView,替换整个对话框窗口的布局
		Window window = mAlertDialog.getWindow();
		window.setContentView(R.layout.dialog_progress);
//		WindowManager.LayoutParams lp = window.getAttributes();
//		lp.dimAmount = 0.9f;
		mLoadingView = (com.hp.android.halcyon.view.LoadingView)mAlertDialog.findViewById(R.id.progress_bar);
		mMsgView=(TextView)window.findViewById(R.id.tv_progress_msg);
		mFlContainer = (FrameLayout) window.findViewById(R.id.fl_dialog_container);
		setCanceledOnTouchOutside(false);
		mAlertDialog.setOnKeyListener(new OnKeyListener() {
			public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
				if(keyCode == KeyEvent.KEYCODE_BACK){
					//改成可以取消的对话框，避免在部分情况下永远都不能操作
					mAlertDialog.cancel();
					return true;
				}
				return false;
			}
		});
		mLoadingView.startAnim();
	}
	
	public void setCanceledOnTouchOutside(boolean cancel){
		mAlertDialog.setCanceledOnTouchOutside(cancel);
	}
	
	public void setCancelable(boolean cancel){
		mAlertDialog.setCancelable(cancel);
	}
	
	public void setMessage(int resId) {
		mMsgView.setText(resId);
	}
 
	public void setMessage(String message)
	{
		mMsgView.setText(message);
	}
	
	/**
	 * 关闭对话框
	 */
	public void dismiss() {
		mAlertDialog.dismiss();
		mLoadingView.stopAnim();
	}
}
