package com.hp.android.halcyon.util;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import com.fq.halcyon.entity.AlarmClock;
import com.hp.android.halcyon.HalcyonApplication;
import com.hp.android.halcyon.server.AlarmReceiver;

public class AlarmUtil {
	
	public static final String ACTION_ALARM = "action_alarm_intent";
	
	private Context mContext;
	 private AlarmManager mAlarmManager;
	private static AlarmUtil mAlarmUtil;
	
	private AlarmUtil(){};
	
	public static AlarmUtil getInstance(){
		if(mAlarmUtil == null){
			mAlarmUtil = new AlarmUtil();
			mAlarmUtil.mContext = HalcyonApplication.getAppContext();
			mAlarmUtil.mAlarmManager = (AlarmManager)mAlarmUtil.mContext.getSystemService(Context.ALARM_SERVICE);
		}
		return mAlarmUtil;
	}
	
	public void setAlarm(AlarmClock alarm){
		Intent intent = new Intent(mContext, AlarmReceiver.class);    //创建Intent对象
		intent.putExtra("alarm_content", alarm.getTimerContent());
		intent.setAction(ACTION_ALARM);
        PendingIntent pi = PendingIntent.getBroadcast(mContext, 0, intent, 0);    //创建PendingIntent
        mAlarmManager.set(AlarmManager.RTC_WAKEUP, alarm.getTimerDate(), pi); //设置闹钟，当前时间就唤醒
	}
}
