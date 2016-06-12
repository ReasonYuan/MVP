package com.hp.android.halcyon;

import android.content.Intent;
import android.net.Uri;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.hp.android.halcyon.util.UITools;

public class AboutPlusActivity extends BaseActivity {

	private TextView mDeal;
	private TextView mVersion;
	private RelativeLayout mGrade;
	private RelativeLayout mWelcome;
	private RelativeLayout mFunction;
	private RelativeLayout mNotice;
	private RelativeLayout mHelp;

	@Override
	public int getContentId() {
		return R.layout.activity_about;
	}

	@Override
	public void init() {
		setTitle(R.string.about_title);
		setTopLeftBtnShow(true);
		initWidget();

		mVersion.setText(getString(R.string.about_version, UITools.getVersionName()));

		mGrade.setOnClickListener(new OnClickListener() {
			// 去评分的点击事件处理
			@Override
			public void onClick(View arg0) {
				Uri uri = Uri.parse("market://details?id="+getPackageName());
				Intent intent = new Intent(Intent.ACTION_VIEW,uri);
				intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				startActivity(intent);
			}
		});

		mWelcome.setOnClickListener(new OnClickListener() {
			// 欢迎页的点击事件处理
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

			}
		});

		mFunction.setOnClickListener(new OnClickListener() {
			// 功能介绍的点击事件处理
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

			}
		});

		mNotice.setOnClickListener(new OnClickListener() {
			// 系统通知的点击事件处理
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

			}
		});

		mHelp.setOnClickListener(new OnClickListener() {
			// 帮助与反馈的点击事件处理
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub

			}
		});

		mDeal.setOnClickListener(new OnClickListener() {
			// 协议文字点击事件处理
			@Override
			public void onClick(View arg0) {
				Intent intent = new Intent(AboutPlusActivity.this,
						DealActivity.class);
				startActivity(intent);
			}
		});
	}

	/**
	 *初始化控件 
	 */
	public void initWidget() {
		mDeal = (TextView) findViewById(R.id.tv_about_deal);
		mVersion = (TextView) findViewById(R.id.tv_about_version);
		mGrade = (RelativeLayout) findViewById(R.id.rl_about_grade);
		mWelcome = (RelativeLayout) findViewById(R.id.rl_about_welcome);
		mFunction = (RelativeLayout) findViewById(R.id.rl_about_function);
		mNotice = (RelativeLayout) findViewById(R.id.rl_about_notice);
		mHelp = (RelativeLayout) findViewById(R.id.rl_about_help);
		
		mGrade.setSelected(true);
		
		//TODO 设置其他几项不可用
		mWelcome.setEnabled(false);
		mWelcome.setSelected(false);
		mFunction.setEnabled(false);
		mFunction.setSelected(false);
		mNotice.setEnabled(false);
		mNotice.setSelected(false); 
		mHelp.setEnabled(false);
		mHelp.setSelected(false);
	}
}
