package com.fq.halcyon.entity.practice;

public class ModifyObject {
	int recordItemId = 0;
	int imageId = 0;
	public ModifyObject(int recordItemId,int imageId) {
		this.recordItemId = recordItemId;
		this.imageId = imageId;
	}
	public int getRecordItemId() {
		return recordItemId;
	}
	public void setRecordItemId(int recordItemId) {
		this.recordItemId = recordItemId;
	}
	public int getImageId() {
		return imageId;
	}
	public void setImageId(int imageId) {
		this.imageId = imageId;
	}
	
}
