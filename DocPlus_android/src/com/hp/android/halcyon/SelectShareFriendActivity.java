package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.HashMap;

import android.content.Intent;
import android.util.SparseBooleanArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Patient;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.entity.Record;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.halcyon.logic2.ContactLogic;
import com.fq.halcyon.logic2.ContactLogic.ContactLogicInterface;
import com.fq.halcyon.logic2.ShareRecordLogic;
import com.fq.halcyon.logic2.ShareRecordLogic.ShareRecordCallBack;
import com.fq.halcyon.logic2.TagLogic;
import com.fq.lib.callback.ICallback;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.Constants;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CircleImageView;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

/**
 * 选着分享人的Activity
 * 
 * @author niko
 */
public class SelectShareFriendActivity extends BaseActivity {

	private ArrayList<Contacts> mDoctorList;
	private ListView mDoctorListView;
	private CommonAdapter<Contacts> mAdapter;
	private SparseBooleanArray mChkStatus = new SparseBooleanArray();
	private ArrayList<Integer> mShareFriends = new ArrayList<Integer>();
	private int mShareType;
	private Patient mSharePatient;
	private Record mShareRecord;
	private RecordItemSamp mShareItem;
	private int mRecordId;
	
	@Override
	public int getContentId() {
		return R.layout.activity_select_share_friend;
	}

	@Override
	public void init() {
		setTitle("选择分享人");
		mSharePatient = (Patient) getIntent().getSerializableExtra("sharePatient");
		mShareRecord = (Record) getIntent().getSerializableExtra("shareRecord");
		mShareItem = (RecordItemSamp)getIntent().getSerializableExtra("shareItem");
		mShareType = getIntent().getIntExtra("shareType", 0);
		mRecordId = getIntent().getIntExtra("recordId", 0);
		initWidgets();
		initListener();
		getDoctorList();
	}

	private void initWidgets() {
		mDoctorList = new ArrayList<Contacts>();
		mDoctorListView = (ListView) findViewById(R.id.list_select_share_friends);
		mDoctorListView.setAdapter(mAdapter = new CommonAdapter<Contacts>(this,
				R.layout.item_select_share_friend) {

			@Override
			public void convert(int position, ViewHolder helper,
					final Contacts contacts) {
				helper.setText(R.id.item_share_friend_name,contacts.getUsername());
				final CircleImageView imgFace = helper.getView(R.id.item_share_friend_face);
				FrameLayout btnChkFriend = helper.getView(R.id.item_share_check_friend);
				final ImageView imgChkFriend = helper.getView(R.id.item_share_check_friend_image);
				imgChkFriend.setSelected(mChkStatus.get(contacts.getUserId(),false));
				final Photo photo = new Photo();
				photo.setImageId(contacts.getImageId());
				
				//==YY==imageId(只要imageId)
//				photo.setImagePath(contacts.getHeadPicPath());
				ApiSystem.getInstance().getHeadImage(photo, new ICallback() {
					
					@Override
					public void doCallback(Object obj) {
						imgFace.setImageBitmap(UITools.getBitmapWithPath(""+obj));
					}
						
				}, false,2);
			}
		});
	}

	private void initListener() {
		findViewById(R.id.btn_share_to_friends).setOnClickListener(
				new OnClickListener() {

					@Override
					public void onClick(View v) {
						shareWarm();
					}
				});
		mDoctorListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				if (mChkStatus.get(mAdapter.getItem(arg2).getUserId())) {
					mChkStatus.put(mAdapter.getItem(arg2).getUserId(), false);
					mAdapter.notifyDataSetChanged();
					return;
				}else {
					mChkStatus.put(mAdapter.getItem(arg2).getUserId(), true);
					mAdapter.notifyDataSetChanged();
					return;
				}
			}
		});

		findViewById(R.id.btn_review_share_content).setOnClickListener(
				new OnClickListener() {

					@Override
					public void onClick(View v) {
						Intent intent = new Intent(SelectShareFriendActivity.this,ReviewShareDataActivity.class);
						intent.putExtra("shareType", mShareType);
						if (mShareType == RecordConstants.SHARE_RECORD) {
							intent.setClass(SelectShareFriendActivity.this,ReviewShareDataActivity.class);
							intent.putExtra("shareDatas", mShareRecord);
						} else if (mShareType == RecordConstants.SHARE_PATIENT) {
							intent.setClass(SelectShareFriendActivity.this,ReviewShareDataActivity.class);
							intent.putExtra("shareDatas", mSharePatient);
						}else if(mShareType == RecordConstants.SHARE_RECORD_ITEM){
							ArrayList<RecordItemSamp> itemList = new ArrayList<RecordItemSamp>();
							itemList.add(mShareItem);
							intent.putExtra("record_id", mRecordId);
							intent.putExtra("record_type_item", itemList);
							intent.putExtra("clickPosition", 0);
							intent.putExtra("isOnlyInfo", true);
							intent.setClass(SelectShareFriendActivity.this, BrowRecordItemActivity.class);
						}
						startActivity(intent);
					}
				});
	}

	private void getDoctorList() {
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
				mDoctorList = Constants.contactsMap.get(Constants.ROLE_DOCTOR);
				mAdapter.addDatas(mDoctorList);
			}
		}, Constants.getUser().getUserId());
	}

	/**
	 * 分享
	 */
	private void shareDatas() {
		final CustomProgressDialog dialog = new CustomProgressDialog(this);
		ShareRecordLogic logic = new ShareRecordLogic(
				new ShareRecordCallBack() {

					@Override
					public void shareRecordSuccess(int code, String msg) {
						dialog.dismiss();
						UITools.showToast("分享成功");
						finish();
					}

					@Override
					public void shareRecordError(int code, String msg) {
						dialog.dismiss();
						UITools.showToast("分享失败");
					}
				});
		switch (mShareType) {
		case RecordConstants.SHARE_PATIENT:
			logic.sharePatient(mSharePatient.getMedicalId(), mShareFriends);
			break;
		case RecordConstants.SHARE_RECORD:
			ArrayList<Integer> recordIds = new ArrayList<Integer>();
			recordIds.add(mShareRecord.getFolderId());
			logic.shareRecord(recordIds, mShareFriends);
			break;
		case RecordConstants.SHARE_RECORD_ITEM:
			ArrayList<Integer> recordItemIds = new ArrayList<Integer>();
			recordItemIds.add(mShareItem.getRecordItemId());
			logic.shareRecordItem(recordItemIds, mShareFriends);
			break;
		default:
			break;
		}

	}

	/**
	 * 分享提示
	 */
	private void shareWarm() {
		mShareFriends.clear();
		for (int i = 0; i < mChkStatus.size(); i++) {
			if (mChkStatus.valueAt(i)) {
				mShareFriends.add(mChkStatus.keyAt(i));
			}
		}
		if (!(mShareFriends.size() > 0)) {
			UITools.showToast("请选择联系人");
			return;
		}
		final CustomDialog dialog = new CustomDialog(this);
		View shareView = LayoutInflater.from(this).inflate(R.layout.view_delete_item, null);
		dialog.setOnlyContainer(shareView);
		dialog.setCanceledOnTouchOutside(false);
		TextView mTitle = (TextView) shareView.findViewById(R.id.view_delete_item_title);
		mTitle.setText("确认分享？");
		Button btnSure = (Button) shareView.findViewById(R.id.btn_delete_item_sure);
		Button btnCancel = (Button) shareView.findViewById(R.id.btn_delete_item_cancel);

		btnCancel.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				dialog.dismiss();
			}
		});

		btnSure.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				shareDatas();
			}
		});
	}
}
