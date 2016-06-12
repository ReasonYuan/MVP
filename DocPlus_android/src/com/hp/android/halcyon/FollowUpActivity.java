package com.hp.android.halcyon;

import android.content.Intent;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

import com.fq.android.plus.R;

public class FollowUpActivity extends BaseActivity implements OnClickListener{

	private Button mSendBtn;
	private Button mManageBtn;
	@Override
	public int getContentId() {
		return R.layout.activity_follow_up;
	}

	@Override
	public void init() {
		setTopLeftBtnShow(false);
		setTopRightImgSrc(R.drawable.btn_new_close);
		initWidget();
		initListener();
	}

	@Override
	public void onTopRightBtnClick(View view) {
		super.onBackPressed();
	}
	
	public void initWidget(){
		mSendBtn = (Button) findViewById(R.id.send_follow);
		 mManageBtn = (Button) findViewById(R.id.manage_follow);
		
	}
	
	public void initListener(){
		mSendBtn.setOnClickListener(this);
		mManageBtn.setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.send_follow:
			Log.e("发送随访", "发送随访");
			Intent mIntent = new Intent();
			mIntent.setClass(this, SelectFollowUpPatientActivity.class);
			startActivity(mIntent);
			break;
		case R.id.manage_follow:
			Log.e("管理随访", "管理随访");
			Intent mIntent1 = new Intent();
			mIntent1.setClass(this, ManageFollowUpTempleActivity.class);
			startActivity(mIntent1);
			break;
		default:
			break;
		}
	}
}
