package com.fq.lib.record;

import com.fq.lib.tools.TimeFormatUtils;

public class RecordConstants {
	
	/**待云识别*/
	public static final int CLOUD_REC_WAIT = 0;
	/**云识别中*/
	public static final int CLOUD_REC_ING = 1;
	/**云识别完成*/
	public static final int CLOUD_REC_END = 2;
	/**云识别失败*/
	public static final int CLOUD_REC_FAIL = 3;
	
	private static final String[] CLOUDS_STATUS = {"待云识别","识别中","识别完成","识别失败"};
			
	public static String getRecSTRByType(int type){
		return CLOUDS_STATUS[type];
	}
	
	
	/**病案类别：住院、门诊病案*/
	public static final int PATIENT_CATEGORY_NORMAL = 1;
	
	/**病案类别：体检病案*/
	public static final int PATIENT_CATEGORY_MEDICAL = 3;
	
	
	/**
	 * 病历类型：门诊病历
	 */
	public static final int RECORD_TYPE_DOORCASE = 1;
	/**
	 * 病历类型：住院病历
	 */
	public static final int RECORD_TYPE_ADMISSION = 2;
	
	/**
	 * 病案来源：自己上传
	 */
	public static final int MEDICAL_FROM_OWN = 1;
	/**
	 * 病案来源：分享
	 */
	public static final int MEDICAL_FROM_SHARE = 2;
	/**
	 * 病历来源：自己上传
	 */
	public static final int RECORD_FROM_OWN = 1;
	/**
	 * 病历来源：分享
	 */
	public static final int RECORD_FROM_SHARE = 2;

	/**
	 * 分享病案
	 */
	public static final int SHARE_PATIENT = 1;
	/**
	 * 分享病历
	 */
	public static final int SHARE_RECORD = 2;
	/**
	 * 分享病历记录
	 */
	public static final int SHARE_RECORD_ITEM = 3;
	
	/**入院记录*/
	public static final int TYPE_ADMISSION = 1;
	/**化验*/
	public static final int TYPE_EXAMINATION = 2;
	/**手术*/
	public static final int TYPE_SUGERY= 3;
	/**检查*/
	public static final int TYPE_MEDICAL_IMAGING = 4;
	/**出院*/
	public static final int TYPE_DISCHARGE = 5;
	/**门诊*/
	public static final int TYPE_DOORCASE = 6;
	/**其他*/
	public static final int TYPE_OTHERS = 9;
	/**治疗方案*/
	public static final int TYPE_OUTPATIENTS = 10;
	/**检查-CT*/
	public static final int TYPE_CT = 11;
	/**检查-心电图*/
	public static final int TYPE_XINDIAN = 12;
	/**检查-超声*/
	public static final int TYPE_CHAOSHENG = 13;
	
	
	private static final String[] TYTE_NAME ={"","入院记录","化验记录","手术记录","检查记录","出院记录","门诊记录","","","其他记录","治疗方案","CT","心电图","超声"};
	
	private static final String[] TYTE_TITLE ={"","入院","化验","手术","检查","出院","门诊记录","","","其他","治疗方案","CT","心电图","超声"};
	
	/**根据Record type得到UI index*/
//	public static final int[] RCORDS_TYPE_INDEXING = new int[11];
	/**
	 * 根据UI的index对应数据库的types
	 */
	public static final int[] TYPES = { TYPE_ADMISSION, TYPE_EXAMINATION, TYPE_SUGERY, TYPE_MEDICAL_IMAGING, TYPE_DISCHARGE,
		TYPE_OUTPATIENTS,TYPE_OTHERS,TYPE_DOORCASE };
	
	private static final int[] ZHUYUAN_IDS = {TYPE_ADMISSION,TYPE_EXAMINATION,TYPE_MEDICAL_IMAGING,TYPE_OUTPATIENTS,TYPE_SUGERY,TYPE_DISCHARGE,TYPE_OTHERS};
	private static final int[] MENZEHN_IDS = {TYPE_DOORCASE,TYPE_EXAMINATION,TYPE_MEDICAL_IMAGING,TYPE_DISCHARGE,TYPE_OTHERS};
//	private static final int[] CHECK_ITEMS = {TYPE_CT,TYPE_XINDIAN,TYPE_CHAOSHENG};
	
	private static final String[] TYPE_ABSTRACT = {"","初步诊断","异常项","手术前诊断","项目","出院诊断","摘要信息","","","上传时间","查房时间"};
	
