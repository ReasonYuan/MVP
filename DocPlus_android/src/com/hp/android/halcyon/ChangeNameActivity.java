package com.hp.android.halcyon;

import android.text.Editable;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.fq.lib.tools.Constants;

public class ChangeNameActivity extends BaseActivity {

	private EditText mChangeName;
	private LinearLayout mOutLinearLayout;
	@Override
	public int getContentId() {
		return R.layout.activity_change_name;
	}

	@Override
	public void init() {
		setTitle("更改名字");
		setContainerTop();
		hideTitleLine();
		setTopLeftBtnEnable(true);

		mChangeName = (EditText) findViewById(R.id.et_change_name);
		mChangeName.setText(Constants.getUser().getName());

		if (!TextUtils.isEmpty(mChangeName.getText().toString().trim())) {
			Editable editable = mChangeName.getText();
			mChangeName.setSelection(editable.length());
		}
		
		mOutLinearLayout = (LinearLayout) findViewById(R.id.out_linearlayout);
		mOutLinearLayout.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				((InputMethodManager)getSystemService(INPUT_METHOD_SERVICE)).hideSoftInputFromWindow(ChangeNameActivity.this.getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);  
			}
		});
	}
	
	public void onChangeNameSureClick(View v) {
		if (TextUtils.isEmpty(mChangeName.getText().toString().trim())) {
			Toast.makeText(this, "姓名不能为空", Toast.LENGTH_LONG).show();
			return;
		}
		String name = mChangeName.getText().toString().trim();
		if (name.equals(Constants.getUser().getName())) {
			finish();
			return;
		} else {
			Constants.getUser().setName(mChangeName.getText().toString().trim());//setNickName
			setResult(UserProfileActivity.CHANGE_NAME_RESULT);
			finish();
		}
	}

	/*
	 * @Override public void onTopLeftBtnClick(View view) {
	 * if(TextUtils.isEmpty(mChangeName.getText())){ Toast.makeText(this,
	 * "姓名不能为空", Toast.LENGTH_LONG).show(); return; } String name =
	 * mChangeName.getText().toString().trim();
	 * if(name.equals(Constants.getUser().getName())){ finish(); return; }else{ final
	 * CustomDialog dialog = new CustomDialog(ChangeNameActivity.this);
	 * dialog.setTitle("名字有改动，是否保存？");
	 * dialog.setPositiveListener(R.string.btn_yes, new OnClickListener() {
	 * 
	 * @Override public void onClick(View v) {
	 * Constants.getUser().setNickname(mChangeName.getText().toString().trim());
	 * setResult(UserProfileActivity.CHANGE_NAME_RESULT); dialog.dismiss();
	 * finish(); } }); dialog.setNegativeButton(R.string.btn_no, new
	 * OnClickListener() {
	 * 
	 * @Override public void onClick(View v) { dialog.dismiss(); finish(); } });
	 * } }
	 */
}
