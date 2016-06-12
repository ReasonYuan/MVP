package com.fq.halcyon.logic2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Tag;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.UriConstants;

public class TagLogic {

	/**
	 * 获取医生所有的标签
	 * 
	 * @param infCallBack
	 *            获取所有标签的回调函数
	 */
	public void getListAllTags(final RequestTagInfCallBack callback) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		final String url = UriConstants.Conn.URL_PUB + "/tags/list_all_tags.do";
		final FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		ApiSystem.getInstance().require(url, params, API_TYPE.BROW,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						FQLog.i("getListAllTags error", "~~~~msg:" + e);
						if (Constants.tagList == null) {
							Constants.tagList = new ArrayList<Tag>();
						}
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0 && type == 2) {
							JSONArray array = (JSONArray) results;
							ArrayList<Tag> tags = new ArrayList<Tag>();
							for (int i = 0, count = array.length(); i < count; i++) {
								try {
									// Tag tag =
									// EntityUtil.FromJson(array.getJSONObject(i),
									// Tag.class);
									Tag tag = new Tag();
									tag.setAtttributeByjson(array
											.getJSONObject(i));
									tags.add(tag);

									if (Constants.contactsList != null) {
										for (Contacts user : Constants.contactsList) {
											ArrayList<String> tgs = user.getTags();
											for (String tg : tgs) {
												if (tg.equals(tag.getTitle())) {
													tag.addContacts(user);
													break;
												}
											}
										}
									}
									tag.setCount(tag.getContacts().size());
								} catch (JSONException e) {
									e.printStackTrace();
								}
							}
							Constants.tagList = tags;
							if (callback != null)
								callback.resTagList(tags);
						} else {
							onError(responseCode, new Throwable(msg));
						}
					}
				});
	}

	/**
	 * 新建标签(只新建标签，不会将标签添加到病历上)
	 * 
	 * @param tag
	 *            需要新建的标签名称
	 */
	public void addTag(final String tag, final OnTagModifyCallback callback) {
		Map<String, Object> map = new HashMap<String, Object>();
		String[] tags = { tag };
		map.put("user_id", Constants.getUser().getUserId());
		try {
			map.put("tag", new JSONArray(tags));
		} catch (JSONException e) {
			e.printStackTrace();
		}
		final String url = UriConstants.Conn.URL_PUB + "/tags/add_tag.do";
		final FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));

		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {
					public void onError(int code, Throwable e) {
						callback.onModifySuccess(false);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							Tag tg = new Tag();
							tg.setId(((JSONObject) results).optInt("tag_id"));
							tg.setTitle(tag);
							callback.addTag(tg);
						} else {
							callback.onModifySuccess(false);
						}
					}
				});
		// LoopCell cell = new LoopCell(url, params);
		// HalcyonUploadLooper.getInstance().push(cell);
	}

	/**
	 * 新建标签(新建标签同时给病历贴上此标签)
	 * 
	 * @param tag
	 *            需要新建的标签名称
	 * @param patientIdList
	 *            需要添加新建标签的病历列表
	 * @param success
	 *            成功的回调函数
	 * @param fail
	 *            失败的回调函数
	 */
	public void addTag(ArrayList<String> tagList,
			ArrayList<Integer> patientIdList, final SuccessCallBack success,
			final FailCallBack fail) {
		Map<String, Object> map = new HashMap<String, Object>();
		JSONArray arrayPatient = new JSONArray(patientIdList);
		JSONArray arrayTag = new JSONArray(tagList);
		map.put("user_id", Constants.getUser().getUserId());
		map.put("tag", arrayTag);
		map.put("doctor_patient_id", arrayPatient);
		final String url = UriConstants.Conn.URL_PUB
				+ "/tags/add_tag_doctor_patient_id.do";
		final FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		// LoopCell cell = new LoopCell(url, params);
		// HalcyonUploadLooper.getInstance().push(cell);
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						if (fail != null) {
							fail.onFail(code, e.getMessage());
						}
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							if (success != null) {
								success.onSuccess(responseCode, msg, type,
										results);
							}
						} else {
							if (fail != null) {
								fail.onFail(responseCode, msg);
							}
						}
					}
				});
	}

	/**
	 * 删除标签
	 * 
	 * @param tagIdList
	 *            需要删除的标签的ID列表
	 * @param success
	 *            成功的回调函数
	 * @param fail
	 *            失败的回调函数
	 */
	public void delTag(final ArrayList<Integer> tagIdList,
			final SuccessCallBack success, final FailCallBack fail) {
		Map<String, Object> map = new HashMap<String, Object>();
		JSONArray array = new JSONArray(tagIdList);
		map.put("user_id", Constants.getUser().getUserId());
		map.put("tag_id", array);
		final String url = UriConstants.Conn.URL_PUB + "/tags/delete_tag.do";
		final FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		// LoopCell cell = new LoopCell(url, params);
		// HalcyonUploadLooper.getInstance().push(cell);
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						if (fail != null) {
							fail.onFail(code, e.getMessage());
						}
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							if (tagIdList != null) {
								// 目前只有一个
								for (int j = 0; j < Constants.tagList.size(); j++) {
									if (tagIdList.get(0) == Constants.tagList
											.get(j).getId()) {
										Constants.tagList.remove(j);
										break;
									}
								}
							}
							if (success != null) {
								success.onSuccess(responseCode, msg, type,
										results);
							}
						} else {
							if (fail != null) {
								fail.onFail(responseCode, msg);
							}
						}
					}
				});
	}

	/**
	 * 获取病历下所有已贴标签
	 * 
	 * @param patientIdList
	 *            病历的ID列表
	 * @param callBack
	 *            得到标签列表的回调函数
	 */
	public void getPatientIdTags(ArrayList<Integer> patientIdList,
			final RequestTagInfCallBack callBack) {
		Map<String, Object> map = new HashMap<String, Object>();
		JSONArray array = new JSONArray(patientIdList);
		map.put("user_id", Constants.getUser().getUserId());
		map.put("doctor_patient_id", array);
		final String url = UriConstants.Conn.URL_PUB
				+ "/tags/list_tags_doctor_patient_id.do";
		final FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						FQLog.i("getPatientIdTags error", "msg:" + e);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0 && type == 2) {
							JSONArray array = (JSONArray) results;
							ArrayList<Tag> tags = new ArrayList<Tag>();
							for (int i = 0, count = array.length(); i < count; i++) {
								try {
									// Tag tag =
									// EntityUtil.FromJson(array.getJSONObject(i),
									// Tag.class);
									Tag tag = new Tag();
									tag.setAtttributeByjson(array
											.getJSONObject(i));
									tags.add(tag);
								} catch (JSONException e) {
									e.printStackTrace();
								}
							}
							if (callBack != null)
								callBack.resTagList(tags);
						} else {
							onError(responseCode, new Throwable(msg));
						}
					}
				});
	}

	/**
	 * 获取某个标签下的所有病历
	 * 
	 * @param tagIdList
	 *            标签的ID列表
	 * @param 得到病历列表结果的回调函数
	 */
