package com.hp.android.halcyon;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.android.plus.guidepage.GuidePageActivity;
import com.fq.halcyon.entity.Version;
import com.fq.halcyon.logic.CheckVersionLogic;
import com.fq.halcyon.logic.CheckVersionLogic.VersionCallback;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.util.UpdateVersion;
import com.hp.android.halcyon.widgets.CustomDialog;

public class WelcomeActivity extends Activity implements VersionCallback {

	private static final int WELCOME_TIME = 2000;
	private TextView mTextVision;
	private long mStartTime = System.currentTimeMillis();
	private Handler mHandler = new Handler();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_welcome);

		initWidgets();

//		Timer timer = new Timer();
//		TimerTask task = new TimerTask() {
//
//			@Override
//			public void run() {
//				gotoNextPage();
//			}
//		};
////		timer.schedule(task, 1200);
//		timer.schedule(task, 2000);
		
		mHandler.postDelayed(new Runnable() {
			@Override
			public void run() {
				CheckVersionLogic logic = new CheckVersionLogic();
				logic.checkVersion(Constants.CLIENT_DOCTOR_ANDORID, WelcomeActivity.this);
			}
		}, 100);
	}

	private void initWidgets() {
		mTextVision = (TextView) findViewById(R.id.welcome_vision);
		mTextVision.setText("V" + UITools.getVersionName());
		TextView tvServerVer = (TextView)findViewById(R.id.tv_server_ver);
		tvServerVer.setText(getServerVer());
	}
	
	/**
	 * 检测版本或welcome时间到后，根据需要去到下一个页面
	 */
	private void gotoNextPage(){
		SharedPreferences sharedPreferences = getSharedPreferences("dp_guide", MODE_PRIVATE);    
	    boolean isFirstRun = sharedPreferences.getBoolean("isFirstRun", true); 
	    if (isFirstRun)    
	    {    
	    	startActivity(new Intent(WelcomeActivity.this,GuidePageActivity.class));
	    } else    
	    {   
	    	startActivity(new Intent(WelcomeActivity.this,LoginActivity.class));
	    }   
		WelcomeActivity.this.finish();
	}
	
	/**
	 * 如果网络很快，仍然要等待
	 */
	private void delayGotoNextPage(){
		long delayTime = 0;
		if (System.currentTimeMillis() - mStartTime < WELCOME_TIME) {
			delayTime = WELCOME_TIME - (System.currentTimeMillis() - mStartTime);
			if(delayTime < 0){
				delayTime = 0;
			}
		}
		mHandler.postDelayed(new Runnable() {
			@Override
			public void run() {
				gotoNextPage();
			}
		}, delayTime);
	}
	
	
	/**
	 * 所属服务器信息
	 * @return
	 */
	private String getServerVer(){
		//默认是生产服务器
		String res = "内测版"; //当前阶段还是内测版，正式发布后改为空字符串
		if (UriConstants.Conn.URL_PUB.indexOf("115.29.229.128") >= 0) {
			res = "客户端开发版";
		} else if(UriConstants.Conn.URL_PUB.indexOf("115.29.239.19") >= 0) {
			res = "测试环境版";
		} else if(UriConstants.Conn.URL_PUB.indexOf("120.26.107.4") >= 0){
			res = "演示版";
		}
		return res;
	}

	@Override
	public void onBackPressed() {
	}
	
	@Override
	public void call(final Version version) {
		// 不需要更新
		runOnUiThread(new Runnable() {
			@Override
			public void run() {

				int code = UITools.getVersionCode();
				if (version == null || version.getVersionCode() <= code) {
					delayGotoNextPage();
				} else {// 需要更新
					final CustomDialog dialog = new CustomDialog(
							WelcomeActivity.this);
					dialog.setCanceledOnTouchOutside(false);
					dialog.setCancelable(false);
					dialog.setTitle("发现新的版本:v" + version.getVersionName());
					if (code >= version.getMinCode()) {// 可以不更新
						dialog.setPositiveListener(R.string.btn_upgrade,new View.OnClickListener(){
							public void onClick(View v) {
								dialog.dismiss();
								UITools.showToast("正在后台下载,可在通知栏查看");
								UpdateVersion.downloadApk(WelcomeActivity.this, version);
								delayGotoNextPage();
							}
						});
						dialog.setNegativeButton(R.string.btn_later,
								new View.OnClickListener() {
									public void onClick(View v) {
										dialog.dismiss();
										delayGotoNextPage();
									}
								});
					} else {// 必须更新
						dialog.setMessage("您的版本过低，需要更新以后才能使用");
						dialog.setPositiveListener(R.string.btn_upgrade,new View.OnClickListener(){
							public void onClick(View v) {
								dialog.dismiss();
								UITools.showToast("正在后台下载,可在通知栏查看");
								UpdateVersion.downloadApk(WelcomeActivity.this, version);
							}
						});
					}
				}
			}
		});
	}
}
