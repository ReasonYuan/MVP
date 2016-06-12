package com.hp.android.halcyon;

import android.content.Context;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.CountDownTimer;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic.RegisterLogic;
import com.fq.halcyon.logic.RegisterLogic.RegisterLogicListener;
import com.fq.halcyon.logic2.ResquestIdentfyLogic;
import com.fq.halcyon.logic2.ResquestIdentfyLogic.ResIdentfyCallback;
import com.fq.halcyon.logic2.UserInfoManagerLogic;
import com.fq.halcyon.logic2.UserInfoManagerLogic.SuccessCallBack;
import com.fq.halcyon.uilogic.RegisterUILogic;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.AeSimpleSHA1;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.util.UITools;

public class ChangePhoneActivity extends BaseActivity implements
		OnClickListener {

	private Button mBtnChangePhone;
	private EditText mEdtPhone;
	private EditText mEdtPwd;
	private EditText mEdtCode;

	private ImageView mImgPhoneIsRight; // 手机号码格式正确时显示
	private ImageView mImgCodeIsRight; // 验证码正确时显示
	private ImageView mImgPwdIsRight; // 密码正确时显示

	private TextView mOldPhone; // 用户原手机号码
	private String mPassword; // 用户的登录密码
	private String mTextCode; // 服务器返回的验证码
	private TextView mOldPhoneTV;
	private TextView mSureMsg;

	private LinearLayout mLayout; // 点击之后隐藏键盘
	private CountDownTimer mCountTimer; // 验证码的倒计时
	private TextView mGetVertification; // 显示倒计时
	private boolean isPhoneRight;
	private boolean isKeyRight;
	private boolean isVerRight;
	private ResquestIdentfyLogic mIdentLogic; // 获取验证码

	@Override
	public int getContentId() {
		return R.layout.activity_change_phone;
	}

	@Override
	public void init() {
		initWidgets();
		initListener();
		initData();
	}

	/** 初始化控件 */
	private void initWidgets() {
		Typeface mFont = Typeface.createFromAsset(getAssets(),
				"lantingchuheijian.TTF");
		// ((TextView) findViewById(R.id.tv_topbar_text)).setTextColor(Color
		// .parseColor("#535353"));
		// ((TextView) findViewById(R.id.tv_topbar_text)).setTypeface(mFont);
		setTitle("修改手机号");
		mEdtPhone = (EditText) findViewById(R.id.edt_change_phonenumber);
		mEdtPwd = (EditText) findViewById(R.id.edt_change_phone_password);
		mEdtCode = (EditText) findViewById(R.id.edt_change_phone_code);
		mImgPhoneIsRight = (ImageView) findViewById(R.id.img_change_phone_right);
		mImgPwdIsRight = (ImageView) findViewById(R.id.img_change_phone_password_right);
		mImgCodeIsRight = (ImageView) findViewById(R.id.img_change_phone_code_right);
		mBtnChangePhone = (Button) findViewById(R.id.btn_change_phone);
		mOldPhone = (TextView) findViewById(R.id.tv_change_old_phone);
		// Typeface mFont2 = Typeface.createFromAsset(getAssets(),
		// "ElleNovCMed.otf");
		// mOldPhone.setTypeface(mFont2);
		mOldPhoneTV = (TextView) findViewById(R.id.old_phone_tv);
		// mOldPhoneTV.setTypeface(mFont);
		mLayout = (LinearLayout) findViewById(R.id.ll_change_phone);
		mSureMsg = (TextView) findViewById(R.id.sure_msg);
		// mSureMsg.setTypeface(mFont);
		mGetVertification = (TextView) findViewById(R.id.tv_change_phone_get_vertification);
	}

	/** 初始化控件事件 */
	private void initListener() {
		mBtnChangePhone.setOnClickListener(this);
		mEdtPhone.addTextChangedListener(new MyTextWatcher(1));
		mEdtPwd.addTextChangedListener(new MyTextWatcher(2));
		mEdtCode.addTextChangedListener(new MyTextWatcher(3));
		mLayout.setOnClickListener(this);
		mGetVertification.setOnClickListener(this);
	}

	/** 初始化数据 */
	private void initData() {
		mBtnChangePhone.setEnabled(false);
		mOldPhone.setText((Constants.getUser().getPhoneNumber()));
		mPassword = Constants.getUser().getPassword();
	}

	private String get4number(String number) {
		String str = (number + "9").replaceAll("(?<=\\d)(?=(?:\\d{4})+$)", " ");
		return str.substring(0, str.length() - 1);
	}

	/** 监听所有的点击事件 */
	@Override
	public void onClick(View v) {
		if (!UITools.isNetworkAvailable(ChangePhoneActivity.this)) {
			UITools.showToast("请确认已经连接到网络");
			return;
		}
		switch (v.getId()) {
		case R.id.btn_change_phone:
			// 修改手机号
			changePhoneNum();
			break;
		case R.id.ll_change_phone:
			// 隐藏键盘
			InputMethodManager im = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
			im.hideSoftInputFromWindow(getCurrentFocus()
					.getApplicationWindowToken(),
					InputMethodManager.HIDE_NOT_ALWAYS);
			break;
		case R.id.tv_change_phone_get_vertification:
			getCode();
			break;
		default:
			break;
		}
	}

	/** 监听编辑框输入改变事件 */
	public class MyTextWatcher implements TextWatcher {

		/**
		 * 1：修改手机号的改变事件 2：本帐号密码的改变事件 3：验证码的改变事件
		 * */
		private int mStyle;

		public MyTextWatcher(int mStyle) {
			this.mStyle = mStyle;
		}

		@Override
		public void beforeTextChanged(CharSequence s, int start, int count,
				int after) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onTextChanged(CharSequence s, int start, int before,
				int count) {
			// TODO Auto-generated method stub

		}

		@Override
		public void afterTextChanged(Editable s) {
			// TODO Auto-generated method stub
			if (mStyle == 1) {
				// 手机号码
				mImgPhoneIsRight.setVisibility(View.VISIBLE);
				if (s.length() == 11) {
					if (RegisterUILogic.isMobileNO(s.toString())) {
						mImgPhoneIsRight.setSelected(true);
						if (!UITools
								.isNetworkAvailable(ChangePhoneActivity.this)) {
							showToast("请检查网络连接", Toast.LENGTH_LONG);
							return;
						}
						if (mCountTimer != null) {
							mCountTimer.onFinish();
							mCountTimer = null;
						}
						isPhoneRight = true;
						mEdtPhone.clearFocus();
						mEdtPwd.setFocusable(true);
						mEdtPwd.setFocusableInTouchMode(true);
						mEdtPwd.requestFocus();
//						mImgPhoneIsRight.setVisibility(View.VISIBLE);
						validatePhone();
					} else {
						isPhoneRight = false;
						mImgPhoneIsRight.setVisibility(View.VISIBLE);
						mImgPhoneIsRight.setSelected(false);
					}
				} else {
					isPhoneRight = false;
					mImgPhoneIsRight.setSelected(false);
				}
				isAllOK();
			} else if (mStyle == 2) {
				// 密码
				if (AeSimpleSHA1.repeat20TimesAndSHA1(s.toString()).equals(mPassword)) {
					isKeyRight = true;
					mImgPwdIsRight.setVisibility(View.VISIBLE);
					mImgPwdIsRight.setSelected(true);
				} else {
					isKeyRight = false;
					mImgPwdIsRight.setSelected(false);
				}
				isAllOK();
			} else if (mStyle == 3) {
				// 验证码
				if (s.length() == 4) {
					if (s.toString().equals(mTextCode)) {
						isVerRight = true;
						mImgCodeIsRight.setVisibility(View.VISIBLE);
						mImgCodeIsRight.setSelected(true);
					} else {
						isVerRight = false;
						mImgCodeIsRight.setVisibility(View.VISIBLE);
						mImgCodeIsRight.setSelected(false);
					}
				} else {
					mImgCodeIsRight.setSelected(false);
				}
				isAllOK();
			}
		}
	}

	/**
	 * 判断所有输入是否满足，满足则提交按钮可用，否则不可用
	 * */
	private void isAllOK() {
		if (isPhoneRight && isVerRight && isKeyRight) {
			mBtnChangePhone.setEnabled(true);
		} else {
			mBtnChangePhone.setEnabled(false);
		}
	}

	/** 获取验证码的倒计时 */
	private void getCodeCountTimer() {
		mCountTimer = new CountDownTimer(60000, 1000) {
			public void onTick(long millisUntilFinished) {
				mGetVertification.setVisibility(View.VISIBLE);
				mGetVertification.setEnabled(false);
				mGetVertification.setText(millisUntilFinished / 1000 + "\" "
						+ "重新发送");
				mGetVertification.setSelected(true);
			}

			public void onFinish() {
				this.cancel();
				mGetVertification.setText("重新发送");
				mGetVertification.setSelected(false);
				mGetVertification.setEnabled(true);
			}
		};
		mCountTimer.start();
	}

	/** 修改手机号的逻辑 */
	private void changePhoneNum() {
		if (!UITools.isNetworkAvailable(ChangePhoneActivity.this)) {
			UITools.showToast("请确认已经连接到网络");
			return;
		}
		// 修改手机号的逻辑
		UserInfoManagerLogic logic = new UserInfoManagerLogic();
		final String mPhoneNumberStr = mEdtPhone.getText().toString().trim();
		String mVertificationStr = mEdtCode.getText().toString().trim();
		String mPassWordStr = mEdtPwd.getText().toString();
		logic.changeMobile(mPhoneNumberStr, mVertificationStr, AeSimpleSHA1.repeat20TimesAndSHA1(mPassWordStr) ,
				new SuccessCallBack() {

					@Override
					public void onSuccess(int responseCode, String msg,
							int type, Object results) {
						UITools.showToast("修改号码成功");
						FileSystem.getInstance().saveLoginUser(
								Constants.getUser().getPhoneNumber(), "",Constants.getUser().getUserId());
						Intent intent = new Intent(ChangePhoneActivity.this,
								LoginActivity.class);
						intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK
								| Intent.FLAG_ACTIVITY_CLEAR_TASK);
						intent.putExtra("byexit", true);
						startActivity(intent);
						finish();
					}
				}, new UserInfoManagerLogic.FailCallBack() {
					@Override
					public void onFail(int code, String msg) {
						// Tools.showToast("修改手机号失败");
						UITools.showToast(msg);
					}
				});
	}

	private void validatePhone() {
		final String phone = mEdtPhone.getText().toString().trim();
		if (!UITools.isNetworkAvailable(ChangePhoneActivity.this)) {
			showToast("请检查网络连接", Toast.LENGTH_LONG);
			return;
		}
		if (phone == null || "".equals(phone)) {
			UITools.showToast("请输入手机号");
			return;
		}
		if (!RegisterUILogic.isMobileNO(phone)) {
			UITools.showToast("请输入正确的手机号码");
			return;
		}
		runOnUiThread(new Runnable() {
			public void run() {
				mEdtCode.setText("");
			}
		});
		RegisterLogic registerLogic = new RegisterLogic() {
		};
		RegisterLogicListener registerLogicListener = new RegisterLogicListener() {

			@Override
			public void returnData(int responseCode, JSONObject results) {
				// TODO Auto-generated method stub

			}

			@Override
			public void isPhoneExist(boolean isExist) {
				if (isExist) {
					isPhoneRight = false;
					UITools.showToast("该手机号码已经注册过了");
					mImgPhoneIsRight.setSelected(false);
					if (mCountTimer != null) {
						mCountTimer.onFinish();
						mCountTimer = null;
					}
				} else {
					isPhoneRight = true;
					mGetVertification.setEnabled(true);
				}
				isAllOK();
			}

			@Override
			public void error(int code, String msg) {
				// TODO Auto-generated method stub

			}
		};
		registerLogic.setListener(registerLogicListener);
		registerLogic.isPhoneExist(phone);
	}

	/**
	 * 获取验证码
	 */
	private void getCode() {
		// 获取验证码按钮点击事件
		final String phone = mEdtPhone.getText().toString().trim();
		if (!UITools.isNetworkAvailable(ChangePhoneActivity.this)) {
			showToast("请检查网络连接", Toast.LENGTH_LONG);
			return;
		}
		if (phone == null || "".equals(phone)) {
			UITools.showToast("请输入手机号");
			return;
		}
		if (!RegisterUILogic.isMobileNO(phone)) {
			UITools.showToast("请输入正确的手机号码");
			return;
		}
		/*
		 * runOnUiThread(new Runnable() { public void run() {
		 * mEdtCode.setText(""); } });
		 */
		if (mIdentLogic == null) {
			mIdentLogic = new ResquestIdentfyLogic(new ResIdentfyCallback() {

				@Override
				public void resIdentfy(String identfy) {
					runOnUiThread(new Runnable() {
						public void run() {
							// UITools.showToast("已发送验证码至您填入的手机号");
						}
					});
					mTextCode = identfy;
					if (Constants.DEBUG) {
						showToast("验证码:" + identfy, Toast.LENGTH_SHORT);
					}
				}

				@Override
				public void resIdentError(int code, String msg) {
					if (mCountTimer != null) {
						mCountTimer.onFinish();
						mCountTimer = null;
					}
					showToast("获取验证码失败", Toast.LENGTH_SHORT);
				}
			});
		}
		getCodeCountTimer();
		mIdentLogic.reqIdentfy(phone, 3);
	}
}
