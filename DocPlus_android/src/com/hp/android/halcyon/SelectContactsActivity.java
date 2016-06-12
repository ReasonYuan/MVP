package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Photo;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CircleImageView;

public class SelectContactsActivity extends BaseActivity implements
		OnClickListener {
	
	public static final int CONTACTS_RESULT_CODE = 222;

	public static final String EXTRAS_TAG_TITLE = "tag_title";
	public static final String EXTRAS_SEL_RECORDIDS = "unsel_records";
	public static final String EXTRAS_SEL_RECORDS = "sel_records";
	
	//private FrameLayout mSearchCancel;// 用于清除搜索框的内容
	private EditText mEditText;
	private FrameLayout mDoctorLi;
	private FrameLayout mPatientLi;
//	private FrameLayout mDocStuLi;
	private ListView mSelectListView;
	private MyAdapter mAdapter;
	private ArrayList<Contacts> mDoctorList;
	private ArrayList<Contacts> mPatientList;
//	private ArrayList<Contacts> mDocStuList;
	private FrameLayout mSearch;

	private ArrayList<Integer> mUnEnableContacts;
	private ArrayList<Contacts> mSelectContacts = new ArrayList<Contacts>();
	
	@Override
	public int getContentId() {
		return R.layout.activity_select_contact;
	}

	/*@Override
	public void onTopLeftBtnClick(View view) {
		// startActivity(new Intent(this, SetRemindActivity.class));
		finish();
		super.onTopLeftBtnClick(view);
	}*/

	@Override
	public void onTopRightBtnClick(View view) {
		//final int size = mSelectContacts.size();
		//if(size == 0)return;
		Intent intent = new Intent();
		intent.putExtra(EXTRAS_SEL_RECORDS, mSelectContacts);
		setResult(CONTACTS_RESULT_CODE, intent);
		finish();
	}
	
	
	@Override
	public void init() {
		mDoctorList = new ArrayList<Contacts>();
		mPatientList = new ArrayList<Contacts>();
//		mDocStuList = new ArrayList<Contacts>();
		setTopRightImgSrc(R.drawable.snapphoto_camera_ok);
		setTitle("通讯录");
		
		
		findViewById(R.id.ll_contact_search_bar).setVisibility(View.GONE);
		/*mSearchCancel = (FrameLayout) findViewById(R.id.btn_contact_search_clean);
		mEditText = (EditText) findViewById(R.id.edt_search);

		// 搜索框内容改变事件
		mEditText.addTextChangedListener(new MyTextWatch());

		// 清除搜索框内容
		mSearchCancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				mEditText.setText("");
			}
		});*/
		
		mDoctorList = Constants.contactsMap.get(Constants.ROLE_DOCTOR);
		mPatientList = Constants.contactsMap.get(Constants.ROLE_PATIENT);
//		mDocStuList = Constants.contactsMap.get(Constants.ROLE_DOCTOR_STUDENT);

		mUnEnableContacts = (ArrayList<Integer>) getIntent().getSerializableExtra(EXTRAS_SEL_RECORDIDS);
		
		mDoctorLi = (FrameLayout) findViewById(R.id.select_doctor_li);
		mPatientLi = (FrameLayout) findViewById(R.id.select_patient_li);
//		mDocStuLi = (FrameLayout) findViewById(R.id.select_doc_stu_li);
		mDoctorLi.setOnClickListener(this);
		mPatientLi.setOnClickListener(this);
//		mDocStuLi.setOnClickListener(this);
		mSearch = (FrameLayout) findViewById(R.id.search_fl_layout);
		mSearch.setOnClickListener(this);
		mSelectListView = (ListView) findViewById(R.id.select_listview);
		mAdapter = new MyAdapter();
		mSelectListView.setAdapter(mAdapter);
		onClick(mDoctorLi);
	}

	/*private void getFromServer() {
		new ContactLogic(new ContactLogicInterface() {

			@Override
			public void onError(int code, Throwable e) {
				UITools.showToast("网络异常或不稳定，请稍后再试");
				e.printStackTrace();
			}

			@Override
			public void onDataReturn(
					HashMap<String, ArrayList<User>> hashPeerList) {
				mDoctorList = Constants.contactsMap.get(Constants.ROLE_DOCTOR);
				mPatientList = Constants.contactsMap.get(Constants.ROLE_PATIENT);
				mDocStuList = Constants.contactsMap
						.get(Constants.ROLE_DOCTOR_STUDENT);

				mAdapter.setList(mDoctorList);
				mAdapter.notifyDataSetChanged();
			}
		}, Constants.user.getUserId());
	}*/

	private void getData(int type) {
		switch (type) {
		case 1:
			mAdapter.setList(mDoctorList);
			mAdapter.notifyDataSetChanged();
			break;
		case 2:
			mAdapter.setList(mPatientList);
			mAdapter.notifyDataSetChanged();
			break;
//		case 3:
//			mAdapter.setList(mDocStuList);
//			mAdapter.notifyDataSetChanged();
//			break;
		default:
			break;
		}
	}

	private class MyAdapter extends BaseAdapter implements OnClickListener{
		private ArrayList<Contacts> mList = new ArrayList<Contacts>();

		public void setList(ArrayList<Contacts> list) {
			mList = list;
		}

		@Override
		public int getCount() {
			return mList.size();
		}

		@Override
		public Contacts getItem(int position) {
			return mList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView,
				ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(SelectContactsActivity.this).inflate(R.layout.item_contacts_select, parent,false);
			}
			final CircleImageView mHeadImage = (CircleImageView) convertView
					.findViewById(R.id.head_image);
			TextView mName = (TextView) convertView.findViewById(R.id.name);
			final Contacts mCurrentUser = mList.get(position);
			mName.setText(mCurrentUser.getName());

			ApiSystem.getInstance().getHeadImage(new Photo(mCurrentUser.getImageId(), ""), new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					mHeadImage.setImageBitmap(UITools.getBitmapWithPath(""+obj));
				}
			}, false, 2);
