package com.hp.android.halcyon.util;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListAdapter;
import android.widget.ListView;

import com.fq.android.plus.R;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.hp.android.halcyon.HalcyonApplication;

public class UITools {

	public static final String LOGIN_TAG = "firstlogin";
	// private static Tools mInstance = null;

	private static float mScale;
	private static Context mContext;

	static {
		mContext = HalcyonApplication.getAppContext();
		mScale = HalcyonApplication.getAppContext().getResources()
				.getDisplayMetrics().density;
	}

	private UITools() {

	}

	/*
	 * public static Tools getInstance(){ if(mInstance==null){ mInstance = new
	 * Tools(); } return mInstance; }
	 */

	/**
	 * 将px值转换为dip或dp值，保证尺寸大小不变
	 * 
	 * @param pxValue
	 * @param scale
	 *            （DisplayMetrics类中属性density）
	 * @return
	 */
	public static int px2dip(Context context, float pxValue) {
		final float scale = context.getResources().getDisplayMetrics().density;
		return (int) (pxValue / scale + 0.5f);
	}

	/**
	 * 将dip或dp值转换为px值，保证尺寸大小不变
	 * 
	 * @param dipValue
	 * @param scale
	 *            （DisplayMetrics类中属性density）
	 * @return
	 */
	public static int dip2px(Context context, float dipValue) {
		final float scale = context.getResources().getDisplayMetrics().density;
		return (int) (dipValue * scale + 0.5f);
	}

	public static int dip2px(float dipValue) {
		return (int) (dipValue * mScale + 0.5f);
	}

	/**
	 * 将px值转换为sp值，保证文字大小不变
	 * 
	 * @param pxValue
	 * @param fontScale
	 *            （DisplayMetrics类中属性scaledDensity）
	 * @return
	 */
	public static int px2sp(Context context, float pxValue) {
		final float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
		return (int) (pxValue / fontScale + 0.5f);
	}

	/**
	 * 将sp值转换为px值，保证文字大小不变
	 * 
	 * @param spValue
	 * @param fontScale
	 *            （DisplayMetrics类中属性scaledDensity）
	 * @return
	 */
	public static int sp2px(Context context, float spValue) {
		final float fontScale = context.getResources().getDisplayMetrics().scaledDensity;
		return (int) (spValue * fontScale + 0.5f);
	}

	/**
	 * 一个activity进入另外一个activity
	 */
	/*
	 * public static void toAnotherActivity(Context context, Class cls) { Intent
	 * mIntent = new Intent(); mIntent.setClass(context, cls);
	 * context.startActivity(mIntent); }
	 */

	public static void showToast(String text) {
		// Toast.makeText(HalcyonApplication.getAppContext(), text,
		// Toast.LENGTH_SHORT).show();
		HalcyonApplication.showToast(text);
	}

	/**
	 * 
	 * @param friendId
	 *            申请好友的朋友的Id
	 * @param type
	 *            1:表示你加对方为好友，2表示对方要加你为好友，0表示已经是朋友
	 */
	public static boolean isFriendHold(int friendId) {
		SharedPreferences sp = HalcyonApplication.getAppContext()
				.getSharedPreferences("dis_friend", Context.MODE_PRIVATE);
		int type = sp.getInt("fri" + friendId, 0);
		if (type == 0) {
			return false;
		} else {
			if (type == 1) {
				showToast("你已对TA发出过请求，等待对方验证");
			} else if (type == 2) {
				showToast("对方已对你发出过请求，快去验证吧");
			}
			return true;
		}
	}

	public static void setFriendHold(int friendId, int type) {
		SharedPreferences sp = HalcyonApplication.getAppContext()
				.getSharedPreferences("dis_friend", Context.MODE_PRIVATE);
		sp.edit().putInt("fri" + friendId, type).commit();
	}

	public static void removeFriendHold(int friendId) {
		SharedPreferences sp = HalcyonApplication.getAppContext()
				.getSharedPreferences("dis_friend", Context.MODE_PRIVATE);
		sp.edit().remove("fri" + friendId).commit();
	}

	/**
	 * 获取版本号
	 * 
	 * @return 当前应用的version_name
	 */
	public static String getVersionName() {
		try {
			PackageManager manager = mContext.getPackageManager();
			PackageInfo info = manager.getPackageInfo(
					mContext.getPackageName(), 0);
			String version = info.versionName;
			return version;
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}
	}

