package com.hp.android.halcyon;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.tools.AeSimpleSHA1;
import com.hp.android.halcyon.widgets.CustomDialog;

public class LoginActivity extends Activity implements Serializable {

	private static final int RES_INTENT_FOR = 998;

	private static final long serialVersionUID = 1L;
	private String mUserName;
	private String mPassWord;
	private Button mLoginButton;
	private EditText mUserNameEditText;
	private EditText mPassWordEditText;
	private TextView mPwTextView;
	private Button mBtnRegister;
	public static Activity mIntance;

	private LinearLayout mHiden;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		mIntance = this;
		setContentView(R.layout.activity_login);
		initWidget();
		mHiden = (LinearLayout) findViewById(R.id.login_hiden);
		mHiden.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE))
						.hideSoftInputFromWindow(LoginActivity.this
								.getCurrentFocus().getWindowToken(),
								InputMethodManager.HIDE_NOT_ALWAYS);
			}
		});
		
	}

	public void initWidget() {
		mLoginButton = (Button) findViewById(R.id.login);
		mPwTextView = (TextView) findViewById(R.id.tx_password);
		mBtnRegister = (Button) findViewById(R.id.btn_register);
		mUserNameEditText = (EditText) findViewById(R.id.username);
		mPassWordEditText = (EditText) findViewById(R.id.password);

		boolean isb = getIntent().getBooleanExtra("byexit", false);
		ArrayList<String> keys = FileSystem.getInstance().loadLoginUser();
		if (isb) {
			keys.set(1, "");
		}
		;
		if (keys != null) {
			mUserName = keys.get(0);
			mPassWord = keys.get(1);
			mUserNameEditText.setText(keys.get(0));
		}

		mLoginButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				login();
			}
		});
		/*
		 * if(Tools.getNameAndWordFromSp(this)[0] != null){
		 * mUserNameEditText.setText(Tools.getNameAndWordFromSp(this)[0]); }
		 */

		mPwTextView.setOnClickListener(new OnClickListener() {
			// 忘记密码
			@Override
			public void onClick(View arg0) {
				findPassWord();
			}
		});

		mBtnRegister.setOnClickListener(new OnClickListener() {
			public void onClick(View view) {
				Intent mIntent = new Intent();
				mIntent.setClass(LoginActivity.this, RegisterActivity.class);
				startActivity(mIntent);
			}
		});

		if (keys != null && !"".equals(keys.get(0)) && !"".equals(keys.get(1))) {
			goToLoadingActivity(keys);
		}
	}

	public void goToLoadingActivity(ArrayList<String> keys) {
		Intent mIntent = new Intent();
		mIntent.putExtra("mUserName", keys.get(0));
		mIntent.putExtra("mPassWord", keys.get(1));
		mIntent.setClass(this, LoadingActivity.class);
		startActivityForResult(mIntent, 2);
	}

	/**
	 * 手动登录
	 */
	public void login() {
		mUserName = mUserNameEditText.getText().toString().trim();
		mPassWord = mPassWordEditText.getText().toString().trim();
		if (!mUserName.equals("") && !mPassWord.equals("")) {
			Intent mIntent = new Intent();
			mIntent.putExtra("mUserName", mUserName);
			mIntent.putExtra("mPassWord",
					AeSimpleSHA1.repeat20TimesAndSHA1(mPassWord));
			mIntent.setClass(this, LoadingActivity.class);
			startActivityForResult(mIntent, 2);
			// finish();
		} else {
			Toast.makeText(this, "密码或者用户名不能为空", Toast.LENGTH_LONG).show();
		}
	}

	public void findPassWord() {
		Intent mIntent = new Intent();
		String userPhone = mUserNameEditText.getText().toString().trim();
		mIntent.putExtra("user_phone", userPhone);
		mIntent.setClass(this, ForgetPwdActivity.class);
		// startActivity(mIntent);
		startActivityForResult(mIntent, RES_INTENT_FOR);
	}

	public HashMap<String, Object> creatJsonMap() {
		HashMap<String, Object> mMap = new HashMap<String, Object>();
		mMap.put("username", mUserName);
		mMap.put("pass_word", mPassWord);
		return mMap;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		if (requestCode == 2) {
			int resId = R.string.load_failed;
			if (resultCode == 0) {
				resId = R.string.load_failed_net;
			}
			final CustomDialog mCustomDialog = new CustomDialog(
					LoginActivity.this);
			mCustomDialog.setMessage(resId);
			mCustomDialog
					.setPositiveBackground(R.drawable.selector_botton_radiu);
			mCustomDialog.setPositiveListener(R.string.btn_sure,
					new OnClickListener() {
						@Override
						public void onClick(View v) {
							mCustomDialog.dismiss();
							mPassWordEditText.setText("");
						}
					});
		} else if (requestCode == 998) {
			// mUserNameEditText.setText("");
			mPassWordEditText.setText("");
			mUserName = "";
			mPassWord = "";
		}
	}

}
