package com.fq.lib.record;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.HalcyonUploadLooper;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.halcyon.entity.RecordType;
import com.fq.halcyon.uimodels.OneCopy;
import com.fq.halcyon.uimodels.OneType;
import com.fq.http.async.uploadloop.LoopCellHandle;
import com.fq.http.async.uploadloop.LoopUpLoadCell;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.TimeFormatUtils;

/**
 * 处理与病历相关算法的工具类</br>
 * 病案*病历*病历记录
 * @author reason
 */
public class RecordTool {
	
	/**
	 * 存放病历记录数据的模板列表
	 */
	public static final HashMap<Integer, JSONObject> mRecordMoudles = new HashMap<Integer, JSONObject>();
	
	/**
	 * 将病历记录的数据模板添加到模板列表里面
	 * @param type 病历记录的类型
	 * @param moudle 这个病历记录的数据模板
	 */
	public static void addMoudle(int type,JSONObject moudle){
		if(!mRecordMoudles.containsKey(type)){
			mRecordMoudles.put(type, moudle);
		}
	}
	
	/**
	 * 将本地模板文本转为json数据
	 * @param moudle 本地数据模板JsonArray数组
	 * @param data 从服务器得到的数据（将要格式化）的数据
	 * @return 通过格式化的数据
	 */
	public static JSONObject getMouldJson(JSONArray moudle,JSONObject data){
		JSONObject obj = new JSONObject();
		for(int i = 0; i < moudle.length(); i++){
			String key = moudle.optString(i);
			String value = data.optString(key);
			if(!"".equals(value)){
				try {
					obj.put(key, value);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		}
		return obj;
	}
	
	
	/**
	 * 通过病历记录的类型从模板列表得到这个病历记录的数据模板
	 * @param type 病历记录的类型
	 * @param moudle 病历记录的数据模板，如果模板列表里面没有则返回null
	 */
	public static JSONObject getMoudleByType(int type){
		return mRecordMoudles.get(type);
	}
	
	
	
	
	/**
	 * 获取所有识别成功的病历的列表
	 * @param mRecordTypes
	 * @return
	 */
	public static ArrayList<RecordItemSamp> getAllRecRecord(ArrayList<RecordType> mRecordTypes){
		ArrayList<RecordItemSamp> itemList = new ArrayList<RecordItemSamp>();
		for (int i = 0; i <mRecordTypes.size() ; i++) {
			RecordType recordType = mRecordTypes.get(i);
			for (int j = 0; j < recordType.getItemList().size(); j++) {
				RecordItemSamp itemSamp = recordType.getItemList().get(j);
				if (itemSamp.getRecStatus() == RecordItemSamp.REC_SUCC) {
					itemList.add(itemSamp);
				}
			}
		}
		return itemList;
	}
	
	/**
	 * 获取所有的病历列表
	 * @param mRecordTypes
	 * @return
	 */
	public static ArrayList<RecordItemSamp> getAllRecordItem(ArrayList<RecordType> mRecordTypes){
		ArrayList<RecordItemSamp> itemList = new ArrayList<RecordItemSamp>();
		for (int i = 0; i <mRecordTypes.size() ; i++) {
			RecordType recordType = mRecordTypes.get(i);
			for (int j = 0; j < recordType.getItemList().size(); j++) {
				RecordItemSamp itemSamp = recordType.getItemList().get(j);
				itemList.add(itemSamp);
			}
		}
		return itemList;
	}
	
	/**
	 * 判断病历类型是否还能拍照添加记录
	 * @param type
	 * @return
	 */
	public static boolean isTypeCatch(RecordType type){
		if((type.getRecordType() == RecordConstants.TYPE_ADMISSION && type.getItemList().size() > 0) ||
				(type.getRecordType() == RecordConstants.TYPE_DISCHARGE && type.getItemList().size() > 0)){
			return false;
		}
		return true;
	}
	
	/**
	 * 从拍摄界面界面返回, 返回数据ArrayList<oneType>,将oneType里面的oneCopy<br>
	 * 添加到对应RecordType的ArrayList<RecordItemSamp>里,因为OneCopy与RecordItemSamp<br/>
	 * 不同类型，所以需要new一个RecordItemSamp，然后把参数复制过去。复制完数据后刷新界面...
	 */
	public static void updateDataFromSnap(ArrayList<RecordType> types, ArrayList<OneType> tps){
		for(int i = 0; i < tps.size(); i++){
			OneType onetp = tps.get(i);
			for(int j = 0; j < types.size(); j++){
				RecordType type = types.get(j);
				if (type.getRecordType() == onetp.getType()) {
					
					//先删除里面的假数据
					if(type.getItem(0).getRecStatus() == RecordItemSamp.REC_NONE_DATA){
						type.getItemList().remove(0);
					}
					
					//有onetp,那么里面必有onecopy,也必有图片
					OneCopy copy = onetp.getCopyById(0);
					RecordItemSamp item = new RecordItemSamp();
					item.setRecStatus(RecordItemSamp.REC_UPLOAD);
					item.setReocrdType(type.getRecordType());
					item.setPhotos(copy.getPhotos());
					item.setImageCount(copy.getPhotos().size());
					item.setUploadTime(TimeFormatUtils
							.getTimeByFormat(System
									.currentTimeMillis(),
									"yyyyMMdd HH:mm"));
					type.getItemList().add(0, item);
					RecordUploadNotify.getInstance().addItems(copy.getPhotos());
				}
			}
		}
	}
	
	/**
	 * 检查病历类型，如果顺序不对则按照顺序排列</br>
	 * 如果没有某种类型的病历则创建一个加入到需要的位置.
	 * @param recordType 病历类型的Type,分为门诊和住院
	 * @param recordTypes 传入的源病历（入院、化验等）集合。
	 */
	public static void addAndFormatTypes(int recordType,ArrayList<RecordType> recordTypes){
		int[] types = RecordConstants.getTypesByRecordType(recordType);
		for (int i = 0; i < types.length; i++) {
			int id = types[i];
			boolean isExits = false;
			for (int j = 0; j < recordTypes.size(); j++) {
				RecordType type = recordTypes.get(j);
				if (type.getRecordType() == id) {
					recordTypes.remove(type);
					recordTypes.add(i, type);
					isExits = true;
					break;
				}
			}
			if (!isExits) {
				RecordType type = new RecordType();
				type.setRecordType(id);
				recordTypes.add(i, type);
			}
		}
	}
	
	/**
	 * 添加某病历下正在上传的各类型的病历到给定病历集合对应的类型下
	 * @param recordId 该病历的id
	 * @param recordTypes 需要添加到的拥有各类型病历的集合
	 */
	public static void addUploadReocrd(int recordId,ArrayList<RecordType> recordTypes){
		ArrayList<LoopCellHandle> handles = HalcyonUploadLooper.getInstance().getUploadArray();
		ArrayList<RecordType> uploadRecordTypes = new ArrayList<RecordType>();
		//找到指定病历下正在上传的所有病历记录（图片）
		for (int i = 0; i < handles.size(); i++) {
			if(handles.get(i) != null && handles.get(i).cell != null && handles.get(i).cell instanceof LoopUpLoadCell){
				LoopUpLoadCell cell = (LoopUpLoadCell)handles.get(i).cell;
				if(recordId == cell.getRecordId()){
					ArrayList<RecordType> types = cell.todRecordTypes();
					uploadRecordTypes.addAll(types);
					//增加上传完成后需要通知的图片集
					for(RecordType type:types){
						for(RecordItemSamp item:type.getItemList()){
							RecordUploadNotify.getInstance().addItems(item.getPhotos());
						}
					}
				}
			}
		}
		
		for (int j = 0; j < uploadRecordTypes.size(); j++) {
			for (int i = 0; i < recordTypes.size(); i++) {
				if(uploadRecordTypes.get(j).getRecordType() == recordTypes.get(i).getRecordType()){
					recordTypes.get(i).addItems(0,uploadRecordTypes.get(j).getItemList());
					break;
				}
			}
		}
	}
	
	
	/**
	 * 检查病历里面的数据，如果没有某种类型的病历记录<br/>
	 * 则构造一个假的数据，用于UI显示
	 * @param types
	 */
	public static void checkNewTypes(RecordType type){
		if(type.getItemList().size() == 0){
			RecordItemSamp item = new RecordItemSamp();
			item.setReocrdType(type.getRecordType());
			item.setRecStatus(RecordItemSamp.REC_NONE_DATA);
			type.getItemList().add(item);
		}
	}
}
