package com.fq.halcyon.logic.practice;


import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.PatientAbstract;
import com.fq.halcyon.entity.practice.RecordAbstract;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

public class SendPatientLogic {

	public interface SendPatientInterface {
		public void onSendPatientSuccess(int shareMessageId,
				int sharePatientId, PatientAbstract obj);

		public void onSendPatientError(int errorCode, String msg);
	}

	public interface SendRecordInterface {
		public void onSendRecordSuccess(int shareMessageId,
				int shareRecordItemId, JSONArray shareRecordInfIds,
				RecordAbstract obj);

		public void onSendRecordError(int errorCode, String msg);
	}

	@Weak
	public SendPatientInterface mPatientInterface;

	@Weak
	public SendRecordInterface mRecordInterface;

	/***
	 * 发送病案到某个群
	 * 
	 * @param mIn
	 * @param groupId
	 * @param patientId
	 * @param shareType 0 不去身份化 1去身份化
	 */ 
	public void sendPatientToGroup(SendPatientInterface mIn, String groupId,
			int patientId, PatientAbstract obj,int shareType) {
		mPatientInterface = mIn;
		JSONObject params = new JSONObject();
		try {
			params.put("share_from_id", Constants.getUser().getUserId());
			params.put("cgroup_id", groupId);
			params.put("patient_id", patientId);
			params.put("remove_identify", shareType);
		} catch (JSONException e) {
			e.printStackTrace();
		}

		String url = UriConstants.Conn.URL_PUB
				+ "/group/send_patient_record.do";
		FQHttpParams hparams = new FQHttpParams(params);
		hparams.setTimeoutTime(60000);
		obj.setIsShowIdentity(shareType == 0);
		hparams.setTag(obj);
		ApiSystem.getInstance().require(url, hparams, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						mPatientInterface.onSendPatientError(-1,
								Constants.Msg.NET_ERROR);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {

						if (responseCode == 0) {
							JSONObject mObject = (JSONObject) results;
							int shareMessageId = mObject
									.optInt("share_message_id");
							int sharePatientId = mObject
									.optInt("share_patient_id");
							mPatientInterface.onSendPatientSuccess(
									shareMessageId, sharePatientId,
									(PatientAbstract) this.mParams.getTag());
						} else {
							mPatientInterface.onSendPatientError(responseCode,
									msg);
						}
					}
				});
	}

	/***
	 * 发送记录到某个群
	 * 
	 * @param mIn
	 * @param groupId
	 * @param patientId
	 */
	public void sendRecordToGroup(SendRecordInterface mIn, String groupId,
			int recordItemId, RecordAbstract obj,int shareType) {
		mRecordInterface = mIn;
		JSONObject params = new JSONObject();
		try {
			params.put("share_from_id", Constants.getUser().getUserId());
			params.put("cgroup_id", groupId);
			params.put("record_item_id", recordItemId);
			params.put("remove_identify", shareType);
		} catch (JSONException e) {
			e.printStackTrace();
		}

		String url = UriConstants.Conn.URL_PUB
				+ "/group/send_patient_record.do";
		FQHttpParams hparams = new FQHttpParams(params);
		hparams.setTimeoutTime(60000);
		hparams.setTag(obj);
		ApiSystem.getInstance().require(url, hparams, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						mRecordInterface.onSendRecordError(-1,
								Constants.Msg.NET_ERROR);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {

						if (responseCode == 0) {
							JSONObject mObject = (JSONObject) results;
							int shareMessageId = mObject
									.optInt("share_message_id");
							int shareRecordItemId = mObject
									.optInt("share_record_item_id");
							JSONArray shareRecordInfIds = mObject
									.optJSONArray("share_record_info_ids");
							
//							int[] shareRecordInfIds = new int[]{};
//							for (int i = 0; i < array.length(); i++) {
//								shareRecordInfIds[i] = array.optInt(i);
//							}
							
							mRecordInterface.onSendRecordSuccess(
									shareMessageId, shareRecordItemId,
									shareRecordInfIds,
									(RecordAbstract) this.mParams.getTag());
						} else {
							mRecordInterface.onSendRecordError(
									responseCode, msg);
						}

					}
				});
	}

	/***
	 * 发送记录到某个人
	 * 
	 * @param mIn
	 * @param groupId
	 * @param patientId
	 */
	public void sendRecordToUser(SendRecordInterface mIn, int toUserId,
			int recordItemId, RecordAbstract obj,int shareType) {
		mRecordInterface = mIn;
		JSONObject params = new JSONObject();
		try {
			params.put("share_from_id", Constants.getUser().getUserId());
			params.put("share_to_id", toUserId);
			params.put("record_item_id", recordItemId);
			params.put("remove_identify", shareType);
		} catch (JSONException e) {
			e.printStackTrace();
		}

		String url = UriConstants.Conn.URL_PUB
				+ "/group/send_patient_record.do";
		FQHttpParams hparams = new FQHttpParams(params);
		hparams.setTimeoutTime(60000);
		hparams.setTag(obj);
		ApiSystem.getInstance().require(url, hparams, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						mRecordInterface.onSendRecordError(-1,
								Constants.Msg.NET_ERROR);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {

						if (responseCode == 0) {
							JSONObject mObject = (JSONObject) results;
							int shareMessageId = mObject
									.optInt("share_message_id");
							int shareRecordItemId = mObject
									.optInt("share_record_item_id");
							JSONArray shareRecordInfIds = mObject.optJSONArray("share_record_info_ids");
//							int[] shareRecordInfIds = new int[]{};
//							for (int i = 0; i < array.length(); i++) {
//								shareRecordInfIds[i] = array.optInt(i);
//							}
							mRecordInterface.onSendRecordSuccess(
									shareMessageId, shareRecordItemId,
									shareRecordInfIds,
									(RecordAbstract) this.mParams.getTag());
						} else {
							mRecordInterface.onSendRecordError(
									responseCode, msg);
						}

					}
				});
	}

	/***
	 * 发送病案到某个人
	 * 
	 * @param mIn
	 * @param groupId
	 * @param patientId
	 */
	public void sendPatientToUser(SendPatientInterface mIn, int toUserId,
			int patientId, PatientAbstract obj,int shareType) {
		mPatientInterface = mIn;
		JSONObject params = new JSONObject();
		try {
			params.put("share_from_id", Constants.getUser().getUserId());
			params.put("share_to_id", toUserId);
			params.put("patient_id", patientId);
			params.put("remove_identify", shareType);
		} catch (JSONException e) {
			e.printStackTrace();
		}

		String url = UriConstants.Conn.URL_PUB
				+ "/group/send_patient_record.do";
		obj.setIsShowIdentity(shareType == 0);
		FQHttpParams hparams = new FQHttpParams(params);
		hparams.setTimeoutTime(60000);		
		hparams.setTag(obj);
		ApiSystem.getInstance().require(url, hparams, API_TYPE.DIRECT,
				new HalcyonHttpResponseHandle() {

					@Override
					public void onError(int code, Throwable e) {
						mPatientInterface.onSendPatientError(-1,
								Constants.Msg.NET_ERROR);
					}

					@Override
					public void handle(int responseCode, String msg, int type,
							Object results) {
						if (responseCode == 0) {
							JSONObject mObject = (JSONObject) results;
							int shareMessageId = mObject
									.optInt("share_message_id");
							int sharePatientId = mObject
									.optInt("share_patient_id");
							mPatientInterface.onSendPatientSuccess(
									shareMessageId, sharePatientId,
									(PatientAbstract) this.mParams.getTag());
						} else {
							mPatientInterface.onSendPatientError(responseCode,
									msg);
						}
					}
				});
	}
}
