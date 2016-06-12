package com.fq.android.visualization;

import java.util.ArrayList;

import android.content.Intent;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Exam;
import com.fq.halcyon.entity.Hospital;
import com.fq.halcyon.entity.visualize.VisualData;
import com.fq.halcyon.entity.visualize.VisualizeEntity.VISUALTYPE;
import com.fq.halcyon.logic2.GetExamListLogic;
import com.fq.halcyon.logic2.GetExamListLogic.GetExamListCallBack;
import com.fq.halcyon.logic2.SearchHospitalLogic;
import com.fq.halcyon.logic2.SearchHospitalLogic.SearchHospitalCallBack;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.util.UITools;

public class ExamAnalysisActivity extends BaseActivity implements
		OnClickListener {
	private TextView mHospitolName;
	private TextView mExamName;
	private ListView mListView;
	private Button sureBtn;
	private EditText mHospitolSearch;
	private EditText mExamSearch;
	private ArrayList<Hospital> mHospitals;
	private HosAdapter mHosAdapter;
	private ExamAdapter mExamAdapter;
	private ArrayList<Exam> mExams;
	private int mHosSelectedItem = -1;
	private int mExamSelectedItem = -1;

	private Hospital hospital;
	private Hospital oldHospital;
	private Exam exam;

	private boolean isHos;

	@Override
	public int getContentId() {
		return R.layout.activity_exam_analysis;
	}

	@Override
	public void init() {
		setTitle("化验项分析图表");
		mHospitals = new ArrayList<Hospital>();
		mExams = new ArrayList<Exam>();
		this.getWindow().setSoftInputMode(
				WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
		isHos = true;
		initWidget();
		initListener();
	}

	private void initWidget() {
		mHospitolName = (TextView) findViewById(R.id.tv_hospital_name);
		mExamName = (TextView) findViewById(R.id.tv_exam);
		mListView = (ListView) findViewById(R.id.lv_hot_hospital);
		mHospitolSearch = (EditText) findViewById(R.id.et_hosp_current);
		mExamSearch = (EditText) findViewById(R.id.et_search_exam);
		sureBtn = (Button) findViewById(R.id.btn_hospital_sure);
		mHosAdapter = new HosAdapter();
		mExamAdapter = new ExamAdapter();
	}

	private void initListener() {
		mHospitolName.setOnClickListener(this);
		mExamName.setOnClickListener(this);
		mHospitolSearch.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View arg0, boolean arg1) {
				if (arg1) {
					isHos = true;
					getHosList();
				}
			}
		});
		mHospitolSearch.addTextChangedListener(new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence arg0, int arg1, int arg2,
					int arg3) {
			}

			@Override
			public void beforeTextChanged(CharSequence arg0, int arg1,
					int arg2, int arg3) {

			}

			@Override
			public void afterTextChanged(Editable arg0) {
				isHos = true;
				getHosList();
			}
		});
		mExamSearch.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View arg0, boolean arg1) {
				if (arg1) {
					if (hospital != null) {
						isHos = false;
						getExamList(hospital.getHospitalId(), mExamSearch
								.getText().toString());
					} else {
						UITools.showToast("请选择医院");
						mExamSearch.clearFocus();
						mHospitolSearch.requestFocus();
					}
				}
			}
		});
		mExamSearch.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence arg0, int arg1, int arg2,
					int arg3) {
			}

			@Override
			public void beforeTextChanged(CharSequence arg0, int arg1,
					int arg2, int arg3) {
			}

			@Override
			public void afterTextChanged(Editable arg0) {
				isHos = false;
				getExamList(hospital.getHospitalId(), mExamSearch.getText()
						.toString());
			}
		});
		sureBtn.setOnClickListener(this);
		mListView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				if (isHos) {
					if (hospital != null) {
						oldHospital = hospital;
					}
					hospital = mHospitals.get(arg2);
					if (oldHospital == null
							|| !hospital.getName()
									.equals(oldHospital.getName())) {
						mHospitolName.setText(hospital.getName());
						mHosSelectedItem = arg2;
						mHosAdapter.notifyDataSetChanged();
						mExamSelectedItem = -1;
						mExamName.setText("选择化验项");
						sureBtn.setEnabled(false);
					}
				} else {
					exam = mExams.get(arg2);
					mExamName.setText(exam.getExamName());
					mExamSelectedItem = arg2;
					mExamAdapter.notifyDataSetChanged();
					sureBtn.setEnabled(true);
				}

			}
		});
	}

	@Override
	public void onClick(View arg0) {
		switch (arg0.getId()) {
		case R.id.tv_hospital_name:
			mExamSearch.clearFocus();
			mHospitolSearch.requestFocus();
			break;
		case R.id.tv_exam:
			mHospitolSearch.clearFocus();
			mExamSearch.requestFocus();
			break;
		case R.id.btn_hospital_sure:
			VisualData data = new VisualData(VISUALTYPE.EXAMS);
			data.setDataColumn(exam.getExamName());
			Intent intent = new Intent(this, ChosePatientActivity.class);
			intent.putExtra("extra", data);
			startActivity(intent);
			break;

		default:
			break;
		}
	}

	class HosAdapter extends BaseAdapter {

		@Override
		public int getCount() {
			return mHospitals.size();
		}

		@Override
		public Object getItem(int arg0) {
			return mHospitals.get(arg0);
		}

		@Override
		public long getItemId(int arg0) {
			return arg0;
		}

		@Override
		public View getView(int arg0, View arg1, ViewGroup arg2) {
			Hospital hospital = mHospitals.get(arg0);
			if (arg1 == null) {
				arg1 = LayoutInflater.from(ExamAnalysisActivity.this).inflate(
						R.layout.site_item_left, null);
			}
			TextView tv = (TextView) arg1.findViewById(R.id.tv_btn_list_text);
			tv.setText(hospital.getName());
			tv.setTag(arg0);
			if (arg0 == mHosSelectedItem) {
				tv.setTextColor(getResources().getColor(R.color.app_emerald));
			} else {
				tv.setTextColor(0xff000000);
			}
			if (mHospitolName.getText().equals(hospital.getName())) {
				tv.setTextColor(getResources().getColor(R.color.app_emerald));
			}
			return arg1;
		}
	}

	class ExamAdapter extends BaseAdapter {

		@Override
		public int getCount() {
			return mExams.size();
		}

		@Override
		public Object getItem(int arg0) {
			return mExams.get(arg0);
		}

		@Override
		public long getItemId(int arg0) {
			return arg0;
		}

		@Override
		public View getView(int arg0, View arg1, ViewGroup arg2) {
			Exam exam = mExams.get(arg0);

			if (arg1 == null) {
				arg1 = LayoutInflater.from(ExamAnalysisActivity.this).inflate(
						R.layout.site_item_left, null);
			}

			TextView tv = (TextView) arg1.findViewById(R.id.tv_btn_list_text);

			tv.setText(exam.getExamName());

			tv.setTag(arg0);
			if (arg0 == mExamSelectedItem) {
				tv.setTextColor(getResources().getColor(R.color.app_emerald));
			} else {
				tv.setTextColor(0xff000000);
			}
			if (mExamName.getText().equals(exam.getExamName())) {
				tv.setTextColor(getResources().getColor(R.color.app_emerald));
			}
			return arg1;
		}

	}

	/**
	 * 获取医院列表
	 */
	private void getHosList() {
		if (mHosAdapter != mListView.getAdapter()) {
			mListView.setAdapter(mHosAdapter);
		}
		SearchHospitalLogic logic = new SearchHospitalLogic(
				new SearchHospitalCallBack() {

					@Override
					public void onSearchHospitalResult(ArrayList<Hospital> mList) {
						mHospitals.clear();
						mHospitals.addAll(mList);
						mHosAdapter.notifyDataSetChanged();
					}

					@Override
					public void onSearchHospitalError(int code, String msg) {
						UITools.showToast("搜索失败");
					}
				});
		logic.searchHDRHospital();
	}

	/**
	 * 获取化验项列表
	 */
	private void getExamList(int hosId, String keyExam) {
		mExams.clear();
		mExamAdapter.notifyDataSetChanged();
		if (mExamAdapter != mListView.getAdapter()) {
			mListView.setAdapter(mExamAdapter);
		}
		GetExamListLogic examListLogic = new GetExamListLogic(
				new GetExamListCallBack() {

					@Override
					public void onGetExamListResult(ArrayList<Exam> examList) {
						mExams.clear();
						mExams.addAll(examList);
						mExamAdapter.notifyDataSetChanged();
					}

					@Override
					public void onGetExamListError(int code, String msg) {
						UITools.showToast("搜索失败");
					}
				});
		examListLogic.getExamList(hosId, keyExam);
	}
}
