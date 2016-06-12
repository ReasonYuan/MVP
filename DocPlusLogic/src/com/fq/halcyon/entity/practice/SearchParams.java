package com.fq.halcyon.entity.practice;

import java.util.ArrayList;
import java.util.Map;

import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;

/**
 * 病案和记录筛选时请求接口需要的参数类<br/>
 * 由于需要的数据过多，所以单独抽象成一个类
 * 
 * @author reason
 * 
 */
public class SearchParams {

	/** 搜索时不需要服务器返回后面的分类类别 */
	public static final int FILTERS_UNNEED = 0;
	/** 搜索时需要服务器返回后面的分类类别 */
	public static final int FILTERS_NEED = 1;

	/** 返回病案和记录两种 */
	public static final int RESPONSE_ALL = 0;
	/** 只返回病案 */
	public static final int RESPONSE_PATIENT = 1;
	/** 只返回记录 */
	public static final int RESPONSE_RECORD = 2;

	// private static final long serialVersionUID = 1L;

	/** 是不是需要服务器返回后面的过滤(分类)列表。(0:不需要 1:需要) */
	private int needFilters;

	/** 需要返回数据的类型(0:病案和记录 1:只有病案 2:只有记录) */
	private int responseType;

	/** 搜索条件id */
	private int id;

	/** 病案id */
	private int patientId;

	/** 搜索的关键字 */
	private String key;

	/** 第几页,从1开始计算 */
	private int page;

	/** 每页显示的数据数量,病案、记录为各取(默认为5条) */
	private int pageSize = 5;

	/** 筛选时的起始时间 */
	private String toData;

	/** 筛选时的结束时间 */
	private String fromData;

	/** 需要筛选的关键字 */
	private ArrayList<SearchFilter> filters;
	
	/** 保存搜索结果的名字 */
	private String name;
	
	/** 保存搜索结果的病案ID */
	private ArrayList<Integer> patientIds;

	public ArrayList<Integer> getPatientIds() {
		return patientIds;
	}

	public void setPatientIds(ArrayList<Integer> patientIds) {
		this.patientIds = patientIds;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getNeedFilters() {
		return needFilters;
	}

	public void setNeedFilters(int needFilters) {
		this.needFilters = needFilters;
	}

	public void setNeedFilters(boolean isNeed) {
		this.needFilters = isNeed ? 1 : 0;
	}

	public int getResponseType() {
		return responseType;
	}

	public void setResponseType(int responseType) {
		this.responseType = responseType;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getPagintId() {
		return patientId;
	}

	public void setPagintId(int pagintId) {
		this.patientId = pagintId;
	}

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	public int getPage() {
		return page;
	}

	public void setPage(int page) {
		this.page = page;
	}

	public int getPageSize() {
		return pageSize;
	}

	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}

	public String getToData() {
		return toData;
	}

	public void setToData(String toData) {
		this.toData = toData;
	}

	public String getFromData() {
		return fromData;
	}

	public void setFromData(String fromData) {
		this.fromData = fromData;
	}

	public ArrayList<SearchFilter> getFilters() {
		return filters;
	}

	public void setFilters(ArrayList<SearchFilter> filters) {
		this.filters = filters;
	}

	public void setFilters(JSONArray filtersArray) {
		ArrayList<SearchFilter> mFilters = new ArrayList<SearchFilter>();
		for (int i = 0; i < filtersArray.length(); i++) {
			try {

				SearchFilter filter = new SearchFilter();
				filter.setAtttributeByjson(filtersArray.getJSONObject(i));
				mFilters.add(filter);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		this.filters = mFilters;
	}

	public JSONArray getFiltersJson() {
		JSONArray mArray = new JSONArray();
		for (int i = 0; i < filters.size(); i++) {
			try {
				if (filters.get(i).getCategory() == "记录类型") {
					JSONObject recordObject = new JSONObject();

					recordObject.put("category", "记录类型");

					JSONArray recordArray = new JSONArray();
					ArrayList<FilterItem> items = filters.get(i).getItems();
					if (items.size() > 0) {
						FilterItem item = items.get(0);
						Map<String, ArrayList<String>> itemMap = item
								.getItemsMap();
						for (String key : itemMap.keySet()) {
							JSONObject tmpObj = new JSONObject();
							ArrayList<String> list = itemMap.get(key);
							tmpObj.put("name", key);
							JSONArray tmpArray = new JSONArray();
							if (list != null || list.size() > 0) {
								for (String string : list) {
									tmpArray.put(string);
								}
							}
							tmpObj.put("value", tmpArray);
							recordArray.put(tmpObj);
						}
					}
					recordObject.put("items", recordArray);
					mArray.put(recordObject);
				} else {
					mArray.put(filters.get(i).getJson());

				}
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		return mArray;
	}

	public JSONObject getSearhParams() {
		JSONObject params = JsonHelper.createUserIdJson();

		try {
			params.put("user_id", Constants.getUser().getUserId());// Constants.getUser().getUserId()
			params.put("need_filters", needFilters);
			params.put("response_type", responseType);
			params.put("data_filter", key);
			params.put("page", page);
			params.put("page_size", pageSize);
			if (patientId != 0)
				params.put("patient_id", patientId);
			if (!"".equals(fromData))
				params.put("from_date", fromData);
			if (!"".equals(toData))
				params.put("to_date", toData);
			JSONArray array = new JSONArray();
			if (filters != null) {
				for (int i = 0; i < filters.size(); i++) {
					JSONObject obj = new JSONObject();
					SearchFilter filter = filters.get(i);
					obj.put("category", filter.getCategory());
					JSONArray filterArray = new JSONArray();
					if (filter.getCategory() == "记录类型") {
						JSONArray recordArray = new JSONArray();
						ArrayList<FilterItem> items = filter.getItems();
						if (items.size() > 0) {
							FilterItem item = items.get(0);
							Map<String, ArrayList<String>> itemMap = item
									.getItemsMap();
							for (String key : itemMap.keySet()) {
								JSONObject tmpObj = new JSONObject();
								ArrayList<String> list = itemMap.get(key);
								tmpObj.put("name", key);
								JSONArray tmpArray = new JSONArray();
								if (list != null || list.size() > 0) {
									for (String string : list) {
										tmpArray.put(string);
									}
								}
								tmpObj.put("value", tmpArray);
								recordArray.put(tmpObj);
							}
						}
						obj.put("items", recordArray);
					} else {
						for (FilterItem item : filter.getItems()) {
							filterArray.put(item.getItemsName());
						}
						obj.put("items", filterArray);
					}
					array.put(obj);
				}
			}
			params.put("filters", array);
		} catch (JSONException e) {
			FQLog.i("构建搜索接口的请求参数出错");
			e.printStackTrace();
		}
		return params;
	}
}
