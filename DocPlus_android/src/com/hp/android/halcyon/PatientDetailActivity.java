package com.hp.android.halcyon;

import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.entity.PatientFriend;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic2.SearchPatientDetailLogic;
import com.fq.halcyon.logic2.SearchPatientDetailLogic.SearchPatientDetailLogicInterface;
import com.fq.lib.callback.ICallback;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;

public class PatientDetailActivity extends BaseActivity implements OnClickListener{

	private ImageView mHeadImage;
	private TextView mNameAndGender;
	private TextView mDescription;
	private View mLine;
	/**
	 * 查看病历
	 */
	private Button mLookPatient;
	
	private int mPateintFriendId;
	
	private PatientFriend mPatientFriend;
	
	@Override
	public int getContentId() {
		return R.layout.activity_patient_detail;
	}

	@Override
	public void init() {
		setTitle("个人详情");
		mPateintFriendId = getIntent().getExtras().getInt("patient_friend_id");
		mHeadImage = (ImageView) findViewById(R.id.patient_friend_head);
		mNameAndGender = (TextView) findViewById(R.id.name_gender);
		mDescription = (TextView) findViewById(R.id.description);
		mLookPatient = (Button) findViewById(R.id.btn_look_patient);
		mLine = findViewById(R.id.line);
		mLookPatient.setOnClickListener(this);
		mLookPatient.setVisibility(View.INVISIBLE);
		mLine.setVisibility(View.INVISIBLE);
		getDetail();
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_look_patient:
			Intent mItent = new Intent();
			mItent.setClass(PatientDetailActivity.this, RecordListActivity.class);
			mItent.putExtra("patientName",mPatientFriend.getPatientName());
			mItent.putExtra("patientId",mPatientFriend.getPatientId());
			startActivity(mItent);
			break;

		default:
			break;
		}
	}

	public void getDetail(){
		SearchPatientDetailLogic mDetailLogic = new SearchPatientDetailLogic(new SearchPatientDetailLogicInterface() {
			
			@Override
			public void onError(int code, Throwable error) {
				UITools.showToast(error.toString());
			}
			
			@Override
			public void onSearchPatientErrorDetail(int code, String msg) {
				UITools.showToast(msg);
			}
			
			@Override
			public void onSearchPatientDetailSuccess(PatientFriend mFriend) {
				mPatientFriend = mFriend;
				ApiSystem.getInstance().getHeadImage(new Photo(mFriend.getImageId(), ""), new ICallback() {
					
					@Override
					public void doCallback(Object obj) {
						mHeadImage.setImageBitmap(UITools.getBitmapWithPath(""+obj));
					}
				}, false, 2);
				if (mFriend.getPatientFriendGender().equals("1")) {
					mNameAndGender.setText(mFriend.getName()+"   "+"女");
				}else if (mFriend.getPatientFriendGender().equals("2")){
					mNameAndGender.setText(mFriend.getName()+"   "+"男");
				}
				
				mDescription.setText(mFriend.getDescription());
				if (mFriend.getPatientId() != 0) {
					mLookPatient.setVisibility(View.VISIBLE);
					mLine.setVisibility(View.VISIBLE);
				}else{
					CustomDialog mCustomDialog = new CustomDialog(PatientDetailActivity.this);
					mCustomDialog.setMessage("该患者还未分享病案");
				}
			}
		});
		mDetailLogic.searchPatientDetail(mPateintFriendId);
	}
}
