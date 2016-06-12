package com.hp.android.halcyon;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.User;
import com.fq.lib.tools.Constants;

public class SelectTitleActivity extends BaseActivity{

	/**
	 * 是否为医生职称，不是则为医学生当前在读（学历）
	 */
	private boolean mIsDoctorTitle;
	private String[] mTitles;
	private User mUser;
	
	@Override
	public int getContentId() {
		return R.layout.activity_select_title;
	}

	@Override
	public void init() {
		mUser = Constants.getUser();
		mIsDoctorTitle = getIntent().getBooleanExtra("doc_title", true);
		
		if(mIsDoctorTitle){
			setTitle("职称");
			mTitles = new String[]{"实习医生","住院医师","主治医师","副主任医师","主任医师"};
		}else{
			setTitle("当前在读");
			mTitles = new String[]{"本科","硕士","博士"};
		}
		
		ListView listView = (ListView) findViewById(R.id.lv_select_title);
		listView.setAdapter(new TitleAdapter());
		listView.setOnItemClickListener(new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view,int position, long id) {
				isChanged(position + 1);
			}
		});
	}
	
	private void isChanged(int selectedId){
		if(mIsDoctorTitle){
			if(selectedId != mUser.getTitle()){
				mUser.setTitle(selectedId);
				setResult(UserProfileActivity.CHANGE_DOCTOR_TITLE);
				finish();
			}
		}else{
			if(selectedId != mUser.getEducation()){
				mUser.setEducation(selectedId);
				setResult(UserProfileActivity.CHANGE_DOCSTD_EDCATION);
				finish();
			}
		}
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
		public View getView(int position, View convertView, ViewGroup parent) {
			if(convertView == null){
				convertView = LayoutInflater.from(SelectTitleActivity.this).inflate(R.layout.site_item_center, null);
			}
			
			((TextView)convertView.findViewById(R.id.tv_btn_list_text)).setText(mTitles[position]);
			if(mUser.getRole_type() == Constants.ROLE_DOCTOR){
				convertView.setSelected(mUser.getTitle() == position+1);
			}else{
				convertView.setSelected(mUser.getEducation() == position+1);
			}
			return convertView;
		}
	}
}
