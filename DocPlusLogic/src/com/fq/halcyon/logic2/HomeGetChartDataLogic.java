package com.fq.halcyon.logic2;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.TimeFormatUtils;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 图表数据的数据类型
 * 
 * @author liaomin
 * 
 */
class ChartEntity {

	/**
	 * 图表的时间，格式yyyy-MM-dd
	 */
	public String date = null;

	/**
	 * 年份
	 */
	public int year = 0;

	/**
	 * 在年中得月份 0 - 11
	 */
	public int monthInYear = 0;

	/**
	 * 在月份中得天数 1 - 31
	 */
	public int dayInMonth = 0;

	/**
	 * 数据，上传量或病历的份数
	 */
	public int copies = 0;

	public ChartEntity(String pdate) {
		this.date = pdate;
		Calendar calendar = TimeFormatUtils.getCalendar4Str(this.date, "yyyy-MM-dd");
		if (calendar != null) {
			this.year = calendar.get(Calendar.YEAR);
			this.monthInYear = calendar.get(Calendar.MONTH);
			this.dayInMonth = calendar.get(calendar.DAY_OF_MONTH);
		}
	}

	public ChartEntity(Calendar calendar) {
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern("yyyy-MM-dd");
		this.date = dft.format(calendar.getTime());
		if (calendar != null) {
			this.year = calendar.get(Calendar.YEAR);
			this.monthInYear = calendar.get(Calendar.MONTH);
			this.dayInMonth = calendar.get(calendar.DAY_OF_MONTH);
		}
	}

	public String getChineseDescription() {
		return getChineseDescription("yyyy年MM月");
	}

	public String getChineseDescriptionYYYY() {
		return getChineseDescription("yyyy年");
	}

	public String getChineseDescriptionMM() {
		return getChineseDescription("MM月dd日");
	}

	private String getChineseDescription(String format) {
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern(format);
		Calendar calendar = TimeFormatUtils.getCalendar4Str(this.date, "yyyy-MM-dd");
		return dft.format(calendar.getTime());
		
	}
	
	public boolean isToday(){
		Calendar calendar = TimeFormatUtils.getCalendar4Str(this.date, "yyyy-MM-dd");
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern("yyyy-MM-dd");
		String tody = dft.format(new Date());
		Calendar calendar2 = TimeFormatUtils.getCalendar4Str(tody, "yyyy-MM-dd");
		return calendar.equals(calendar2);
	}
	
	public boolean afterToday() {
		Calendar calendar = TimeFormatUtils.getCalendar4Str(this.date, "yyyy-MM-dd");
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern("yyyy-MM-dd");
		String tody = dft.format(new Date());
		Calendar calendar2 = TimeFormatUtils.getCalendar4Str(tody, "yyyy-MM-dd");
		return calendar.after(calendar2);
	}
	
	public boolean beforeToday() {
		Calendar calendar = TimeFormatUtils.getCalendar4Str(this.date, "yyyy-MM-dd");
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern("yyyy-MM-dd");
		String tody = dft.format(new Date());
		Calendar calendar2 = TimeFormatUtils.getCalendar4Str(tody, "yyyy-MM-dd");
		return calendar.before(calendar2);
	}
	
	@Override
	public String toString() {
		return this.date;
	}
}

/**
 * 主页获取图表数据的逻辑代码。
 * 
 * @author liaomin
 */
public class HomeGetChartDataLogic {

	/**
	 * 回调接口
	 * 
	 * @author liaomin
	 * 
	 */
	public interface GetChartDatCallBack {
		/**
		 * 成功请求到图表数据
		 * 
		 * @param data
		 *            数据
		 * @param type
		 *            1：表示请求病案总量图表 2：表示请求每日上传图表
		 */
		public void onGetChartData(ArrayList<ChartEntity> data, int type);

		/**
		 * 
		 * @param returnData
		 *            like
		 *            {“patient_count”:1,“record_count”:2,“today_record_count
		 *            ”:3,“today_image_count”:4}
		 */
		public void onGetTotalCount(JSONObject returnData);
		
		public void onInsightDataReturn(JSONObject returnData);

		public void onError(int code, String msg);
	}

	@Weak
	private GetChartDatCallBack mCallBack;

	public HomeGetChartDataLogic(GetChartDatCallBack callBack) {
		mCallBack = callBack;
	}

