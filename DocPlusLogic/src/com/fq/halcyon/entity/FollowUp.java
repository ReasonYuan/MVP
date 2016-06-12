package com.fq.halcyon.entity;

import java.util.ArrayList;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
/**
 * 随访实体类
 * @author wangxi
 *
 */
public class FollowUp extends HalcyonEntity{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	
	/**
	 * 随访第一条留言
	 */
	private String mTips;
	
	/**
	 * 随访人员id集合
	 */
	private ArrayList<Integer> mMemberList;
	
	/**
	 * 随访人员详细列表
	 */
	private ArrayList<Contacts> mFriendsList;
	
	/**
	 * 随访名称
	 */
	private String mFolloUpTempleName;
	
	/**
	 * 医生id
	 */
	private int mDoctorId;
	
	/**
	 * 随访每次的内容以及时间
	 */
	private ArrayList<OnceFollowUpCycle> mFollowUpItemsList;
	
	/**
	 * 随访留言列表
	 */
	private ArrayList<LeaveMessage> mMessageList;
	
	/**
	 * 随访开始时间
	 */
	private String mFromDate;
	
	/**
	 * 随访的ID
	 */
	private String mId;
	
	@Override
	public void test() {
		
	}


	public String getmTips() {
		return mTips;
	}

	public void setmTips(String mTips) {
		this.mTips = mTips;
	}


	public ArrayList<Integer> getmMemberList() {
		return mMemberList;
	}


	public void setmMemberList(ArrayList<Integer> mMemberList) {
		this.mMemberList = mMemberList;
	}


	public String getmFolloUpTempleName() {
		return mFolloUpTempleName;
	}


	public void setmFolloUpTempleName(String mFolloUpTempleName) {
		this.mFolloUpTempleName = mFolloUpTempleName;
	}


	public int getmDoctorId() {
		return mDoctorId;
	}


	public void setmDoctorId(int mDoctorId) {
		this.mDoctorId = mDoctorId;
	}


	public ArrayList<OnceFollowUpCycle> getmFollowUpItemsList() {
		return mFollowUpItemsList;
	}


	public void setmFollowUpItemsList(
			ArrayList<OnceFollowUpCycle> mFollowUpItemsList) {
		this.mFollowUpItemsList = mFollowUpItemsList;
	}
	
	public ArrayList<Contacts> getmFriendsList() {
		return mFriendsList;
	}


	public void setmFriendsList(ArrayList<Contacts> mFriendsList) {
		this.mFriendsList = mFriendsList;
	}


	public ArrayList<LeaveMessage> getmMessageList() {
		return mMessageList;
	}


	public void setmMessageList(ArrayList<LeaveMessage> mMessageList) {
		this.mMessageList = mMessageList;
	}


	public String getmFromDate() {
		return mFromDate;
	}


	public void setmFromDate(String mFromDate) {
		this.mFromDate = mFromDate;
	}


	public String getmId() {
		return mId;
	}


	public void setmId(String mId) {
		this.mId = mId;
	}


	@Override
	public void setAtttributeByjson(JSONObject json) {
		super.setAtttributeByjson(json);
		
		this.mFolloUpTempleName = json.optString("followup_name");
		this.mFromDate = json.optString("from_date");
		
		/**
		 * 解析提醒人列表
		 */
		JSONArray mArray = json.optJSONArray("members");
		mFriendsList = new ArrayList<Contacts>();
		for (int i = 0; i < mArray.length(); i++) {
			mFriendsList = new ArrayList<Contacts>();
			Contacts mContacts = new Contacts();
			JSONObject mJsonObject = mArray.optJSONObject(i);
			mContacts.setName(mJsonObject.optString("name"));

			//==YY==imageId(只要imageId)
			mContacts.setImageId(mJsonObject.optInt("image_id"));
//			mContacts.setHeadPicPath(mJsonObject.optString("image_path"));
//			mContacts.setHeadPicImageId(mJsonObject.optInt("image_id"));
	
			mContacts.setUserId(mJsonObject.optInt("member_id"));
			mFriendsList.add(mContacts);
		}
		
		/**
		 * 解析随访周期
		 */
		JSONArray mItemts = json.optJSONArray("followup_template_items");
		mFollowUpItemsList = new ArrayList<OnceFollowUpCycle>();
		for (int i = 0; i < mItemts.length(); i++) {
			OnceFollowUpCycle mCycle = new OnceFollowUpCycle();
			mCycle.setAtttributeByjson(mItemts.optJSONObject(i));
			mFollowUpItemsList.add(mCycle);
		}
		
		/**
		 * 解析随访留言
		 */
		JSONArray mContents = json.optJSONArray("content");
		mMessageList = new ArrayList<LeaveMessage>();
		for (int i = 0; i < mContents.length(); i++) {
			LeaveMessage message = new LeaveMessage();
			message.setAtttributeByjson(mContents.optJSONObject(i));
			mMessageList.add(message);
		}
		
	}
	
}
