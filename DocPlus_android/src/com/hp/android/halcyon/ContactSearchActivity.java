package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.List;

import android.content.Intent;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnKeyListener;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.entity.UserAction;
import com.fq.halcyon.logic2.DoctorAddFriendLogic;
import com.fq.halcyon.logic2.DoctorAddFriendLogic.DoctorAddFriendLogicInterface;
import com.fq.halcyon.logic2.SearchFriendsLogic;
import com.fq.halcyon.logic2.SearchFriendsLogic.SearchFriendsLogicInterface;
import com.fq.lib.UserActionManger;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.util.IntentKey;
import com.hp.android.halcyon.util.MessageStruct;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.SearchView;
import com.hp.android.halcyon.widgets.SearchView.SearchListener;

public class ContactSearchActivity extends BaseActivity {
	private ListView mListView;
	private SearchAdapter mAdapter;
	private List<Contacts> mUserList;
	private EditText mSearchText;
	private FrameLayout mSearchBtn;
	private FrameLayout mSearchCancel;//用于清除搜索框的内容
	private SearchView mSearchContact;
	private int page = 0;
	private int pageSize = 20;
	
	private boolean isNewFriend; //用于判断类型，true：搜索好友进行添加，false：搜索好友列表
	private String mKeyWords; //搜索我的好友列表的关键字
	private boolean isFromSetRemind; //用于判断是否是来自添加提醒的搜索
	@Override
	public int getContentId() {
		return R.layout.activity_contact_search;
	}
	
	
	@Override
	public void onTopLeftBtnClick(View v){
		if (mSearchContact.getSearchStatus()) {
			mSearchContact.startViewAnimOut();
		}
		onBackPressed();
	}
	
