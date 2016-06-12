package com.hp.android.halcyon.view;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.android.visualization.VisualizeActivity;
import com.fq.halcyon.entity.CertificationStatus;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.ContactsActivity;
import com.hp.android.halcyon.FollowUpActivity;
import com.hp.android.halcyon.HomeActivity;
import com.hp.android.halcyon.PatientListActivity;
import com.hp.android.halcyon.SettingActivity;
import com.hp.android.halcyon.SettingPlusIdActivity;
import com.hp.android.halcyon.ShareActivity;
import com.hp.android.halcyon.UserProfileActivity;
import com.hp.android.halcyon.ZxingCreateBmpActivity;
import com.hp.android.halcyon.util.UITools;

public class HomeRightMenu {

	private View mView;
	private Context mContext;
	private ViewGroup mMenuParent;
	
	private View mMenuClinic; // 临床数据库
	private View mMenuManager; // 病历管理
	private View mMenuRemind; // 提醒
	private View mMenuSetting; // 设置
	private View mMenuContacts; // 联系人
	private View mMenuRec; // 推荐给朋友
	private View mMenuTwoCode;//查看二维码
	private View mMenuData;//数据可视化
	private ImageView mImgUserHead; // 用户头像
	private TextView mTextDocPlucNum; // 医家号
	private TextView mTextUserName; // 姓名
	
	public View getView() {
		return mView;
	}

	public HomeRightMenu(Context mContext,ViewGroup parent) {
		this.mContext = mContext;
		mMenuParent = parent;
		mView = LayoutInflater.from(mContext).inflate(R.layout.fragment_home_menu, null);
		initWidgets();
		initListener();
	}

	public void onResume(){
		User user = Constants.getUser();
		mImgUserHead.setImageBitmap(UITools.getBitmapWithPath(FileSystem.getInstance().getUserHeadPath()));
		if(user.getDPName().equals("")){
			mTextDocPlucNum.setText("未设置");
			mTextDocPlucNum.setTextColor(mContext.getResources().getColorStateList(R.drawable.selector_btn_dpnum_not_setting_text));
			mTextDocPlucNum.setClickable(true);
			mTextDocPlucNum.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					mContext.startActivity(new Intent(mContext,SettingPlusIdActivity.class));
				}
			});
		}else {
			mTextDocPlucNum.setClickable(false);
			mTextDocPlucNum.setText(user.getDPName());
			mTextDocPlucNum.setTextColor(0xFF5BC3B6);
		}
		mTextUserName.setText(user.getName());
		
		if(CertificationStatus.getInstance().getState() == CertificationStatus.CERTIFICATION_PASS){
			mView.findViewById(R.id.iv_rectangle_state).setVisibility(View.VISIBLE);
		}
	}
	
	private void initWidgets() {
		mMenuClinic = mView.findViewById(R.id.menu_clinic_db);
		mMenuManager = mView.findViewById(R.id.menu_patient_manager);
		mMenuRemind = mView.findViewById(R.id.menu_remind);
		mMenuSetting = mView.findViewById(R.id.menu_setting);
		mMenuContacts = mView.findViewById(R.id.menu_contacts_list);
		mMenuRec = mView.findViewById(R.id.menu_recommend);
		mMenuTwoCode = mView.findViewById(R.id.ll_home_menu_my_twocode);
		mMenuData = mView.findViewById(R.id.menu_data);
		mImgUserHead = (ImageView) mView.findViewById(R.id.iv_home_menu_head);
		mTextDocPlucNum = (TextView) mView.findViewById(R.id.tv_home_menu_plus_num);
		mTextUserName = (TextView) mView.findViewById(R.id.tv_home_menu_score);
	}

	private void initListener() {
		mMenuClinic.setOnClickListener(menuClickListener);
		mMenuManager.setOnClickListener(menuClickListener);
		mMenuRemind.setOnClickListener(menuClickListener);
		mMenuSetting.setOnClickListener(menuClickListener);
		mMenuContacts.setOnClickListener(menuClickListener);
		mMenuRec.setOnClickListener(menuClickListener);
		mMenuTwoCode.setOnClickListener(menuClickListener);
		mMenuData.setOnClickListener(menuClickListener);
		mView.findViewById(R.id.v_menu_head_btn).setOnClickListener(menuClickListener);
		
		mView.findViewById(R.id.menu_close_menu_view).setOnClickListener(menuClickListener);
		mView.findViewById(R.id.img_menu_arrows).setOnClickListener(menuClickListener);
	}

	public void showChange(){
		if(mView.isShown()){
			dismiss();
		}else{
			show();
		}
	}
	
	boolean mIsSHow = false;
	
	public void show(){
		if(mIsSHow)return;
		mIsSHow = true;
		mImgUserHead.setImageBitmap(UITools.getBitmapWithPath(FileSystem.getInstance().getUserHeadPath()));
		((HomeActivity)mContext).blur();
		
		mView.setAnimation(AnimationUtils.loadAnimation(mContext, R.anim.push_left_in));
		mMenuParent.addView(mView);
	}
	
	public void dismiss(){
		mIsSHow = false;
		((HomeActivity)mContext).unblur();
		
		mView.setAnimation(AnimationUtils.loadAnimation(mContext, R.anim.push_right_out));
		mMenuParent.removeView(mView);
	}
	
	public boolean isShow(){
		return mView.isShown();
	}
	
	private OnClickListener menuClickListener = new OnClickListener() {
		@Override
		public void onClick(View v) {
			Intent intent;
			switch (v.getId()) {
			case R.id.v_menu_head_btn:
				//头像
				intent = new Intent(mContext, UserProfileActivity.class);
				intent.putExtra("user_profile", true);
				mContext.startActivity(intent);
				break;
			case R.id.ll_home_menu_my_twocode:
				//我的二维码
				mContext.startActivity(new Intent(mContext,ZxingCreateBmpActivity.class));
				break;
			case R.id.menu_clinic_db:
				// 临床数据库
//				mContext.startActivity(new Intent(mContext, MyPatientActivity.class));
				break;
			case R.id.menu_patient_manager:
				// 病历管理
				//mContext.startActivity(new Intent(mContext, UploadStateActivity.class));
				// 云病历库
				mContext.startActivity(new Intent(mContext, PatientListActivity.class));
				break;
			case R.id.menu_remind:
				// 提醒
//				mContext.startActivity(new Intent(mContext, SetRemindActivity.class));
				mContext.startActivity(new Intent(mContext, FollowUpActivity.class));
				break;
			case R.id.menu_setting:
				// 设置
				intent = new Intent();
				intent.setClass(mContext, SettingActivity.class);
				mContext.startActivity(intent);
				break;
			case R.id.menu_contacts_list:
				// 通讯录
				intent = new Intent();
				intent.setClass(mContext, ContactsActivity.class);
				mContext.startActivity(intent);
				break;
			case R.id.menu_recommend:
				// 推荐给朋友
				intent = new Intent();
				intent.setClass(mContext, ShareActivity.class);
				mContext.startActivity(intent);
				break;
			case R.id.img_menu_arrows:
			case R.id.menu_close_menu_view:
				showChange();
				break;
			case R.id.menu_data:
				//数据可视化Demo
				mContext.startActivity(new Intent(mContext, VisualizeActivity.class));
				break;
			default:
				break;
			}
		}
	};
}
