package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.baidu.mapapi.model.LatLng;
import com.baidu.mapapi.search.poi.OnGetPoiSearchResultListener;
import com.baidu.mapapi.search.poi.PoiDetailResult;
import com.baidu.mapapi.search.poi.PoiNearbySearchOption;
import com.baidu.mapapi.search.poi.PoiResult;
import com.baidu.mapapi.search.poi.PoiSearch;
import com.baidu.mapapi.search.poi.PoiSortType;
import com.fq.android.plus.R;
import com.fq.halcyon.entity.City;
import com.fq.halcyon.entity.Hospital;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.logic2.RequestCSDLogic;
import com.fq.halcyon.logic2.RequestCSDLogic.RequetHospitalInf;
import com.fq.halcyon.logic2.ResetDoctorInfoLogic;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.lbs.LocationInfo;
import com.hp.android.halcyon.lbs.LocationInfo.RequestLocationCallBack;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

public class HospitalActivity extends BaseActivity {

	private LinearLayout mPosition;
	private ListView mHotListView;
	private TextView mHospitalName;

	private HostpitalAdapter mAdaper;

	private TextView mCityPoint;

	private City mCity;

	private ArrayList<Hospital> mHospitals;

	private ArrayList<Hospital> mTempHospitals;

	private String mOldCityName = "";

	// private SearchView mSearchView;
	private ResetDoctorInfoLogic logic;

	private Hospital mSelectHosp;

	private boolean mIsHostSchool;
	private Button mSureButton;
	private LinearLayout mBtnSearch;
	private String hos;
	private String cityName = "未定位~";
	private int mSelectedItem = -1;
	private PoiSearch mPoiSearch;

	@Override
	public int getContentId() {
		return R.layout.activity_hospital;
	}

