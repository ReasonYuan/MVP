package com.fq.lib.record;

import java.util.ArrayList;

import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.uimodels.OneCopy;
import com.fq.halcyon.uimodels.OneType;
/**
 * 用于拍摄病历时病历图片的数据操作(增、删、查)
 * @author reason
 *
 */
public class SnapPhotoManager {

	private static SnapPhotoManager mInstance;

	/**拍摄病历图片的数据集 一个oneType表示一份*/
	private ArrayList<OneType> mTypes;
	
	private int[] TYPES;
	private OneCopy mCurrentCopy;
	/** 当前第几份病历记录*/
	private int mCurrentIndex;
	/** 拍照类型: 入院记录，出院记录等*/
	private int mUIIndex;
	
	private int mRecordId;
	
	private SnapPhotoManager(){}
	
	/**是否允许拍摄入院病历*/
	private boolean mIsAllowRu;
	/**是否允许拍摄出院病历*/
	private boolean mIsAllowChu;
	
	/**当前拍摄的图片*/
	private Object mTakePhoto;
	
	public Object getTakePhoto(){
		return mTakePhoto;
	}
	
	public void setTakePhoto(Object obj){
		mTakePhoto = obj;
	}
	
	
	/**
	 * 初始化拍摄病历数据
	 * @param recordId 病历的id
	 * @param docType 病历的类型：住院|门诊
	 * @param currType 当前拍摄病历记录的类型
	 * @return
	 */
	public static SnapPhotoManager instance(int recordId,int docType,int currType,boolean isRu,boolean isChu){
		if(mInstance == null){
			mInstance = new SnapPhotoManager();
			mInstance.mRecordId = recordId;
			mInstance.mIsAllowRu = isRu;
			mInstance.mIsAllowChu = isChu;
			mInstance.TYPES = RecordConstants.getTypesByRecordType(docType);
			for (int i = 0; i < mInstance.TYPES.length; i++) {
				int type = mInstance.TYPES[i];
				if(type == currType)mInstance.mUIIndex = i;
			}
			mInstance.mTypes = RecordCache.getInstance().getUnUploadTypes();
			if(mInstance.mTypes == null){
				mInstance.mTypes = new ArrayList<OneType>();
			}else{
				int count = mInstance.mTypes.size();
				mInstance.mCurrentIndex = count - 1;
				mInstance.mCurrentCopy = mInstance.mTypes.get(count - 1).getCopyById(0);
			}
		}
		return mInstance;
	}
	
	public void setCurrentIndex(int index){
		mCurrentIndex = index;
	}
	
	public static SnapPhotoManager getInstance(){
		return mInstance;
	}
	
	public int getRecordId(){
		return mRecordId;
	}
	
	/**
	 * 得到拍摄的所有病历类型
	 * @return ArrayList<OneType>
	 */
	public ArrayList<OneType> getTypes(){
		return mTypes;
	}
	
	/**
	 * 因为选择的图片可能会被用户用其他软件删除掉<br/>
	 * 所以上传前需要得到还存在的病历记录的图片
	 * @return
	 */
	public ArrayList<OneType> getRealyTypes(){
		for(int i = 0; i < mTypes.size(); i++){
			OneCopy copy = mTypes.get(i).getCopyById(0);
			ArrayList<PhotoRecord> photos = copy.getPhotos();
			for(int j = 0; j < photos.size(); j++){
				String path = photos.get(j).getLocalPath();
				if(path == null){
					photos.remove(j);
					j--;
					if(photos.size() == 0){
						mTypes.remove(i);
						i--;
						break;
					}
				}
			}
		}
		return mTypes;
	}
	
	
	/**
	 * 拍摄结束后清除数据
	 */
	public void clear(){
//		mTypes = null;
		mInstance = null;
		mCurrentCopy = null;
	}
	
//************************************************************
//************************mTypes的处理**************************	
//************************************************************
	/**
	 * 得到所拍摄病历图片的总图片数
	 * @return 病历图片数量
	 */
	public int getPhotoCount(){
		int cnt = 0;
		for (int i = 0; i < mTypes.size(); i++) {
			cnt += mTypes.get(i).getCopyById(0).getPhotos().size();
		}
		return cnt;
	}
	
