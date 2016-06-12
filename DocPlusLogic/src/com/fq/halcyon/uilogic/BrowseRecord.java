package com.fq.halcyon.uilogic;

import java.util.HashMap;
import java.util.Iterator;

import com.fq.lib.json.JSONObject;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.Tool;

/**
 * 用于浏览病历界面的数据解析
 */
public class BrowseRecord {
	
    /**
     * 入院的头信息
     */
	public String[] ruyuanHead = {"姓名","性别","年龄","病区","床号","住院号","名族","婚否","职业","住址","出生地","入院日期","病史采集日期","病史记录日期","病史陈述着"};
	/**
	 * 化验的头信息 
	 */
	public String[] huayanHead = {"姓名","性别","年龄","病历号","病区","床号","病人类型","化验单名称","标本编号","样本类型","采样时间","临床诊断","送检医生","接收日期","报告日期","检验师","核对者"};
	/**
	 * 影像的头信息 
	 */
	public String[] yingxiangHead = {"姓名","年龄","性别","病区","床号","ID号","住院号","检查设备","临床诊断"};
	/**
	 * 手术记录
	 */
	public String[] shoushuHead = {"姓名","病区","床号","ID号","住院号","入院日期","住址","职业"};
	/**
	 * 出院记录
	 */
	public String[] chuyuanHead = {"姓名","入院日期","职业","住址","科别","病区","床号","ID号","住院号","性别","年龄","X线号","CT号"};
	/**
	 * 基本信息的map
	 */
	private HashMap<String, Object> headMap;
	/**
	 * 详细信息的map
	 */
	private HashMap<String, Object> infoMap;
	
	/**
	 * @param obj  得到的病历详情的json数据
	 * @param headType  病历类型</br>
	 */
	public BrowseRecord(JSONObject obj ,int type) {
		headMap = new HashMap<String, Object>();
		infoMap = new HashMap<String, Object>();
		getHeadInfo(obj ,type);
	}
	
	/**
	 * 获取病历头信息
	 */
	public HashMap<String, Object> getHeadMap() {
		return headMap;
	}

	/**
	 * 获取病历详细
	 */
	public HashMap<String, Object> getInfoMap() {
		return infoMap;
	}
	
	private void getHeadInfo(JSONObject obj ,int type){
		
		HashMap<String, Object> map = Tool.getMapByJsonObject(obj);
		HashMap<String, Object> headmap = new HashMap<String, Object>();
		Iterator<String> iter = map.keySet().iterator();
		String[] headItems = {};
		switch (type) {
		case RecordConstants.TYPE_ADMISSION:
			headItems = ruyuanHead;
			break;
		case RecordConstants.TYPE_EXAMINATION:
			headItems = huayanHead;
			break;
		case RecordConstants.TYPE_MEDICAL_IMAGING:
			headItems = yingxiangHead;
			break;
		case RecordConstants.TYPE_SUGERY:
			headItems = shoushuHead;
			break;
		case RecordConstants.TYPE_DISCHARGE:
			headItems = chuyuanHead;
			break;
		default:
			break;
		}
		int count = headItems.length;
		while(iter.hasNext()){
			boolean b = true;
			String key = iter.next();
			for(int i = 0 ; i < count && b;  i++){
				String item = headItems[i];
				if(item.equals(key)){
					headMap.put(item, map.get(item));
					b = false;
				}
			}
			if(b){
				infoMap.put(key, map.get(key));
			}
		}
	}
}
