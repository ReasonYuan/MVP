package com.fq.android.patient;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.text.InputFilter;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Patient;
import com.fq.halcyon.entity.SurveyPatientItem;
import com.fq.halcyon.logic2.CreatePatientLogic;
import com.fq.halcyon.logic2.CreatePatientLogic.CreateMedicalCallBack;
import com.fq.halcyon.logic2.DelPatientLogic;
import com.fq.halcyon.logic2.DelPatientLogic.DelMedicalCallBack;
import com.fq.halcyon.logic2.ModifyPatientNameLogic;
import com.fq.halcyon.logic2.ModifyPatientNameLogic.ModifyPatientNameCallBack;
import com.fq.halcyon.logic2.SearchPatientLogic;
import com.fq.halcyon.logic2.SearchPatientLogic.SearchMedicalCallBack;
import com.fq.halcyon.logic2.SurveyPatientLogic;
import com.fq.halcyon.logic2.SurveyPatientLogic.SurveyPatientCallBack;
import com.fq.lib.record.RecordConstants;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.hp.android.halcyon.RecordListActivity;
import com.hp.android.halcyon.SelectShareFriendActivity;
import com.hp.android.halcyon.adapter.PatientListAdapter;
import com.hp.android.halcyon.adapter.PatientListAdapter.OverviewClickListener;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.view.LoadingView;
import com.hp.android.halcyon.view.PatientCtrlView;
import com.hp.android.halcyon.view.PatientCtrlView.PatiantCtrlViewClickListener;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.CustomProgressDialog;
import com.hp.android.halcyon.widgets.SearchView;

public class PatientListCtrl {

	private Context context;
	private ArrayList<Patient> mPatientList;
	private PatientListAdapter mAdapter;
	private CommonAdapter<SurveyPatientItem> mItemAdapter;
	private int page = 1;
	private int pageSize = 20;
	/**
	 * 标记是否处于编辑模式
	 */
	private boolean mIsModify = false;
	/**
	 * 标记是否有改动
	 */
	private boolean mHaveModify = false;
	private Patient mSelectedPatient;
	private int mSelectedPosition = -1;
	private PatientCtrlView mPatientCtrlView;
	
	public PatientListCtrl(Context context, PatientCtrlView mPatientCtrlView) {
		this.context = context;
		this.mPatientCtrlView = mPatientCtrlView;
		mPatientList = new ArrayList<Patient>();
		mAdapter = new PatientListAdapter(context);
		mItemAdapter = new CommonAdapter<SurveyPatientItem>(context, R.layout.item_survey_patient) {
			
			@Override
			public void convert(int position, ViewHolder helper,
					SurveyPatientItem item) {
				helper.setText(R.id.item_survey_patient_name, item.getPatientName());
				helper.setText(R.id.item_survey_patient_diagnosis, item.getTentativeDiag());
			}
		};
		mAdapter.onOverviewClickListener(new OverviewClickListener() {
			//概览的点击事件
			@Override
			public void onClickListener(Patient patient) {
				getSurPatientItem(patient.getMedicalId(), patient.getRecordCount());
			}
		});
		
		mPatientCtrlView.setPatiantCtrlViewClickListener(new PatiantCtrlViewClickListener() {
			//操作病案的事件处理
			@Override
			public void shareCallBack() {
				//分享
				sharePatient(mSelectedPatient);
			}
			
			@Override
			public void renameCallBack() {
				//重命名
				modifyName(mSelectedPatient);
			}
			
			@Override
			public void deleteCallBack() {
				//删除
				delPatient(mSelectedPatient.getMedicalId(), mSelectedPosition);
			}
		});
	}
	
	public boolean isModify(){
		return mIsModify;
	}
	
	public PatientListAdapter getAdapter() {
		return mAdapter;
	}
	
	public Patient getSelectedPatient() {
		return mSelectedPatient;
	}

	public void setSelectedPatient(Patient mSelectedPatient) {
		this.mSelectedPatient = mSelectedPatient;
	}

	public int getSelectedPosition() {
		return mSelectedPosition;
	}

	public void setSelectedPosition(int mSelectedPosition) {
		this.mSelectedPosition = mSelectedPosition;
	}

	public ArrayList<Patient> getPatientList(){
		return mPatientList;
	}
	
	public void setPage(int page) {
		this.page = page;
	}
	
	public boolean isHaveModify() {
		return mHaveModify;
	}

	public void setHaveModify(boolean mHaveModify) {
		this.mHaveModify = mHaveModify;
	}

