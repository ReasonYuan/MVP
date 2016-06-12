package com.hp.android.halcyon;

import android.content.Intent;
import android.os.CountDownTimer;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic.RegisterLogic;
import com.fq.halcyon.logic.RegisterLogic.RegisterLogicListener;
import com.fq.halcyon.logic2.ResquestIdentfyLogic;
import com.fq.halcyon.logic2.ResquestIdentfyLogic.ResIdentfyCallback;
import com.fq.halcyon.uilogic.RegisterUILogic;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.Tool;
import com.hp.android.halcyon.util.UIConstants;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomProgressDialog;
import com.hp.android.halcyon.widgets.SwitchButton;
import com.hp.android.halcyon.widgets.SwitchButton.OnChangeListener;

public class RegisterActivity extends BaseActivity implements OnClickListener,
		ResIdentfyCallback {
	private Button mRegisterButton;
	private EditText mInputPhoneNumber;
	private EditText mInputPassword;
//	private EditText mReInputPassword;
	private EditText mInputVertification;
	private EditText mInviteEdit;
	private TextView mGetVertification;
//	private ImageView mImgMatch;
//	private TextView mPontTextView;

	private String mPhoneNumber;
	private String mPassword;
	private String mRePassword;
	private String mVertification;
//	private String mInvite;
	private CustomProgressDialog mProgressDialog;
	private RegisterUILogic uiLogic;
	private boolean isPhoneExist;

	private ResquestIdentfyLogic mIdentLogic;
	private CountDownTimer mCountTimer;

//	private Button mBtnBack;// 返回按钮
//	private Button mBtnDoctor;// 医生
//	private Button mBtnDoctorStd;// 医学生
	private int mRoleType = 1;

	private ImageView mImgPhoneIsRight; // 手机号码格式正确时显示
	private ImageView mImgCodeIsRight; // 验证码正确时显示
	private ImageView mImgPwdIsRight; // 密码正确时显示
	private ImageView mImgInviteRight; //邀请码正确时显示
	private String mCodeText; // 验证码

	private LinearLayout mLayoutDeal;  //行医助手协议
	private SwitchButton mSwitchBtn; //选择角色
	private TextView mTextNotice; //提示用户输入错误
	private boolean isPhoneRight;
	private boolean isVerRight;
	private boolean isKeyRight;
	private boolean isInviteRight;
	private LinearLayout mHiden;
	
	private final int TY_PHN = 0;
	private final int TY_PWD = 1;
	private final int TY_VER = 2;
	private final int TY_INV = 3;
	
	
	private void isAllOK(int type){
		
		if(isPhoneRight&&isVerRight&&isKeyRight&&isInviteRight){
			mRegisterButton.setEnabled(true);
			mTextNotice.setVisibility(View.INVISIBLE);
		}else{
			mRegisterButton.setEnabled(false);
			mTextNotice.setVisibility(View.INVISIBLE);
			
			switch (type) {
			case TY_PWD:
				if(!isKeyRight){
					String password = mInputPassword.getText().toString();
					if(password.length() > 0){
						mTextNotice.setVisibility(View.VISIBLE);
						mTextNotice.setText("请输入6~20位字母与数字的密码组合");
					}
				}
				break;
			case TY_VER:
				if(!isVerRight){
					String code = mInputVertification.getText().toString().trim();
					if(code.length() == 4){
						mTextNotice.setVisibility(View.VISIBLE);
						mTextNotice.setText("请输入正确的验证码");
					}
				}
				break;
			case TY_INV:
				if(!isInviteRight){
					String code = mInviteEdit.getText().toString().trim();
					if(code.length() == 4){
						mTextNotice.setVisibility(View.VISIBLE);
						mTextNotice.setText("请输入4位字母与数字组合的邀请码");
					}
				}
				break;
			case TY_PHN:	
			default:
				if(!isPhoneRight){
					String phone = mInputPhoneNumber.getText().toString().trim();
					if(phone.length() == 11){
						mTextNotice.setVisibility(View.VISIBLE);
						mTextNotice.setText("请重新输入手机号");
					}
				}
				break;
			}
			/*if(!isPhoneRight){
				String phone = mInputPhoneNumber.getText().toString().trim();
				if(phone.length() == 11){
					mTextNotice.setVisibility(View.VISIBLE);
					mTextNotice.setText("请重新输入手机号");
				}
			}else if(!isKeyRight){
				String password = mInputPassword.getText().toString();
				if(password.length() > 0){
					mTextNotice.setVisibility(View.VISIBLE);
					mTextNotice.setText("请输入6~20位字母与数字的密码组合");
				}
			}else if(!isVerRight){
				String code = mInputVertification.getText().toString().trim();
				if(code.length() == 4){
					mTextNotice.setVisibility(View.VISIBLE);
					mTextNotice.setText("请输入正确的验证码");
				}
			}else if(!isInviteRight){
				String code = mInviteEdit.getText().toString().trim();
				if(code.length() == 4){
					mTextNotice.setVisibility(View.VISIBLE);
					mTextNotice.setText("请输入4位字母与数字组合的邀请码");
				}
			}*/
		}
	}
	
	RegisterLogic registerLogic = new RegisterLogic() {};
	RegisterLogicListener registerLogicListener = new RegisterLogicListener() {
		@Override
		public void returnData(int responseCode, JSONObject results) {
			if (mProgressDialog != null) {
				mProgressDialog.dismiss();
				mProgressDialog = null;
			}
			
			User user = new User();
			user.setAtttributeByjson(results);
			user.setPhone_number(new String(mPhoneNumber));
			user.setPassword(new String(Tool.encrypt(mPassword)));
			FileSystem.getInstance().saveUser(user);
			
			Constants.setUser(user);
			
			//因为如果用户注册后不填写完用户信息，而有可以自动登录，那么用户一打开程序就只有进入设置信息界面，
			//而且还不能退出，所以把保存登录信息放到设置用户信息完成后
//			SaveInfoUILogic.saveInfo(mPhoneNumber, Tool.encrypt(mPassword),
//					Constants.getUser().getUserId(), Constants.getUser());
			HalcyonApplication.getInstance().onUserLoginIn();
			UITools.showToast("注册成功");
			HomeActivity.mIsFirstLoading = true;
			Intent intent = new Intent(RegisterActivity.this, UserProfileActivity.class);
			intent.putExtra("user_regist", true);
			startActivity(intent);
			finish();
			if (LoginActivity.mIntance != null) {
				LoginActivity.mIntance.finish();
				LoginActivity.mIntance = null;
			}
		}
		
		@Override
		public void error(int code, String msg) {
			if (code == -11)
				return;
			if (mProgressDialog != null) {
				mProgressDialog.dismiss();
				mProgressDialog = null;
			}

			UITools.showToast("注册失败:"+msg);
		}

		public void isPhoneExist(final boolean isExist) {
			// isPhoneExist = isExist;
			runOnUiThread(new Runnable() {
				public void run() {
					if (isExist) {
						isPhoneExist = true;
						isPhoneRight = false;
//						mPontTextView.setText(R.string.regist_phone_exist);
//						mPontTextView.setTextColor(Color.RED);
//						mPontTextView.setVisibility(View.VISIBLE);
					} else {
						isPhoneExist = false;
						isPhoneRight = true;
//						mPontTextView.setText(R.string.regist_phone_can);
//						mPontTextView.setTextColor(Color.BLUE);
					}
				}
			});
		}
	};
	
	
	@Override
	public int getContentId() {
		return R.layout.activity_register;
	}

	@Override
	public void init() {
		//getTopBar().setVisibility(View.GONE);
		//setTopText(getString(R.string.register_title));
//		setContainerTop();
		Widget();
		super.setTitle("注册");
		mHiden = (LinearLayout) findViewById(R.id.register_hiden);
		mHiden.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				((InputMethodManager)getSystemService(INPUT_METHOD_SERVICE)).hideSoftInputFromWindow(RegisterActivity.this.getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
			}
		});
		uiLogic = new RegisterUILogic();
		/**
		 * 新密码输入的监听事件
		 */
		mInputPassword.addTextChangedListener(new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {}

			@Override
			public void afterTextChanged(Editable s) {
				String psd = s.toString();
				if (psd == null || "".equals(psd))
					return;
				if(RegisterUILogic.checkPassword(psd)){
					isKeyRight = true;
					mImgPwdIsRight.setVisibility(View.VISIBLE);
					mImgPwdIsRight.setSelected(true);
				}else{
					isKeyRight = false;
					mImgPwdIsRight.setSelected(false);
				}
				isAllOK(TY_PWD);
			}
		});
		
		registerLogic.setListener(registerLogicListener);
	}

	protected void hideInvite(){
		findViewById(R.id.ll_register_invite).setVisibility(View.GONE);
	}
	
	public void Widget() {
		mImgPhoneIsRight = (ImageView) findViewById(R.id.img_register_right);
		mImgCodeIsRight = (ImageView) findViewById(R.id.img_register_vertification_right);
		mImgPwdIsRight = (ImageView) findViewById(R.id.img_register_password_right);
		mImgInviteRight = (ImageView) findViewById(R.id.img_register_invite_right);
		mRegisterButton = (Button) findViewById(R.id.register_button);
		mInputPhoneNumber = (EditText) findViewById(R.id.register_phonenumber);
		mInputPassword = (EditText) findViewById(R.id.register_password);
		mInputVertification = (EditText) findViewById(R.id.et_vertification);
		mInviteEdit = (EditText) findViewById(R.id.et_invite);
		mGetVertification = (TextView) findViewById(R.id.get_vertification);
//		mReInputPassword = (EditText) findViewById(R.id.reinput_password);
//		mPontTextView = (TextView) findViewById(R.id.tv_regist_point);
//		mImgMatch = (ImageView) findViewById(R.id.iv_register_pwd_right);
//		mBtnBack = (Button) findViewById(R.id.btn_register_back);
//		mBtnDoctor = (Button) findViewById(R.id.btn_register_role_doctor);
//		mBtnDoctorStd = (Button) findViewById(R.id.btn_register_role_doctor_student);
		mLayoutDeal = (LinearLayout) findViewById(R.id.ll_register_deal);
		mSwitchBtn = (SwitchButton) findViewById(R.id.sb_register_selector_role);
		mTextNotice = (TextView) findViewById(R.id.tv_register_input_wrong);
//		mBtnDoctor.setSelected(true);
		mRegisterButton.setEnabled(false);
		mRegisterButton.setOnClickListener(this);
		mGetVertification.setOnClickListener(this);
//		mBtnBack.setOnClickListener(this);
//		mBtnDoctor.setOnClickListener(this);
//		mBtnDoctorStd.setOnClickListener(this);
		mLayoutDeal.setOnClickListener(this);
		mInputPhoneNumber.setOnFocusChangeListener(new OnFocusChangeListener() {
			public void onFocusChange(View v, boolean hasFocus) {
				if (hasFocus)
					return;
				if (!Constants.DEBUG && mInputPhoneNumber.length() != 11) {
//					mPontTextView.setText("手机号码不是11位");
//					mPontTextView.setTextColor(Color.RED);
//					mPontTextView.setVisibility(View.VISIBLE);
					return;
				}
				String phone = mInputPhoneNumber.getText().toString();
				if (phone != null && !"".equals(phone)) {
					registerLogic.isPhoneExist(phone);
				}
			}
		});
		
		mInputPhoneNumber.addTextChangedListener(new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {}

			@Override
			public void beforeTextChanged(CharSequence arg0, int arg1,
					int arg2, int arg3) {}

			@Override
			public void afterTextChanged(Editable s) {
				if (s.length() == 11) {
					boolean isMobile = RegisterUILogic.isMobileNO(s.toString());
					if (isMobile) {
						isPhoneRight = true;
						mImgPhoneIsRight.setSelected(true);
						if (!UITools.isNetworkAvailable(RegisterActivity.this)) {
							showToast("请检查网络连接", Toast.LENGTH_LONG);
							return;
						}
						mInputPhoneNumber.clearFocus();
						mInputPassword.setFocusable(true);
						mInputPassword.setFocusableInTouchMode(true);
						mInputPassword.requestFocus();
						mImgPhoneIsRight.setVisibility(View.VISIBLE);
						if(mCountTimer != null){
							mCountTimer.cancel();
						}
//						getCode();
						yanZhengPhone();
					}else{
//						if(mCountTimer != null){
//							mCountTimer.cancel();
//						}
//						mGetVertification.setVisibility(View.GONE);
					}
				} else {
					isPhoneRight = false;
					mImgPhoneIsRight.setSelected(false);
					mCodeText = "";
					mInputVertification.setText("");
//					if(mCountTimer != null){
//						mCountTimer.cancel();
//					}
//					mGetVertification.setVisibility(View.GONE);
				}
				isAllOK(TY_PHN);
			}
		});

		mInputVertification.addTextChangedListener(new TextWatcher() {
			public void onTextChanged(CharSequence arg0, int arg1, int arg2,
					int arg3) {}

			@Override
			public void beforeTextChanged(CharSequence arg0, int arg1,
					int arg2, int arg3) {}

			@Override
			public void afterTextChanged(Editable s) {
				if(s.length() == 4){
					if (s.toString().equals(mCodeText)) {
						isVerRight = true;
						mImgCodeIsRight.setVisibility(View.VISIBLE);
						mImgCodeIsRight.setSelected(true);
//						if(mCountTimer != null){
//							mCountTimer.cancel();
//						}
//						mGetVertification.setVisibility(View.GONE);
					} else {
						isVerRight = false;
						mImgCodeIsRight.setVisibility(View.VISIBLE);
						mImgCodeIsRight.setSelected(false);
					}
				}else{
					isVerRight = false;
					mImgCodeIsRight.setSelected(false);
				}
				isAllOK(TY_VER);
			}
		});
		mInviteEdit.setOnFocusChangeListener(new View.OnFocusChangeListener() {  
		       
		    @Override  
		    public void onFocusChange(View v, boolean hasFocus) {  
		        if(hasFocus){//获得焦点  
		        	UITools.showToast("请向注册用户索取邀请码");
		        }else{//失去焦点  
		             
		        }  
		    }             
		});
		mInviteEdit.addTextChangedListener(new TextWatcher() {
			public void onTextChanged(CharSequence s, int start, int before, int count) {}
			
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {}
			
			@Override
			public void afterTextChanged(Editable s) {
				String invite = s.toString();
				if (invite == null || "".equals(invite))return;
				mImgInviteRight.setVisibility(View.VISIBLE);
				if(RegisterUILogic.checkInvite(invite)){
					isInviteRight = true;
					mImgInviteRight.setSelected(true);
				}else{
					isInviteRight = false;
					mImgInviteRight.setSelected(false);
				}
				isAllOK(TY_INV);
			}
		});
		
		mSwitchBtn.setOnChangeListener(new OnChangeListener() {
			
			@Override
			public void onChange(SwitchButton sb, boolean state) {
				if(state){
					mRoleType = Constants.ROLE_DOCTOR_STUDENT;
				}else{
					mRoleType = Constants.ROLE_DOCTOR;
				}
			}
		});
	}

	@Override
	public void onClick(View v) {
		if (!UITools.isNetworkAvailable(RegisterActivity.this)) {
			UITools.showToast("请确认已经连接到网络");
			return;
		}
		switch (v.getId()) {
		case R.id.get_vertification:
			getCode();
			break;
		case R.id.register_button:
			// 注册按钮点击事件
			register();
			break;
		case R.id.btn_register_back:
			// 返回到登录界面
			finish();
			break;
		case R.id.btn_register_role_doctor:
			// 选择角色为医生
//			mBtnDoctor.setSelected(true);
//			mBtnDoctorStd.setSelected(false);
			mRoleType = Constants.ROLE_DOCTOR;
			// Constants.getUser().setRole_type(Constants.ROLE_DOCTOR);
			break;
		case R.id.btn_register_role_doctor_student:
			// 选择角色为医学生
//			mBtnDoctor.setSelected(false);
//			mBtnDoctorStd.setSelected(true);
			mRoleType = Constants.ROLE_DOCTOR_STUDENT;
			// Constants.getUser().setRole_type(Constants.ROLE_DOCTOR_STUDENT);
			break;
		case R.id.ll_register_deal:
			//用户协议
			startActivity(new Intent(RegisterActivity.this, DealActivity.class));
			break;
		default:
			break;
		}
	}

	@Override
	public void resIdentError(int code, String msg) {
		if (mCountTimer != null) {
			mCountTimer.onFinish();
//			mCountTimer.cancel();
			mCountTimer = null;
		}
		runOnUiThread(new Runnable() {
			public void run() {
				UITools.showToast("获取验证码失败,请重新获取");
			}
		});
	}

	@Override
	public void resIdentfy(final String identfy) {
		runOnUiThread(new Runnable() {
			public void run() {
				mCodeText = identfy;
				if (Constants.DEBUG) {
					Toast.makeText(RegisterActivity.this, "获取到的验证码为：" + identfy,
							Toast.LENGTH_LONG).show();
				}
				//供开发人员使用
				Log.i(this.getClass().getSimpleName(), "indentify_code: " + identfy);
//				LittleTextDialog textDialog = new LittleTextDialog(RegisterActivity.this);
//				textDialog.setMessage("验证码：" + identfy);
				getCodeCountTimer();
			}
		});
	}
	
	/**
	 *注册 
	 */
	private void register(){
		if (isPhoneExist)
			return;
		mVertification = mInputVertification.getText().toString().trim();
		if(!mVertification.equals(mCodeText)){
			UITools.showToast("验证码错误");
			return;
		}
		
		mPhoneNumber = mInputPhoneNumber.getText().toString().trim();
		mPassword = mInputPassword.getText().toString();
		mRePassword = mPassword;//mReInputPassword.getText().toString();

		// 检测输入的各项是否都符合要求
		boolean isRight = uiLogic.checkInput(mPhoneNumber, mPassword,
				mRePassword, mVertification,
				new RegisterUILogic.MessageCallBack() {
					@Override
					public void message(String msg) {
						UITools.showToast(msg);
					}
				});
		if (isRight) {
				String invite = mInviteEdit.getText().toString().trim();
				registerLogic.register(mRoleType,mPhoneNumber,mPassword,mVertification,invite, UITools.getVersion(getApplicationContext()), UIConstants.PLATFORM_NAME);
				mProgressDialog = new CustomProgressDialog(this);
				mProgressDialog.setMessage("正在注册，请稍后");
		}
	}
	
	/**
	 * 验证手机号
	 */
	private void yanZhengPhone(){
		final String phone = mInputPhoneNumber.getText().toString().trim();
		if (!uiLogic.checkPhone(phone)) {
			UITools.showToast("请输入11位手机号码");
			return;
		}
		RegisterLogic registerLogic = new RegisterLogic() {};
		RegisterLogicListener logicListener = new RegisterLogicListener() {
			
			@Override
			public void returnData(int responseCode, JSONObject results) {

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
//					if (mIdentLogic == null) {
//						mIdentLogic = new ResquestIdentfyLogic(
//								RegisterActivity.this);
//					}
//					mIdentLogic.reqIdentfy(phone, 1);
					mGetVertification.setEnabled(true);
				}
				isAllOK(TY_PHN);
			}

			@Override
			public void error(int code, String msg) {}
		};
		registerLogic.setListener(logicListener);
		registerLogic.isPhoneExist(phone);
		
