package com.fq.lib.tools;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * 关于时间的工具类</br>
 * y:年--M:月--d:日--H:时(24)--h:时(12)--m:分--s:秒--a:AM/PM标记
 * @author reason
 */
public class TimeFormatUtils {

	public static String[] WEEK_US = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
	public static String[] WEEK_CN = {"星期天","星期一","星期二","星期三","星期四","星期五","星期六"};
	public static String[] MONTH_US = {"January","February","March","April","May","June","July","August","September","October","November","December"};
	public static String[] MONTH_US_IOS = {"Jan.","Feb.","Mar.","Apr.","May.","Jun.","Jul.","Aug.","Sep.","Oct.","Nov.","Dec."};
	private static final String[] WEEKS = {"Sun","Mon","Tues","Wed","Thur","Fri","Sat"};
	
	private static final String[] HISTORY_TITLES = {"今日","昨日","一周","更早"};
	
	/**
	 * 根据id获得今日、昨日等
	 */
	public static String getTitleByindex(int index){
		try{
			return HISTORY_TITLES[index];
		}catch(Exception e){
			return "";
		}
	}
	
	public static String getMonthDescription(int index){
		if(index >= 0 && index < MONTH_US_IOS.length){
			return MONTH_US_IOS[index];
		}else{
			return "";
		}
	}
	
	/**
	 * @param startTime 起始时间（精确到秒）
	 * @param endTime 和束时间（精确到秒）
	 * @return 从某时到某时所用的时间(精确到秒)，格式：5天1°3'20"。时间错误返回""。
	 */
	public static String getUseDay(long startTime,long endTime){
		long time = endTime - startTime;
		if (time <= 0) {
			return "";
		}

		long sec = time % 60;
		long temp = time / 60;
		if (temp == 0) {
			return sec + "\"";
		}
		long min = temp % 60;
		temp = temp / 60;
		if (temp == 0) {
			return min + "'" + sec + "\"";
		}

		long hour = temp % 24;
		temp = temp / 24;
		if (temp == 0) {
			return hour + "°" + min + "'" + sec + "\"";
		}
		return temp + "天" + hour + "°" + min + "'" + sec + "\"";
	}

	/**
	 * @param time 1970年后的毫秒数
	 * @param format 需要返回的日期的格式，如：yy.MM.dd
	 * @return 期望格式的日期。时间错误返回""。
	 */
	public static String getTimeByFormat(long time,String format){
		if(time <= 0){
            return "";
        }
		Date date = new Date(time);
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern(format);
		return dft.format(date);
	}
	
	/**
	 * @param time 1970年后的毫秒数
	 * @return "yyyy/MM/dd HH:mm AM/PM"
	 */
	public static String getTimeByFormat(long time){
		String dateTime = "";
		if(time <= 0){
			return "";
		}
		Date date = new Date(time);
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern("yyyy/MM/dd HH:mm");
		dateTime = dft.format(date);
		if(date.getHours() < 12){
			dateTime = dateTime + " AM";
		}else{
			dateTime = dateTime + " PM";
		}
		return dateTime;
	}
	
	/**
	 * 将字符串格式的日期转换为Date
	 * @param dateStr 日期
	 * @param format 日期的类型
	 * @return
	 */
	public static Date getDate4Str(String dateStr,String format){
//		SimpleDateFormat formatDate = new SimpleDateFormat(format);
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern(format);
        //String str = formatDate.format(dateStr);
        try {
           Date time = dft.parse(dateStr);
           return time;//formatDate.format(time);
        } catch (ParseException e) {
            e.printStackTrace();
            return null;
        }
	}
	
