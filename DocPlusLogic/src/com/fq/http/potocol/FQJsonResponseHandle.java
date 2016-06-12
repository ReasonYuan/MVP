package com.fq.http.potocol;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;

import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.google.j2objc.annotations.ObjectiveCName;

/*-[
#import "FQJsonResponseHandle.h"
]-*/
@ObjectiveCName("FQJsonResponseHandle")
public abstract class FQJsonResponseHandle extends FQBinaryResponseHandle{

	private String id = null;
	
	private String subId = null;
	
	
	@Override
	public void handleError(int code, Throwable e) {
		String cache = Platform.getInstance().getCache(getId());
		if(cache != null && !cache.equals("")){ //有本地数据
			if(!Platform.isNetWorkConnect){ //网络没有连接
				return; //不处理异常
			}
		}
		super.handleError(code, e);
	}
	
	public void setSubId(String subId){
		this.subId = subId;
		if(subId != null && this.id != null){
			String cache = Platform.getInstance().getCache(getId());
			if(cache != null && !cache.equals("")){
				this.handleBinaryData(cache.getBytes());
			}
		}
	}
	
	
	public void setId(String id,boolean havaSubId){
		this.id = id;
		if(!havaSubId && this.id != null){
			String cache = Platform.getInstance().getCache(getId());
			if(cache != null && !cache.equals("")){
				this.handleBinaryData(cache.getBytes());
			}
		}
	}
	
	public String getId(){
		if(id == null) return "";
		if(subId != null){
			return id+"_"+subId;
		}
		return id;
	}
	
	@Override
	public void handleResponse(byte[] data) {
		if(id != null){
			try {
				String str = new String(data,"UTF-8");
				onCacheString(getId(), str);
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
		}
		super.handleResponse(data);
	}
	
	@Override
	public void handleBinaryData(byte[] data) {
		try {
			String str = new String(data,"UTF-8");
			JSONObject json = new  JSONObject(str);
			handleJson(json);
		} catch (Exception e) {
			e.printStackTrace();
			onError(0,e);
		}
	}
	
	public abstract void handleJson(JSONObject json);

	protected void onCacheString(String id,String data){
		Platform.getInstance().cache(id, data,new ArrayList<String>(), "");
	}
}