//		mGetVertification.setText("");
		mImgCodeIsRight.setVisibility(View.GONE);
	}
	
	/**
	 *获取验证码 
	 */
	private void getCode(){
		// 获取验证码按钮点击事件
		final String phone = mInputPhoneNumber.getText().toString().trim();
		if (!uiLogic.checkPhone(phone)) {
			UITools.showToast("请输入11位手机号码");
			return;
		}
		if (mIdentLogic == null) {
			mIdentLogic = new ResquestIdentfyLogic(
					RegisterActivity.this);
		}
		mIdentLogic.reqIdentfy(phone, 1);
		getCodeCountTimer();
//		mGetVertification.setEnabled(true);
	}
	
	/**获取验证码的倒计时*/
	private void getCodeCountTimer(){
		mCountTimer = new CountDownTimer(60000, 1000) {
			public void onTick(long millisUntilFinished) {
				mGetVertification.setVisibility(View.VISIBLE);
				mGetVertification.setEnabled(false);
				mGetVertification.setText(millisUntilFinished/ 1000 + "\" " + "重新发送");
				mGetVertification.getPaint().setFakeBoldText(false); 
				//mGetVertification.setSelected(true);
			}

			public void onFinish() {
				this.cancel();
				mGetVertification.setText("重新发送");
				//mGetVertification.setSelected(false);
				mGetVertification.setEnabled(true);
				mGetVertification.getPaint().setFakeBoldText(true); 
			}
		};
		mCountTimer.start();
	}
}