	/**
	 * 将字符串格式的日期转换为Calender
	 * @param dateStr 日期
	 * @param format 日期的类型
	 * @return
	 */
	public static Calendar getCalendar4Str(String dateStr,String format){
		SimpleDateFormat dft = (SimpleDateFormat) SimpleDateFormat.getDateInstance();
		dft.applyPattern(format);
        try {
           Date time = dft.parse(dateStr);
           Calendar cal = Calendar.getInstance();
           cal.setTime(time);
           return cal;
        } catch (ParseException e) {
            e.printStackTrace();
            return null;
        }
	}
	
	
	
	
	/**
	 * 获取英文的星期几
	 * @param date
	 *                      -- 日期的long型参数
	 * @return eg. Sunday
	 */
	public static String getUSWeek(long date){
		Date mDate = new Date(date);
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(mDate);
		String week = WEEK_US[calendar.get(Calendar.DAY_OF_WEEK) - 1];
		return week;
	}
	
	/**
	 * 获取中文的年月日 星期
	 * @param date
	 *                      -- 日期的long型参数
	 * @return  eg. 2014年12月23日 星期二
	 */
	public static String getCNDate(long date){
		Date mDate = new Date(date);
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(mDate);
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy年MM月dd日");
		String dateResult = simpleDateFormat.format(mDate) + " "+WEEK_CN[calendar.get(Calendar.DAY_OF_WEEK) - 1];
		return dateResult;
	}
	
	/**
	 * 获取中文的年月日 星期
	 * @param date
	 *                      -- 日期的long型参数
	 * @return  eg. 2014/12/23日 星期二
	 */
	public static String getCNDate2(long date){
		Date mDate = new Date(date);
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(mDate);
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy/MM/dd");
		String dateResult = simpleDateFormat.format(mDate) + " "+WEEK_CN[calendar.get(Calendar.DAY_OF_WEEK) - 1];
		return dateResult;
	}
	
	/**
	 * 获取英文的年月日
	 * @param date
	 *                      -- 日期的long型参数
	 * @return  eg. January 6th,2014
	 */
	public static String getUSDate(long date){
		Date mDate = new Date(date);
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(mDate);
		String month = MONTH_US[calendar.get(Calendar.MONTH)];
		String day = calendar.get(Calendar.DAY_OF_MONTH) + "th,";
		String year = calendar.get(Calendar.YEAR) + "";
		String dateResult = month + " " + day + year;
		return dateResult;
	}
	
	/**
	 * 获取日期格式 yyyy-MM-dd
	 * @param date
	 *                      -- 日期的long型参数
	 */
	public static String getStrDate(long date){
		Date mDate = new Date(date);
		String remindDate = new SimpleDateFormat("yyyy-MM-dd").format(mDate);
		return remindDate;
	}
	
	/**将字符串(yyyy-MM-dd格式)转为时间戳*/
    public static long getTimeMillisByDate(String time) {
    	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date date = new Date();
        try{
            date = sdf.parse(time);
        } catch(ParseException e) {
            FQLog.i("TimeFormatUtils.getTimeMillisByDate()解析yyyy-MM-dd格式的时间:"+time+"->为Date出错");
        }
        return date.getTime();
    }
    
	/**将字符串(yyyy-MM-dd HH:mm:ss格式)转为时间戳*/
    public static long getTimeMillisByDateWithSeconds(String time) {
    	if("".equals(time)){
    		FQLog.i("TimeFormatUtils.getTimeMillisByDateWithSeconds(String time)传入时间参数为空，无法解析");
    		return System.currentTimeMillis();
    	}
    	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date date = new Date();
        try{
            date = sdf.parse(time);
        } catch(ParseException e) {
        	 FQLog.i("TimeFormatUtils.getTimeMillisByDateWithSeconds()解析yyyy-MM-dd HH:mm:ss格式的时间:"+time+"->为Date出错");
            e.printStackTrace();
//            return System.currentTimeMillis();
        }
        return date.getTime();
    }
    
    /**将字符串(yyyy-MM-dd HH:mm:ss格式)转为时间戳*/
    public static long getTimeMillisByDateWithSeconds(String time,String foamat) {
    	if("".equals(time)){
    		FQLog.i("TimeFormatUtils.getTimeMillisByDateWithSeconds(String time,String foamat)传入时间参数为空，无法解析");
    		return System.currentTimeMillis();
    	}
    	SimpleDateFormat sdf = new SimpleDateFormat(foamat);
        Date date = new Date();
        try{
            date = sdf.parse(time);
        } catch(ParseException e) {
            e.printStackTrace();
//            return System.currentTimeMillis();
        }
        return date.getTime();
    }
	
