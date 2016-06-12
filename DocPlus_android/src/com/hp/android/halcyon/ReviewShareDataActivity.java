package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Patient;
import com.fq.halcyon.entity.Record;
import com.fq.halcyon.logic2.GetRecordListLogic;
import com.fq.halcyon.logic2.GetRecordListLogic.GetRecordListCallBack;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.TimeFormatUtils;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.hp.android.halcyon.util.UITools;

/**
 * 查看去身份化数据
 * @author niko
 */
public class ReviewShareDataActivity extends BaseActivity{

	private ListView mShareDatasListView;
	private CommonAdapter<Record> mAdapter;
	private ArrayList<Record> mRecords;
	private ArrayList<Patient> mPatients;
	private int mShareType;
	private Patient mSharePatient;
	private Record mShareRecord;
	
	@Override
	public int getContentId() {
		return R.layout.activity_review_share_datas;
	}

	@Override
	public void init() {
		initWidgets();
		initListener();
		initDatas();
	}
	
	private void initDatas() {
		if (mShareType == RecordConstants.SHARE_PATIENT) {
			if (mSharePatient != null) {
				getShareRecordList(mSharePatient.getMedicalId());
			}
		}
	}

	private void initWidgets() {
		setTitle("查看去身份化数据");
		mShareType = getIntent().getIntExtra("shareType", 0);
		mShareDatasListView = (ListView) findViewById(R.id.lv_review_share_datas);
		mShareDatasListView.setAdapter(mAdapter = new CommonAdapter<Record>(this, R.layout.item_record_folder) {
			
			@Override
			public void convert(int position, ViewHolder helper, Record record) {
				helper.getView(R.id.item_record_from).setVisibility(View.GONE);
				helper.setText(R.id.item_tv_record_folder_name, record.getFolderName());
				helper.setText(R.id.item_record_create_time, TimeFormatUtils.getTimeByStr(record.getCreateTime(), "yyyy-MM-dd"));
				if(record.getFolderType() == RecordConstants.RECORD_TYPE_ADMISSION){
					//住院
					helper.setImageBitmap(R.id.item_img_record_type, R.drawable.record_type_zy);
				}else if(record.getFolderType() == RecordConstants.RECORD_TYPE_DOORCASE){
					//门诊
					helper.setImageBitmap(R.id.item_img_record_type, R.drawable.record_type_mz);
				}
			}
		});
		if(mShareType == RecordConstants.SHARE_PATIENT){
			mSharePatient = (Patient) getIntent().getSerializableExtra("shareDatas");
		}else if(mShareType == RecordConstants.SHARE_RECORD){
			mRecords = new ArrayList<Record>();
			mShareRecord = (Record) getIntent().getSerializableExtra("shareDatas");
			mRecords.add(mShareRecord);
			mAdapter.addDatas(mRecords);
		}
	}

	private void initListener(){
		mShareDatasListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				//TODO 传"docType"
				Intent intent = new Intent(ReviewShareDataActivity.this,BrowRecordActivity2.class);
				intent.putExtra("docType", mAdapter.getItem(position).getFolderType());
				intent.putExtra("docName", mAdapter.getItem(position).getFolderName());
				intent.putExtra("docId", mAdapter.getItem(position).getFolderId());
				intent.putExtra("isOnlyInfo", true);//去身份化
				startActivity(intent);
			}
		});
	}
	
	/**
	 * 获取需要分享的病历
	 */
	private void getShareRecordList(int patientId){
		GetRecordListLogic logic = new GetRecordListLogic(new GetRecordListCallBack() {
			
			@Override
			public void onGetRecordListError(int code, String msg) {
				UITools.showToast("获取数据失败");
			}
			
			@Override
			public void onGetRecordList(ArrayList<Record> mRecordList) {
				mAdapter.addDatas(mRecordList);
			}
		});
		logic.getRecordList(patientId);
	}
}
