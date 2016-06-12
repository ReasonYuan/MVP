package com.hp.android.halcyon;

import android.content.Intent;
import android.text.format.DateUtils;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.patient.PatientListCtrl;
import com.fq.android.plus.R;
import com.fq.halcyon.entity.Patient;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshBase.Mode;
import com.handmark.pulltorefresh.library.PullToRefreshBase.OnRefreshListener2;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.hp.android.halcyon.util.IntentKey;
import com.hp.android.halcyon.view.PatientCtrlView;
import com.hp.android.halcyon.widgets.SearchView;
import com.hp.android.halcyon.widgets.SearchView.CloseClickListenerCallBack;
import com.hp.android.halcyon.widgets.SearchView.SearchListener;

public class SearchPatientActivity extends BaseActivity{

	private SearchView mSearchView;
	private PullToRefreshListView mPatientList;
	private String searchKey;
	private PatientListCtrl mPatientListCtrl;
	private PatientCtrlView mPatientCtrlView;
	private TextView mAddNotice;
	private PullToRefreshListView mListViewPatient;
	private ListView actualListView;
	private View mHintCtrlView;
	
	@Override
	public int getContentId() {
		return R.layout.activity_medical_list;
	}

	@Override
	public void init() {
		initWidgets();
		initListener();
		initDatas();
	}

	private void initWidgets() {
		setTitle("搜索病案");
		mSearchView = getView(R.id.sv_medical_search);
		mPatientList = getView(R.id.plv_medical_list);
		mPatientCtrlView = getView(R.id.view_patientctril);
		mListViewPatient = getView(R.id.plv_medical_list);
		mAddNotice = getView(R.id.tv_have_not_patient_notice);
		mHintCtrlView = getView(R.id.view_patient_hint_ctrl);
		actualListView = mListViewPatient.getRefreshableView();
		mListViewPatient.setMode(Mode.PULL_FROM_END);
		mPatientListCtrl = new PatientListCtrl(this, mPatientCtrlView);
		mAddNotice.setText("没有搜索到相匹配的结果");
	}
	
	private void initDatas() {
		actualListView.setAdapter(mPatientListCtrl.getAdapter());
		searchKey = getIntent().getStringExtra(IntentKey.SEARCH_KEY);
		mPatientListCtrl.getPatientListLogic(searchKey, mAddNotice, mListViewPatient);
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
					mPatientListCtrl.getPatientListLogic(searchKey,mAddNotice, mListViewPatient);
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
					if (patient.getRecordCount() == 0) {
						intent.putExtra("isCreateNewPatient", true);
					}
					intent.setClass(SearchPatientActivity.this, RecordListActivity.class);
					startActivityForResult(intent, 100);
				}
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
					if (patient.getRecordCount() == 0) {
						intent.putExtra("isCreateNewPatient", true);
					}
					intent.setClass(SearchPatientActivity.this, RecordListActivity.class);
					startActivityForResult(intent, 100);
				}
			}
		});
		
		actualListView.setOnItemLongClickListener(new OnItemLongClickListener() {
			//病案Item长按事件
			@Override
			public boolean onItemLongClick(AdapterView<?> parent, View view,
					int position, long id) {
				mPatientListCtrl.setSelectedPatient((Patient)mPatientListCtrl.getAdapter().getItem(position - 1));
				mPatientListCtrl.setSelectedPosition(position - 1);
				mPatientListCtrl.getAdapter().setItemSelected(position - 1);
				mPatientListCtrl.setModifyStatus(true);
				return true;
			}
		});
		
		mSearchView.setSearchListener(new SearchListener() {
			//搜索的事件处理
			@Override
			public void searchChange(final String key) {
				return;
			}
			
			@Override
			public void searchCallback(String key) {
				mPatientListCtrl.setModifyStatus(false);
				mPatientListCtrl.getAdapter().clearDatas();
				searchKey = key;
				mPatientListCtrl.setPage(1);
				mPatientListCtrl.getPatientListLogic(key, mAddNotice, mListViewPatient);
			}
		});
		
		mSearchView.onCloseClickListener(new CloseClickListenerCallBack() {
			//搜索关闭的点击事件
			@Override
			public void onClick() {
				mPatientListCtrl.setModifyStatus(false);
			}
		});
		
		mHintCtrlView.setOnTouchListener(new OnTouchListener() {
			//设置点击空白处隐藏控制按钮
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				if (mPatientListCtrl.isModify()) {
					mPatientListCtrl.setModifyStatus(false);
					return true;
				}
				return false;
			}
		});
	}
	
	@Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
        	//检测回退按钮，如果是编辑状态则取消编辑状态，如果不是则直接返回上一层
        	if (mPatientListCtrl.isModify()) {
				mPatientListCtrl.setModifyStatus(false);
			}else{
				setFinishResult();
				finish();
			}
            return false;
        }
        return false;
    }
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode == IntentKey.RECORD_LIST_HAS_MODIFY) {
			mPatientListCtrl.setHaveModify(true);
			int patientId = data.getIntExtra("patientId", 0);
			int recordCount = data.getIntExtra("recordCount", 0);
			for (int i = 0; i < mPatientListCtrl.getPatientList().size(); i++) {
				Patient patient = mPatientListCtrl.getPatientList().get(i);
				if(patient.getMedicalId() == patientId ){
					patient.setRecordCount(recordCount);
					break;
				}
			}
			mPatientListCtrl.getAdapter().notifyDataSetChanged();
		}
	}
	
	@Override
	public void onTopLeftBtnClick(View view) {
		setFinishResult();
		finish();
	}
	
	protected void setFinishResult() {
		if (mPatientListCtrl.isHaveModify()) {
			setResult(IntentKey.SEARCH_PATIENT_HAVE_MODIFY);
		}
	}
}
