 package com.fq.halcyon.entity;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.DES3Utils;
import com.fq.lib.platform.Platform;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.TimeFormatUtils;

/**
 * 一个病历记录（详细信息，区别于病历记录简要）
 * @author reason
 *
 */
public class RecordItem extends HalcyonEntity{

	
	private static final String[] MEDICAL_TITLES = {"项目","结果","参考值","单位"};
	
	/**
	 * 化验数据的状态 M(正常)、L(低)、H(高)
	 * @author reason
	 */
	public enum EXAM_STATE{
		M,L,H
	}
	
	/**
	 * 非化验单中一条信息的类型，分为：基本信息，加密（身份化）的基本信息，详细信息，加密（身份化）的详细信息
	 * @author reason
	 *
	 */
	public static final String DETAILTYPE_BASE = "basic_info";
	public static final String DETAILTYPE_BASE_IDN = "basic_identity_info";
	public static final String DETAILTYPE_NOTE = "note_info";
	public static final String DETAILTYPE_NOTE_IDN = "note_identity_info";		
	
	private static final long serialVersionUID = 1L;

	/**记录的类型，目前分为一般(1)和体检(3)*/
	private int recordCategory;
	/**病历记录类型*/
	private int mType;
	/**病历记录识别状态*/
	private int mState;
	/**病历记录信息Id*/
	private int recordInfoId;
	/**病历记录信息对应图片的记录Id*/
	private int recordItemId;
	/**病历记录是否为别人分享*/
	private boolean mIsShared;
	
	/**记录所属病案的id*/
	private int patientId;
	
//	/**病历记录基本信息*/
//	private JSONArray mBaseInfo;
	
	/**体检需要用到：图表的内容或综合诊断*/
	private String mNotoInfos;
	/**体检需要用到：图表的文字档案*/
	private String mOhterInfos;
	/**体检需要用到：图表的内容*/
	private String mExamInfos;
	
	/**记录详情信息的列表*/
	private ArrayList<DetailItem> mDetailInfos;
	
	/**病历记录化验数据*/
	private ArrayList<RecordExamItem> mExams;
	/**非标准的化验数据，当标准化验数据没有时显示*/
	private ArrayList<ArrayList<String>> mOtherExams;
//	private HashMap<Integer, ArrayList<TemplateItem>> mTemplates;
//	/**病历记录锚点数据*/
//	private ArrayList<TemplateItem> mTemplates;
	
	/**病历记录原图片*/
	private ArrayList<PhotoRecord> mPhotos = new ArrayList<PhotoRecord>();
	
	/**记录的附件*/
	private HashMap<String, ArrayList<PhotoRecord>> mAttachmentImageId = new HashMap<String, ArrayList<PhotoRecord>>();
	
	/**是不是分享模式。因为用户可以查看这份病历分享给别人时分享的记录详细情况*/
	private boolean mIsShareModel;
	
	/**这条记录的通知消息*/
	private String noticeMessage;
	
	/**记录title*/
	private String recordTitle;
	

	
	public void setRecordTitle(String recordTitle) {
		this.recordTitle = recordTitle;
	}

	/**记录识别完成的时间*/
	private String recogTime;
	
	private ArrayList<Integer> mImgIds;
	
	/**记录所属医院ID*/
	private int hospitalID;
	
	
	public int getHospitalID() {
		return hospitalID;
	}

	public void setHospitalID(int hospitalID) {
		this.hospitalID = hospitalID;
	}

	/**为了方便修改，所以分开保存*/
	private HashMap<String, ArrayList<DetailItem>> mInfoMaps;
	
	public HashMap<String, ArrayList<DetailItem>> getInfoMap(){
		return mInfoMaps;
	}
	
	public ArrayList<Integer> getImageIds(){
		if(mImgIds == null){
			mImgIds = new ArrayList<Integer>();
			if(mPhotos == null)return mImgIds;
			for(int i = 0; i < mPhotos.size(); i++){
				mImgIds.add(mPhotos.get(i).getImageId());
			}
		}
		return mImgIds;
	}
	
