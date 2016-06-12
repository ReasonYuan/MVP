package com.hp.android.halcyon.widgets;

import android.content.Context;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.fq.android.plus.R;


/**
 * 自定义对话框
 */
public class LittleTextDialog {
	Context mContext;
	android.app.AlertDialog mAlertDialog;
	TextView mMsgView;
	public LittleTextDialog(Context context) {
		// TODO Auto-generated constructor stub
		this.mContext=context;
		mAlertDialog=new android.app.AlertDialog.Builder(context).create();
		mAlertDialog.show();
		mAlertDialog.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);//不隐藏键盘
		//关键在下面的两行,使用window.setContentView,替换整个对话框窗口的布局
		Window window = mAlertDialog.getWindow();
		window.setContentView(R.layout.dialog_text_layout);
		//titleView=(TextView)window.findViewById(R.id.dialog_msg);
		initUI(window);
	}
	
	private void initUI(Window window){
		mMsgView=(TextView)window.findViewById(R.id.tv_dialog_text_content);
	}
	
	public void setCanceledOnTouchOutside(boolean cancel){
		mAlertDialog.setCanceledOnTouchOutside(cancel);
	}
	
	public void setMessage(int resId) {
		mMsgView.setText(resId);
	}
 
	public void setMessage(String message)
	{
		mMsgView.setText(message);
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
 
}
