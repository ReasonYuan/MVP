package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.List;

import android.graphics.Typeface;
import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.ScoreDetail;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic2.ExpenseDetailLogic;
import com.fq.halcyon.logic2.ExpenseDetailLogic.ExpenseDetailLogicCallBack;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.TimeFormatUtils;
import com.fq.lib.tools.Tool;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshBase.Mode;
import com.handmark.pulltorefresh.library.PullToRefreshBase.OnRefreshListener2;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.hp.android.halcyon.util.UITools;

public class ScoreDetailActivity extends BaseActivity{

	private ImageView mImgHead;//头像
	private TextView mTextName;//医家号
	private TextView mTextScore;//积分
	private PullToRefreshListView mDetailListView; //积分变动详细列表
	private ListView actualListView;
	private DetailAdapter mAdapter;
	private int page = 0;
	private int pageSize = 20;
	private List<ScoreDetail> mDetailList = new ArrayList<ScoreDetail>();
	
	@Override
	public int getContentId() {
		return R.layout.activity_score_detail;
	}

	@Override
	public void init() {
		initWidgets();
		initData();
		initListener();
	}
	
	/**
	 * 初始化控件 
	 */
	private void initWidgets() {
		mImgHead = (ImageView) findViewById(R.id.iv_score_detail_head);
		mTextName = (TextView) findViewById(R.id.tv_score_detail_dp_name);
		mTextScore = (TextView) findViewById(R.id.tv_score_detail_score);
		mDetailListView = (PullToRefreshListView) findViewById(R.id.lv_score_detail_list);
		actualListView = mDetailListView.getRefreshableView();
		mDetailListView.setMode(Mode.PULL_FROM_END);
		Typeface mFont2 = Typeface.createFromAsset(getAssets(),"ElleNovCMed.otf");
		mTextScore.setTypeface(mFont2);
	}

	/**
	 * 初始化数据 
	 */
	private void initData() {
		mImgHead.setImageBitmap(UITools.getBitmapWithPath(FileSystem.getInstance().getUserHeadPath()));
		mTextName.setText(Constants.getUser().getDPName());
		mTextScore.setText(Tool.get3Th(Constants.getUser().getDPMoney()));
		mAdapter = new DetailAdapter();
		actualListView.setAdapter(mAdapter);
		getDetailList(page, pageSize);
	}
	
	/**
	 * 事件处理 
	 */
	private void initListener() {
		mDetailListView.setOnRefreshListener(new OnRefreshListener2<ListView>() {

			@Override
			public void onPullDownToRefresh(
					PullToRefreshBase<ListView> refreshView) {
				
			}

			@Override
			public void onPullUpToRefresh(PullToRefreshBase<ListView> refreshView) {
				String label = DateUtils.formatDateTime(getApplicationContext(), System.currentTimeMillis(),
						DateUtils.FORMAT_SHOW_TIME | DateUtils.FORMAT_SHOW_DATE | DateUtils.FORMAT_ABBREV_ALL);
				refreshView.getLoadingLayoutProxy().setLastUpdatedLabel(label);
				page++;
				getDetailList(page, pageSize);
			}
		});
	}
	
	/**
	 * 积分变动详细的列表的Adapter
	 */
	protected class DetailAdapter extends BaseAdapter{

		private List<ScoreDetail> mList = new ArrayList<ScoreDetail>();
		
		public void addList(List<ScoreDetail> mList) {
			this.mList = mList;
			notifyDataSetChanged();
		}
		
		public void cleanData(){
			this.mList.clear();
		}
		
		@Override
		public int getCount() {
			return mList.size();
		}

		@Override
		public ScoreDetail getItem(int position) {
			return mList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View view, ViewGroup group) {
			if(view == null){
				view = LayoutInflater.from(ScoreDetailActivity.this).inflate(R.layout.item_score_detail, null);
			}
			Typeface mFont2 = Typeface.createFromAsset(getAssets(),"ElleNovCMed.otf");
			TextView mTextLeftScore = (TextView) view.findViewById(R.id.item_score_detail_left_score);
			TextView mTextTime = (TextView) view.findViewById(R.id.item_score_detail_time);
			TextView mTextCtrl = (TextView) view.findViewById(R.id.item_score_detail_ctrl);
			TextView mTextScore = (TextView) view.findViewById(R.id.item_score_detail_score);
			mTextLeftScore.setTypeface(mFont2);
			View mLine = view.findViewById(R.id.item_score_detail_bottom_line);
			mLine.setVisibility(View.VISIBLE);
			mTextLeftScore.setText(Tool.get3Th(getItem(position).getScore()));
			mTextTime.setText(TimeFormatUtils.getTimeByFormat(getItem(position).getDate(), "yyyy/MM/dd"));
			mTextCtrl.setText(getItem(position).getCtrlName() + "");
			mTextScore.setText(Tool.get3Th(getItem(position).getScore()));
			if(position == getCount() - 1){
				mLine.setVisibility(View.INVISIBLE);
			}
			return view;
		}
	}
	
	/**
	 *获取积分详细列表 
	 */
	public void getDetailList(int page, int pageSize){
		new ExpenseDetailLogic(page, pageSize, new ExpenseDetailLogicCallBack() {
			
			@Override
			public void onResultCallBack(int code, List<ScoreDetail> mDetailList) {
				ScoreDetailActivity.this.mDetailList.addAll(mDetailList);
//				mAdapter.cleanData();
				mAdapter.addList(ScoreDetailActivity.this.mDetailList);
				mDetailListView.onRefreshComplete();
			}
			
			@Override
			public void onErrorCallBack(int code, String msg) {
				System.out.println(msg);
				mDetailListView.onRefreshComplete();
			}
		});
	}
}
