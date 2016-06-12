package com.fq.android.visualization;

import java.util.ArrayList;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Record;
import com.fq.halcyon.entity.SurveyRecordItem;
import com.fq.halcyon.entity.visualize.VisualData;
import com.fq.halcyon.logic2.GetRecordListLogic;
import com.fq.halcyon.logic2.SurveyRecordLogic;
import com.fq.halcyon.logic2.GetRecordListLogic.GetRecordListCallBack;
import com.fq.halcyon.logic2.SurveyRecordLogic.SurveyRecordCallBack;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.TimeFormatUtils;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.DataVisualizationActivity;
import com.hp.android.halcyon.util.IntentKey;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.view.LoadingView;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.CustomProgressDialog;
import com.hp.android.halcyon.widgets.SearchView;
import com.hp.android.halcyon.widgets.SearchView.SearchListener;

public class SVisualizeRecordActivity extends BaseActivity{

	private String searchKey;
	
	private LinearLayout mVisLayout;
	private ListView mRecordListView;
	private CommonAdapter<SurveyRecordItem> mItemAdapter;
	private ArrayList<Record> mRecordList;
	private CommonAdapter<Record> mAdapter;
	private int patientId;
	private SearchView mSearchPatient;
	private VisualData data;
	private ArrayList<Integer> selectedRecords = new ArrayList<Integer>();
	
	@Override
	public int getContentId() {
		return R.layout.activity_chose_record;
	}

	@Override
	public void init() {
		patientId = getIntent().getIntExtra("patientId", 0);
		data = (VisualData) getIntent().getSerializableExtra("extra");
		mRecordList = new ArrayList<Record>();
		initWidgets();
		initListener();
		initDatas();
	}

	private void initDatas() {
		searchKey = getIntent().getStringExtra(IntentKey.SEARCH_KEY);
		getRecordList(searchKey);
	}

	private void initWidgets() {
		setTitle("请选择病历");
		mVisLayout = getView(R.id.ll_chose_record_visualize);
		mRecordListView = getView(R.id.lv_chose_record);
		mSearchPatient = getView(R.id.sv_chose_record_search);
		mRecordListView.setAdapter(mAdapter = new CommonAdapter<Record>(this,R.layout.item_record_folder) {
			
			@Override
			public void convert(final int position,ViewHolder helper, final Record record) {

				TextView surveyRecord = helper.getView(R.id.item_tv_record_overview);
				ImageView imgBg = helper.getView(R.id.img_item_record_bg);
				imgBg.setSelected(true);
				boolean isExist = false;
				for (Integer id : selectedRecords) {
					if (id == record.getFolderId()) {
						imgBg.setSelected(true);
						isExist = true;
						break;
					}
				}
				if (!isExist) {
					imgBg.setSelected(false);
				}
				helper.setText(R.id.item_tv_record_folder_name, record.getFolderName());
				helper.getView(R.id.item_record_from).setVisibility(View.GONE);
				helper.getView(R.id.ll_record_folder).setSelected(false);
				helper.getView(R.id.ll_record_folder).setSelected(false);
				helper.getView(R.id.tv_record_unrecong_count).setVisibility(View.GONE);
				helper.getView(R.id.record_from_cutline).setVisibility(View.GONE);
				if(record.getUnRecongCount() > 0){
					imgBg.setBackgroundResource(R.drawable.selector_img_record_have_unrec);
					helper.getView(R.id.ll_record_folder).setSelected(true);
					helper.getView(R.id.tv_record_unrecong_count).setVisibility(View.VISIBLE);
					if(record.getUnRecongCount() > 99){
						((TextView)helper.getView(R.id.tv_record_unrecong_count)).setText("99");
					}else{
						((TextView)helper.getView(R.id.tv_record_unrecong_count)).setText(record.getUnRecongCount()+"");
					}
				}else{
					imgBg.setBackgroundResource(R.drawable.selector_img_record_normal);
				}
				if(record.getFolderType() == RecordConstants.RECORD_TYPE_ADMISSION){
					//住院
					helper.setImageBitmap(R.id.item_img_record_type, R.drawable.record_type_zy);
				}else if(record.getFolderType() == RecordConstants.RECORD_TYPE_DOORCASE){
					//门诊
					helper.setImageBitmap(R.id.item_img_record_type, R.drawable.record_type_mz);
				}
				if(record.getSourceFrom() == RecordConstants.RECORD_FROM_OWN){
					helper.getView(R.id.item_record_from).setVisibility(View.GONE);
					helper.setText(R.id.item_record_from, "自己上传");
				}else{
					helper.getView(R.id.item_record_from).setVisibility(View.VISIBLE);
					helper.getView(R.id.record_from_cutline).setVisibility(View.VISIBLE);
					helper.setText(R.id.item_record_from, record.getSharePerson()+"分享");
				}
				
				String time = ("".equals(record.getCreateTime()))?"":record.getCreateTime().substring(0, 10);
				helper.setText(R.id.item_record_create_time, TimeFormatUtils.getTimeByStr(record.getCreateTime(), "yyyy/MM/dd"));
							
				surveyRecord.setOnClickListener(new OnClickListener() {
					//病历概览点击事件
					@Override
					public void onClick(View v) {
						getSurRecordItem(record.getFolderId());
					}
				});
			}
		});
		
		mItemAdapter = new CommonAdapter<SurveyRecordItem>(this,R.layout.item_survey_record) {
			
			@Override
			public void convert(int position, ViewHolder helper, SurveyRecordItem item) {
				View topView = helper.getView(R.id.item_survey_record_topview);
				View bottomView = helper.getView(R.id.item_survey_record_bottomview);
				View bottomLine = helper.getView(R.id.item_survey_record_bottomline);
				if (position%2 == 0) {
					topView.setVisibility(View.VISIBLE);
					bottomView.setVisibility(View.GONE);
					bottomLine.setVisibility(View.GONE);
				}else{
					topView.setVisibility(View.GONE);
					bottomView.setVisibility(View.VISIBLE);
					bottomLine.setVisibility(View.VISIBLE);
				}
				helper.setText(R.id.item_survey_record_key, item.getName());
				helper.setText(R.id.item_survey_record_value, item.getContent());
			}
		};
	}