	/**
	 * 获取版本号
	 * 
	 * @return 当前应用的version_code
	 */
	public static int getVersionCode() {
		try {
			PackageManager manager = mContext.getPackageManager();
			PackageInfo info = manager.getPackageInfo(
					mContext.getPackageName(), 0);
			int version = info.versionCode;
			return version;
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}

//	public static Bitmap getUserHeadBmp() {
//		Bitmap bm = BitmapManager.decodeSampledBitmapFromFile(FileSystem
//				.getInstance().getUserHeadPath(), 4);
//		if (bm == null) {
//			bm = BitmapFactory.decodeResource(HalcyonApplication
//					.getAppContext().getResources(),
//					R.drawable.shape_rectangle_head);
//		}
//		return bm;
//	}
//	
//	public static Bitmap getCertificationBmp(int type) {
//		Bitmap bm = BitmapManager.decodeSampledBitmapFromFile(FileSystem
//				.getInstance().getAuthImgPathByType(type), 4);
//		if (bm == null) {
//			bm = BitmapFactory.decodeResource(HalcyonApplication
//					.getAppContext().getResources(),
//					R.drawable.shape_rectangle_head);
//		}
//		return bm;
//	}
//
//
//	public static Bitmap getBmp(int imageId) {
//		Bitmap bm = BitmapManager.decodeSampledBitmapFromFile(FileSystem
//				.getInstance().getImgCachePath() + "/" + imageId, 4);
//		if (bm == null) {
//			bm = BitmapFactory.decodeResource(HalcyonApplication
//					.getAppContext().getResources(),
//					R.drawable.shape_rectangle_head);
//		}
//		return bm;
//	}
	
	public static Bitmap getBitmapWithPath(String path){
		Bitmap bm = BitmapManager.decodeSampledBitmapFromFile(path, 4);
		if (bm == null) {
			bm = BitmapFactory.decodeResource(HalcyonApplication
					.getAppContext().getResources(),
					R.drawable.shape_rectangle_head);
		}
		return bm;
	}

	/**
	 * 检测是否连接了网络
	 * 
	 * @return boolean -true 连接，false 未连接
	 */
	public static boolean isNetworkAvailable(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		if (cm == null) {
		} else {
			NetworkInfo[] info = cm.getAllNetworkInfo();
			if (info != null) {
				for (int i = 0; i < info.length; i++) {
					if (info[i].getState() == NetworkInfo.State.CONNECTED) {
						return true;
					}
				}
			}
		}
		return false;
	}

	/**
	 * 检测是否连接了wifi
	 * 
	 * @return boolean -true 连接，false 未连接
	 */
	public static boolean isWifiConnected(Context context) {
		ConnectivityManager connectivityManager = (ConnectivityManager) context
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo wifiNetworkInfo = connectivityManager
				.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		if (wifiNetworkInfo.isConnected()) {
			return true;
		}
		return false;
	}

	/** 根据ListView的item计算ListView的高度 */
	public static void setListViewHeightBasedOnChildren(ListView listView) {
		// 获取ListView对应的Adapter
		ListAdapter listAdapter = listView.getAdapter();
		if (listAdapter == null) {
			// pre-condition
			return;
		}

		int totalHeight = 0;
		for (int i = 0, len = listAdapter.getCount(); i < len; i++) { // listAdapter.getCount()返回数据项的数目
			View listItem = listAdapter.getView(i, null, listView);
			listItem.measure(0, 0); // 计算子项View 的宽高
			totalHeight += listItem.getMeasuredHeight(); // 统计所有子项的总高度
		}

		ViewGroup.LayoutParams params = listView.getLayoutParams();
		params.height = totalHeight
				+ (listView.getDividerHeight() * (listAdapter.getCount() - 1));
		// listView.getDividerHeight()获取子项间分隔符占用的高度
		// params.height最后得到整个ListView完整显示需要的高度
		listView.setLayoutParams(params);
	}

	/*public static JSONObject getRecordMouldByType(int id) {
		try {
			InputStreamReader inputReader = new InputStreamReader(mContext
					.getAssets().open("mould/" + id));
			BufferedReader bufReader = new BufferedReader(inputReader);
			String line = "";
			String result = "";
			while ((line = bufReader.readLine()) != null)
				result += line;
			return new JSONObject(result);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}*/
	
	/**
	 * 通知系统扫描病历图片，用于系统相册实时更新
	 */
	public static void scanRecordImage(){
		scanFile(FileSystem.getInstance().getRecordImgPath());
	}
	
	/**
	 * 通知系统扫描文件(或文件夹)，用于系统文件实时更新
	 */
	public static void scanFile(String path){
		//ACTION_MEDIA_MOUNTED（有问题）   ACTION_MEDIA_SCANNER_SCAN_FILE
		mContext.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + path)));
	}
	
	/**
	 * 通知系统扫描文件，用于系统文件实时更新<br/>
	 * 用于文件(图片)改名后对两个文件扫描
	 */
	public static void scanFile(String path,String path2){
		//ACTION_MEDIA_MOUNTED（有问题）  ACTION_MEDIA_SCANNER_SCAN_FILE
		mContext.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + path)));
		mContext.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + path2)));
	}
	
	/**
	 * 获取版本号
	 * @param context
	 * @return
	 */
	public static String getVersion(Context context)
	{
		try {
			PackageInfo pi=context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
			return pi.versionName;
		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return "Unknown version";
		}
	}
}
