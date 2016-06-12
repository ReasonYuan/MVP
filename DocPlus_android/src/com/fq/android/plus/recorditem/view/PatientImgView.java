package com.fq.android.plus.recorditem.view;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.entity.RecordItem;
import com.hp.android.halcyon.widgets.PhotoView;

public class PatientImgView implements IRecordItemView{

	private View mView;
	private PhotoView mPhoto;
	
	public PatientImgView(Context context) {
		mView = LayoutInflater.from(context).inflate(R.layout.view_record_item_image, null);
	}
	
	@Override
	public View getRecordItemView() {
		return mView;
	}

	@Override
	public void setDatas(RecordItem recordItem) {
		mPhoto = (PhotoView) mView.findViewById(R.id.record_item_image);
		mPhoto.setScale(false);
		ArrayList<PhotoRecord> photos = recordItem.getPhotos();
		if (photos.size() > 0) {
			mPhoto.loadImageByPhoto(photos.get(0));
		}
	}

	@Override
	public boolean isEdit() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public void exitEdit() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void cancelEdit() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void saveEdit() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setEditState(boolean state) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnJoinEditListener(JoinEditStateCallBack editStateCallBack) {
		
	}

}
