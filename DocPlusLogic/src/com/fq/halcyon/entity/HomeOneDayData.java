package com.fq.halcyon.entity;

import java.util.ArrayList;
import java.util.Calendar;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.TimeFormatUtils;

/**
 * 首页，一天的数据
 * @author reason
 */
public class HomeOneDayData extends HalcyonEntity{

	public enum CurrSate{
		BEFO,
		CURR,
		AFTER
	}
	
	private static final long serialVersionUID = 1L;

	private ArrayList<HomeData> mHomeDatas = new ArrayList<HomeData>();

	private Calendar mCalendar = Calendar.getInstance();
	
	private CurrSate mCurrState;
	
	/**
	 * 当天病历记录识别数， 默认为0, 如果服务器有数据，则填充为服务器数据
	 */
	private int mRecRecongnizedNum = 0;
	
	/**
	 * 当天病历记录识别数
	 * @return
	 */
	public int getmRecRecongnizedNum() {
		return mRecRecongnizedNum;
	}

	public void setmRecRecongnizedNum(int mRecRecongnizedNum) {
		this.mRecRecongnizedNum = mRecRecongnizedNum;
	}

	public ArrayList<HomeData> getDatas(){
		return mHomeDatas;
	}
	
	public int getDataCount(){
		return mHomeDatas.size();
	}
	
	public HomeData getData(int index){
		return mHomeDatas.get(index);
	}
	
	public CurrSate getCurrentSate(){
		return mCurrState;
	}
	
	public long getTimeMillis(){
		return mCalendar.getTimeInMillis();
	}
	
	public Calendar getCalendar(){
		return mCalendar;
	}
	
	public int getMonth(){
		return mCalendar.get(Calendar.MONTH);
	}
	
	public int getDayOfWeek(){
		return mCalendar.get(Calendar.DAY_OF_WEEK)-1;
	}
	
	public int getDayOfMonth(){
		return mCalendar.get(Calendar.DAY_OF_MONTH);
	}
	
	public boolean isHaveUnReadData(){
		for(HomeData data:mHomeDatas){
			if(!data.isRead()){
				return true;
			}
		}
		return false;
	}
	
	public void setCalendar(long timeMillis){
//		mCalendar.setFirstDayOfWeek(Calendar.SUNDAY);
		mCalendar.setTimeInMillis(timeMillis);
		
		int state = TimeFormatUtils.dataCompare(timeMillis);
		switch (state) {
		case -1:
			mCurrState = CurrSate.BEFO;break;
		case 0:
			mCurrState = CurrSate.CURR;break;
		case 1:
			mCurrState = CurrSate.AFTER;break;
		}
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		
		String date = json.optString("date");
		if(date != null && !"".equals(date)){
			long time = TimeFormatUtils.getTimeMillisByDate(date);
			setCalendar(time);
		}
		mHomeDatas.clear();
		JSONArray array = json.optJSONArray("followups");
		for(int i = 0; i < array.length(); i++){
			try {
				HomeData data = new HomeData();
				data.setAtttributeByjson(array.getJSONObject(i));
				mHomeDatas.add(data);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
	}
}