	@Override
	public void init() {
		initWidgets();
		initSearch();
		
		mSearchBtn.setOnClickListener(new OnClickListener() {
		//搜索事件	
			@Override
			public void onClick(View view) {
				String mSearchStr = mSearchText.getText().toString().trim();
				if(!UITools.isNetworkAvailable(ContactSearchActivity.this)){
					UITools.showToast("请检查网络连接");
					return;
				}
				if(mSearchStr == null || "".equals(mSearchStr)){
					return;
				}
				mAdapter.cleanListData();
				getSearchResult(mSearchStr,isNewFriend);
			}
		});
		
		//搜索框内容改变事件
		mSearchText.addTextChangedListener(new MyTextWatch());
		
		mSearchText.setOnKeyListener(new OnKeyListener() {
			
			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				if(keyCode==KeyEvent.KEYCODE_ENTER  && event.getAction() == KeyEvent.ACTION_DOWN){
					((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE)) 
					.hideSoftInputFromWindow( 
					ContactSearchActivity.this 
					.getCurrentFocus() 
					.getWindowToken(), 
					InputMethodManager.HIDE_NOT_ALWAYS); 
					
					String mSearchStr = mSearchText.getText().toString().trim();
					if(!UITools.isNetworkAvailable(ContactSearchActivity.this)){
						UITools.showToast("请检查网络连接");
						return false;
					}
					if(mSearchStr == null || "".equals(mSearchStr)){
						return false;
					}
					mAdapter.cleanListData();
					getSearchResult(mSearchStr,isNewFriend);
				}
				return false;
			}
		});
		
		
		//清除搜索框内容
		mSearchCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				mSearchText.setText("");
			}
		});
		
		if(mKeyWords == null || "".equals(mKeyWords)){
			mSearchCancel.setVisibility(View.INVISIBLE);
		}else{
			mSearchCancel.setVisibility(View.VISIBLE);
		}
		
		mSearchContact.setSearchListener(new SearchListener() {
			//搜索事件
			@Override
			public void searchChange(String key) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void searchCallback(String key) {
				if (!"".equals(key)) {
					getSearchResult(key, isNewFriend);
				}
			}
		});
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		if(!isNewFriend){
			getSearchResult(mSearchText.getText().toString().trim(), false);
		}
	}
	
	/**
	 *  初始化控件 
	 */
	private void initWidgets() {
//		Typeface mFont = Typeface.createFromAsset(getAssets(),
//				"lantingchuheijian.TTF");
//		((TextView) findViewById(R.id.tv_topbar_text)).setTextColor(Color
//				.parseColor("#535353"));
		isNewFriend = getIntent().getBooleanExtra("isNewFriend", true);
		isFromSetRemind = getIntent().getBooleanExtra("isFromSetRemind", false);
		mSearchContact = (SearchView) findViewById(R.id.sv_contact_search);
		if(isNewFriend){
			setTitle("添加朋友");
		}else{
			setTitle("搜索");
			mKeyWords = getIntent().getStringExtra("mKeyWords");
		}
		mSearchContact.setSearchHintText("医加号/手机号/姓名");
		mListView = (ListView) findViewById(R.id.listview);
		mSearchText = (EditText) findViewById(R.id.search_et);
		mSearchBtn = (FrameLayout) findViewById(R.id.btn_contact_search);
		mSearchCancel = (FrameLayout) findViewById(R.id.btn_contact_search_clean);
		mAdapter = new SearchAdapter();
		mUserList = new ArrayList<Contacts>();
		mListView.setAdapter(mAdapter);
		
		if(mKeyWords == null || "".equals(mKeyWords)){
			mSearchCancel.setVisibility(View.INVISIBLE);
		}else{
			mSearchCancel.setVisibility(View.VISIBLE);
		}
	}
	
	private void initSearch(){
		if(isNewFriend){
			return;
		}
		if("".equals(mKeyWords) || mKeyWords == null){
			return;
		}
		mSearchText.setText(mKeyWords);
		getSearchResult(mKeyWords,isNewFriend);
	}
	
	/**
	 *搜索到数据的adapter 
	 */
	private class SearchAdapter extends BaseAdapter{
		private List<Contacts> list = new ArrayList<Contacts>();
		
		public void setList(List<Contacts> mList){
			this.list = mList;
		}
		
		public void cleanListData(){
			if(list != null){
				list.clear();
				notifyDataSetChanged();
			}
		}
		
		@Override
		public int getCount() {
			return list.size();
		}

		@Override
		public Contacts getItem(int position) {
			return list.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			if(convertView == null){
				convertView = LayoutInflater.from(ContactSearchActivity.this).inflate(R.layout.item_contact_search, null);
			}
			
			final ImageView mHeadImage = (ImageView) convertView.findViewById(R.id.head_image);
			mHeadImage.setImageResource(R.color.app_head_pink);
			TextView mName = (TextView) convertView.findViewById(R.id.name);
			TextView mAdd= (TextView) convertView.findViewById(R.id.add);
			TextView mPatientFrom = (TextView) convertView.findViewById(R.id.patient_from);
			mPatientFrom.setVisibility(View.GONE);
			TextView mWichFrom = (TextView) convertView.findViewById(R.id.which_people);
			mWichFrom.setVisibility(View.GONE);
			if (isNewFriend) {
				mAdd.setVisibility(View.VISIBLE);
			}else{
				mAdd.setVisibility(View.GONE);
			}
			final Contacts friend = list.get(position);
			final Photo photo = new Photo();
			photo.setImageId(getItem(position).getImageId());
			
			//==YY==imageId(只要imageId)
//			photo.setImagePath(getItem(position).getHeadPicPath());
			ApiSystem.getInstance().getHeadImage(photo, new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					mHeadImage.setImageBitmap(UITools.getBitmapWithPath(""+obj));
				}
					
			}, false,2);
			mName.setText(getItem(position).getName());
			mAdd.setOnClickListener(new OnClickListener() {
				//添加按钮点击事件
				@Override
				public void onClick(View arg0) {
					
					new DoctorAddFriendLogic(new DoctorAddFriendLogicInterface() {
						
						@Override
						public void onDataReturn() {
							HalcyonApplication.getInstance().sendMessage(MessageStruct.MESSAGE_TYPE_ADD_NEW_FRIEND, "++++", friend.getUserId());
							Intent intent = new Intent();
							intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
							intent.setClass(ContactSearchActivity.this, NewFriendsActivity.class);
							startActivity(intent);
							int actionType = -1;
							int roleType = getItem(position).getRole_type();
							if(roleType == Constants.ROLE_DOCTOR || roleType == Constants.ROLE_DOCTOR_STUDENT){
								actionType = UserAction.ACTION_ADD_DEOCTOR;
							}else if(roleType == Constants.ROLE_PATIENT){
								actionType = UserAction.ACTION_ADD_PATIENT;
							}
							UserAction action = new UserAction(System.currentTimeMillis(),actionType,getItem(position).getName());
							UserActionManger.getInstance().addAction(action);
							UserActionManger.getInstance().getActions();
							finish();
						}


						@Override
						public void onError(int code, Throwable e) {
							Toast.makeText(ContactSearchActivity.this, "发送请求失败", Toast.LENGTH_LONG).show();
						}
					}, Constants.getUser().getUserId(), friend.getUserId(),DoctorAddFriendLogic.FRIEND_FROM_NORMAL);
				}
			});
			
			convertView.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					if(isFromSetRemind){
						Intent intent = new Intent();
						intent.putExtra("user", getItem(position));
						intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//						intent.setClass(ContactSearchActivity.this, SetRemindActivity.class);
						setResult(RESULT_OK, intent);
						finish();
					}
				}
			});
			
			mHeadImage.setOnClickListener(new OnClickListener() {
				//头像点击事件
				@Override
				public void onClick(View v) {
					Intent intent = new Intent();
					intent.putExtra(IntentKey.EXTRA_USER, getItem(position));
					
					if(isNewFriend){
						intent.putExtra(IntentKey.EXTRA_IS_FRIEND, false);
					}else if(!isNewFriend){
						intent.putExtra(IntentKey.EXTRA_IS_FRIEND, true);
						intent.putExtra(IntentKey.EXTRA_RELATION_ID, getItem(position).getRelationId());
					}
					
						intent.setClass(ContactSearchActivity.this, UserInfoActivity.class);
						startActivity(intent);
				}
			});
			return convertView;
		}
	}

	/**
	 *调用搜索接口获取到搜索的结果 
	 */
	private void getSearchResult(String keyWords, boolean isNewFriend){
		new SearchFriendsLogic(new SearchFriendsLogicInterface() {
			
			@Override
			public void onError(int code, Throwable e) {
				e.printStackTrace();
				UITools.showToast("搜索失败");
			}
			
			@Override
			public void onDataReturn(List<Contacts> mUserList) {
				if(mUserList.size() == 0){
					UITools.showToast("没有搜索到相匹配用户");
					mAdapter.cleanListData();
					return;
				}
				if(ContactSearchActivity.this.mUserList != null){
					ContactSearchActivity.this.mUserList.clear();
				}
				ContactSearchActivity.this.mUserList = mUserList;
				mAdapter.cleanListData();
				mAdapter.setList(mUserList);
				runOnUiThread(new Runnable() {
					@Override
					public void run() {
						mAdapter.notifyDataSetChanged();
					}
				});
			}
		}, Constants.getUser().getUserId(), keyWords, page, pageSize,isNewFriend);
	}

	/**
	 *搜索框内容改变的事件 
	 */
	private class MyTextWatch implements TextWatcher{

		@Override
		public void afterTextChanged(Editable arg0) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void beforeTextChanged(CharSequence arg0, int arg1, int arg2,
				int arg3) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void onTextChanged(CharSequence s, int arg1, int arg2,
				int arg3) {
			if(s.length() > 0){
				mSearchCancel.setVisibility(View.VISIBLE);
			}else{
				mSearchCancel.setVisibility(View.GONE);
			}
		}
	}
	

}
