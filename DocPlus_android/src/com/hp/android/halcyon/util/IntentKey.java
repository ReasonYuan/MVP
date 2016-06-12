package com.hp.android.halcyon.util;

public class IntentKey {

	public static final String SEARCH_KEY = "searchKey";
	/**
	 * 标记搜索病案界面的数据有变化
	 */
	public static final int SEARCH_PATIENT_HAVE_MODIFY = 111;
	/**
	 * 病历列表有变化时的result的返回值
	 */
	public static final int RECORD_LIST_HAS_MODIFY = 120;
	/**
	 * UserInfoActivity界面判断是否是朋友关系
	 */
	public static final String EXTRA_IS_FRIEND = "is_friend";
	/**
	 * UserInfoActivity用于接收user
	 */
	public static final String EXTRA_USER = "user";
	/**
	 * UserInfoActivity用于接收mRelationId
	 */
	public static final String EXTRA_RELATION_ID = "mRelationId";
	
	/**
	 *用于可视化数据传递时候的类型判断的key
	 */
	public static final String VISUALIZE_DATA_TYPE = "dataType" ;
	/**
	 *用于可视化数据传递时候的药品可视化
	 */
	public static String VISUALIZE_DRUGS = "drugs";
	/**
	 *用于可视化数据传递时候的化验项可视化
	 */
	public static String VISUALIZE_EXAMS = "exams";
	/**
	 *用于可视化数据传递时候的化验项或药品名的key
	 */
	public static String VISUALIZE_DATA_COLUMN = "data_column";

}