    /**
     * 将时间字符串(yyyy-MM-dd)转换为指定的形式
     * @param time
     * @param format
     * @return
     */
    public static String getTimeByStr(String time, String format){
    	if("".equals(time)){
    		FQLog.i("TimeFormatUtils.getTimeByStr(String time,String foamat)传入时间参数为空，无法解析");
    		return "";
    	}
    	String remindDate = "";
    	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date date = new Date();
        try{
            date = sdf.parse(time);
            remindDate = new SimpleDateFormat(format).format(date);
        } catch(ParseException e) {
            e.printStackTrace();
        }
        return remindDate;
    }
    
    /**
     * 得到英文的星期几(简写版，例：Sun、Mon)
     * @param day 一星期的第几天，星期天为第0天
     * @return
     */
	public static String getdayOfWeek(int day){
		return WEEKS[day];
	}
	
	/**
	 * 日期（与当前系统时间）的比较 
	 * @param timeMillis 传入时间的毫秒数，必须精确到天（即 时分秒毫秒都为0） 
	 * @return 0：传入时间就是今天； -1：传入时间小于今天； 1： 传入时间大于今天
	 */
	public static int dataCompare(long timeMillis){
		long temp = System.currentTimeMillis()/1000*1000;
		long todayTime = TimeFormatUtils.getTimeMillisByDate(TimeFormatUtils.getStrDate(temp));
		if(timeMillis == todayTime)return 0;
		else if(timeMillis < todayTime)return -1;
		else return 1;
		
	}
	
	/**
	 * 将yyyy-MM-dd HH:mm:ss格式的日期转为yyyy年MM月dd日
	 * @param time
	 */
	public static String changeDealTime(String time){
		SimpleDateFormat sdf = (SimpleDateFormat) SimpleDateFormat.getInstance();
		sdf.applyPattern("yyyy-MM-dd HH:mm:ss");
		try{
			Date date = sdf.parse(time);
			sdf.applyPattern("yyyy年MM月dd日");
			return sdf.format(date);
		}catch (Exception e){
			return "";
		}
	}
	
	/**
	 * 将格式为yyyy-MM-dd HH:mm:ss格式的时间转化为yyyyMMdd<br/>
	 * 主要用于UI上列表的Group Head
	 * @param time 需要转化的时间
	 * @return
	 */
	public static String turnTime(String time){
		if("".equals(time))return "";
		String tmp = time.substring(0,10);
		return tmp.replaceAll("-", "");
	}
	
	/**
	 * 得到系统当天的零时的毫秒数
	 * @return 当天零时的毫秒数
	 */
	public static long getCurrentZeroTime(){
		Calendar today = Calendar.getInstance();
        today.set(Calendar.HOUR_OF_DAY,0);
		today.set(Calendar.SECOND, 0);
		today.set(Calendar.MILLISECOND, 0);
		return today.getTimeInMillis();
	}
	
	/**
	 * 根据日期时间获得属于哪一个类型的
	 * @param todayMills 判断所依据的日期的毫秒数
	 * @param cal 需要判断的日期
	 * @return 属于哪一个类型：今日、昨日、一周、更早
	 */
	public static String getHeadByTime(long todayMills,Calendar cal){
		try{
			long time = cal.getTimeInMillis();	
			return getHeadByTime(todayMills,time);
		}catch(Exception e){
			return "";
		}
	}
	
	/**
	 * 根据日期时间获得属于哪一个类型的
	 * @param todayMills 判断所依据的日期的毫秒数
	 * @param time 需要判断的日期的Mills....精确到毫秒
	 * @return 属于哪一个类型：今日、昨日、一周、更早
	 */
	public static String getHeadByTime(long todayMills,long time){
		if(time >= todayMills)return HISTORY_TITLES[0];
		else if(time >= todayMills-24*3600000)return HISTORY_TITLES[1];
		else if(time >= todayMills-6*24*3600000)return HISTORY_TITLES[2];
		else return HISTORY_TITLES[3];
	}
}
