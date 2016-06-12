package com.fq.android.visualization;

import java.util.ArrayList;

import android.content.Intent;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnKeyListener;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Medicine;
import com.fq.halcyon.entity.visualize.VisualData;
import com.fq.halcyon.entity.visualize.VisualizeEntity.VISUALTYPE;
import com.fq.halcyon.logic2.RequestMedicineLogic;
import com.fq.halcyon.logic2.RequestMedicineLogic.RequetMedicineInf;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

public class MedicinalAnalysisActivity extends BaseActivity {

	private Button sureBtn;
	private ListView medicineList;
	private TextView currentMedicineText;
	private EditText searchEditText;
	private Medicine mSelectMedicine;
	private ArrayList<Medicine> mMedicines;
	private MedicineAdapter mAdaper;
	private String mKeywords = "";
	private int mSelectedItem = -1;

	@Override
	public int getContentId() {
		return R.layout.activity_medical_analyse_diagram;
	}

	@Override
	public void init() {
		initWidgets();
		setTitle("药物分析图表");
		mMedicines = new ArrayList<Medicine>();
		getMedicineList();
		mAdaper = new MedicineAdapter();
		medicineList.setAdapter(mAdaper);
		// 药物列表item点击事件
		medicineList.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				mSelectMedicine = mMedicines.get(arg2);
				// 必须选中一个药物后才能点击确认按钮,否则确定按钮为不可点击状态
				if (!mSelectMedicine.getName().equals("")) {
					sureBtn.setEnabled(true);
				} else {
					sureBtn.setEnabled(false);
				}
				currentMedicineText.setText(mSelectMedicine.getName());
				mSelectedItem = arg2;
				mAdaper.notifyDataSetInvalidated();
			}
		});

		// 监听搜索框的文字变化，模糊查询药物
		searchEditText.addTextChangedListener(new TextWatcher() {

			// 文字变化时
			@Override
			public void onTextChanged(CharSequence arg0, int arg1, int arg2,
					int arg3) {
				if (searchEditText.getText() != null) {
					mKeywords = searchEditText.getText().toString();
					getMedicineList();
				}
			}

			@Override
			public void beforeTextChanged(CharSequence arg0, int arg1,
					int arg2, int arg3) {

			}

			@Override
			public void afterTextChanged(Editable arg0) {

			}
		});
		searchEditText.setOnKeyListener(new OnKeyListener() {

			// 点击软键盘上搜索按钮，隐藏键盘
			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				if (keyCode == KeyEvent.KEYCODE_ENTER) {
					((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE))
							.hideSoftInputFromWindow(
									MedicinalAnalysisActivity.this
											.getCurrentFocus().getWindowToken(),
									InputMethodManager.HIDE_NOT_ALWAYS);
				}
				return false;
			}
		});
	}

	/**
	 * 初始化控件
	 */
	private void initWidgets() {
		sureBtn = (Button) findViewById(R.id.btn_medicine_sure);
		medicineList = (ListView) findViewById(R.id.lv_medicine);
		currentMedicineText = (TextView) findViewById(R.id.tv_current_medicine);
		searchEditText = (EditText) findViewById(R.id.et_medicine_search);
	}

	/**
	 * 药物列表Adapter
	 * 
	 * @author niko
	 * 
	 */
	class MedicineAdapter extends BaseAdapter {

		@Override
		public int getCount() {
			return mMedicines.size();
		}

		@Override
		public Object getItem(int arg0) {
			return null;
		}

		@Override
		public long getItemId(int arg0) {
			return 0;
		}

		@Override
		public View getView(int arg0, View convertView, ViewGroup arg2) {
			Medicine medicine = mMedicines.get(arg0);
			if (convertView == null) {
				convertView = LayoutInflater.from(
						MedicinalAnalysisActivity.this).inflate(
						R.layout.site_item_left, null);
			}
			TextView tv = (TextView) convertView
					.findViewById(R.id.tv_btn_list_text);
			tv.setText(medicine.getName());
			tv.setTag(arg0);
			if (arg0 == mSelectedItem) {
				tv.setTextColor(getResources().getColor(R.color.app_emerald));

			} else {
				tv.setTextColor(0xff000000);
			}
			return convertView;
		}
	}

	/**
	 * 获取药物列表
	 */
	private void getMedicineList() {
		final CustomProgressDialog dialog = new CustomProgressDialog(this);
		dialog.setMessage("获取药物列表…");
		new RequestMedicineLogic().requestMedicine(new RequetMedicineInf() {

			@Override
			public void onError(int code, Throwable error) {
				dialog.dismiss();
				UITools.showToast("获取药物列表失败");
			}

			@Override
			public void feedMedicine(ArrayList<Medicine> medicine) {
				mMedicines = medicine;
				mSelectedItem = -1;
				dialog.dismiss();
				mAdaper.notifyDataSetChanged();
				if(medicine.size() == 0){
					UITools.showToast("没有该药物");
				}
			}
		}, mKeywords);
	}

	/**
	 * 确定按钮点击事件
	 * 
	 * @param v
	 */
	public void sureClicked(View v) {
		String txt = currentMedicineText.getText().toString().trim();
		if (txt == null || "".equals(txt)) {
			return;
		}
		VisualData data = new VisualData(VISUALTYPE.DRUGS);
		data.setDataColumn(txt);
		Intent intent = new Intent(this, ChosePatientActivity.class);
		intent.putExtra("extra", data);
		startActivity(intent);
	}
}
