package com.fq.halcyon.entity.practice;

public class UpLoadObject {
	int recordItemId = 0;
	String imageName = "";
	public UpLoadObject(int recordItemId,String imageName) {
		this.recordItemId = recordItemId;
		this.imageName = imageName;
	}
	public int getRecordItemId() {
		return recordItemId;
	}
	public void setRecordItemId(int recordItemId) {
		this.recordItemId = recordItemId;
	}
	public String getImageName() {
		return imageName;
	}
	public void setImageName(String imageName) {
		this.imageName = imageName;
	}
	
	
}
