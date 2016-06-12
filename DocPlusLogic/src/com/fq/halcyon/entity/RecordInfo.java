package com.fq.halcyon.entity;

/**
 * 病历记录详情note_info里的一项信息<br/>
 * 由于服务器返回的数据为JsonArray里装载JsonObject,数据不好管理<br/>
 * 所以转换成该类
 * @author reason
 */
public class RecordInfo {
	
	/**一项信息的关键词（title）*/
	public String key;
	/**一项信息的内容*/
	public String info;

	public RecordInfo(String key, String info){
		this.key = key;
		this.info = info;
	}
}
