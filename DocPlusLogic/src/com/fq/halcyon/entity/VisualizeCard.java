package com.fq.halcyon.entity;

public class VisualizeCard extends HalcyonEntity{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	private String cardName;
	private int imageId;
	public String getCardName() {
		return cardName;
	}
	public void setCardName(String cardName) {
		this.cardName = cardName;
	}
	public int getImageId() {
		return imageId;
	}
	public void setImageId(int imageId) {
		this.imageId = imageId;
	}
	
}
