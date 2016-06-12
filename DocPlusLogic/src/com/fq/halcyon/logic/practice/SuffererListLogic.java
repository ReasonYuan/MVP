package com.fq.halcyon.logic.practice;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.practice.SuffererAbstract;
import com.fq.http.async.FQHttpParams;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.StrDataComparator;
import com.fq.lib.tools.UriConstants;
import com.google.j2objc.annotations.Weak;

/**
 * 获取医生患者列表的接口逻辑
 * @author reason
 *
 */
public class SuffererListLogic {

	@Weak
	private SuffererListCallBack mCallback;
	
	/**
	 * 获得记录列表的接口逻辑的构造方法
	 * @param callback 接口访问完后的回调
	 */
	public SuffererListLogic(SuffererListCallBack callback){
		mCallback = callback;
	}
	
	/**
	 * 加载医生患者列表
	 * @param userId 用户的id
	 * @param recordType 想要获取的病历记录的类型，为0表示所有类型
	 * @param page 列表的第几页
	 * @param pageSize 每页列表的记录条数，为0时默认为5条
	 */
	public void loadSufferersList(int userId){
		//TODO==YY==测试时使用假数据。。当前所取数据有冗余，到时需处理(此处取得除了患者列表外还有医生好友列表)
//		SuffererAbstract suffer = new SuffererAbstract();
//		suffer.setSuffererId(255);
//		suffer.setSuffererName("王二小");
//		
//		ArrayList<String> keys = new ArrayList<String>();
//		HashMap<String, ArrayList<SuffererAbstract>> map = new HashMap<String, ArrayList<SuffererAbstract>>();
//		ArrayList<SuffererAbstract> list = new ArrayList<SuffererAbstract>();
//		list.add(suffer);
//		map.put("20150827", list);
//		mCallback.suffererListCallback(keys, map);
		
		JSONObject params = JsonHelper.createUserIdJson();

		String url = UriConstants.Conn.URL_PUB + "/users/doctor_friends_list.do";		
		ApiSystem.getInstance().require(url, new FQHttpParams(params), API_TYPE.DIRECT, new HalcyonHttpResponseHandle() {

			@Override
			public void onError(int code, Throwable e) {
				mCallback.suffererListCallbackError(code, Constants.Msg.NET_ERROR);
			}

			@Override
			public void handle(int responseCode, String msg, int type,Object results) {
				if(responseCode == 0){    
					ArrayList<String> keys = new ArrayList<String>();
					HashMap<String, ArrayList<SuffererAbstract>> map = new HashMap<String, ArrayList<SuffererAbstract>>();
					
					JSONObject json = (JSONObject)results;

					JSONArray array = json.optJSONArray("patients");
					if(array == null){
						mCallback.suffererListCallback(keys, map);
						return;
					}
					
					for(int i = 0; i < array.length(); i++){
						try {
							SuffererAbstract suffer = new SuffererAbstract();
							suffer.setAtttributeByjson(array.getJSONObject(i));
							
							String time = suffer.getUpdateTime();
							if("".equals(time))time="不详";
							
							ArrayList<SuffererAbstract> sufferers = map.get(time);
							if(sufferers == null){
								sufferers = new ArrayList<SuffererAbstract>();
								map.put(time, sufferers);
								keys.add(time);
							}
							sufferers.add(suffer);
						} catch (JSONException e) {
							e.printStackTrace();
						}
					}
					Collections.sort(keys, new StrDataComparator());
					mCallback.suffererListCallback(keys, map);
				}else{
					mCallback.suffererListCallbackError(responseCode, msg);
				}
			}
		});
	}
	
	
	/**
	 * 获得医生的患者列表的接口的回调
	 * @author reason
	 */
	public interface SuffererListCallBack{
		
		/**
		 * 接口访问成功的回调方法。
		 * @param keys 列表以时间为参照组装成的Map的所有key的集合。
		 * @param map 列表以时间为参照组装成的Map。
		 */
		public void suffererListCallback(ArrayList<String> keys,HashMap<String, ArrayList<SuffererAbstract>> map);
		
		/**
		 * 请求错误的回调(包括访问出错和服务器出错)。
		 * @param code 错误信息的代号
		 * @param msg  错误信息的内容
		 */
		public void suffererListCallbackError(int code,String msg);
	}
}
