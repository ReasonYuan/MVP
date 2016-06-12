package com.fq.lib.platform;

import java.lang.ref.WeakReference;
import java.util.ArrayList;

/**
 * logic层对UI层的回调，各个平台实现自己的方法
 * @author reason
 * @version 2015-04-09 v3.0.2
 */
public abstract class Platform {
	
	public interface onNetworkChangeListener{
		public void  onNetworkChanged(int state);
	}
	
	public static final int PLANTFORM_ANDROID = 1;
	
	public static final int PLANTFORM_IOS = 2;
	
	private static Platform instance;
	
	private ArrayList<WeakReference<onNetworkChangeListener>> mListers;
	
	/**
	 * 当前网络是否连接
	 */
	public static boolean isNetWorkConnect = false;
	
	/**
	 * 网络类型:未连接
	 */
	public static int NETWORKSATE_NO = 0;
	
	/**
	 * 网络类型:WiFi连接
	 */
	public static int NETWORKSATE_WIFI = 1;
	
	/**
	 * 网络类型:其他连接
	 */
	public static int NETWORKSATE_OTHER = 2;
	
	private int mCurrentNetworkStatus;
	
	/**
	 * @return  {@link #NETWORKSATE_NO },{@link #NETWORKSATE_OTHER },{@link #NETWORKSATE_WIFI }
	 */
	public int getNetworkState(){
		return mCurrentNetworkStatus;
	};
	
	/**
	 * 检查网络是否连接
	 */
	public abstract void  checkNetwork();
	
	/**
	 * {@link #NETWORKSATE_NO },{@link #NETWORKSATE_OTHER },{@link #NETWORKSATE_WIFI }
	 * @param status 当前网络状态
	 */
	public void setNetworkState(int status){
		if(status>=NETWORKSATE_NO && status <= NETWORKSATE_OTHER ){
			if(status != NETWORKSATE_NO) isNetWorkConnect = true;
			else isNetWorkConnect = false;
			if(mCurrentNetworkStatus != status){
				mCurrentNetworkStatus = status;
				for (int i = 0; i < mListers.size();) {
					WeakReference<onNetworkChangeListener> ref = mListers.get(i);
					onNetworkChangeListener listener = ref.get();
					if (listener != null) {
						listener.onNetworkChanged(status);
					}else{
						mListers.remove(ref);
						continue;
					}
					i++;
				}
			}
			mCurrentNetworkStatus = status;
		}
	}
	
	
	public Platform(){
		mListers = new ArrayList<WeakReference<onNetworkChangeListener>>();
		mCurrentNetworkStatus = NETWORKSATE_NO;
		initNetWorkLibrary();
		initDes3Utils();
		initHMACSHA1();
	}
	
	
	public void addOnNetworkChangeListener(onNetworkChangeListener listener){
		for (int i = 0; i < mListers.size(); i++) {
			WeakReference<onNetworkChangeListener> ref = mListers.get(i);
			if (ref.get() == listener) {
				return;
			}
		}
		WeakReference<onNetworkChangeListener> ref = new WeakReference<Platform.onNetworkChangeListener>(listener);
		mListers.add(ref);
	}
	
	public static Platform getInstance(){
//		if(instance == null){
//			throw new RuntimeException("not set instance yet;");
//		}
		return instance;
	}
	
	public static void setInstance(Platform platfrom){
		instance = platfrom;
	}
	
	/**
	 * 初始化网络库
	 */
	public abstract void initNetWorkLibrary();
	
	/**
	 * Des3算法加密
	 */
	public abstract void initDes3Utils();
	
	/**
	 * Des3算法加密
	 */
	public abstract void initHMACSHA1();
	
	public abstract String SHA1(String text);
	
	/**
	 * 通知系统扫描文件(或文件夹)，用于对新增文件实时更新<br/>
	 */
	public abstract void scanFile(String path);
	
	/**
	 * 通知系统(UI层)扫描文件，用于系统文件实时更新<br/>
	 * 用于文件(图片)改名后对两个文件扫描
	 * @param path
	 * @param newPath
	 */
	public abstract void scanFile(String oldPath,String newPath);
	
	/**
	 * 得到病历记录关键信息解密的key。用来解密病历记录的关键信息
	 * @return
	 */
	public abstract byte[] getRecord3DesKey();
	
	public abstract int getTargetPlatform();
	
	/**
	 * 各平台存储数据的抽象，Android的sharepreference或ios的userDefault
	 * @param key
	 * @param value
	 * @return
	 */
	public abstract boolean set(String key,String value);
	
	/**
	 * 获取存的储数据
	 * @param key
	 * @return
	 */
	public abstract String get(String key);
	
	/**
	 * 退出登录时清除用户相关数据或第三方库,因为ios和android所调库各是各，所以分别处理
	 */
	public abstract void clearUser();
	
	/**
	 * 发送通知，ios用
	 * @param type
	 * @param userInfo
	 */
	public abstract void sendNotification(String type,String userInfo);
	
	/**
	 * 缓存数据到本地
	 * @param id    本地数据唯一id
	 * @param data  缓存数据
	 * @param keyworlds 关键字	
	 * @param time  时间
	 */
	public abstract void cache(String id,String data,ArrayList<String> keyworlds,String time);
	
	/**
	 * 获取缓存数据	
	 * @param id 本地数据唯一id
	 * @return  缓存数据
	 */
	public abstract String getCache(String id);
	
	/**
	 * 缓存病案的更新时间
	 * @param id  patientd
	 * @param time 时间
	 */
	public abstract void cachePatientUpdatetime(int id,String time);
	
	/**
	 * 缓存病案列表
	 * @param time  
	 */
	public abstract void cachePatientList(String time);
	
	/**
	 * 缓存记录列表
	 * @param time  
	 */
	public abstract void cacheRecordList(String time);
	
	/**
	 * 离线查找
	 * @param key  关键字
	 */
	public abstract String search(String key);
	
	public abstract void UpdateDB(String localPath,int imageId,int responceCode);
}
