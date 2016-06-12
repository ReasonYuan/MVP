package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.HalcyonHttpResponseHandle.HalcyonHttpHandleDelegate;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.TimeFormatUtils;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class StructuredLogic {

	@Weak
	public HalcyonHttpHandleDelegate delegate;

	public StructuredLogic() {

	}

	public void requireData(int patientId) {
		JSONObject params = new JSONObject();
		try {
			params.put("patient_id", patientId);
		} catch (Exception e) {
			e.printStackTrace();
		}
		// String url =
		// UriConstants.Conn.URL_PUB+"/record-structuring/patientInfo/event_list.do ";
		String url = UriConstants.Conn.URL_PUB +"/patientInfo/event_list.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {
			@Override
			public void onError(int code, Throwable e) {
				if (delegate != null)
					delegate.handleError(code, e);
			}

			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if (delegate != null && responseCode == 0 && type == 1) {
					paserJsonObjec((JSONObject)results);
				}else {
					if (delegate != null)
						delegate.handleError(-1, new Throwable("数据格式错误！"+results.toString()));
				}
			}
		});
	}

	public void paserJsonObjec(JSONObject object) {
		JSONArray symptoms = object.optJSONArray("symptoms");  //症状
		JSONArray checkups = object.optJSONArray("checkups");  //检查
		JSONArray examinations = object.optJSONArray("examinations"); //化验
		JSONArray discharges = object.optJSONArray("discharges"); //出院
		JSONArray treatments = object.optJSONArray("treatments"); //用药
		JSONArray diagnosis = object.optJSONArray("diagnosis"); //诊断
		JSONArray incidences = object.optJSONArray("incidences"); //什么鬼？发病率？
		//结构化的表用到的数据有symptoms，diagnosis，checkups，treatments
		//第一步，把相同时间的放在一起
		JSONObject days = new JSONObject();
		setValue(days, symptoms, "symptoms");
		setValue(days, checkups, "checkups");
		setValue(days, discharges, "discharges");
		setValue(days, treatments, "treatments");
		setValue(days, diagnosis, "diagnosis");
		Iterator<String> iterator = days.keys();
		ArrayList<String> keys = new ArrayList<String>();
		try {
			while (iterator.hasNext()) {
				String key = iterator.next();
				keys.add(key);
				JSONObject day = days.getJSONObject(key);
				Calendar calendar = TimeFormatUtils.getCalendar4Str(key, "yyyy-MM-dd");
				if(calendar == null) calendar = TimeFormatUtils.getCalendar4Str(key, "yyyy年MM月dd日");
                if(calendar == null) calendar = TimeFormatUtils.getCalendar4Str(key, "dd/MM/yyy");
				if(calendar == null) {
					days.remove(key);
					continue;
				};
				day.put("year", calendar.get(Calendar.YEAR));
				day.put("month", calendar.get(Calendar.MONTH));
				day.put("day", calendar.get(Calendar.DAY_OF_MONTH));
				if(day != null){
					int symptomsLength = getLength(day, "symptoms");
					int checkupsLength = getLength(day, "checkups");
					int treatmentsLength = getLength(day, "treatments");
					int diagnosisLength = getLength(day, "diagnosis");
					day.put("maxSize", getMax(symptomsLength,checkupsLength,treatmentsLength,diagnosisLength,getLength(day, "discharges")));
					day.put("date",key);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		//to jsonArray
		Collections.sort(keys, new Comparator<String>() {
			@Override
			public int compare(String lhs, String rhs) {
				Calendar ca1 = TimeFormatUtils.getCalendar4Str(lhs, "yyyy-MM-dd");
				if(ca1 == null) ca1 = TimeFormatUtils.getCalendar4Str(lhs, "yyyy年MM月dd日");
                if(ca1 == null) ca1 = TimeFormatUtils.getCalendar4Str(lhs, "dd/MM/yyy");
				Calendar ca2 = TimeFormatUtils.getCalendar4Str(rhs, "yyyy-MM-dd");
				if(ca2 == null) ca2 = TimeFormatUtils.getCalendar4Str(rhs, "yyyy年MM月dd日");
                if(ca2 == null) ca2 = TimeFormatUtils.getCalendar4Str(rhs, "dd/MM/yyy");
				if(ca1.equals(ca2))return 0;
				boolean before = ca1.before(ca2);
				if(before) return 1;
				return -1;
			}
		});
		JSONArray array = new JSONArray();
		for (int i = 0; i < keys.size(); i++) {
			array.put(days.opt(keys.get(i)));
		}
		delegate.handleSuccess(array);
	}

	private int getLength(JSONObject day,String key) {
		JSONArray array = day.optJSONArray(key);
		if(array != null)return array.length();
		return 0;
	}
	
	private int getMax(int...args){
		int max = -1;
		for (int i = 0; i < args.length; i++) {
			if (max < args[i]) {
				max = args[i];
			}
		}
		if(max < 2)max = 2;
		return max;
	}
	
	private void setValue(JSONObject dst,JSONArray src,String name){
		try {
			if(src != null && src.length() > 0){
				for (int i = 0; i < src.length(); i++) {
					JSONObject object = src.optJSONObject(i);
					if(object != null){
						String date = jsonObjectOptiemTime(object);
						if(!date.equals("")){
							JSONObject object2 = dst.optJSONObject(date);
							if(object2 == null){
								object2 = new JSONObject();
								dst.put(date, object2);
							}
							JSONArray array = object2.optJSONArray(name);
							if(array == null){
								array = new JSONArray();
								object2.put(name, array);
							}
							array.put(object);
						}
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private String jsonObjectOptiemTime(JSONObject object){
		if(object != null){
			String time = object.optString("diseaseTime");
			if(time.equals(""))time = object.optString("dealTime");
			if(time.equals(""))time = object.optString("diagnosisTime");
			if(time.equals(""))time = object.optString("treatTime");
			if(!time.equals("") && time.indexOf(" ") > 0){
				time = time.substring(0,time.indexOf(" "));
			}
			return time;
		}
		return "";
	}
	
	public void paserJson(String json) {
		try {
			JSONObject jsonObject = new JSONObject(json);
			if(jsonObject.optInt("response_code") == 0){
				paserJsonObjec(jsonObject.optJSONObject("results"));
			}else {
				if(delegate != null){
					delegate.handleError(jsonObject.optInt("response_code"), new Throwable(jsonObject.optString("msg")));
				}
			}
			
		} catch (JSONException e) {
			e.printStackTrace();
			if(delegate != null){
				delegate.handleError(-1, new Throwable(e.getMessage()));
			}
		}
		
	}
}
