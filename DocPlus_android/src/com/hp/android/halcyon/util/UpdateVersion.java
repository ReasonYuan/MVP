package com.hp.android.halcyon.util;

import java.io.File;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import android.annotation.SuppressLint;
import android.app.DownloadManager;
import android.app.DownloadManager.Query;
import android.app.DownloadManager.Request;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.Version;
import com.fq.halcyon.extend.filesystem.FileSystem;

public class UpdateVersion {

	private static long enqueue;
	private static ScheduledExecutorService scheduledExecutorService;

	@SuppressLint("NewApi")
	public static void downloadApk(final Context context, Version version) {
		// String fileUrl =
		// "http://softfile.3g.qq.com:8080/msoft/179/24659/43549/qq_hd_mini_1.4.apk";
		String fileUrl = version.getUpdateUrl().replace("https", "http");
		String apkName = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);

		String filePath = FileSystem.getInstance().getSDCardRootPath();
		File file = new File(filePath);
		if (!file.exists()) {
			file.mkdirs();
		}

		final DownloadManager downloadManager = (DownloadManager) context
				.getSystemService(Context.DOWNLOAD_SERVICE);

		Uri uri = Uri.parse(fileUrl);
		Request request = new Request(uri);
		request.setTitle(context.getString(R.string.app_name)+"v" + version.getVersionName());
		// request.setDescription("");
		request.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE
				| DownloadManager.Request.NETWORK_WIFI); // 设置允许使用的网络类型
		//request.setShowRunningNotification(true);
		request.setDestinationInExternalPublicDir(filePath,apkName);//下载路径和文件名
		request.setNotificationVisibility(Request.VISIBILITY_VISIBLE|Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);// 
		request.allowScanningByMediaScanner();// 可被媒体扫描到
		request.setVisibleInDownloadsUi(true);// 显示下载界面（可见可管理）
		request.setMimeType("application/vnd.android.package-archive");
		
		registerOnComplete(context);

		enqueue = downloadManager.enqueue(request);
		SharedPreferences preferences = context.getSharedPreferences("app_version",Context.MODE_PRIVATE);
		Editor editor = preferences.edit().putLong("download_id",enqueue);
		editor.commit();
		
		/**
		scheduledExecutorService = Executors.newScheduledThreadPool(3);
		Runnable command = new Runnable() {

				@Override
				public void run() {
					//updateView();
					int[] status = getBytesAndStatus(context, enqueue);
					System.out.println("s: " + status[0]);
				}
			};
		scheduledExecutorService.scheduleAtFixedRate(command, 0, 1, TimeUnit.SECONDS);
		*/
	}
	
	private static BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            DownloadManager dm = (DownloadManager) context
			.getSystemService(Context.DOWNLOAD_SERVICE);
            if (DownloadManager.ACTION_DOWNLOAD_COMPLETE.equals(action)) {
//                long downloadId = intent.getLongExtra(
//                        DownloadManager.EXTRA_DOWNLOAD_ID, 0);
            	if(scheduledExecutorService != null) {
            		scheduledExecutorService.shutdown();
            	}
                Query query = new Query();
                query.setFilterById(enqueue);
                Cursor c = dm.query(query);
                if (c.moveToFirst()) {
                    int columnIndex = c
                            .getColumnIndex(DownloadManager.COLUMN_STATUS);
                    if (DownloadManager.STATUS_SUCCESSFUL == c
                            .getInt(columnIndex)) {
                        String uriString = c
                                .getString(c
                                        .getColumnIndex(DownloadManager.COLUMN_LOCAL_URI));
                        //Log.i("", "uriString: " + uriString);
                        try {
                        	context.getApplicationContext().unregisterReceiver(receiver);
                            Intent inta = new Intent(Intent.ACTION_VIEW);
                            inta.setDataAndType(Uri.parse(uriString), "application/vnd.android.package-archive");
                            inta.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            context.startActivity(intent);
						} catch (Exception e) {
							e.printStackTrace();
						}
                    }
                }
            }
        }
    };
	
	private static void registerOnComplete(Context context){
        context.getApplicationContext().registerReceiver(receiver, new IntentFilter(
                DownloadManager.ACTION_DOWNLOAD_COMPLETE));
	}
	
	protected static int[] getBytesAndStatus(Context context, long downloadId) {
		int[] bytesAndStatus = new int[] { -1, -1, 0 };
		DownloadManager.Query query = new DownloadManager.Query().setFilterById(downloadId);
		Cursor c = null;
		try {
			DownloadManager dm = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
			c = dm.query(query);
			if (c != null && c.moveToFirst()) {
				bytesAndStatus[0] = c.getInt(c.getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR));
				bytesAndStatus[1] = c.getInt(c.getColumnIndexOrThrow(DownloadManager.COLUMN_TOTAL_SIZE_BYTES));
				bytesAndStatus[2] = c.getInt(c.getColumnIndex(DownloadManager.COLUMN_STATUS));
			}
		} finally {
			if (c != null) {
				c.close();
			}
		}
		return bytesAndStatus;
	}
}
