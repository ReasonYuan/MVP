package com.hp.android.halcyon;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.MediaStore.Images.ImageColumns;
import android.provider.MediaStore.MediaColumns;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.animation.AlphaAnimation;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.CertificationStatus;
import com.fq.halcyon.entity.Department;
import com.fq.halcyon.entity.Hospital;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.uilogic.SaveInfoUILogic;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.Tool;
import com.fq.lib.tools.UserProfileManager;
import com.fq.lib.tools.UserProfileManager.OnResultCallBack;
import com.fq.lib.tools.UserProfileManager.OnUploadCallBack;
import com.hp.android.halcyon.camerahelp.ClipPictureActivity;
import com.hp.android.halcyon.util.BaiDuTJSDk;
import com.hp.android.halcyon.util.TextFontUtils;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.view.EducationTitleSelectView;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.MyPopupWindow;

public class UserProfileActivity extends Activity {

	private String TAG = "UserProfileActivity";

	private static final int FLAG_CHOOSE_IMG = 5;
	private static final int FLAG_CHOOSE_PHONE = 6;
	private static final int FLAG_MODIFY_FINISH = 7;

	public static final int CHANGE_NAME_RESULT = 10;
	public static final int CHANGE_HOSPITAL_RESULT = 20;
	public static final int CHANGE_DEPARTMENT_RESULT = 30;
	public static final int CHANGE_GENDER_RESULT = 40;
	public static final int CHANGE_DESCRIPTION_RESULT = 50;
	public static final int CHANGE_FACE_RESULT = 60;
	public static final int CHANGE_CREATE_HOSPITAL_RESULT = 70;
	public static final int CHANGE_DOCTOR_TITLE = 80;
	public static final int CHANGE_DOCSTD_EDCATION = 90;
	public static final int CHANGE_DOCSTD_ENTRANCETIME = 100;
	public static final int CHANGE_DOCSTD_HOS_SCHOOL = 110;
	public static final int CHANGE_DOCSTD_MAJOR = 120;

	public static final int CHANGE_CREATE_DEPARTMENT_RESULT = 130;

	private User mUser;
	public boolean mIsHeadUploading;
	public static boolean mIsHeadChanged;

	private EducationTitleSelectView mTitleView;
	private MyPopupWindow mHeadWindow;


	private boolean mIsToBeDoctor;
	private boolean mIsDoctor;

