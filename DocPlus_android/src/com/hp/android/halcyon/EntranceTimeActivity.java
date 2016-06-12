package com.hp.android.halcyon;

import android.text.Editable;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.widgets.CustomDialog;

public class EntranceTimeActivity extends BaseActivity{

	private EditText mEditView;
	
	@Override
	public int getContentId() {
		return R.layout.activity_change_name;
	}

	@Override
	public void init() {
		setTitle("入学时间");
		setTopRightBtnEnable(true);
		setTopRightImgSrc(R.drawable.icon_sure);
		
		mEditView = (EditText) findViewById(R.id.et_change_name);
		mEditView.setText(Constants.getUser().getEntranceTime());
		if(!TextUtils.isEmpty(mEditView.getText())){
			//如果EditText不为空，将光标移动到文字末尾
			Editable editable = mEditView.getText();
			mEditView.setSelection(editable.length());
		}
	}

	/**
	 *保存按钮点击事件 
	 */
	@Override
	public void onTopRightBtnClick(View view) {
		
		if(TextUtils.isEmpty(mEditView.getText())){
			Toast.makeText(this, "时间不能为空", Toast.LENGTH_LONG).show();
			return;
		}
		String time = mEditView.getText().toString().trim();
		if(time.equals(Constants.getUser().getEntranceTime())){
			finish();
			return;
		}else{
			Constants.getUser().setEntranceTime(mEditView.getText().toString().trim());
			setResult(UserProfileActivity.CHANGE_DOCSTD_ENTRANCETIME);
			finish();
		}
	}
	
	/**
	 *退出按钮点击事件 
	 */
	@Override
	public void onTopLeftBtnClick(View view) {
		if(TextUtils.isEmpty(mEditView.getText())){
			Toast.makeText(this, "时间不能为空", Toast.LENGTH_LONG).show();
			return;
		}
		String time = mEditView.getText().toString().trim();
		if(time.equals(Constants.getUser().getEntranceTime())){
			finish();
			return;
		}else{
			final CustomDialog dialog = new CustomDialog(this);
			dialog.setTitle("时间有改动，是否保存？");
			dialog.setPositiveListener(R.string.btn_yes, new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					Constants.getUser().setEntranceTime(mEditView.getText().toString().trim());
					setResult(UserProfileActivity.CHANGE_DOCSTD_ENTRANCETIME);
					dialog.dismiss();
					finish();
				}
			});
			dialog.setNegativeButton(R.string.btn_no, new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					dialog.dismiss();
					finish();
				}
			});
		}
	}
}
