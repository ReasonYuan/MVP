package com.hp.android.halcyon.lbs;

import android.content.Context;
import android.util.Log;

import com.baidu.location.BDLocation;
import com.baidu.location.BDLocationListener;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;
import com.baidu.location.LocationClientOption.LocationMode;
import com.fq.lib.tools.Constants;

/**
 * example code blow <br/>
 * BaiduLocationFetcher baiduLocationFetcher = new
 * BaiduLocationFetcher(getApplicationContext(), new LocationListener() {<br/>
 * public void onReceiveLocation(String city, double latitude, double
 * longtitude) {<br/>
 * <br/>
 * }<br/>
 * });<br/>
 * baiduLocationFetcher.initLocation();<br/>
 * baiduLocationFetcher.getLocationClient().start();<br/>
 * 
 */
public class BaiduLocationFetcher {

	private boolean isOnce = false;

	public static interface LocationListener {
		/**
		 * @param city
		 *            - 可能为Null， 如果逆地址解析失败的话
		 * @param latitude
		 * @param longtitude
		 */
		public void onReceiveLocation(String city, double latitude,
				double longtitude);
	}

	private LocationListener mListener = null;
	public LocationClient mLocationClient;
	public MyLocationListener mMyLocationListener;

	private LocationMode tempMode = LocationMode.Hight_Accuracy;
	private String tempcoor = "gcj02";

	public BaiduLocationFetcher(Context appContex,
			LocationListener locationListener) {
		mLocationClient = new LocationClient(appContex);
		mMyLocationListener = new MyLocationListener();
		mLocationClient.registerLocationListener(mMyLocationListener);
		mListener = locationListener;
	}

	public LocationClient getLocationClient() {
		return mLocationClient;
	}

	/*
	 * 开始定位
	 */
	public void start(boolean once) {
		initLocation();
		isOnce = once;
		mLocationClient.start();
	}

	public void stop() {
		mLocationClient.stop();
	}

	private void initLocation() {
		LocationClientOption option = new LocationClientOption();
		option.setLocationMode(tempMode);// 设置定位模式
		option.setCoorType(tempcoor);// 返回的定位结果是百度经纬度，默认值gcj02
		int span = 1000;
		option.setScanSpan(span);// 设置发起定位请求的间隔时间为5000ms
		option.setIsNeedAddress(true);
		mLocationClient.setLocOption(option);
	}

	/**
	 * 实现实位回调监听
	 */
	private class MyLocationListener implements BDLocationListener {

		@Override
		public void onReceiveLocation(BDLocation location) {
			// Receive Location
			/**
			 * StringBuffer sb = new StringBuffer(256); sb.append("time : ");
			 * sb.append(location.getTime()); sb.append("\nerror code : ");
			 * sb.append(location.getLocType()); sb.append("\nlatitude : ");
			 * sb.append(location.getLatitude()); sb.append("\nlontitude : ");
			 * sb.append(location.getLongitude()); sb.append("\nradius : ");
			 * sb.append(location.getRadius()); if (location.getLocType() ==
			 * BDLocation.TypeGpsLocation) { sb.append("\nspeed : ");
			 * sb.append(location.getSpeed()); sb.append("\nsatellite : ");
			 * sb.append(location.getSatelliteNumber());
			 * sb.append("\ndirection : "); sb.append("\naddr : ");
			 * sb.append(location.getAddrStr()); sb.append("\ncity : ");
			 * sb.append(location.getCity());
			 * sb.append(location.getDirection()); } else if
			 * (location.getLocType() == BDLocation.TypeNetWorkLocation) {
			 * sb.append("\naddr : "); sb.append(location.getAddrStr());
			 * sb.append("\ncity : "); sb.append(location.getCity()); // 运营商信息
			 * sb.append("\noperationers : ");
			 * sb.append(location.getOperators()); }
			 * Log.i("BaiduLocationApiDem", sb.toString());
			 */
			// if (location.getLocType() == BDLocation.TypeGpsLocation) {
			//
			// } else if (location.getLocType() ==
			// BDLocation.TypeNetWorkLocation) {
			//
			// }
			if (Constants.DEBUG) {
				Log.i("",
						"found location: " + location.getCity() + ","
								+ location.getLatitude() + ","
								+ location.getLongitude());
			}
			if (mListener != null) {
				mListener.onReceiveLocation(location.getCity(),
						location.getLatitude(), location.getLongitude());
			}
			if (isOnce) {
				mLocationClient.stop();
			}
		}

	}

}
