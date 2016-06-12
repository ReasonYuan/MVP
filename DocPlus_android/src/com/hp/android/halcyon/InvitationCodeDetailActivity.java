package com.hp.android.halcyon;

import android.view.View;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.logic2.ResetDoctorInfoLogic;
import com.fq.halcyon.logic2.ResetDoctorInfoLogic.InvientCallback;
import com.fq.lib.tools.Constants;

public class InvitationCodeDetailActivity extends BaseActivity {

	@Override
	public int getContentId() {
		// TODO Auto-generated method stub
		return R.layout.activity_two_dimension_show;
	}

	@Override
	public void init() {
		final TextView tv = (TextView) findViewById(R.id.tv_two_dimension);
		if("".equals(Constants.getUser().getInvition())){
			new ResetDoctorInfoLogic().requestInvient(new InvientCallback() {
				@Override
				public void doInvientBack(String invient) {
					tv.setVisibility(View.VISIBLE);
					if ("".equals(invient)) {
						tv.setText("获取中");
					}else{
						tv.setText(invient);
						Constants.getUser().setInvition(invient);
					}
				}
			});
		}else{
			tv.setText(Constants.getUser().getInvition());
		}
		
		
	}

}
