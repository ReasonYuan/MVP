package com.fq.halcyon.uilogic;

import java.util.ArrayList;

import com.fq.halcyon.entity.CertificationStatus;
import com.fq.halcyon.entity.CertificationStatus.AuthImage;
import com.fq.halcyon.logic.DoctorAuthLogic;
import com.fq.halcyon.logic.DoctorAuthLogic.OnRequestAuthCallback;

public class UIAuthLogic {

	
	private boolean[] mBmps = new boolean[3];
	private ArrayList<Integer> mTypes = new ArrayList<Integer>();

	private CertificationStatus mAuthStatus = CertificationStatus.getInstance();
	private DoctorAuthLogic certificateLogic = new DoctorAuthLogic();
	
	public void initTypes(int type){
		if(mAuthStatus.getImgs() == null){
			if(!mTypes.contains(type))mTypes.add(type);
		}else{
			AuthImage img = mAuthStatus.getAuthImageByType(type);
			if(img != null)mTypes.add(type);
		}
	}
	
	public void setBmpReady(int type,boolean isb){
		mBmps[type-1] = isb;
	}
	
	public void addIfTypeNotExits(int type){
		if(!mTypes.contains(type))mTypes.add(type);
	}
	
	public boolean isAllImgReady(){
		return mBmps[0];//&&mBmps[1]&&mBmps[2];
	}
	
	public void applyAuth(OnRequestAuthCallback callback){
		certificateLogic.applyAuth(mTypes,callback);
	}

	public ArrayList<Integer> getTypes() {
		return mTypes;
	}
	
	public void dataClear(){
		mTypes.clear();
	}
	
	public int bmpCount(){
		return mTypes.size();
	}
}
