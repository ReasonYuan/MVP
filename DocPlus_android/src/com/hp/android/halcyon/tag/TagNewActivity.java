package com.hp.android.halcyon.tag;

import java.util.ArrayList;
import java.util.HashMap;

import android.content.Intent;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.entity.Tag;
import com.fq.halcyon.logic2.ContactLogic;
import com.fq.halcyon.logic2.ContactLogic.ContactLogicInterface;
import com.fq.halcyon.logic2.TagLogic;
import com.fq.halcyon.logic2.TagLogic.OnTagModifyCallback;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.Tool;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.SelectContactsActivity;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.CustomProgressDialog;
import com.hp.android.halcyon.widgets.LittleTextDialog;
import com.hp.android.halcyon.widgets.MyGridView;

public class TagNewActivity extends BaseActivity implements OnTagModifyCallback {
	public static final int DEL_SUCCESS = 200; // 删除成功
	public static final String REMOVE_TAG_NAME = "removeTag";

	private MyGridView mGridView;
	private EditText mEtAddTag;
	private TextView mTextNote;
	private ArrayList<Tag> mTagList = Constants.tagList;
	private ArrayList<Contacts> mSelContacts = new ArrayList<Contacts>();
	private ArrayList<Contacts> mOldContacts;
	private GridUserAdapter mAdapter = new GridUserAdapter();
	private Tag mTag;
	private boolean mIsRemove;
	private boolean mIsTagExise; // 判断标签是否已经存在，false为不存在，true为存在
	private CustomProgressDialog mProgressDialog;

	public static int ADD_TAG_SUCCESS = 100;

	private View mTagNameDel;

	@Override
	public int getContentId() {
		return R.layout.activity_tag_new;
	}

