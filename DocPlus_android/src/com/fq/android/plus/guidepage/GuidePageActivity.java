package com.fq.android.plus.guidepage;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;

import com.fq.android.plus.R;
import com.fq.android.plus.guidepage.GuideViewFour.OnStartListener;
import com.hp.android.halcyon.LoginActivity;

public class GuidePageActivity extends Activity implements OnClickListener,
		OnPageChangeListener {
	// 定义ViewPager对象
	private ViewPager viewPager;

	// 定义ViewPager适配器
	private ViewPagerAdapter vpAdapter;

	// 定义一个ArrayList来存放View
	private ArrayList<View> views;
	private boolean isGuideTwoFirstShow = true, isGuideThreeFirstShow = true,
			isGuideFourFirstShow = true;

	// 引导图片资源
	private static final int[] pics = { R.drawable.ic_launcher,
			R.drawable.ic_launcher, R.drawable.ic_launcher,
			R.drawable.ic_launcher };

	// 底部小点的图片
	private ImageView[] points;

	// 记录当前选中位置
	private int currentIndex;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_guide);
		initView();
		initData();
	}

	/**
	 * 初始化组件
	 */
	private void initView() {
		
		// 实例化ArrayList对象
		views = new ArrayList<View>();

		// 实例化ViewPager
		viewPager = (ViewPager) findViewById(R.id.viewpager);
		
		//自动跳转滑动时间调整
//		try {
//            Field field = ViewPager.class.getDeclaredField("mScroller");
//            field.setAccessible(true);
//            MyScroller scroller = new MyScroller(viewPager.getContext(),
//                    new AccelerateInterpolator());
//            field.set(viewPager, scroller);
//            scroller.setmDuration(400);
//        } catch (Exception e) {
//        }
		

		// 实例化ViewPager适配器
		vpAdapter = new ViewPagerAdapter(views);
	}

	/**
	 * 初始化数据
	 */
	private void initData() {
		
		//自动跳转回调
//		View guide1 = new GuideViewOne(this, new AnimationFinishCallBack() {
//
//			@Override
//			public void onFinishCallback() {
//				viewPager.setCurrentItem(1,false);
//				
//			}
//		});
//		View guide2 = new GuideViewTwo(this, new AnimationFinishCallBack() {
//
//			@Override
//			public void onFinishCallback() {
//				viewPager.setCurrentItem(2,false);
//			}
//		});
		// 初始化引导列表
		View guide1 = new GuideViewOne(this);
		View guide2 = new GuideViewTwo(this);
		View guide3 = new GuideViewThree(this);
		View guide4 = new GuideViewFour(this);
		views.add(guide1);
		views.add(guide2);
		views.add(guide3);
		views.add(guide4);

		// 设置数据
		viewPager.setAdapter(vpAdapter);
		// 设置监听
		viewPager.setOnPageChangeListener(this);

		// 初始化底部小点
		// initPoint();
		((GuideViewFour) guide4).setOnStartListener(new OnStartListener() {
			// 监听开始按钮的点击事件
			@Override
			public void onStart() {
				Intent intent = new Intent(GuidePageActivity.this,
						LoginActivity.class);
				intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
				SharedPreferences sharedPreferences = getSharedPreferences(
						"dp_guide", Context.MODE_PRIVATE);
				Editor editor = sharedPreferences.edit();
				editor.putBoolean("isFirstRun", false);
				editor.commit();
				startActivity(intent);
				finish();
			}
		});

	}

	/**
	 * 初始化底部小点
	 */
	private void initPoint() {
		// LinearLayout linearLayout = (LinearLayout) findViewById(R.id.ll);

		points = new ImageView[pics.length];

		// 循环取得小点图片
		for (int i = 0; i < pics.length; i++) {
			// 得到一个LinearLayout下面的每一个子元素
			// points[i] = (ImageView) linearLayout.getChildAt(i); 获取小点
			// 默认都设为灰色
			points[i].setEnabled(true);
			// 给每个小点设置监听
			points[i].setOnClickListener(this);
			// 设置位置tag，方便取出与当前位置对应
			points[i].setTag(i);
		}

		// 设置当面默认的位置
		currentIndex = 0;
		// 设置为白色，即选中状态
		points[currentIndex].setEnabled(false);
	}

	/**
	 * 当滑动状态改变时调用
	 */
	@Override
	public void onPageScrollStateChanged(int arg0) {

	}

	/**
	 * 当当前页面被滑动时调用
	 */

	@Override
	public void onPageScrolled(int arg0, float arg1, int arg2) {

	}

	/**
	 * 当新的页面被选中时调用
	 */

	@Override
	public void onPageSelected(int position) {
		// 设置底部小点选中状态
		// setCurDot(position);
		switch (position ) {
		case 0:
			((GuideViewOne) views.get(position)).setFirstShow(false);
			((GuideViewOne) views.get(position)).show();
			break;
		case 1:
			if (isGuideTwoFirstShow) {
				isGuideTwoFirstShow = false;
			} else {
				((GuideViewTwo) views.get(position)).setFirstShow(false);
			}
			((GuideViewTwo) views.get(position)).show();
			break;
		case 2:
			if (isGuideThreeFirstShow) {
				isGuideThreeFirstShow = false;
			} else {
				((GuideViewThree) views.get(position)).setFirstShow(false);
			}
			((GuideViewThree) views.get(position)).show();
			break;
		case 3:
			if (isGuideFourFirstShow) {
				isGuideFourFirstShow = false;
			} else {
				((GuideViewFour) views.get(position)).setFirstShow(false);
			}
			((GuideViewFour) views.get(position)).show();
			break;
		default:
			break;
		}

	}

	/**
	 * 通过点击事件来切换当前的页面
	 */
	@Override
	public void onClick(View v) {
		int position = (Integer) v.getTag();
		setCurView(position);
		// setCurDot(position);
	}

	/**
	 * 设置当前页面的位置
	 */
	private void setCurView(int position) {
		if (position < 0 || position >= pics.length) {
			return;
		}
		viewPager.setCurrentItem(position);
	}

	/**
	 * 设置当前的小点的位置
	 */
	private void setCurDot(int positon) {
		if (positon < 0 || positon > pics.length - 1 || currentIndex == positon) {
			return;
		}
		points[positon].setEnabled(false);
		points[currentIndex].setEnabled(true);

		currentIndex = positon;
	}
}
