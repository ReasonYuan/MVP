package com.hp.android.halcyon;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.text.InputFilter;
import android.text.format.DateUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.Button;
import android.widget.EditText;
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
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.SearchView;
import com.hp.android.halcyon.widgets.SearchView.CloseClickListenerCallBack;
import com.hp.android.halcyon.widgets.SearchView.SearchListener;
/**
 * 云病案库显示的Activity
 */
@SuppressLint("HandlerLeak")
public class PatientListActivity extends BaseActivity{

	private SearchView mSearchPatient;
	private PullToRefreshListView mListViewPatient;
	private ListView actualListView;
	private PatientCtrlView mPatientCtrlView;
	private TextView mAddNotice;
	private View mHintCtrlView;
	private PatientListCtrl mPatientListCtrl;
	@Override
	public int getContentId() {
		return R.layout.activity_medical_list;
	}

	@Override
	public void init() {
		initWidgets();
		initListener();
	}

	private void initWidgets() {
		setTitle("云病例库");
		setTopRightImgSrc(R.drawable.btn_add_icon);
		mPatientCtrlView = getView(R.id.view_patientctril);
		mHintCtrlView = getView(R.id.view_patient_hint_ctrl);
		mListViewPatient = (PullToRefreshListView) findViewById(R.id.plv_medical_list);
		actualListView = mListViewPatient.getRefreshableView();
		mListViewPatient.setMode(Mode.PULL_FROM_END);
		mSearchPatient = (SearchView) findViewById(R.id.sv_medical_search);
		mAddNotice = getView(R.id.tv_have_not_patient_notice);
		mPatientListCtrl = new PatientListCtrl(this, mPatientCtrlView);
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
					if (patient.getRecordCount() == 0) {
						intent.putExtra("isCreateNewPatient", true);
					}
					intent.setClass(PatientListActivity.this, RecordListActivity.class);
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
				intent.setClass(PatientListActivity.this, SearchPatientActivity.class);
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
	
		mListViewPatient.setOnClickListener(new OnClickListener() {
			//设置点击空白处隐藏控制按钮
			@Override
			public void onClick(View v) {
				if (mPatientListCtrl.isModify()) {
					mPatientListCtrl.setModifyStatus(false);
					mPatientListCtrl.getAdapter().notifyDataSetChanged();
				}
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
	public void onTopRightBtnClick(View view) {
		//右上角创建病案
		createPatient();
	}

	/**
	 * 创建新的病案
	 */
	private void createPatient() {
		mPatientListCtrl.setModifyStatus(false);
		final CustomDialog dialog = new CustomDialog(this);
		View viewCreate = LayoutInflater.from(this).inflate(R.layout.view_create_patient, null);
		dialog.setOnlyContainer(viewCreate);
		dialog.setCanceledOnTouchOutside(false);    
		final EditText editName = (EditText) viewCreate.findViewById(R.id.edit_create_patient_name);
		editName.setFilters(new InputFilter[]{new InputFilter.LengthFilter(25)});//限定输入的字数最大为25
		Button btnSure = (Button) viewCreate.findViewById(R.id.btn_create_patient_sure);
		Button btnCancel = (Button) viewCreate.findViewById(R.id.btn_create_patient_cancel);
		btnCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				dialog.dismiss();
			}
		});
		btnSure.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				String str = editName.getText().toString().trim();
				if (!"".equals(str)) {
					mPatientListCtrl.createPatient(str, mAddNotice, mSearchPatient);
				}
				dialog.dismiss();
			}
		});
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode == IntentKey.RECORD_LIST_HAS_MODIFY) {
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
		}else if (resultCode == IntentKey.SEARCH_PATIENT_HAVE_MODIFY) {
			mPatientListCtrl.setPage(1);
			mPatientListCtrl.getAdapter().clearDatas();
			mPatientListCtrl.getPatientListLogic("", mAddNotice, mListViewPatient);
		}
	}
	
	@Override
	public void onTopLeftBtnClick(View view) {
		if (mSearchPatient.getSearchStatus()) {
			mSearchPatient.startViewAnimOut();
		}
		mPatientListCtrl.setModifyStatus(false);
		finish();
	}
	
	@Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
        	//检测回退按钮，如果是编辑状态则取消编辑状态，如果不是则直接返回上一层
        	if (mPatientListCtrl.isModify()) {
				mPatientListCtrl.setModifyStatus(false);
			}else{
				finish();
			}
            return false;
        }
        return false;
    }

}
