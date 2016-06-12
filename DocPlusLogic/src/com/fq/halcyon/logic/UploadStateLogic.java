package com.fq.halcyon.logic;

import java.io.File;
import java.util.ArrayList;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.HalyconOnLineHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.Photo;
import com.fq.http.async.FQHttpParams;
import com.fq.http.async.uploadloop.LoopCellHandle;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class UploadStateLogic {

	public enum RecordsState {

		/**
		 * 上传失败
		 */
		UPLOADING_FAILED,

		/**
		 * 上传中
		 */
		UPLOADING,

		/**
		 * 上传成功
		 */
		UPLOADED,

		/**
		 * 识别失败
		 */
		IDENTIFUCATION_FAILED,
		
		/**
		 * 无法识别
		 */
		CANT_IDENTIFUCATION,

		/**
		 * 识别中
		 */
		IDENTIFUCATION,

		/**
		 * 完成识别
		 */
		IDENTIFUCATION_COMPLETED,

	}

	public interface OnGetOnlineStateListener {
		public void OnGetOnlineState(ArrayList<StateItem> items);

		public void onError(int code, Throwable e);
	}

	private OnGetOnlineStateListener mListener;

	public class StateItem {

		public ArrayList<Photo> mImages;

		public RecordsState mState;

		public String mTitle;

		public int mUploadedCount = 0;

		public int mTotalCount = 0;

		public int mRecordType = 0;
		
		public int mRecordId = 0;

		public LoopCellHandle mUpLoadHandle;

		public long mTime;

		/**
		 * 审核状态 0 等待OCR识别 1 待识别员识别 2 待审核 3审核通过 4 审核失败 5是无法识别 7已删除
		 */
		public int mIdentifucationState;

		public StateItem() {
			mImages = new ArrayList<Photo>();
			mState = RecordsState.UPLOADING;
			mTitle = "入院";
		}
	}

	public UploadStateLogic(OnGetOnlineStateListener l) {
		mListener = l;
	}

	public void getOnLineStates() {
		if (Constants.getUser() == null)
			return;
		JSONObject object = new JSONObject();
		JSONObject record = new JSONObject();
		try {
			record.put("user_id", Constants.getUser().getUserId());
			object.put("record", record);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		ApiSystem.getInstance().require(UriConstants.Conn.URL_PUB + "/records/list_recognition.do", new FQHttpParams(object), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				if (mListener != null)
					mListener.onError(code, e);
			}

			@Override
			public void handle(int responseCode, String msg, int type, Object results) {
				if (responseCode == 0 && type == 2) {
					ArrayList<StateItem> mItems = new ArrayList<StateItem>();
					JSONArray array = (JSONArray) results;
					for (int i = 0; i < array.length(); i++) {
						JSONObject pObject = array.optJSONObject(i);
						StateItem item = new StateItem();
						item.mTitle = pObject.optString("patient_name");
						int identifucationState = pObject.optInt("status");
						item.mIdentifucationState = identifucationState;
						//参考: http://114.215.196.3:7090/pages/viewpage.action?pageId=1638884#id-2.%E9%A6%96%E9%A1%B5-2.9%E8%AF%B7%E6%B1%82%E5%BD%93%E5%89%8D%E4%BA%91%E8%AF%86%E5%88%AB%E5%88%97%E8%A1%A8
						//不过下面的代码很奇怪，TODO 需要清理
						if(item.mState == RecordsState.IDENTIFUCATION_COMPLETED) {
							continue;
						}
						item.mRecordId =  pObject.optInt("record_id");
						if (identifucationState == 0){
							item.mState = RecordsState.UPLOADED;
						} else if (identifucationState < 3) { //both 1：待识别员识别；2：待审核；
							item.mState = RecordsState.IDENTIFUCATION;
						} else if (identifucationState == 3) {
							item.mState = RecordsState.IDENTIFUCATION_COMPLETED;
						} else {
							item.mState = RecordsState.IDENTIFUCATION_FAILED;
							if(identifucationState == 5){
								item.mState = RecordsState.CANT_IDENTIFUCATION;
							}
						}
						item.mRecordType = pObject.optInt("record_type");
						item.mTime = pObject.optLong("update_time", 0);
						JSONArray images = pObject.optJSONArray("images");
						if (images != null) {
							for (int j = 0; j < images.length(); j++) {
								JSONObject imObject = images.optJSONObject(j);
								Photo image = new Photo();
								image.setAtttributeByjson(imObject);
								item.mImages.add(image);
							}
						}
						mItems.add(item);
					}
					if (mListener != null)
						mListener.OnGetOnlineState(mItems);
				}
			}
		});

	}

	public void delete(final StateItem item) {
		if (item == null || item.mRecordId == 0)
			return;
		String deleteUrl = UriConstants.Conn.URL_PUB + "/records/delete.do";
		JSONObject params = new JSONObject();
		JSONObject record = new JSONObject();
		try {
			params.put("record", record);
			record.put("user_id", Constants.getUser().getUserId());
			record.put("record_id", item.mRecordId);
			record.put("record_status", item.mIdentifucationState);
		} catch (Exception e) {
		}
		ApiSystem.getInstance().require(deleteUrl, new FQHttpParams(params), API_TYPE.ONLINE, new HalyconOnLineHandle() {

			@Override
			public void saveData(boolean success) {
				if (success) {
					// 删除本地文件
					for (int i = 0; i < item.mImages.size(); i++) {
						Photo photo = item.mImages.get(i);
						String localPath = photo.getLocalPath();
						if(localPath != null && !localPath.equals("")){
							File localImagePath = new File(localPath);
							if (localImagePath.exists())
								localImagePath.delete();
						}
					}
					
				}
			}

			@Override
			public void handle(int responseCode, String msg, int type, Object results) {

			}

			@Override
			public void onError(int code, Throwable e) {
			}

		});

	}

}
