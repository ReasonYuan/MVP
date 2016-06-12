package com.hp.android.halcyon;


import android.app.Activity;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.hp.android.halcyon.util.BaiDuTJSDk;
import com.hp.android.halcyon.util.TextFontUtils;

public abstract class BaseActivity extends Activity{
	protected FrameLayout mContainer;
	private ImageView mTopLeftImgView;
	private ImageView mTopRightImgView;
	private TextView mTopLeftTxtView;
	private TextView mTopRightTxtView;
	private TextView mTittle;
	private ImageView mTopLeftImgView2;
	private ImageView mTopRightImgView2;
	private TextView mTopLeftTxtView2;
	private TextView mTopRightTxtView2;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_base);
		mContainer = (FrameLayout) findViewById(R.id.fl_parent_container);
		int id = getContentId();
		if(id != 0){
			mContainer.addView(LayoutInflater.from(this).inflate(id, null));
		}
		
		mTittle = (TextView) findViewById(R.id.tv_topbar_text);
		mTopLeftImgView = (ImageView) findViewById(R.id.img_topbar_left);
		mTopRightImgView = (ImageView) findViewById(R.id.img_topbar_right);
		mTopLeftTxtView = (TextView) findViewById(R.id.tv_topbar_left);
		mTopRightTxtView = (TextView) findViewById(R.id.tv_topbar_right);
		mTopLeftImgView2 = (ImageView) findViewById(R.id.img_topbar_left2);
		mTopRightImgView2 = (ImageView) findViewById(R.id.img_topbar_right2);
		mTopLeftTxtView2 = (TextView) findViewById(R.id.tv_topbar_left2);
		mTopRightTxtView2 = (TextView) findViewById(R.id.tv_topbar_right2);
		init();
	}
	
	public abstract int getContentId();
	
	public abstract void init();
	
	public void setTopLeftImgShow(boolean isShow){
		mTopLeftImgView.setVisibility(isShow?View.VISIBLE:View.GONE);
	}
	
	public void setTopLeft2ImgShow(boolean isShow){
		mTopLeftImgView2.setVisibility(isShow?View.VISIBLE:View.GONE);
	}
	
	public void setTopRightImgShow(boolean isShow){
		mTopRightImgView.setVisibility(isShow?View.VISIBLE:View.GONE);
		findViewById(R.id.fl_topbar_right).setVisibility(View.VISIBLE);
	}
	
	public void setTopRightTextShow(boolean isShow){
		mTopRightTxtView.setVisibility(isShow?View.VISIBLE:View.GONE);
		findViewById(R.id.fl_topbar_right).setVisibility(View.VISIBLE);
	}
	
	public void setTopRight2ImgShow(boolean isShow){
		mTopRightImgView2.setVisibility(isShow?View.VISIBLE:View.GONE);
		findViewById(R.id.fl_topbar_right2).setVisibility(View.VISIBLE);
	}
	
	public void setTopLeftImgSrc(int resid){
		mTopLeftImgView.setImageResource(resid);
		mTopLeftImgView.setVisibility(View.VISIBLE);
	}
	
	public void setTopLeft2ImgSrc(int resid){
		mTopLeftImgView2.setImageResource(resid);
		mTopLeftImgView2.setVisibility(View.VISIBLE);
	}
	
	public void setTopRightImgSrc(int resid){
		mTopRightImgView.setImageResource(resid);
		mTopRightImgView.setVisibility(View.VISIBLE);
		findViewById(R.id.fl_topbar_right).setVisibility(View.VISIBLE);
	}
	
	public void setTopRight2ImgSrc(int resid){
		mTopRightImgView2.setImageResource(resid);
		mTopRightImgView2.setVisibility(View.VISIBLE);
		findViewById(R.id.fl_topbar_right2).setVisibility(View.VISIBLE);
	}
	
	public void setTopLeftText(int resid){
		mTopLeftTxtView.setText(resid);
		mTopLeftTxtView.setVisibility(View.VISIBLE);
		setTopLeftImgShow(false);
	}
	
	public void setTopLeft2Text(int resid){
		mTopLeftTxtView2.setText(resid);
		mTopLeftTxtView2.setVisibility(View.VISIBLE);
		findViewById(R.id.fl_topbar_left2).setVisibility(View.VISIBLE);
	}
	
	
	public void setTopRightText(String text){
		mTopRightTxtView.setText(text);
		mTopRightTxtView.setVisibility(View.VISIBLE);
		findViewById(R.id.fl_topbar_right).setVisibility(View.VISIBLE);
	}
	
	public void setTopRight2Text(String text){
		mTopRightTxtView2.setText(text);
		mTopRightTxtView2.setVisibility(View.VISIBLE);
		findViewById(R.id.fl_topbar_right2).setVisibility(View.VISIBLE);
	}
	
	public void setTopRightText(int resid){
		mTopRightTxtView.setText(resid);
		mTopRightTxtView.setVisibility(View.VISIBLE);
		findViewById(R.id.fl_topbar_right).setVisibility(View.VISIBLE);
	}
	
	public void setTopRight2Text(int resid){
		mTopRightTxtView2.setText(resid);
		mTopRightTxtView2.setVisibility(View.VISIBLE);
		findViewById(R.id.fl_topbar_right2).setVisibility(View.VISIBLE);
	}
	
	public void setTopRightBtnEnable(boolean isEnable){
		findViewById(R.id.fl_topbar_right).setEnabled(isEnable);
		mTopRightTxtView.setEnabled(isEnable);
	}
	
	public void setTopLeftBtnEnable(boolean isEnable){
		findViewById(R.id.fl_topbar_left).setEnabled(isEnable);
		mTopLeftTxtView.setEnabled(isEnable);
	}
	
	public void setTopRight2BtnEnable(boolean isEnable){
		findViewById(R.id.fl_topbar_right2).setEnabled(isEnable);
		mTopRightTxtView2.setEnabled(isEnable);
	}
	
	public void setTopLeftBtnShow(boolean isShow){
		findViewById(R.id.fl_topbar_left).setVisibility(isShow?View.VISIBLE:View.GONE);
	}
	
	public void setTopLeft2BtnShow(boolean isShow){
		findViewById(R.id.fl_topbar_left2).setVisibility(isShow?View.VISIBLE:View.GONE);
	}
	
	public void setTitle(String tittle){
		mTittle.setText(tittle);
		Typeface mFont = TextFontUtils.getTypeface(TextFontUtils.FONT_FZLTJT_BLOD);//Typeface.createFromAsset(getAssets(),"lantingchuheijian.TTF");
//		mTittle.setTextColor(Color.parseColor("#535353"));
		mTittle.setTypeface(mFont);
	}

	public void setTitle(int resid){
		mTittle.setText(resid);
	}
	
	/*public void setTitle2(String title){
		((TextView) findViewById(R.id.tv_topbar_title_text)).setText(title);
		findViewById(R.id.ll_topbar_title).setVisibility(View.VISIBLE);
		findViewById(R.id.v_title_place_view).setVisibility(View.VISIBLE);
	}
	
	public void setTitle2(int titleId){
		((TextView) findViewById(R.id.tv_topbar_title_text)).setText(titleId);
		findViewById(R.id.ll_topbar_title).setVisibility(View.VISIBLE);
		findViewById(R.id.v_title_place_view).setVisibility(View.VISIBLE);
	}*/
	
	public void hideTitleLine(){
		findViewById(R.id.v_base_title_line).setVisibility(View.GONE);
	}
	
	/*public void setContainerTopUnderTopbar(){
		findViewById(R.id.v_title_topbar_view).setVisibility(View.VISIBLE);
		findViewById(R.id.v_title_place_view).setVisibility(View.GONE);
	}*/
	
	public void setContainerTop(){
		findViewById(R.id.v_title_topbar_view).setVisibility(View.GONE);
	}
	
	public void onTopLeftBtnClick(View view){
		onBackPressed();
	}
	
	public void onTopLeftBtn2Click(View view){}
	
	public void onTopRightBtnClick(View view){}
	
	public void onTopRightBtnClick2(View view){}
	
	public View getTopBar(){
		return findViewById(R.id.rl_topbar);
	}
	
	/**
	 * 显示一条toast信息
	 * @param msg
	 * @param time
	 */
	protected void showToast(final String msg, final int duration){
		try {
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Toast.makeText(BaseActivity.this, msg, duration).show();
				}
			});
		} catch (Exception e) {
		}
	}
	
	/**
	 * 安全运行后台通知前台更新UI
	 * 防止后台线程在UI消失后通知ui报异常
	 * @param runnable
	 */
	protected void runOnUiThreadSafety(Runnable runnable){
		try {
			runOnUiThread(runnable);
		} catch (Exception e) {
			Log.e("", "", e);
		}
	}
	
	/**
	 * 获取某个view，代替繁琐的findViewById
	 * @param id
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public final <E extends View> E getView (int id) {
	    try {
	        return (E) findViewById(id);
	    } catch (ClassCastException ex) {
	        Log.e("BaseActivity", "Could not cast View to concrete class.", ex);
	        throw ex;
	    }
	}
	
	@Override
	protected void onResume() {
		BaiDuTJSDk.onResume(this);
		super.onResume();
	}
	
	@Override
	protected void onPause() {
		BaiDuTJSDk.onPause(this);
		super.onPause();
	}
}
