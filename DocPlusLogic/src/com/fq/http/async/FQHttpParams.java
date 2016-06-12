package com.fq.http.async;

import java.io.IOException;
import java.io.UnsupportedEncodingException;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.entity.StringEntity;
import org.apache.http.message.BasicHeader;

import com.fq.http.potocol.HttpClientPotocol;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.RequestParams;
import com.loopj.android.http.ResponseHandlerInterface;

public class FQHttpParams extends ParamsWrapper {

	private static final long serialVersionUID = 1L;

	protected JSONObject json = null;

	protected JSONArray jsonArray = null;
	
	protected Object object = null;
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

	public Object getObject() {
		return object;
	}

	public void setObject(Object object) {
		this.object = object;
	}

	public FQHttpParams(JSONObject json) {
		super();
		this.json = json;
	}

	@Override
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

	@Override
	public HttpEntity getEntity(ResponseHandlerInterface progressHandler) throws IOException {
		String params =  HttpClientPotocol.getInstance().encode(getStringParams()) ;
		if(params.equals("")){
			return super.getEntity(progressHandler);
		}
		return new FOJSONStringEntity(params);
	}

	private class FOJSONStringEntity extends StringEntity {
		
		public FOJSONStringEntity(String s) throws UnsupportedEncodingException {
			super(s,"UTF-8");
		}

		public FOJSONStringEntity(String s, String charset) throws UnsupportedEncodingException {
			super(s, charset);
		}

		@Override
		public Header getContentType() {
			return new BasicHeader(
                    AsyncHttpClient.HEADER_CONTENT_TYPE,
                    RequestParams.APPLICATION_JSON);
		}
	}
}
