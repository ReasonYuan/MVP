package com.fq.halcyon.practice;

import java.util.Calendar;
import java.util.Random;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.TimeFormatUtils;

public class ExamChartTools {

	public static String getCallFunc(String examItemName,JSONArray array){
		
		int length = array.length()>40?40:array.length();//
		
		JSONArray times = new JSONArray();
		JSONArray values = new JSONArray();
		Calendar cal = Calendar.getInstance();
		Random random = new Random();
		cal.add(Calendar.DATE, -random.nextInt(500));
		for(int i = 0; i < length; i++){
			try {
				JSONObject json = array.getJSONObject(i);
				values.put(json.optInt("exam_value"));
				
				cal.add(Calendar.DATE, random.nextInt(10));//random.nextInt(10)
				String time = TimeFormatUtils.getTimeByFormat(cal.getTimeInMillis(), "yyyy-MM-dd");
//				String time = i+"";//json.optString("report_time","null");
				times.put(time);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		String call = "drawChart('"+examItemName+"','"+times.toString()+"','"+values.toString()+"')";
		return call;
	}
}
