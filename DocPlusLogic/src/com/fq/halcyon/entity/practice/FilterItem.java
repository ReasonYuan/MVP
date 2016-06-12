package com.fq.halcyon.entity.practice;

import java.util.ArrayList;
import java.util.Map;

public class FilterItem {
	public int indexSection;
	public int getIndexSection() {
		return indexSection;
	}
	public void setIndexSection(int indexSection) {
		this.indexSection = indexSection;
	}
	public int indexRow;
	public int getIndexRow() {
		return indexRow;
	}
	public void setIndexRow(int indexRow) {
		this.indexRow = indexRow;
	}
	public int position;

	public int getPosition() {
		return position;
	}
	public void setPosition(int position) {
		this.position = position;
	}
	public String itemsName;
	public String getItemsName() {
		return itemsName;
	}
	public void setItemsName(String itemsName) {
		this.itemsName = itemsName;
	}
	public boolean isSelected;
	public boolean isSelected() {
		return isSelected;
	}
	public void setSelected(boolean isSelected) {
		this.isSelected = isSelected;
	}
	
	public Map<String, ArrayList<String>> itemsMap;
	
	public Map<String, ArrayList<String>> getItemsMap() {
		return itemsMap;
	}
	public void setItemsMap(Map<String, ArrayList<String>> itemsMap) {
		this.itemsMap = itemsMap;
	}
}
