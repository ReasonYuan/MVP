package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.HomeOneDayData;
import com.fq.halcyon.entity.HomeOneDayData.CurrSate;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.HttpRequestPotocol;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.TimeFormatUtils;
import com.fq.lib.tools.UriConstants;

public class DoctorHomeLogic {
	
	private long mLastRequestDataTime;

	public HttpRequestPotocol requestPatientMonth(final OnDoctorHomeCallback callback) {
		if(Constants.getUser() == null) return null;
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());

		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		String url = UriConstants.Conn.URL_PUB + "/timer/stat.do";

		return ApiSystem.getInstance().require(url, params, API_TYPE.BROW,
				new HalcyonHttpResponseHandle() {
					public void onError(int code, Throwable e) {
						callback.errorMonth("你当前还没有数据");
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						Map<Integer, ArrayList<Integer>> data = new TreeMap<Integer, ArrayList<Integer>>();
						if (responseCode == 0 && type == 1) {
							try {
								JSONObject json = (JSONObject) results;
								Iterator iterator = json.keys();
								while (iterator.hasNext()) {
									String key = String.valueOf(iterator.next());
									JSONArray array = json.optJSONArray(key);
									ArrayList<Integer> mouth = new ArrayList<Integer>();
									if (array != null) {
										for (int i = 0; i < array.length(); i++) {
											mouth.add(array.optInt(i));
										}
									}
									data.put(Integer.valueOf(key), mouth);
								}
								if (callback != null)
									callback.feedMonth(data);
							} catch (Exception e) {
								e.printStackTrace();
								onError(0, e);
							}
						}

					}
				});
	}

	public HttpRequestPotocol requestPatients(long date, OnDoctorHomeCallback callback) {
		return requestPatients(date, 30, 30, callback);
	}

	public HttpRequestPotocol requestPatients(OnDoctorHomeCallback callback) {
		return requestPatients(System.currentTimeMillis(), 30, 30, callback);
	}
	
	
