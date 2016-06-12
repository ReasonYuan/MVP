package com.fq.halcyon.entity;


public class SurveyRecordItem extends HalcyonEntity{

	private static final long serialVersionUID = 1L;

	private String name;
	private String content;
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	
}
