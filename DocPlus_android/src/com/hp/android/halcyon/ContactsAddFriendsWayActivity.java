package com.hp.android.halcyon;


import android.content.Intent;
import android.view.View;

import com.fq.android.plus.R;

public class ContactsAddFriendsWayActivity extends BaseActivity {
//private Button mCancel;
	@Override
	public int getContentId() {
		// TODO Auto-generated method stub
		return R.layout.activity_add_friends_way;
	}

	@Override
	public void init() {
		// TODO Auto-generated method stub
		
		setTopLeftBtnShow(false);
//		mCancel = (Button)findViewById(R.id.button1);

	}

	public void cancel(View view) {
		onBackPressed();
	}
	public void finding(View view) {
		startActivity(new Intent(ContactsAddFriendsWayActivity.this, ZxingScanActivity.class));
		finish();
	}
	public void add(View view) {
		Intent mIntent3 = new Intent();
		mIntent3.setClass(ContactsAddFriendsWayActivity.this,
				ContactSearchActivity.class);
		startActivity(mIntent3);
		finish();
	}

}
