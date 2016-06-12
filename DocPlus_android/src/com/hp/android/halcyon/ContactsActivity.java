package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.HashMap;

import android.app.ActionBar.LayoutParams;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnKeyListener;
import android.view.View.OnLongClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic2.ContactLogic;
import com.fq.halcyon.logic2.ContactLogic.ContactLogicInterface;
import com.fq.halcyon.logic2.TagLogic;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.tag.TagListActivity;
import com.hp.android.halcyon.util.IntentKey;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.view.ContactLongView;
import com.hp.android.halcyon.widgets.CircleImageView;
import com.hp.android.halcyon.widgets.SearchView;
import com.hp.android.halcyon.widgets.SearchView.SearchListener;

public class ContactsActivity extends BaseActivity implements OnClickListener {

	private FrameLayout mFrameLayout;
	private View mDoctorView;
	private View mPatientView;
	private View mDocStuView;
	private LinearLayout mDocNewFriends;
	private LinearLayout mDocTag;
	private LinearLayout mDocDepartment;
	private LinearLayout mPatientNewFriends;
	private LinearLayout mPatientTag;
	private LinearLayout mDocStuNewFriends;
	private LinearLayout mDocStuTag;
	private ListView mDoctorListView;
	private ListView mPatientListView;
	private ListView mDocStuListView;
//	private int mOtherType;
	private ContactsAdapter mDoctorAdapter;
	private ContactsAdapter mPatientdapter;
	private ArrayList<Contacts> mDoctorList;
	private ArrayList<Contacts> mPatientList;
//	private ArrayList<Contacts> mDocStuList;
	private PopupWindow mPop;
	private FrameLayout mSearchFl;
	private EditText mEditText;
	private FrameLayout mDoctorLi;
	private FrameLayout mPatientLi;
	private FrameLayout mDocStuLi;
	private FrameLayout mSearchCancel;// 用于清除搜索框的内容
	private SearchView mSearchContact;
	private ContactLongView mContactLongView;

	private HashMap<String, ArrayList<Contacts>> mHashPeerList = new HashMap<String, ArrayList<Contacts>>();

	private FrameLayout mDoctorContact;
	private FrameLayout mPatientContact;
//	private View mTagLine;

	@Override
	public int getContentId() {
		return R.layout.activity_contacts;
	}

	public void onViewDismisss(View v) {
		mContactLongView.dismiss();
	}

