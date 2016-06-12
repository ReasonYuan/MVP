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
import com.fq.halcyon.entity.Department;
import com.fq.halcyon.logic2.SearchDepartmentLogic;
import com.fq.halcyon.logic2.SearchDepartmentLogic.SearchDepartmentCallBack;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.SearchView;
import com.hp.android.halcyon.widgets.SearchView.SearchListener;

/**
 * 搜索科室
 * 
 * @author niko
 * 
 */
public class SearchDepartmentActivity extends BaseActivity {

	private ListView mDepartmentListView;
	private CommonAdapter<Department> mAdapter;
	private SearchView mSearchHospital;
	private String mSearchKey;
	private TextView mTextNoHospital;
	private TextView mButtonNewHospital;
	private LinearLayout mbbb;
	private View topView;
	private View bottomView;

	@Override
	public int getContentId() {
		return R.layout.activity_search_department;
	}

	@Override
	public void init() {
		initWidgets();
	}

	private void initWidgets() {
		setTitle("搜索");
		mDepartmentListView = (ListView) findViewById(R.id.lv_hospital_list);
		topView = findViewById(R.id.view_search_department_top);
		bottomView = findViewById(R.id.view_search_department_bottom);
		mTextNoHospital = getView(R.id.tv_hospital_list_no_data);
		mButtonNewHospital = getView(R.id.btn_new_hospital);
		mbbb = getView(R.id.ll_bbb);
		// setTopRightImgSrc(R.drawable.btn_add_icon);
		// setTopRightBtnEnable(false);

		mDepartmentListView
				.setAdapter(mAdapter = new CommonAdapter<Department>(
						SearchDepartmentActivity.this, R.layout.site_item_left) {

					@Override
					public void convert(int position, ViewHolder helper,
							Department hospital) {
						helper.setText(R.id.tv_btn_list_text,
								hospital.getName());
					}
				});
		setTopAndBottomViewVisibility();

		mDepartmentListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				Intent intent = new Intent();
				intent.putExtra("department", mAdapter.getItem(position));
				setResult(33, intent);
				finish();
			}
		});
		
		mDepartmentListView.setOnScrollListener(new OnScrollListener() {

			@Override
			public void onScrollStateChanged(AbsListView arg0, int arg1) {

				// 判断滚动到底部
				if (mDepartmentListView.getLastVisiblePosition() == (mDepartmentListView
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
				if (mDepartmentListView.getFirstVisiblePosition() == 0) {
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
		mSearchHospital.setSearchHintText("搜索科室");
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
						.hideSoftInputFromWindow(SearchDepartmentActivity.this
								.getCurrentFocus().getWindowToken(),
								InputMethodManager.HIDE_NOT_ALWAYS);
				getSearchResult(mSearchKey);
			}
		});
	}

	private void getSearchResult(final String key) {

		SearchDepartmentLogic logic = new SearchDepartmentLogic(
				new SearchDepartmentCallBack() {

					@Override
					public void onSearchDepartmentResult(
							ArrayList<Department> mList) {
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
					public void onSearchDepartmentError(int code, String msg) {
						UITools.showToast("搜索失败");
					}
				});
		logic.searchDepartment(key);
	}
	
	private void setTopAndBottomViewVisibility(){
		if (mDepartmentListView.getLastVisiblePosition() == (mDepartmentListView
				.getCount() - 1)) {
			bottomView.setVisibility(View.INVISIBLE);
		}else {
			bottomView.setVisibility(View.VISIBLE);
		}
		
		if (mDepartmentListView.getFirstVisiblePosition() == 0) {
			topView.setVisibility(View.INVISIBLE);
		}else {
			topView.setVisibility(View.VISIBLE);
		}
	}

	public void btn_new_department(View v) {
		final CustomDialog dialog = new CustomDialog(this);
		View viewCreate = LayoutInflater.from(this).inflate(
				R.layout.view_create_patient, null);
		dialog.setOnlyContainer(viewCreate);
		dialog.setCanceledOnTouchOutside(false);
		final EditText editName = (EditText) viewCreate
				.findViewById(R.id.edit_create_patient_name);
		editName.setHint("输入科室名称");
		TextView mTextView = (TextView) viewCreate
				.findViewById(R.id.edit_create_title);
		mTextView.setText("新建科室");
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
					Department department = new Department();
					department.setName(str);
					intent.putExtra("department", department);
					setResult(33, intent);
					finish();
				}
				dialog.dismiss();
			}
		});
	}
}
