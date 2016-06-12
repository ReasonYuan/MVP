package com.fq.halcyon.uilogic;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.entity.RecordItem;
import com.fq.halcyon.entity.RecordItem.DetailItem;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.DES3Utils;
import com.fq.lib.platform.Platform;
import com.fq.lib.tools.FQLog;

/**
 * 普通（非化验）记录的数据逻辑，主要用于对数据的各种操作，<br/>
 * 方便UI上直接使用。
 * @author reason
 *
 */
public class RecordDTNormalLogic extends RecordDTLogic{
	
	/**病历记录的锚点*/
	public ArrayList<String> mTemplates = new ArrayList<String>();
	
	
	private ArrayList<String> mEditTypeList;
	
//=====================================UI需要用到的方法（Start）========================================	
	
	/**
	 * 初始化
	 * @param RecordExamDTCallBack 对数据做操作后的UI回调
	 */
	public RecordDTNormalLogic(RecordDTCallBack callback){
		super(callback);
	}
	
	
	/**
	 * 获得锚点总数
	 * @return
	 */
	public int getTemplementsCount(){
		return mTemplates.size();
	}
	
	/**
	 * 获得某一个锚点
	 * @param index 这个锚点的序号
	 * @return 锚点的内容
	 */
	public String getTemplatesByIndex(int index){
		return mTemplates.get(index);
	}
	
	/**
	 * 获取记录信息的总条数
	 * @return
	 */
	public int getInfoCount(){
		return mRecordItem.getDetails().size();
	}
	
	/**
	 * 获取记录信息的总条数
	 * @return
	 */
	public int getHospital(){
		return mRecordItem.getHospitalID();
	}
	
	/**
	 * 获取记录名称
	 * @return
	 */
	public String getRecordName(){
		return mRecordItem.getRecordTitle();
	}

	/**
	 * 获得某一项数据的title
	 * @param index 记录详情中某一项数据的序号
	 * @return 该项的title
	 */
	public String getInfoTitleByIndex(int index){
		return mRecordItem.getDetails().get(index).mTitle;
	}
	
	/**
	 * 获得某一项数据的内容
	 * @param index 记录详情中某一项数据的序号
	 * @return 该项的内容
	 */
	public String getInfoContentByIndex(int index){
		return mRecordItem.getDetails().get(index).mContent;
	}
	
	/**
	 * 通过锚点得到对应的数据，目前这个方法没有用
	 * @param template
	 * @return
	 */
	public int getIndexByTemplate(String template){
		for(int i = 0; i < mTemplates.size(); i++){
			if(template.equals(mTemplates.get(i))){
				return i;
			}
		}
		return 0;
	}

	/**保存编辑了的内容*/
	public void editContent(int index,String content){
		DetailItem item = mRecordItem.getDetails().get(index);
//        item.mTitle = "姓名";
		item.mContent = content;
		if(mEditTypeList == null)mEditTypeList = new ArrayList<String>();
		
		boolean noHave = true;
		for(int i = 0; i < mEditTypeList.size(); i++){
			if(item.mInfoTyp.equals(mEditTypeList.get(i))){
				noHave = false;
				break;
			}
		}
		if(noHave)mEditTypeList.add(item.mInfoTyp);
	}
	
	/**
	 * 请求保存的数据到服务器
	 */
	public void saveEditInfo(){
		if(mEditTypeList == null){
			doBack(true);
			return;
		}
		HashMap<String, String> map = new HashMap<String, String>();
		
		//构建修改了的数据
		for(int i = 0; i < mEditTypeList.size(); i++){
			String type = mEditTypeList.get(i);
			ArrayList<DetailItem> items = mRecordItem.getInfoMap().get(type);
			
			JSONArray array = new JSONArray();
			
			for(DetailItem item:items){
				JSONObject json = new JSONObject();
				try {
					json.put("index", item.index);
					json.put(item.mTitle, item.mContent);
                    array.put(json);
				} catch (JSONException e) {
					FQLog.i("构建修改记录信息出错");
					e.printStackTrace();
				}
			}
			
			String content =  array.toString();
			//如果是身份化信息，则需要加密
			if(RecordItem.DETAILTYPE_BASE_IDN.equals(type)||RecordItem.DETAILTYPE_NOTE_IDN.equals(type)){
				content = DES3Utils.encryptMode(content.getBytes(), Platform.getInstance().getRecord3DesKey());
			}
			
			map.put(type, content);
		}
		modifyRecord(map);
	}
	
	//=====================================UI需要用到的方法（End）========================================	
	
	
	@Override
	public void initDataSuccess() {
		mTemplates = mRecordItem.getInfoTitles();
	}
	
	
	
	//---------------------------------------UI在用数据逻辑时需要实现的回调---------------------------------
}
