package uk.co.senab.photoview;


import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ProgressBar;

import com.fq.android.plus.R;

public class ProgressImageView extends View{

	private View mView;
	private PhotoImageView mPhotoView;
	private ProgressBar mCycleBar;
	private Context mContext;
	public ProgressImageView(Context context, AttributeSet attrs,
			int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		mContext = context;
		init();
	}

	public ProgressImageView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mContext = context;
		init();
	}

	public ProgressImageView(Context context) {
		super(context);
		mContext = context;
		init();
	}

	public void init(){
		mView = LayoutInflater.from(mContext).inflate(R.layout.progress_image, null);
		mPhotoView = (PhotoImageView) mView.findViewById(R.id.photoview);
		mCycleBar = (ProgressBar) mView.findViewById(R.id.largeProgressBar);
	}
	
	public View getView(){
		return mView;
	}
	
	public void hiddenProgressBar(){
		mCycleBar.setVisibility(View.GONE);
	}
	
	public void showProgressBar(){
		mCycleBar.setVisibility(View.VISIBLE);
	}
	
	public void setImageResource(int resId){
		mPhotoView.setImageResource(resId);
	}
	
//	public void downLoadImage(final String url){
//		mPhotoView.downLoadImage(url,new DownLoadSuccessCallBack() {
//			
//			@Override
//			public void onSuccess() {
//				hiddenProgressBar();
//				Log.e("下载成功回调", url);
//			}
//		});
//	}
}
