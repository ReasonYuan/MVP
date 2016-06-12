package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.FollowUpTemple;
import com.fq.halcyon.logic2.DeleteFollowUpTempleLogic;
import com.fq.halcyon.logic2.DeleteFollowUpTempleLogic.DeleteFollowUpTempleLogicInterface;
import com.fq.halcyon.logic2.FollowUpTempleListLogic;
import com.fq.halcyon.logic2.FollowUpTempleListLogic.FollowUpTempleListLogicInterface;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

public class ManageFollowUpTempleActivity extends BaseActivity implements View.OnClickListener, OnItemClickListener{
	private Button mAdd;
	private ListView mListView;
	private ArrayList<FollowUpTemple> list;
	@Override
	public int getContentId() {
		return R.layout.activity_manage_follow_up_temple;
	}

	@Override
	public void init() {
		setTopLeftBtnShow(true);
		setTitle("管理随访模板");
		initWidget();
	}

	public void initWidget(){
		View mView = LayoutInflater.from(ManageFollowUpTempleActivity.this).inflate(R.layout.manage_temple_add_btn, null);
		mAdd = (Button) mView.findViewById(R.id.add);
		mAdd.setOnClickListener(this);
		mListView = (ListView) findViewById(R.id.manage_listview);
		mListView.setOnItemClickListener(this);
		mListView.addFooterView(mView);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		getTempleList();
	}
	
	public void getTempleList(){
		FollowUpTempleListLogic mListLogic = new FollowUpTempleListLogic(new FollowUpTempleListLogicInterface() {
			
			@Override
			public void onError(int code, Throwable error) {
				UITools.showToast("获取随访模板列表失败！");
			}
			
			@Override
			public void onDataReturn(ArrayList<FollowUpTemple> mTempleList) {
				list = mTempleList;
				MamageAdapter mamageAdapter = new MamageAdapter();
				mListView.setAdapter(mamageAdapter);
			}
			
			@Override
			public void onDataError(int code, String msg) {
				UITools.showToast("获取随访模板列表失败！");
			}
		});
		
		mListLogic.getTempleList();
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.add:
			Intent mIntent = new Intent();
			mIntent.setClass(this, AddFollowUpTempleActivity.class);
			startActivity(mIntent);
			break;

		default:
			break;
		}
	}
	
	class MamageAdapter extends BaseAdapter{

		@Override
		public int getCount() {
			return list.size();
		}

		@Override
		public Object getItem(int position) {
			return list.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(ManageFollowUpTempleActivity.this).inflate(R.layout.item_manage_temple, null);
			}
			final FollowUpTemple mFollowUpTemple = list.get(position);
			TextView mTextView = (TextView) convertView.findViewById(R.id.temple_name);
			mTextView.setText(mFollowUpTemple.getTempleName());
			Button mDelete = (Button) convertView.findViewById(R.id.delete);
			mDelete.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					final CustomDialog dialog = new CustomDialog(ManageFollowUpTempleActivity.this);
					View delView = LayoutInflater.from(ManageFollowUpTempleActivity.this).inflate(R.layout.view_delete_item, null);
					dialog.setOnlyContainer(delView);
					dialog.setCanceledOnTouchOutside(false);
					TextView mTittle = (TextView) delView.findViewById(R.id.view_delete_item_title);
					mTittle.setText("确认删除该模板?");
					Button btnSure = (Button) delView.findViewById(R.id.btn_delete_item_sure);
					Button btnCancel = (Button) delView.findViewById(R.id.btn_delete_item_cancel);
					btnSure.setOnClickListener(new OnClickListener() {
						
						@Override
						public void onClick(View v) {
							final CustomProgressDialog mCustomProgressDialog = new CustomProgressDialog(ManageFollowUpTempleActivity.this);
							DeleteFollowUpTempleLogic mDeleteFollowUpTempleLogic = new DeleteFollowUpTempleLogic(new DeleteFollowUpTempleLogicInterface() {
								
								@Override
								public void onError(int code, Throwable error) {
									UITools.showToast("删除模板失败");
									dialog.dismiss();
									mCustomProgressDialog.dismiss();
								}
								
								@Override
								public void onDeleteSuccessful() {
									list.remove(position);
									notifyDataSetChanged();
									UITools.showToast("删除模板成功");
									dialog.dismiss();
									mCustomProgressDialog.dismiss();
								}
								
								@Override
								public void onDeleteError(int code, String msg) {
									UITools.showToast("删除模板失败");
									dialog.dismiss();
									mCustomProgressDialog.dismiss();
								}
							}, mFollowUpTemple.getmTempleId());
							mDeleteFollowUpTempleLogic.deleteTemple();
						}
					});
					btnCancel.setOnClickListener(new OnClickListener() {
						
						@Override
						public void onClick(View v) {
							dialog.dismiss();
						}
					});
				}
			});
			
			convertView.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					FollowUpTemple mFollowUpTemple = list.get(position);
					Intent mIntent = new Intent();
					mIntent.putExtra("mFollowUpTempleId", mFollowUpTemple.getmTempleId());
					mIntent.putExtra("IsFromSendFollowUp",false);
					mIntent.setClass(ManageFollowUpTempleActivity.this, ModifyFollowUpTempleAcitivity.class);
					startActivity(mIntent);
				}
			});
			return convertView;
		}
		
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
				
	}
}
