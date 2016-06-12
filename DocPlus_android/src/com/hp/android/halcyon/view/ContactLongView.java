package com.hp.android.halcyon.view;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.widget.TextView;

import com.fq.android.plus.R;
//import com.hp.android.halcyon.tag.SettingTagActivity;
import com.fq.android.plus.tag.SettingTagActivity;
import com.fq.halcyon.entity.Contacts;

public class ContactLongView {

	private View mView;
	
	private ViewGroup mParent;
	private TextView mNameText;
	
	private Context mContext;
	
	private Contacts mUser;
	
	public ContactLongView(Context context,ViewGroup parent){
		mContext = context;
		mParent = parent;
		mView = LayoutInflater.from(context).inflate(R.layout.view_contacts_long, null);
		mNameText = (TextView)mView.findViewById(R.id.tv_contacts_long_name);
		
		
		mView.findViewById(R.id.btn_contact_set_tag).setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				if(mUser == null)return;
				Intent intent = new Intent(mContext, SettingTagActivity.class);
				intent.putExtra("user_id", mUser.getUserId());
				intent.putExtra("user", mUser);
				mContext.startActivity(intent);
				dismiss();
			}
		});
	}
	
	public void setContact(Contacts user){
		mUser = user;
		mNameText.setText(mUser.getName());
	}
	
	public boolean isShown(){
		return mView.isShown();
	}
	
	public void show(){
		mParent.addView(mView);
		AlphaAnimation alphaAnimation = new AlphaAnimation(0, 1);
		alphaAnimation.setDuration(500);
		mView.startAnimation(alphaAnimation);
	}
	
	public void dismiss(){
		AlphaAnimation alphaAnimation = new AlphaAnimation(1, 0);
		alphaAnimation.setDuration(500);
		mView.startAnimation(alphaAnimation);
		mParent.removeView(mView);
	}
	
	public ViewGroup getParent(){
		return mParent;
	}
	
}
