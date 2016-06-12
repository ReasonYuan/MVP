package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic2.AddOrRefuseFriendLogic;
import com.fq.halcyon.logic2.AddOrRefuseFriendLogic.AddOrRefuseFriendLogicInterface;
import com.fq.halcyon.logic2.GetAddingFriendsListLogic;
import com.fq.halcyon.logic2.GetAddingFriendsListLogic.GetAddingFriendsListLogicInterface;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CircleImageView;

public class NewFriendsActivity extends BaseActivity implements OnClickListener {
	private ListView mNewFriendListView;
	private NewFriendsAdapter mAdapter;
	private ArrayList<Contacts> mFriendsListReq = new ArrayList<Contacts>();
	private ArrayList<Contacts> mFriendsListRsp = new ArrayList<Contacts>();
	private ArrayList<Contacts> mFriendsListAll = new ArrayList<Contacts>();
	private View mAgreeLayout;
	private FrameLayout mBigLayout;
	private Button mMoneyAcceptBtn;
	private Button mFreeAcceptBtn;
	private Contacts mAccpetUser;

	@Override
	public int getContentId() {
		return R.layout.activity_new_friends;
	}

	@Override
	public void init() {
		setTopLeftImgSrc(R.drawable.btn_back);
		setTopRightImgSrc(R.drawable.btn_new_friend_right);
		setTitle("新的朋友");
		mBigLayout = (FrameLayout) findViewById(R.id.linearlayout_all);
		mAgreeLayout = (View) LayoutInflater.from(this).inflate(
				R.layout.contact_add_patient, null);
		mMoneyAcceptBtn = (Button) mAgreeLayout.findViewById(R.id.money_accept);
		mFreeAcceptBtn = (Button) mAgreeLayout.findViewById(R.id.free_accept);
		mMoneyAcceptBtn.setOnClickListener(this);
		mFreeAcceptBtn.setOnClickListener(this);
		mNewFriendListView = (ListView) findViewById(R.id.new_friends_list);
		getDataFromServer();

	}

	public void getDataFromServer() {
		new GetAddingFriendsListLogic(new GetAddingFriendsListLogicInterface() {

			@Override
			public void onError(int code, Throwable e) {
				UITools.showToast("获取数据失败");
			}

			@Override
			public void onDataReturn(ArrayList<Contacts> friendsListReq,
					ArrayList<Contacts> friendsListRsp) {
				mFriendsListReq = friendsListReq;
				mFriendsListRsp = friendsListRsp;
				mFriendsListAll.clear();
				parseStatusFor4();
				mFriendsListAll.addAll(mFriendsListReq);
				mFriendsListAll.addAll(mFriendsListRsp);
				mAdapter = new NewFriendsAdapter();
				mNewFriendListView.setAdapter(mAdapter);
			}
		}, Constants.getUser().getUserId());

	}

	private void parseStatusFor4() {
		for (int i = 0; i < mFriendsListRsp.size(); i++) {
			Contacts mUser = mFriendsListRsp.get(i);
			if (mUser.getStatus() == 4) {
				mFriendsListRsp.remove(i);
			}
		}
	}

	@Override
	public void onTopRightBtnClick(View view) {
		super.onTopRightBtnClick(view);
		Intent mIntent = new Intent();
		mIntent.setClass(NewFriendsActivity.this, ContactSearchActivity.class);
		startActivity(mIntent);
	}

