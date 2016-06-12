package com.hp.android.halcyon.server;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.IBinder;
import android.util.Log;

import com.fq.halcyon.HalcyonUploadLooper;
import com.hp.android.halcyon.HalcyonApplication;

public class HalcyonService extends Service {

	public static OnNetWorkChangedListener mNetWorkChangedListener;

	public static boolean mCurrnetWifiConnected = true;

	public static interface OnNetWorkChangedListener {
		public void onNetWorkChanged(boolean connected);
	}

	private BroadcastReceiver mReceiver = new BroadcastReceiver() {

		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();
			if (action.equals(ConnectivityManager.CONNECTIVITY_ACTION)) {
				checkNetWork();
//			}else if(action.equals(AlarmUtil.ACTION_ALARM)){
//				MessageStruct.createNotification(context, "一个提醒", intent.getStringExtra("alarm_content"), 1, HomeActivity.class);
			}
		}
	};
	
	public static boolean isNetworkConnected(Context context) {
		ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = connectivityManager.getActiveNetworkInfo();
		return (info != null && info.isAvailable());
	}

	/**
	 * 检查网络
	 * 
	 * @return 半段网络是否联通
	 */
	private boolean checkNetWork() {
		ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		if (info != null && info.isAvailable()) {
			mCurrnetWifiConnected = true;
			HalcyonUploadLooper.getInstance().start();
		} else {
			mCurrnetWifiConnected = false;
			HalcyonUploadLooper.getInstance().stop();
		}
		info = connectivityManager.getActiveNetworkInfo();
		boolean isNetWorkConnected = (info != null && info.isAvailable());
		if (mNetWorkChangedListener != null)
			mNetWorkChangedListener.onNetWorkChanged(isNetWorkConnected);
		HalcyonApplication.getInstance().onNetWorkChanged(isNetWorkConnected);
		return isNetWorkConnected;
	}

	@Override
	public IBinder onBind(Intent intent) {
		return null;
	}

	@Override
	public void onCreate() {
		super.onCreate();
		checkNetWork();
		IntentFilter mFilter = new IntentFilter();
		mFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
		registerReceiver(mReceiver, mFilter);
		try {
			copyFile(getAssets().open("daemon"), "daemon");
			exec("/data/data/" + getPackageName() + "/files/daemon");
		} catch (Exception e) {
			e.printStackTrace();
		}
		Log.e("start!!!!!!!", "start!!!!!!!!!!!!!!!!");
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		unregisterReceiver(mReceiver);
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		return super.onStartCommand(intent, flags, startId);
	}

	public static String exec(String cmd) {
		String ret = "\n";
		BufferedReader in = null;
		try {
			Process p = Runtime.getRuntime().exec(cmd);
			in = new BufferedReader(new InputStreamReader(p.getInputStream()));
			String line = null;
			while ((line = in.readLine()) != null) {
				ret += line + "\n";
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				in.close();
			} catch (Exception e2) {
			}

		}
		return ret;
	}

	private void copyFile(InputStream inputStream, String fileName) {
		final String SUBPATH = getFilesDir().getAbsolutePath();
		String tmpFileName = new String();
		tmpFileName = "/data/data/" + getPackageName() + "/files/" + fileName;
		try {
			File file = new File(tmpFileName);
			if (!file.exists() || file.length() != inputStream.available()) {
				FileOutputStream fos = new FileOutputStream(file);
				byte[] buffer = new byte[8192];
				int count = 0;
				while ((count = inputStream.read(buffer)) > 0) {
					fos.write(buffer, 0, count);
				}
				fos.close();
				inputStream.close();
				exec("chmod 777 /data/data/" + getPackageName() + "/files/daemon");
			}

		} catch (IOException e) {
			Log.e("", "", e);
		}
	}
}
