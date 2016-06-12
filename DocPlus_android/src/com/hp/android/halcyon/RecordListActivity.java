package com.hp.android.halcyon;

import java.util.ArrayList;

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
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Record;
import com.fq.halcyon.entity.SurveyRecordItem;
import com.fq.halcyon.logic2.CreateRecordLogic;
import com.fq.halcyon.logic2.CreateRecordLogic.CreateRecordFolderCallBack;
import com.fq.halcyon.logic2.DelRecordLogic;
import com.fq.halcyon.logic2.DelRecordLogic.DelRecordFolderCallBack;
import com.fq.halcyon.logic2.GetRecordListLogic;
import com.fq.halcyon.logic2.GetRecordListLogic.GetRecordListCallBack;
import com.fq.halcyon.logic2.ModifyRecordNameLogic;
import com.fq.halcyon.logic2.ModifyRecordNameLogic.ModifyRecordNameCallBack;
import com.fq.halcyon.logic2.SurveyRecordLogic;
import com.fq.halcyon.logic2.SurveyRecordLogic.SurveyRecordCallBack;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.TimeFormatUtils;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshBase.Mode;
import com.handmark.pulltorefresh.library.PullToRefreshBase.OnRefreshListener2;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.hp.android.halcyon.util.IntentKey;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.view.LoadingView;
import com.hp.android.halcyon.view.PatientCtrlView;
import com.hp.android.halcyon.view.PatientCtrlView.PatiantCtrlViewClickListener;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.CustomProgressDialog;
/**
 * 获取病历列表
 * @author Chengxu Zhou
 *
 */
public class RecordListActivity extends BaseActivity{

	private PullToRefreshListView mFolderListView;
	private View mViewHintCtrl;
	private CommonAdapter<Record> mAdapter;
	private ArrayList<Record> mRecordList;
	private ListView actualListView;
	private int patientId;
	private int mOldRecordCount;
	private int page = 1;
	private int pageSize = 20;
	private int mCtrlPosition = -1;
	private PatientCtrlView mPatientCtrlView;
	private CommonAdapter<SurveyRecordItem> mItemAdapter;
	private boolean isModifty = false;
	
	@Override
	public int getContentId() {
		return R.layout.activity_record_folder_list;
	}

	@Override
	public void init() {
		patientId = getIntent().getIntExtra("patientId", 0);
		
		initWidgets();
		initListener();
		boolean isNewPatient = getIntent().getBooleanExtra("isCreateNewPatient", false);
		if (!isNewPatient) {
			//如果是新创建的病案，则不调用接口获取数据
			getRecordList();
		}else{
			page = 2;
		}
	}

