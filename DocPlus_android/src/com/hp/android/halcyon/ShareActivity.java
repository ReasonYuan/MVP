package com.hp.android.halcyon;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.onekeyshare.OnekeyShare;

import com.fq.android.plus.R;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.hp.android.halcyon.zxing.ZxingTools;

public class ShareActivity extends BaseActivity implements OnClickListener {

	private LinearLayout mWeibo;
	private LinearLayout mPhoneMsg;
	private LinearLayout mWxZone;
	private LinearLayout mWxFriend;

	@Override
	public int getContentId() {
		return R.layout.activity_share;
	}

	@Override
	public void init() {
		setTopLeftImgSrc(R.drawable.btn_back);
		WindowManager wm = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
		int width = wm.getDefaultDisplay().getWidth();
		int height = wm.getDefaultDisplay().getHeight();
		int bitmapWidth = Math.min(width, height) * 2 / 3;
		String url = UriConstants.getInvitationURL() + "?user_id="
				+ Constants.getUser().getUserId();
		ZxingTools.initMinBitmap(this);
		Bitmap bmp = ZxingTools.createQRImage(url, bitmapWidth, bitmapWidth);
		if (bmp != null) {
			((ImageView) findViewById(R.id.iv_zxing_bmp)).setImageBitmap(bmp);
		}

		mWeibo = (LinearLayout) findViewById(R.id.sina_weibo);
		mPhoneMsg = (LinearLayout) findViewById(R.id.phone_msg);
		mWxZone = (LinearLayout) findViewById(R.id.wx_friend_zone);
		mWxFriend = (LinearLayout) findViewById(R.id.wx_friend);
		mWeibo.setOnClickListener(this);
		mPhoneMsg.setOnClickListener(this);
		mWxZone.setOnClickListener(this);
		mWxFriend.setOnClickListener(this);
		ShareSDK.initSDK(this);
		Platform[] list = ShareSDK.getPlatformList();
		if (list != null) {
			mWeibo.setTag(list[0]);
			mWxFriend.setTag(list[1]);
			mWxZone.setTag(list[2]);
			mPhoneMsg.setTag(list[3]);

		}

	}

	public void share(String name) {
		OnekeyShare oks = new OnekeyShare();
		// 关闭sso授权
		oks.disableSSOWhenAuthorize();
		// 分享时Notification的图标和文字
		oks.setNotification(R.drawable.app_icon, getString(R.string.app_name));
//		oks.setTitle(getString(R.string.share));
		String url = UriConstants.getInvitationURL() + "?user_id="
				+ Constants.getUser().getUserId();
		if (name.equals("SinaWeibo")  ||  name.equals("ShortMessage") ) {//短信、微博
			oks.setText(Constants.getShareText(1) + url);
		} else{
			 if("Wechat".equals(name)){//微信好友
				 oks.setTitle(Constants.getShareTitle());
				 oks.setText(Constants.getShareText(3));
			 }else{//微信朋友圈
				 oks.setTitle(Constants.getShareText(2));
			 }
			oks.setUrl(url);
			oks.setImageUrl(UriConstants.getShareIconURL());
			oks.setSite(getString(R.string.app_name));
		}

		// 启动分享GUI
		oks.setPlatform(name);
		oks.show(this);
	}

	@Override
	public void onClick(View v) {
		share(((Platform) v.getTag()).getName());

	}

}
