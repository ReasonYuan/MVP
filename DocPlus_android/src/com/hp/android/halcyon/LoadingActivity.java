package com.hp.android.halcyon;

import java.io.File;
import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;

import com.fq.android.plus.R;
import com.fq.halcyon.HalcyonUploadLooper;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.AlarmClock;
import com.fq.halcyon.entity.CertificationStatus;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.uilogic.UILoginLogic;
import com.fq.halcyon.uilogic.UILoginLogic.UILogicCallback;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.Tool;
import com.hp.android.halcyon.server.HalcyonService;
import com.hp.android.halcyon.util.AlarmUtil;
import com.hp.android.halcyon.util.UIConstants;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.view.LoadingView;

public class LoadingActivity extends Activity implements UILogicCallback {
	private String mUserName;
	private String mPassWord;
	private UILoginLogic mUILoginLogic;
	private LoadingView loadingView;
//	private static final String TAG = LoadingActivity.class.getSimpleName();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_login_loading);
		mUserName = getIntent().getExtras().getString("mUserName");
		mPassWord = getIntent().getExtras().getString("mPassWord");
		loadingView = (LoadingView) findViewById(R.id.loading_view);
		loadingView.startAnim();
		new Handler().postDelayed(new Runnable() {
			public void run() {
				autoLogin();
			}
		}, 1000);
	}

	public void autoLogin() {
		// 务必要用密文密码
		mUILoginLogic = new UILoginLogic(this);
		mUILoginLogic.login(isNetWorkOK(), mUserName, mPassWord, UITools.getVersion(getApplicationContext()), UIConstants.PLATFORM_NAME);
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		loadingView.stopAnim();
	}

	public void goOtherActivity() {
		Intent mIntent = new Intent();
		mIntent.setClass(this, LoginActivity.class);
		startActivity(mIntent);
		this.finish();
	}

	private boolean isNetWorkOK() {
		ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = connectivityManager.getActiveNetworkInfo();
		return info != null && info.isAvailable();
	}

	private void checkNetWork() {
		ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = connectivityManager.getActiveNetworkInfo();
		if (info != null && info.isAvailable()) {
			HalcyonUploadLooper.getInstance().start();
		} else {
			HalcyonUploadLooper.getInstance().stop();
		}
	}

	public void checkUser() {
		checkNetWork();
		// new TagLogic().getListAllTags(null);
		initUserHead();
		CertificationStatus.initCertification();
	}

	public void initUserHead() {
		File file = new File(FileSystem.getInstance().getUserHeadPath());
		if (file.exists())
			return;
		//==YY==imageId(只要imageId)
//		if (Constants.getUser() == null|| "".equals(Constants.getUser().getHeadPicPath()))
		if (Constants.getUser() == null|| 0 == Constants.getUser().getImageId())
			return;
		Photo photo = new Photo();
		photo.setImageId(Constants.getUser().getImageId());
//		photo.setImageId(Constants.getUser().getHeadPicImageId());
//		photo.setImagePath(Constants.getUser().getHeadPicPath());
		
		ApiSystem.getInstance().getHeadImage(photo, new ICallback() {

			@Override
			public void doCallback(Object obj) {
			}

		}, false, 1);
	}

	@Override
	public void logicBack(int type, int code, String msg) {
//		Log.i("Loading", "~~~~type:"+type+" code"+code+" msg:"+msg);
		if (type == 0) {
			Intent mIntent = new Intent();
			setResult(code, mIntent);
			LoadingActivity.this.finish();
		} else if (type == 1) {
			Intent service = new Intent(this, HalcyonService.class);
			startService(service);
//			Log.i("Loading", "~~~~startServer");
			HalcyonApplication.getInstance().onUserLoginIn();
//			Log.i("Loading", "~~~~onUserLoginIn");
			if (Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR_STUDENT) {
				Constants.getUser().setRole_type(Constants.ROLE_DOCTOR);
			}
			Intent mIntent = new Intent();
			if (Tool.isUserInfoFull(Constants.getUser())) {
				mIntent.setClass(LoadingActivity.this, HomeActivity.class);
//				Log.i("Loading", "~~~~to HomeActivity");
			} else {
				mIntent.setClass(LoadingActivity.this,UserProfileActivity.class);
				mIntent.putExtra("user_regist", true);
//				Log.i("Loading", "~~~~to UserProfileActivity");
			}
			startActivity(mIntent);
//			Log.i("Loading", "~~~~startActivity");
			if (Constants.getUser() != null) {
				SharedPreferences share = getSharedPreferences("dp_isOnlyWifi",Activity.MODE_PRIVATE);
				boolean b = share.getBoolean(FileSystem.getInstance().getCurrentMD5Id(), true);
				Constants.getUser().setOnlyWifi(b);
			}
			LoadingActivity.this.finish();
//			Log.i("Loading", "~~~~LoadingActivity finish");
			if (LoginActivity.mIntance != null) {
				LoginActivity.mIntance.finish();
//				Log.i("Loading", "~~~~LoginActivity finish");
				LoginActivity.mIntance = null;
			}
		}
	}

	@Override
	public void onAlarmCallback() {
		ArrayList<AlarmClock> alarms = Constants.alarms;
		AlarmUtil alarmUtil = AlarmUtil.getInstance();
		if (alarms != null) {
			for (int i = 0; i < alarms.size(); i++) {
				AlarmClock alarm = alarms.get(i);
				if (alarm.getTimerDate() > System.currentTimeMillis())
					alarmUtil.setAlarm(alarm);
			}
		}
	}
}