	/**
	 * 拍摄的病历里面是否有所指类型类型
	 * @param recordType 指定的病历类型
	 * @return true：有所指定的类型， false:还没有指定的类型
	 */
	public boolean isHaveType(int recordType){
		for(int i = 0; i < mTypes.size(); i++){
			int type = mTypes.get(i).getType();
			if(type == recordType){
				return true;
			}
		}
		return false;
	}
	
	/**
	 * 获得所拍摄的病历份数
	 * @return int 拍摄的病历份数
	 */
	public int getTypeCount(){
		return mTypes.size();
	}
	
	/**
	 * 得到指定的第几份病历
	 * @param index 指定的第几分
	 * @return 如果存在返回指定的病历，如果不存在则返回null;
	 */
	public OneType getTypeByIndex(int index){
		try{
			return mTypes.get(index);
		}catch(Exception e){
			return null;
		}
	}
	
	/**
	 * 得到列表里面最后一份病历
	 * @return 如果没有则返回null
	 */
	public OneType getLastType(){
		try{
			return mTypes.get(mTypes.size()-1);
		}catch(Exception e){
			return null;
		}
	}
	
	/**
	 * 得到列表里面最后一张图片
	 * @return 如果没有则返回null
	 */
	public PhotoRecord getLastPhoto(){
		OneType type = getLastType();
		if(type == null)return null;
		try{
			ArrayList<PhotoRecord> photos = type.getCopyById(0).getPhotos();
			return photos.get(photos.size()-1);
		}catch(Exception e){
			return null;
		}
	}
	
	/**
	 * 添加病历数据到指定位置
	 * @param index 指定的位置
	 * @param type 所要添加的病历数据
	 */
	public void addType(int index,OneType type){
		mTypes.add(index, type);
	}
	
	/**
	 * 得到当前病历
	 * @return
	 */
	public OneType getCurrentType(){
		try{
			return mTypes.get(mCurrentIndex);
		}catch(Exception e){
			return null;
		}
	}
	
//************************************************************
//********************mCurrentCopy的处理************************	
//************************************************************

	/**
	 * 得到当前的病历序号
	 * @return
	 */
	public int getCurrentIndex(){
		return mCurrentIndex;
	}
	
	/**
	 * 得到当前的病历
	 * @return
	 */
	public OneCopy getCurrentCopy(){
		return mCurrentCopy;
	}
	
	/**
	 * 得到当前病历类型的名字
	 * @return
	 */
	public String getCurrenTypeName(){
		return RecordConstants.getTypeNameByRecordType(mTypes.get(mCurrentIndex).getType());
	}
	
	/**
	 * 得到当前病历记录里面的照片数
	 * @return
	 */
	public int getCurrentTypePhotoCount(){
		try{
			OneCopy copy = mTypes.get(mCurrentIndex).getCopyById(0);
			return copy.getPhotos().size();
		}catch(Exception e){
			return 0;
		}
	}
	
	/**
	 * 改变当前
	 * @param plus
	 */
	public void addCurrentIndex(int plus){
		mCurrentIndex += plus;
	}
	
	/**
	 * 是否允许拍摄图片<br/>
	 * 目前条件只有当化验单有一份记录时不允许再拍摄
	 * @return 如果允许拍摄返回true，否则返回false
	 */
	public boolean isAllowCatch(){
		if(mCurrentCopy != null 
				&& mCurrentCopy.getType() == RecordConstants.TYPE_EXAMINATION){
			if(mCurrentCopy.getPhotos().size() > 0){
				return false;
			}
		}
		return true;
	}
	
	/**
	 * 是否只允许拍摄一张照片<br/>
	 * 目前条件只有化验单
	 * @return 如有只允许拍一张返回true，否则返回false
	 */
	public boolean isSignlePhoto(){
		return TYPES[mUIIndex] == RecordConstants.TYPE_EXAMINATION;
	}
	
