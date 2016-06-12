package com.fq.android.plus.recorditem.factory;

import android.content.Context;

import com.fq.android.plus.recorditem.view.IRecordItemView;
import com.fq.android.plus.recorditem.view.OtherExaminationView;
import com.fq.halcyon.entity.RecordItem;
import com.fq.lib.record.RecordConstants;

public class SampleFactory {

	private SampleFactory() {
		
	}
	
	public static IRecordItemView getInstance(Context context,RecordItem item){
		IRecordItemFactory factory = null;
		IRecordItemView recordItem = null;
		switch (item.getRecordType()) {
		case RecordConstants.TYPE_EXAMINATION:
			if(item.getExams() != null && item.getExams().size() != 0){//标准化验单
				factory = new ExaminationViewFactory();
			}else if(item.getOtherExams() != null && item.getOtherExams().size() != 0){
				//非标准化验单
				return new OtherExaminationView(context);
			}
			break;
		case RecordConstants.TYPE_MEDICAL_IMAGING:
		case RecordConstants.TYPE_CT:
		case RecordConstants.TYPE_XINDIAN:
		case RecordConstants.TYPE_CHAOSHENG:
			factory = new PatientImageViewFactory();
			break;
		default:
			factory = new OtherRecordViewFactory();
			break;
		}
		if(factory == null){
			factory = new OtherRecordViewFactory();
		}
		recordItem = factory.createRecordItem(context);
		return recordItem;
	}
}