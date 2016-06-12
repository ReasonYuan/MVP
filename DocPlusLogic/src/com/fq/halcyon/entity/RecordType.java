package com.fq.halcyon.entity;

import java.util.ArrayList;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

/**
 * 病历记录实体类
 * @author Monkey Zhou
 */
public class RecordType extends HalcyonEntity{

	private static final long serialVersionUID = 1L;

	private int recordType;
	private ArrayList<RecordItemSamp> mItemList = new ArrayList<RecordItemSamp>();
	
	/**是否为用户查看分享模式*/
	private boolean isShareModel;
	
	public void setIsShareModel(boolean isShareModel){
		this.isShareModel = isShareModel;
	}
	
	public int getRecordType() {
		return recordType;
	}

	public void setRecordType(int recordType) {
		this.recordType = recordType;
	}

	public ArrayList<RecordItemSamp> getItemList() {
		return mItemList;
	}

	public void setItemList(ArrayList<RecordItemSamp> mItemList) {
		this.mItemList = mItemList;
	}

	public RecordItemSamp getItem(int position){
		return (RecordItemSamp)mItemList.get(position);
	}
	
	public void addItem(RecordItemSamp item){
		mItemList.add(item);
	}
	
	public void addItems(ArrayList<RecordItemSamp> items){
		mItemList.addAll(items);
	}
	
	public void addItems(int index, ArrayList<RecordItemSamp> items){
		mItemList.addAll(index,items);
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		this.recordType = json.optInt("record_type");
		
		mItemList.clear();
		JSONArray jsonArr = json.optJSONArray("record_items");
		int count = jsonArr.length();
		for (int i = 0; i < count; i++) {
			JSONObject jsonObj = jsonArr.optJSONObject(i);
			RecordItemSamp item = new RecordItemSamp();
			item.setReocrdType(recordType);
			item.setIsShareModel(isShareModel);
			item.setAtttributeByjson(jsonObj);
			mItemList.add(item);
		}
	}
}