	/**
	 * 是否只有一份，入院和出院
	 * @return
	 */
	public boolean isSignelCopy(){
		return TYPES[mUIIndex] == RecordConstants.TYPE_ADMISSION ||  TYPES[mUIIndex] == RecordConstants.TYPE_DISCHARGE ;
	}
	
	/**
	 * 是否只允许拍摄一张照片<br/>
	 * 目前条件只有化验单
	 * @return 如有只允许拍一张返回true，否则返回false
	 */
	public boolean isSignlePhoto(int type){
		return type == RecordConstants.TYPE_EXAMINATION;
	}
	
	/**
	 * 选择之前拍的某一份
	 * @param index
	 */
	public void selectIndex(int index){
		if(index == -1)return;
		mCurrentIndex = index;
		OneType type = getTypeByIndex(index);
		if(type == null)return;
		try{
			mCurrentCopy = type.getCopyById(0);
//			return type.getCopyById(0);
		}catch(Exception e){
			mCurrentCopy = null;
		}
	}
	
	/**
	 * 上一份病历记录
	 */
	public void lastRecordItem(){
		mCurrentIndex--;
		mCurrentCopy = null;
//		initCurrentType();
	}
	
	/**
	 * 下一份病历记录
	 */
	public void nextRecordItem(){
		mCurrentIndex++;
		mCurrentCopy = null;
//		initCurrentType();
//		if(mCurrentIndex < getTypeCount()){
//			lastRecordType();
//			mTypeSelectView.setVisibility(View.GONE);
//			mTitleText.setText(mSnapManager.getCurrenTypeName());
//		}else{
//			mTypeSelectView.setVisibility(View.VISIBLE);
//		}
	}
	
	/**
	 * 是不是目前的最后一份记录
	 * @return 是然会true，否则返回false
	 */
	public boolean canNextRecordItem(){
		OneType type = getLastType();
		if(type == null)return false;
		return (type.getCopyById(0).getPhotos().size() > 0);
	}
	
	/**
	 * 主要用于下一份时，如果之前是入院或出院<br/>
	 * 则需要更改类型
	 * @return
	 */
	public boolean isChangeType(){
		int willtype = TYPES[mUIIndex];
		//入院或出院时，如果已经含有该类型就跳过
		if(willtype == RecordConstants.TYPE_ADMISSION){
			if(mIsAllowRu ||isHaveType(willtype)){
				mUIIndex++;
				if(mUIIndex >= TYPES.length)mUIIndex = 0;
				return true;
			}
		}else if(willtype == RecordConstants.TYPE_DISCHARGE){
			if(mIsAllowChu ||isHaveType(willtype)){
				mUIIndex++;
				if(mUIIndex >= TYPES.length)mUIIndex = 0;
				return true;
			}
		}
		/*if(willtype == RecordConstants.TYPE_ADMISSION || willtype == RecordConstants.TYPE_DISCHARGE){
			if(isHaveType(willtype)){
				mUIIndex++;
				if(mUIIndex >= TYPES.length)mUIIndex = 0;
				return true;
			}
		}*/
		return false;
	}
	
	/**
	 * 为病历记录选择（上一个）病历类型
	 */
	public void lastRecordType(){
		mUIIndex--;
		if(mUIIndex < 0)mUIIndex = TYPES.length-1;
		int willtype = TYPES[mUIIndex];
		
		//入院或出院时，如果已经含有该类型就跳过
		if(willtype == RecordConstants.TYPE_ADMISSION){
			if(mIsAllowRu ||isHaveType(willtype)){
				mUIIndex--;
				if(mUIIndex < 0)mUIIndex = TYPES.length-1;
			}
		}else if(willtype == RecordConstants.TYPE_DISCHARGE){
			if(mIsAllowChu ||isHaveType(willtype)){
				mUIIndex--;
				if(mUIIndex < 0)mUIIndex = TYPES.length-1;
			}
		}
		/*if(willtype == RecordConstants.TYPE_ADMISSION || willtype == RecordConstants.TYPE_DISCHARGE){
			if(isHaveType(willtype)){
				mUIIndex--;
				if(mUIIndex < 0)mUIIndex = TYPES.length-1;
			}
		}*/
	}
	
