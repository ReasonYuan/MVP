package com.hp.android.halcyon.tag;

import java.util.ArrayList;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemLongClickListener;
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
import com.fq.halcyon.entity.Tag;
import com.fq.halcyon.logic2.TagLogic;
import com.fq.halcyon.logic2.TagLogic.RequestTagInfCallBack;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.UserInfoActivity;
import com.hp.android.halcyon.util.IntentKey;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;

public class TagListActivity extends BaseActivity {

	private ExpandableListView mListView;
	private ArrayList<Tag> mTagList = Constants.tagList;
	private TagAdapter mAdapter = new TagAdapter();
	private LinearLayout mLayoutDatas;
	private TextView mTextNote;

	@Override
	public int getContentId() {
		return R.layout.activity_tag_list;
	}

	@Override
	public void init() {
		setTopRightImgSrc(R.drawable.btn_new_friend_right);
		setTitle("标签");
		mLayoutDatas = getView(R.id.ll_tag_list);
		mTextNote = getView(R.id.tv_tag_list_data_none);
		mListView = getView(R.id.lv_tag_home_list);
		mListView.setAdapter(mAdapter);

		mListView.setOnItemLongClickListener(new OnItemLongClickListener() {

			public boolean onItemLongClick(AdapterView<?> parent, View view,
					int position, long id) {
				if (view.getId() == 992) {
					final Tag tag = (Tag) view.getTag();
					final CustomDialog dialog = new CustomDialog(
							TagListActivity.this);
					dialog.setMessage("是否编辑标签:" + tag.getTitle() + "?");
					dialog.setPositiveListener(R.string.btn_sure,
							new OnClickListener() {
								public void onClick(View v) {
									dialog.dismiss();
									Intent intent = new Intent(TagListActivity.this,TagNewActivity.class);
									intent.putExtra("tagId", tag.getId());
									startActivityForResult(intent, 200);
								}
							});
					dialog.setNegativeButton(R.string.btn_cancel,
							new OnClickListener() {
								public void onClick(View v) {
									dialog.dismiss();
								}
							});
					return true;
				}
				return false;
			}
		});

		mListView.setOnGroupExpandListener(new OnGroupExpandListener() {

			@Override
			public void onGroupExpand(int groupPosition) {
				for (int i = 0, count = mListView.getExpandableListAdapter()
						.getGroupCount(); i < count; i++) {
					if (groupPosition != i) {
						mListView.collapseGroup(i);
					}
				}
			}
		});
	}

	@Override
	protected void onResume() {
		super.onResume();
		getTagList();
	}

	@Override
	public void onTopRightBtnClick(View view) {
		startActivity(new Intent(this, TagNewActivity.class));
	}

	/**
	 * 标签列表的adapter
	 */
	class TagAdapter extends BaseExpandableListAdapter implements
			android.view.View.OnClickListener {

		public TagAdapter() {
			if (mTagList == null)
				mTagList = new ArrayList<Tag>();
		}

		@Override
		public int getGroupCount() {
			return mTagList.size();
		}

		@Override
		public int getChildrenCount(int groupPosition) {
			return mTagList.get(groupPosition).getCount();
		}

		@Override
		public Tag getGroup(int groupPosition) {
			return mTagList.get(groupPosition);
		}

		@Override
		public Object getChild(int groupPosition, int childPosition) {
			return null;
		}

		@Override
		public long getGroupId(int groupPosition) {
			return 0;
		}

		@Override
		public long getChildId(int groupPosition, int childPosition) {
			return 0;
		}

		@Override
		public boolean hasStableIds() {
			return false;
		}

		@Override
		public View getGroupView(int groupPosition, boolean isExpanded,
				View convertView, ViewGroup parent) {
			Tag tag = mTagList.get(groupPosition);
			if (convertView == null) {
				convertView = LayoutInflater.from(TagListActivity.this)
						.inflate(R.layout.item_department, null);
				convertView.setId(992);
			}
			TextView mType = (TextView) convertView
					.findViewById(R.id.department);
			TextView mCount = (TextView) convertView
					.findViewById(R.id.department_count);
			mType.setText(tag.getTitle());
			mCount.setText("(" + tag.getCount() + "人)");
			convertView.setTag(tag);
			return convertView;
		}

		@Override
		public View getChildView(int groupPosition, int childPosition,
				boolean isLastChild, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(TagListActivity.this)
						.inflate(R.layout.item_department_detail_item, null);
			}
			Contacts user = mTagList.get(groupPosition).getContacts()
					.get(childPosition);
			View bottomLine = convertView
					.findViewById(R.id.item_department_detail_item_bottom_line);
			if (childPosition == getChildrenCount(groupPosition) - 1
					&& groupPosition != getGroupCount() - 1) {
				bottomLine.setVisibility(View.VISIBLE);
			} else {
				bottomLine.setVisibility(View.GONE);
			}

			final ImageView img = (ImageView) convertView
					.findViewById(R.id.img_item_department_detail_head);
			
			ApiSystem.getInstance().getHeadImage(new Photo(user.getImageId(), ""), new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					img.setImageBitmap(UITools.getBitmapWithPath(""+obj));
				}
			}, false, 2);
//			ImageManager.from(TagListActivity.this).displayImage(img,
//					user.getHeadPicPath(), R.drawable.app_icon);

			TextView text = (TextView) convertView
					.findViewById(R.id.tv_item_department_detail_name);
			text.setText(user.getName());
			View v = convertView.findViewById(R.id.ll_tag_item);
			v.setTag(user);
			v.setOnClickListener(this);

			return convertView;
		}

		@Override
		public boolean isChildSelectable(int groupPosition, int childPosition) {
			return false;
		}

		@Override
		public void onClick(View v) {
			Contacts user = (Contacts) v.getTag();
			Intent intent = new Intent(TagListActivity.this,
					UserInfoActivity.class);
			intent.putExtra(IntentKey.EXTRA_USER, user);
			intent.putExtra(IntentKey.EXTRA_RELATION_ID, user.getRelationId());
			intent.putExtra(IntentKey.EXTRA_IS_FRIEND, true);
			startActivity(intent);
		}
	}

	/**
	 * 获取医生的所有标签
	 */
	private void getTagList() {
		// if(mTagList != null)mTagList.clear();
		TagLogic logic = new TagLogic();
		logic.getListAllTags(new RequestTagInfCallBack() {
			@Override
			public void onError(int code, Throwable error) {
				error.printStackTrace();
				UITools.showToast("网络异常或不稳定，请稍后再试");
			}

			@Override
			public void resTagList(final ArrayList<Tag> tags) {

				runOnUiThread(new Runnable() {
					public void run() {
						if (tags.size() == 0) {
							mLayoutDatas.setVisibility(View.GONE);
							mTextNote.setVisibility(View.VISIBLE);
							return;
						}else{
							mLayoutDatas.setVisibility(View.VISIBLE);
							mTextNote.setVisibility(View.GONE);
						}
						if (mTagList != null) {
							mTagList.clear();
						} else {
							mTagList = new ArrayList<Tag>();
						}
						mTagList.addAll(tags);
						mAdapter.notifyDataSetChanged();
					}
				});
			}
		});
	}
}
