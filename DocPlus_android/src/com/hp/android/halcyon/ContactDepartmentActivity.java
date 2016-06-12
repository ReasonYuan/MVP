package com.hp.android.halcyon;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextPaint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ExpandableListView.OnGroupExpandListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Photo;
import com.fq.lib.callback.ICallback;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.hp.android.halcyon.util.IntentKey;
import com.hp.android.halcyon.util.UITools;

public class ContactDepartmentActivity extends BaseActivity {

	private ExpandableListView mExpandableListView;
	private DepartmentAdapter mAdapter;
	private List<List<Contacts>> mChildData = new ArrayList<List<Contacts>>();
	private List<String> mTitle = new ArrayList<String>();
	private HashMap<String, ArrayList<Contacts>> mDepartmentMap = new HashMap<String, ArrayList<Contacts>>();

	@Override
	public int getContentId() {
		return R.layout.activity_contact_department;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void init() {
		// Typeface mFont = Typeface.createFromAsset(getAssets(),
		// "lantingchuheijian.TTF");
		// ((TextView) findViewById(R.id.tv_topbar_text)).setTextColor(Color
		// .parseColor("#535353"));
		// ((TextView) findViewById(R.id.tv_topbar_text)).setTypeface(mFont);
		setTitle("科室分布");
		mExpandableListView = (ExpandableListView) findViewById(R.id.listview);
		mAdapter = new DepartmentAdapter();
		mExpandableListView.setAdapter(mAdapter);
		mExpandableListView.setGroupIndicator(null);
		mExpandableListView.setVerticalScrollBarEnabled(false);
		Bundle bundle = getIntent().getExtras();
		mDepartmentMap = (HashMap<String, ArrayList<Contacts>>) bundle
				.get("mDepartmentMap");
		initData();
	}

	private void initData() {
		getDepartment();
		Set<String> key = mDepartmentMap.keySet();
		for (Iterator<String> it = key.iterator(); it.hasNext();) {
			String s = (String) it.next();
			// mTitle.add(s);
			mChildData.add(mDepartmentMap.get(s));
		}
		mExpandableListView
				.setOnGroupExpandListener(new OnGroupExpandListener() {

					@Override
					public void onGroupExpand(int groupPosition) {
						// TODO Auto-generated method stub
						for (int i = 0, count = mExpandableListView
								.getExpandableListAdapter().getGroupCount(); i < count; i++) {
							if (groupPosition != i) {
								mExpandableListView.collapseGroup(i);
							}
						}
					}

				});
	}

	@SuppressWarnings("unchecked")
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		switch (resultCode) {
		case 202:
			mDepartmentMap = (HashMap<String, ArrayList<Contacts>>) data
					.getExtras().get("departmentMapBack");
			getDepartment();
			mAdapter.notifyDataSetChanged();
			break;

		default:
			break;
		}

	}

	private class DepartmentAdapter extends BaseExpandableListAdapter {

		@Override
		public Object getChild(int groupPosition, int childPosition) {
			return mDepartmentMap.get(mTitle.get(groupPosition)) == null ? null
					: mDepartmentMap.get(mTitle.get(groupPosition)).get(
							childPosition);
		}

		@Override
		public long getChildId(int groupPosition, int childPosition) {
			return childPosition;
		}