	/**设置用户是否查看该记录在分享模式下的详细信息*/
	public void setShareModel(boolean isb){
		mIsShareModel = isb;
	}
	
	/**是否是查看分享模式*/
	public boolean isShareModel(){
		return mIsShareModel;
	}
	
	public int getRecordType() {
		return mType;
	}
	public void setRecordType(int type) {
		this.mType = type;
	}
	public JSONArray getNoteInfo() {
//		return mNotoInfo;
		return null;
	}
	public void setNoteInfo(JSONArray noteInfo) {
//		this.mNotoInfo = noteInfo;
	}
	public ArrayList<PhotoRecord> getPhotos() {
//		if(mType != RecordConstants.TYPE_MEDICAL_IMAGING && (mIsShared || mIsShareModel)){
//			PhotoRecord photo = new PhotoRecord(-1, "");
//			photo.setIsShared(true);
//			ArrayList<PhotoRecord> ps = new ArrayList<PhotoRecord>();
//			ps.add(photo);
//			return ps;
//		}
		return mPhotos;
	}
	public void setPhotos(ArrayList<PhotoRecord> photos) {
		this.mPhotos = photos;
	}
	public void setExams(ArrayList<RecordExamItem> exams){
		mExams = exams;
	}
	public ArrayList<RecordExamItem> getExams(){
		return mExams;
	}
	public ArrayList<ArrayList<String>> getOtherExams(){
		return mOtherExams;
	}
	public void setBaseInfo(JSONArray json){
//		mBaseInfo = json;
	}
	public JSONArray getBaseInfo() {
//		return mBaseInfo;
		return null;
	}
	public int getState(){
		return mState;
	}
	public int getRecordItemId(){
		return this.recordItemId;
	}
	public int getRecordInfoId(){
		return this.recordInfoId;
	}
	public int getPatientId(){
		return this.patientId;
	}
	
	public ArrayList<TemplateItem> getTemplates(){
//		return mTemplates;
		return null;
	}
	
	/**病历记录是否是别人分享过来的或者自己查看的分享模式*/
	public boolean isShared(){
		return mIsShared;
	}
	/**设置病历记录是否为别人分享的或者自己查看的分享模式*/
	public void setShared(boolean isShared){
		mIsShared = isShared;
	}
	
	/**得到记录的通知消息*/
	public String getNoticeMessage(){
		return noticeMessage;
	}
	
	/**得到记录的识别完成时间*/
	public String getRecogTime(){
		if(recogTime == null || "".equals(recogTime))return "";
		return TimeFormatUtils.changeDealTime(recogTime);
//		return recogTime;
	}
	
	/**获得病案类型，住院还是天津*/
	public int getRecordCategory(){
		return recordCategory;
	}
	
	/**
	 * 获取解析格式化后的记录详细信息
	 * @return
	 */
	public ArrayList<DetailItem> getDetails(){
		return mDetailInfos;
	}
	
	
	
	/**得到记录的标题*/
	public String getRecordTitle(){
		return recordTitle;
	}
	
	/**
	 * 判断这份（化验）记录是否为非标准化验单
	 * @return
	 */
	public boolean isOtherExam(){
		if(mType != RecordConstants.TYPE_EXAMINATION)return false;
		if(mExams != null && mExams.size() != 0){//标准化验单
			return false;
		}else if(mOtherExams != null){
			//非标准化验单
			return true;
		}
		return false;
	}
	
	public String getNoteStr(){
		return mNotoInfos;
	}
	
	public String getOtherStr(){
		return mOhterInfos;
	}
	
	public String getExamStr(){
		return mExamInfos;
	}
	
	/**
	 * 得到记录图片附件的ids的map 
	 * @return
	 */
	public HashMap<String, ArrayList<PhotoRecord>> getAttachImgIdsMap(){
		return mAttachmentImageId;
	}
	
