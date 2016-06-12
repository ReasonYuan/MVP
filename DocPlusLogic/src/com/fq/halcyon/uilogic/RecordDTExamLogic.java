package com.fq.halcyon.uilogic;

import java.util.ArrayList;

import com.fq.halcyon.entity.RecordItem.EXAM_STATE;
import com.fq.halcyon.entity.RecordItem.RecordExamItem;


/**
 * 化验单记录的数据逻辑，主要用于对数据的各种操作，<br/>
 * 方便UI上直接使用。
 * @author reason
 *
 */
public class RecordDTExamLogic extends RecordDTLogic{
	
	/**标准化验单的数据*/
	private ArrayList<RecordExamItem> mExams;
	
	/**非标准化验单的数据*/
	private ArrayList<ArrayList<String>> mOtherExams;
	
	/**
	 * 初始化
	 * @param RecordExamDTCallBack 对数据做操作后的UI回调
	 */
	public RecordDTExamLogic(RecordDTCallBack callback) {
		super(callback);
	}
	
	//=====================================UI需要用到的方法（Start）========================================
	
	/**
	 * 该份化验单是否为非标准化验单
	 * @return boolean, true 表示是 非标准化验单，false 表示为标准化验单
	 */
	public boolean isOtherExam(){
		return mRecordItem.isOtherExam();
	}
	
	/**得到标准化验单项目的总条数*/
	public int getExamCount(){
		return mExams.size();
	}
	
	/**
	 * 得到化验单的某一条化验记录
	 * @param index 需要某项的序号
	 * @return RecordExamItem 一条化验数据
	 */
	public RecordExamItem getExamByIndex(int index){
		return mExams.get(index);
	}
	
	
	/**
	 * 得到标准化验的某一项的名字
	 * @param index 需要某项的序号
	 * @return
	 */
	public String getExamNameByIndex(int index){
		return mExams.get(index).getName();
	}
	
	/**
	 * 得到标准化验的某一项的值
	 * @param index 需要某项的序号
	 * @return
	 */
	public String getExamValueByIndex(int index){
		return mExams.get(index).getExamValus();
	}
	
	/**
	 * 得到标准化验的某一项的单位
	 * @param index 需要某项的序号
	 * @return
	 */
	public String getExamUnitByIndex(int index){
		return mExams.get(index).getUnit();
	}
	
	
	/**
	 * 该化验项的结果的状态
	 * @param index
	 * @return
	 */
	public EXAM_STATE getExamStateByIndex(int index){
		return mExams.get(index).getState();
	}
	
	/**
	 * 获得非标准化验单的化验项的总条数，除去了head
	 * @return
	 */
	public int getOtherExamCount(){
		return mOtherExams.size();
	}
	
	/**
	 * 获得非标准化验记录的列数
	 * @return
	 */
	public int getOtherExamCloum(){
		try{
			return mOtherExams.get(0).size();
		}catch(Exception e){
			return 0;
		}
	}
	
	/**
	 * 获得非标准化验单需要显示的Head
	 * @return
	 */
	public ArrayList<String> getOtherExamHead(){
		return mOtherExams.get(0);
	}
	
	/**
	 * 获得非标准化验单某一条的记录信息
	 * @return
	 */
	public ArrayList<String> getOtherExamOneItem(int index){
		return mOtherExams.get(index);
	}

	
	//=====================================UI需要用到的方法（End）========================================

	@Override
	public void initDataSuccess() {
		mExams = mRecordItem.getExams();
		mOtherExams = mRecordItem.getOtherExams();
	}
	
}
