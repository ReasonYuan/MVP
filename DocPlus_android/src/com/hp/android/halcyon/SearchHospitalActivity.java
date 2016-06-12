package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.AlphaAnimation;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.City;
import com.fq.halcyon.entity.Hospital;
import com.fq.halcyon.logic2.SearchHospitalLogic;
import com.fq.halcyon.logic2.SearchHospitalLogic.SearchHospitalCallBack;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.SearchView;
import com.hp.android.halcyon.widgets.SearchView.SearchListener;

/**
 * 搜索医院
 * 
 * @author niko
 * 
 */
public class SearchHospitalActivity extends BaseActivity {

	private ListView mHospitalListView;
	private CommonAdapter<Hospital> mAdapter;
	private SearchView mSearchHospital;
	private String mSearchKey;
	private City mCity;
	private TextView mTextNoHospital;
	private TextView mButtonNewHospital;
	private LinearLayout mbbb;
	private View topView;
	private View bottomView;

	@Override
	public int getContentId() {
		return R.layout.activity_search_hospital;
	}

	@Override
	public void init() {
		mCity = (City) getIntent().getSerializableExtra("city");
		initWidgets();
	}

	private void initWidgets() {
		setTitle("搜索");
		mHospitalListView = (ListView) findViewById(R.id.lv_hospital_list);
		topView = findViewById(R.id.view_search_hos_top);
		bottomView = findViewById(R.id.view_search_hos_bottom);
		mTextNoHospital = getView(R.id.tv_hospital_list_no_data);
		mButtonNewHospital = getView(R.id.btn_new_hospital);
		mbbb = getView(R.id.ll_bbb);
		// setTopRightImgSrc(R.drawable.btn_add_icon);
		// setTopRightBtnEnable(false);

		mHospitalListView.setAdapter(mAdapter = new CommonAdapter<Hospital>(
				SearchHospitalActivity.this, R.layout.site_item_left) {

			@Override
			public void convert(int position, ViewHolder helper,
					Hospital hospital) {
				helper.setText(R.id.tv_btn_list_text, hospital.getName());
			}
		});
		
		setTopAndBottomViewVisibility();

		mHospitalListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				Intent intent = new Intent();
				intent.putExtra("hospital", mAdapter.getItem(position));
				setResult(33, intent);
				finish();
			}
		});
		mHospitalListView.setOnScrollListener(new OnScrollListener() {

			@Override
			public void onScrollStateChanged(AbsListView arg0, int arg1) {

				// 判断滚动到底部
				if (mHospitalListView.getLastVisiblePosition() == (mHospitalListView
						.getCount() - 1)) {
					if (bottomView.getVisibility() != View.INVISIBLE) {
						AlphaAnimation alpha = new AlphaAnimation(1, 0);
						alpha.setDuration(800);
						alpha.setFillAfter(true);
						bottomView.startAnimation(alpha);
						bottomView.setVisibility(View.INVISIBLE);
					}

				} else {
					if (bottomView.getVisibility() != View.VISIBLE) {
						AlphaAnimation alpha = new AlphaAnimation(0, 1);
						alpha.setDuration(800);
						alpha.setFillAfter(true);
						bottomView.startAnimation(alpha);
						bottomView.setVisibility(View.VISIBLE);
					}

				}
				// 判断滚动到顶部
				if (mHospitalListView.getFirstVisiblePosition() == 0) {
					if (topView.getVisibility() != View.INVISIBLE) {
						AlphaAnimation alpha = new AlphaAnimation(1, 0);
						alpha.setDuration(800);
						alpha.setFillAfter(true);
						topView.startAnimation(alpha);
						topView.setVisibility(View.INVISIBLE);
					}
				} else {
					if (topView.getVisibility() != View.VISIBLE) {
						AlphaAnimation alpha = new AlphaAnimation(0, 1);
						alpha.setDuration(800);
						alpha.setFillAfter(true);
						topView.startAnimation(alpha);
						topView.setVisibility(View.VISIBLE);
					}
				}

			}

			@Override
			public void onScroll(AbsListView arg0, int arg1, int arg2, int arg3) {

			}
		});

		mSearchHospital = (SearchView) findViewById(R.id.sv_hospital_search);
		mSearchHospital.setSearchHintText("搜索医院");
		mSearchHospital.setSearchListener(new SearchListener() {

			@Override
			public void searchChange(final String key) {
				if (key == null || "".equals(key)) {
					mbbb.setVisibility(View.GONE);
				}
				searchCallback(key);

			}

			@Override
			public void searchCallback(String key) {
				mSearchKey = key;
				if (key == null || "".equals(key)) {
					getSearchResult(mSearchKey);
					return;
				}
				((InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE))
						.hideSoftInputFromWindow(SearchHospitalActivity.this
								.getCurrentFocus().getWindowToken(),
								InputMethodManager.HIDE_NOT_ALWAYS);
				getSearchResult(mSearchKey);
			}
		});
	}

	private void getSearchResult(final String key) {

		SearchHospitalLogic logic = new SearchHospitalLogic(
				new SearchHospitalCallBack() {

					@Override
					public void onSearchHospitalResult(ArrayList<Hospital> mList) {
						if(key.equals("")){
							mList.clear();
							mAdapter.addDatas(mList);
							setTopAndBottomViewVisibility();
							
							return;
						}
						mAdapter.addDatas(mList);
						setTopAndBottomViewVisibility();
						
						if (mList.size() == 0) {
							mTextNoHospital.setVisibility(View.VISIBLE);
							mButtonNewHospital.setVisibility(View.VISIBLE);
							mbbb.setVisibility(View.VISIBLE);
							// setTopRightImgShow(true);
							// setTopRightBtnEnable(true);
						} else {
							mTextNoHospital.setVisibility(View.GONE);
							mButtonNewHospital.setVisibility(View.GONE);
							mbbb.setVisibility(View.GONE);
							// setTopRightImgShow(false);
							// setTopRightBtnEnable(false);
						}
					}

					@Override
					public void onSearchHospitalError(int code, String msg) {
						UITools.showToast("搜索失败");
					}
				});
		String cityName = "";
		if (mCity != null) {
			cityName = mCity.getName();
		}
		logic.searchHospital(key, cityName);
	}

	// public void onTopRightBtnClick(View view) {
	//
	// }
	
	private void setTopAndBottomViewVisibility(){
		if (mHospitalListView.getLastVisiblePosition() == (mHospitalListView
				.getCount() - 1)) {
			bottomView.setVisibility(View.INVISIBLE);
		}else {
			bottomView.setVisibility(View.VISIBLE);
		}
		
		if (mHospitalListView.getFirstVisiblePosition() == 0) {
			topView.setVisibility(View.INVISIBLE);
		}else {
			topView.setVisibility(View.VISIBLE);
		}
	}

	public void OnNewHospital(View v) {
		final CustomDialog dialog = new CustomDialog(this);
		View viewCreate = LayoutInflater.from(this).inflate(
				R.layout.view_create_patient, null);
		dialog.setOnlyContainer(viewCreate);
		dialog.setCanceledOnTouchOutside(false);
		final EditText editName = (EditText) viewCreate
				.findViewById(R.id.edit_create_patient_name);
		editName.setHint("输入医院名称");
		TextView mTextView = (TextView) viewCreate
				.findViewById(R.id.edit_create_title);
		mTextView.setText("新建医院");
		Button btnSure = (Button) viewCreate
				.findViewById(R.id.btn_create_patient_sure);
		Button btnCancel = (Button) viewCreate
				.findViewById(R.id.btn_create_patient_cancel);
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
					Intent intent = new Intent();
					Hospital hospital = new Hospital();
					hospital.setName(str);
					intent.putExtra("hospital", hospital);
					setResult(33, intent);
					finish();
				}
				dialog.dismiss();
			}
		});
	}
}