	@Override
	public void init() {
		getWindow().setSoftInputMode(
				WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN
						| WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING);
		setTopLeftImgSrc(R.drawable.btn_back);
		setTopRightImgSrc(R.drawable.btn_new_friend_right);
		setTitle("通讯录");
		mSearchCancel = (FrameLayout) findViewById(R.id.btn_contact_search_clean);
		mSearchContact = (SearchView) findViewById(R.id.sv_contacts_search);
		mDoctorList = new ArrayList<Contacts>();
		mPatientList = new ArrayList<Contacts>();
//		mDocStuList = new ArrayList<Contacts>();

		mFrameLayout = (FrameLayout) findViewById(R.id.container);

		mDoctorLi = (FrameLayout) findViewById(R.id.doctor_li);
		mPatientLi = (FrameLayout) findViewById(R.id.patient_li);
		mDocStuLi = (FrameLayout) findViewById(R.id.doc_stu_li);
		mDoctorLi.setOnClickListener(this);
		mPatientLi.setOnClickListener(this);
		mDocStuLi.setOnClickListener(this);

		mDoctorView = LayoutInflater.from(this).inflate(
				R.layout.contacts_doctor_view, null);
		mPatientView = LayoutInflater.from(this).inflate(
				R.layout.contacts_other_view, null);
		mDocStuView = LayoutInflater.from(this).inflate(
				R.layout.contacts_other_view, null);

		// mTagLine = mDocStuView.findViewById(R.id.tag_line);

		mDocNewFriends = (LinearLayout) mDoctorView
				.findViewById(R.id.new_friends);
		mDocTag = (LinearLayout) mDoctorView.findViewById(R.id.tag);
		mDocDepartment = (LinearLayout) mDoctorView
				.findViewById(R.id.department);
		mDoctorListView = (ListView) mDoctorView.findViewById(R.id.doctor_list);

		mPatientNewFriends = (LinearLayout) mPatientView
				.findViewById(R.id.new_friends_other);
		mPatientTag = (LinearLayout) mPatientView.findViewById(R.id.tag_other);
		mPatientListView = (ListView) mPatientView
				.findViewById(R.id.doctor_list_other);

		mDocStuNewFriends = (LinearLayout) mDocStuView
				.findViewById(R.id.new_friends_other);
		mDocStuTag = (LinearLayout) mDocStuView.findViewById(R.id.tag_other);
		mDocStuListView = (ListView) mDocStuView
				.findViewById(R.id.doctor_list_other);
		mSearchFl = (FrameLayout) findViewById(R.id.search_fl_layout);
		mSearchFl.setOnClickListener(this);
		mEditText = (EditText) findViewById(R.id.edt_search);

		mEditText.setOnKeyListener(new OnKeyListener() {

			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				if (keyCode == KeyEvent.KEYCODE_ENTER
						&& event.getAction() == KeyEvent.ACTION_DOWN) {
					((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE))
							.hideSoftInputFromWindow(ContactsActivity.this
									.getCurrentFocus().getWindowToken(),
									InputMethodManager.HIDE_NOT_ALWAYS);

					onClick(mSearchFl);
					return true;
				}
				return false;
			}
		});

		// 搜索框内容改变事件
		mEditText.addTextChangedListener(new MyTextWatch());

