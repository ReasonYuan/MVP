package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.HashMap;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic2.ContactLogic;
import com.fq.halcyon.logic2.ContactLogic.ContactLogicInterface;
import com.fq.lib.callback.ICallback;
import com.hp.android.halcyon.util.UITools;

public class SelectFollowUpPatientActivity extends BaseActivity implements OnItemClickListener{

	private ListView mPatientListView;
	private ArrayList<Contacts> mList = new ArrayList<Contacts>();
	@Override
	public int getContentId() {
		return R.layout.activity_select_follow_up_patient;
	}

	@Override
	public void init() {
		setTopLeftBtnEnable(true);
		setTitle("发送随访");
		initWidget();	
		getData();
	}

	public void initWidget(){
		mPatientListView = (ListView) findViewById(R.id.patient_list);
		mPatientListView.setOnItemClickListener(this);
	}
	
	public void getData(){
		new ContactLogic(new ContactLogicInterface() {
			
			@Override
			public void onError(int code, Throwable e) {
				UITools.showToast("获取数据失败！");
			}
			
			@Override
			public void onDataReturn(HashMap<String, ArrayList<Contacts>> mHashPeerList) {
				mList = com.fq.lib.tools.Constants.contactsMap.get(com.fq.lib.tools.Constants.ROLE_PATIENT);
				MyPatientAdapter mAdapter = new MyPatientAdapter();
				mPatientListView.setAdapter(mAdapter);
			}
		}, com.fq.lib.tools.Constants.getUser().getUserId());
	}

	class MyPatientAdapter extends BaseAdapter{

		@Override
		public int getCount() {
			return mList.size();
		}

		@Override
		public Object getItem(int position) {
			return mList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(SelectFollowUpPatientActivity.this).inflate(R.layout.item_follow_up_patient, null);
			}
			
			Contacts mPatient = mList.get(position);
			
			final ImageView mHeadImage = (ImageView) convertView.findViewById(R.id.patient_head);
			TextView mName = (TextView) convertView.findViewById(R.id.follow_patient_name);
			ApiSystem.getInstance().getHeadImage(new Photo(mPatient.getImageId(), ""), new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					mHeadImage.setImageBitmap(UITools.getBitmapWithPath(""+obj));
				}
			}, false, 2);
			mName.setText(mPatient.getName());
			return convertView;
		}
		
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		Contacts mPatient = mList.get(position);
		Intent mIntent = new Intent();
		mIntent.putExtra("Patient", mPatient);
		mIntent.setClass(this, SelectFollowUpTemplate.class);
		startActivity(mIntent);
	}
}