//	public void requestPatients(OnDoctorHomeCallback callback) {
//		requestPatients(TimeFormatUtils.getTimeByFormat(
//				System.currentTimeMillis(), "yyyy-MM-dd"), 30, 30, callback);
//	}
	
	public HttpRequestPotocol requestOneDayPatientsForAlarm(long data,final OnDoctorHomeCallback callback){
		String format = "yyyy-MM-dd";
		Calendar calendar = Calendar.getInstance();
		calendar.setTimeInMillis(data);
		calendar.add(Calendar.DAY_OF_YEAR, 1);
		String toDate = TimeFormatUtils.getTimeByFormat(calendar.getTimeInMillis(), format);
		String  startDate = TimeFormatUtils.getTimeByFormat(data, format);
		String url = UriConstants.Conn.URL_PUB + "/timer/home.do";

		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());// Constants.getUser().getUserId() 900000319
		map.put("from_date", startDate);
		map.put("to_date", toDate);
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		return ApiSystem.getInstance().require(url, params, API_TYPE.BROW,
				new HalcyonHttpResponseHandle() {
					public void onError(int code, Throwable e) {
						e.printStackTrace();
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0 && type == 1) {
							JSONArray array = ((JSONObject) results)
									.optJSONArray("contents");
							if (array == null)// || array.length() == 0
								callback.feedHomeDatas(null);

							ArrayList<HomeOneDayData> dataInfos = new ArrayList<HomeOneDayData>();
							for (int i = 0; i < array.length(); i++) {
								try {
									JSONObject obj = array.getJSONObject(i);
									HomeOneDayData info = new HomeOneDayData();
									info.setAtttributeByjson(obj);
									dataInfos.add(info);
								} catch (JSONException e) {
									e.printStackTrace();
								}
							}
							callback.feedHomeDatas(dataInfos);
						}
					}
				});
		
	}
	
	public void requestOneDayPatients(long data,final OnDoctorHomeCallback callback){
		/**
		 * 这里时间一会儿需要减一天 一会儿需要增加一天才能拿到第二天的数据  暂时注释在这里 
		 */
//		String format = "yyyy-MM-dd";
//		Calendar calendar = Calendar.getInstance();
//		calendar.setTimeInMillis(data);
//		calendar.add(Calendar.DAY_OF_YEAR, -1);
//		String startDate = TimeFormatUtils.getTimeByFormat(calendar.getTimeInMillis(), format);
//		String toDate = TimeFormatUtils.getTimeByFormat(data, format);
//		String url = UriConstants.Conn.URL_PUB + "/timer/home.do";
//
//		HashMap<String, Object> map = new HashMap<String, Object>();
//		map.put("user_id", Constants.getUser().getUserId());// Constants.getUser().getUserId() 900000319
//		map.put("from_date", startDate);
//		map.put("to_date", toDate);
		String format = "yyyy-MM-dd";
		Calendar calendar = Calendar.getInstance();
		calendar.setTimeInMillis(data);
		calendar.add(Calendar.DAY_OF_YEAR, 1);
		String toDate = TimeFormatUtils.getTimeByFormat(calendar.getTimeInMillis(), format);
		String  startDate = TimeFormatUtils.getTimeByFormat(data, format);
		String url = UriConstants.Conn.URL_PUB + "/timer/home.do";

		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());// Constants.getUser().getUserId() 900000319
		map.put("from_date", startDate);
		map.put("to_date", toDate);
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		ApiSystem.getInstance().require(url, params, API_TYPE.BROW,
				new HalcyonHttpResponseHandle() {
					public void onError(int code, Throwable e) {
						e.printStackTrace();
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0 && type == 1) {
							JSONArray array = ((JSONObject) results)
									.optJSONArray("contents");
							if (array == null)// || array.length() == 0
								callback.feedHomeDatas(null);

							ArrayList<HomeOneDayData> dataInfos = new ArrayList<HomeOneDayData>();
							for (int i = 0; i < array.length(); i++) {
								try {
									JSONObject obj = array.getJSONObject(i);
									HomeOneDayData info = new HomeOneDayData();
									info.setAtttributeByjson(obj);
									dataInfos.add(info);
								} catch (JSONException e) {
									e.printStackTrace();
								}
							}
							callback.feedHomeDatas(dataInfos);
						}
					}
				});
		
	}
	
	public HttpRequestPotocol requestPatients(long date, int fromDay, int toDay,
			final OnDoctorHomeCallback callback) {
		long currentTime = System.currentTimeMillis();
		//小于10s不刷新数据
		if(currentTime - mLastRequestDataTime <= 500 || date == 0){
			callback.feedHomeDatas(null);
			return null;
		}
		mLastRequestDataTime = currentTime;
		String format = "yyyy-MM-dd";
		//Date currDate = TimeFormatUtils.getDate4Str(date, format);
		Calendar cal = Calendar.getInstance();
		String fromDate = "";
		String toDate = "";
		String currDdate = TimeFormatUtils.getTimeByFormat(date, format);
		if (fromDay == 0) {
			fromDate = currDdate;
		} else {
			cal.setTimeInMillis(date);
			cal.add(Calendar.DATE, -fromDay);
			fromDate = TimeFormatUtils.getTimeByFormat(cal.getTimeInMillis(),
					format);
		}
		if (toDay == 0) {
			toDate = currDdate;
		} else {
			cal.setTimeInMillis(date);
			cal.add(Calendar.DATE, toDay);
			toDate = TimeFormatUtils.getTimeByFormat(cal.getTimeInMillis(),
					format);
		}

		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());// Constants.getUser().getUserId() 900000319
		map.put("from_date", fromDate);
		map.put("to_date", toDate);

