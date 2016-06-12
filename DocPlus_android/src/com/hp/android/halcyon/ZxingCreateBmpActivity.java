package com.hp.android.halcyon;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.zxing.ZxingTools;

public class ZxingCreateBmpActivity extends BaseActivity {

	private ImageView mImgHead;
//	private TextView mDocPlusName;
//	private TextView mSweep;
	private TextView mTextRole;
	@Override
	public int getContentId() {
		return R.layout.activity_zxing_create_bmp;
	}

	@Override
	public void init() {
		WindowManager wm = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
		int width = wm.getDefaultDisplay().getWidth();
		int height = wm.getDefaultDisplay().getHeight();
		int bitmapWidth = Math.min(width, height)*2/3;
		initWidgets();
		String url = UriConstants.getInvitationURL()+"?user_id="+Constants.getUser().getUserId();
		ZxingTools.initMinBitmap(ZxingCreateBmpActivity.this);
		Bitmap bmp = ZxingTools.createQRImage(url,bitmapWidth,bitmapWidth);
		if (bmp != null) {
			((ImageView) findViewById(R.id.iv_zxing_creta_bmp))
					.setImageBitmap(bmp);
		}
	}
	
	private void initWidgets() {
//		((TextView) findViewById(R.id.tv_topbar_text)).setTextColor(Color
//				.parseColor("#535353"));
//		Typeface mFont = Typeface.createFromAsset(getAssets(),"lantingchuheijian.TTF");
//		((TextView) findViewById(R.id.tv_topbar_text)).setTypeface(mFont);
		setTitle("二维码");
		mImgHead = (ImageView) findViewById(R.id.img_zxing_user_head);
		mImgHead.setImageBitmap(UITools.getBitmapWithPath(FileSystem.getInstance().getUserHeadPath()));
//		mSweep = (TextView) findViewById(R.id.sweep);
//		mSweep.setTypeface(mFont);
//		String name = Constants.getUser().getDPName();
//		if(name == null ||"".equals(name))name = Constants.getUser().getUsername();
		TextView mDocPlusName = (TextView) findViewById(R.id.tv_zxing_doc_plus_name);
		mDocPlusName.setText(Constants.getUser().getUsername());
		mTextRole = (TextView) findViewById(R.id.tv_zxing_role);
		if(Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR){
			mTextRole.setText("医生");
		}else if(Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR_STUDENT){
			mTextRole.setText("医学生");
		}
	}
}
