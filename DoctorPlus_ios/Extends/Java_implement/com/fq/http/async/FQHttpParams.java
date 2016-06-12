package com.fq.http.async;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

public class FQHttpParams extends ParamsWrapper {

	protected JSONObject json = null;

	protected JSONArray jsonArray = null;

	public FQHttpParams() {
		super();
	}

	public JSONObject getJson() {
		return json;
	}

	public void setJson(JSONObject json) {
		this.json = json;
	}

	public JSONArray getJsonArray() {
		return jsonArray;
	}

	public void setJsonArray(JSONArray jsonArray) {
		this.jsonArray = jsonArray;
	}

	public FQHttpParams(JSONObject json) {
		super();
		this.json = json;
	}

	public boolean isJsonParams() {
		return json != null || jsonArray != null;
	}

	public FQHttpParams(JSONArray jsonArray) {
		super();
		this.jsonArray = jsonArray;
	}

	@Override
	public String getStringParams() {
		if (json != null) {
			return json.toString();
		} else if (jsonArray != null) {
			return jsonArray.toString();
		}
		return "";
	}
}