	/**
	 * 为病历记录选择（下一个）病历类型
	 */
	public void nextRecordType(){
		mUIIndex++;
		if(mUIIndex >= TYPES.length)mUIIndex = 0;
		int willtype = TYPES[mUIIndex];
		
		//入院或出院时，如果已经含有该类型就跳过
		if(willtype == RecordConstants.TYPE_ADMISSION){
			if(mIsAllowRu ||isHaveType(willtype)){
				mUIIndex++;
				if(mUIIndex >= TYPES.length)mUIIndex = 0;
			}
		}else if(willtype == RecordConstants.TYPE_DISCHARGE){
			if(mIsAllowChu ||isHaveType(willtype)){
				mUIIndex++;
				if(mUIIndex >= TYPES.length)mUIIndex = 0;
			}
		}
		/*if(willtype == RecordConstants.TYPE_ADMISSION || willtype == RecordConstants.TYPE_DISCHARGE){
			if(isHaveType(willtype)){
				mUIIndex++;
				if(mUIIndex >= TYPES.length)mUIIndex = 0;
			}
		}*/
	}
	
	/**
	 * 得到选择的病历类型的名字
	 * @return
	 */
	public String getSelectTypeName(){
		return RecordConstants.getTypeNameByRecordType(TYPES[mUIIndex]);
	}
	
	
	/**
	 * 初始化当前病历记录
	 * @return 是否新建的一个病历记录
	 */
	public void initCurrentType(){
		if(mCurrentCopy != null)return;
		
		OneType type = getCurrentType();
		if(type == null){
			type = new OneType(TYPES[mUIIndex]);
			addType(mCurrentIndex, type);
			mCurrentCopy = new OneCopy(TYPES[mUIIndex]);
			type.AddOneCopy(mCurrentCopy);
		}else{
			mCurrentCopy = type.getCopyById(0);
		}
	}
	
	public void currentCopyAddPhoto(String path){
		PhotoRecord photo = new PhotoRecord(path);
		photo.setRecordType(mCurrentCopy.getType());
		mCurrentCopy.photos.add(photo);
	}
	
	public void reSetData(){
		mCurrentCopy = null;
		mCurrentIndex = mTypes.size();
		if(mCurrentIndex > 0){
			mCurrentIndex--;
			mCurrentCopy = getLastType().getCopyById(0);
		}else{
			mCurrentCopy = null;
		}
	}
	
	/**
	 * 将份数定位到指定记录类型出现的第一个
	 * @param type 指定的记录类型
	 */
	public void setToTypeInFirst(int type){
		for(int i = 0; i < mTypes.size(); i++){
			if(mTypes.get(i).getType() == type){
				mCurrentIndex = i;
				mCurrentCopy = mTypes.get(i).getCopyById(0);
			}
		}
	}
	
	public ArrayList<PhotoRecord> getAllPhotos(){
		ArrayList<PhotoRecord> mPhotos = new ArrayList<PhotoRecord>();
		for(int i = 0; i < mTypes.size(); i++){
			mPhotos.addAll(mTypes.get(i).getCopyById(0).getPhotos());
		}
		return mPhotos;
	}
	
	public String getLastPhotoPath(){
		ArrayList<PhotoRecord> mPhotos = this.getAllPhotos();
		if (!mPhotos.isEmpty()) {
			return mPhotos.get(mPhotos.size() -1).getLocalPath();
		}
		return null;
	}
	
	public void remove(PhotoRecord photo){
		if(photo != null){
			for(int i = 0; i < mTypes.size(); i++){
				OneType type = mTypes.get(i);
				OneCopy copy = type.getCopyById(0);
				if(copy.getPhotos().contains(photo)){
					copy.getPhotos().remove(photo);
					return;
				}
			}
		}
	}
	
}
