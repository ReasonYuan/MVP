package com.fq.lib.tools;

import java.util.ArrayList;
import java.util.Calendar;

import com.fq.halcyon.entity.OnceFollowUpCycle;

public class SettingFollowUpManager {
	
	
	/**
	 * 计算所有随访的随访时间
	 * @param mCycles
	 * @return
	 */
	public static ArrayList<OnceFollowUpCycle> calculationAllTime(ArrayList<OnceFollowUpCycle> mCycles,String modifytime){
		mCycles.get(0).setmTimerDate(modifytime);
		for (int i = 0; i < mCycles.size()-1; i++) {
			OnceFollowUpCycle mCurrentCycle = mCycles.get(i);
			OnceFollowUpCycle mNextCycle = mCycles.get(i+1);
			if (!mNextCycle.getmItentValue().equals("") &&  !mNextCycle.getmItemUnit().equals("")) {
				String date = calculationNextTime(mCurrentCycle.getmTimerDate(), Integer.parseInt(mNextCycle.getmItentValue()), mNextCycle.getmItemUnit());
				mCycles.get(i+1).setmTimerDate(date);
				System.out.println("time_date~~~~~~~~~"+date);
			}
		}
		return mCycles;
	}
	/**
	 * 计算下一次随访的随访时间
	 * @param mTmpDate 上一次随访的时间
	 * @param addCount 时间大小
	 * @param mUnit  时间单位
	 * @return
	 */
	public static String calculationNextTime(String mTmpDate,int addCount,String mUnit){
		long time = TimeFormatUtils.getTimeMillisByDate(mTmpDate);
		String date = setTime(time, mUnit, addCount);
		return date;
	}
	
	/**
	 * 设置计算闹钟时间
	 * @param time
	 * @param str
	 * @param addcount
	 * @return
	 */
	public static String setTime(long time,String str,int addcount){
		Calendar mCalendar = Calendar.getInstance();
		mCalendar.setTimeInMillis(time);
		if (str.equals("day")) {
			mCalendar.add(Calendar.DAY_OF_MONTH, addcount);
		}else if (str.equals("week")) {
			mCalendar.add(Calendar.DAY_OF_MONTH, addcount*7);
		}else if (str.equals("month")) {
			mCalendar.add(Calendar.MONTH, addcount);
		}else if (str.equals("year")) {
			mCalendar.add(Calendar.YEAR, addcount);
		}
		
		String date = TimeFormatUtils.getTimeByFormat(mCalendar.getTime().getTime(), "yyyy-MM-dd");
		return date;
	}
	
	/**
	 * 计算每次闹钟的时间 返回类型为long
	 * @param time
	 * @return
	 */
	public static long calculationOnceAlarmLongTime(long time){
		Calendar mCalendar = Calendar.getInstance();
		mCalendar.setTimeInMillis(time);
		mCalendar.add(Calendar.HOUR_OF_DAY, -12);
		long mTime = mCalendar.getTime().getTime();
		String date = TimeFormatUtils.getTimeByFormat(mTime, "yyyy-MM-dd HH:mm:ss");
		return mTime;
	}
	
}
