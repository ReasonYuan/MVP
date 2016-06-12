package com.hp.android.halcyon.lbs;

import java.util.ArrayList;
import java.util.HashMap;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Person;
import com.fq.halcyon.logic2.AddOrRefuseFriendLogic;
import com.fq.halcyon.logic2.AddOrRefuseFriendLogic.AddOrRefuseFriendLogicInterface;
import com.fq.halcyon.logic2.DoctorAddFriendLogic;
import com.fq.halcyon.logic2.DoctorAddFriendLogic.DoctorAddFriendLogicInterface;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.ContactDepartmentActivity;
import com.hp.android.halcyon.HalcyonApplication;
import com.hp.android.halcyon.NewFriendsActivity;
import com.hp.android.halcyon.util.MessageStruct;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

public class UserInfoManager {
	
	public static UserInfoManager instance() {
		if (mInstance == null) {
			mInstance = new UserInfoManager();
		}
		return mInstance;
	}
	/**
	 * 添加好友逻辑
	 * 
	 * @param mFromZxing
	 * @param mUser
	 * @param context
	 */
	private static UserInfoManager mInstance;
	public void addFriendLogic(boolean mFromZxing, final Person mUser,
			final Context context) {
		int type = mFromZxing ? DoctorAddFriendLogic.FRIEND_FROM_ZXING
				: DoctorAddFriendLogic.FRIEND_FROM_NORMAL;
		new DoctorAddFriendLogic(new DoctorAddFriendLogicInterface() {

			@Override
			public void onDataReturn() {
				HalcyonApplication.getInstance().sendMessage(
						MessageStruct.MESSAGE_TYPE_ADD_NEW_FRIEND, "++++",
						mUser.getUserId());
				Intent intent = new Intent();
				intent.setClass((Activity) context, NewFriendsActivity.class);
				context.startActivity(intent);
				((Activity) context).finish();
			}

			@Override
			public void onError(int code, Throwable e) {
				UITools.showToast("发送请求失败");
			}
		}, Constants.getUser().getUserId(), mUser.getUserId(), type);
	}

	/**
	 * 删除好友逻辑
	 * 
	 * @param dialog
	 * @param mUser
	 * @param context
	 * @param depNameString
	 * @param mDepartmentMap
	 * @param mRelationId
	 */
	public void delFriendLogic(final CustomDialog dialog, final Person mUser,
			final Context context, final String depNameString,
			final HashMap<String, ArrayList<Contacts>> mDepartmentMap,
			int mRelationId) {
		final CustomProgressDialog proDialog = new CustomProgressDialog(context);
		proDialog.setMessage("删除好友…");
		new AddOrRefuseFriendLogic(new AddOrRefuseFriendLogicInterface() {

			@Override
			public void onDataReturn() {
				if (Constants.contactsList != null && mUser != null) {
					for (int i = 0; i < Constants.contactsList.size(); i++) {
						if (mUser.getUserId() == Constants.contactsList.get(i)
								.getUserId()) {
							Constants.contactsList.remove(i);
							break;
						}
					}
				}
				if (Constants.contactsMap.get(Constants.ROLE_PATIENT) != null) {
					for (int i = 0; i < Constants.contactsMap.get(
							Constants.ROLE_PATIENT).size(); i++) {
						if (mUser.getUserId() == Constants.contactsMap
								.get(Constants.ROLE_PATIENT).get(i).getUserId()) {
							Constants.contactsMap.get(Constants.ROLE_PATIENT)
									.remove(i);
						}
					}
				}
				if (Constants.contactsMap.get(Constants.ROLE_DOCTOR) != null) {
					for (int i = 0; i < Constants.contactsMap.get(
							Constants.ROLE_DOCTOR).size(); i++) {
						if (mUser.getUserId() == Constants.contactsMap
								.get(Constants.ROLE_DOCTOR).get(i).getUserId()) {
							Constants.contactsMap.get(Constants.ROLE_DOCTOR)
									.remove(i);
						}
					}
				}
				dialog.dismiss();
				proDialog.dismiss();
				UITools.showToast("删除好友成功");
				if (depNameString != null) {
					for (int i = 0; i < mDepartmentMap.get(depNameString)
							.size(); i++) {
						if (mDepartmentMap.get(depNameString).get(i)
								.getUserId() == mUser.getUserId()) {
							mDepartmentMap.get(depNameString).remove(i);
							break;
						}
					}
					Intent mIntent = new Intent();
					mIntent.setClass(context, ContactDepartmentActivity.class);
					mIntent.putExtra("departmentMapBack", mDepartmentMap);
					((Activity) context).setResult(202, mIntent);
				}
				((Activity) context).finish();
			}

			@Override
			public void onError(int code, Throwable e) {
				dialog.dismiss();
				proDialog.dismiss();
				UITools.showToast("删除好友失败");
			}
		}, Constants.getUser().getUserId(), mUser.getUserId(), mUser
				.getRole_type(), mRelationId, false, true, true);
	}
}
