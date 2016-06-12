package com.fq.android.visualization;

import java.util.ArrayList;

import android.content.Intent;
import android.graphics.Bitmap;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.fq.android.plus.R;
import com.fq.android.visualization.VisualizeCardView.OnCardItemClickListener;
import com.fq.android.visualization.VisualizeCardView.OnCardItemSelectedListener;
import com.fq.halcyon.entity.VisualizeCard;
import com.fq.halcyon.entity.visualize.VisualMap;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.DataVisualizationActivity;
import com.hp.android.halcyon.util.BitmapManager;

public class VisualizeActivity extends BaseActivity{

	private FrameLayout mCardLayout;
	private VisualizeCardView mCardView;
	private ImageView mImgBg1;
	private ImageView mImgBg2;
	private String[] titles = {"药物分析图表","化验项分析图表","地区分布比重图"};
	private int[] imgIds = {R.drawable.analysis_medicinal,R.drawable.analysis_exam,R.drawable.analysis_map};
	
	/**
	 * 药物分析的所在页
	 */
	private final int MEDICINAL_ANALYSIS = 0;
	/**
	 * 化验项分析的所在页
	 */
	private final int EXAM_ANALYSIS = 1;
	/**
	 * 地区分布比重图所在页
	 */
	private final int DISTRIBUTE_ANALYSIS = 2;
	
	@Override
	public int getContentId() {
		// TODO Auto-generated method stub
		return R.layout.activity_visualize;
	}
	@Override
	public void init() {
		initWidgets();
		initDatas();
		initListener();
	}
	
	private void initWidgets() {
		setTitle("数据可视化(Demo)");
		mCardLayout = getView(R.id.fl_visualize_card);
		mCardView = new VisualizeCardView(this);
		mCardLayout.addView(mCardView);
		mImgBg1 = getView(R.id.img_visualize_bg1);
		mImgBg2 = getView(R.id.img_visualize_bg2);
		mImgBg2.setVisibility(View.GONE);
	}

	private void initDatas() {
		ArrayList<VisualizeCard> datas = new ArrayList<VisualizeCard>();
		for (int i = 0; i < titles.length; i++) {
			VisualizeCard card = new VisualizeCard();
			card.setCardName(titles[i]);
			card.setImageId(imgIds[i]);
			datas.add(card);
		}
		mCardView.addDatas(datas);
		mCardView.scrollToPosition(1);
	}
	
	private void initListener() {
		mCardView.setCardItemClickListener(new OnCardItemClickListener() {
			
			@Override
			public void onItemClick(int position) {
				switch (position) {
				case MEDICINAL_ANALYSIS:
					startActivity(new Intent(VisualizeActivity.this,MedicinalAnalysisActivity.class));
					break;
				case EXAM_ANALYSIS:
					startActivity(new Intent(VisualizeActivity.this,ExamAnalysisActivity.class));
					break;
				case DISTRIBUTE_ANALYSIS:
					Intent intent = new Intent(VisualizeActivity.this,DataVisualizationActivity.class);
					intent.putExtra(DataVisualizationActivity.EXTRA, new VisualMap());
					startActivity(intent);
					break;
				default:
					break;
				}
			}
		});
		
		mCardView.setItemSelectedListener(new OnCardItemSelectedListener() {
			@Override
			public void onItemSelected(final VisualizeCard item) {
				runOnUiThread(new Runnable() {
					public void run() {
						setImgBg(item.getImageId());
					}
				});
			}
		});
	}
	
	/**
	 * 设置背景图片
	 */
	private void setImgBg(int resId){
		Animation animationIn= AnimationUtils.loadAnimation(VisualizeActivity.this, R.anim.fade_in);
		final Animation animationOut= AnimationUtils.loadAnimation(VisualizeActivity.this, R.anim.fade_out);
		animationIn.setDuration(450);
		animationOut.setDuration(450);
		if (mImgBg1.getVisibility() == View.GONE) {
			Bitmap bmp = BitmapManager.decodeSampledBitmapFromFile(resId, 4);
			mImgBg1.setImageBitmap(bmp);
			mImgBg1.setVisibility(View.VISIBLE);
			mImgBg1.startAnimation(animationIn);
			animationIn.setAnimationListener(new AnimationListener() {
				@Override
				public void onAnimationStart(Animation arg0) {
				}
				
				@Override
				public void onAnimationRepeat(Animation arg0) {
				}
				
				@Override
				public void onAnimationEnd(Animation arg0) {
					mImgBg2.setVisibility(View.GONE);
					mImgBg2.setAnimation(animationOut);
				}
			});
			
		}else{
			Bitmap bmp = BitmapManager.decodeSampledBitmapFromFile(resId, 4);
			mImgBg2.setImageBitmap(bmp);
			mImgBg2.setVisibility(View.VISIBLE);
			mImgBg2.startAnimation(animationIn);
			animationIn.setAnimationListener(new AnimationListener() {
				
				@Override
				public void onAnimationStart(Animation arg0) {
				}
				
				@Override
				public void onAnimationRepeat(Animation arg0) {
				}
				
				@Override
				public void onAnimationEnd(Animation arg0) {
					mImgBg1.setVisibility(View.GONE);
					mImgBg1.setAnimation(animationOut);
				}
			});
			
		}
	}
}
