package com.hp.android.halcyon;

import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic2.ChangeDPNameLogic;
import com.fq.halcyon.logic2.ChangeDPNameLogic.ChangeDPNameCallback;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

public class SettingPlusIdActivity extends BaseActivity implements ChangeDPNameCallback{
	
	private TextView mOnlyEnNum;
	private CustomProgressDialog dialog;
	private ChangeDPNameLogic mLogic;
	
	private String mDPName;
	
	@Override
	public int getContentId() {
		return R.layout.activity_setting_plus_id;
	}

	@Override
	public void init() {
		initWidgets();
	}

	
	private void initWidgets() {
//		((TextView) findViewById(R.id.tv_topbar_text)).setTextColor(Color
//				.parseColor("#535353"));
//		Typeface mFont = Typeface.createFromAsset(getAssets(),
//				"lantingchuheijian.TTF");
//		((TextView) findViewById(R.id.tv_topbar_text)).setTypeface(mFont);
		setTitle("医加号");
		mOnlyEnNum = (TextView) findViewById(R.id.only_en_num);
//		mOnlyEnNum.setTypeface(mFont);
		
		mLogic = new ChangeDPNameLogic();
	}
	
	public void onDPNameSureClick(View v){
		mDPName = ((EditText) findViewById(R.id.edt_setting_plus_id)).getText().toString().trim();
		if("".equals(mDPName) || mDPName == null){
			return;
		}
		dialog = new CustomProgressDialog(this);
		dialog.setMessage("正在提交信息");
		mLogic.changeDPName(mDPName, this);
	}

	@Override
	public void onError(int code, Throwable error) {
		if(dialog != null){
			dialog.dismiss();
			dialog = null;
		}
		UITools.showToast("医加号已经存在");
	}

	@Override
	public void feedChangeDPName(boolean isSuccess,String msg) {
		if(dialog != null){
			dialog.dismiss();
			dialog = null;
		}
		if(isSuccess){
			UITools.showToast("设置成功");
			Constants.getUser().setDPName(mDPName);
			FileSystem.getInstance().saveCurrentUser();
			((EditText) findViewById(R.id.edt_setting_plus_id)).setEnabled(false);
			findViewById(R.id.btn_setting_plus_id).setEnabled(false);
			onBackPressed();
		}else{
			UITools.showToast("已有用户注册");
		}
	}
}