		@Override
		public View getChildView(int groupPosition, final int childPosition,
				boolean isLastChild, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(
						ContactDepartmentActivity.this).inflate(
						R.layout.item_department_detail_item, null);
			}
			LinearLayout mLayout = (LinearLayout) convertView
					.findViewById(R.id.ll_tag_item);
			if (mDepartmentMap.get(mTitle.get(groupPosition)) != null) {
				final Contacts user = mDepartmentMap.get(
						mTitle.get(groupPosition)).get(childPosition);
				View bottomLine = convertView
						.findViewById(R.id.item_department_detail_item_bottom_line);
				final ImageView mImgHead = (ImageView) convertView
						.findViewById(R.id.img_item_department_detail_head);
				TextView mName = (TextView) convertView
						.findViewById(R.id.tv_item_department_detail_name);
				ApiSystem.getInstance().getHeadImage(
						new Photo(user.getImageId(), ""), new ICallback() {

							@Override
							public void doCallback(Object obj) {
								mImgHead.setImageBitmap(UITools
										.getBitmapWithPath("" + obj));
							}
						}, false, 2);
				// ImageManager.from(ContactDepartmentActivity.this).displayImage(
				// mImgHead, user.getHeadPicPath(), R.drawable.app_icon);
				mName.setText(user.getName());
				// topLine.setVisibility(View.GONE);
				// if (childPosition == 0) {
				// topLine.setVisibility(View.VISIBLE);
				// }
				bottomLine.setVisibility(View.GONE);
				if (childPosition == getChildrenCount(groupPosition) - 1
						&& groupPosition != mTitle.size() - 1) {
					bottomLine.setVisibility(View.VISIBLE);
				}
				mLayout.setOnClickListener(new OnClickListener() {

					@Override
					public void onClick(View v) {
						Intent mIntent = new Intent();
						mIntent.putExtra(IntentKey.EXTRA_USER, user);
						mIntent.putExtra(IntentKey.EXTRA_RELATION_ID,
								user.getRelationId());
						mIntent.putExtra(IntentKey.EXTRA_IS_FRIEND, true);
						mIntent.setClass(ContactDepartmentActivity.this,
								UserInfoActivity.class);
						mIntent.putExtra("departmentName", user.getDepartment());
						mIntent.putExtra("departmentMap", mDepartmentMap);
						startActivityForResult(mIntent, 200);
					}
				});
			}
			return convertView;
		}

		@Override
		public int getChildrenCount(int groupPosition) {
			return mDepartmentMap.get(mTitle.get(groupPosition)) == null ? 0
					: mDepartmentMap.get(mTitle.get(groupPosition)).size();
		}

		@Override
		public Object getGroup(int groupPosition) {
			return mTitle.get(groupPosition);
		}

		@Override
		public int getGroupCount() {
			return mTitle.size();
		}

		@Override
		public long getGroupId(int groupPosition) {
			return groupPosition;
		}

		@Override
		public View getGroupView(int groupPosition, boolean isExpanded,
				View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(
						ContactDepartmentActivity.this).inflate(
						R.layout.item_department, null);
			}
			TextView mType = (TextView) convertView
					.findViewById(R.id.department);
			TextView mCount = (TextView) convertView
					.findViewById(R.id.department_count);
			mType.setText(mTitle.get(groupPosition));
			TextPaint tp = mType.getPaint();
			tp.setFakeBoldText(true);
			int size = 0;
			if (mDepartmentMap.get(mTitle.get(groupPosition)) != null) {
				size = mDepartmentMap.get(mTitle.get(groupPosition)).size();
			}
			mCount.setText("(" + size + ")");
			return convertView;
		}

		@Override
		public boolean hasStableIds() {
			return false;
		}

		@Override
		public boolean isChildSelectable(int groupPosition, int childPosition) {
			return true;
		}

	}

	public void getDepartment() {
		String line = "";
		String result = "";

		try {
			InputStreamReader inputReader = new InputStreamReader(
					getResources().getAssets().open("departments.json"));
			BufferedReader bufReader = new BufferedReader(inputReader);

			while ((line = bufReader.readLine()) != null)
				result += line;
			JSONObject jsonObj = new JSONObject(result);
			JSONArray jsonArray = jsonObj.getJSONArray("departments");
			for (int i = 0; i < jsonArray.length(); i++) {
				String mTittle = jsonArray.getString(i).toString();
				boolean b = true;
				for (int j = 0; j < mDepartmentMap.size() && b; j++) {
					if (mDepartmentMap.get(mTittle) != null) {
						mTitle.add(0, mTittle);
						b = false;
					}
				}
				if (b) {
					mTitle.add(mTittle);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
}
