package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.Map;

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
import com.fq.halcyon.entity.HomeData;
import com.fq.halcyon.entity.HomeOneDayData;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic2.DoctorHomeLogic;
import com.fq.halcyon.logic2.DoctorHomeLogic.OnDoctorHomeCallback;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.TimeFormatUtils;
import com.hp.android.halcyon.util.UITools;

public class FollowupListActivity extends BaseActivity implements OnItemClickListener{

	private ListView mListView;
	private FollowUpListAdapter mAdapter;
	private ArrayList<HomeOneDayData> OneDayDaas = new ArrayList<HomeOneDayData>();
	@Override
	public int getContentId() {
		return R.layout.activity_follow_up_list;
	}

	@Override
	public void init() {
		long time = getIntent().getExtras().getLong("time");
		String mCurrentDate = TimeFormatUtils.getCNDate2(time);
		setTitle(mCurrentDate);
		mListView = (ListView) findViewById(R.id.folloup_list);
		mAdapter = new FollowUpListAdapter();
		mListView.setOnItemClickListener(this);
		getOneDayHomeData(time);
	}
	
	public void getOneDayHomeData(long time){
		DoctorHomeLogic mHomeLogic = new DoctorHomeLogic();
		mHomeLogic.requestOneDayPatients(time, new OnDoctorHomeCallback() {
			
			@Override
			public void feedMonth(Map<Integer, ArrayList<Integer>> data) {
				
			}
			
			@Override
			public void feedHomeDatas(ArrayList<HomeOneDayData> infos) {
				OneDayDaas.clear();
				OneDayDaas = infos;
				mListView.setAdapter(mAdapter);
				mAdapter.notifyDataSetChanged();
			}
			
			@Override
			public void errorMonth(String msg) {
				
			}
			
			@Override
			public void error(String msg) {
				
			}
		});
	}

	class FollowUpListAdapter extends BaseAdapter{

		@Override
		public int getCount() {
			return OneDayDaas.get(0).getDatas().size();
		}

		@Override
		public Object getItem(int position) {
			return  OneDayDaas.get(0).getDatas().get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(FollowupListActivity.this).inflate(R.layout.item_follow_up_list, null);
			}
			
			HomeOneDayData mData = OneDayDaas.get(0);
			HomeData mHomeData = mData.getData(position);
			final ImageView mHead = (ImageView) convertView.findViewById(R.id.head_image);
			TextView mName = (TextView) convertView.findViewById(R.id.name);
			TextView mFollowUpName = (TextView) convertView.findViewById(R.id.follow_up_name);
			ApiSystem.getInstance().getHeadImage(new Photo(mHomeData.getmImgID(), ""), new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					mHead.setImageBitmap(UITools.getBitmapWithPath(""+obj));
				}
			}, false, 2);
			mName.setText(mHomeData.getmPatientName());
			mFollowUpName.setText(mHomeData.getmFollowUpName());
			return convertView;
		}
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		HomeOneDayData mData = OneDayDaas.get(0);
		HomeData mHomeData = mData.getData(position);
		Intent mIntent = new Intent();
		mIntent.putExtra("timerId", mHomeData.getmFollowUpId());
		mIntent.setClass(FollowupListActivity.this, LookFollowUpActivity.class);
		startActivity(mIntent);
	}
}
