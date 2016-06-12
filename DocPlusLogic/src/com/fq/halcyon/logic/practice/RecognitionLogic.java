package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.RecordAbstract;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.StrDataComparator;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 病历记录识别的接口，用于请求待识别和识别完成（包括识别失败）的列表数据
 * @author reason
 */
public class RecognitionLogic {
	
	/**每页数量，默认为5条*/
	public static final int PAGE_SIZE = 5;
	
	/**待识别的记录*/
	public static final int REQUEST_RECGN_WAIT = 0;
	
	/**云识别中的记录*/
	public static final int REQUEST_RECGN_ING = 1;
	
	/**识别完成的记录：包括云识别完成和云识别失败*/
	public static final int REQUEST_RECGN_END = 2;
	
	/**所有识别的记录(目前没有待云识别的)*/
	public static final int REQUEST_RECGN_ALL = 3;
	
	@Weak
	private RecognitionCallBack mCallBack;

	
	@Weak
	private ApplyRecognizeCallBack mApplyCallback;
		
	/**
	 * 初始化，传入加载云识别列表的回调
	 * @param callBack
	 */
	public RecognitionLogic(RecognitionCallBack callBack) {
		mCallBack = callBack;
	}
	
	/**
	 * 初始化，传入申请云识别的回调
	 * @param callback
	 */
	public RecognitionLogic(ApplyRecognizeCallBack callback){
		mApplyCallback = callback;
	}
	
	/**
	 * 请求病历记录的识别列表（分为：待识别、识别完成[包括识别失败]）
	 * @param recgnizeStatus 当前的识别状态 REQUEST_RECGN_WAIT（待识别）REQUEST_RECGN_ING（云识别中） REQUEST_RECGN_END（识别完成）
	 * @param page 需要返回第几页的数据
	 * @param pageSize 每页数据的数量
	 */
	public void loadRecognitionList(int recgnizeStatus, int page, int pageSize){
		JSONObject params = JsonHelper.createUserIdJson();
		try{
			params.put("recgnize_status", recgnizeStatus);
			params.put("page", page);
			params.put("page_size", pageSize==0?PAGE_SIZE:pageSize);
		}catch(Exception e){
			e.printStackTrace();
			FQLog.i("请求搜索病案或病历时,构造参数出错");
		}
		
		String url = UriConstants.Conn.URL_PUB+"/record/select_recent_item.do";
		
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mCallBack.recognzeError(-1, Constants.Msg.NET_ERROR);
			}

			@Override
			public void handle(int responseCode, String msg, int type,Object results) {
				if(responseCode == 0){
					try {
						JSONArray array = ((JSONObject)results).getJSONArray("record_items");
						HashMap<String, ArrayList<RecordAbstract>> map = new HashMap<String, ArrayList<RecordAbstract>>();
						ArrayList<String> keys = new ArrayList<String>();
						
						//组装数据
						for(int i = 0; i < array.length(); i++){
							JSONObject json = array.getJSONObject(i);
							RecordAbstract record = new RecordAbstract();
							record.setAtttributeByjson(json);
							
							String fileTime = record.getFileTime();
							ArrayList<RecordAbstract> records = map.get(fileTime);
							if(records == null){
								records = new ArrayList<RecordAbstract>();
								map.put(fileTime, records);
								keys.add(fileTime);
							}
							records.add(record);
						}
						
						
						Collections.sort(keys, new StrDataComparator());
						
//						for(int i = 0; i < keys.size();i++){
//							FQLog.i("~~~~"+i+":"+keys.get(i));
//							FQLog.i("----1-time:"+map.get(keys.get(i)).get(0).getFileTime());
//						}
						
						mCallBack.recognzeReturnData(keys,map);
					} catch (JSONException e) {
						FQLog.i("获得识别记录列表时，解析返回数据异常");
						e.printStackTrace();
					}
				}else{
					mCallBack.recognzeError(responseCode, msg);
				}
			}
		});
	}
	
	
	/**
	 * 请求服务器对病历记录进行云识别
	 * @param records 可以一个或多个，所以传入arrayList.
	 */
	public void applyRecognize(ArrayList<RecordAbstract> records){
		JSONObject params = JsonHelper.createUserIdJson();
		
		try {
			JSONArray array = new JSONArray();
			for(int i = 0; i < records.size(); i++){
				array.put(records.get(i).getRecordItemId());
			}
			params.put("record_item_ids", array);
		} catch (JSONException e) {
			FQLog.i("构建对病历记录云识别的请求参数出错");
			e.printStackTrace();
		}
		
		String url = UriConstants.Conn.URL_PUB + "/record/item/get_anticipate_time.do";
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mApplyCallback.applyError(code, Constants.Msg.NET_ERROR);
			}

			@Override
			public void handle(int responseCode, String msg, int type,
					Object results) {
				if(responseCode == 0){
					mApplyCallback.applyRecognizeSuccess();
				}else{
					mApplyCallback.applyError(responseCode, msg);
				}
			}
		});
	}
	
	
	/**
	 * 识别列表的回调接口
	 * @author Reason
	 */
	public interface RecognitionCallBack {
		
		/**
		 * 请求成功后的返回数据
		 * @param keys 返回的数据Map的有序的key值
		 * @param 按日期归纳的数据map
		 */
		public void recognzeReturnData(ArrayList<String> keys,HashMap<String, ArrayList<RecordAbstract>> recordMap);
		
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void recognzeError(int code,String msg);
	}
	
	/**
	 * 申请云识别的回调接口
	 * @author Reason
	 */
	public interface ApplyRecognizeCallBack{
		/**
		 * 接口访问成功的回调方法。
		 * @param keys 列表以时间为参照组装成的Map的所有key的集合。
		 * @param map 列表以时间为参照组装成的Map。
		 */
		public void applyRecognizeSuccess();
		
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void applyError(int code,String msg);
	}
}
