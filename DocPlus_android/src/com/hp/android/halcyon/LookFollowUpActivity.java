package com.hp.android.halcyon;

import java.util.ArrayList;

import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.FollowUp;
import com.fq.halcyon.entity.LeaveMessage;
import com.fq.halcyon.entity.OnceFollowUpCycle;
import com.fq.halcyon.logic2.SearchFollowUpDetailLogic;
import com.fq.halcyon.logic2.SearchFollowUpDetailLogic.SearchFollowUpDetailLogicInterface;
import com.fq.halcyon.logic2.SendFollowUpLeaveMessageLogic;
import com.fq.halcyon.logic2.SendFollowUpLeaveMessageLogic.SendFollowUpLeaveMessageLogicInterface;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.TimeFormatUtils;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.view.LookFollowUpView;
import com.hp.android.halcyon.view.LookFollowUpView.UpdateUIInterface;

public class LookFollowUpActivity extends BaseActivity implements OnClickListener{
	private ViewPager mPager;
	private ArrayList<View> mViewList;
	private MypageAdapter adapter;
	private MessageAdapter messageAdapter;
	private TextView mTittle;
	private ListView mMessageListView;
	private EditText mMsgEt;
	private Button mBackMsg;
	private int mTimerId;
	private FollowUp mCurrentFollowUp;
	private  ArrayList<LeaveMessage> mMessageList = new ArrayList<LeaveMessage>();
	
	
	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.message_back:
			String msg = mMsgEt.getText().toString().trim();
			if (!msg.equals("")) {
				submitMessage(msg,mTimerId);
			}
			break;

		default:
			break;
		}
	}

	@Override
	public int getContentId() {
		return R.layout.activity_loo_follow_up;
	}

	@Override
	public void init() {
		setTopLeftBtnShow(true);
		setTitle("查看随访");
		initWidget();
		mTimerId = getIntent().getExtras().getInt("timerId");
		getDetail();
		mPager = (ViewPager) findViewById(R.id.view_pager);
		
	}
	
	public void submitMessage(final String msg,int timerId){
		SendFollowUpLeaveMessageLogic messageLogic = new SendFollowUpLeaveMessageLogic(new SendFollowUpLeaveMessageLogicInterface() {
			
			@Override
			public void onError(int code, Throwable error) {
				UITools.showToast("回复留言失败!");
			}
			
			@Override
			public void onSubmitMessageSuccess() {
				LeaveMessage message = new LeaveMessage();
				message.setmDate(TimeFormatUtils.getTimeByFormat(System.currentTimeMillis(), "yyyy-MM-dd HH:mm"));
				message.setmMessage(msg);
				message.setRoleType(3);
				message.setmName(Constants.getUser().getUsername());
				mMessageList.add(message);
				messageAdapter.notifyDataSetChanged();
				mMsgEt.setText("");
			}
			
			@Override
			public void onSubmitMessageError(int code, String msg) {
				UITools.showToast("回复留言失败!");
			}
		});
		messageLogic.submitMessage(msg, timerId);
	}
	
	public void getDetail(){
		SearchFollowUpDetailLogic mDetailLogic = new SearchFollowUpDetailLogic(new SearchFollowUpDetailLogicInterface() {
			
			@Override
			public void onError(int code, Throwable error) {
				UITools.showToast("获取数据失败！");
			}
			
			@Override
			public void onSearchSuccess(FollowUp mFollowUp) {
				mCurrentFollowUp = mFollowUp;
				mTittle.setText(mFollowUp.getmFolloUpTempleName());
				initFollowUpViewDataAndView(mFollowUp);
				mMessageList = mFollowUp.getmMessageList();
				messageAdapter = new MessageAdapter();
				mMessageListView.setAdapter(messageAdapter);
			}
			
			@Override
			public void onSearchError(int code, String msg) {
				UITools.showToast("获取数据失败！");
			}
		});
		mDetailLogic.searchFollowUpDetail(mTimerId);
	}
	
	public void initFollowUpViewDataAndView(FollowUp mFollowUp){
		mPager.removeAllViews();
		adapter = new MypageAdapter();
		mViewList = new ArrayList<View>();
		ArrayList<OnceFollowUpCycle> mOnceFollowUpCycleList = mFollowUp.getmFollowUpItemsList();
		ArrayList<Integer> mItemsId = new ArrayList<Integer>();
		int size = mOnceFollowUpCycleList.size();
		ArrayList<Contacts> mFriendList = mFollowUp.getmFriendsList();
		if (size == 0) {
			finish();
		}
		/**
		 * 目前设计中只有一个提醒的病人 因此取mFriendList.get(0)
		 */
		Contacts mPatient = mFriendList.get(0);
		for (int i = 0; i < size; i++) {
			OnceFollowUpCycle mCycle = mOnceFollowUpCycleList.get(i);
			mItemsId.add(mCycle.getmItemtId());
			LookFollowUpView mView = new LookFollowUpView(this);
			mViewList.add(mView.getView());
			mView.initData(mItemsId,mCycle.getmTimerDate(),mPatient,mCycle,new UpdateUIInterface() {
				
				@Override
				public void callBack(int type) {
					switch (type) {
					case 1:
						getDetail();
						break;
					case 2:
						finish();
						break;
					default:
						break;
					}
					
				}
			},mTimerId);
		}
		adapter.initViewList(mViewList);
		mPager.setAdapter(adapter);
	}
	
	public void initWidget(){
		mTittle = (TextView) findViewById(R.id.look_tittle);
		mMessageListView = (ListView) findViewById(R.id.message_list);
		mMsgEt = (EditText) findViewById(R.id.msg_et);
		mBackMsg = (Button) findViewById(R.id.message_back);
		mBackMsg.setOnClickListener(this);
	}

	class MypageAdapter extends PagerAdapter{
		ArrayList<View> mList = new ArrayList<View>();
		
		public void initViewList(ArrayList<View> mViewList){
			mList = mViewList;
			notifyDataSetChanged();
		}
		
		@Override
		public int getCount() {
			return mList.size();
		}

		@Override
		public boolean isViewFromObject(View arg0, Object arg1) {
			return arg0 == arg1;
		}
		
		@Override
		public Object instantiateItem(ViewGroup container, int position) {
			container.addView(mList.get(position),0);
			return mList.get(position);
		}
		
		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			container.removeView(mList.get(position));
		}
	}
	
	class MessageAdapter extends BaseAdapter{

		@Override
		public int getCount() {
			return mMessageList.size();
		}

		@Override
		public Object getItem(int position) {
			return mMessageList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(LookFollowUpActivity.this).inflate(R.layout.item_follow_up_msg, null);
			}
			LeaveMessage mLeaveMessage =  mMessageList.get(position);
			TextView mDate = (TextView) convertView.findViewById(R.id.date);
			TextView mName = (TextView) convertView.findViewById(R.id.name);
			TextView mContent = (TextView) convertView.findViewById(R.id.content);
			ImageView mIcon = (ImageView) convertView.findViewById(R.id.icon);
			if (mLeaveMessage.getRoleType() == 1) {
				mIcon.setImageResource(R.drawable.doctor_icon);
			}else if(mLeaveMessage.getRoleType() == 3){
				mIcon.setImageResource(R.drawable.patient_icon);
			}
			String date = TimeFormatUtils.getTimeByFormat(TimeFormatUtils.getTimeMillisByDateWithSeconds(mLeaveMessage.getmDate()));
			mDate.setText(date);
			mName.setText(mLeaveMessage.getmName()+":");
			mContent.setText(mLeaveMessage.getmMessage());
			return convertView;
		}
		
	}
}
