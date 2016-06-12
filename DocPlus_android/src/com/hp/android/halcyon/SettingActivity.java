package com.hp.android.halcyon;

import java.io.File;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.ToggleButton;

import com.fq.android.plus.R;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic2.AnnualFreeLogic;
import com.fq.halcyon.logic2.AnnualFreeLogic.AnnualFreeLogicInterface;
import com.fq.lib.FileHelper;
import com.fq.lib.tools.BaiduAnalysis;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.Tool;
import com.fq.platfrom.android.FQSecuritySession;
import com.hp.android.halcyon.util.BaiDuTJSDk;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;

public class SettingActivity extends BaseActivity implements OnClickListener {

	private RelativeLayout mChangePhone; // 修改登录手机
	private RelativeLayout mChangePlus; // 修改医家号
	private RelativeLayout mChangePwd; // 修改密码
	private RelativeLayout mQuickMark; // 二维码
	private RelativeLayout mChangePlay; // 修改年费
	private RelativeLayout mIsWifi; // 设置是否仅在有Wifi的情况下上传
	private RelativeLayout mCleanCatch; // 清除缓存
	private RelativeLayout mAboutPlus; // 关于医家
	private RelativeLayout mTickling; // 反馈

	private TextView mTxtPhone;  //显示用户的手机号码
	private TextView mTxtAnnualFee; //显示用户选择的年费方式 
	private ToggleButton mTogWifiBtn; //用于设置是否仅wifi时上传病历
	private Button mBtnExit;  //退出按钮
	
	
	private final int REQUEST_CODE_CHANGE_PHONE = 10;
	private final int REQUEST_CODE_ANNUAL_FEE = 50;
	
	private SharedPreferences mSharePreferences;
	
	@Override
	public int getContentId() {
		return R.layout.activity_setting;
	}

	@Override
	public void init() {
		initWidgets();
		initListener();
	}

	/**初始化控件*/
	private void initWidgets() {
		setTitle("设 置");
		mChangePhone = (RelativeLayout) findViewById(R.id.ll_setting_change_phone);
		mChangePlus = (RelativeLayout) findViewById(R.id.ll_setting_change_plus);
		mChangePwd = (RelativeLayout) findViewById(R.id.ll_setting_change_pwd);
		mQuickMark = (RelativeLayout) findViewById(R.id.ll_setting_quickmark);
		mChangePlay = (RelativeLayout) findViewById(R.id.ll_setting_play);
		mIsWifi = (RelativeLayout) findViewById(R.id.ll_setting_wifi);
		mCleanCatch = (RelativeLayout) findViewById(R.id.ll_setting_clean_catch);
		mAboutPlus = (RelativeLayout) findViewById(R.id.ll_setting_about_plus);
		mTickling = (RelativeLayout) findViewById(R.id.ll_setting_tickling);
		mTxtPhone = (TextView) findViewById(R.id.tv_setting_user_phone);
		mTxtPhone.setText(Constants.getUser().getPhoneNumber());
		mTxtAnnualFee = (TextView) findViewById(R.id.tv_setting_annual_fee);
		mBtnExit = (Button) findViewById(R.id.btn_exit_app);
		mTxtAnnualFee.setText(AnnualFeeActivity.getAnnualStr());
		
		mTogWifiBtn = (ToggleButton) findViewById(R.id.mTogBtn);
		mTogWifiBtn.setChecked(Constants.getUser().isOnlyWifi());
	}

	@Override
	protected void onResume() {
		super.onResume();
		((TextView)findViewById(R.id.tv_setting_dp_name)).setText(Constants.getUser().getDPName());
	}
	