	private class NewFriendsAdapter extends BaseAdapter implements
			OnClickListener {

		@Override
		public int getCount() {
			return mFriendsListAll.size();
		}

		@Override
		public Object getItem(int position) {
			return mFriendsListAll.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(NewFriendsActivity.this)
						.inflate(R.layout.item_new_friends, null);
			}
			final CircleImageView mHeadImage = (CircleImageView) convertView
					.findViewById(R.id.new_head_image);
			TextView mName = (TextView) convertView.findViewById(R.id.name);
			TextView mWhichPeople = (TextView) convertView
					.findViewById(R.id.which_people);
			TextView mState = (TextView) convertView.findViewById(R.id.state);
			TextView mFrom = (TextView) convertView
					.findViewById(R.id.patient_from);

			LinearLayout mPatientLinear = (LinearLayout) convertView
					.findViewById(R.id.add_linear_patient);
			LinearLayout mOtherLinear = (LinearLayout) convertView
					.findViewById(R.id.add_linear_other);
			Button mMoneyAccept = (Button) convertView
					.findViewById(R.id.patient_accept);
			Button mRefuse = (Button) convertView
					.findViewById(R.id.patient_refuse);

			Button mAddOther = (Button) convertView
					.findViewById(R.id.add_other);
			Button mRefuseOther = (Button) convertView
					.findViewById(R.id.other_refuse);
//			ImageManager.from(NewFriendsActivity.this).displayImage(mHeadImage,
//					mFriendsListAll.get(position).getHeadPicPath(),
//					R.color.app_head_pink);
			final Photo photo = new Photo();
			photo.setImageId(mFriendsListAll.get(position).getImageId());
			
			//==YY==imageId(只要imageId)
//			photo.setImagePath(mFriendsListAll.get(position).getHeadPicPath());
			
			ApiSystem.getInstance().getHeadImage(photo, new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					System.out.println(""+obj);
					mHeadImage.setImageBitmap(UITools.getBitmapWithPath(""+obj));
				}
					
			}, false,2);

			mName.setText(mFriendsListAll.get(position).getUsername());

			mMoneyAccept.setOnClickListener(this);
			mRefuse.setOnClickListener(this);
			mAddOther.setOnClickListener(this);
			mRefuseOther.setOnClickListener(this);

			Contacts mUser = mFriendsListAll.get(position);
			int mReqSize = mFriendsListReq.size();
			int roletype = mUser.getRole_type();
			int status = mUser.getStatus();
			mMoneyAccept.setTag(mUser);
			mRefuse.setTag(mUser);
			mAddOther.setTag(mUser);
			mRefuseOther.setTag(mUser);
			switch (roletype) {
			case 1:// 医生、医学生
			case 2:
				if (mReqSize >= (position + 1)) {// 请求好友列表
					if (status == 0 || status == 4) {
						mPatientLinear.setVisibility(View.GONE);
						mOtherLinear.setVisibility(View.GONE);
						mState.setText("等待...");
					} else {
						mPatientLinear.setVisibility(View.GONE);
						mOtherLinear.setVisibility(View.GONE);
						mState.setText("已添加");
					}
				} else {// 接受好友列表
					if (status == 0) {
						mPatientLinear.setVisibility(View.GONE);
						mOtherLinear.setVisibility(View.VISIBLE);
						mState.setVisibility(View.GONE);
					} else if (status == 4) {
						mPatientLinear.setVisibility(View.GONE);
						mOtherLinear.setVisibility(View.GONE);
						mState.setText("等待...");
					} else {
						mPatientLinear.setVisibility(View.GONE);
						mOtherLinear.setVisibility(View.GONE);
						mState.setText("已添加");
					}
				}
				mFrom.setVisibility(View.GONE);
				mWhichPeople.setVisibility(View.GONE);
				break;
			case 3:// 病人
				if (mReqSize >= (position + 1)) {// 请求好友列表
					if (status == 0 || status == 4) {
						mPatientLinear.setVisibility(View.GONE);
						mOtherLinear.setVisibility(View.GONE);
						mState.setText("等待...");

					} else {
						mPatientLinear.setVisibility(View.GONE);
						mOtherLinear.setVisibility(View.GONE);
						mState.setText("已添加");
					}
				} else {// 接受好友列表
					if (status == 0) {
						mPatientLinear.setVisibility(View.VISIBLE);
						mOtherLinear.setVisibility(View.GONE);
						mState.setVisibility(View.GONE);
					} else if (status == 4) {
						mPatientLinear.setVisibility(View.GONE);
						mOtherLinear.setVisibility(View.GONE);
						mState.setText("等待...");
					} else {
						mPatientLinear.setVisibility(View.GONE);
						mOtherLinear.setVisibility(View.GONE);
						mState.setText("已添加");
					}
				}
				mFrom.setVisibility(View.VISIBLE);
				mWhichPeople.setVisibility(View.VISIBLE);
				mWhichPeople.setText(mUser.getSource());// 目前没有数据

				break;
			default:
				break;
			}

			return convertView;
		}

		@Override
		public void onClick(View v) {
			mAccpetUser = (Contacts) v.getTag();
			switch (v.getId()) {
			case R.id.patient_accept:// 接受病人添加
				if (mAgreeLayout.getParent() != null) {
					mBigLayout.removeView(mAgreeLayout);
				}
				mBigLayout.addView(mAgreeLayout);
				AlphaAnimation alphaAnimation = new AlphaAnimation(0, 1);
				alphaAnimation.setDuration(500);
				mAgreeLayout.startAnimation(alphaAnimation);
				break;
			case R.id.patient_refuse:// 拒绝病人添加
				new AddOrRefuseFriendLogic(
						new AddOrRefuseFriendLogicInterface() {

							@Override
							public void onError(int code, Throwable e) {
								UITools.showToast("操作失败");
							}

							@Override
							public void onDataReturn() {
								mBigLayout.removeView(mAgreeLayout);
								getDataFromServer();
							}
						}, Constants.getUser().getUserId(),
						mAccpetUser.getUserId(), mAccpetUser.getRole_type(),
						mAccpetUser.getRelationId(), false, true,false);
				break;
			case R.id.add_other:// 添加医生或者医学生
				new AddOrRefuseFriendLogic(
						new AddOrRefuseFriendLogicInterface() {

							@Override
							public void onError(int code, Throwable e) {
								UITools.showToast("操作失败");
							}

							@Override
							public void onDataReturn() {
								mBigLayout.removeView(mAgreeLayout);
								getDataFromServer();
							}
						}, Constants.getUser().getUserId(),
						mAccpetUser.getUserId(), mAccpetUser.getRole_type(),
						mAccpetUser.getRelationId(), true, true,false);
				break;
			case R.id.other_refuse:// 拒绝医生或者医学生
				new AddOrRefuseFriendLogic(
						new AddOrRefuseFriendLogicInterface() {

							@Override
							public void onError(int code, Throwable e) {
								UITools.showToast("操作失败");
							}

							@Override
							public void onDataReturn() {
								mBigLayout.removeView(mAgreeLayout);
								getDataFromServer();
							}
						}, Constants.getUser().getUserId(),
						mAccpetUser.getUserId(), mAccpetUser.getRole_type(),
						mAccpetUser.getRelationId(), false, true,false);
				break;
			default:
				break;
			}
		}

	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.money_accept:
			new AddOrRefuseFriendLogic(new AddOrRefuseFriendLogicInterface() {

				@Override
				public void onError(int code, Throwable e) {
					UITools.showToast("添加病人失败");
				}

				@Override
				public void onDataReturn() {
					mBigLayout.removeView(mAgreeLayout);
					getDataFromServer();
				}
			}, Constants.getUser().getUserId(), mAccpetUser.getUserId(),
					mAccpetUser.getRole_type(), mAccpetUser.getRelationId(),
					true, false,false);

			break;
		case R.id.free_accept:
			new AddOrRefuseFriendLogic(new AddOrRefuseFriendLogicInterface() {

				@Override
				public void onError(int code, Throwable e) {
					UITools.showToast("添加病人失败");
				}

				@Override
				public void onDataReturn() {
					mBigLayout.removeView(mAgreeLayout);
					getDataFromServer();
				}
			}, Constants.getUser().getUserId(), mAccpetUser.getUserId(),
					mAccpetUser.getRole_type(), mAccpetUser.getRelationId(),
					true, true,false);

			break;
		default:
			break;
		}

	}

}
