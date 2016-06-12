package com.hp.android.halcyon.server;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.hp.android.halcyon.FollowUpAlarmActivity;
import com.hp.android.halcyon.util.AlarmHelper;

public class AlarmReceiver extends BroadcastReceiver{

    @Override
    public void onReceive(Context context, Intent intent) {
        //Intent i=new Intent(context, HomeActivity.class);
        //i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        //context.startActivity(i);
//    	MessageStruct.createNotification(context, "一个提醒", intent.getStringExtra("alarm_content"), 1, HomeActivity.class);
    	AlarmHelper.removeDeprecatedAlarms();
    	Intent intent2 = new Intent(context, FollowUpAlarmActivity.class);
    	intent2.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    	context.startActivity(intent2);
    }
}