	public void init() {
		mIsHostSchool = getIntent()
				.getBooleanExtra("is_hospital_school", false);
		if (mIsHostSchool) {
			setTitle(R.string.activity_title_hospital_school);
			((TextView) findViewById(R.id.tv_hosp_current)).setText("当前医学院");
			((TextView) findViewById(R.id.tv_hosp_host_title))
					.setText("热\n门\n医\n学\n院");
		} else {
			setTitle(R.string.activity_title_hospital);
		}

		setTopLeftImgShow(true);
		// setTopRightText(R.string.btn_addnew);
		// setTopRightImgSrc(R.drawable.icon_addnew);
		// setTopRightBtnEnable(false);
		logic = new ResetDoctorInfoLogic();
		mCityPoint = (TextView) findViewById(R.id.tv_hosptial_city_p);
		mHospitalName = (TextView) findViewById(R.id.tv_hospital_name);
		mPosition = (LinearLayout) findViewById(R.id.ll_hospital_position);
		mHotListView = (ListView) findViewById(R.id.lv_hot_hospital);
		mSureButton = (Button) findViewById(R.id.btn_hospital_sure);
		// mSearchView = (SearchView) findViewById(R.id.search_hospital_view);
		mBtnSearch = (LinearLayout) findViewById(R.id.search_hospital_view);
		// Hospital ho = FileSystem.getInstance().loadEntity(Hospital.class);

		final User user = Constants.getUser();
		hos = user.getHospital();
		if (hos == null || "".equals(hos)) {
			mHospitalName.setText("未指定医院");
		} else {
			mHospitalName.setText(hos);
			mSelectHosp = new Hospital();
			mSelectHosp.setName(hos);
		}

		mCity = new City();
		requestLocation();
		mCity.setName(cityName);

		// mCityPoint.setText(cityName);
		// mCity.setName(cityName);

		mTempHospitals = new ArrayList<Hospital>();
		mAdaper = new HostpitalAdapter();
		mHotListView.setAdapter(mAdaper);
		mPosition.setOnClickListener(new OnClickListener() {
			// 点击跳转到选择城市
			@Override
			public void onClick(View view) {
				Intent intent = new Intent(HospitalActivity.this,
						CityActivity.class);
				startActivityForResult(intent, 22);

			}
		});

		mHotListView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				// Hospital hospital = mTempHospitals.get(arg2);
				mSelectHosp = mTempHospitals.get(arg2);
				if (!mSelectHosp.getName().equals(user.getHospital())) {
					mSureButton.setEnabled(true);
				} else {
					mSureButton.setEnabled(false);
				}
				mHospitalName.setText(mSelectHosp.getName());
				mSelectedItem = arg2;
				mAdaper.notifyDataSetInvalidated();
				hos = "";
			}
		});

		mBtnSearch.setOnClickListener(new OnClickListener() {
			// 跳转到搜索医院界面
			@Override
			public void onClick(View v) {
				Intent intent = new Intent(HospitalActivity.this,
						SearchHospitalActivity.class);
				intent.putExtra("city", mCity);
				startActivityForResult(intent, 100);
			}
		});
	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
		finish();
	}

	public void onHospitalSureClick(View v) {
		if (mHospitals == null) {
			onBackPressed();
			return;
		}
		Constants.getUser().setHospital(mSelectHosp.getName());
		Intent intent = new Intent();
		intent.putExtra("hosptial", mSelectHosp);
		int res = mSelectHosp.getHospitalId() == 0 ? UserProfileActivity.CHANGE_CREATE_HOSPITAL_RESULT
				: UserProfileActivity.CHANGE_HOSPITAL_RESULT;
		setResult(res, intent);
		finish();
	}

	// 获取当前位置和最近医院
	private void requestLocation() {
		mCityPoint.setText(cityName);
		final CustomProgressDialog dialog = new CustomProgressDialog(this);
		// 如果用户手机无法获得定位或定位接口失败，则进度窗口始终无法取消，故增加用户取消的能力
		// dialog.setCanceledOnTouchOutside(true);
		dialog.setCancelable(true);
		dialog.setMessage("正在定位城市，请稍候...");
		LocationInfo.getInstance().startRequestLocation(this,
				new RequestLocationCallBack() {

					@Override
					public void onRequestLocationSuccess(String msg) {
						cityName = msg;
						mCityPoint.setText(cityName);
						mCity.setName(cityName);
						// key不对 定位成功后10秒关闭dialog
						final Timer timer = new Timer();
						timer.schedule(new TimerTask() {

							@Override
							public void run() {
								dialog.dismiss();
								timer.cancel();
							}
						}, 10000, 10000);
						// 判断是否需要定位最近的医院
						if (!"未定位~".equals(msg)
								&& (hos == null || "".equals(hos))) {
							mPoiSearch = PoiSearch.newInstance();
							mPoiSearch
									.setOnGetPoiSearchResultListener(new OnGetPoiSearchResultListener() {

										@Override
										public void onGetPoiResult(
												PoiResult arg0) {
											if (arg0 != null
													&& arg0.getAllPoi() != null) {
												// double temp = 3000;
												// for (int i = 0; i < arg0
												// .getAllPoi().size(); i++) {
												// System.out
												// .println(arg0.getAllPoi().get(i).name);
												// System.out
												// .println(LocationInfo.latitude
												// +"  "+LocationInfo.longtitude);
												// double lat1 =
												// LocationInfo.latitude
												// * Math.PI / 180;
												// double lat2 = arg0
												// .getAllPoi().get(i).location.latitude
												// * Math.PI / 180;
												// double a = lat1 - lat2;
												// double b =
												// LocationInfo.longtitude
												// * Math.PI
												// / 180
												// - arg0.getAllPoi()
												// .get(i).location.longitude
												// * Math.PI / 180;
												// double s = 2 *
												// Math.asin(Math.sqrt(Math.pow(
												// Math.sin(a / 2), 2)
												// + Math.cos(lat1)
												// * Math.cos(lat2)
												// * Math.pow(
												// Math.sin(b / 2),
												// 2)));
												// s = s * 6378.137;
												// s = Math.round(s * 10000) /
												// 10000;
												// if (s < temp) {
												// temp = s;
												hos = arg0.getAllPoi().get(0).name;
												// }
												// }
												mHospitalName.setText(hos);
												mSelectHosp = new Hospital();
												mSelectHosp.setName(hos);
												mSureButton.setEnabled(true);
											} else {
												mHospitalName.setText("未指定医院");
											}
											dialog.dismiss();
											timer.cancel();
										}

										@Override
										public void onGetPoiDetailResult(
												PoiDetailResult arg0) {

										}
									});
							mPoiSearch
									.searchNearby((new PoiNearbySearchOption())
											.location(
													new LatLng(
															LocationInfo.latitude,
															LocationInfo.longtitude))
											.keyword("医院")
											.radius(3000)
											.sortType(
													PoiSortType.distance_from_near_to_far)
											.pageNum(0).pageCapacity(50));
						} else {
							dialog.dismiss();
							timer.cancel();
						}
						dialog.setMessage("正在定位医院，请稍候...");
						refreshHospitalList();

					}
				});
	}

	// 刷新医院列表
	private void refreshHospitalList() {
		if (mCity.getName().equals(mOldCityName))
			return;
		mCityPoint.setText(mCity.getName());
		if ("未定位~".equals(mCity.getName()))
			return;
		new RequestCSDLogic().requestHospital(mCity.getName(), mIsHostSchool,
				new RequetHospitalInf() {
					public void onError(int code, Throwable e) {

					}

					public void feedHospital(ArrayList<Hospital> hos) {
						mHospitals = hos;
						mTempHospitals = hos;
						mOldCityName = mCity.getName();
						runOnUiThread(new Runnable() {
							public void run() {
								findViewById(R.id.ll_hostipal_list_zone)
										.setVisibility(View.VISIBLE);
								mSelectedItem = -1;
								mAdaper.notifyDataSetChanged();
							}
						});
					}
				});
	}

	@Override
	protected void onResume() {
		super.onResume();
		refreshHospitalList();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		// mCity.setName(LocationInfo.getInstance().getCity());
		if (data == null)
			return;
		if (requestCode == 22) {
			mCity = (City) data.getSerializableExtra("city");
			// 保存城市ID
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("city_id", mCity.getCityId());
			logic.requestModifyDoctor(map);
		}
		if (resultCode == 33) {
			mSureButton.setEnabled(true);
			mSelectHosp = (Hospital) data.getSerializableExtra("hospital");
			runOnUiThread(new Runnable() {
				public void run() {
					mHospitalName.setText(mSelectHosp.getName());
					hos = mSelectHosp.getName();
				}
			});
			mAdaper.notifyDataSetChanged();
		}
	}

	class HostpitalAdapter extends BaseAdapter {

		@Override
		public int getCount() {
			return mTempHospitals.size();
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
			Hospital hospital = mTempHospitals.get(arg0);

			if (convertView == null) {
				convertView = LayoutInflater.from(HospitalActivity.this)
						.inflate(R.layout.site_item_left, null);
			}

			TextView tv = (TextView) convertView
					.findViewById(R.id.tv_btn_list_text);

			tv.setText(hospital.getName());

			tv.setTag(arg0);
			if (arg0 == mSelectedItem) {
				tv.setTextColor(getResources().getColor(R.color.app_emerald));

			} else {
				tv.setTextColor(0xff000000);
			}
			if (hos.equals(hospital.getName())) {
				tv.setTextColor(getResources().getColor(R.color.app_emerald));
			}
			return convertView;
		}
	}

}
