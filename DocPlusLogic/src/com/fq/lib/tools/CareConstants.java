package com.fq.lib.tools;

import java.util.ArrayList;

/**
 * Care版所需要用到的常量
 * @author reason
 */
public class CareConstants {

	/**用户的家庭关系*/
	private static final String[] RELATION = {"","本人","父亲","母亲","公公","婆婆","女儿","儿子","配偶","孙子","孙女"};
	

	/**
	 * 得到用户家庭关系列表
	 */
	public static String[] getRelations(){
		return RELATION;
	}
	
	/**
	 * 通过类型得到家庭关系
	 * @param type
	 * @return
	 */
	public static String getRelationByType(int type){
		return RELATION[type];
	}
	
	/**
	 * 获取关系ID
	 * @param relation
	 * @return
	 */
	public static int getRelationId(String relation){
		
		for (int i = 0; i < RELATION.length; i++) {
			if(RELATION[i].equals(relation)){
				return i;
			}
		}
		
		return 0;
	}
	
	/**
	 * 获取关系的arraylist
	 * @return
	 */
	public static ArrayList<String> getRelationArray(){
		ArrayList<String> array = new ArrayList<String>();
		for (int i = 0; i < RELATION.length; i++) {
			if(!"".equals(RELATION[i])){
				array.add(RELATION[i]);
			}
		}
		return array;
	}
}
