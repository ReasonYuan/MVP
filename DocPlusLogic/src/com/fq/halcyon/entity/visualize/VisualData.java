package com.fq.halcyon.entity.visualize;

import java.util.ArrayList;

import com.fq.lib.tools.UriConstants;

/**
 * 可视化数据，药物分析参数
 * @author reason
 *
 */
public class VisualData extends VisualizeEntity{

	private static final long serialVersionUID = 1L;

	
	/**该类型的参数*/
	private String dataColumn;
	
	/**所选中的病历*/
	private ArrayList<Integer> recordIds;
	
	public VisualData(VISUALTYPE tp){
		type = tp;
	}
	
	/**设置需要可视化的数据*/
	public void setDataColumn(String data){
		dataColumn = data;
	}
	
	/**
	 * 赋值选中的病历id
	 */
	public void setRecordIds(ArrayList<Integer> ids){
		recordIds = ids;
	}
	
	
	@Override
	public String getURL() {
		return UriConstants.getVasualDataURL()+"?"+getPraUserId()+"&"+getPraDataType()+"&"+getPraDataColumn()+"&"+getPraRecordIds();
	}

	/**可视化数据的类型参数*/
	public String getPraDataType(){
		if(type == VISUALTYPE.DRUGS){
			return "dataType='drugs'";
		}
		return "dataType='exams'";
	}
	
	/**可视化数据的数据参数*/
	public String getPraDataColumn(){
		return "dataColumn='"+dataColumn+"'";
	}
	
	/**可视化数据的选中的病历参数参数*/
	public String getPraRecordIds(){
		if(recordIds == null || recordIds.size() == 0)return "";
		StringBuffer buf = new StringBuffer("recordIds='");
		for(int i = 0; i < recordIds.size(); i++){
			if(i != 0)buf.append(";");
			buf.append(recordIds.get(i)+"");
		}
		buf.append("'");
		return buf.toString();
	}
}