	private void initListener() {
		mVisLayout.setOnClickListener(new OnClickListener() {
			//可视化点击事件
			@Override
			public void onClick(View view) {
				Intent intent = new Intent(SVisualizeRecordActivity.this, DataVisualizationActivity.class);
				data.setRecordIds(selectedRecords);
				intent.putExtra(DataVisualizationActivity.EXTRA, data);
				startActivity(intent);
			}
		});
		
		mRecordListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int position,
					long arg3) {
				Record record = mAdapter.getItem(position);
				boolean isExist = false;
				for (Integer id : selectedRecords) {
					if (id == record.getFolderId()) {
						isExist = true;
						selectedRecords.remove(id);
						break;
					}
				}
				if (!isExist) {
					selectedRecords.add(record.getFolderId());
				}
				mAdapter.notifyDataSetChanged();
			}
		});
		
		mSearchPatient.setSearchListener(new SearchListener() {
			//搜索的事件处理
			@Override
			public void searchChange(final String key) {
				return;
			}
			
			@Override
			public void searchCallback(String key) {
				if ("".equals(key)) {
					return;
				}
				getRecordList(key);
			}
		});
		
	}
	
	/**获取病历列表*/
	private void getRecordList(String searchKey){
		final CustomProgressDialog dialog = new CustomProgressDialog(this);
		dialog.setMessage("获取病历列表…");
		GetRecordListLogic logic = new GetRecordListLogic(new GetRecordListCallBack() {
			
			@Override
			public void onGetRecordListError(int code, String msg) {
				dialog.dismiss();
				UITools.showToast("获取病历列表失败");
			}
			
			@Override
			public void onGetRecordList(ArrayList<Record> mRecordList) {
				SVisualizeRecordActivity.this.mRecordList.clear();
				SVisualizeRecordActivity.this.mRecordList.addAll(mRecordList);
				mAdapter.addDatas(SVisualizeRecordActivity.this.mRecordList);
				for (Record record : mRecordList) {
					selectedRecords.add(record.getFolderId());
				}
				dialog.dismiss();
			}
		});
		logic.getRecordList(patientId,searchKey);
	}
	
	/**
	 * 获取病案的概览信息
	 * @param patientId
	 */
	public  void getSurRecordItem(final int recordId){
		CustomDialog dialog = new CustomDialog(SVisualizeRecordActivity.this);
		View view = LayoutInflater.from(SVisualizeRecordActivity.this).inflate(R.layout.view_overview_record, null, false);
		dialog.setOnlyContainer(view);
		final LoadingView loading = (LoadingView) view.findViewById(R.id.view_overview_record_loading);
		final ListView items = (ListView) view.findViewById(R.id.lv_overview_record_list);
		final TextView notice = (TextView) view.findViewById(R.id.tv_overview_record_notice);
		items.setAdapter(mItemAdapter);		
		mItemAdapter.cleanDatas();
		dialog.show();
		loading.startAnim();
		loading.setVisibility(View.VISIBLE);
		SurveyRecordLogic logic = new SurveyRecordLogic(new SurveyRecordCallBack() {
			
			@Override
			public void onSurveyResult(int code, ArrayList<SurveyRecordItem> surItemList) {
				loading.stopAnim();
				loading.setVisibility(View.GONE);
				if (surItemList.size() == 0) {
					loading.setVisibility(View.GONE);
					notice.setText("没有概览信息");
					notice.setVisibility(View.VISIBLE);
					items.setVisibility(View.GONE);
					return;
				}
				mItemAdapter.addDatas(surItemList);
				notice.setVisibility(View.GONE);
			}
			
			@Override
			public void onSurveyError(int code, String msg) {
				loading.stopAnim();
				loading.setVisibility(View.GONE);
				notice.setText("获取概览信息失败");
				notice.setVisibility(View.VISIBLE);
				items.setVisibility(View.GONE);
			}
		});
		logic.surveyRecord(recordId);
	}

}