	/**
	 * 获取病历列表
	 * @param mAddNotice
	 * @param mListViewPatient
	 */
	public void getPatientListLogic(String key,final TextView mAddNotice, final PullToRefreshListView mListViewPatient){
		final CustomProgressDialog dialog = new CustomProgressDialog(context);
		dialog.setMessage("获取病案…");
		SearchPatientLogic logic = new SearchPatientLogic(new SearchMedicalCallBack() {
			
			@Override
			public void onSearchMedicalResult(ArrayList<Patient> medicalList) {
				mPatientList.addAll(medicalList);
				mAdapter.addDatas(mPatientList);
				dialog.dismiss();
				mListViewPatient.onRefreshComplete();
				if (medicalList.size() > 0) {
					page++;
					mAddNotice.setVisibility(View.GONE);
				}else{
					if (page == 1) {
						mAddNotice.setVisibility(View.VISIBLE);
					}else{
						UITools.showToast("没有更多病案");
						mAddNotice.setVisibility(View.GONE);
					}
				}
			}
			
			@Override
			public void onSearchMedicalError(int code, String msg) {
				UITools.showToast("获取病案失败！");
				dialog.dismiss();
				mListViewPatient.onRefreshComplete();
			}
		});
		logic.searchMedical(key,page,pageSize);
	}
	
	/**
	 * 获取病案的概览信息
	 * @param patientId
	 * @param recordCount
	 */
	public  void getSurPatientItem(final int patientId, int recordCount){
		CustomDialog dialog = new CustomDialog(context);
		View view = LayoutInflater.from(context).inflate(R.layout.view_overview_patient, null, false);
		dialog.setOnlyContainer(view);
		final LoadingView loading = (LoadingView) view.findViewById(R.id.view_overview_patient_loading);
		final ListView items = (ListView) view.findViewById(R.id.lv_overview_patient_list);
		final TextView notice = (TextView) view.findViewById(R.id.tv_overview_patient_notice);
		items.setAdapter(mItemAdapter);
		mItemAdapter.cleanDatas();
		dialog.show();
		if (recordCount == 0) {
			notice.setText("没有概览信息");
			notice.setVisibility(View.VISIBLE);
			items.setVisibility(View.GONE);
			return;
		}
		loading.startAnim();
		loading.setVisibility(View.VISIBLE);
		getSurPatientLogic(patientId, loading, items, notice);
	}

	/**
	 * 获取病案概览信息的逻辑
	 * @param patientId
	 * @param loading
	 * @param items
	 * @param notice
	 */
	private void getSurPatientLogic(final int patientId,
			final LoadingView loading, final ListView items,
			final TextView notice) {
		SurveyPatientLogic logic = new SurveyPatientLogic(new SurveyPatientCallBack() {
				
			@Override
			public void onSurveyResult(int code,ArrayList<SurveyPatientItem> surItemList) {
				loading.stopAnim();
				loading.setVisibility(View.GONE);
				if (surItemList.size() == 0) {
					notice.setVisibility(View.VISIBLE);
					items.setVisibility(View.GONE);
					notice.setText("没有概览信息");
				}else{
					notice.setVisibility(View.GONE);
					items.setVisibility(View.VISIBLE);
					mItemAdapter.addDatas(surItemList);
				}
			}
				
			@Override
			public void onSurveyError(int code, String msg) {
				loading.stopAnim();
				loading.setVisibility(View.GONE);
				notice.setText("获取概览信息失败");
				notice.setVisibility(View.VISIBLE);
			}
		});
		logic.surveyPatient(patientId);
	}
	