//	public void getTagPatientList(ArrayList<Integer> tagIdList,
//			final RequestPatientListCallBack callBack) {
//		Map<String, Object> map = new HashMap<String, Object>();
//		JSONArray array = new JSONArray(tagIdList);
//		map.put("user_id", Constants.getUser().getUserId());
//		map.put("tag_id", array);
//		final String url = UriConstants.Conn.URL_PUB + "/tags/list_patients.do";
//		final FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
//		FQLog.i(params.toString());
//		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT,
//				new HalcyonHttpResponseHandle() {
//
//					@Override
//					public void onError(int code, Throwable e) {
//						FQLog.i("TagLogic getTagPatientList error" + e);
//					}
//
//					@Override
//					public void handle(int responseCode, String msg, int type,
//							Object results) {
//						if (responseCode == 0 && type == 2) {
//							if (callBack != null) {
//								JSONArray jsonArray = (JSONArray) results;
//								ArrayList<PatientRecord> patients = new ArrayList<PatientRecord>();
//								for (int i = 0, count = jsonArray.length(); i < count; i++) {
//									try {
//										// PatientRecord records =
//										// EntityUtil.FromJson(jsonArray.getJSONObject(i),
//										// PatientRecord.class);
//										PatientRecord records = new PatientRecord();
//										records.setAtttributeByjson(jsonArray
//												.getJSONObject(i));
//										patients.add(records);
//									} catch (JSONException e) {
//										e.printStackTrace();
//									}
//								}
//								callBack.getPatientList(patients);
//							}
//						}
//					}
//				});
//	}

	/**
	 * 为病历和修改标签
	 * 
	 * @param patientIdList
	 *            需要修改标签的病历的ID列表
	 * @param addTagIdList
	 *            添加已经存在的标签的列表
	 * @param addTagStrList
	 *            添加不存在的标签的列表
	 * @param delTagIdList
	 *            需要删除的标签的列表
	 */
	public void attachPatients(ArrayList<Integer> patientIdList,
			ArrayList<Integer> addTagIdList, ArrayList<String> addTagStrList,
			ArrayList<Integer> delTagIdList, final SuccessCallBack onSuccess,
			final FailCallBack onFail) {
		Map<String, Object> map = new HashMap<String, Object>();
		Map<String, Object> setMap = new HashMap<String, Object>();
		Map<String, Object> removeMap = new HashMap<String, Object>();
		JSONArray patientIdArray = new JSONArray(patientIdList);
		JSONArray addTagIdArray = new JSONArray(addTagIdList);
		JSONArray addTagStrArray = new JSONArray(addTagStrList);
		JSONArray delTagIdArray = new JSONArray(delTagIdList);
		setMap.put("user_friend_id", patientIdArray);
		setMap.put("tag_id", addTagIdArray);
		setMap.put("tag", addTagStrArray);
		JSONObject setJson = new JSONObject(setMap);
		removeMap.put("user_friend_id", patientIdArray);
		removeMap.put("tag_id", delTagIdArray);
		JSONObject removeJson = new JSONObject(removeMap);
		map.put("user_id", Constants.getUser().getUserId());
		map.put("tag_set", setJson);
		map.put("tag_remove", removeJson);
		final String url = UriConstants.Conn.URL_PUB + "/tags/attach_patients.do";
		final FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		// LoopCell cell = new LoopCell(url, params);
		// HalcyonUploadLooper.getInstance().push(cell);
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						// TODO Auto-generated method stub
						if (onFail != null) {
							onFail.onFail(code, e.getMessage());
						}
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							if (onSuccess != null) {
								onSuccess.onSuccess(responseCode, msg, type,
										results);
							}
						} else {
							if (onFail != null) {
								onFail.onFail(responseCode, msg);
							}
						}
					}
				});
	}

	public void modifyTagContact(int[] adddocPatId, int[] addTagIds,
			ArrayList<String> tagTitils, int[] remdocPatIds, int[] remTagIds,
			final OnTagModifyCallback callback) {
		String[] tagTitilst = null;
		if (tagTitils != null) {
			tagTitilst = new String[tagTitils.size()];
			tagTitils.toArray(tagTitilst);
		}
		this.modifyTagContact(adddocPatId, addTagIds, tagTitilst, remdocPatIds,
				remTagIds, callback);
	}

	public void modifyTagContact(int[] adddocPatId, final int[] addTagIds,
			String[] tagTitils, final int[] remdocPatIds, int[] remTagIds,
			final OnTagModifyCallback callback) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		if (adddocPatId != null) {
			JSONObject addJson = new JSONObject();
			try {
				addJson.put("user_friend_id", new JSONArray(adddocPatId));// user-friend-id
																			// doctor_patient_id

				if (addTagIds != null) {
					JSONArray addTagId = new JSONArray(addTagIds);
					addJson.put("tag_id", addTagId);
				}

				if (tagTitils != null) {
					if(Platform.getInstance().getTargetPlatform() == Platform.PLANTFORM_ANDROID){
						JSONArray addTagTitle = new JSONArray(tagTitils);
						addJson.put("tag", addTagTitle);
					}else{
						ArrayList<String> titils = new ArrayList<String>();
						for (int i = 0; i < tagTitils.length; i++) {
							titils.add(tagTitils[i]);
						}
						JSONArray addTagTitle = new JSONArray(titils);
						addJson.put("tag", addTagTitle);
					}
				}
				map.put("tag_set", addJson);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}

		if (remdocPatIds != null) {
			JSONObject removeJson = new JSONObject();
			try {
				removeJson.put("user_friend_id", new JSONArray(remdocPatIds));

				if (remTagIds != null) {
					removeJson.put("tag_id", new JSONArray(remTagIds));
				}
				map.put("tag_remove", removeJson);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}

		String url = UriConstants.Conn.URL_PUB + "/tags/attach_patients.do";
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));

		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {
					public void onError(int code, Throwable e) {
						callback.onModifySuccess(false);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							/*
							 * JSONObject obj = (JSONObject) results; JSONArray
							 * array = obj.optJSONArray("results"); if(addTagIds
							 * == null){//新增的 for(int i = 0; i < array.length();
							 * i++){ try { JSONObject json =
							 * array.getJSONObject(i); String title =
							 * json.optString("title"); int id =
							 * json.optInt("user_friend_id"); for(User user :
							 * Constants.contactsList){ if(id ==
							 * user.getUserFriendId()){
							 * user.getTags().add(title); break; } } } catch
							 * (JSONException e) { e.printStackTrace(); } }
							 * }else{//修改 if(remdocPatIds != null){ //TODO 删除标签
							 * } for(int i = 0; i < array.length(); i++){ try {
							 * JSONObject json = array.getJSONObject(i); String
							 * title = json.optString("title"); int id =
							 * json.optInt("user_friend_id"); for(User user :
							 * Constants.contactsList){ if(id ==
							 * user.getUserFriendId()){
							 * user.getTags().add(title); break; } } } catch
							 * (JSONException e) { e.printStackTrace(); } } }
							 */

							callback.onModifySuccess(true);
						} else {
							callback.onModifySuccess(false);
						}
					}
				});
	}

	public void modifyTag(Tag tag, final OnTagModifyCallback callback) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("tag_id", new JSONArray().put(tag.getId()));
		map.put("tag_title", tag.getTitle());

		String url = UriConstants.Conn.URL_PUB + "/tags/modify_tags_title.do";
		FQHttpParams params = new FQHttpParams(JsonHelper.createJson(map));
		ApiSystem.getInstance().require(url, params, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {
					@Override
					public void onError(int code, Throwable e) {
						callback.onSuccess(null);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0 && type == 1) {
							// Tag tag =
							// EntityUtil.FromJson((JSONObject)results,
							// Tag.class);
							Tag tag = new Tag();
							tag.setAtttributeByjson((JSONObject) results);
							callback.onSuccess(tag);
						} else {
							callback.onSuccess(null);
						}
					}
				});
	}

	/**
	 * 返回所有标签的回调函数
	 */
	public interface RequestTagInfCallBack extends FQHttpResponseInterface {
		public void resTagList(ArrayList<Tag> tags);
	}

	/**
	 * 返回标签下所有病历的回调函数
	 */
	public interface RequestPatientListCallBack extends FQHttpResponseInterface {
		public void getPatientList(ArrayList<Object> records);
	}

	/**
	 * 修改标签title回调
	 */
	public interface OnTagModifyCallback {
		public void onSuccess(Tag tag);

		public void onModifySuccess(boolean isb);

		public void addTag(Tag tag);
	}

	/**
	 * 操作成功的回调函数
	 */
	public interface SuccessCallBack {
		public void onSuccess(int responseCode, String msg, int type,
				Object results);
	}

	/**
	 * 操作失败的回调函数
	 */
	public interface FailCallBack {
		public void onFail(int code, String msg);
	}
}
