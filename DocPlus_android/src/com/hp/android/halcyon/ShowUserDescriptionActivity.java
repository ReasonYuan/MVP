package com.hp.android.halcyon;

import android.widget.EditText;

import com.fq.android.plus.R;

public class ShowUserDescriptionActivity extends BaseActivity{

	public static final String EXTRA_DES_CONTENT = "extra_des_content";
	
	
	@Override
	public int getContentId() {
		return R.layout.activity_show_description;
	}

	@Override
	public void init() {
		setTitle("个人简介");
//		setContainerTopUnderTopbar();
		
		EditText text = (EditText)findViewById(R.id.pde);
		text.setText(getIntent().getStringExtra(EXTRA_DES_CONTENT));
	}
}
