package com.hp.android.halcyon;

import android.view.View;
import android.widget.Button;

import com.fq.android.plus.R;
import com.fq.lib.tools.Constants;

public class GenderActivity extends BaseActivity {
	
	private Button mBtnMale,mBtnFemale;
	
	private int mSelectGender;
	@Override
	public int getContentId() {
		return R.layout.activity_gender;
	}

	@Override
	public void init() {
		setTitle("性别");
		setContainerTop();
		hideTitleLine();
		mSelectGender = Constants.getUser().getGender();
		if(mSelectGender == 0)mSelectGender = Constants.MALE;
		mBtnMale = (Button) findViewById(R.id.btn_gender_male);
		mBtnFemale = (Button) findViewById(R.id.btn_gender_female);
		setInfo(mSelectGender);
	}

	@Override
	public void onBackPressed() {
		if(mSelectGender != Constants.getUser().getGender()){
			Constants.getUser().setGender(mSelectGender);
			setResult(UserProfileActivity.CHANGE_GENDER_RESULT);
		}
		super.onBackPressed();
	}
	
	public void onGenderClick(View v){
		mSelectGender = Integer.valueOf((String)v.getTag()) ;
		setInfo(mSelectGender);
	}
	
	/**
	 * 设置显示
	 */
	private void setInfo(int gender) {
		switch (gender) {
		case Constants.MALE:
			mBtnMale.setSelected(true);
			mBtnFemale.setSelected(false);
			break;
		case Constants.FEMALE:
			mBtnMale.setSelected(false);
			mBtnFemale.setSelected(true);
			break;
		default:
			mBtnMale.setSelected(true);
			mBtnFemale.setSelected(false);
			break;
		}
	}
}
