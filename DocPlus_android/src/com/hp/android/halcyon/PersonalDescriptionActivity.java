package com.hp.android.halcyon;

import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.lib.tools.Constants;

public class PersonalDescriptionActivity extends BaseActivity {
	private EditText mPDEditText;
	private TextView mCount;
	public static final int REQUEST_CODE = 0x4;
	public static final int RESULT_CODE = 0x5;
	public static final int PERSON_DESCROPTION_RESULT_CODE = 0x6;
	public static final int MAX_COUNT = 500;

	@Override
	public int getContentId() {
		return R.layout.activity_personal_description;
	}

	@Override
	public void init() {
		setTitle(getString(R.string.personal_profile));
		mCount = (TextView) findViewById(R.id.tv_description_count);
		mPDEditText = (EditText) findViewById(R.id.pde);
		mPDEditText.setText(Constants.getUser().getDescription());
		if (!TextUtils.isEmpty(mPDEditText.getText())) {
			Editable editable = mPDEditText.getText();
			mPDEditText.setSelection(editable.length());
		}
		if (getIntent().getStringExtra("personal_profile") != null) {
			mPDEditText.setText(getIntent().getStringExtra("personal_profile"));
		}
		mPDEditText.addTextChangedListener(mTextWatcher);
		setLeftCount();
	}

	public String getPersonnalMessage() {
		String mMessage = mPDEditText.getText().toString().trim();
		return mMessage;
	}

	public void onDesSureClick(View v){
		if (!TextUtils.isEmpty(mPDEditText.getText())) {
			String des = mPDEditText.getText().toString();
			if(!des.equals(Constants.getUser().getDescription())){
				Constants.getUser().setDescription(des);
				setResult(UserProfileActivity.CHANGE_DESCRIPTION_RESULT);
			}
		}
		this.finish();
	}
	
	private TextWatcher mTextWatcher = new TextWatcher() {

		int editStart;
		int editEnd;

		@Override
		public void onTextChanged(CharSequence s, int start, int before,
				int count) {
		}

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count,
				int after) {
		}

		@Override
		public void afterTextChanged(Editable s) {
			editStart = mPDEditText.getSelectionStart();
			editEnd = mPDEditText.getSelectionEnd();
			// 先去掉监听器，否则会出现栈溢出
			mPDEditText.removeTextChangedListener(mTextWatcher);
			// 注意这里只能每次都对整个EditText的内容求长度，不能对删除的单个字符求长度
			// 因为是中英文混合，单个字符而言，calculateLength函数都会返回1
			while (calculateLength(s.toString()) > MAX_COUNT) {
				// 当输入字符个数超过限制的大小时，进行截断操作
				s.delete(editStart - 1, editEnd);
				editStart--;
				editEnd--;
			}
			
			mPDEditText.setSelection(editStart);

			// 恢复监听器
			mPDEditText.addTextChangedListener(mTextWatcher);

			setLeftCount();
		}
	};

	/**
	 * 计算内容的字数，一个汉字=两个英文字母，一个中文标点=两个英文标点 注意：该函数的不适用于对单个字符进行计算，因为单个字符四舍五入后都是1
	 * 
	 * @param c
	 * @return
	 */
	private long calculateLength(CharSequence c) {
		double len = 0;
		for (int i = 0; i < c.length(); i++) {
//			int tmp = (int) c.charAt(i);
//			if (tmp > 0 && tmp < 127) {
//				len += 0.5;
//			} else {
//				len++;
//			}
			len++;
		}
		return Math.round(len);
	}
	
    /** 
     * 刷新剩余输入字数
     */  
    private void setLeftCount() {  
    	mCount.setText(String.valueOf((MAX_COUNT - getInputCount())));  
    }  
  
    /** 
     * 获取用户输入的内容字数 
     *  
     * @return 
     */  
    private long getInputCount() {  
        return calculateLength(mPDEditText.getText().toString());  
    } 
}