		// 清除搜索框内容
		mSearchCancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				mEditText.setText("");
			}
		});

		mDocNewFriends.setOnClickListener(this);
		mPatientNewFriends.setOnClickListener(this);
		mDocStuNewFriends.setOnClickListener(this);
		mDocTag.setOnClickListener(this);
		mPatientTag.setOnClickListener(this);
		mDocStuTag.setOnClickListener(this);
		mDocDepartment.setOnClickListener(this);

		mDoctorAdapter = new ContactsAdapter();
		mPatientdapter = new ContactsAdapter();
		mDoctorListView.setAdapter(mDoctorAdapter);
		mPatientListView.setAdapter(mPatientdapter);
		mDocStuListView.setAdapter(mPatientdapter);
		initPopWindow();

		mDoctorContact = (FrameLayout) findViewById(R.id.doctor_contact);
		mPatientContact = (FrameLayout) findViewById(R.id.patient_contact);

		mDoctorContact.setOnClickListener(this);
		mPatientContact.setOnClickListener(this);

		mDoctorContact.setSelected(true);
		onClick(mDoctorContact);

		mSearchContact.setSearchListener(new SearchListener() {
			// 搜索事件
			@Override
			public void searchChange(String key) {

			}

			@Override
			public void searchCallback(String key) {
				if (!"".equals(key)) {
					Intent intent = new Intent();
					intent.putExtra("isNewFriend", false);
					intent.putExtra("mKeyWords", key);
					intent.setClass(ContactsActivity.this,
							ContactSearchActivity.class);
					startActivity(intent);
				}
				((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE))
						.hideSoftInputFromWindow(ContactsActivity.this
								.getCurrentFocus().getWindowToken(),
								InputMethodManager.HIDE_NOT_ALWAYS);
			}
		});
	}

	/**是否第一次进入界面*/
	private boolean mIsFirst = true;
	@Override
	protected void onResume() {
		super.onResume();
		if(mIsFirst){
			mIsFirst = false;
			return;
		}
		initData();
	}

	// 服务器返回真数据
	public void initData() {
		new ContactLogic(new ContactLogicInterface() {
			@Override
			public void onError(int code, Throwable e) {
				UITools.showToast("网络异常或不稳定，请稍后再试");
				e.printStackTrace();
			}

			@Override
			public void onDataReturn(
					HashMap<String, ArrayList<Contacts>> hashPeerList) {

				new TagLogic().getListAllTags(null);
				mHashPeerList = hashPeerList;
				mDoctorList = Constants.contactsMap.get(Constants.ROLE_DOCTOR);
				mPatientList = Constants.contactsMap.get(Constants.ROLE_PATIENT);
//				mDocStuList = Constants.contactsMap.get(Constants.ROLE_DOCTOR_STUDENT);
				mDoctorAdapter.setType(1);
				mDoctorAdapter.setList(mDoctorList);
				mPatientdapter.setList(mPatientList);
				mPatientdapter.setType(2);
				mDoctorAdapter.notifyDataSetChanged();
				mPatientdapter.notifyDataSetChanged();
			}
		}, Constants.getUser().getUserId());
	}

	private void getDataFromServert(int type) {
		switch (type) {
		case 1:
			initData();
			mDoctorAdapter.setType(1);
			mFrameLayout.removeAllViews();
			mFrameLayout.addView(mDoctorView);
			break;
		case 2:
			mPatientdapter.setType(2);
			mFrameLayout.removeAllViews();
			mFrameLayout.addView(mPatientView);
			break;
		case 3:
			mFrameLayout.removeAllViews();
			mFrameLayout.addView(mDocStuView);
			break;
		default:
			break;
		}
	}

	private void initPopWindow() {
		View View = LayoutInflater.from(ContactsActivity.this).inflate(
				R.layout.contact_add_pop, null);
		mPop = new PopupWindow(View, LayoutParams.WRAP_CONTENT,
				LayoutParams.WRAP_CONTENT, false);
		TextView mAddFriends = (TextView) View.findViewById(R.id.add_friends);
		TextView mFinding = (TextView) View.findViewById(R.id.finding);
		mAddFriends.setOnClickListener(this);
		mFinding.setOnClickListener(this);
		// 需要设置一下此参数，点击外边可消失
		mPop.setBackgroundDrawable(new BitmapDrawable());
		// 设置点击窗口外边窗口消失
		mPop.setOutsideTouchable(true);
		// 设置此参数获得焦点，否则无法点击
		mPop.setFocusable(true);
	}

	@Override
	public void onTopRightBtnClick(View v) {
		super.onTopRightBtnClick(v);
		Intent mIntent = new Intent();
		mIntent.setClass(ContactsActivity.this,
				ContactsAddFriendsWayActivity.class);
		startActivity(mIntent);
	}

	@Override
	public void onTopLeftBtn2Click(View view) {
		super.onTopLeftBtn2Click(view);
	}

	@Override
	public void onBackPressed() {
		if (mContactLongView != null && mContactLongView.isShown()) {
			mContactLongView.dismiss();
			return;
		}
		super.onBackPressed();
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.doctor_contact:
//			mOtherType = 0;
			getDataFromServert(1);
			mPatientLi.setSelected(false);
			mDoctorLi.setSelected(true);
			mDoctorContact.setSelected(true);
			mPatientContact.setSelected(false);
			break;
		case R.id.patient_contact:
//			mOtherType = 1;
			getDataFromServert(2);
			mPatientLi.setSelected(true);
			mDocStuLi.setSelected(false);
			mDoctorContact.setSelected(false);
			mPatientContact.setSelected(true);
			break;
		// case R.id.doc_stu_li:
		// mOtherType = 2;
		// getDataFromServert(3);
		// mPatientLi.setSelected(false);
		// mDocStuLi.setSelected(true);
		// mDoctorLi.setSelected(false);
		// break;
		case R.id.new_friends:
			Intent mIntent = new Intent();
			mIntent.setClass(ContactsActivity.this, NewFriendsActivity.class);
			startActivity(mIntent);
			break;
		case R.id.new_friends_other:
			Intent mIntent1 = new Intent();
			mIntent1.setClass(ContactsActivity.this, NewFriendsActivity.class);
			startActivity(mIntent1);
			break;
		case R.id.tag:
		case R.id.tag_other:
			Intent intentTag = new Intent(this, TagListActivity.class);
			startActivity(intentTag);
			break;
		case R.id.department:
			Intent mIntent2 = new Intent();
			mIntent2.putExtra("mDepartmentMap", mHashPeerList);
			mIntent2.setClass(ContactsActivity.this,
					ContactDepartmentActivity.class);
			startActivity(mIntent2);
			break;
		case R.id.add_friends:
			Intent mIntent3 = new Intent();
			mIntent3.setClass(ContactsActivity.this,
					ContactSearchActivity.class);
			startActivity(mIntent3);
			if (mPop.isShowing())
				mPop.dismiss();
			break;
		case R.id.finding:
			startActivity(new Intent(this, ZxingScanActivity.class));// ZBarScannerActivity
			if (mPop.isShowing())
				mPop.dismiss();
			break;
		case R.id.search_fl_layout:
			String mStr = mEditText.getText().toString().trim();
			if (mStr.length() != 0) {
				Intent mIntent4 = new Intent();
				mIntent4.putExtra("isNewFriend", false);
				mIntent4.putExtra("mKeyWords", mStr);
				mIntent4.setClass(ContactsActivity.this,
						ContactSearchActivity.class);
				startActivity(mIntent4);
			}
			break;
		default:
			break;
		}
	}

	private class ContactsAdapter extends BaseAdapter implements
			OnLongClickListener {
		private ArrayList<Contacts> mUserList = new ArrayList<Contacts>();
		private int type;

		public void setList(ArrayList<Contacts> mList) {
			if (mList != null)
				mUserList = mList;
		}

		public void setType(int mType) {
			this.type = mType;
		}

		@Override
		public int getCount() {
			return mUserList.size();
		}

		@Override
		public Object getItem(int position) {
			return mUserList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(ContactsActivity.this)
						.inflate(R.layout.item_contacts_list, null);
			}
			if (type == 1) {// 医生列表
				mUserList = mDoctorList;
			} else if (type == 2) {// 病人列表
				mUserList = mPatientList;
			}
			final CircleImageView mHeadImage = (CircleImageView) convertView
					.findViewById(R.id.head_image);
			TextView mName = (TextView) convertView.findViewById(R.id.name);
			final Contacts mCurrentUser = mUserList.get(position);
			mName.setText(mCurrentUser.getName());

			final Photo photo = new Photo();
			photo.setImageId(mCurrentUser.getImageId());
			
			//==YY==imageId(只要imageId)
//			photo.setImagePath(mCurrentUser.getHeadPicPath());
			ApiSystem.getInstance().getHeadImage(photo, new ICallback() {

				@Override
				public void doCallback(Object obj) {
					mHeadImage.setImageBitmap(UITools.getBitmapWithPath(""
							+ obj));
				}

			}, false, 2);

			LinearLayout mLayout = (LinearLayout) convertView
					.findViewById(R.id.item_linearlayout);
			mLayout.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					Intent intent = new Intent(ContactsActivity.this,
							UserInfoActivity.class);
					intent.putExtra("user", mCurrentUser);
					intent.putExtra(IntentKey.EXTRA_RELATION_ID,
							mCurrentUser.getRelationId());
					intent.putExtra("is_friend", true);
					startActivity(intent);
				}
			});
			mLayout.setTag(mCurrentUser);
			mLayout.setOnLongClickListener(this);
			return convertView;
		}

		@Override
		public boolean onLongClick(View v) {
			if (mContactLongView == null) {
				ViewGroup parent = (ViewGroup) findViewById(R.id.ll_parent);
				mContactLongView = new ContactLongView(ContactsActivity.this,
						parent);
			}
			mContactLongView.setContact((Contacts) v.getTag());

			mContactLongView.show();
			return true;
		}
	}

	private class MyTextWatch implements TextWatcher {

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

	}
}
