package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.FollowUpTemple;
import com.fq.halcyon.logic2.FollowUpTempleListLogic;
import com.fq.halcyon.logic2.FollowUpTempleListLogic.FollowUpTempleListLogicInterface;
import com.hp.android.halcyon.util.UITools;

public class SelectFollowUpTemplate extends BaseActivity implements OnItemClickListener{

	private Contacts mContact;
	private ListView mListView;
	private ArrayList<FollowUpTemple> mTempleList;
	@Override
	public int getContentId() {
		return R.layout.activity_select_follow_up_temple;
}

	@Override
	public void init() {
		setTopLeftBtnShow(true);
		setTitle(R.string.select_follow_up_plan);
		mContact = (Contacts) getIntent().getExtras().get("Patient");
		initWidget();
		getTempleList();
	}

	public void initWidget(){
		mListView = (ListView) findViewById(R.id.temple_listview);
		mListView.setOnItemClickListener(this);
	}
	
	/**
	 * 获取服务器已有模板列表
	 */
	public void getTempleList(){
			FollowUpTempleListLogic mListLogic = new FollowUpTempleListLogic(new FollowUpTempleListLogicInterface() {
			
			@Override
			public void onError(int code, Throwable error) {
				UITools.showToast("获取数据失败！");
			}
			
			@Override
			public void onDataReturn(ArrayList<FollowUpTemple> templeList) {
				mTempleList = templeList;
				TempleAdapter mAdapter = new TempleAdapter();
				mListView.setAdapter(mAdapter);
			}
			
			@Override
			public void onDataError(int code, String msg) {
				UITools.showToast("获取数据失败！");
			}
		});
		
		mListLogic.getTempleList();
	}
	
	
	class TempleAdapter extends BaseAdapter {

		@Override
		public int getCount() {
			return mTempleList.size();
		}

		@Override
		public Object getItem(int position) {
			return mTempleList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(SelectFollowUpTemplate.this).inflate(R.layout.item_select_follow_up_temple, null);
			}
			TextView mTempleName = (TextView) convertView.findViewById(R.id.temple_name);
			FollowUpTemple mFollowUpTemple = mTempleList.get(position);
			mTempleName.setText(mFollowUpTemple.getTempleName());
			return convertView;
		}
		
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		Intent mIntent = new Intent();
		mIntent.putExtra("Patient", mContact);
		FollowUpTemple mFollowUpTemple = mTempleList.get(position);
		mIntent.putExtra("mFollowUpTemple",mFollowUpTemple);
		mIntent.setClass(this, SettingFollowUpActivity.class);
		startActivity(mIntent);	
	}
}
