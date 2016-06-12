package com.hp.android.halcyon.util;

import android.content.Context;
import android.util.StateSet;

import com.baidu.mobstat.StatService;
import com.fq.lib.tools.Constants;

/**
 * 百度统计的sdk，用于封装百度统计的一些方法，apk只能通过该类调用发送统计信息<br/>
 * 调用之前，需要在Application里初始化
 * @author reason
 * @version 2015-04-28 v3.0.3
 */
public class BaiDuTJSDk {

	private static Context mContext;
	
	
	
	
	private BaiDuTJSDk(){};
	
	/**
	 * 初始化百度统计
	 */
	public static void init(Context context){
		mContext = context;
		StatService.setDebugOn(Constants.DEBUG);
	}
	
	/*public static BaiDuTJSDk getInstance(){
		if(mInstance == null){
			throw new RuntimeException("百度统计，必须要在应用启动时出视化");
		}
		return mInstance;
	}*/
	
	/**
	 * 用于统计自定义事件的发生次数<br/>
	 * 嵌入位置：任意,一般在开发者自定义事件(如点击事件等)的监听位置
	 * @param eventId 调用页面的设备上下文
	 * @param label 事件ID,注意要先在mtj.baidu.com中注册此事件ID
	 * @param acc 自定义事件计数
	 */
	public static void onEvent(String eventId,String label,int acc){
		StatService.onEvent(mContext, eventId, label,acc);
	}
	
	/**
	 * 用于统计自定义事件的发生次数<br/>
	 * 嵌入位置：任意,一般在开发者自定义事件(如点击事件等)的监听位置
	 * @param eventId 事件ID,注意要先在mtj.baidu.com中注册此事件ID
	 * @param label 自定义事件标签
	 */
	public static void onEvent(String eventId,String label){
		StatService.onEvent(mContext, eventId, label);
	}
	
	/**
	 * 用于统计自定义事件的时长，此为开启计时的函数<br/>
	 * 注意此函数中的事件ID应该与onEvent函数中的不同
	 * @param eventId 事件ID,注意要先在mtj.baidu.com中注册此事件ID
	 * @param label 自定义事件标签
	 */
	public static void onEventStart(String eventId,String label){
		StatService.onEventStart(mContext, eventId, label);
	}
	
	/**
	 * 用于统计自定义事件的时长，此为结束计时的函数<br/>
	 * 注意此函数中的事件ID应该与onEvent函数中的不同
	 * @param eventId 事件ID,注意要先在mtj.baidu.com中注册此事件ID
	 * @param label 自定义事件标签
	 */
	public static void onEventEnd(String eventId,String label){
		StatService.onEventEnd(mContext, eventId, label);
	}
	
	/**
	 * 用于统计自定义事件的时长，此为开发者传入时长的函数<br/>
	 * 注意此函数中的事件ID应该与onEvent函数中的不同<br/>
	 * 此函数等价于(onEventStart+onEventEnd)
	 * @param eventId 事件ID,注意要先在mtj.baidu.com中注册此事件ID
	 * @param label 自定义事件标签
	 */
	public static void onEventDuration(String eventId,String label,long milliseconds){
		StatService.onEventDuration(mContext, eventId, label,milliseconds);
	}
	
	/**
     * 页面起始（每个Activity中都需要添加，如果有继承的父Activity中已经添加了该调用，那么子Activity中务必不能添加）
     * 不能与StatService.onPageStart一级onPageEnd函数交叉使用
     */
	public static void onResume(Context context){
		StatService.onResume(context);
	}
	
	/**
     * 页面结束（每个Activity中都需要添加，如果有继承的父Activity中已经添加了该调用，那么子Activity中务必不能添加）
     * 不能与StatService.onPageStart一级onPageEnd函数交叉使用
     */
	public static void onPause(Context context){
		StatService.onPause(context);
	}
	
	/**
	 * 用于统计单个自定义页面的起始
	 * @param pageName 页面的自定义名字
	 */
	public static void onPageStart(String pageName){
		StatService.onPageStart(mContext, pageName);
	}
	
	/**
	 * 用于统计单个自定义页面的结束
	 * @param pageName 页面的自定义名字
	 */
	public static void onPageEnd(String pageName){
		StatService.onPageEnd(mContext, pageName);
	}
}