	public void setAttachImgIdsMap(HashMap<String, ArrayList<PhotoRecord>> map){
		mAttachmentImageId = map;
	}
	
	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		//FQSecuritySession.get3DesKeyBytes
		try {
			noticeMessage = json.optString("notice_message");
			noticeMessage = checkNull(noticeMessage);
			
			recordTitle = json.optString("recordTitle");
			recordTitle = checkNull(recordTitle);
			
			recogTime = json.optString("recog_time");
			recogTime = checkNull(recogTime);
			
			recordCategory = json.optInt("record_category", RecordConstants.PATIENT_CATEGORY_NORMAL);
			mType = json.optInt("record_type");
			mState = json.optInt("status");
			recordInfoId = json.optInt("record_info_id");
			recordItemId = json.optInt("record_item_id");
			patientId = json.optInt("patient_id");
			
			//病历本来为分享或者
			mIsShared = json.optBoolean("is_shared");
			
			hospitalID = json.optInt("hospital_id");

			//分为一般项的和体检项的
			//记录分为化验单记录和非化验单记录
			//目前只有非化验单记录才有基本信息，而化验单记录没有
			
			if(recordCategory == RecordConstants.PATIENT_CATEGORY_MEDICAL){//体检类型
				parseMedicalInfo(json);
			}else{
				if(mType != RecordConstants.TYPE_EXAMINATION){	
					mDetailInfos = new ArrayList<RecordItem.DetailItem>();
					mInfoMaps = new HashMap<String, ArrayList<DetailItem>>();
					mInfoMaps.put(DETAILTYPE_BASE, new ArrayList<DetailItem>());
					mInfoMaps.put(DETAILTYPE_BASE_IDN, new ArrayList<DetailItem>());
					mInfoMaps.put(DETAILTYPE_NOTE, new ArrayList<DetailItem>());
					mInfoMaps.put(DETAILTYPE_NOTE_IDN, new ArrayList<DetailItem>());
					
					parseBaseInfo(json);
					parseNoteInfo(json);
					
					Collections.sort(mDetailInfos);//通过index，对数据进行排序
				}else{
					parseExamRecord(json);
				}
			}
			
//			//基本信息
//			ArrayList<Info> basinfos = new ArrayList<Info>();
//			try {
//				JSONArray ary = new JSONArray(baseInfo);
//				for(int i = 0; i < ary.length(); i++){
//					Info info = new Info();
//					info.setAttributeByjson(ary.getJSONObject(i));
//					basinfos.add(info);
//				}
//			} catch (Exception e) {
//			}
//			
//			//解密基本的关键信息,用户自己查看分享模式下时不需要显示关键信息出来
//			if(!mIsShareModel){
//				String base = json.optString("basic_identity_info");
//				if(base != null && !"".equals(base) && Platform.getInstance() != null){
//					String basic = DES3Utils.decryptMode(base.getBytes(), Platform.getInstance().getRecord3DesKey());
//					try {
//						JSONArray infos = new JSONArray(basic);
//						for(int i = 0; i < infos.length(); i++){
//							Info info = new Info();
//							info.setAttributeByjson(infos.getJSONObject(i));
//							basinfos.add(info);
//						}
//					} catch (Exception e) {
//						e.printStackTrace();
//					}
//				}
//			}
//			//基本信息排序
//			Collections.sort(basinfos);
//			mBaseInfo = new JSONArray();
//			for(int i = 0; i < basinfos.size(); i++){
//				mBaseInfo.put(i, basinfos.get(i).json);
//			}
//			
//			
//			//详细信息
//			ArrayList<Info> noteifos = new ArrayList<Info>();
//			try {
//				JSONArray ary = new JSONArray(noteInfo);
//				for(int i = 0; i < ary.length(); i++){
//					Info info = new Info();
//					info.setAttributeByjson(ary.getJSONObject(i));
//					noteifos.add(info);
//				}
//			} catch (Exception e) {
////				mNotoInfo = new JSONArray();
//			}
//			//解密详情的关键信息,用户自己查看分享模式下时不需要显示关键信息出来
//			if(!mIsShareModel){
//				String note = json.optString("note_identity_info");
//				if(note != null && !"".equals(note) && Platform.getInstance() != null){
//					String noteinfo = DES3Utils.decryptMode(note.getBytes(), Platform.getInstance().getRecord3DesKey());
//					try {
//						JSONArray notes = new JSONArray(noteinfo);
//						for(int i = 0; i < notes.length(); i++){
//							Info info = new Info();
//							info.setAttributeByjson(notes.getJSONObject(i));
//							noteifos.add(info);
//						}
//					} catch (Exception e) {
//						e.printStackTrace();
//					}
//				}
//			}
//			//详细信息排序
//			Collections.sort(noteifos);
//			mNotoInfo = new JSONArray();
//			for(int i = 0; i < noteifos.size(); i++){
//				mNotoInfo.put(i, noteifos.get(i).json);
//			}
//			
			//这个记录含有的图像
			//如果是分享的病历记录,或者这个病历的分享模式，图片数可能会为0，这时人为创建一个，只用于显示。检查的原图在分享状态仍是可看的

			JSONArray photos = json.optJSONArray("images");
			if(photos != null){
				for(int i = 0; i < photos.length(); i++){
					PhotoRecord photo = new PhotoRecord();
					photo.setAtttributeByjson(photos.getJSONObject(i));
					mPhotos.add(photo);
				}
			}
			
//			//解析记录的附件图片Id
//			JSONArray attachmetns = json.optJSONArray("images_attachment");
//			if (attachmetns != null){
//				for(int i = 0; i < attachmetns.length(); i++){
//					JSONObject item = attachmetns.getJSONObject(i);
//					String date = item.optString("created_at");
//					
//					ArrayList<Integer> imageIds = mAttachmentImageId.get(date);
//					if(imageIds == null){
//						imageIds = new ArrayList<Integer>();
//						mAttachmentImageId.put(date, imageIds);
//					}
//					
//					JSONArray ids = item.optJSONArray("images");
//					for(int j = 0; j < ids.length(); j++){
//						imageIds.add(ids.optInt(j));
//					}
//				}
//			}
			
//			//数据显示模板（锚点） 现在不需要服务器返回锚点了，自己统计
//			JSONArray temps = json.optJSONArray("templateItems");
//			if(temps != null){
//				mTemplates = new ArrayList<RecordItem.TemplateItem>();
//				for(int i = 0; i < temps.length(); i++){
//					TemplateItem temp = new TemplateItem();
//					temp.setAtttributeByjson(temps.optJSONObject(i));
//					if(temp.category == 2){
//						mTemplates.add(temp);
//					}
//				}
//			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public JSONObject getJson() {
		JSONObject json = new JSONObject();
		
		try {
			json.put("recordTitle", recordTitle);
			json.put("recog_time", recogTime);
			json.put("record_type", mType);
			json.put("status", mState);
			json.put("record_info_id", recordInfoId);
			json.put("record_item_id", recordItemId);
			json.put("patient_id", patientId);
			json.put("hospital_id", hospitalID);
		} catch (Exception e) {
		}
		
		//病历记录的原图
		if(mPhotos != null){
			JSONArray photos = new JSONArray();
			for(int i = 0; i < mPhotos.size(); i++){
				photos.put(mPhotos.get(i).getJson());
			}
			try{
				json.put("images", photos);
			}catch(Exception e){
				e.printStackTrace();
			}
		}
		
//		//数据的模板(锚点)
//		if(mTemplates != null){
//			JSONArray temps = new JSONArray();
//			for(int i = 0; i < mTemplates.size(); i++){
//				temps.put(mTemplates.get(i).getJson());
//			}
//			try{
//				json.put("templateItems", temps);
//			}catch(Exception e){
//				e.printStackTrace();
//			}
//		}
		
		//化验数据
		if(mExams != null){
			JSONArray exams = new JSONArray();
			for(int i = 0; i < mExams.size(); i++){
				exams.put(mExams.get(i).getJson());
			}
			try{
				json.put("examItems", exams);
			}catch(Exception e){
				e.printStackTrace();
			}
		}
		
		//非标准化验数据
		if((mExams == null || mExams.size() == 0) && mOtherExams != null){
			JSONArray otherinfos = new JSONArray();
			for(int i = 0; i < mOtherExams.size(); i++){
				JSONArray ary = new JSONArray();
				ArrayList<String> items = mOtherExams.get(i);
				for(String str:items){
					ary.put(str);
				}
				otherinfos.put(ary);
			}
			try {
				json.put("other_info", otherinfos.toString());
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		
		//基本信息 basic_info
//		if(mBaseInfo != null){
//			try {
//				json.put("basic_info", mBaseInfo.toString());
//			} catch (JSONException e) {
//				e.printStackTrace();
//			}
//		}
//		
//		//详细信息 note_info
//		if(mNotoInfo != null){
//			try {
//				json.put("note_info", mNotoInfo.toString());
//			} catch (JSONException e) {
//				e.printStackTrace();
//			}
//		}
		
		return json;
	}
	
	
	
	
	
	/**
	 * 病历记录详情的数据模板<br/>
	 * 用于病历记录数据的排序显示和关键字查询<br/>
	 * category:1基本信息，2记录详情
	 * @author reason
	 */
	public class TemplateItem extends HalcyonEntity {

		private static final long serialVersionUID = 1L;
		public String name;
		public int sortId;
		/**1基本信息，2记录详情*/
		public int category;
		
		public String getName(){
			return name;
		}
		
		public int getSortId() {
			return sortId;
		}

		public void setSortId(int sortId) {
			this.sortId = sortId;
		}

		public int getCategory() {
			return category;
		}

		public void setCategory(int category) {
			this.category = category;
		}

		@Override
		public void setAtttributeByjson(JSONObject json) {
			name = json.optString("column_name");
			sortId = json.optInt("sort_id",-1);
			category = json.optInt("column_category",-1);
		}
				
		@Override
		public JSONObject getJson() {
			JSONObject json = new JSONObject();
			try{
				json.put("column_name", name);
				json.put("sort_id", sortId);
				json.put("column_category", category);
			}catch(Exception e){
				e.printStackTrace();
			}
			return json;
		}
	}
	
	public class Info{// implements Comparable<Info>{
//		public int index;
//		public JSONObject json;
//		
		public void setAttributeByjson(JSONObject js){
//			index = js.optInt("index");
//			json = js;
		}
//
//		@Override
//		public int compareTo(Info another) {
//			return index - another.index;
//		}
	}
	
	public ArrayList<String> getKeys(){
//		ArrayList<String> arrayKeys = new ArrayList<String>();
//		if(mNotoInfo == null){
//			return arrayKeys;
//		}
//		for (int i = 0; i < mNotoInfo.length(); i++) {
//			try {
//				JSONObject obj = mNotoInfo.getJSONObject(i);
//				Iterator<String> keys = obj.keys();
//				while (keys.hasNext()) {
//					String key = keys.next();
//					if("index".equals(key))continue;//这个字段只是用于排序，不需要显示出来
//					arrayKeys.add(key);
//				}
//			} catch (Exception e) {
//				Log.e("OtherRecordView", "brow record item other record view get key error", e);
//			}
//		}
//		return arrayKeys;
		return null;
	}
	
	/**
	 * 获取信息所有信息的title,用作锚点
	 * @return
	 */
	public ArrayList<String> getInfoTitles(){
		ArrayList<String> arrayKeys = new ArrayList<String>();
		for(int i = 0; i < mDetailInfos.size(); i++){
			arrayKeys.add(mDetailInfos.get(i).mTitle);
		}
		return arrayKeys;
	}
	
	public ArrayList<String> getContents(){
//		ArrayList<String> arrayContents = new ArrayList<String>();
//		if(mNotoInfo == null){
//			return arrayContents;
//		}
//		for (int i = 0 ; i < getKeys().size(); i ++ ){
//			JSONObject obj = mNotoInfo.optJSONObject(i);
//			arrayContents.add(obj.optString(getKeys().get(i)));
//		}
//		return arrayContents;
		return null;
	}
	
	
	/**
	 * 解析基本信息，目前非化验单才显示基本信息
	 */
	private void parseBaseInfo(JSONObject json){
		//身份化信息
		parseInfo(json, "basic_info", false);
		
		//身份化（加密）信息
		parseInfo(json, "basic_identity_info", true);
	}
	
	
	/**
	 * 解析普通记录信息的数据
	 */
	private void parseNoteInfo(JSONObject json){
		//详细信息
		parseInfo(json, "note_info", false);
		
		//详细（加密）信息
		parseInfo(json, "note_identity_info", true);
	}
	
	/**
	 * 解析记录信息
	 * @param json JsonObject格式的整个记录
	 * @param key 需要解析的字段
	 * @param isDES3 改字段的内容是不是用DES3加密了的
	 */
	private void parseInfo(JSONObject json,String key,boolean isDES3){
		ArrayList<DetailItem> temp = mInfoMaps.get(key);
		
		String jstr = json.optString(key);
		if(jstr == null || "".equals(jstr))return;
		if(isDES3 && Platform.getInstance() != null){
			jstr = DES3Utils.decryptMode(jstr.getBytes(), Platform.getInstance().getRecord3DesKey());
		}
		try {
			JSONArray infos = new JSONArray(jstr);
			for(int i = 0; i < infos.length(); i++){
				try{
					DetailItem item = new DetailItem(key);
					item.setAttributeByjson(infos.getJSONObject(i));
					mDetailInfos.add(item);
					temp.add(item);
				}catch(Exception e){
					FQLog.i("解析记录中某天数据出错，出错数据为："+jstr);
					e.printStackTrace();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
	
	/**
	 * 解析化验单数据（分为标准和非标准）
	 */
	private void parseExamRecord(JSONObject json){
//		if(mType == RecordConstants.TYPE_EXAMINATION){
			//标准化验单数据
			JSONArray exams = json.optJSONArray("examItems");
			if(exams != null && exams.length() != 0){
				mExams = new ArrayList<RecordItem.RecordExamItem>();
				for(int i = 0; i < exams.length(); i++){
					RecordExamItem exam = new RecordExamItem();
					try{
						exam.setAtttributeByjson(exams.getJSONObject(i));
						mExams.add(exam);
					}catch(Exception e){
						FQLog.i("解析化验单数据出错，病历记录recordInfoId:"+recordInfoId);
					}
				}
			}
			
			//非标准化验单数据，当没有标准化验单数据时才显示
//			if(mExams == null || mExams.size() == 0){
				String otin = json.optString("other_info");
				try{
					if(!(otin == null || "".equals(otin))){
						JSONArray otherinfos = new JSONArray(otin);
						if(otherinfos != null){
							mOtherExams = new ArrayList<ArrayList<String>>();
							for(int i = 0; i < otherinfos.length(); i++){
								JSONArray item = otherinfos.getJSONArray(i);
								ArrayList<String> info = new ArrayList<String>();
								for(int j = 0; j < item.length(); j ++){
									info.add(item.getString(j));
								}
								mOtherExams.add(info);
							}
						}
					}else{
						mOtherExams = new ArrayList<ArrayList<String>>();
					}
				}catch(Exception e){
					e.printStackTrace();
				}
//			}
//		}
	}
	
	/**
	 * 解析体检记录的数据
	 */
	public void parseMedicalInfo(JSONObject json){
		//解析体检文档
		mNotoInfos = json.optString("note_info");
		
		//解析体检图表title
		String other = json.optString("other_info");
		try{
			JSONArray array = new JSONArray(other);
			
			JSONArray temp = array.optJSONArray(0);
			JSONArray head = new JSONArray();
			for(int i = 0; i < temp.length(); i++){
				head.put(MEDICAL_TITLES[i]);
			}
			mOhterInfos = head.toString();
			
			//解析体检图表内容
			JSONArray exam = json.optJSONArray("examItems");
			if(exam != null && exam.length() > 0){
				JSONArray ex = new JSONArray();
				
				for(int i = 0; i < exam.length(); i++){
					JSONObject r = exam.optJSONObject(i);
					JSONArray item = new JSONArray();
					
					//判定化验结果是否正常
					String abn = json.optString("abnormal_value");
					if("L".equals(abn))item.put(-1);
					else if("H".equals(abn))item.put(1);
					else item.put(0);
					
					//这两个值是两种（标准、非标准）化验类型都有的
					item.put(r.optString(temp.optString(0)));
					item.put(r.optString(temp.optString(1)));
					
					//这连个值只有标准化验类型才有
					if(temp.length() == 4){
						item.put(r.optString(temp.optString(2)));
						item.put(r.optString(temp.optString(3)));
					}
					
					ex.put(item);
				}
				mExamInfos = ex.toString();
			}else{
				mExamInfos="";
			}
		}catch(Exception e){
			mOhterInfos = "";
			mExamInfos="";
		}	
	}

	/**
	 * 一个类型为化验的病历记录
	 * @author reason
	 */
	public class RecordExamItem extends HalcyonEntity{
		
		private static final long serialVersionUID = 1L;
		public String name;
		public String expectValue;
		public String examValus;
		public String unit;
		private String abn;
		private EXAM_STATE state;
		private int examId;
		/**标本*/
		private String sample;
		public String getName(){
			return name;
		}
		
		public String getExpectValue() {
			return expectValue;
		}

		public void setExpectValue(String expectValue) {
			this.expectValue = expectValue;
		}

		public String getExamValus() {
			return examValus;
		}

		public void setExamValus(String examValus) {
			this.examValus = examValus;
		}

		public String getUnit() {
			return unit;
		}

		public void setUnit(String unit) {
			this.unit = unit;
		}

		public String getAbn() {
			return abn;
		}

		public void setAbn(String abn) {
			this.abn = abn;
		}

		public EXAM_STATE getState() {
			return state;
		}

		public void setState(EXAM_STATE state) {
			this.state = state;
		}

		public int getExamId(){
			return examId;
		}
		
		public String getValueState(){
			if(state == EXAM_STATE.L)return "↓";
			else if(state == EXAM_STATE.H)return "↑";
			else return "";
		}
		
		public String getSample() {
			return sample;
		}

		public void setSample(String sample) {
			this.sample = sample;
		}
		
		/**
		 * 得到当前化验数据的状态
		 * @return EXAM_STATE
		 */
		public EXAM_STATE getExamState(){
			return state;
//			if("L".equals(state))return EXAM_STATE.L;
//			else if("H".equals(state))return EXAM_STATE.H;
//			else return EXAM_STATE.M;
		}
		
		@Override
		public void setAtttributeByjson(JSONObject json) {
			try {
				name = json.optString("item_name");
				unit = json.optString("item_unit");
				expectValue = json.optString("expect_value");
				examValus = json.optString("exam_value");
				abn = json.optString("abnormal_value");
				examId = json.optInt("info_exam_id");
				sample = json.optString("item_specimen");
				if("L".equals(abn))state = EXAM_STATE.L;
				else if("H".equals(abn))state = EXAM_STATE.H;
				else state = EXAM_STATE.M;
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		@Override
		public JSONObject getJson() {
			JSONObject json = new JSONObject();
			try{
				json.put("item_name", name);
				json.put("item_unit", unit);
				json.put("expect_value", expectValue);
				json.put("exam_value", examValus);
				json.put("abnormal_value", abn);
				json.put("exam_id", examId);
				json.put("item_specimen", sample);
			}catch(Exception e){
				e.printStackTrace();
			}
			return json;
		}
		
	}


	/**
	 * 记录详情的一条信息
	 * @author reason
	 *
	 */
	public class DetailItem implements Comparable<DetailItem>{
		public String mTitle;
		public String mContent;
		public String mInfoTyp;
		public int index;
		
		/**
		 * 初始化
		 * @param type 传入信息的类型：基本信息，基本身份化信息，详细信息，详细身份化信息
		 */
		public DetailItem(String type){
			mInfoTyp = type;
		}
		
		/**自动解析填充数据*/
		public void setAttributeByjson(JSONObject json){
			Iterator<String> keys =  json.keys();
			while(keys.hasNext()){
				String key = keys.next();
				if("index".equals(key)){
					index = json.optInt(key);
				}else{
					mTitle = key;
					mContent = json.optString(key);
				}
			}
		}
		
		/**
		 * 用于比较
		 */
		@Override
		public int compareTo(DetailItem another) {
			return index - another.index;
		}
	}
}
