package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Person;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic2.ReadUserInfoLogic;
import com.fq.halcyon.logic2.ReadUserInfoLogic.OnReadInfoCallback;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.hp.android.halcyon.lbs.UserInfoManager;
import com.hp.android.halcyon.util.IntentKey;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;

@SuppressLint("NewApi")
public class UserInfoActivity extends BaseActivity implements
		OnReadInfoCallback {

	private int mRelationId;
	private Person mUser;
	private List<String> mDeses = new ArrayList<String>();
	private TextView mTvDocNum;
	private HashMap<String, ArrayList<Contacts>> mDepartmentMap = new HashMap<String, ArrayList<Contacts>>();
	private CommonAdapter<String> mAdapter;

	private ReadUserInfoLogic mLogic;
	private ImageView mImgHead;
	private Button setFollowUpBtn;
	private Button addOrDelFriendBtn;
	private boolean mFromZxing;
	private String depNameString;
	private TextView mUserName;
	private TextView mUserGender;
	private ListView mListView;

	private String[] mTitles = {};
	private int[] mIcons = {};

	private UserInfoManager mUserinfomInfoManager;

	@Override
	public int getContentId() {
		return R.layout.activity_user_info;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		mUserinfomInfoManager = UserInfoManager.instance();
	}

	@Override
	public void init() {
		setTitle("详细资料");
		initWidgets();
		initDatas();
		initListener();
	}

	@SuppressWarnings("unchecked")
	private void initDatas() {
		Bundle bundle = getIntent().getExtras();
		mDepartmentMap = (HashMap<String, ArrayList<Contacts>>) bundle
				.get("departmentMap");
		depNameString = getIntent().getStringExtra("departmentName");
		mLogic = new ReadUserInfoLogic();
		mUser = (Person) getIntent().getSerializableExtra(IntentKey.EXTRA_USER);
		if (mUser != null) {
			boolean isb = getIntent().getBooleanExtra(
					IntentKey.EXTRA_IS_FRIEND, false);
			mRelationId = getIntent().getIntExtra(IntentKey.EXTRA_RELATION_ID,
					-1);
			initInfo(mUser);
			initSetFollowUpBtn(isb);
			initAddOrDelFriendBtn(isb);
			mLogic.readUserInfoByPost(mUser.getUserId(), this);
		} else {
			String url = getIntent().getStringExtra("scan_url");
			mFromZxing = true;
			int starId = url.indexOf("user_id=");
			String strId = url.substring(starId + 8);
			try {
				int uerId = Integer.valueOf(strId);
				if (uerId == Constants.getUser().getUserId()) {
					mUser = Constants.getUser();
					initInfo(mUser);
					initHashMap();
				} else {
					if (!"".equals(url))
						mLogic.readUserInfoByGet(url, this);
				}
			} catch (Exception e) {

				e.printStackTrace();
			}
		}
	}

	private void initWidgets() {
		mImgHead = (ImageView) findViewById(R.id.iv_user_info_head);
		mUserName = (TextView) findViewById(R.id.tv_user_info_name);
		mUserGender = (TextView) findViewById(R.id.tv_user_info_gender);
		mTvDocNum = ((TextView) findViewById(R.id.tv_user_info_dpname));
		mListView = (ListView) findViewById(R.id.lv_user_info);
		setFollowUpBtn = (Button) findViewById(R.id.btn_user_info_send);
		addOrDelFriendBtn = (Button) findViewById(R.id.btn_user_info_del);
		mListView.setAdapter(mAdapter = new CommonAdapter<String>(this,
				R.layout.item_user_info) {

			@Override
			public void convert(int position, ViewHolder helper, String object) {

				ImageView imgIcon = helper.getView(R.id.iv_user_info_icon);
				imgIcon.setBackgroundResource(mIcons[position]);
				helper.setText(R.id.tv_user_info_title, mTitles[position]);
				helper.setText(R.id.tv_user_info_des, mDeses.get(position));

			}
		});
	}

	private void initListener() {
		mListView.setOnItemClickListener(new OnItemClickListener() {
			// 如果是个人简介的字数超过十，则可以点击，其他不可点击
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1,
					int position, long arg3) {
				String des = mDeses.get(position);
				if (position == 3
						&& mUser.getRole_type() == Constants.ROLE_DOCTOR
						&& des.length() > 10) {
					Intent intent = new Intent(UserInfoActivity.this,
							ShowUserDescriptionActivity.class);
					intent.putExtra(
							ShowUserDescriptionActivity.EXTRA_DES_CONTENT, des);
					startActivity(intent);
				}
			}
		});
	}

	private void initInfo(Person user) {
		mUserName.setText(user.getName());
		mUserGender.setText(user.getGenderStr());
		ApiSystem.getInstance().getHeadImage(new Photo(user.getImageId(), ""),
				new ICallback() {

					@Override
					public void doCallback(Object obj) {
						Bitmap bmp = UITools.getBitmapWithPath("" + obj);
						mImgHead.setImageBitmap(bmp);
					}
				}, false, 2);
		if ("".equals(user.getDPName())) {
			mTvDocNum.setVisibility(View.GONE);
		} else {
			mTvDocNum.setText("医加号：" + user.getDPName());
		}
	}

	private void initSetFollowUpBtn(boolean isFriend) {
		if (isFriend && (mUser.getRole_type() == 3)) {
			setFollowUpBtn.setText("设置随访");
			setFollowUpBtn.setVisibility(View.VISIBLE);
		}
	}

	private void initAddOrDelFriendBtn(boolean isFriend) {
		if (isFriend) {
			addOrDelFriendBtn.setText("删除");
		} else {
			addOrDelFriendBtn.setText("添加");
		}
		addOrDelFriendBtn.setVisibility(View.VISIBLE);
	}

	public void initHashMap() {
		mDeses.clear();
		if (mUser.getRole_type() == Constants.ROLE_DOCTOR) {
			String[] deses = { mUser.getHospital(), mUser.getDepartment(),
					mUser.getTitleStr(), mUser.getDescription() };
			mTitles = new String[] { "医院", "科室", "职务", "个人简介" };
			mIcons = new int[] { R.drawable.icon_doctor_detail_hospital,
					R.drawable.icon_address_department_unselected,
					R.drawable.icon_doctor_detail_zhiwu,
					R.drawable.icon_summary };
			mDeses = Arrays.asList(deses);
		} else if (mUser.getRole_type() == Constants.ROLE_PATIENT) {
			for (int i = 0; i < 3; i++) {
				mDeses.add("");
			}
			mIcons = new int[] { 0, 0, 0 };
			mTitles = new String[] { "生日", "居住地区", "居住地址" };
		}
		mAdapter.addDatas(mDeses);
	}

	@Override
	public void onError(int code, Throwable error) {

	}

	@Override
	public void feedUser(final Contacts user) {
		if (mUser == null) {
			initInfo(user);
			if (user.getUserId() != Constants.getUser().getUserId()) {
				mUser = user;
				mRelationId = user.getRelationId();
				initAddOrDelFriendBtn(user.isFriend());
				initSetFollowUpBtn(user.isFriend());
			}
		}
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (!user.isFriend()) {
					addOrDelFriendBtn.setVisibility(View.VISIBLE);
				}
				mUser = user;
				initHashMap();
				mAdapter.notifyDataSetChanged();
			}
		});
	}

	/**
	 * 添加或者删除的点击事件
	 * 
	 * @param v
	 */
	@SuppressLint("InflateParams")
	public void onDelClick(View v) {
		if (addOrDelFriendBtn.getText().equals("删除")) {

			final CustomDialog dialog = new CustomDialog(this);
			View delView = LayoutInflater.from(this).inflate(
					R.layout.view_delete_item, null);
			dialog.setOnlyContainer(delView);
			dialog.setCanceledOnTouchOutside(false);
			Button btnSure = (Button) delView
					.findViewById(R.id.btn_delete_item_sure);
			Button btnCancel = (Button) delView
					.findViewById(R.id.btn_delete_item_cancel);

			btnCancel.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					dialog.dismiss();
				}
			});

			btnSure.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					// 调用删除好友逻辑
					mUserinfomInfoManager.delFriendLogic(dialog, mUser,
							UserInfoActivity.this, depNameString,
							mDepartmentMap, mRelationId);
				}
			});

		} else if (addOrDelFriendBtn.getText().equals("添加")) {
			// 调用添加好友逻辑
			mUserinfomInfoManager.addFriendLogic(mFromZxing, mUser,
					UserInfoActivity.this);
		}
	}

	/**
	 * 设置随访按钮点击事件
	 * 
	 * @param v
	 */
	public void onSendClick(View v) {
		if (mUser instanceof Contacts && ((Contacts) mUser).isFriend()) {
			Contacts mPatient = (Contacts) mUser;
			Intent mIntent = new Intent();
			mIntent.putExtra("Patient", mPatient);
			mIntent.setClass(this, SelectFollowUpTemplate.class);
			startActivity(mIntent);
			finish();
		}
	}
}
