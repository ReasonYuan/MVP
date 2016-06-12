package com.hp.android.halcyon.server;

import android.annotation.SuppressLint;
import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;

import com.hp.android.halcyon.util.UITools;

@SuppressLint("NewApi")
public class UpdataBroadCastReceiver extends BroadcastReceiver{

	@Override
	public void onReceive(Context context, Intent intent) {
		long myDwonloadID = intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1);
		SharedPreferences sPreferences = context.getSharedPreferences("app_version", 0);
		long downloadId = sPreferences.getLong("download_id", 0);
		
		try{
			DownloadManager downloadManager = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
			downloadManager.openDownloadedFile(myDwonloadID);
			if (downloadId == myDwonloadID) {
				Uri downloadFileUri = downloadManager.getUriForDownloadedFile(downloadId);
				
				Intent install = new Intent(Intent.ACTION_VIEW);
				install.setDataAndType(downloadFileUri,"application/vnd.android.package-archive");
				if (intent.resolveActivity(context.getPackageManager()) != null) {
					install.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
					context.startActivity(install);
				}else{
					UITools.showToast("最新的医加已下载成功，可以安装了");
				}
			}	
		}catch(Exception e){
			e.printStackTrace();
		}
	}
}