//		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
//		String url = UriConstants.Conn.URL_PUB + "/timer/list.do";
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		String url = UriConstants.Conn.URL_PUB + "/timer/home.do";

		final long from = TimeFormatUtils.getDate4Str(fromDate, format).getTime();
		final int size = fromDay+toDay;
		return ApiSystem.getInstance().require(url, params, API_TYPE.BROW,
				new HalcyonHttpResponseHandle() {
					public void onError(int code, Throwable e) {
						e.printStackTrace();
						callback.feedHomeDatas(fillList(null, from, size,null));
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0 && type == 1) {
							JSONArray array = ((JSONObject) results).optJSONArray("contents");
							if (array == null)// || array.length() == 0
								callback.feedHomeDatas(null);

							ArrayList<HomeOneDayData> dataInfos = new ArrayList<HomeOneDayData>();
							for (int i = 0; i < array.length(); i++) {
								try {
									JSONObject obj = array.getJSONObject(i);
									HomeOneDayData info = new HomeOneDayData();
									info.setAtttributeByjson(obj);
									dataInfos.add(info);
								} catch (JSONException e) {
									e.printStackTrace();
								}
							}
							
							//统计每天识别的病例数
							JSONArray numArray = ((JSONObject) results).optJSONArray("recongnizedNums");
							
							dataInfos = fillList(dataInfos, from, size,numArray);
							callback.feedHomeDatas(dataInfos);
						}
					}
				});
	}

	private ArrayList<HomeOneDayData> fillList(ArrayList<HomeOneDayData> dayDatas,long fromDate,int size, JSONArray numArray) {
		if(dayDatas == null || dayDatas.size() == 0){
			dayDatas = new ArrayList<HomeOneDayData>();
			Calendar cal = Calendar.getInstance();
			cal.setTimeInMillis(fromDate);
			for(int i = 0; i < size; i++){
				HomeOneDayData info = new HomeOneDayData();
				info.setCalendar(cal.getTimeInMillis());
				dayDatas.add(i, info);
				cal.add(Calendar.DATE, 1);
			}
			fillRecNum(dayDatas, numArray);
			return dayDatas;
		}
		
		if (dayDatas.size() >= size)
			return dayDatas;

		Calendar cal = Calendar.getInstance();
		Calendar calDate = Calendar.getInstance();
		cal.setTimeInMillis(fromDate);

		for(int i = 0; i < size; i++){
			if(dayDatas.size() <= i){
				HomeOneDayData info = new HomeOneDayData();
				info.setCalendar(cal.getTimeInMillis());
				dayDatas.add(i, info);
			}else{
				calDate.setTimeInMillis(dayDatas.get(i).getTimeMillis());
				if(cal.get(Calendar.DAY_OF_YEAR) != calDate.get(Calendar.DAY_OF_YEAR)){
					HomeOneDayData info = new HomeOneDayData();
					info.setCalendar(cal.getTimeInMillis());
					dayDatas.add(i, info);
				}
			}
			cal.add(Calendar.DATE, 1);
		}
		
		fillRecNum(dayDatas, numArray);
		
		return dayDatas;
	}

	/**
	 * 填充每天识别的病历数
	 * @param dayDatas
	 * @param numArray
	 */
	private void fillRecNum(ArrayList<HomeOneDayData> dayDatas,
			JSONArray numArray) {
		if (numArray != null) {
			for (int i = 0; i < numArray.length(); i++) {
				JSONObject temp = numArray.optJSONObject(i);
				String dateStr = temp.optString("date");
				long dateLong = TimeFormatUtils.getTimeMillisByDate(dateStr);
				int recongnizedNum = temp.optInt("recongnizedNum");
				boolean isExist = false;
				for (int j = 0; j < dayDatas.size() && !isExist; j++) {
					if (dayDatas.get(j).getTimeMillis() == dateLong) {
						dayDatas.get(j).setmRecRecongnizedNum(recongnizedNum);
						isExist = true;
					}
				}
			}
		}
	}
	
	/**
	 * @return 今天的index，如果没有返回-1
	 */
	public static int getCurrentDayIndex(ArrayList<HomeOneDayData> dayDatas) {
		for (int i = 0; i < dayDatas.size(); i++) {
			HomeOneDayData info = dayDatas.get(i);
			if(info.getCurrentSate() == CurrSate.CURR){
				return i;
			}
		}
		return -1;
	}

	public static LinkedHashMap<Integer, ArrayList<HomeOneDayData>> getPatientTree(
			ArrayList<HomeOneDayData> dayDatas) {
		LinkedHashMap<Integer, ArrayList<HomeOneDayData>> map = new LinkedHashMap<Integer, ArrayList<HomeOneDayData>>();

		for (HomeOneDayData data:dayDatas) {
			int month = data.getMonth();
			if (map.containsKey(month)) {
				map.get(month).add(data);
			} else {
				ArrayList<HomeOneDayData> dataInfos = new ArrayList<HomeOneDayData>();
				map.put(month, dataInfos);
				dataInfos.add(data);
			}
		}
		return map;
	}

	public static ArrayList<ArrayList<HomeOneDayData>> sortAndGroup(
			ArrayList<HomeOneDayData> data) {
		if(data != null){
			sort(data);
			return group(data);
		}
		return null;
	}
	
	
	public static int getFirstDayIndexInMonth(int year,int month,ArrayList<ArrayList<HomeOneDayData>> mData){
		Calendar cal = TimeFormatUtils.getCalendar4Str(year+"-"+month, "yyyy-MM");
		return getFirstDayIndexInMonth(cal, mData);
	}
	
	public static long getTimeInMillis(int year,int month){
		Calendar cal = TimeFormatUtils.getCalendar4Str(year+"-"+month, "yyyy-MM");
		return cal.getTimeInMillis();
	}
	
	public static Calendar getCalendar(int year,int month){
		return TimeFormatUtils.getCalendar4Str(year+"-"+month, "yyyy-MM");
	}
	
	public static int getFirstDayIndexInMonth(Calendar cal,ArrayList<ArrayList<HomeOneDayData>> mData){
		int year = cal.get(Calendar.YEAR);
		int month = cal.get(Calendar.MONDAY);
		if(mData != null){
			int index = 0;
			for(int i = 0; i < mData.size(); i++){
				HomeOneDayData oneDayData = mData.get(i).get(0);
				Calendar c = oneDayData.getCalendar();
				int m = c.get(Calendar.MONTH);
				int y = c.get(Calendar.YEAR);
				if(year == y && m == month){
					if(c.get(Calendar.DAY_OF_MONTH)== 1){
						return index;
					}
				}
				index += mData.get(i).size();
			}
		}
		return -1;
	}
	
	public static ArrayList<HomeOneDayData> sort(ArrayList<HomeOneDayData> data) {
		if(data != null){
			Collections.sort(data, new Comparator<HomeOneDayData>() {
				@Override
				public int compare(HomeOneDayData lhs, HomeOneDayData rhs) {
					long l = lhs.getTimeMillis();
					long r = rhs.getTimeMillis();
					if(l > r)return 1;
					if(l < r)return -1;
					return 0;
				}
			});
			return  data;
		}
		return null;
	}
	
	public static ArrayList<ArrayList<HomeOneDayData>> group(ArrayList<HomeOneDayData> data) {
		if(data != null){
			ArrayList<ArrayList<HomeOneDayData>> group= new ArrayList<ArrayList<HomeOneDayData>>();
			for (int i = 0; i < data.size(); i++) {
				ArrayList<HomeOneDayData> currentGroup = null;
				HomeOneDayData currnet = data.get(i);
				HomeOneDayData last = i-1 < 0 ? null : data.get(i-1);
				boolean createNew = false;
				if(group.isEmpty() || last == null){
					createNew = true;
				}else {
					if(last.getMonth() != currnet.getMonth()) createNew = true;
				}
				if(createNew){
					currentGroup = new ArrayList<HomeOneDayData>();
					group.add(currentGroup);
				}
				currentGroup = group.get(group.size() - 1);
				currentGroup.add(currnet);
			}
			return group;
		}
		return null;
	}
	
	
	public interface OnDoctorHomeCallback {
		public void errorMonth(String msg);

		public void feedMonth(Map<Integer, ArrayList<Integer>> data);

		public void error(String msg);

		public void feedHomeDatas(ArrayList<HomeOneDayData> infos);
	}
	
	public static long getMinMonthTime(Map<Integer, ArrayList<Integer>> mMonth){
		if (mMonth == null || mMonth.isEmpty())
			return new Date().getTime();
		Iterator<Integer> keys = mMonth.keySet().iterator();
		int year = 0;
		while (keys.hasNext()) {
			int key = (Integer) keys.next();
			if (year == 0 || key < year) {
				year = key;
			}
		}
		ArrayList<Integer> monthArray = mMonth.get(year);
		int month = 0;
		for (int i = 0; i < monthArray.size(); i++) {
			int tmp = monthArray.get(i);
			if (month == 0 || month > tmp) {
				month = tmp;
			}
		}
		Calendar calendar = Calendar.getInstance();
		calendar.set(year, month - 1, 0);
		return calendar.getTimeInMillis();
	}
}