//			ImageManager.from(SelectContactsActivity.this).displayImage(
//					mHeadImage, mCurrentUser.getHeadPicPath(),
//					R.color.app_head_pink);
/*
			LinearLayout mLayout = (LinearLayout) convertView
					.findViewById(R.id.item_linearlayout);
			mLayout.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					Intent intent = new Intent();
					intent.putExtra("user", getItem(position));
					setResult(RESULT_OK, intent);
					finish();
				}
			});*/
			
			CheckBox ckb = (CheckBox)convertView.findViewById(R.id.ckb_contacts_select);
			
			if(mUnEnableContacts != null){
            	for(int id :mUnEnableContacts){
            		if(id == mCurrentUser.getUserId()){
            			convertView.setEnabled(false);
            			ckb.setEnabled(false);
            			return convertView;
            		}
            	}
            }
			
			convertView.setEnabled(true);
			ckb.setEnabled(true);
			ckb.setChecked(mSelectContacts.contains(mCurrentUser));
			ckb.setTag(mCurrentUser);
			ckb.setOnClickListener(this);
			
			convertView.setTag(mCurrentUser);
			convertView.setOnClickListener(this);
			
			return convertView;
		}

		@Override
		public void onClick(View v) {
			Contacts user = (Contacts) v.getTag();
			if(mSelectContacts.contains(user)){
				mSelectContacts.remove(user);
			}else{
				mSelectContacts.add(user);
			}
			notifyDataSetChanged();
		}
	}
	/*private class MyTextWatch implements TextWatcher {

		@Override
		public void afterTextChanged(Editable arg0) {

		}

		@Override
		public void beforeTextChanged(CharSequence arg0, int arg1, int arg2,
				int arg3) {

		}

		@Override
		public void onTextChanged(CharSequence s, int arg1, int arg2, int arg3) {
			if (s.length() > 0) {
				mSearchCancel.setVisibility(View.VISIBLE);
			} else {
				mSearchCancel.setVisibility(View.GONE);
			}
		}

	}*/

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.select_doctor_li:
			getData(1);
			mPatientLi.setSelected(false);
			mDoctorLi.setSelected(true);
//			mDocStuLi.setSelected(false);
			break;
		case R.id.select_patient_li:
			getData(2);
			mPatientLi.setSelected(true);
//			mDocStuLi.setSelected(false);
			mDoctorLi.setSelected(false);
			break;
//		case R.id.select_doc_stu_li:
//			getData(3);
//			mPatientLi.setSelected(false);
//			mDocStuLi.setSelected(true);
//			mDoctorLi.setSelected(false);
//			break;
		case R.id.search_fl_layout:
			String mSearchStr = mEditText.getText().toString().trim();
			if ("".equals(mSearchStr) || mSearchStr == null) {
				return;
			} else {
				Intent mIntent2 = new Intent();
				mIntent2.putExtra("isNewFriend", false);
				mIntent2.putExtra("isFromSetRemind", true);
				mIntent2.putExtra("mKeyWords", mSearchStr);
				mIntent2.setClass(SelectContactsActivity.this,
						ContactSearchActivity.class);
				startActivityForResult(mIntent2, 100);
			}
			break;
		default:
			break;
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == 100 && resultCode == RESULT_OK) {
			Intent intent = new Intent();
			intent.putExtra("user", data.getSerializableExtra("user"));
			setResult(RESULT_OK, intent);
			finish();
		}
		super.onActivityResult(requestCode, resultCode, data);
	}
}
