package com.hp.android.halcyon.util;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import com.fq.android.plus.R;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.HomeActivity;

public class MessageStruct {

	/**
	 * 请求添加好友
	 */
	public static final int MESSAGE_TYPE_ADD_NEW_FRIEND = 0x1;

	/**
	 * 同意添加好友请求
	 */
	public static final int MESSAGE_TYPE_AGREE_ADD_NEW_FRIEND = 0x2;
	
	/**
	 * 新的留言
	 */
	public static final int MESSAGE_TYPE_NEW_MESSAGE = 0x3;
	
	/**
	 * 新的留言
	 */
	public static final int MESSAGE_TYPE_NEW_NOTIFY = 0x4;

	/**
	 *随访的提醒
	 */
	public static final int MESSAGE_TYPE_NEW_FOLLOW_UP = 0x5;
	
	/**
	 * 删除随访闹钟
	 */
	public static final int MESSAGE_TYPE_DELETE_ONE_FOLLOW_UP = 0x6;
	
	/**
	 * 删除所有的随访闹钟
	 */
	public static final int MESSAGE_TYPE_DELETE_ALL_FOLLOW_UP = 0x7;
	
	public int mFrom;
	
	public String mSendUserName;

	public int mTo;

	public int mType;

	public String mMsg;
	
	/**
	 * 随访提前时间hashmap  存的itemId 和 提醒时间 ：前一天的12点
	 */
	public JSONObject mAlarms;

	public MessageStruct(int msgType, String msg, int toUser) {
		mFrom = Constants.getUser().getUserId();
		mSendUserName = Constants.getUser().getName();
		mTo = toUser;
		mType = msgType;
		mMsg = msg;
	}
	
	public MessageStruct(int msgType, String msg, int toUser,JSONObject alarms) {
		this(msgType, msg, toUser);
		mAlarms = alarms;
	}

	public MessageStruct(String msg) {
		try {
			JSONObject json = new JSONObject(msg);
			mFrom = json.optInt("from");
			mTo = json.optInt("to");
			mType = json.optInt("type");
			mMsg = json.optString("message");
			mSendUserName = json.optString("send_user_name");
			mAlarms = json.optJSONObject("alarms");
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
	public void onMessageSend(){
		switch (mType) {
		case MESSAGE_TYPE_NEW_FOLLOW_UP:
			AlarmHelper.addAlarms(this);
			break;
		case MESSAGE_TYPE_DELETE_ONE_FOLLOW_UP:
			AlarmHelper.cancleAlarms(this);
			break;
		case MESSAGE_TYPE_DELETE_ALL_FOLLOW_UP:
			AlarmHelper.cancleAlarms(this);
			break;
		default:
			break;
		}
	}
	
	public void onReceiveMessage(){
		onMessageSend();
	}

	@Override
	public String toString() {
		JSONObject json = new JSONObject();
		try {
			json.put("from", mFrom);
			json.put("to", mTo);
			json.put("type", mType);
			json.put("message", mMsg);
			json.put("send_user_name", mSendUserName);
			json.put("alarms", mAlarms);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return json.toString();
	}
	
	public void handleMessage(Context context){
		switch (mType) {
		case MESSAGE_TYPE_ADD_NEW_FRIEND:
			createNotification(context, "好友请求", mSendUserName+"请求添加好友", 1,HomeActivity.class);
			break;
		case MESSAGE_TYPE_NEW_MESSAGE:
			createNotification(context, "新的留言", "你有新的留言信息", 1,HomeActivity.class);
		case MESSAGE_TYPE_NEW_NOTIFY:
			createNotification(context, "新的提醒", "你有新的提醒", 1,HomeActivity.class);
			break;
		case MESSAGE_TYPE_NEW_FOLLOW_UP:
			createNotification(context, "新的随访信息", "你有新的随访信息", 1,HomeActivity.class);
			break;
		case MESSAGE_TYPE_DELETE_ONE_FOLLOW_UP:
			createNotification(context, "医生取消一次随访", "你有新的随访信息", 1,HomeActivity.class);
			break;
		case MESSAGE_TYPE_DELETE_ALL_FOLLOW_UP:
			createNotification(context, "医生取消所有的随访", "你有新的随访信息", 1,HomeActivity.class);
			break;
		default:
			break;
		}
		onReceiveMessage();
	}
	
	public static void createNotification(Context context,String title,String contentText,int count, Class<?> cls){
		NotificationManager mNotificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
		Notification notification = new Notification( R.drawable.app_icon,contentText,System.currentTimeMillis());
		notification.number = count;
		notification.defaults |=Notification.DEFAULT_SOUND;
		notification.defaults |= Notification.DEFAULT_VIBRATE;
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		Intent notificationIntent = new Intent(context,cls); //点击该通知后要跳转的Activity
		notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_NEW_TASK);
		PendingIntent contentIntent = PendingIntent.getActivity(context,0,notificationIntent,0);
		notification.setLatestEventInfo(context, title, contentText, contentIntent);
		mNotificationManager.notify(0,notification);
	}
	
}
