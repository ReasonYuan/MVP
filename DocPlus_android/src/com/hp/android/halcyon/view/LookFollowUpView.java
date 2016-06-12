package com.hp.android.halcyon.view;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.FollowUp;
import com.fq.halcyon.entity.OnceFollowUpCycle;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic2.CancleFollowUpLogic;
import com.fq.halcyon.logic2.CancleFollowUpLogic.CancleFollowUpLogicInterface;
import com.fq.lib.callback.ICallback;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.HalcyonApplication;
import com.hp.android.halcyon.PatientDetailActivity;
import com.hp.android.halcyon.util.MessageStruct;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;

public class LookFollowUpView extends View implements OnClickListener{

	private Context mContext;
	private View mView;
	private Button mCancleFollowUp;
	private FollowUp mFollowUp;
	private TextView mTime;
	private ImageView mDoctorHead;
	private ImageView mFriendHead;
	private TextView mEditText;
	private Contacts mPatient;
	private OnceFollowUpCycle mCurrentCycle;
	private UpdateUIInterface mInterface;
	private CustomDialog mCustomDialog;
	private Button mCurrentCB;
	private Button mAllCB;
	private View mDialogView;
	private Button mSure;
	private Button mDismiss;
	private int mSelectCancleIndex = 0;
	private int mTimerId;
	private ArrayList<Integer> mItemsId;
	private TextView mDoctorName;
	private TextView mPatientName;
	public LookFollowUpView(Context context, AttributeSet attrs,
			int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		this.mContext = context;
		initView();
	}

	public LookFollowUpView(Context context, AttributeSet attrs) {
		super(context, attrs);
		this.mContext = context;
		initView();
	}

	public LookFollowUpView(Context context) {
		super(context);
		this.mContext = context;
		initView();
	}

