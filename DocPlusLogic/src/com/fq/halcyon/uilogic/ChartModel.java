package com.fq.halcyon.uilogic;

import java.util.ArrayList;

import com.fq.halcyon.entity.RecordExams;
import com.fq.halcyon.entity.RecordExams.ExamDate;

/**
 * 明细数据模型 
 */
public class ChartModel {
	
	//为了不至于每次都最顶和最低有显示，照成不好看，所以扩充下显示范围
	private static final float TOTAL_DISPLAY_EXTENDS =  1.25f; //必须>1
	
	private float displayViewHeight;
	
	private float screenHeight;
	
	private final float DISPLAY_PADDING_RATIO = 0.1f;
	
	/**
	 * 缩放比例
	 */
	private float scale = 1;
	
	/**
	 * 纵坐标默认被划分为n个等分， 化验明细按比例落在纵轴上
	 */
	private String[] yDisplayLabels = new String[20];
	
	/**
	 * 每一格y的跳跃高度
	 */
	private float yStepHeight = 0;
	
	/**
	 * 每一格x的跳跃宽度
	 */
	private final float xStepWidth = 100;
	
	/**
	 * x轴是可变的，根据化验份数而定
	 */
	private float[] xPositions;
	
	/**
	 * 明细数据
	 */
	private RecordExams examData;
	
	private float refType = REF_TYPE_RANGE;
	
	/**
	 * 化验数据里最小的数据
	 */
	private float lowestValue = 0;
	
	/**
	 * 化验数据里最大的数据
	 */
	private float highestValue = 0;
	
	/**
	 * 参考值是一个取值范围
	 */
	public static final int REF_TYPE_RANGE = 1; 
	
	private boolean isDisplayInfoInited = false;
	
	public ChartModel(RecordExams exams){
		this.examData = exams;
	}
	
	public boolean isDisplayInfoInited(){
		return isDisplayInfoInited;
	}
	
	/**
	 * 初始化显示数据
	 * @param screenHeight
	 */
	public void initDisplayInfo(float screenHeight){
		this.displayViewHeight = screenHeight*(1-DISPLAY_PADDING_RATIO*2);
		this.screenHeight = screenHeight;
		isDisplayInfoInited = true;
		
		//计算最大/小数据
		for (int i = 0; i < examData.getEXamDates().size(); i++) {
			if(i == 0){
				lowestValue = toFloat(examData.getEXamDates().get(i).getValue());
				highestValue = toFloat(examData.getEXamDates().get(i).getValue());
			} else {
				lowestValue = Math.min(lowestValue, toFloat(examData.getEXamDates().get(i).getValue()));
				highestValue = Math.max(highestValue, toFloat(examData.getEXamDates().get(i).getValue()));
			}
		}
		//只有一条记录， lowestValue和highestValue必定相等，则图形非常难看，必须处理
		if (examData.getEXamDates().size() == 1 || lowestValue == highestValue) {
			float nowValue = lowestValue;
			lowestValue = nowValue*0.8f;
			highestValue = nowValue*1.2f;
		}
		float displayRange = highestValue - lowestValue;
		//为了显示好看，实际数据只落在y轴80%范围内
		float yTotalHight = displayRange * TOTAL_DISPLAY_EXTENDS;//5/4
		//计算出每个y轴格子的坐标, x轴(y=0)不算在内
		for (int i = 1; i <= yDisplayLabels.length; i++) {
			yDisplayLabels[i-1] = String.format("%.2f", yTotalHight*i/yDisplayLabels.length + (lowestValue - displayRange*(TOTAL_DISPLAY_EXTENDS - 1)/2));
		}
		//x轴
		xPositions = new float[examData.getEXamDates().size()];
		for (int i = 0; i < xPositions.length; i++) {
			xPositions[i] = (i+1)*xStepWidth;
		}
		yStepHeight = displayViewHeight/yDisplayLabels.length;
	}
	
	private float toFloat(String str){
		return Float.parseFloat(str);
	}
	
	/**
	 * 对应化验值到坐标系
	 * @param value
	 * @return
	 */
	public float getYByValue(float value){
		float displayRange = highestValue - lowestValue;
		//为了显示好看，实际数据只落在y轴80%范围内
		float yTotalHight = displayRange * TOTAL_DISPLAY_EXTENDS;//5/4
		float vr = value - lowestValue;
		return ((yTotalHight - displayRange)/2 + vr) / yTotalHight * (yStepHeight * yDisplayLabels.length);
	}
	
	/**
	 * y的格子跳跃高度
	 * @return
	 */
	public float getYStepHeight(){
		return yStepHeight;
	}
	
	/**
	 * x的格子跳跃宽度
	 * @return
	 */
	public float getXStepWidth(){
		return xStepWidth;
	}
	
	/**
	 * y轴格子数目
	 * @return
	 */
	public int getYCellsNum(){
		return yDisplayLabels.length;
	}
	
	/**
	 * 原点位置
	 * @return
	 */
	public float getStartX(){
		return 60;
	}
	
	/**
	 * 原点位置
	 * @return
	 */
	public float getStartY(){
		return (screenHeight - displayViewHeight)/2;
	}
	
	/**
	 * 坐标y最高画多高
	 * @return
	 */
	public float getChartMaxY(){
		return displayViewHeight*1.1f;
	}
	
	/**
	 * 坐标x轴最长画多长
	 * @return
	 */
	public float getChartWidth(){
		return xStepWidth * examData.getEXamDates().size();
	}
	
	/**
	 * y轴显示label
	 * @param stepIndex
	 * @return
	 */
	public String getYLabel(int stepIndex){
		return yDisplayLabels[stepIndex];
	}
	
	/**
	 * 化验明细
	 * @return
	 */
	public ArrayList<ExamDate> getExamData(){
		return examData.getEXamDates();
	}
	
}