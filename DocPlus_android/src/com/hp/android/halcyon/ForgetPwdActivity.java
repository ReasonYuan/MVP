package com.hp.android.halcyon;

import android.content.Intent;
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
import com.fq.halcyon.logic2.ResquestIdentfyLogic;
import com.fq.halcyon.logic2.ResquestIdentfyLogic.ResIdentfyCallback;
import com.fq.halcyon.logic2.UserInfoManagerLogic;
import com.fq.halcyon.uilogic.RegisterUILogic;
import com.fq.lib.tools.AeSimpleSHA1;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.Tool;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomProgressDialog;
import com.hp.android.halcyon.widgets.LittleTextDialog;
import com.hp.android.halcyon.widgets.SwitchButton;

public class ForgetPwdActivity extends BaseActivity implements OnClickListener {

	private LinearLayout mChoseRole;
	private Button mBtnResetPwd;
	private Button mBtnBack;
	private TextView mPwdLabel;
	// private TextView mTextNote; //提示用户手机号是否正确以及正在发送验证码
	private EditText mEdtPhone; // 用户手机号
	private EditText mEdtPassword; // 用户密码
	private EditText mEdtCode; // 验证码
	private ImageView mImgPhoneIsRight; // 手机号码格式正确时显示
	private ImageView mImgPwdIsRight; // 密码输入符合要求时显示
	private ImageView mImgCodeIsRight; // 验证码正确时显示
	private String mTextCode; // 服务器返回的验证码

	private TextView mTextLabelNote; // 在此界面需要隐藏的控件
	private SwitchButton mSwithcButton; // 在此界面需要隐藏的控件
	private LinearLayout mLayoutDeal; // 在此界面需要隐藏的控件
	private ImageView mImgIcon; // 在此界面需要隐藏的控件

	private TextView mTextTitle; // 用于设置界面的标题
	private TextView mTextNotice; // 由于用户输入错误时提示
	private String phoneNum;
	private String password;
	private String vertification;

	private boolean isPhoneRight;
	private boolean isKeyRight;
	private boolean isVerRight;

	private CountDownTimer mCountTimer; // 验证码的倒计时
	private TextView mGetVertification; // 显示倒计时

	private boolean isForgetPwd = true; // 判断是忘记密码还是修改密码，true：忘记密码，false：修改密码

	private LinearLayout mOutHide;

	@Override
	public int getContentId() {
		return R.layout.activity_forgetpw;
	}

