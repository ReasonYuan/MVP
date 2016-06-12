package com.hp.android.halcyon.lbs;

import android.content.Context;
import android.util.Log;

import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.lbs.BaiduLocationFetcher.LocationListener;

public class LocationInfo {

	private String city;

	public static double latitude, longtitude;

	private static LocationInfo _locaLocationInfo;

	public static LocationInfo getInstance() {
		if (_locaLocationInfo == null) {
			_locaLocationInfo = new LocationInfo();
			_locaLocationInfo.city = "未定位~";
		}
		return _locaLocationInfo;
	}

	BaiduLocationFetcher baiduLocationFetcher;

	public void startRequestLocation(Context appContext,final RequestLocationCallBack locationCallBack) {
		baiduLocationFetcher = new BaiduLocationFetcher(appContext,
				new LocationListener() {
					@Override
					public void onReceiveLocation(String city, double latitude,
							double longtitude) {
						LocationInfo.this.city = city;
						LocationInfo.latitude = latitude;
						LocationInfo.longtitude = longtitude;
						if (city == null || "".equals(city))
							LocationInfo.this.city = "未定位~";
						if (Constants.DEBUG) {
							Log.i("", "city_name: " + city);
						}
						baiduLocationFetcher.stop();
						baiduLocationFetcher = null;
						
						locationCallBack.onRequestLocationSuccess(LocationInfo.this.city);
					}
				});
		baiduLocationFetcher.start(true);
	}

	public String getCity() {
		return city;// city.substring(0, city.length()-1);
	}

	public void setCity(String city) {
		this.city = city;
	}
	
	public interface RequestLocationCallBack{
		public void onRequestLocationSuccess(String msg);
	}
	

}
