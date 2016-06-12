package com.fq.lib.tools;

/**
 * 用于远程记录那些非常难以确定的bug
 * @author johnny_peng
 *
 */
public class FQRemoteDebugTool {
	
	private static RemoteLogger mRemoteLogger;
	
	public static interface RemoteLogger {
		
		public void log(String message);
		
	}
	
	public static void setRemoteLogger(RemoteLogger remoteLogger){
		mRemoteLogger = remoteLogger;
	}
	
	public static void log(String message){
		if (mRemoteLogger == null) {
			throw new RuntimeException("Must call FQRemoteDebugTool#setRemoteLogger first!");
		}
		mRemoteLogger.log(message);
	}
	
	public static void log(String message, Throwable e){
		if (mRemoteLogger == null) {
			throw new RuntimeException("Must call FQRemoteDebugTool#setRemoteLogger first!");
		}
		mRemoteLogger.log(message + ",\n" + e.toString() + "\n" + getStackTraceString(e.getStackTrace()));
	}
	
	private static String getStackTraceString(StackTraceElement[] es){
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < es.length; i++) {
			sb.append(es[i].toString()).append("\n");
		}
		return sb.toString();
	}
	
}