	public void initView(){
		mView = LayoutInflater.from(mContext).inflate(R.layout.follow_up_view, null);
		mCancleFollowUp = (Button) mView.findViewById(R.id.cancle_follow_up);
		mTime = (TextView) mView.findViewById(R.id.look_time);
		mCancleFollowUp.setOnClickListener(this);
		
		mDoctorHead = (ImageView) mView.findViewById(R.id.doctor_head);
		mFriendHead = (ImageView) mView.findViewById(R.id.friend_head_view);
		mDoctorHead.setOnClickListener(this);
		mFriendHead.setOnClickListener(this);
		
		mDoctorName = (TextView) mView.findViewById(R.id.doctor_name);
		mPatientName = (TextView) mView.findViewById(R.id.patient_name);
		
		mEditText = (TextView) mView.findViewById(R.id.content);
		
		mDialogView = LayoutInflater.from(mContext).inflate(R.layout.view_cancle_follow_up, null);
		mSure = (Button) mDialogView.findViewById(R.id.sure);
		mDismiss = (Button) mDialogView.findViewById(R.id.dismiss);
		mSure.setOnClickListener(this);
		mDismiss.setOnClickListener(this);
		mCurrentCB = (Button) mDialogView.findViewById(R.id.current);
		mAllCB = (Button) mDialogView.findViewById(R.id.all);
		mSelectCancleIndex = 1;
		mCurrentCB.setSelected(true);
		mCurrentCB.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				mSelectCancleIndex = 1;
				mAllCB.setSelected(false);
				mCurrentCB.setSelected(true);
			}
		});
			
				
		
		mAllCB.setOnClickListener(new OnClickListener(){
			
			@Override
			public void onClick(View v) {
				mSelectCancleIndex = 2;
				mAllCB.setSelected(true);
				mCurrentCB.setSelected(false);
			}
		});
		
	}

	public void initData(ArrayList<Integer> itemsId,String date,Contacts patient,OnceFollowUpCycle mCycle,UpdateUIInterface mIn,int timerId){
		this.mInterface = mIn;
		mPatient = patient;
		this.mTimerId = timerId;
		mCurrentCycle = mCycle;
		this.mItemsId = itemsId;
		mDoctorName.setText(Constants.getUser().getName());
		mPatientName.setText(mPatient.getName());
		mTime.setText("随访时间："+"\n" +date);
		mDoctorHead.setImageBitmap(UITools.getBitmapWithPath(FileSystem.getInstance().getUserHeadPath()));
		
		//==YY==imageId(只要imageId)
//		Photo mPhone = new Photo(mPatient.getHeadPicImageId(),"");
		Photo mPhone = new Photo(mPatient.getImageId(),"");
		
		ApiSystem.getInstance().getHeadImage(mPhone, new ICallback() {
			
			@Override
			public void doCallback(Object obj) {
				mFriendHead.setImageBitmap(UITools.getBitmapWithPath(""+obj));
			}
		}, false, 2);
		mEditText.setText(mCurrentCycle.getmItemName());
	}
	
	
	public View getView(){
		return mView;
		
	}
	
	public void cancleOnceFollowUpAlarm(int itemtId){
		JSONObject mJsonObject = new JSONObject();
		try {
			mJsonObject.put(""+itemtId,itemtId);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		HalcyonApplication.getInstance().sendMessage(MessageStruct.MESSAGE_TYPE_DELETE_ONE_FOLLOW_UP, "删除一条随访", mPatient.getUserId(), mJsonObject);
	}
	
	public void cancleAllFollowUpAlarm(ArrayList<Integer> itemsId){
		JSONObject mJsonObject = new JSONObject();
		for (int i = 0; i < itemsId.size(); i++) {
			try {
				mJsonObject.put(""+itemsId.get(i),itemsId.get(i));
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		HalcyonApplication.getInstance().sendMessage(MessageStruct.MESSAGE_TYPE_DELETE_ALL_FOLLOW_UP, "删除全部随访", mPatient.getUserId(), mJsonObject);
	}
	
	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.cancle_follow_up:
//			UITools.showToast("取消当前随访id"+mCurrentCycle.getmItemtId());
			
			mSelectCancleIndex = 1;
			if (mCustomDialog != null) {
				mCurrentCB.setSelected(true);
				mAllCB.setSelected(false);
				mCustomDialog.show();
			}else{
				mCustomDialog = new CustomDialog(mContext);
				mCustomDialog.setOnlyContainer(mDialogView);
			}
			
			break;
		case R.id.doctor_head:
			
			break;
		case R.id.friend_head_view:
			Intent mIntent = new Intent();
			mIntent.putExtra("patient_friend_id", mPatient.getUserId());
			mIntent.setClass(mContext, PatientDetailActivity.class);
			mContext.startActivity(mIntent);
			break;
		case R.id.sure:
			if (mSelectCancleIndex == 1) {
				CancleFollowUpLogic mCancleFollowUpLogic = new CancleFollowUpLogic(new CancleFollowUpLogicInterface() {
					
					@Override
					public void onError(int code, Throwable error) {
						UITools.showToast(error.toString());
					}
					
					@Override
					public void onCancleSuccess() {
						mInterface.callBack(1);
//						UITools.showToast("确定"+mSelectCancleIndex);
						mCustomDialog.dismiss();
						cancleOnceFollowUpAlarm(mCurrentCycle.getmItemtId());
					}
					
					@Override
					public void onCancleError(int code, String msg) {
						UITools.showToast(msg);
					}
				});
				mCancleFollowUpLogic.cancleOneFollowUp(mCurrentCycle.getmItemtId());
			}else if(mSelectCancleIndex == 2){
				CancleFollowUpLogic mCancleFollowUpLogic = new CancleFollowUpLogic(new CancleFollowUpLogicInterface() {
					
					@Override
					public void onError(int code, Throwable error) {
						UITools.showToast(error.toString());
					}
					
					@Override
					public void onCancleSuccess() {
						mInterface.callBack(2);
//						UITools.showToast("确定"+mSelectCancleIndex);
						mCustomDialog.dismiss();
						cancleAllFollowUpAlarm(mItemsId);
					}
					
					@Override
					public void onCancleError(int code, String msg) {
						UITools.showToast(msg);
					}
				});
				mCancleFollowUpLogic.cancleAllFollowUp(mTimerId);
			}
			
			break;
		case R.id.dismiss:
			mCustomDialog.dismiss();
			break;
		default:
			break;
		}
	}
	
	public interface UpdateUIInterface{
		public void callBack(int type);
	}
}
