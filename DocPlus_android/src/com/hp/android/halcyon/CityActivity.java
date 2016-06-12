package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.view.View;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.City;
import com.fq.halcyon.logic2.RequestCSDLogic;
import com.fq.halcyon.logic2.RequestCSDLogic.ResCityInf;
import com.hp.android.halcyon.wheel2.ArrayWheelAdapter;
import com.hp.android.halcyon.wheel2.WheelView;
import com.hp.android.halcyon.wheel2.WheelView.OnClickCenterListener;

public class CityActivity extends SelectActivity implements OnClickCenterListener {

	// ExpandableListView mExListView;
	public ArrayList<City> mCitys;
	private City mCity;
	private boolean isChild = false;

	@Override
	public void init() {
		super.init();
		setTitle("省份");
		setTopLeftImgShow(true);
		setTopRightImgSrc(R.drawable.snapphoto_camera_ok);
		hideTitleLine();
		mCitys = (ArrayList<City>) getIntent().getSerializableExtra("citys");
		mCity = (City) getIntent().getSerializableExtra("city");
		if (mCity != null) {
			setTitle(mCity.getName());
		}
		if (mCitys != null) {
			isChild = true;
			mValues = new ArrayList<String>();
			if(mCitys.size()==1){
				setWheelCyclie(false);
			}else {
				setWheelCyclie(true);
			}
			for (int i = 0; i < mCitys.size(); i++) {
				City city = mCitys.get(i);
				mValues.add(city.getName());
				String[] items = new String[mValues.size()];
				mValues.toArray(items);
				mWheelAdapter = new ArrayWheelAdapter<String>(this, items);
				mWheelView.setViewAdapter(mWheelAdapter);
				mWheelView.setOnClickCenterListener(CityActivity.this);
			}
		} else {
			mCitys = new ArrayList<City>();
		}
		if (!isChild) {
			new RequestCSDLogic().requestCity(new ResCityInf() {
				public void feedCity(final ArrayList<City> ctys) {
					mCitys = ctys;
					if (mValues != null) {
						mValues.clear();
					} else {
						mValues = new ArrayList<String>();
					}
					for (int i = 0; i < mCitys.size(); i++) {
						City city = mCitys.get(i);
						mValues.add(city.getName());
					}
					String[] items = new String[mValues.size()];
					mValues.toArray(items);
					mWheelAdapter = new ArrayWheelAdapter<String>(CityActivity.this, items);
					mWheelView.setViewAdapter(mWheelAdapter);
					mWheelView.setOnClickCenterListener(CityActivity.this);
					mWheelView.setCyclic(true);
				}

				@Override
				public void onError(int code, Throwable e) {
				}
			});
		}		
//		setWheelCyclie(true);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == 222 && resultCode == 22) {
			setResult(22, data);
			finish();
		}
	}

	@Override
	public void onTopLeftBtnClick(View view) {
		onBackPressed();
	}
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
			// 选择省份
			if (mCity == null) {
				for (int i = 0; i < mCitys.size(); i++) {
					City city = mCitys.get(i);
					if (city.getName().equals(mWheelAdapter.getItemText(mWheelView.getCurrentItem()))) {
						if ( city.isHaveChild()) {
							if(backPressed) {
								onBackPressed();
								return;
							}
							Intent intent = new Intent();
							intent.putExtra("citys", city.getChildren());
							intent.putExtra("city", city);
							intent.setClass(CityActivity.this, CityActivity.class);
							startActivityForResult(intent, 222);
						}else {
							Intent intent = new Intent();
							intent.putExtra("city", city);
							setResult(22, intent);
							finish();
						}
						break;
					}
				}

			} else {// 选择城市
				for (int i = 0; i < mCitys.size(); i++) {
					City city = mCitys.get(i);
					if (city.getName().equals(mWheelAdapter.getItemText(mWheelView.getCurrentItem()))) {
						Intent intent = new Intent();
						intent.putExtra("city", city);
						setResult(22, intent);
						finish();
						break;
					}
				}
			}
		}

	}

	public void OnClickCenter(WheelView view) {
		onSelected(false);
	}

}
