package com.fq.halcyon.uilogic;

import java.util.Iterator;

import com.fq.halcyon.entity.RecordItem;
import com.fq.halcyon.entity.care.MedicalItem;
import com.fq.halcyon.logic2.GetRecordItemLogic;
import com.fq.halcyon.logic2.GetRecordItemLogic.RecordItemCallBack;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;

/***
 * 体检报告文字(网页)版的UI逻辑，上方为表格，下方为文字
 * @author reason
 *
 */
public class ReportDocumentUILogic implements RecordItemCallBack{
	
	/**得到记录详情的逻辑类*/
	private GetRecordItemLogic mLogic;
	
	/**体检子项的实体类*/
	private MedicalItem mMedicalItem;
	
	/**该项目的记录详情，即体检结果详情*/
	private RecordItem mRecordItem;
	
	private ReportDocumentUICallBack mCallback;
	
	public ReportDocumentUILogic(MedicalItem item,ReportDocumentUICallBack callback){
		mMedicalItem = item;
		mCallback = callback;
	}
	
	
	public void loadRecordItem(){
		if(mLogic == null){
			mLogic = new GetRecordItemLogic(this);
		}
		mLogic.loadRecordItem(mMedicalItem.getInfoId(), false);
	}

	public String getChartHead(){
//		try {
//			JSONArray array = new JSONArray(mRecordItem.getOtherStr());
//			return array.optString(0).toString();
//		} catch (JSONException e) {
//			e.printStackTrace();
//			return "";
//		}
		return mRecordItem.getOtherStr();
	}
	
	public String getChartBody(){
		return mRecordItem.getExamStr();
	}

	public String getDocument(){
		JSONArray array = new JSONArray();
		try {
            String notes = mRecordItem.getNoteStr();
			JSONArray datas = new JSONArray(notes);
			for(int i = 0; i < datas.length(); i++){
				JSONObject json = datas.optJSONObject(i);
				if(json != null){
					Iterator<String> itor = json.keys();
					while(itor.hasNext()){
						String key = itor.next();
						if("index".equals(key))continue;
						JSONArray jry = new JSONArray();
						jry.put(key);
						jry.put(json.optString(key));
						array.put(jry);
					}
				}
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		return array.toString();
	}
	
	@Override
	public void doRecordItemBack(RecordItem recordItem) {
		if(recordItem != null){
			mRecordItem = recordItem;
		}
        mCallback.loadRecordCallback(recordItem != null);
	}	
	
	
	
	public interface ReportDocumentUICallBack{
		
		/**
		 * 加载record成功与否的回调
		 * @param isb 如果从服务器加载数据成功返回true,否则返回false
		 */
		public void loadRecordCallback(boolean isb);
		
		
	}
}
