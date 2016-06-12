package com.fq.android.plus.tag;

import java.util.ArrayList;

import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.entity.Tag;
import com.fq.halcyon.logic2.TagLogic;
import com.fq.halcyon.logic2.TagLogic.FailCallBack;
import com.fq.halcyon.logic2.TagLogic.SuccessCallBack;
import com.fq.halcyon.uilogic.TagUtils;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.fq.library.utils.KeyBoardUtils;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CircleImageView;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

/**
 * 为个人设置标签
 * @author niko
 *
 */
public class SettingTagActivity extends BaseActivity{

	private CircleImageView mImgUserHead;
	private TextView mUserName;
	private ListView mListViewTag;
	private Button mBtnSure;
	private EditText mAddTag;
	private View mFooterView;
	private CommonAdapter<Tag> mAdapter;
	private Contacts mUser;
	private ArrayList<Tag> datas;
	private int selectedPosition = -1;
	private TagUtils mTagUtils;
	
	@Override
	public int getContentId() {
		return R.layout.activity_plus_setting_tag;
	}

	@Override
	public void init() {
		initWidgets();
		initDatas();
		initListener();
	}

	private void initWidgets(){
		setTitle("设置标签");
		mImgUserHead = getView(R.id.cv_setting_tag_user_head);
		mUserName = getView(R.id.tv_setting_tag_user_name);
		mListViewTag = getView(R.id.lv_setting_tag_person_tag_list);
		mBtnSure = getView(R.id.btn_setting_tag_sure);
		mFooterView = LayoutInflater.from(this).inflate(R.layout.item_user_tag_edit, null);
		mAddTag = (EditText) mFooterView.findViewById(R.id.item_user_tag_add);
	}
	
	private void initDatas(){
		mTagUtils = new TagUtils();
		mUser = (Contacts) getIntent().getSerializableExtra("user");
		if (mUser != null) {
			ApiSystem.getInstance().getHeadImage(new Photo(mUser.getImageId(), ""), new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					mImgUserHead.setImageBitmap(UITools.getBitmapWithPath(""+obj));
				}
			}, false, 2);
			datas = mTagUtils.getMyContactTagList(mUser);
			mUserName.setText(mUser.getUsername());
		}
		
		mAdapter = new CommonAdapter<Tag>(this, R.layout.item_user_tag) {
			
			@Override
			public void convert(final int position, ViewHolder helper, Tag tag) {
				TextView tagText = helper.getView(R.id.tv_item_user_tag);
				TextView btnDelTag = helper.getView(R.id.btn_item_user_tag_del);
				tagText.setText(tag.getTitle());
				if (position%2  == 0) {
					//设置Tag的背景交替显示
					tagText.setSelected(false);
				}else{
					tagText.setSelected(true);
				}
				if (position == selectedPosition) {
					//设置item的删除按钮是否显示
					btnDelTag.setVisibility(View.VISIBLE);
				}else{
					btnDelTag.setVisibility(View.INVISIBLE);
				}
				
				btnDelTag.setOnClickListener(new OnClickListener() {
					//删除事件
					@Override
					public void onClick(View v) {
						datas.remove(position);
						selectedPosition = -1;
						mAdapter.notifyDataSetChanged();
					}
				});
			}
		};
		mAdapter.addDatas(datas);
		mListViewTag.addFooterView(mFooterView);
		mListViewTag.setAdapter(mAdapter);
	}
	
	private void initListener(){
		mListViewTag.setOnItemLongClickListener(new OnItemLongClickListener() {
			//长按显示删除按钮
			@Override
			public boolean onItemLongClick(AdapterView<?> parent, View view,
					int position, long id) {
				
				selectedPosition = position;
				mAdapter.notifyDataSetChanged();
				return true;
			}
		});
		
		mListViewTag.setOnItemClickListener(new OnItemClickListener() {
			//点击item取消删除按钮的显示
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				if (position != selectedPosition && selectedPosition >= 0) {
					selectedPosition = -1;
					mAdapter.notifyDataSetChanged();
				}
			}
		});
		
		//添加标签
		mListViewTag.setOnTouchListener(new MyTouchListener());
		getView(R.id.view_setting_tag_title).setOnTouchListener(new MyTouchListener());
		getView(R.id.view_setting_tag_userinfo).setOnTouchListener(new MyTouchListener());
		
		mBtnSure.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				addTagFromEditText();
				mTagUtils.getChangeList(mTagUtils.getMyContactTagList(mUser), datas);
				
				final CustomProgressDialog dialog = new CustomProgressDialog(SettingTagActivity.this);
				TagLogic logic = new TagLogic();
				ArrayList<Integer> patientIdList = new ArrayList<Integer>();
				patientIdList.add(mUser.getUserId());
				logic.attachPatients(patientIdList, mTagUtils.getAddTagWithIdList(), mTagUtils.getAddTagWithStrList(), mTagUtils.getDelTagList(), new SuccessCallBack() {
					
					@Override
					public void onSuccess(int responseCode, String msg, int type, Object results) {
						dialog.dismiss();
						UITools.showToast("设置成功");
						finish();
						new TagLogic().getListAllTags(null);
						
						for(Contacts user : Constants.contactsList){
							if(user.getUserId() == mUser.getUserId()){
								user.getTags().clear();
								for(int i = 0; i < datas.size(); i++){
									user.getTags().add(datas.get(i).getTitle());
								}
								break;
							
							}
						}
					}
				}, new FailCallBack(){

					@Override
					public void onFail(int code, String msg) {
						dialog.dismiss();
						UITools.showToast("网络状况不佳，设置失败");
					}
					
				});
				setResult(250);
			}
		});
	}
	
	/**
	 *使得EditView失去焦点的Touch事件 
	 */
	private class MyTouchListener implements OnTouchListener {

		@Override
		public boolean onTouch(View v, MotionEvent event) {
			KeyBoardUtils.closeKeybord(mAddTag, SettingTagActivity.this);
			mUserName.setFocusable(true);
			mUserName.setFocusableInTouchMode(true);
			mUserName.requestFocus();
			addTagFromEditText();
			return false;
		}
	}
	
	/**
	 * 通过输入框添加标签的操作
	 */
	private void addTagFromEditText(){
		String tagText = mAddTag.getText().toString().trim();
		ArrayList<Tag> allTags = mTagUtils.getMyContactTagList(mUser);
		boolean isExist = false;
		if (!"".equals(tagText)) {
			mAddTag.setText("");
			
			for (int i = 0; i < datas.size(); i++) {
				Tag tempTag = datas.get(i);
				if (tagText.equals(tempTag.getTitle())) {
					datas.remove(i);
					datas.add(0, tempTag);
					mAdapter.notifyDataSetChanged();
					return;
				}
			}
			for (Tag tag : allTags) {
				if (tagText.equals(tag.getTitle())) {
					isExist = true;
					datas.add(tag);
					break;
				}
			}
			if (!isExist) {
				Tag tag = new Tag();
				tag.setId(-1);
				tag.setTitle(tagText);
				datas.add(tag);
			}
			
			mAdapter.notifyDataSetChanged();
		}
	}
}
