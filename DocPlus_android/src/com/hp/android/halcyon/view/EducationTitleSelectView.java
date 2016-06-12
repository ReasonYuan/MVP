package com.hp.android.halcyon.view;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.User;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;

public class EducationTitleSelectView {

	private View mView;
	private Context mContext;
	
	private String[] mTitles;
	private User mUser;
	private ICallback mCallback;
	private View view;
	
	public View getView(){
		return mView;
	}
	
	/**
	 * isDoctorTitle 是否为医生职称，不是则为医学生当前在读（学历）
	 */
	public EducationTitleSelectView(Context context,boolean isDoctorTitle,ICallback back){
		mContext = context;
		mCallback = back;
		
		mUser = Constants.getUser();
		
		if(isDoctorTitle){
			mTitles = new String[]{"实习医生","住院医师","主治医师","副主任医师","主任医师"};
		}else{
			mTitles = new String[]{"本科","硕士","博士"};
		}
		
		mView = LayoutInflater.from(context).inflate(R.layout.view_education_title, null);
		ListView listView = (ListView) mView.findViewById(R.id.lv_education_title);
		listView.setAdapter(new TitleAdapter());
//		listView.setOnItemClickListener(new OnItemClickListener() {
//			public void onItemClick(AdapterView<?> parent, View view,int position, long id) {
//				isChanged(position + 1);
//			}
//		});
		mView.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				remove4Parent();
			}
		});
		/*mView.setOnKeyListener(new OnKeyListener() {
			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				if(keyCode == KeyEvent.KEYCODE_BACK){
					mView.setBackgroundColor(0xdbdbdb);
					remove4Parent();
					return true;
				}
				return false;
			}
		});*/
	}
	
	public void remove4Parent(){
		AlphaAnimation alphaAnimation = new AlphaAnimation(1, 0);
		alphaAnimation.setDuration(500);
		
		mView.startAnimation(alphaAnimation);
		ViewGroup group = (ViewGroup) mView.getParent();
		if(group!=null)group.removeView(mView);
	}
	
	private void isChanged(int selectedId){
/*		if(mIsDoctorTitle){
			if(selectedId != mUser.getTitle()){
				mUser.setTitle(selectedId);
				setResult(UserProfileActivity.CHANGE_DOCTOR_TITLE);
			}
		}else{
			if(selectedId != mUser.getEducation()){
				mUser.setEducation(selectedId);
				setResult(UserProfileActivity.CHANGE_DOCSTD_EDCATION);
			}
		}*/
		if(mCallback != null){
			mCallback.doCallback(selectedId);
		}
		remove4Parent();
	}
	
	public class TitleAdapter extends BaseAdapter{

		@Override
		public int getCount() {
			return mTitles.length;
		}

		@Override
		public Object getItem(int position) {
			return mTitles[position];
		}

		@Override
		public long getItemId(int position) {
			return 0;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			if(convertView == null){
				convertView = LayoutInflater.from(mContext).inflate(R.layout.item_education_title_view, null);
			}
			TextView tv = (TextView)convertView.findViewById(R.id.tv_btn_list_text);
			
			tv.setText(mTitles[position]);
			if (mTitles[position].equals(mUser.getTitleStr())) {
				tv.setTextColor(mContext.getResources().getColor(R.color.text_zhicheng_selected));
				view = tv;
			}else {
//				tv.setTextColor(0xffF0D6AF);
				tv.setTextColor(mContext.getResources().getColor(R.color.text_zhicheng_nomarl));
			}
			tv.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					if (view != null) {
						((TextView)view).setTextColor(mContext.getResources().getColor(R.color.text_zhicheng_nomarl));
					}
					((TextView)arg0).setTextColor(mContext.getResources().getColor(R.color.text_zhicheng_selected));
					view = arg0;
					isChanged(position + 1);
				}
			});
			if(mUser.getRole_type() == Constants.ROLE_DOCTOR){
				convertView.setSelected(mUser.getTitle() == position+1);
			}else{
				convertView.setSelected(mUser.getEducation() == position+1);
			}
			return convertView;
		}
	}
}
