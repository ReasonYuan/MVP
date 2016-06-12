package com.fq.halcyon.uilogic;

import java.util.ArrayList;
import java.util.HashMap;

import com.fq.halcyon.entity.RecordItem;
import com.fq.halcyon.entity.practice.PatientAbstract;
import com.fq.halcyon.logic2.GetRecordItemLogic;
import com.fq.halcyon.logic2.GetRecordItemLogic.ModifyItemCallBack;
import com.fq.halcyon.logic2.GetRecordItemLogic.RecordItemCallBack;
import com.fq.lib.tools.Constants;
import com.google.j2objc.annotations.Weak;

/**
 * 记录详情的逻辑父类，子类分别有：
 * RecordDTNormalLogic：处理非化验单数据的逻辑
 * RecordDTExamLogic：处理化验单数据的逻辑
 * @author reason
 *
 */
public abstract class RecordDTLogic implements RecordItemCallBack,ModifyItemCallBack{

	/**
	 * 病历记录详细信息
	 */
	protected RecordItem mRecordItem;
	
	
	/**
	 * 从服务器获得数据的逻辑 
	 */
	protected GetRecordItemLogic mRecordLogic;
	
	/**
	 * UI处理数据的回调
	 */
	@Weak
	protected RecordDTCallBack mDTCallback;
	
	
	/**
	 * 初始化
	 * @param RecordExamDTCallBack 对数据做操作后的UI回调
	 */
	public RecordDTLogic(RecordDTCallBack callback){
		mDTCallback = callback;
		mRecordLogic = new GetRecordItemLogic(this);
	}
	
	
	public ArrayList<Integer> getImgIds(){
		return mRecordItem.getImageIds();
	}
	
	
	/**
	 * 获得记录识别完成的时间
	 * @return
	 */
	public String getRecTime(){
		return mRecordItem.getRecogTime();
	}
	
	/**
	 * 获得通知信息
	 * @return
	 */
	public String getNoticeMessage(){
		return mRecordItem.getNoticeMessage();
	}
	
	/**
	 * 获得病历标题
	 * @return
	 */
	public String getRecordTitle(){
		return mRecordItem.getRecordTitle();
	}
	
	/**
	 * 获得记录详情实例
	 * 只在界面跳转传递参数时使用
	 * @return
	 */
	public RecordItem getRecordItem(){
		return mRecordItem;
	}
	
	
	/**
	 * 得到改记录详情所属的病案
	 * @return PatientAbstract 病案
	 */
	public PatientAbstract getPatientAbstract(){
		PatientAbstract patient = new PatientAbstract();
		patient.setPatientId(mRecordItem.getPatientId());
		return patient;
	}
	
	//=====================================UI需要用到的方法（Start）========================================
	/**
	 * 访问服务器加载记录数据详细信息
	 */
	public void resquestRecordDetailData(int recordInfoId){
//		if(mRecordLogic == null){
//			mRecordLogic = new GetRecordItemLogic(this);
//		}
		//TODO==YY==是否显示去身份化信息，默认都不去身份化，需要和服务器沟通接口
		mRecordLogic.loadRecordItem(recordInfoId, false);
	}
	
	
	public void modifyRecord(HashMap<String, String> modifyMap){
		mRecordLogic.modifyRecordItem(mRecordItem.getRecordInfoId(), modifyMap, this);
	}
	
	public void offlineHandle(String str){
		mRecordLogic.offlineHandle(str);
	}
	
	
	//=====================================UI需要用到的方法（End）========================================
	
    int index = 0;
    
	@Override
	public void doRecordItemBack(RecordItem recordItem) {
		if(mRecordItem !=null && recordItem == null){
			return;
		}
        index++;
		mRecordItem = recordItem;
		if(mRecordItem == null){
			mDTCallback.loadDataError(Constants.Msg.NET_ERROR);
		}else{
			initDataSuccess();
			mDTCallback.loadDataSuccess();
		}
	}
	
	@Override
	public void doBack(boolean isb) {
		mDTCallback.modifyStatus(isb);
	}
	
	
	
	/**获得数据成功*/
	public abstract void initDataSuccess();
	
	//---------------------------------------UI在用数据逻辑时需要实现的回调---------------------------------
	/**
	 * UI方面需要实现的接口，用于回调数据操作后UI上需要做的处理
	 * @author reason
	 *
	 */
	public interface RecordDTCallBack{
		
		/**
		 * 从服务器获得数据失败的回调
		 * @param code
		 * @param msg
		 */
		public void loadDataError(String msg);
		
		/**
		 * 从服务器获得数据成功的回调
		 * @param code
		 * @param msg
		 */
		public void loadDataSuccess();
		
		/**
		 * 访问服务器修改记录的回调
		 * @param isb 成功true 识别false
		 */
		public void modifyStatus(boolean isb);
	}
}
