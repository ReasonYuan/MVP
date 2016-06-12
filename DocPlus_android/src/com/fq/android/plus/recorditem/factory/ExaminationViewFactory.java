package com.fq.android.plus.recorditem.factory;

import android.content.Context;

import com.fq.android.plus.recorditem.view.ExaminationView;
import com.fq.android.plus.recorditem.view.IRecordItemView;

public class ExaminationViewFactory implements IRecordItemFactory{
	
	@Override
	public IRecordItemView createRecordItem(Context mContext) {
		return new ExaminationView(mContext);
	}

}
