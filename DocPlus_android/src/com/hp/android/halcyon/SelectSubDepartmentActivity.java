package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.view.View;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Department;
import com.hp.android.halcyon.wheel2.ArrayWheelAdapter;
import com.hp.android.halcyon.wheel2.WheelView;
import com.hp.android.halcyon.wheel2.WheelView.OnClickCenterListener;

public class SelectSubDepartmentActivity extends SelectActivity implements OnClickCenterListener {

	private ArrayList<Department> mDepartments;
	
	private Department mDepartment;

	@Override
	public void init() {
		super.init();
		setTopLeftImgShow(true);
		setTopRightImgSrc(R.drawable.snapphoto_camera_ok);
		hideTitleLine();
		mDepartments = (ArrayList<Department>) getIntent().getSerializableExtra("departments");
		mDepartment = (Department) getIntent().getSerializableExtra("department");
		if (mDepartment != null) {
			setTitle(mDepartment.getName());
		}
		if (mDepartments != null) {
			mValues = new ArrayList<String>();
			for (int i = 0; i < mDepartments.size(); i++) {
				Department department = mDepartments.get(i);
				mValues.add(department.getName());
				String[] items = new String[mValues.size()];
				mValues.toArray(items);
				mWheelAdapter = new ArrayWheelAdapter<String>(this, items);
				mWheelView.setViewAdapter(mWheelAdapter);
				mWheelView.setOnClickCenterListener(SelectSubDepartmentActivity.this);
			}
			setWheelCurrenItem(mValues.size()/2);
		}
		setWheelCyclie(false);
	}

//	@Override
//	public void onTopLeftBtnClick(View view) {
//		onSelected(true);
//	}
	public void onTopRightBtnClick(View view) {
	onSelected(false);
}
	/**
	 * 点击返回或者选中时调用
	 */
	private void onSelected(boolean backPressed) {
		if (mWheelAdapter == null) {
			onBackPressed();
		} else {
			for (int i = 0; i < mDepartments.size(); i++) {
				Department department = mDepartments.get(i);
				if (department.getName().equals(mWheelAdapter.getItemText(mWheelView.getCurrentItem()))) {
					Intent intent = new Intent();
					intent.putExtra("department", department);
					setResult(UserProfileActivity.CHANGE_DEPARTMENT_RESULT, intent);
					finish();
					break;
				}
			}
		}
	}

	public void OnClickCenter(WheelView view) {
		onSelected(false);
	}

}
