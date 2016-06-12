package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class ChatGroupLogic {
	public interface CreateChatGroupCallBack {
		public void createGroupSuccess();

		public void createGroupError(int code, String msg);
	}

	public interface AddGroupContactCallBack {
		public void addGroupContactSuccess();

		public void addGroupContactError(int code, String msg);
	}

	public interface DelGroupContactCallBack {
		public void delGroupContactSuccess();

		public void delGroupContactError(int code, String msg);
	}

	/** 创建讨论组 */
	public void createGroup(String groupId, ArrayList<Integer> adduserid,
			final CreateChatGroupCallBack mCallback) {
		HashMap<String, Object> mMap = new HashMap<String, Object>();
		mMap.put("creater_id", Constants.getUser().getUserId());
		mMap.put("cgroup_id", groupId);
		mMap.put("add_user_ids", new JSONArray(adduserid));
		JSONObject mDelGroupJson = JsonHelper.createJson(mMap);
		FQHttpParams mFqHttpParams = new FQHttpParams(mDelGroupJson);

		ApiSystem.getInstance().require(
				UriConstants.Conn.URL_PUB + "/group/add_members.do",
				mFqHttpParams, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						mCallback.createGroupError(-1, Constants.Msg.NET_ERROR);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							mCallback.createGroupSuccess();

						} else {
							mCallback.createGroupError(responseCode, msg);
						}

					}
				});
	}

	/** 添加群成员 */
	public void addGroupContact(String groupId, ArrayList<Integer> adduserid,
			final AddGroupContactCallBack mCallback) {
		HashMap<String, Object> mMap = new HashMap<String, Object>();
		mMap.put("cgroup_id", groupId);
		mMap.put("add_user_ids", new JSONArray(adduserid));

		JSONObject mDelGroupJson = JsonHelper.createJson(mMap);
		
		FQHttpParams mFqHttpParams = new FQHttpParams(mDelGroupJson);

		ApiSystem.getInstance().require(
				UriConstants.Conn.URL_PUB + "/group/add_members.do",
				mFqHttpParams, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						mCallback.addGroupContactError(-1,
								Constants.Msg.NET_ERROR);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							mCallback.addGroupContactSuccess();

						} else {
							mCallback.addGroupContactError(responseCode, msg);
						}

					}
				});
	}

	/** 群主删除群成员 */
	public void createrDelGroupContact(String groupId,
			ArrayList<Integer> removeids,
			final DelGroupContactCallBack mCallback) {
		HashMap<String, Object> mMap = new HashMap<String, Object>();
		mMap.put("creater_id", Constants.getUser().getUserId());
		mMap.put("cgroup_id", groupId);
		mMap.put("remove_user_ids", new JSONArray(removeids));

		JSONObject mDelGroupJson = JsonHelper.createJson(mMap);
		FQHttpParams mFqHttpParams = new FQHttpParams(mDelGroupJson);

		ApiSystem.getInstance().require(
				UriConstants.Conn.URL_PUB + "/group/add_members.do",
				mFqHttpParams, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						mCallback.delGroupContactError(-1,
								Constants.Msg.NET_ERROR);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							mCallback.delGroupContactSuccess();

						} else {
							mCallback.delGroupContactError(responseCode, msg);
						}

					}
				});
	}

	/** 群成员自己退出 */
	public void otherDelGroupContact(String groupId,
			ArrayList<Integer> removeids,
			final DelGroupContactCallBack mCallback) {
		HashMap<String, Object> mMap = new HashMap<String, Object>();
		mMap.put("cgroup_id", groupId);
		mMap.put("remove_user_ids", new JSONArray(removeids));

		JSONObject mDelGroupJson = JsonHelper.createJson(mMap);
		FQHttpParams mFqHttpParams = new FQHttpParams(mDelGroupJson);

		ApiSystem.getInstance().require(
				UriConstants.Conn.URL_PUB + "/group/add_members.do",
				mFqHttpParams, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						mCallback.delGroupContactError(-1,
								Constants.Msg.NET_ERROR);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							mCallback.delGroupContactSuccess();

						} else {
							mCallback.delGroupContactError(responseCode, msg);
						}

					}
				});
	}

}