	@Override
	public void init() {
		isForgetPwd = getIntent().getBooleanExtra("isForgetPwd", true);
		initWidgets();
		initListener();
		mOutHide = (LinearLayout) findViewById(R.id.out_hide_changge_pw);
		mOutHide.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE))
						.hideSoftInputFromWindow(ForgetPwdActivity.this
								.getCurrentFocus().getWindowToken(),
								InputMethodManager.HIDE_NOT_ALWAYS);
			}
		});
	}

	private void initWidgets() {
		// setContainerTop();
		setTitle("重设密码");
		mChoseRole = (LinearLayout) findViewById(R.id.ll_register_selector_role);
		mChoseRole.setVisibility(View.GONE);
		mBtnResetPwd = (Button) findViewById(R.id.register_button);
		mBtnBack = (Button) findViewById(R.id.btn_register_back);
		mPwdLabel = (TextView) findViewById(R.id.tv_register_pwd_label);
		mBtnResetPwd.setText("重设密码");
		mBtnBack.setText("返回");
		mPwdLabel.setText("新密码");
		mEdtPhone = (EditText) findViewById(R.id.register_phonenumber);
		mEdtPassword = (EditText) findViewById(R.id.register_password);
		mEdtPassword.setHint("新密码");
		mEdtCode = (EditText) findViewById(R.id.et_vertification);
		mImgPhoneIsRight = (ImageView) findViewById(R.id.img_register_right);
		mImgCodeIsRight = (ImageView) findViewById(R.id.img_register_vertification_right);
		mImgPwdIsRight = (ImageView) findViewById(R.id.img_register_password_right);
		mTextLabelNote = (TextView) findViewById(R.id.tv_register_privacy_label);
		mTextLabelNote.setVisibility(View.GONE);
		mSwithcButton = (SwitchButton) findViewById(R.id.sb_register_selector_role);
		mSwithcButton.setVisibility(View.GONE);
		mLayoutDeal = (LinearLayout) findViewById(R.id.ll_register_deal);
		mLayoutDeal.setVisibility(View.INVISIBLE);
		mImgIcon = (ImageView) findViewById(R.id.img_register_app_icon);
		// mImgIcon.setVisibility(View.GONE);
		mTextTitle = (TextView) findViewById(R.id.register_title);
		mTextNotice = (TextView) findViewById(R.id.tv_forgetpw_input_wrong);
		if (isForgetPwd) {
			mTextTitle.setText("忘记密码");
			String userPhone = getIntent().getStringExtra("user_phone");
			if (Tool.isMobileNO(userPhone)) {
				phoneNum = userPhone;
				mEdtPhone.setText(userPhone);
			}

			if (!(userPhone.equals(""))&&judgePhome(userPhone)) {
				mImgPhoneIsRight.setVisibility(View.VISIBLE);
			}

		} else {
			mTextTitle.setText("修改密码");
		}
		mTextTitle.setVisibility(View.GONE);
		mBtnResetPwd.setEnabled(false);
		mGetVertification = (TextView) findViewById(R.id.get_vertification);
	}

	private void initListener() {
		mBtnResetPwd.setOnClickListener(this);
		mBtnBack.setOnClickListener(this);
		mGetVertification.setOnClickListener(this);
		mEdtPhone.addTextChangedListener(new TextWatcher() {
			// 手机号输入改变的事件监听
			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				// TODO Auto-generated method stub
			}

			@Override
			public void beforeTextChanged(CharSequence arg0, int arg1,
					int arg2, int arg3) {
				// TODO Auto-generated method stub

			}

			@Override
			public void afterTextChanged(Editable s) {
				if (s.length() == 11) {
					judgePhome(s.toString());
				} else {
					isPhoneRight = false;
					mImgPhoneIsRight.setSelected(false);
					mImgPhoneIsRight.setVisibility(View.VISIBLE);
					// if(mCountTimer != null){
					// mCountTimer.cancel();
					// }
					// mGetVertification.setVisibility(View.GONE);
					mEdtCode.setText("");
				}
				isAllOK();
			}
		});

		mEdtCode.addTextChangedListener(new TextWatcher() {
			// 验证码输入框改变事件的监听
			@Override
			public void onTextChanged(CharSequence arg0, int arg1, int arg2,
					int arg3) {
				// TODO Auto-generated method stub

			}

			@Override
			public void beforeTextChanged(CharSequence arg0, int arg1,
					int arg2, int arg3) {
				// TODO Auto-generated method stub

			}

			@Override
			public void afterTextChanged(Editable s) {
				if (s.length() == 4) {
					if (s.toString().equals(mTextCode)) {
						isVerRight = true;
						mImgCodeIsRight.setVisibility(View.VISIBLE);
						mImgCodeIsRight.setSelected(true);
						// if(mCountTimer != null){
						// mCountTimer.cancel();
						// }
						// mGetVertification.setVisibility(View.GONE);
					} else {
						isVerRight = false;
						mImgCodeIsRight.setVisibility(View.VISIBLE);
						mImgCodeIsRight.setSelected(false);
						mEdtPhone.setEnabled(true);
					}
				} else {
					isVerRight = false;
					mImgCodeIsRight.setSelected(false);
					mEdtPhone.setEnabled(true);
				}
				isAllOK();
			}
		});

		mEdtPassword.addTextChangedListener(new TextWatcher() {

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
				mImgPwdIsRight.setVisibility(View.VISIBLE);
				if (RegisterUILogic.checkPassword(s.toString())) {
					isKeyRight = true;
					mImgPwdIsRight.setSelected(true);
				} else {
					isKeyRight = false;
					mImgPwdIsRight.setSelected(false);
				}
				isAllOK();
			}
		});
	}

	/**
	 * 判断所有的输入是否正确
	 */
	private void isAllOK() {
		if (isPhoneRight && isVerRight && isKeyRight) {
			mBtnResetPwd.setEnabled(true);
			mTextNotice.setVisibility(View.INVISIBLE);
		} else {
			mBtnResetPwd.setEnabled(false);
			String password = mEdtPassword.getText().toString();
			if (!isKeyRight && password.length() > 0) {
				mTextNotice.setText("请输入6~20位的数字与字母的密码组合");
				mTextNotice.setVisibility(View.VISIBLE);
			} else {
				mTextNotice.setVisibility(View.INVISIBLE);
			}
		}
	}

	/**
	 * 点击事件
	 */
	@Override
	public void onClick(View view) {
		if (!UITools.isNetworkAvailable(ForgetPwdActivity.this)) {
			UITools.showToast("请确认已经连接到网络");
			return;
		}
		switch (view.getId()) {
		case R.id.register_button:
			// 注册按钮
			if (!UITools.isNetworkAvailable(ForgetPwdActivity.this)) {
				showToast("请检查网络连接", Toast.LENGTH_LONG);
				return;
			}
			phoneNum = mEdtPhone.getText().toString();
			if (!RegisterUILogic.checkPassword(mEdtPassword.getText()
					.toString())) {
				runOnUiThread(new Runnable() {
					public void run() {
						LittleTextDialog textDialog = new LittleTextDialog(
								ForgetPwdActivity.this);
						textDialog.setMessage("请输入6~20位数字字母密码组合");
						mEdtPassword.setText("");
					}
				});
				return;
			} else {
				password = mEdtPassword.getText().toString();
			}
			if (!mEdtCode.getText().toString().equals(mTextCode)) {
				runOnUiThread(new Runnable() {
					public void run() {
						LittleTextDialog textDialog = new LittleTextDialog(
								ForgetPwdActivity.this);
						textDialog.setMessage("请输入正确的验证码");
						mEdtPassword.setText("");
					}
				});
				return;
			} else {
				vertification = mEdtCode.getText().toString();
			}
			resetPassword(phoneNum, vertification, AeSimpleSHA1.repeat20TimesAndSHA1(password));
			break;
		case R.id.btn_register_back:
			// 返回按钮
			finish();
			break;
		case R.id.get_vertification:
			// 获取验证码
			phoneNum = mEdtPhone.getText().toString();
			getCode(phoneNum);
			break;
		default:
			break;
		}
	}

	/**
	 * 调用重置密码的接口进行密码的修改
	 */
	public void resetPassword(String username, String vertification,
			String password) {
		if (!isForgetPwd) {
			if (!Constants.getUser().getPhoneNumber().equals(username)) {
				UITools.showToast("只能修改当前登录手机的密码！");
				return;
			}
		}

		final CustomProgressDialog mProgressDialog = new CustomProgressDialog(
				ForgetPwdActivity.this);
		UserInfoManagerLogic logic = new UserInfoManagerLogic();
		logic.resetPassword(username, vertification, password,
				new UserInfoManagerLogic.SuccessCallBack() {

					@Override
					public void onSuccess(int responseCode, String msg,
							int type, Object results) {
						mProgressDialog.dismiss();
						if (Constants.getUser() != null) {
							FileSystem.getInstance().saveLoginUser(
									Constants.getUser().getPhoneNumber(), "",Constants.getUser().getUserId());
						}
						showToast("修改成功", Toast.LENGTH_SHORT);
						Intent intent = new Intent(ForgetPwdActivity.this,
								LoginActivity.class);
						intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK
								| Intent.FLAG_ACTIVITY_CLEAR_TASK);
						startActivity(intent);
						finish();
					}
				}, new UserInfoManagerLogic.FailCallBack() {

					@Override
					public void onFail(int code, String msg) {
						UITools.showToast("修改密码失败:" + msg);
						mProgressDialog.dismiss();
						mEdtPhone.setEnabled(true);
					}
				});
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
				mGetVertification.setText("重新发送");
				this.cancel();
				mGetVertification.setSelected(false);
				mGetVertification.setEnabled(true);
			}
		};
		mCountTimer.start();
	}

	/** 获取验证码 */
	private void getCode(String phone) {
		if (phone == null) {
			showToast("请输入手机号", Toast.LENGTH_SHORT);
			return;
		}
		if (!RegisterUILogic.isMobileNO(phone)) {
			showToast("请输入正确的手机号", Toast.LENGTH_SHORT);
			return;
		}
		getCodeCountTimer();
		ResquestIdentfyLogic mIdentLogic = new ResquestIdentfyLogic(
				new ResIdentfyCallback() {
					// 获取验证码
					@Override
					public void resIdentfy(final String identfy) {
						mTextCode = identfy;
						// getCodeCountTimer();
						runOnUiThread(new Runnable() {
							public void run() {
								if (Constants.DEBUG) {
									Toast.makeText(ForgetPwdActivity.this,
											"获取到的验证码为：" + identfy,
											Toast.LENGTH_LONG).show();
								}
							}
						});
					}

					@Override
					public void resIdentError(int code, final String msg) {
						runOnUiThread(new Runnable() {
							public void run() {
//								mEdtPhone.setText("");
								LittleTextDialog textDialog = new LittleTextDialog(
										ForgetPwdActivity.this);
								textDialog.setMessage("获取验证码失败");
								mGetVertification.setVisibility(View.VISIBLE);
								mCountTimer.onFinish();
							}
						});
					}
				});
		mIdentLogic.reqIdentfy(phone, 2);
	}

	/**
	 * 判断手机号是否满足条件
	 */
	private boolean judgePhome(String phone) {
		boolean isMobile = RegisterUILogic.isMobileNO(phone);
		if (isMobile) {
			isPhoneRight = true;
			if (!UITools.isNetworkAvailable(ForgetPwdActivity.this)) {
				showToast("请检查网络连接", Toast.LENGTH_LONG);
				return true;
			}
			mEdtPhone.clearFocus();
			mEdtPassword.setFocusable(true);
			mEdtPassword.setFocusableInTouchMode(true);
			mEdtPassword.requestFocus();
			mImgPhoneIsRight.setVisibility(View.VISIBLE);
			mImgPhoneIsRight.setSelected(true);
			phoneNum = phone;
			if (mCountTimer != null) {
				mCountTimer.cancel();
			}
			// getCode(phoneNum);
			// showToast("已发送验证码到您的手机", Toast.LENGTH_SHORT);
		} else {
			isPhoneRight = false;
			mImgPhoneIsRight.setVisibility(View.VISIBLE);
			mImgPhoneIsRight.setSelected(false);
			// if(mCountTimer != null){
			// mCountTimer.cancel();
			// }
			// mGetVertification.setVisibility(View.GONE);
		}

		return isMobile;
	}

}
