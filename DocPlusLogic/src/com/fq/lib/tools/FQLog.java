package com.fq.lib.tools;

public class FQLog {

	private static final boolean DEBUG = Constants.DEBUG;
	
	public static void print(String TAG,String msg){
		if(DEBUG)System.out.println(TAG+"->"+msg);
	}
	
	public static void i(String msg){
		print("", msg);
	}
	
	public static void i(String TAG,String msg){
		print(TAG, msg);
	}
	
	public static void w(String TAG,String msg){
		print(TAG, msg);
	}
	
	public static void e(String TAG,String msg){
		print(TAG, msg);
	}
	
	public static void v(String TAG,String msg){
		print(TAG, msg);
	}
	
	public static void d(String TAG,String msg){
		print(TAG, msg);
	}
}