	private void initWidgets() {
		String title = getIntent().getStringExtra("patientName");
		setTitle(title);
		setTopRightImgSrc(R.drawable.btn_add_icon);
		mPatientCtrlView = getView(R.id.view_record_pc);
		mViewHintCtrl = getView(R.id.v_record_folder_hint_ctrl);
		mRecordList = new ArrayList<Record>();
		mFolderListView = (PullToRefreshListView) findViewById(R.id.lv_record_folder);
		mFolderListView.setMode(Mode.PULL_FROM_END);
		actualListView = mFolderListView.getRefreshableView();
		actualListView.setAdapter(mAdapter = new CommonAdapter<Record>(this,R.layout.item_record_folder) {
			
			@Override
			public void convert(final int position,ViewHolder helper, final Record record) {

				TextView surveyRecord = helper.getView(R.id.item_tv_record_overview);
				ImageView imgBg = helper.getView(R.id.img_item_record_bg);
				if (mCtrlPosition == position) {
					imgBg.setSelected(true);
				}else{
					imgBg.setSelected(false);
				}
				helper.setText(R.id.item_tv_record_folder_name, record.getFolderName());
				helper.getView(R.id.item_record_from).setVisibility(View.GONE);
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
							
				mPatientCtrlView.setPatiantCtrlViewClickListener(new PatiantCtrlViewClickListener() {
					
					@Override
					public void shareCallBack() {
						Intent intent = new Intent(RecordListActivity.this, SelectShareFriendActivity.class);
						intent.putExtra("shareType", RecordConstants.SHARE_RECORD);
						intent.putExtra("shareRecord", mAdapter.getItem(mCtrlPosition));
						startActivity(intent);
					}
					
					@Override
					public void renameCallBack() {
						renameRecordName(mAdapter.getItem(mCtrlPosition),mCtrlPosition);
					}
					
					@Override
					public void deleteCallBack() {
						delRecord(mAdapter.getItem(mCtrlPosition).getFolderId(),mCtrlPosition);
					}
				});
				surveyRecord.setOnClickListener(new OnClickListener() {
					//病历概览点击事件
					@Override
					public void onClick(View v) {
						getSurRecordItem(record.getFolderId());
					}
				});
			}
		});
		mAdapter.addDatas(mRecordList);
		
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
	
	private void initListener(){
		
		mFolderListView.setOnRefreshListener(new OnRefreshListener2<ListView>() {

			@Override
			public void onPullDownToRefresh(
					PullToRefreshBase<ListView> refreshView) {
				
			}

			@Override
			public void onPullUpToRefresh(
					PullToRefreshBase<ListView> refreshView) {
				String label = DateUtils.formatDateTime(getApplicationContext(), System.currentTimeMillis(),
						DateUtils.FORMAT_SHOW_TIME | DateUtils.FORMAT_SHOW_DATE | DateUtils.FORMAT_ABBREV_ALL);
				refreshView.getLoadingLayoutProxy().setLastUpdatedLabel(label);
				getRecordList();
			}
		});
		
		mFolderListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				if (isModifty) {
					setModifyStatus(false);
					return;
				}
				if (mCtrlPosition != -1) {
					setModifyStatus(false);
					mAdapter.notifyDataSetChanged();
					return;
				}
				Record record = mAdapter.getItem(position - 1);
				Intent intent = new Intent(RecordListActivity.this,BrowRecordActivity2.class);
				intent.putExtra("docType", record.getFolderType());
				intent.putExtra("docName", record.getFolderName());
				intent.putExtra("docId", record.getFolderId());
				startActivity(intent);
			}
		});
		
		actualListView.setOnItemLongClickListener(new OnItemLongClickListener() {
			//长按控制控制按钮的显示
			@Override
			public boolean onItemLongClick(AdapterView<?> parent, View view,
					int position, long id) {
				setModifyStatus(true);
				mCtrlPosition = position - 1;
				mAdapter.notifyDataSetChanged();
				mPatientCtrlView.show();
				return true;
			}
		});
		
		mViewHintCtrl.setOnTouchListener(new OnTouchListener() {
			@Override
			public boolean onTouch(View arg0, MotionEvent arg1) {
				if (isModifty) {
					setModifyStatus(false);
					return true;
				}
				return false;
			}
		});
	}
	
	/**获取病历列表*/
	private void getRecordList(){
		final CustomProgressDialog dialog = new CustomProgressDialog(this);
		dialog.setMessage("获取病历列表…");
		GetRecordListLogic logic = new GetRecordListLogic(new GetRecordListCallBack() {
			
			@Override
			public void onGetRecordListError(int code, String msg) {
				dialog.dismiss();
				UITools.showToast("获取病历列表失败");
				mFolderListView.onRefreshComplete();
			}
			
			@Override
			public void onGetRecordList(ArrayList<Record> mRecordList) {
				mFolderListView.onRefreshComplete();
				if (mRecordList.size() > 0) {
					page++;
				}else{
					UITools.showToast("没有更多病历");
				}
				RecordListActivity.this.mRecordList.addAll(mRecordList);
				mOldRecordCount = mRecordList.size();
				mAdapter.addDatas(RecordListActivity.this.mRecordList);
				dialog.dismiss();
			}
		});
		logic.getRecordList(patientId,page,pageSize);
//		logic.getRecordList(patientId);
	}
	
	/**创建病历*/
	private void createRecord(Record record){
		final CustomProgressDialog dialog = new CustomProgressDialog(this);
		dialog.setMessage("创建病历…");
		CreateRecordLogic logic = new CreateRecordLogic(new CreateRecordFolderCallBack() {
			
			@Override
			public void onCreateFolderSuccess(int code, Record record) {
				mRecordList.add(0, record);
				mAdapter.notifyDataSetChanged();
				dialog.dismiss();
			}
			
			@Override
			public void onCreateFolderError(int code, String msg) {
				dialog.dismiss();
				UITools.showToast("创建病历失败");
			}
		});
		logic.createRecordFolder(record.getFolderName(),patientId,record.getFolderType());
	}
	
	/**删除病历*/
	private void delRecord(final int recordId, final int position){
		final CustomDialog dialog = new CustomDialog(this);
		View delView = LayoutInflater.from(this).inflate(R.layout.view_delete_item, null);
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
				final CustomProgressDialog proDialog = new CustomProgressDialog(RecordListActivity.this);
				proDialog.setMessage("删除病历…");
				DelRecordLogic logic = new DelRecordLogic(new DelRecordFolderCallBack() {
					
					@Override
					public void onDelFolderSuccess(int code, String msg) {
						mRecordList.remove(position);
						setModifyStatus(false);
						dialog.dismiss();
						proDialog.dismiss();
					}
					
					@Override
					public void onDelFolderError(int code, String msg) {
						dialog.dismiss();
						proDialog.dismiss();
						setModifyStatus(false);
						UITools.showToast("删除病历失败");
					}
				});
				logic.delRecordFolder(recordId);
			}
		});
	}
	
	private void renameRecordName(final Record record, final int position){
		final CustomDialog dialog = new CustomDialog(this);
		View viewCreate = LayoutInflater.from(this).inflate(R.layout.view_create_patient, null);
		dialog.setOnlyContainer(viewCreate);
		dialog.setCanceledOnTouchOutside(false);    
		final EditText editName = (EditText) viewCreate.findViewById(R.id.edit_create_patient_name);
		TextView title = (TextView) viewCreate.findViewById(R.id.edit_create_title);
		title.setText("重命名");
		editName.setHint("");
		editName.setText(record.getFolderName());
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
					ModifyRecordNameLogic logic = new ModifyRecordNameLogic(new ModifyRecordNameCallBack() {
						
						@Override
						public void modifyNameSuccess(int code, String msg) {
							mRecordList.get(position).setFolderName(str);
							setModifyStatus(false);
							dialog.dismiss();
						}
						
						@Override
						public void modifyNameError(int code, String msg) {
							UITools.showToast("重命名失败");
							dialog.dismiss();
							setModifyStatus(false);
						}
					});
					logic.modifyName(record.getFolderId(), str);
				}
				dialog.dismiss();
			}
		});
	}
	
	@Override
	public void onTopRightBtnClick(View view) {
		if (isModifty) {
			setModifyStatus(false);
		}
		final Record record = new Record();
		record.setFolderType(RecordConstants.RECORD_TYPE_DOORCASE);
		final CustomDialog dialog = new CustomDialog(this);
		dialog.setCanceledOnTouchOutside(false);
		View createView = LayoutInflater.from(this).inflate(R.layout.view_create_record, null);
		dialog.setOnlyContainer(createView);
		final EditText edtName = (EditText) createView.findViewById(R.id.edit_create_record_name);
		edtName.setFilters(new InputFilter[]{new InputFilter.LengthFilter(25)});//限定输入的字数最大为25
		final Button btnMz = (Button) createView.findViewById(R.id.btn_create_record_mz);
		final Button btnZy = (Button) createView.findViewById(R.id.btn_create_record_zy);
		Button btnSure = (Button) createView.findViewById(R.id.btn_create_record_sure);
		Button btnCancel = (Button) createView.findViewById(R.id.btn_create_record_cancel);
		btnZy.setSelected(true);
		btnSure.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				String name = edtName.getText().toString().trim();
				if(!"".equals(name)){
					record.setFolderName(name);
					if (btnMz.isSelected()) {
						record.setFolderType(RecordConstants.RECORD_TYPE_DOORCASE);
					}else{
						record.setFolderType(RecordConstants.RECORD_TYPE_ADMISSION);
					}
					createRecord(record);
				}
				dialog.dismiss();
			}
		});
		
		btnCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				dialog.dismiss();
			}
		});
		
		btnMz.setOnClickListener(new OnClickListener() {
			//选择门诊类型
			@Override
			public void onClick(View v) {
				if(!btnMz.isSelected()){
					btnMz.setSelected(true);
					btnZy.setSelected(false);
				}
			}
		});
		
		btnZy.setOnClickListener(new OnClickListener() {
			//选择住院类型
			@Override
			public void onClick(View v) {
				if(!btnZy.isSelected()){
					btnZy.setSelected(true);
					btnMz.setSelected(false);
				}
			}
		});
	}
	
	@Override
	public void onTopLeftBtnClick(View view) {
		setResultInfo();
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
			if (isModifty) {
				setModifyStatus(false);
			}else{
				setResultInfo();
				finish();
			}
            return false;
        }
        return false; 
	}
	
	private void setResultInfo(){
		if (mOldRecordCount != mRecordList.size()) {
			Intent intent = new Intent();
			intent.putExtra("patientId", patientId);
			intent.putExtra("recordCount", mRecordList.size());
			setResult(IntentKey.RECORD_LIST_HAS_MODIFY, intent);
		}
		finish();
	}
	
	private void setModifyStatus(boolean b){
		isModifty = b;
		if (!isModifty) {
			mCtrlPosition = -1;
			mAdapter.notifyDataSetChanged();
			mPatientCtrlView.hidden();
		}
	}
	
	/**
	 * 获取病案的概览信息
	 * @param patientId
	 */
	public  void getSurRecordItem(final int recordId){
		CustomDialog dialog = new CustomDialog(RecordListActivity.this);
		View view = LayoutInflater.from(RecordListActivity.this).inflate(R.layout.view_overview_record, null, false);
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