	/**
	 * 删除病案
	 * @param patientId
	 * @param position
	 */
	public void delPatient(final int patientId,final int position){
		final CustomDialog dialog = new CustomDialog(context);
		View delView = LayoutInflater.from(context).inflate(R.layout.view_delete_item, null);
		dialog.setOnlyContainer(delView);
		dialog.setCanceledOnTouchOutside(false);
		Button btnSure = (Button) delView.findViewById(R.id.btn_delete_item_sure);
		Button btnCancel = (Button) delView.findViewById(R.id.btn_delete_item_cancel);
		
		btnCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				dialog.dismiss();
			}
		});
		
		btnSure.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				delPatientLogic(patientId, position, dialog);
			}
		});
	}

	/**
	 * 删除病案的逻辑
	 * @param patientId
	 * @param position
	 * @param dialog
	 */
	private void delPatientLogic(final int patientId, final int position,final CustomDialog dialog) {
		final CustomProgressDialog proDialog = new CustomProgressDialog(context);
		proDialog.setMessage("删除病案……");
		DelPatientLogic logic = new DelPatientLogic(new DelMedicalCallBack() {
			
			@Override
			public void onDelMedicalSuccess(int code, String msg) {
				mHaveModify = true;
				mPatientList.remove(position);
				mAdapter.notifyDataSetChanged();
				setModifyStatus(false);
				dialog.dismiss();
				proDialog.dismiss();
			}
			
			@Override
			public void onDelMedicalError(int code, String msg) {
				dialog.dismiss();
				proDialog.dismiss();
				UITools.showToast("删除病案失败");
			}
		});
		logic.delMedical(patientId);
	}
	
	/**
	 * 新增病案
	 * @param name
	 * @param mAddNotice
	 * @param mSearchPatient
	 */
	public void createPatient(String name,final TextView mAddNotice,final SearchView mSearchPatient){
		final CustomProgressDialog dialog = new CustomProgressDialog(context);
		dialog.setMessage("创建病案…");
		CreatePatientLogic logic = new CreatePatientLogic(new CreateMedicalCallBack() {
			
			@Override
			public void createMedicalSuccess(int code, Patient medical) {
				if(mSearchPatient.getSearchStatus()){
					mSearchPatient.startViewAnimOut();
				}
				mPatientList.add(0, medical);
				mAddNotice.setVisibility(View.GONE);
				mAdapter.addDatas(mPatientList);
				dialog.dismiss();
				Intent intent = new Intent();
				intent.putExtra("patientName", medical.getMedicalName());
				intent.putExtra("patientId", medical.getMedicalId());
				intent.putExtra("isCreateNewPatient", true);
				intent.setClass(context, RecordListActivity.class);
				((Activity)context).startActivityForResult(intent, 100);
			}
			
			@Override
			public void createMedicalError(int code, String msg) {
				dialog.dismiss();
				UITools.showToast("创建病案失败");
			}
		});
		logic.createMedical(name);
	}
	
	/**
	 * 修改病案名字
	 * @param mPatient
	 */
	public void modifyName(final Patient mPatient){
		final CustomDialog dialog = new CustomDialog(context);
		View viewCreate = LayoutInflater.from(context).inflate(R.layout.view_create_patient, null);
		dialog.setOnlyContainer(viewCreate);
		dialog.setCanceledOnTouchOutside(false);    
		final EditText editName = (EditText) viewCreate.findViewById(R.id.edit_create_patient_name);
		TextView title = (TextView) viewCreate.findViewById(R.id.edit_create_title);
		title.setText("重命名");
		editName.setHint("");
		editName.setText(mPatient.getMedicalName());
		editName.setFilters(new InputFilter[]{new InputFilter.LengthFilter(25)});//限定输入的字数最大为25
		Button btnSure = (Button) viewCreate.findViewById(R.id.btn_create_patient_sure);
		Button btnCancel = (Button) viewCreate.findViewById(R.id.btn_create_patient_cancel);
		btnSure.setText("确认");
		btnCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				dialog.dismiss();
			}
		});
		btnSure.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				final String str = editName.getText().toString().trim();
				if (!"".equals(str)) {
					modifyNameLogic(mPatient, str);
				}
				dialog.dismiss();
			}
		});
	}

	/**
	 * 修改病历名字的逻辑
	 * @param mPatient
	 * @param str
	 */
	private void modifyNameLogic(final Patient mPatient, final String str) {
		ModifyPatientNameLogic logic = new ModifyPatientNameLogic(new ModifyPatientNameCallBack() {
			
			@Override
			public void modifyNameSuccess(int code, String msg) {
				mHaveModify = true;
				for (int i = 0; i < mPatientList.size(); i++) {
					Patient patient = mPatientList.get(i);
					if(patient.getMedicalId() == mPatient.getMedicalId()){
						patient.setMedicalName(str);
						break;
					}
				}
				mAdapter.notifyDataSetChanged();
			}
			
			@Override
			public void modifyNameError(int code, String msg) {
				UITools.showToast("重命名失败");
			}
		});
		logic.modifyName(mPatient.getMedicalId(), str);
	}	
	
	/**
	 * 分享病案
	 * @param patient
	 */
	public void sharePatient(Patient patient){
		Intent intent = new Intent(context, SelectShareFriendActivity.class);
		intent.putExtra("sharePatient", patient);
		intent.putExtra("shareType", RecordConstants.SHARE_PATIENT);
		context.startActivity(intent);
	}
	
	/**
	 * 设置是否是编辑状态
	 * @param status
	 */
	public void setModifyStatus(boolean status){
		if (!status) {
			mPatientCtrlView.hidden();
			mSelectedPosition = -1;
			mAdapter.setItemSelected(-1);
		}else{
			mPatientCtrlView.show();
		}
		this.mIsModify = status;
	}
}
