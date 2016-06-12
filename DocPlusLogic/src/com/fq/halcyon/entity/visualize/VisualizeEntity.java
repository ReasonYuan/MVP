package com.fq.halcyon.entity.visualize;

import java.io.Serializable;

import com.fq.lib.tools.Constants;

/**
 * 可视化数据，参数的实体类，将参数分装成一个类
 * @author reason
 * @version 2015-04-28 v3.0.3
 */
public abstract class VisualizeEntity implements Serializable{
	
	private static final long serialVersionUID = 1L;

	/**科室话数据类型*/
	public enum VISUALTYPE{
		MAP,DRUGS,EXAMS
	}
	
	/**可视化的类型*/
	public VISUALTYPE type;
	
	/**
	 *得到访问的URL(包括请求参数) 
	 */
	public abstract String getURL();
	
	/**
	 * 组装得到用户UserId的参数
	 * @return
	 */
	public String getPraUserId(){
		return "userId="+Constants.getUser().getUserId();
	}
}
