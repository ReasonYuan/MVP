package com.fq.android.plus.recorditem.factory;

import android.content.Context;

import com.fq.android.plus.recorditem.view.IRecordItemView;
import com.fq.android.plus.recorditem.view.OtherRecordView;

public class OtherRecordViewFactory implements IRecordItemFactory{

	@Override
	public IRecordItemView createRecordItem(Context context) {
		return new OtherRecordView(context);
	}

}
