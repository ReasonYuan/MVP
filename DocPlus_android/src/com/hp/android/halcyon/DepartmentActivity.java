package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Department;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.logic2.RequestCSDLogic;
import com.fq.halcyon.logic2.RequestCSDLogic.FeedSaveDepartment;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.util.UITools;

public class DepartmentActivity extends BaseActivity implements
		FeedSaveDepartment {

	private ListView mListView;
	private TextView selectedNameView;
	private Department mDepartment;
	private Button mSureButton;
	// private EditText mEditText;
	// private View mCurrentDepart;
	// private View mListTopLine;

	private ArrayList<Department> departments;
	private RequestCSDLogic logic;
	private DepartmentAdapter mAdapter;

	public Department mSelectDepart;
	public Department mResultDepart;
	private boolean mIsSchoolMajor;
	private Intent mResultIntent;
	private String mOldDepart;
	private int selectItem = -1;

	@Override
	public int getContentId() {
		return R.layout.activity_department;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void init() {
		mIsSchoolMajor = getIntent().getBooleanExtra("is_school_major", false);
		mOldDepart = Constants.getUser().getDepartment();
		// hideTitleLine();
		if (mIsSchoolMajor) {
			setTitle("专业");
			((TextView) findViewById(R.id.tv_depart_current)).setText("当前专业");
			((TextView) findViewById(R.id.tv_depart_host_title))
					.setText("热\n门\n专\n业");
		} else {
			setTitle(R.string.activity_title_department);
		}

		setTopLeftImgShow(true);
		mListView = (ListView) findViewById(R.id.lv_hot_depart);
		selectedNameView = (TextView) findViewById(R.id.tv_current_depart_name);
		mSureButton = (Button) findViewById(R.id.btn_depart_sure);

		User user = Constants.getUser();
		String department = mIsSchoolMajor ? user.getMajor() : user
				.getDepartment();
		if ("".equals(department)) {
			selectedNameView.setText(mIsSchoolMajor ? "未指定专业" : getResources()
					.getString(R.string.me_department_no));
		} else {
			selectedNameView.setText(department);
		}

		departments = new ArrayList<Department>();
		mAdapter = new DepartmentAdapter();
		mListView.setAdapter(mAdapter);

		ArrayList<Department> deps = (ArrayList<Department>) getIntent()
				.getSerializableExtra("departments");
		if (deps != null) {
			departments = deps;
			findViewById(R.id.ll_depart_list_zone).setVisibility(View.VISIBLE);
			// mIsLev2 = true;
		} else {
			logic = new RequestCSDLogic();
			logic.requestDepartment(this);
		}

		/*
		 * if(deps != null){ setTopRightImgSrc(R.drawable.icon_addnew);
		 * //setTopRightBtnEnable(false); mCurrentDepart =
		 * findViewById(R.id.ll_department_current);
		 * mCurrentDepart.setVisibility(View.GONE); mEditText = (EditText)
		 * findViewById(R.id.et_department_new);
		 * mEditText.setVisibility(View.VISIBLE); } setListTopLineState();
		 */

		mListView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				Department department = departments.get(position);
				selectItem = position;
				if (department.isHaveChild()) {
					// mIs2Lev2 = true;
					mDepartment = department;
					Intent intent = new Intent();
					intent.putExtra("is_school_major", mIsSchoolMajor);
					intent.putExtra("departments", department.getChild());
					intent.putExtra("department", mDepartment);
					intent.setClass(DepartmentActivity.this,
							SelectSubDepartmentActivity.class);
					startActivityForResult(intent, 201);
				} else {
					mSureButton.setEnabled(true);
					mSelectDepart = department;
					selectedNameView.setText(department.getName());
				}
				mAdapter.notifyDataSetInvalidated();
			}
		});

