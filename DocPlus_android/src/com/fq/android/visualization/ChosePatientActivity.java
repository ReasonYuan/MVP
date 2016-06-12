package com.fq.android.visualization;

import android.content.Intent;
import android.text.format.DateUtils;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.patient.PatientListCtrl;
import com.fq.android.plus.R;
import com.fq.halcyon.entity.Patient;
import com.fq.halcyon.entity.visualize.VisualData;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshBase.Mode;
import com.handmark.pulltorefresh.library.PullToRefreshBase.OnRefreshListener2;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.util.IntentKey;
import com.hp.android.halcyon.view.PatientCtrlView;
import com.hp.android.halcyon.widgets.SearchView;
import com.hp.android.halcyon.widgets.SearchView.CloseClickListenerCallBack;
import com.hp.android.halcyon.widgets.SearchView.SearchListener;

public class ChosePatientActivity extends BaseActivity{

	private SearchView mSearchPatient;
	private PullToRefreshListView mListViewPatient;
	private ListView actualListView;
	private PatientCtrlView mPatientCtrlView;
	private TextView mAddNotice;
	private PatientListCtrl mPatientListCtrl;
	
	@Override
	public int getContentId() {
		return R.layout.activity_medical_list;
	}

	@Override
	public void init() {
		setTitle("请选择病案");
		initWidgets();
		initListener();
	}

	private void initWidgets() {
		mPatientCtrlView = getView(R.id.view_patientctril);
		mListViewPatient = (PullToRefreshListView) findViewById(R.id.plv_medical_list);
		actualListView = mListViewPatient.getRefreshableView();
		mListViewPatient.setMode(Mode.PULL_FROM_END);
		mSearchPatient = (SearchView) findViewById(R.id.sv_medical_search);
		mAddNotice = getView(R.id.tv_have_not_patient_notice);
		mPatientListCtrl = new PatientListCtrl(this, mPatientCtrlView);
		mAddNotice.setText("当前还没有病案，\n赶快去创建吧！");
		mPatientListCtrl.getPatientListLogic("",mAddNotice, mListViewPatient);
		actualListView.setAdapter(mPatientListCtrl.getAdapter());
	}

	private void initListener() {
		mListViewPatient.setOnRefreshListener(new OnRefreshListener2<ListView>() {
			//上拉加载更多事件处理
			@Override
			public void onPullDownToRefresh(PullToRefreshBase<ListView> refreshView) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onPullUpToRefresh(PullToRefreshBase<ListView> refreshView) {
				String label = DateUtils.formatDateTime(getApplicationContext(), System.currentTimeMillis(),
						DateUtils.FORMAT_SHOW_TIME | DateUtils.FORMAT_SHOW_DATE | DateUtils.FORMAT_ABBREV_ALL);
				refreshView.getLoadingLayoutProxy().setLastUpdatedLabel(label);
					mPatientListCtrl.getPatientListLogic("",mAddNotice, mListViewPatient);
			}
		});
		
		mListViewPatient.setOnItemClickListener(new OnItemClickListener() {
			//病案item点击事件
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				if (mPatientListCtrl.isModify()) {
					mPatientListCtrl.setModifyStatus(false);
				}else{
					Patient patient = (Patient) mPatientListCtrl.getAdapter().getItem(position - 1);
					Intent intent = new Intent();
					intent.putExtra("patientName", patient.getMedicalName());
					intent.putExtra("patientId", patient.getMedicalId());
					
					VisualData data = (VisualData) ChosePatientActivity.this.getIntent().getSerializableExtra("extra");
					intent.putExtra("extra", data);
					
					if (patient.getRecordCount() == 0) {
						intent.putExtra("isCreateNewPatient", true);
					}
					mPatientListCtrl.setSelectedPosition(position - 1);
					mPatientListCtrl.getAdapter().setItemSelected(position - 1);
					intent.setClass(ChosePatientActivity.this, ChoseRecordActivity.class);
					startActivityForResult(intent, 100);
				}
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
				mPatientListCtrl.setModifyStatus(false);
				if ("".equals(key)) {
					return;
				}
				Intent intent = new Intent();
				intent.putExtra(IntentKey.SEARCH_KEY, key);
				intent.setClass(ChosePatientActivity.this, SVisualizePatientActivity.class);
				startActivityForResult(intent, 300);
			}
		});
		
		mSearchPatient.onCloseClickListener(new CloseClickListenerCallBack() {
			//搜索关闭的点击事件
			@Override
			public void onClick() {
				mPatientListCtrl.setModifyStatus(false);
			}
		});
	}
}