	@Override
	public void init() {
		// setContainerTopUnderTopbar();
		mTextNote = (TextView) findViewById(R.id.tv_tag_new_note);
		mEtAddTag = (EditText) findViewById(R.id.et_tag_new_add);
		mGridView = (MyGridView) findViewById(R.id.gv_tagnew_group);
		mTagNameDel = findViewById(R.id.iv_tag_new_del);
		mTagNameDel.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				mEtAddTag.setText("");
			}
		});

		mTag = Tool.getTagById(getIntent().getIntExtra("tagId", 0));
		TextView title = (TextView) findViewById(R.id.tv_tag_edit_title);
		if (mTag.getId() == 0) {
			// 新建标签
			setTitle(R.string.activity_title_tag_new);
			title.setText("新建标签");
		} else {
			// 标签成员管理
			setTitle("编辑标签");
			title.setText("编辑标签");
			mOldContacts = new ArrayList<Contacts>();
			mSelContacts.addAll(mTag.getContacts());
			mOldContacts.addAll(mTag.getContacts());
			String tile = mTag.getTitle();
			if (tile != null) {
				mEtAddTag.setText(tile);
				mEtAddTag.setSelection(tile.length());
			}
			findViewById(R.id.btn_tag_new_del).setVisibility(View.VISIBLE);
		}

		if (mTag.getName() != null && !"".equals(mTag.getName())) {
			mTagNameDel.setVisibility(View.VISIBLE);
		}

		mGridView.setAdapter(mAdapter);

		mEtAddTag.addTextChangedListener(new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
			}

			@Override
			public void afterTextChanged(Editable s) {
				String tag = s.toString().trim();
				mTagNameDel.setVisibility(("".equals(tag) ? View.GONE
						: View.VISIBLE));
				if (mTag != null && tag.equals(mTag.getTitle())) {
					mIsTagExise = false;
					mTextNote.setVisibility(View.GONE);
					return;
				}
				for (int i = 0, count = mTagList.size(); i < count; i++) {
					if (tag.equals(mTagList.get(i).getTitle())) {
						mTextNote.setVisibility(View.VISIBLE);
						mIsTagExise = true;
						break;
					} else {
						mIsTagExise = false;
						mTextNote.setVisibility(View.GONE);
					}
				}
			}
		});

		mGridView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				if (!mIsRemove || position == mAdapter.getCount() - 2
						|| position == mAdapter.getCount() - 1)
					return;
				mSelContacts.remove(position);
				mAdapter.notifyDataSetChanged();
				//该标签没有成员时，设置删除标记为false，此时点击添加按钮直接跳转到添加成员页面，而不是将mIsRemove设置为false
				if (mSelContacts.size() == 0) {
					mIsRemove = false;
				}
			}
		});
	}

	public void onTagSaveClick(View v) {
		if (!isNetWork())
			return;
		if (TextUtils.isEmpty(mEtAddTag.getText())) {
			UITools.showToast("请输入标签名称");
			return;
		}
		String tag = mEtAddTag.getText().toString().trim();
		if (mTag.getId() == 0) {
			onAddTag();
		} else {
			if (!tag.equals(mTag.getTitle())) {// 改了标签
				Tag tmpTag = new Tag();
				tmpTag.setId(mTag.getId());
				tmpTag.setTitle(tag);
				new TagLogic().modifyTag(tmpTag, this);
			}

			int[] addDocPIds = getAddDocPatIds();
			int[] remDocPIds = getRemoveDocPatIds();

			int[] ids = { mTag.getId() };
			String[] titles = null;
			showProgress();
			new TagLogic().modifyTagContact(addDocPIds, ids, titles,
					remDocPIds, ids, this);
		}
	}

	public void onTagRemoveClick(View v) {
		onRemoveTag();
	}

	@Override
	public void onTopRightBtnClick(View view) {
		onAddTag();
	}

	private void onAddTag() {
		if (!isNetWork())
			return;

		if (TextUtils.isEmpty(mEtAddTag.getText())) {
			UITools.showToast("请输入标签名称");
			return;
		}

		if (mIsTagExise) {
			UITools.showToast("标签已存在");
			return;
		}

		showProgress();
		String tag = mEtAddTag.getText().toString().trim();
		TagLogic logic = new TagLogic();
		if (mSelContacts.size() == 0) {// 一个空的标签
			logic.addTag(tag, this);
		} else {// 新建标签并贴给病历
			int[] docids = new int[mSelContacts.size()];
			for (int i = 0; i < mSelContacts.size(); i++) {
				docids[i] = mSelContacts.get(i).getUserId();// .getDoctorPatientId();
			}
			String[] titles = { tag };
			logic.modifyTagContact(docids, null, titles, null, null, this);
		}
	}

	private void onRemoveTag() {
		if (!isNetWork())
			return;
		if (mTag.getId() == 0)
			return;

		final CustomDialog dialog = new CustomDialog(TagNewActivity.this);
		dialog.setMessage("确认要删除此标签："+mTag.getTitle()+"?");
		dialog.setPositiveListener(R.string.btn_yes, new OnClickListener() {
			public void onClick(View v) {
				dialog.dismiss();
				delTag(mTag.getTitle());
			}
		});
		dialog.setNegativeButton(R.string.btn_no, new OnClickListener() {
			public void onClick(View v) {
				dialog.dismiss();
			}
		});

	}

	private boolean isNetWork() {
		if (!UITools.isNetworkAvailable(TagNewActivity.this)) {
			LittleTextDialog textDialog = new LittleTextDialog(
					TagNewActivity.this);
			textDialog.setMessage("不支持离线操作");
			return false;
		}
		return true;
	}

	@SuppressWarnings("unchecked")
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		if (resultCode == SelectContactsActivity.CONTACTS_RESULT_CODE) {
			mSelContacts.addAll((ArrayList<Contacts>) data.getSerializableExtra(SelectContactsActivity.EXTRAS_SEL_RECORDS));
			mAdapter.notifyDataSetChanged();
		}

	}

	class GridUserAdapter extends BaseAdapter implements OnClickListener {
		@Override
		public int getCount() {
			return mSelContacts.size() + 2;
		}

		@Override
		public Contacts getItem(int position) {
			//当position对应的是添加和删除按钮时，返回空
			if (position >= mSelContacts.size())
				return null;
			return mSelContacts.get(position);

		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {

			if (position == (getCount() - 2)) {// 添加好友
				convertView = LayoutInflater.from(TagNewActivity.this).inflate(
						R.layout.item_user_add, null);
				convertView.findViewById(R.id.iv_user_add).setOnClickListener(
						this);
			} else if (position == (getCount() - 1)) {// 删除好友
				convertView = LayoutInflater.from(TagNewActivity.this).inflate(
						R.layout.item_user_remove, null);// item_user_remove
				convertView.findViewById(R.id.iv_user_remove)// iv_user_remove
						.setOnClickListener(this);
				convertView
						.setVisibility(mSelContacts.size() > 0 ? View.VISIBLE
								: View.GONE);
			} else {
				Contacts user = mSelContacts.get(position);
				convertView = LayoutInflater.from(TagNewActivity.this).inflate(
						R.layout.item_user_head, null);
				final ImageView mImgFace = (ImageView) convertView
						.findViewById(R.id.iv_user_head);
				TextView mTextName = (TextView) convertView
						.findViewById(R.id.tv_user_name);

				ApiSystem.getInstance().getHeadImage(new Photo(user.getImageId(), ""), new ICallback() {
					
					@Override
					public void doCallback(Object obj) {
						mImgFace.setImageBitmap(UITools.getBitmapWithPath(""+obj));
					}
				}, false, 2);
//				ImageManager.from(TagNewActivity.this).displayImage(mImgFace,
//						user.getHeadPicPath(), R.color.app_head_pink);

				mTextName.setText(user.getName());

				convertView.findViewById(R.id.iv_head_removesign)
						.setVisibility(mIsRemove ? View.VISIBLE : View.GONE);
			}
			return convertView;
		}

		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.iv_user_add:
				if (mIsRemove) {
					mIsRemove = false;
					notifyDataSetChanged();
					break;
				}
				Intent intent = new Intent(TagNewActivity.this,SelectContactsActivity.class);

				if (mSelContacts != null) {
					ArrayList<Integer> ints = new ArrayList<Integer>();
					for (Contacts user : mSelContacts) {
						ints.add(user.getUserId());
					}
					intent.putExtra(SelectContactsActivity.EXTRAS_SEL_RECORDIDS, ints);
				}

				startActivityForResult(intent, 10);

				break;
			case R.id.iv_user_remove:
				mIsRemove = !mIsRemove;
				notifyDataSetChanged();
				break;
			default:
				break;
			}
		}

	}

	/**
	 * 删除标签
	 */
	private void delTag(String tagName) {
		showProgress();
		ArrayList<Tag> tagList = Constants.tagList;
		ArrayList<Integer> tagId = new ArrayList<Integer>();
		for (int i = 0, count = tagList.size(); i < count; i++) {
			if (tagName.equals(tagList.get(i).getTitle())) {
				tagId.add(tagList.get(i).getId());
			}
		}

		final TagLogic logic = new TagLogic();
		logic.delTag(tagId, new TagLogic.SuccessCallBack() {
			public void onSuccess(int responseCode, String msg, int type,
					Object results) {
				// TODO 删除成功
				// logic.getListAllTags(null);
				runOnUiThread(new Runnable() {
					public void run() {
						dismissProgress();
						UITools.showToast("删除成功");
						setResult(DEL_SUCCESS);
						finish();
					}
				});
			}
		}, new TagLogic.FailCallBack() {

			@Override
			public void onFail(int code, String msg) {
				// TODO 删除失败
				runOnUiThread(new Runnable() {
					public void run() {
						dismissProgress();
						UITools.showToast("删除失败");
					}
				});
			}
		});
	}

	private boolean isRecordInArray(int id, ArrayList<Contacts> users) {
		for (Contacts red : users) {
			if (red.getUserId() == id)
				return true;
		}
		return false;
	}

	private int[] getAddDocPatIds() {
		ArrayList<Integer> ids = new ArrayList<Integer>();
		for (Contacts user : mSelContacts) {
			if (!isRecordInArray(user.getUserId(), mOldContacts)) {
				ids.add(user.getUserId());
			}
		}
		if (ids.size() > 0) {
			int[] addids = new int[ids.size()];
			for (int i = 0; i < ids.size(); i++) {
				addids[i] = ids.get(i);
			}
			return addids;
		} else {
			return null;
		}
	}

	private int[] getRemoveDocPatIds() {
		ArrayList<Integer> ids = new ArrayList<Integer>();
		for (Contacts user : mOldContacts) {
			if (!isRecordInArray(user.getUserId(), mSelContacts)) {
				ids.add(user.getUserId());
				ArrayList<String> tags = user.getTags();
				for (int i = 0; i < tags.size(); i++) {
					if (mTag.getTitle().equals(tags.get(i))) {
						tags.remove(i);
						break;
					}
				}
			}
		}
		if (ids.size() > 0) {
			int[] removeids = new int[ids.size()];
			for (int i = 0; i < ids.size(); i++) {
				removeids[i] = ids.get(i);
			}
			return removeids;
		} else {
			return null;
		}

	}

	@Override
	public void onSuccess(Tag tag) {
		if (tag != null) {
			for (Tag tg : Constants.tagList) {
				if (tg.getId() == tag.getId()) {
					tg.setTitle(tag.getTitle());
					tg.setCount(tag.getCount());
					break;
				}
			}
		}
		runOnUiThread(new Runnable() {
			public void run() {
				dismissProgress();
			}
		});
	}

	@Override
	public void onModifySuccess(final boolean isb) {
		if (isb) {
			new ContactLogic(new ContactLogicInterface() {
				public void onError(int code, Throwable e) {
					runOnUiThread(new Runnable() {
						public void run() {
							dismissProgress();
							finish();
						}
					});
				}

				@Override
				public void onDataReturn(
						HashMap<String, ArrayList<Contacts>> mHashPeerList) {
					runOnUiThread(new Runnable() {
						public void run() {
							dismissProgress();
							finish();
						}
					});
				}
			}, Constants.getUser().getUserId());
		} else {
			runOnUiThread(new Runnable() {
				public void run() {
					UITools.showToast("添加标签失败");
					dismissProgress();
				}
			});
		}
	}

	@Override
	public void addTag(final Tag tag) {
		runOnUiThread(new Runnable() {
			public void run() {
				dismissProgress();
				Constants.tagList.add(tag);
				setResult(ADD_TAG_SUCCESS);
				finish();
			}
		});
	}

	@Override
	public void onBackPressed() {
		if (mProgressDialog != null)
			return;
		else
			super.onBackPressed();
	}

	@Override
	protected void onStop() {
		super.onStop();
	}

	public void showProgress() {
		mProgressDialog = new CustomProgressDialog(this);
		mProgressDialog.setMessage("正在提交数据，请稍后...");
	}

	public void dismissProgress() {
		if (mProgressDialog != null) {
			mProgressDialog.dismiss();
			mProgressDialog = null;
		}
	}
}