//		mSureButton.setOnClickListener(new OnClickListener() {
//
//			@Override
//			public void onClick(View v) {
//				setResult(UserProfileActivity.CHANGE_DEPARTMENT_RESULT,
//						mResultIntent);
//				finish();
//			}
//		});
	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
		finish();
	}

	public void onDepartSureClick(View v) {
		if (mResultDepart == null) {
			Constants.getUser().setDepartment(
					mOldDepart == null ? "" : mOldDepart);
			onBackPressed();
			return;
		}

		Constants.getUser().setDepartment(mResultDepart.getName());
//		Intent intent = new Intent();
//		intent.putExtra("department", mSelectDepart);
		// setResult(UserProfileActivity.CHANGE_DEPARTMENT_RESULT, intent);
		if(mResultDepart.getDepartmentId()!=0){
			setResult(UserProfileActivity.CHANGE_DEPARTMENT_RESULT, mResultIntent);
		}else{
			setResult(UserProfileActivity.CHANGE_CREATE_DEPARTMENT_RESULT, mResultIntent);
		}
		finish();
	}

	/*
	 * public void onTopRightBtnClick(View view) { String name =
	 * mEditText.getText().toString().trim(); if("".equals(name)){
	 * UITools.showToast("请输入想要新建的科室名字"); return; }
	 * 
	 * Constants.getUser().setDepartment(name);
	 * 
	 * Department department = new Department(); department.setName(name);
	 * Intent intent = new Intent(); intent.putExtra("department", department);
	 * setResult(UserProfileActivity.CHANGE_DEPARTMENT_RESULT, intent);
	 * finish(); }
	 */

	/*
	 * public void setListTopLineState(){ if(departments.size() == 0){
	 * mListTopLine.setVisibility(View.GONE); }else{
	 * mListTopLine.setVisibility(View.VISIBLE); } }
	 */

	/*
	 * @Override protected void onStop() { super.onStop(); if(mDepartment!=null
	 * && !mIsLev2 && !mIs2Lev2 && !mOldName.equals(mDepartment.getName())){ new
	 * SaveCDSLogic().saveDepartment(mDepartment.getName()); } }
	 */

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		if (requestCode == 201
				&& resultCode == UserProfileActivity.CHANGE_DEPARTMENT_RESULT) {
			mResultDepart = (Department) data
					.getSerializableExtra("department");
			if (mResultDepart != null) {
				mResultIntent = data;
				mResultIntent.putExtra("depart_1", mResultDepart);
				selectedNameView.setText(mResultDepart.getName());
				if (mDepartment.getDepartmentId() != mResultDepart
						.getDepartmentId()) {
					Constants.getUser().setDepartment(mResultDepart.getName());
					mSureButton.setEnabled(true);
				} else {
					mSureButton.setEnabled(false);
				}
			}

		}
		if (resultCode == 33) {
			mSureButton.setEnabled(true);
			mResultDepart = (Department) data
					.getSerializableExtra("department");
			if (mResultDepart != null) {
				mResultIntent = data;
				mResultIntent.putExtra("department", mResultDepart);
				mResultIntent.putExtra("depart_1", mResultDepart);
				selectedNameView.setText(mResultDepart.getName());
			}
		}
	}

	class DepartmentAdapter extends BaseAdapter {

		@Override
		public int getCount() {
			return departments.size();
		}

		@Override
		public Object getItem(int position) {
			return departments.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = LayoutInflater.from(DepartmentActivity.this)
						.inflate(R.layout.site_item_left, null);
			}
			TextView tv = (TextView) convertView
					.findViewById(R.id.tv_btn_list_text);
			Department department = departments.get(position);
			tv.setText(department.getName());
			convertView.findViewById(R.id.v_select_sign).setVisibility(
					department.isHaveChild() ? View.VISIBLE : View.GONE);
			if (position == selectItem) {
				tv.setTextColor(getResources().getColor(R.color.app_emerald));

			} else {
				tv.setTextColor(0xff000000);
			}
			return convertView;
		}
	}

	@Override
	public void onError(int code, Throwable e) {
		if (code < 0)
			UITools.showToast(e.getMessage());
	}

	@Override
	public void feedDepartment(ArrayList<Department> departmets) {
		departments = departmets;
		runOnUiThread(new Runnable() {
			public void run() {
				findViewById(R.id.ll_depart_list_zone).setVisibility(
						View.VISIBLE);
				mAdapter.notifyDataSetChanged();
				// setListTopLineState();
			}
		});
	}

	@Override
	public void onTopLeftBtnClick(View view) {
		Constants.getUser().setDepartment(mOldDepart == null ? "" : mOldDepart);
		finish();
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
			Constants.getUser().setDepartment(
					mOldDepart == null ? "" : mOldDepart);
			finish();
			return true;
		}
		return super.onKeyDown(keyCode, event);

	}

	public void search_dep(View v) {
		Intent intent = new Intent(DepartmentActivity.this,
				SearchDepartmentActivity.class);
		startActivityForResult(intent, 100);
	}
}