	/**初始化控件事件*/
	private void initListener() {
		mChangePhone.setOnClickListener(this);
		mChangePlus.setOnClickListener(this);
		mChangePwd.setOnClickListener(this);
		mQuickMark.setOnClickListener(this);
		mChangePlay.setOnClickListener(this);
		mIsWifi.setOnClickListener(this);
		mCleanCatch.setOnClickListener(this);
		mAboutPlus.setOnClickListener(this);
		mTickling.setOnClickListener(this);
		mBtnExit.setOnClickListener(this);
		mIsWifi.setOnClickListener(this);
		mTogWifiBtn.setOnCheckedChangeListener(new OnCheckedChangeListener() {
			
			@Override
			public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
				Constants.getUser().setOnlyWifi(isChecked);
				mSharePreferences = getSharedPreferences("dp_isOnlyWifi", Context.MODE_PRIVATE);
				Editor editor = mSharePreferences.edit();
				editor.putBoolean(FileSystem.getInstance().getCurrentMD5Id(), isChecked);
				editor.commit();
			}
		});
	}

	@Override
	public void onClick(View v) {
		Intent intent;
		switch (v.getId()) {
		case R.id.ll_setting_change_phone:
			//修改手机
			intent = new Intent();
			intent.setClass(SettingActivity.this, ChangePhoneActivity.class);
			startActivityForResult(intent, REQUEST_CODE_CHANGE_PHONE);
			break;
		case R.id.ll_setting_change_plus:
			//医加号
			if("".equals(Constants.getUser().getDPName())){
				intent = new Intent();
				intent.setClass(SettingActivity.this, SettingPlusIdActivity.class);
				startActivity(intent);
			}
			break;
		case R.id.ll_setting_change_pwd:
			//修改密码
			intent = new Intent();
			intent.putExtra("isForgetPwd", false);
			intent.setClass(SettingActivity.this, ForgetPwdActivity.class);
			startActivity(intent);
			break;
		case R.id.ll_setting_quickmark:
			//二维码
			startActivity(new Intent(this,ZxingCreateBmpActivity.class));
			break;
		case R.id.ll_setting_play:
			//年费
			intent = new Intent();
			intent.setClass(SettingActivity.this, AnnualFeeActivity.class);
			startActivityForResult(intent, REQUEST_CODE_ANNUAL_FEE);
			break;
		case R.id.ll_setting_clean_catch:
			//清除缓存
			cleanCatch();
			break;
		case R.id.ll_setting_about_plus:
			//关于医家
			intent = new Intent();
			intent.setClass(SettingActivity.this, AboutDocPlus.class);
			startActivity(intent);
			break;
		case R.id.ll_setting_tickling:
			//反馈
			intent = new Intent();
			intent.setClass(SettingActivity.this, FeedbackActivity.class);
			startActivity(intent);
			break;
		case R.id.btn_exit_app:
			//退出登录
			BaiDuTJSDk.onEvent(BaiduAnalysis.EVENT_EXIT_LOGIN, BaiduAnalysis.LABEL_NULL);
			Tool.clearUserData();
			FQSecuritySession.getInstance().setAccessToken(null);
			HalcyonApplication.getInstance().onUserLoginOut();
			intent = new Intent(SettingActivity.this,LoginActivity.class);
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
			intent.putExtra("byexit", true);
			startActivity(intent);
			finish();
			break;
		case R.id.ll_setting_wifi:
			mTogWifiBtn.setChecked(!mTogWifiBtn.isChecked());
		default:
			break;
		}
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, final Intent data) {
		
		if(requestCode == REQUEST_CODE_CHANGE_PHONE && resultCode == RESULT_OK){
			//修改手机号码的显示
			mTxtPhone.setText(Constants.getUser().getPhoneNumber());
		}else if(requestCode == REQUEST_CODE_ANNUAL_FEE && resultCode == RESULT_OK){
			//修改年费的显示
			Bundle mBundle = data.getExtras();
			final int mPrice = mBundle.getInt("annualFee",0);
			mTxtAnnualFee.setText(mPrice == 0?"免费义诊":Tool.get3Th(mPrice)+"医家币/年");
			new AnnualFreeLogic(new AnnualFreeLogicInterface() {
				@Override
				public void onError(int code, final Throwable e) {
					UITools.showToast("设置年费失败");
					mTxtAnnualFee.setText(AnnualFeeActivity.getAnnualStr());
				}

				@Override
				public void onDataReturn(int responseCode, String msg) {
					Constants.getUser().setAnnual(mPrice);
					FileSystem.getInstance().saveCurrentUser();
				}
			}, mPrice);
		}
		
		super.onActivityResult(requestCode, resultCode, data);
	}
	
	/**清除缓存数据*/
	private void cleanCatch(){
		final File file = new File(FileSystem.getInstance().getSDCImgRootPath());
		
//		new AlertDialog.Builder(this)
//		.setTitle("清除缓存，释放手机空间")
//		.setMessage("提示：收藏的文件不会被清除")
//		.setPositiveButton(R.string.btn_sure,new AlertDialog.OnClickListener() {
//			
//			@Override
//			public void onClick(DialogInterface dialog, int which) {
//				new Thread( new Runnable() {
//					@Override
//					public void run() {
//						FileHelper.deleteFile(file, false);
//					}
//				}).start();
//				dialog.dismiss();
//				UITools.showToast("缓存清除成功");
//			}})
//			
//		.setNegativeButton(R.string.btn_cancel,new AlertDialog.OnClickListener() {
//		public void onClick(DialogInterface dialog, int which) {
//			dialog.dismiss();
//		}}).show();
		final CustomDialog dialog = new CustomDialog(SettingActivity.this);
		dialog.setMessage("清除缓存，释放手机空间");//提示：收藏的文件不会被清除
		dialog.setNegativeButton(R.string.btn_cancel,
				new OnClickListener() {
					public void onClick(View arg0) {
						dialog.dismiss();
					}
				});
		dialog.setPositiveListener(R.string.btn_sure_ren,
				new OnClickListener() {
					public void onClick(View arg0) {
						new Thread( new Runnable() {
							public void run() {
								FileHelper.deleteFile(file, false);
							}
						}).start();
						dialog.dismiss();
						UITools.showToast("缓存清除成功");
					}
				});
	}
}
