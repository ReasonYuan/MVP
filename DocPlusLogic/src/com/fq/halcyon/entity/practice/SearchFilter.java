package com.fq.halcyon.entity.practice;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;


import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.FQLog;

/**
 * 病案和记录筛选时需要的筛选字段
 * @author reason
 *
 */
public class SearchFilter extends HalcyonEntity{
	
	private static final long serialVersionUID = 1L;
	
	/**过滤的种类*/
	public String category;
	
	/**过滤的选项*/
	public ArrayList<FilterItem> items;
	
	private String[] recordTypes = {"入院","手术","化验","检查","出院","其他"};
	
	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public ArrayList<FilterItem> getItems() {
		return items;
	}

	public void setItems(ArrayList<FilterItem> items) {
		this.items = items;
	}

	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		category = checkNull(json.optString("category"));
		items = new ArrayList<FilterItem>();
		if(category.equals("记录类型")) {
			JSONObject jsonObj = json.optJSONObject("items");
			FilterItem temp = new FilterItem();
			HashMap<String, ArrayList<String>> map = new HashMap<String, ArrayList<String>>();
			if(jsonObj != null){
				for (String item : recordTypes) {
					JSONArray jsonArray = jsonObj.optJSONArray(item);
					ArrayList<String> recordItems = new ArrayList<String>();
					if(jsonArray != null){
						for (int i = 0; i < jsonArray.length(); i++) {
							recordItems.add(jsonArray.optString(i));
						}
					}
					map.put(item, recordItems);
				}
				temp.setItemsMap(map);
				items.add(temp);
			}
			
		}else{
			JSONArray ims = json.optJSONArray("items");
			if(ims != null){
				for(int i = 0; i < ims.length(); i++){
					FilterItem temp = new FilterItem();
					temp.isSelected = false;
					temp.itemsName = ims.optString(i);
					items.add(temp);
				}
			}
		}
		
//		checkNull(category);
	}

	@Override
	public JSONObject getJson() {
		JSONObject json = new JSONObject();
		try {
			json.put("category", category);
			if(items != null){
				String[] itemList = new String[items.size()];
				for (int i = 0; i < items.size(); i++) {
					itemList[i] = items.get(i).getItemsName();
				}
				JSONArray arry = new JSONArray(itemList);
				json.put("items", arry);
			}
		} catch (JSONException e) {
			FQLog.i("构建过滤字段出错");
			e.printStackTrace();
		}
		return json;
	}
}