	//以下是UI索引值
//	/**入院记录*/
//	public static final int UI_INDEX_OF__ADMISSION = 0;
//	/**化验*/
//	public static final int UI_INDEX_OF__EXAMINATION = 1;
//	/**手术*/
//	public static final int UI_INDEX_OF__SUGERY= 2;
//	/**影像*/
//	public static final int UI_INDEX_OF__MEDICAL_IMAGING = 3;
//	/**出院*/
//	public static final int UI_INDEX_OF__DISCHARGE = 4;
//	/**治疗方案*/
//	public static final int UI_INDEX_OF__OUTPATIENTS = 5;
//	/**急诊*/
////	public static final int UI_INDEX_OF__EMERGENCY = 6;
//	/**其他*/
//	public static final int UI_INDEX_OF__OTHERS = 6;
//	/**门诊*/
//	public static final int UI_INDEX_OF__DOORCASE = 7;
	
	//public static final int[] UI_INDEXS ={UI_INDEX_OF__ADMISSION,UI_INDEX_OF__EXAMINATION,UI_INDEX_OF__SUGERY,UI_INDEX_OF__MEDICAL_IMAGING,UI_INDEX_OF__DISCHARGE,UI_INDEX_OF__OUTPATIENTS,UI_INDEX_OF__OTHERS};
	
	/*static {
		RCORDS_TYPE_INDEXING[TYPE_ADMISSION] = UI_INDEX_OF__ADMISSION;
		RCORDS_TYPE_INDEXING[TYPE_EXAMINATION] = UI_INDEX_OF__EXAMINATION;
		RCORDS_TYPE_INDEXING[TYPE_SUGERY] = UI_INDEX_OF__SUGERY;
		RCORDS_TYPE_INDEXING[TYPE_MEDICAL_IMAGING] = UI_INDEX_OF__MEDICAL_IMAGING;
		RCORDS_TYPE_INDEXING[TYPE_DISCHARGE] = UI_INDEX_OF__DISCHARGE;
		RCORDS_TYPE_INDEXING[TYPE_OUTPATIENTS] = UI_INDEX_OF__OUTPATIENTS;
//		RCORDS_TYPE_INDEXING[TYPE_EMERGENCY] = UI_INDEX_OF__EMERGENCY;
		RCORDS_TYPE_INDEXING[TYPE_OTHERS] = UI_INDEX_OF__OTHERS;
		RCORDS_TYPE_INDEXING[TYPE_DOORCASE] = UI_INDEX_OF__DOORCASE;//门诊
	}*/
	
	/**
	 * 获取病历类型的名称
	 * @return String 
	 *                  -- X\nX          
	 */
	/*public static String getRecordTypeName2(int typeId){
		String typeName = "";
		switch (typeId) {
		case 1:
			return "入\n院";
		case 2:
			return "化\n验";
		case 3:
			return "手\n术";
		case 4:
			return "检\n查";
		case 5:
			return "出\n院";
		case 9:
			return "其\n他";
		case 10:
			return "治\n疗";
		default:
			break;
		}
		return typeName;
	}*/
	
	public static String getTypeNameByRecordType(int recordType){
		return recordType > TYTE_NAME.length ? TYTE_NAME[9]:TYTE_NAME[recordType];
	}
	
	public static String getTypeTitleByRecordType(int recordType){
		return recordType > TYTE_TITLE.length ? TYTE_TITLE[9]:TYTE_TITLE[recordType];
	}
	
	public static int getRecordTypeByUIIndex(int uiType){
		return TYPES[uiType];
	}
	
	/*public static int getUIIndexByRecordType(int recordType){
		return RCORDS_TYPE_INDEXING[recordType];
	}*/
	
	public static int[] getTypesByRecordType(int type){
		switch (type) {
		case RECORD_TYPE_DOORCASE:
			return MENZEHN_IDS;
		case RECORD_TYPE_ADMISSION:	
		default:
			return ZHUYUAN_IDS;
		}
	}
	
//	public static int[] getCheckItemIds(){
//		return CHECK_ITEMS;
//	}
	
	public static String getAbstractByType(int type){
		return TYPE_ABSTRACT[type];
	}
	
	/**
	 * 得到创建病案自动生成的名称，在归档图片创建病案时使用<br/>
	 * 规则为：病案+yyyy-MM-dd
	 * @return
	 */
	public static String getCreatePatientName(){
		return ("病案-"+TimeFormatUtils.getStrDate(System.currentTimeMillis()));
	}
	
//	public static int getBigType(RecordItem item){
//		int type = item.getRecordType();
//
//		// CT、心电图、B超等都属于检查大项
//		if (type >= RecordConstants.TYPE_CT
//				&& type <= RecordConstants.TYPE_CHAOSHENG) {
//			type = RecordConstants.TYPE_MEDICAL_IMAGING;
//		}
//		return type;
//	}
	
//	public static int getBigType(RecordItemSamp samp){
//		int type = samp.getRecordType();
//
//		// CT、心电图、B超等都属于检查大项
//		if (type >= RecordConstants.TYPE_CT
//				&& type <= RecordConstants.TYPE_CHAOSHENG) {
//			type = RecordConstants.TYPE_MEDICAL_IMAGING;
//		}
//		return type;
//	}
}
