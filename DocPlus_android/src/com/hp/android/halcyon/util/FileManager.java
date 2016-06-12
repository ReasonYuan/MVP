package com.hp.android.halcyon.util;

import java.io.File;

import android.content.Context;
import android.os.Environment;
import android.os.StatFs;

import com.hp.android.halcyon.HalcyonApplication;

public class FileManager {
	private static final String ROOT_SYSTEM = "/data/data/";
	private static final String ROOT_SDCARD = "/Android/data/";
	
	public static final String FOLDER_NAME_DEBUG = "debugs/";
	
	private static FileManager instance;
	
	private FileManager(){};
	
	/**
	 * mRoot目录，用于存放应用产生的数据，删除时会删除里面的所有东西，
	 * 那么如果存储在手机里的话，可能会连同里面的files等系统文件夹也删除掉，
	 * 所以又另外加了一层目录，即###/DoctorPlus/;
	 */
	
	public static String mRoot;
	
	public static FileManager getInstance(){
		if(instance == null){
			instance = new FileManager();
		}
		
		if(mRoot == null || "".equals(mRoot)){
			initRootPath();
		}  
		return instance;
	}
	
	private static void initRootPath(){
		Context context = HalcyonApplication.getAppContext();
		if(isSdcardExists()){
//			mRoot = Environment.getExternalStorageDirectory()+ROOT_SDCARD+context.getPackageName()+"/DoctorPlus/";
			mRoot = Environment.getExternalStorageDirectory()+"/DoctorPlus/";
    	}else{
    		mRoot = ROOT_SYSTEM + context.getPackageName()+"/DoctorPlus/";
    	}
	}
	
	public String getBackupPhotoPath(String itemName){
		File file = new File(mRoot+"photo/");
		if(!file.exists())file.mkdirs();
		return mRoot+"photo/"+itemName;
	}
	
	public String getFolderPath(String path){
		return mRoot+path;
	}
	
	public File getAndCreateFolderIfNotExist(String path){
		File file = new File(mRoot+path);
		if(!file.exists()){
			file.mkdirs();
		}
		return file;
	}
	
	public String getPhoneRootPath(){
		return ROOT_SYSTEM + HalcyonApplication.getAppContext().getPackageName()+"/DoctorPlus/";
	}
	
	public String getSDCardRootPath(){
		Context context = HalcyonApplication.getAppContext();
//		return Environment.getExternalStorageDirectory()+ROOT_SDCARD+context.getPackageName()+"/DoctorPlus/";
		return Environment.getExternalStorageDirectory()+"/DoctorPlus/";
	}
	
	public String getDebugPath(){
		return getAndCreateFolderIfNotExist(FOLDER_NAME_DEBUG).getPath();
	}
	
	/**
	 * 删除应用中所有文件(包括sharedpreferences)，SDcard和手机里
	 */
	public void deleAllFile(){
		//deleteAllFolderInSDcard();
	}
	
	/**
	 * 如果过期则清空以前的所有文件夹以及删除任务文件，并重新创建，否则什么都不做
	 */
	public void checkValidity(){}
	
	public static boolean isSdcardExists(){
    	String status = Environment.getExternalStorageState();
    	if (status.equals(Environment.MEDIA_MOUNTED)) {
    	   return true;
    	} else {
    	   return false;
    	}
    }
	
	 /**
     * 获取手机内部总的存储空间
     * @return
     */
    private static long getTotalInternalMemorySize() {
        File path = Environment.getDataDirectory();
        StatFs stat = new StatFs(path.getPath());
        long blockSize = stat.getBlockSize();
        long totalBlocks = stat.getBlockCount();
        return totalBlocks * blockSize;
    }
	
	/**
     * 获取手机内部剩余存储空间
     * @return
     */
    private static long getAvailableInternalMemorySize() {
        File path = Environment.getDataDirectory();
        StatFs stat = new StatFs(path.getPath());
        long blockSize = stat.getBlockSize();
        long availableBlocks = stat.getAvailableBlocks();
        return availableBlocks * blockSize;
    }
    
    /**
     * 获取SDCARD总的存储空间
     * @return
     */
    private static long getTotalExternalMemorySize() {
        File path = Environment.getExternalStorageDirectory();
        StatFs stat = new StatFs(path.getPath());
        long blockSize = stat.getBlockSize();
        long totalBlocks = stat.getBlockCount();
        return totalBlocks * blockSize;  
    }
    
    /**
     * 获取SDCARD剩余存储空间
     * @return
     */
    private static long getAvailableExternalMemorySize() {
        File path = Environment.getExternalStorageDirectory();
        StatFs stat = new StatFs(path.getPath());
        long blockSize = stat.getBlockSize();
        long availableBlocks = stat.getAvailableBlocks();
        return availableBlocks * blockSize;   
    }
    
    
    /**
     * 获取手机存储容量
     * @return long[3]:<br/>
     * --第一位表示容量位置：1为sd cards,0为手机内部存储空间<br/>
     * --第二位为总容量<br/>
     * --的三位为剩余容量<br/>
     */
    public static long[] getMemorySize(){
    	long[] size = new long[3];
    	if(isSdcardExists()){
    		size[0] = 1;
    		size[1] = getTotalExternalMemorySize();
    		size[2] = getAvailableExternalMemorySize();
    	}else{
    		size[0] = 0;
    		size[1] = getTotalInternalMemorySize();
    		size[2] = getAvailableInternalMemorySize();
    	}
    	return size;
    }
}