	/**
	 * 请求图表的数据
	 * 
	 * @param type
	 *            1：表示请求病案总量图表 2：表示请求每日上传图表
	 */
	public void requireChartData(String fromDate, String toData, int type) {
		final Calendar start = TimeFormatUtils.getCalendar4Str(fromDate, "yyyy-MM-dd");
		final Calendar end = TimeFormatUtils.getCalendar4Str(toData, "yyyy-MM-dd");
		final int requstType = type;
		if (start == null || end == null) {
			System.err.println("请求数据格式错误！" + fromDate + " " + toData);
			return;
		}
		if (start.after(end)) {
			System.err.println("请求数据格式错误！from在end之后" + fromDate + " " + toData);
			return;
		}
		String baseUrl = UriConstants.Conn.URL_PUB;
		if (type == 1) {
			baseUrl += "/home/patient_daily.do";
		} else if (type == 2) {
			baseUrl += "/home/record_daily.do";
		} else {
			return;
		}
		JSONObject params = new JSONObject();
		try {
			params.put("user_id", Constants.getUser().getUserId());
			params.put("from_date", fromDate);
			params.put("to_date", toData);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		ApiSystem.getInstance().require(baseUrl, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				if (mCallBack != null) {
					mCallBack.onError(code, "请求图表数据错误：" + e.getMessage());
				}
			}

			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if (mCallBack != null && responseCode == 0 && type == 2) {
					JSONArray array = (JSONArray) results;
					ArrayList<ChartEntity> data = new ArrayList<ChartEntity>();
					while ((start.before(end) || (start.equals(end)))) {
						boolean found = false;
						for (int i = 0; i < array.length(); i++) {
							JSONObject item = array.optJSONObject(i);
							if (item != null) {
								String tmpDate = item.optString("date");
								Calendar tmpCalendar = TimeFormatUtils.getCalendar4Str(tmpDate, "yyyy-MM-dd");
								if (tmpCalendar.equals(start)) {
									ChartEntity entity = new ChartEntity(tmpDate);
									entity.copies = item.optInt("count");
									data.add(entity);
									array.remove(i);
									found = true;
									break;
								}
							}
						}
						if (!found) {
							data.add(new ChartEntity(start));
						}
						start.add(Calendar.DAY_OF_YEAR, 1);
					}
					mCallBack.onGetChartData(data, requstType);
				} else if (responseCode != 0) {
					if (mCallBack != null) {
						mCallBack.onError(responseCode, "请求图表数据服务器返回数据不对：" + msg);
					}
				}
			}
		});
	}

	public void requireDaily() {
		
	}
	
	public void requireTotalCount() {
		JSONObject params = new JSONObject();
		try {
			params.put("user_id", Constants.getUser().getUserId());
		} catch (JSONException e) {
			e.printStackTrace();
		}
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/home/get_patient_record_count.do", new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				if (mCallBack != null) {
					mCallBack.onError(code, "请求总量数据错误：" + e.getMessage());
				}
			}

			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if (mCallBack != null && responseCode == 0 && type == 1) {
					mCallBack.onGetTotalCount((JSONObject) results);
				} else if (responseCode != 0) {
					if (mCallBack != null) {
						mCallBack.onError(responseCode, "请总量数据服务器返回数据不对：" + msg);
					}
				}
			}
		});
	}
	
	public void requireInsight(){
		JSONObject params = new JSONObject();
		try {
			params.put("user_id", Constants.getUser().getUserId());
		} catch (JSONException e) {
			e.printStackTrace();
		}
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/home/get_diagnosis_and_symptom.do", new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				if (mCallBack != null) {
					mCallBack.onError(code, "请求Insight数据错误：" + e.getMessage());
				}
			}

			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if (mCallBack != null && responseCode == 0 && type == 1) {
					mCallBack.onInsightDataReturn((JSONObject) results);
				} else if (responseCode != 0) {
					if (mCallBack != null) {
						mCallBack.onError(responseCode, "请Insight数据服务器返回数据不对：" + msg);
					}
				}
			}
		});
	}

	public static String getStartDateFormate(ChartEntity endentity, int length) {
		if (endentity != null) {
			return getStartDateFormate(endentity.date, length);
		}
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern("yyyy-MM-dd");
		return dft.format(new Date());
	}

	public static String getStartDateFormate(String endFormat, int length) {
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern("yyyy-MM-dd");
		if (length > 1) {
			Calendar calendar = TimeFormatUtils.getCalendar4Str(endFormat, "yyyy-MM-dd");
			if (calendar != null) {
				for (int i = 0; i < length-1; i++) {
					calendar.add(Calendar.DAY_OF_YEAR, -1);
				}
				return dft.format(calendar.getTime());
			}
		}
		return dft.format(new Date());
	}

	public static String getEndDateFormate(ChartEntity endentity, int length) {
		if (endentity != null) {
			return getStartDateFormate(endentity.date, length);
		}
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern("yyyy-MM-dd");
		return dft.format(new Date());
	}

	public static String getEndDateFormate(String startFormat, int length) {
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern("yyyy-MM-dd");
		if (length > 0) {
			Calendar calendar = TimeFormatUtils.getCalendar4Str(startFormat, "yyyy-MM-dd");
			if (calendar != null) {
				for (int i = 0; i < length; i++) {
					calendar.add(Calendar.DAY_OF_YEAR, +1);
				}
				return dft.format(calendar.getTime());
			}
		}
		return dft.format(new Date());
	}
	
	public static ArrayList<ChartEntity> getEmptyChartEntities(String fromDate, String toData) {
		Calendar start = TimeFormatUtils.getCalendar4Str(fromDate, "yyyy-MM-dd");
		Calendar end = TimeFormatUtils.getCalendar4Str(toData, "yyyy-MM-dd");
		ArrayList<ChartEntity> data = new ArrayList<ChartEntity>();
		while (start.before(end)) {
			ChartEntity entity = new ChartEntity(start);
			data.add(entity);
			start.add(Calendar.DAY_OF_YEAR, 1);
		}
		return data;
	}

	public static ArrayList<ChartEntity> getRandomChartEntities(String fromDate, String toData) {
		Calendar start = TimeFormatUtils.getCalendar4Str(fromDate, "yyyy-MM-dd");
		Calendar end = TimeFormatUtils.getCalendar4Str(toData, "yyyy-MM-dd");
		ArrayList<ChartEntity> data = new ArrayList<ChartEntity>();
		while (start.before(end)) {
			ChartEntity entity = new ChartEntity(start);
			entity.copies = (int) (Math.random() * 100 + 1);
			data.add(entity);
			start.add(Calendar.DAY_OF_YEAR, 1);
		}
		return data;
	}
}
