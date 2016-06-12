package com.fq.android.plus.recorditem.view;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import android.content.Context;
import android.text.TextUtils.TruncateAt;
import android.text.method.TextKeyListener;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnLongClickListener;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView.LayoutParams;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.RecordItem;
import com.fq.halcyon.entity.RecordItem.TemplateItem;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.hp.android.halcyon.util.UITools;

public class OtherRecordView implements IRecordItemView {

	private View mView;
	private ListView mListBar;
	private Context mContext;
	private boolean mIsEdit;
	private RecordItem mRecordItem = new RecordItem();
	private InfoListAdapter mInfoListAdapter;
	private ListView mInfoListView;
	private boolean mIsMuLuEnable = true;

	public OtherRecordView(Context context) {
		mContext = context;
		mView = LayoutInflater.from(context).inflate(
				R.layout.view_record_item_others, null);
		mListBar = (ListView) mView.findViewById(R.id.view_record_item_bar);
		mInfoListView = (ListView) mView
				.findViewById(R.id.view_record_item_infolist);
		mListBar.setOnItemClickListener(new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				scrollToItemAccordingAnchor(position);
			}
		});
	}
	
	/**
	 * 找得到对应的anchor的则滚动，找不到的什么也不做
	 * @param positionInAnchors
	 */
	private void scrollToItemAccordingAnchor(int positionInAnchors){
		String anchorKey = (String) mListBar.getAdapter().getItem(positionInAnchors);
		//找到anhcorkey对应的listview中的item的位置
		int posInKeys = -1;
		for (int i = 0; i < mInfoListAdapter.getCount(); i++) {
			if (anchorKey.equals(mInfoListAdapter.getKey(i))) {
				posInKeys = i;
				break;
			}
		}
		if (posInKeys != -1) {
			mInfoListView.setSelection(posInKeys);
		}
	}

	@Override
	public View getRecordItemView() {
		return mView;
	}

	@Override
	public void setDatas(RecordItem recordItem) {
		mRecordItem = recordItem;
		setDetailInfo(recordItem.getNoteInfo(), recordItem.getTemplates());
	}

	@Override
	public boolean isEdit() {
		return mIsEdit;
	}

	public void setDetailInfo(JSONArray jsonInfo, ArrayList<TemplateItem> templates) {
//		mInfoListAdapter = (InfoListAdapter) mInfoListView.getAdapter();
		mInfoListAdapter = new InfoListAdapter();
		mInfoListAdapter.initData(jsonInfo, templates);
		mInfoListView.setAdapter(mInfoListAdapter);
	}

	/**
	 * 病历记录详细信息列表适配器
	 */
	class InfoListAdapter extends BaseAdapter implements OnClickListener,
			OnLongClickListener {
		private JSONArray mJsonInfo;
		private ArrayList<String> mKeys = new ArrayList<String>();

		private EditText mCurrenEdit;
		private HashMap<String, EditText> editMap = new HashMap<String, EditText>();

		public void initData(JSONArray json, ArrayList<TemplateItem> templates) {
			try {
				mJsonInfo = new JSONArray(json.toString());
			} catch (JSONException e) {
				e.printStackTrace();
				mJsonInfo = json;
			}

			mKeys.clear();
			for (int i = 0; i < json.length(); i++) {
				try {
					JSONObject obj = json.getJSONObject(i);
					Iterator<String> keys = obj.keys();
					while (keys.hasNext()) {
						String key = keys.next();
						if("index".equals(key))continue;//这个字段只是用于排序，不需要显示出来
						mKeys.add(key);
					}
				} catch (Exception e) {
					Log.e("OtherRecordView", "brow record item other record view get key error", e);
				}
			}
			
			//根据2015-04-10的视频会议，锚点是锚点，关键字是关键字，互不相关
			ArrayList<String>  anchorKeys = new ArrayList<String>();
			if(templates != null){
				for (int i = 0; i < templates.size(); i++) {
					anchorKeys.add(templates.get(i).name);
				}
				mListBar.setAdapter(new ListBarAdapter(anchorKeys));
				notifyDataSetChanged();
			}else{
				mIsMuLuEnable = false;
//				mListBar.setVisibility(View.GONE);
			}
			
			View container = mView.findViewById(R.id.fl_brow_recorditem_detail_info);
			container.setOnClickListener(new OnClickListener() {
				public void onClick(View v) {
					if(mCurrenEdit != null){
						InfoListAdapter.this.onClick(mCurrenEdit);
					}else if(editMap != null){
						Iterator iter = editMap.values().iterator();
						if(iter.hasNext()){
							InfoListAdapter.this.onClick((View) iter.next());
						}
					}
				}
			});
			
			container.setOnLongClickListener(new OnLongClickListener() {
				public boolean onLongClick(View v) {
					if(mCurrenEdit != null){
						InfoListAdapter.this.onLongClick(mCurrenEdit);
					}else if(editMap != null){
						Iterator iter = editMap.values().iterator();
						if(iter.hasNext()){
							InfoListAdapter.this.onLongClick((View) iter.next());
						}
					}
					return true;
				}
			});
		}
		
		@Override
		public int getCount() {
			return mKeys.size();
		}
		
		public String getKey(int position){
			return mKeys.get(position);
		}

		@Override
		public String getItem(int position) {
			JSONObject obj = mJsonInfo.optJSONObject(position);
			return obj.optString(mKeys.get(position));
//			return mJsonInfo.optString(mKeys.get(position));
		}

		@Override
		public long getItemId(int position) {
			return 0;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(mContext).inflate(
						R.layout.item_record_item_detail_list_info, null);
			}

			JSONObject obj = mJsonInfo.optJSONObject(position);
			String title = mKeys.get(position);
			
			EditText titleEdit = (EditText) convertView
					.findViewById(R.id.tv_record_item_detail_title);
			titleEdit.setText(title);
			titleEdit.setOnClickListener(this);
			titleEdit.setOnLongClickListener(this);
			EditText infoEdit = (EditText) convertView
					.findViewById(R.id.tv_record_item_detail_info);
			infoEdit.setText(obj.optString(title));
			infoEdit.setOnClickListener(this);
			infoEdit.setOnLongClickListener(this);
			infoEdit.setTag(title);
			if(mIsEdit){
				enableEdit(infoEdit);
			}else {
				disableEdit(infoEdit);
			}
			if (!editMap.containsKey(title)) {
				editMap.put(title, infoEdit);
			}
			return convertView;
		}

		public EditText getWillEditText(View v) {
			EditText edit = null;
			if (v.getId() == R.id.tv_record_item_detail_title) {
				String title = ((EditText) v).getText().toString();
				edit = editMap.get(title);
			} else {
				edit = (EditText) v;
			}
			return edit;
		}
		
		@Override
		public boolean onLongClick(View v) {
			if(mRecordItem.isShared()){
				UITools.showToast("不能修改分享的病历记录");
				return true;
			}
			
			if (mIsEdit)return true;

			//如果锚点是显示的，则隐藏掉
			if(mListBar.getVisibility() == View.VISIBLE){
				showMuluView();
			}
			
			if (editStateCallBack != null) {
				editStateCallBack.joinEditState();
			}
			enableEdit(mInfoListView);
			
			mCurrenEdit = getWillEditText(v);
			setCurrentEditWork();
			showInput(mCurrenEdit, true);

			return true;
		}

		@Override
		public void onClick(View v) {
			if (mIsEdit) {
				EditText edit = getWillEditText(v);
				if (mCurrenEdit == edit)
					return;
				// 保存改变后的内容
				setCurrentEditDone();
				mCurrenEdit = edit;

				setCurrentEditWork();
			} else {
				if(!mIsMuLuEnable)return;
				if (editStateCallBack != null) editStateCallBack.showMuLuView();
				showMuluView();
			}
		}

		private void setCurrentEditDone() {
			clearFocusable();
			String key = (String) mCurrenEdit.getTag();
			int position = mKeys.indexOf(key);
			try {
				JSONObject json = mJsonInfo.optJSONObject(position);
				json.put(key, mCurrenEdit.getText().toString());
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}

		private void setCurrentEditWork() {
			mCurrenEdit.setFocusable(true);
			mCurrenEdit.setFocusableInTouchMode(true);
			mCurrenEdit.requestFocus();
			mView.post(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					mCurrenEdit.requestFocus();
				}
			});
		}

		private void showInput(EditText edit, boolean isShow) {
			InputMethodManager imm = (InputMethodManager) mContext
					.getSystemService(Context.INPUT_METHOD_SERVICE);
			if (isShow) {
				imm.showSoftInput(edit, InputMethodManager.SHOW_FORCED);
			} else {
				imm.hideSoftInputFromWindow(edit.getWindowToken(), 0);
			}
		}

		public void clearFocusable() {
			mCurrenEdit.setFocusable(false);
			mCurrenEdit.setFocusableInTouchMode(false);
			mCurrenEdit.clearFocus();
		}

		/**
		 * 取消编辑，内容也不保存
		 */
		public void cancelEdit() {
			mJsonInfo = mRecordItem.getNoteInfo();
			notifyDataSetChanged();
		}

		/**
		 * 内容退出编辑模式
		 */
		public void exitEdit() {
			showInput(mCurrenEdit, false);
			clearFocusable();
		}

		/**
		 * 保存编辑的内容
		 */
		public void saveEdit() {
			setCurrentEditDone();
			showInput(mCurrenEdit, false);
			mRecordItem.setNoteInfo(mJsonInfo);
		}
	}

	/**
	 * 病历记录目录列表适配器
	 */
	class ListBarAdapter extends BaseAdapter {

		private ArrayList<String> mKeys = new ArrayList<String>();

		public ListBarAdapter(ArrayList<String> keys) {
			mKeys = keys;
		}

		public void initKeys(ArrayList<String> keys) {
			mKeys = keys;
			notifyDataSetChanged();
		}

		public int getCount() {
			return mKeys.size();
		}

		@Override
		public String getItem(int position) {
			return mKeys.get(position);
		}

		@Override
		public long getItemId(int position) {
			return 0;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			TextView tv = (TextView) convertView;
			if (tv == null) {
				tv = new TextView(mContext);
				tv.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,
						UITools.dip2px(30)));
				tv.setTextColor(0xff61c0b4);
				tv.setSingleLine(true);
				tv.setEllipsize(TruncateAt.MIDDLE);
				tv.setGravity(Gravity.CENTER);
				tv.setTextSize(UITools.sp2px(mContext, 4.5f));
			}
			tv.setText(getItem(position));
			return tv;
		}
	}

	private void showMuluView() {
		Animation animation = null;
		if (mListBar.getVisibility() == View.GONE) {
			mListBar.setVisibility(View.VISIBLE);
			animation = AnimationUtils.loadAnimation(mContext,
					R.anim.top_right_in);
		} else {
			mListBar.setVisibility(View.GONE);
			animation = AnimationUtils.loadAnimation(mContext,
					R.anim.top_right_out);
		}
		mListBar.setAnimation(animation);
	}

	@Override
	public void exitEdit() {
		mInfoListAdapter.exitEdit();
	}

	@Override
	public void cancelEdit() {
		mInfoListAdapter.cancelEdit();
	}

	@Override
	public void saveEdit() {
		mInfoListAdapter.saveEdit();
	}

	@Override
	public void setEditState(boolean state) {
		mIsEdit = state;
		if(!mIsEdit){
			disableEdit(mInfoListView);
		}
	}

	private void enableEdit(View v){
		if(v instanceof ViewGroup){
			ViewGroup viewGroup = (ViewGroup) v;
			for (int i = 0; i < viewGroup.getChildCount(); i++) {
				enableEdit(viewGroup.getChildAt(i));
			}
			return;
		}
		if(v instanceof EditText && v.getId() == R.id.tv_record_item_detail_info){
			((EditText)v).setKeyListener(TextKeyListener.getInstance());
//			v.setClickable(false);
		}
	}
	
	private void disableEdit(View v){
		if(v instanceof ViewGroup){
			ViewGroup viewGroup = (ViewGroup) v;
			for (int i = 0; i < viewGroup.getChildCount(); i++) {
				disableEdit(viewGroup.getChildAt(i));
			}
			return;
		}
		if(v instanceof EditText && v.getId() == R.id.tv_record_item_detail_info){
			((EditText)v).setKeyListener(null);
//			v.setClickable(true);
		}
	}

	
	private JoinEditStateCallBack editStateCallBack;

	@Override
	public void OnJoinEditListener(JoinEditStateCallBack editStateCallBack) {
		this.editStateCallBack = editStateCallBack;
	}
}