	private UserProfileManager userProfileManager;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_user_profile);
		userProfileManager = UserProfileManager.instance();
		mUser = userProfileManager.getUser();

		mIsToBeDoctor = false;
		mIsDoctor = true;

		initProfileTitle();

		((ImageView) findViewById(R.id.riv_user_profile_head))
				.setImageBitmap(UITools.getBitmapWithPath(FileSystem
						.getInstance().getUserHeadPath()));
		((TextView) findViewById(R.id.tv_user_profile_content_name))
				.setText(mUser.getName());
		if (mUser.getGender() != 0) {
			((TextView) findViewById(R.id.tv_user_profile_content_gender))
					.setText(mUser.getGenderStr());
		}

		if (mIsDoctor) {
			((TextView) findViewById(R.id.tv_user_profile_content_hosptial))
					.setText(mUser.getHospital());
			((TextView) findViewById(R.id.tv_user_profile_content_department))
					.setText(mUser.getDepartment());
			((TextView) findViewById(R.id.tv_user_profile_content_zhicheng))
					.setText(mUser.getTitleStr());
			// ((TextView)findViewById(R.id.tv_user_profile_content_auth)).setText(CertificationStatus.getInstance().getStateStr(false));
			// ((TextView)findViewById(R.id.tv_user_profile_content_desp)).setText(mUser.getDescription());
		} else {
			((TextView) findViewById(R.id.tv_user_profile_content_hosptial))
					.setText(mUser.getUniversity());
			((TextView) findViewById(R.id.tv_user_profile_content_department))
					.setText(mUser.getMajor());
			((TextView) findViewById(R.id.tv_user_profile_content_zhicheng))
					.setText(mUser.getEducationStr());
			((TextView) findViewById(R.id.tv_user_profile_content_auth))
					.setText(mUser.getEntranceTime());
		}

		Button btn = (Button) findViewById(R.id.btn_tobe_doc);
		if (mIsToBeDoctor) {
			btn.setVisibility(View.VISIBLE);
			btn.setText("提交审核");
		} else if (!mIsDoctor
				&& !getIntent().getBooleanExtra("user_regist", false)
				&& CertificationStatus.getInstance().getState() == CertificationStatus.CERTIFICATION_PASS) {
			btn.setVisibility(View.VISIBLE);
			btn.setText("成为医生");
		}

		final TextView tv = (TextView) findViewById(R.id.tv_user_profile_invient);
		tv.setTypeface(TextFontUtils.getTypeface(TextFontUtils.FONT_HIRAGINO_SANS_GB_W3));
		
		LinearLayout llMyInvitationCode = (LinearLayout) findViewById(R.id.my_invitation_code);
		LinearLayout llMyScan = (LinearLayout) findViewById(R.id.my_scan);
		LinearLayout llMyTwodimentionCode = (LinearLayout) findViewById(R.id.my_twodimention_code);
		View vMyInvitationCodeLine = findViewById(R.id.my_invitation_code_line);
		View vMyScanLine = findViewById(R.id.my_scan_line);
		View vMyTwodimentionCodeLine = findViewById(R.id.my_twodimention_code_line);
		if (userProfileManager.isFirstLogin()) {
			tv.setVisibility(View.GONE);
			llMyInvitationCode.setVisibility(View.GONE);
			llMyScan.setVisibility(View.GONE);
			llMyTwodimentionCode.setVisibility(View.GONE);
			vMyInvitationCodeLine.setVisibility(View.GONE);
			vMyScanLine.setVisibility(View.GONE);
			vMyTwodimentionCodeLine.setVisibility(View.GONE);
		} else {
			tv.setVisibility(View.VISIBLE);
			llMyInvitationCode.setVisibility(View.VISIBLE);
			llMyScan.setVisibility(View.VISIBLE);
			llMyTwodimentionCode.setVisibility(View.VISIBLE);
			vMyInvitationCodeLine.setVisibility(View.VISIBLE);
			vMyScanLine.setVisibility(View.VISIBLE);
			vMyTwodimentionCodeLine.setVisibility(View.VISIBLE);
		}
		// 获取邀请码并显示
		userProfileManager.getInvient(mUser, new OnResultCallBack() {
			@Override
			public void onResult(String msg) {
				tv.setText(msg);
			}
		});
	}

	private OnClickListener mHeadItemOnClick = new OnClickListener() {
		@Override
		public void onClick(View view) {
			mHeadWindow.dismiss();
			switch (view.getId()) {
			case R.id.btn_me_carmera:
				// 选择相机
				String status = Environment.getExternalStorageState();
				if (status.equals(Environment.MEDIA_MOUNTED)) {
					try {
						Intent intent = new Intent(
								android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
						// localTempImgDir和localTempImageFileName是自己定义的名字
						Uri u = Uri.fromFile(userProfileManager.getLocalTempFileUri());
						intent.putExtra(ImageColumns.ORIENTATION, 0);
						intent.putExtra(MediaStore.EXTRA_OUTPUT, u);
						startActivityForResult(intent, FLAG_CHOOSE_PHONE);
					} catch (ActivityNotFoundException e) {
					}
				}
				break;
			case R.id.btn_me_album:
				// 选择本地相册
				Intent intent = new Intent();
				// intent.setAction(Intent.ACTION_PICK);
				// intent.setType("image/*");
				intent.putExtra("is_single_slection", true);
				intent.setClass(UserProfileActivity.this,
						SelectPhotoBucketListActivity.class);
				startActivityForResult(intent, FLAG_CHOOSE_IMG);
				break;
			case R.id.btn_me_cancel:
				mHeadWindow.dismiss();
				break;
			default:
				break;
			}
		}
	};

	@Override
	public void onBackPressed() {
		if (mTitleView != null) {
			mTitleView.remove4Parent();
			mTitleView = null;
			return;
		}
		
		if(!Tool.isUserInfoFull(mUser) && getIntent().getBooleanExtra("user_regist", false)){
			if(!mIsUserInfoDialogShow){
				showUnFullDialog();
			}else{
				long time = System.currentTimeMillis() - mLastBackTime;
				if (time < 2000) {
					finish();
				} else {
					mLastBackTime = System.currentTimeMillis();
					UITools.showToast("再按一次退出");
				}
			}
		}else{
			backToHome();	
		}
	}

	public void onToHomeClick(View v) {
		backToHome();
	}

	public void initProfileTitle() {
		if (mIsDoctor)
			return;

		((TextView) findViewById(R.id.tv_user_profile_type)).setText("医学生");
		((TextView) findViewById(R.id.tv_user_profile_title_hosptial))
				.setText("医学院");
		((TextView) findViewById(R.id.tv_user_profile_title_department))
				.setText("专业");
		((TextView) findViewById(R.id.tv_user_profile_title_zhicheng))
				.setText("目前在读");
		((TextView) findViewById(R.id.tv_user_profile_title_auth))
				.setText("入学时间");
		((TextView) findViewById(R.id.tv_user_profile_title_desp))
				.setText("学生证上传");
	}

	public void onHeadClick(View v) {
		if (mHeadWindow == null) {
			mHeadWindow = new MyPopupWindow(this,
					R.layout.dialog_me_popupwindow);
			mHeadWindow.setWindow(LayoutParams.MATCH_PARENT,
					LayoutParams.MATCH_PARENT, R.style.popupAnimation);
			View view = mHeadWindow.getView();
			view.findViewById(R.id.btn_me_carmera).setOnClickListener(
					mHeadItemOnClick);
			view.findViewById(R.id.btn_me_album).setOnClickListener(
					mHeadItemOnClick);
			view.findViewById(R.id.btn_me_cancel).setOnClickListener(
					mHeadItemOnClick);
			view.findViewById(R.id.tv_photo_des).setVisibility(View.GONE);
		}
		mHeadWindow.showAtLocation(findViewById(R.id.sll_user_profile),
				Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL, 0, 0);
	}

	public void onNameClick(View v) {
		startActivityForResult(new Intent(this, ChangeNameActivity.class), 100);
	}

	/**
	 * 性别
	 * 
	 * @param v
	 */
	public void onGenderClick(View v) {
		startActivityForResult(new Intent(this, GenderActivity.class), 100);
	}

	/**
	 * 医院
	 * 
	 * @param v
	 */
	public void onHospitalClick(View v) {
		Intent intent = new Intent();
		intent.setClass(this, HospitalActivity.class);
		if (!mIsDoctor) {
			intent.putExtra("is_hospital_school", true);
		}
		startActivityForResult(intent, 100);
	}

	/**
	 * 科室
	 * 
	 * @param v
	 */
	public void onDepartClick(View v) {
		Intent intent = new Intent();
		if (mIsDoctor) {
			intent.setClass(this, DepartmentActivity.class);
		} else {
			// intent.setClass(this,MajorAcitivity.class);
		}
		startActivityForResult(intent, 100);
	}

	/**
	 * 职称
	 * 
	 * @param v
	 */
	public void onZhiChengClick(View v) {
		FrameLayout frame = (FrameLayout) findViewById(R.id.fl_user_profile_container);
		mTitleView = new EducationTitleSelectView(this, mIsDoctor,
				new ICallback() {
					@Override
					public void doCallback(Object obj) {
						((TextView) findViewById(R.id.tv_user_profile_content_zhicheng))
								.setText(userProfileManager.getSelectZhiCheng(obj, mIsDoctor));
						mTitleView = null;
					}
				});

		frame.addView(mTitleView.getView());
		AlphaAnimation alphaAnimation = new AlphaAnimation(0, 1);
		alphaAnimation.setDuration(500);
		mTitleView.getView().startAnimation(alphaAnimation);
	}

	/**
	 * 认证
	 * 
	 * @param v
	 */
	public void onAuthClick(View v) {
		if (mIsDoctor) {
			startActivityForResult(
					new Intent(this, CertificationActivity.class), 100);
		} else {
			startActivityForResult(new Intent(this, TimeActivity.class), 100);
		}
	}

	/**
	 * 扫一扫
	 * 
	 * @param v
	 */
	public void onScanClick(View v) {

		startActivity(new Intent(this, ZxingScanActivity.class));
	}

	/**
	 * 个人简介
	 * 
	 * @param v
	 */
	public void onDespClick(View v) {
		if (mIsDoctor) {
			startActivityForResult(new Intent(this,
					PersonalDescriptionActivity.class), 100);
		} else {
			startActivityForResult(
					new Intent(this, CertificationActivity.class), 100);
		}
	}

	/**
	 * 我的邀请码
	 * 
	 * @param v
	 */
	public void onInviteCodeClick(View v) {
		Intent mIntent = new Intent(this, InvitationCodeDetailActivity.class);
		startActivity(mIntent);
	}

	/**
	 * 我的二维码
	 * 
	 * @param v
	 */
	public void onQuickCodeClick(View v) {
		startActivity(new Intent(this, ZxingCreateBmpActivity.class));
	}

	@Override
	protected void onResume() {
		super.onResume();
		BaiDuTJSDk.onResume(this);

		// 如果认证成功，则显示认证图标
		if (CertificationStatus.getInstance().getState() == CertificationStatus.CERTIFICATION_PASS) {
			findViewById(R.id.iv_user_profile_rectangle_state).setVisibility(
					View.VISIBLE);
		}
		// ((RoundImageView)findViewById(R.id.riv_user_profile_head)).setImageBitmap(UITools.getUserHeadBmp());
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		BaiDuTJSDk.onPause(this);
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		if(userProfileManager != null){
			userProfileManager.clear();
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (resultCode) {
		case CHANGE_NAME_RESULT:
			((TextView) findViewById(R.id.tv_user_profile_content_name))
					.setText(mUser.getName());
			userProfileManager.reqModyName();
			break;
		case CHANGE_CREATE_HOSPITAL_RESULT:
			// 改变的医院是用户新建的
			Hospital hospital = (Hospital) data
					.getSerializableExtra("hosptial");
			// String hospital = Constants.getUser().getHospital();
			userProfileManager.reqModyHosp(0, hospital.getName());
			((TextView) findViewById(R.id.tv_user_profile_content_hosptial))
					.setText(mUser.getHospital());
			break;
		case CHANGE_HOSPITAL_RESULT:
			// 改变的医院是系统已经存在的
			if (data == null)
				return;
			Hospital mHospital = (Hospital) data
					.getSerializableExtra("hosptial");
			userProfileManager.reqModyHosp(mHospital.getHospitalId(),
					mHospital.getName());
			((TextView) findViewById(R.id.tv_user_profile_content_hosptial))
					.setText(mUser.getHospital());
			break;
		case CHANGE_DEPARTMENT_RESULT:
			Department dep1 = (Department) data
					.getSerializableExtra("depart_1");
			Department depart = (Department) data
					.getSerializableExtra("department");
			userProfileManager.reqModyDept(dep1.getDepartmentId(),
					depart.getDepartmentId(), depart.getName());
			((TextView) findViewById(R.id.tv_user_profile_content_department))
					.setText(mUser.getDepartment());
			break;
		case CHANGE_CREATE_DEPARTMENT_RESULT:
			Department departs = (Department) data
					.getSerializableExtra("department");
			userProfileManager.reqModyDept(0, 0, departs.getName());
			((TextView) findViewById(R.id.tv_user_profile_content_department))
					.setText(mUser.getDepartment());
			break;
		case CHANGE_GENDER_RESULT:
			userProfileManager.reqModyGender();
			((TextView) findViewById(R.id.tv_user_profile_content_gender))
					.setText(mUser.getGender() == Constants.MALE ? R.string.man
							: R.string.woman);
			break;
		case CHANGE_DESCRIPTION_RESULT:
			userProfileManager.reqModyDes();
			// ((TextView)findViewById(R.id.tv_user_profile_content_desp)).setText(mUser.getDescription());
			break;
		case CHANGE_DOCSTD_HOS_SCHOOL:
			Hospital hosSchool = (Hospital) data
					.getSerializableExtra("hosptial");
			mUser.setUniversity(hosSchool.getName());
			userProfileManager.reqModyUniversity();
			((TextView) findViewById(R.id.tv_user_profile_content_hosptial))
					.setText(mUser.getUniversity());
			break;
		case CHANGE_DOCSTD_MAJOR:
			// Major major = (Major)data.getSerializableExtra("major");
			// mUser.setMajor(major.getName());
			// resetDoctorInfoLogic.reqModyMajor(mUser.getMajor());
			// ((TextView)findViewById(R.id.tv_user_profile_content_department)).setText(mUser.getMajor());
			break;
		case TimeActivity.TIME_RESULT_CODE:
			String time = data.getStringExtra(TimeActivity.EXRT_SELECT_TIME);
			Constants.getUser().setEntranceTime(time);
			userProfileManager.reqModyEntranceTime(time);
			((TextView) findViewById(R.id.tv_user_profile_content_auth))
					.setText(mUser.getEntranceTime());
			break;
		}

		if (requestCode == CHANGE_FACE_RESULT && mIsHeadChanged
				&& !mIsHeadUploading) {
			mIsHeadUploading = true;
			userProfileManager.upLoadHead(new OnUploadCallBack() {
				
				@Override
				public void onsuccess() {
					mIsHeadChanged = false;
					mIsHeadUploading = false;
				}
				
				@Override
				public void onError() {
					mIsHeadUploading = false;
				}
			});
		}

		if (requestCode == FLAG_CHOOSE_IMG
				&& resultCode == SelectPhotoActivity.TO_ALBUM_RESULT) {
			if (data != null) {
				// Uri uri = data.getData();
				Uri uri = Uri.parse(data
						.getStringExtra(SelectPhotoActivity.EXTRA_PHOTO_NAMES));
				if (uri != null && !TextUtils.isEmpty(uri.getAuthority())) {
					Cursor cursor = getContentResolver().query(uri,
							new String[] { MediaColumns.DATA }, null, null,
							null);
					if (null == cursor) {
						Toast.makeText(this, "图片没找到", Toast.LENGTH_LONG).show();
						return;
					}
					cursor.moveToFirst();
					String path = cursor.getString(cursor
							.getColumnIndex(MediaColumns.DATA));
					cursor.close();
					if (Constants.DEBUG) {
						Log.i(TAG, "path=" + path);
					}
					Intent intent = new Intent(this, ClipPictureActivity.class);
					intent.putExtra("path", path);
					startActivityForResult(intent, FLAG_MODIFY_FINISH);
				} else {
					if (uri == null)
						return;
					if (Constants.DEBUG) {
						Log.i(TAG, "path=" + uri.getPath());
					}
					Intent intent = new Intent(this, ClipPictureActivity.class);
					intent.putExtra("path", uri.getPath());
					startActivityForResult(intent, FLAG_MODIFY_FINISH);// FLAG_MODIFY_FINISH
				}
			}
		} else if (requestCode == FLAG_CHOOSE_PHONE && resultCode == RESULT_OK) {
			Intent intent = new Intent(this, ClipPictureActivity.class);
			intent.putExtra("path", userProfileManager.getlocaltempimageFilegetAbsolutePath());
			startActivityForResult(intent, FLAG_MODIFY_FINISH);
		} else if (requestCode == FLAG_MODIFY_FINISH && resultCode == RESULT_OK) {
			if (data != null) {
				final String path = data.getStringExtra("path");
				if (Constants.DEBUG) {
					Log.i(TAG, "截取到的图片路径是 = " + path);
				}
				((ImageView) findViewById(R.id.riv_user_profile_head))
						.setImageBitmap(UITools.getBitmapWithPath(path));
				userProfileManager.upLoadHead(new OnUploadCallBack() {
					
					@Override
					public void onsuccess() {
						mIsHeadChanged = false;
						mIsHeadUploading = false;
					}
					
					@Override
					public void onError() {
						mIsHeadUploading = false;
					}
				});
			}
		}
	}

	public void onToBeDoctorClick(View v) {
		if (mIsToBeDoctor) {

		} else {
			Intent intent = new Intent(this, UserProfileActivity.class);
			intent.putExtra("is_to_be_doctor", true);
			startActivity(intent);
		}
	}

	/**
	 * 返回首页的监听事件
	 */
	private void backToHome() {
		//如果是新注册用户
		if (getIntent().getBooleanExtra("user_regist", false)) {
			if (!Tool.isUserInfoFull(mUser)) {// 如果用户信息不全
				showUnFullDialog();
				return;
			}
			SaveInfoUILogic.saveUserLogicInfo();
			startActivity(new Intent(this, HomeActivity.class));
			finish();
			return;
		}
		finish();
	}
	
	private void showUnFullDialog(){
		mIsUserInfoDialogShow = true;
		final CustomDialog dialog = new CustomDialog(
				UserProfileActivity.this);
		View notifyView = LayoutInflater.from(UserProfileActivity.this)
				.inflate(R.layout.view_userprofile_notice, null);
		dialog.setOnlyContainer(notifyView);
		dialog.setCanceledOnTouchOutside(false);
		TextView mTittle = (TextView) notifyView
				.findViewById(R.id.view_userprofile_notice_title);
		mTittle.setText("请完善必填信息");
		Button btnSure = (Button) notifyView
				.findViewById(R.id.btn_userprofile_notice_sure);
		btnSure.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				dialog.dismiss();
			}
		});
	}
	

	/** 记录上传点击返回键时间，第二次退出应用 */
	private long mLastBackTime;
	/** 标记用户信息不全dialog是否出现过 */
	private boolean mIsUserInfoDialogShow;
}
