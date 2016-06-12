package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Map;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.FollowUp;
import com.fq.halcyon.entity.HomeData;
import com.fq.halcyon.entity.HomeOneDayData;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic2.DoctorHomeLogic;
import com.fq.halcyon.logic2.DoctorHomeLogic.OnDoctorHomeCallback;
import com.fq.halcyon.logic2.SearchFollowUpDetailLogic;
import com.fq.halcyon.logic2.SearchFollowUpDetailLogic.SearchFollowUpDetailLogicInterface;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.TimeFormatUtils;
import com.hp.android.halcyon.util.AlarmHelper;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CircleImageView;

public class FollowUpAlarmActivity extends Activity implements OnDoctorHomeCallback{

	private FrameLayout mFrameLayout;
	
	private ListView mListView;
	
	private GradientDrawable mShadow;
	
	private long mAlarmTime;
	
	private DoctorHomeLogic mLogic;
	
	private BaseAdapter mAdapter;
	
	private ArrayList<FollowUp> mFollowUps;
	
	private SearchFollowUpDetailLogic mDetailLogic;
	
	private ArrayList<HomeData> datas;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		mFollowUps = new ArrayList<FollowUp>();
		mAlarmTime = getIntent().getLongExtra(AlarmHelper.ALARM_INTENT_TIME, System.currentTimeMillis());
		setContentView(R.layout.activity_follow_up_alarm);
		mFrameLayout = (FrameLayout) findViewById(R.id.fl_listFrame);
		mListView = (ListView) findViewById(R.id.lv_followups);
//		mShadow = new GradientDrawable(Orientation.TOP_BOTTOM, new int[] { 0xff5BC3B6, 0x00000000  ,0xff5BC3B6});
		mFrameLayout.setBackgroundDrawable(mShadow);
		mLogic = new DoctorHomeLogic();
		mLogic.requestOneDayPatientsForAlarm(mAlarmTime, this);
		
		String format = "yyyy年MM月dd";
		Calendar calendar = Calendar.getInstance();
		calendar.setTimeInMillis(System.currentTimeMillis());
		String text = TimeFormatUtils.getTimeByFormat(calendar.getTimeInMillis(), format);
		TextView yearView = (TextView) findViewById(R.id.tv_year);
		yearView.setText(text);
		text = TimeFormatUtils.getTimeByFormat(calendar.getTimeInMillis(), "HH:mm");
		TextView timeView = (TextView) findViewById(R.id.tv_time);
		timeView.setText(text);
		
		mAdapter = new BaseAdapter() {
			
			@Override
			public View getView(int position, View convertView, ViewGroup parent) {
				FollowUp followUp = mFollowUps.get(position);
				View view = convertView;
				if(view == null){
					view = getLayoutInflater().inflate(R.layout.item_alarm_follow_up, null);
				}
				TextView tName = (TextView) view.findViewById(R.id.tx_follow_up_t_name);
				tName.setText(followUp.getmFolloUpTempleName());
				TextView name = (TextView) view.findViewById(R.id.tx_follow_up_name);
				ArrayList<Contacts> friendsList = followUp.getmFriendsList() ;
				if(friendsList != null && friendsList.size() > 0){
					name.setText(friendsList.get(0).getName());
				}else {
					name.setText("");
				}
				
				final CircleImageView heard = (CircleImageView) view.findViewById(R.id.ig_heard);
				String url = datas.get(position).getmImgPath();
				ApiSystem.getInstance().getHeadImage(new Photo(datas.get(position).getmImgID(), ""), new ICallback() {
					
					@Override
					public void doCallback(Object obj) {
						heard.setImageBitmap(UITools.getBitmapWithPath(""+obj));
					}
				}, false, 2);
				return view;
			}
			
			@Override
			public long getItemId(int position) {
				return position;
			}
			
			@Override
			public Object getItem(int position) {
				return mFollowUps.get(position);
			}
			
			@Override
			public int getCount() {
				return mFollowUps.size();
			}
		};
		mListView.setAdapter(mAdapter);
		mDetailLogic  = new SearchFollowUpDetailLogic(new SearchFollowUpDetailLogicInterface() {
			
			@Override
			public void onError(int code, Throwable error) {
				UITools.showToast(error.toString());
			}
			
			@Override
			public void onSearchSuccess(FollowUp mFollowUp) {
				mFollowUps.add(mFollowUp);
				mAdapter.notifyDataSetChanged();
			}
			
			@Override
			public void onSearchError(int code, String msg) {
				UITools.showToast(msg);
			}
		});
		mListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				Intent intent = new Intent(FollowUpAlarmActivity.this,LookFollowUpActivity.class);
				intent.putExtra("timerId", datas.get(position).getmFollowUpId());
				startActivity(intent);
				finish();
			}
		});
	}

	@Override
	public void errorMonth(String msg) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void feedMonth(Map<Integer, ArrayList<Integer>> data) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void error(String msg) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void feedHomeDatas(ArrayList<HomeOneDayData> infos) {
		if(infos != null && infos.size() > 0){
			mFollowUps.clear();
			HomeOneDayData oneData = infos.get(0);
			datas = oneData.getDatas();
			for (int i = 0; i < datas.size(); i++) {
				mDetailLogic.searchFollowUpDetail(datas.get(i).getmFollowUpId());
			}
		}
	}
	

}
