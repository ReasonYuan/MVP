package com.hp.android.halcyon.util;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.FileHelper;
import com.fq.lib.json.JSONObject;
import com.hp.android.halcyon.HalcyonApplication;

/**
 * 闹钟保存到本地的结构体
 */
class AlarmStruct implements Serializable{
	int id;
	long time;
	String extra;
	public AlarmStruct(int id,long time,String extra){
		this.id = id;
		this.time = time;
		this.extra = extra;
	}
}


public class AlarmHelper {

	public static final String ALARM_INTENT_ACTION = "fq.alarm.action";
	public static final String ALARM_INTENT_ID= "alarm.id";
	public static final String ALARM_INTENT_TIME= "alarm.time";
	public static final String ALARM_INTENT_EXTRA = "fq.alarm.extra";
	
	private static final String ALARM_DATA_LOCAL_FILE = "alarm.data";

	private static ArrayList<AlarmStruct> mAlarms;
	
	
	/**
	 * 初始化数据
	 * @return
	 */
	public static boolean init() {
		load();
		return false;
	}
	
	/**
	 * 注册一个闹钟
	 * 如果时间已经存在这不会注册
	 */
	public static void registeAlarm(AlarmStruct alarm){
		/**
		 * 同样乘以1000
		 */
		if(alarm.time*1000 <= System.currentTimeMillis() ) return;
		AlarmManager alarmManager = (AlarmManager) HalcyonApplication.getInstance().getApplicationContext().getSystemService(Context.ALARM_SERVICE);
		Intent intent = new Intent(ALARM_INTENT_ACTION);
		intent.putExtra(ALARM_INTENT_ID, alarm.id);
		intent.putExtra(ALARM_INTENT_TIME,alarm.time);
		if(alarm.extra != null){
			intent.putExtra(ALARM_INTENT_EXTRA, alarm.extra);
		}
		alarmManager.set(AlarmManager.RTC_WAKEUP, alarm.time*1000, getPendingIntent(alarm.id, intent));
	}
	
	
	/**
	 * 取消闹钟
	 */
	public static void cancleAlarm(AlarmStruct alarm){
		AlarmManager alarmManager = (AlarmManager) HalcyonApplication.getInstance().getApplicationContext().getSystemService(Context.ALARM_SERVICE);
		alarmManager.cancel(getPendingIntent(alarm.id, null));
		for (int i = 0; i < mAlarms.size(); i++) {
			if(mAlarms.get(i).id == alarm.id){
				mAlarms.remove(i);
				break;
			}
		}
	}
	
	/**
	 * 持久化闹钟数据
	 */
	private static final void save(){
		String filePath = FileSystem.getInstance().getOthersPath() + ALARM_DATA_LOCAL_FILE;
		FileHelper.saveSerializableObject(mAlarms, filePath);
	}
	
	/**
	 * 加载本地闹钟
	 */
	private static final void load(){
		String filePath = FileSystem.getInstance().getOthersPath() + ALARM_DATA_LOCAL_FILE;
		mAlarms = (ArrayList<AlarmStruct>) FileHelper.loadSerializableObject(filePath);
		if(mAlarms == null){
			mAlarms = new ArrayList<AlarmStruct>();
		}
		removeDeprecatedAlarms();
		for (int i = 0; i < mAlarms.size(); i++) {
			AlarmStruct alarmStruct = mAlarms.get(i);
			registeAlarm(alarmStruct);
		}
	}
	

	/**
	 * 移除过时的alarm
	 */
	public static void removeDeprecatedAlarms(){
		if(mAlarms != null){
			ArrayList<AlarmStruct> deprecatedAlarms = new ArrayList<AlarmStruct>();
			ArrayList<Integer> alarmIds = new ArrayList<Integer>();
			for (int i = 0; i < mAlarms.size(); i++) {
				AlarmStruct  alarmStruct = mAlarms.get(i);
				/**
				 * 此处同样乘以1000
				 */
				if(alarmStruct.time*1000 <= System.currentTimeMillis()){
					deprecatedAlarms.add(alarmStruct);
				}else {
					if(alarmIds.contains(alarmStruct.id)){
						deprecatedAlarms.add(alarmStruct);
					}else {
						alarmIds.add(alarmStruct.id);
					}
				}
			}
			mAlarms.removeAll(deprecatedAlarms);
			save();
		}
	}
	
	
	/**
	 * 根据消息设置闹钟
	 * @param struct
	 */
	public static void addAlarms(MessageStruct struct) {
		if(struct != null && struct.mAlarms != null){
			JSONObject alarms = struct.mAlarms;
			Iterator<String> keys = alarms.keys();
			while (keys.hasNext()) {
				String key = keys.next();
				int realKey = Integer.parseInt(key);
				long value = alarms.optLong(key,0);
				/**
				 * 由于java系统getime得到的多了1000，所以乘1000做比较 实际上需要的还是除1000后的结果
				 */
				if(value*1000 <= System.currentTimeMillis()) continue;
				AlarmStruct alarmStruct = new AlarmStruct(realKey, value, struct.mMsg);
				cancleAlarm(alarmStruct);
				if(value != 0){
					mAlarms.add(alarmStruct);
					registeAlarm(alarmStruct);
				}
			}
			save();
		}
	}
	
	/**
	 * 根据消息取消闹钟
	 * @param struct
	 */
	public static void cancleAlarms(MessageStruct struct) {
		if(struct != null && struct.mAlarms != null){
			JSONObject alarms = struct.mAlarms;
			Iterator<String> keys = alarms.keys();
			while (keys.hasNext()) {
				String key = keys.next();
				int realKey = Integer.parseInt(key);
				cancleAlarm(new AlarmStruct(realKey, 0, struct.mMsg));
				for (int i = 0; i < mAlarms.size(); i++) {
					if(mAlarms.get(i).id == realKey){
						mAlarms.remove(i);
						break;
					}
				}
			}
			save();
		}
	}

	private static final PendingIntent getPendingIntent(int id ,Intent i){
		Intent intent = i;
		if(intent == null){
			intent = new Intent(ALARM_INTENT_ACTION);
		}
		return PendingIntent.getBroadcast(HalcyonApplication.getInstance().getApplicationContext(), id, intent, PendingIntent.FLAG_CANCEL_CURRENT);
	}
	
}
