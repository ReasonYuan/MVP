package com.fq.halcyon.entity;

import com.fq.lib.json.JSONObject;

/**
 * 病历实体
 */
public class Record extends HalcyonEntity{

	private static final long serialVersionUID = 1L;
	/**
	 * 病历ID
	 */
	private int folderId;
	/**
	 * 病历名称
	 */
	private String folderName;
	/**
	 * 病历类型，eg. 门诊，住院 etc.
	 */
	private int folderType;
	/**
	 * 病历来源，eg. 自己上传，分享 etc.
	 */
	private int sourceFrom;
	/**
	 * 病历创建时间
	 */
	private String createTime;
	/**
	 * 分享人的姓名
	 */
	private String sharePerson;
	/**
	 * 未识别的数量
	 */
	private int unRecongCount;


	public int getFolderId() {
		return folderId;
	}

	public void setFolderId(int folderId) {
		this.folderId = folderId;
	}

	public String getFolderName() {
		return folderName;
	}

	public void setFolderName(String folderName) {
		this.folderName = folderName;
	}

	public int getFolderType() {
		return folderType;
	}

	public void setFolderType(int folderType) {
		this.folderType = folderType;
	}

	public int getSourceFrom() {
		return sourceFrom;
	}

	public void setSourceFrom(int sourceFrom) {
		this.sourceFrom = sourceFrom;
	}

	public String getCreateTime() {
		return createTime;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public int getUnRecongCount() {
		return unRecongCount;
	}

	public void setUnRecongCount(int unRecongCount) {
		this.unRecongCount = unRecongCount;
	}

	public String getSharePerson() {
		return sharePerson;
	}

	public void setSharePerson(String sharePerson) {
		this.sharePerson = sharePerson;
	}

	@Override
	public void setAtttributeByjson(JSONObject json) {
		this.folderId = json.optInt("record_id");
		this.folderName = json.optString("record_name");
		this.sourceFrom = json.optInt("create_type");
		this.folderType = json.optInt("record_category");
		this.createTime = json.optString("create_time");
		this.unRecongCount = json.optInt("unrecong_count");
		JSONObject jsonObj = json.optJSONObject("record_from");
		if (jsonObj != null) {
			this.sharePerson = jsonObj.optString("name");
		}
	}

	@Override
	public void test() {
		// TODO Auto-generated method stub
		
	}
	
}
