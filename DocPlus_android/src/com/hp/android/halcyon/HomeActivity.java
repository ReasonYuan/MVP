package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationUtils;
import android.view.animation.TranslateAnimation;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.HomeOneDayData;
import com.fq.halcyon.logic2.DoctorHomeLogic;
import com.fq.halcyon.logic2.DoctorHomeLogic.OnDoctorHomeCallback;
import com.fq.halcyon.logic2.HomeMessageLogic;
import com.fq.halcyon.logic2.HomeMessageLogic.HomeMessageLogicInterface;
import com.fq.http.potocol.HttpRequestPotocol;
import com.fq.lib.callback.ICallback;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.TimeFormatUtils;
import com.fq.library.CustomView.CustomTextView;
import com.fq.library.SlidingDrawer.MultiDirectionSlidingDrawer;
import com.fq.library.SlidingDrawer.MultiDirectionSlidingDrawer.OnDrawerCloseListener;
import com.fq.library.SlidingDrawer.MultiDirectionSlidingDrawer.OnDrawerOpenListener;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshBase.Mode;
import com.handmark.pulltorefresh.library.PullToRefreshBase.OnRefreshListener2;
import com.hp.android.halcyon.adapter.HomeMainAdapter;
import com.hp.android.halcyon.adapter.HomeMainAdapter.OnMonthViewClickListener;
import com.hp.android.halcyon.util.BaiDuTJSDk;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.view.AddTimerRecordView;
import com.hp.android.halcyon.view.CloseView;
import com.hp.android.halcyon.view.HomeRightMenu;
import com.hp.android.halcyon.widgets.FastBlur;
import com.hp.halcyon.widgets.home.HomeView;
import com.hp.halcyon.widgets.home.HomeView.ScrollAligment;
import com.hp.halcyon.widgets.home.HomeViewLayout;
import com.hp.halcyon.widgets.home.HorizontalListView.OnScrollStateChangedListener;
import com.hp.halcyon.widgets.home.PullToRefreshHomeView;
import com.hp.halcyon.widgets.main.FQViewGroup.GestureListener;
import com.hp.halcyon.widgets.main.MainFrameLayout;
import com.hp.halcyon.widgets.main.SelectMainTimeView;
import com.hp.halcyon.widgets.main.SelectMainTimeView.OnSelectTimeListener;

public class HomeActivity extends Activity implements OnClickListener, OnDoctorHomeCallback, OnMonthViewClickListener, OnSelectTimeListener {

	public static final int ANIMATION_TIME = 800;

	protected static boolean mIsFirstLoading;

	private HomeRightMenu mHomeMenu;
	private AddTimerRecordView mAddNewView;
	private HomeView mMainView;
	private PullToRefreshHomeView mPullToRefreshMainView;
	private HomeMainAdapter mAdapter;

	private View mHomeMain;
	private View mContentView;
	private ImageView mImgMarks;
	private View mUnReadView;
	private View mTodayView;

	private DoctorHomeLogic mLogic;

	private SelectMainTimeView mSelectMainTimeView;
	private View mSelectMonthView;
	private CloseView view;
	private Handler mHandler;
	private float mOffsetY;
	private boolean mUpOffseted = false;
	private float mSumOffsetX, mSumOffsetY;
	private boolean mCalculateDirection = false;
	private MainFrameLayout mFrameLayout;
	private HomeViewLayout mHomeViewLayout;

	/**
	 * 有数据的月份
	 */
	private Map<Integer, ArrayList<Integer>> mMonth;

	/**
	 * 首页抽屉slidingdrawer
	 */
	private MultiDirectionSlidingDrawer multiDirectionSlidingDrawer;

	private LinearLayout mMultiDirectionSlidingDrawerContent;

	/**
	 * 首页提示消息
	 */
	private FrameLayout mHomeMessageTittle;

	private com.fq.library.CustomView.CustomTextView mMessageTv;

	private HttpRequestPotocol mRequest;

	private Calendar mSlectCalendar;

	private GestureDetector mGestureDetector;

	public static MyOnGestureListener mGestureListener;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		mHandler = new Handler();
		mGestureListener = new MyOnGestureListener();
		mGestureDetector = new GestureDetector(this, mGestureListener);
		setContentView(R.layout.activity_home);
		mPullToRefreshMainView = (PullToRefreshHomeView) findViewById(R.id.pull_refresh_view);
		mPullToRefreshMainView.setMode(Mode.PULL_FROM_START);
		mAddNewView = new AddTimerRecordView(this);
		mFrameLayout = (MainFrameLayout) findViewById(R.id.fl_home_main);
		mPullToRefreshMainView.setOnRefreshListener(new OnRefreshListener2<HomeView>() {
			@Override
			public void onPullDownToRefresh(PullToRefreshBase<HomeView> refreshView) {
				long firstDate = mAdapter.getFirstDate();
				if (firstDate < getMinMonthTime()) {
					UITools.showToast("没有更多的数据");
					mPullToRefreshMainView.onRefreshComplete();
					return;
				}
				mRequest = mLogic.requestPatients(firstDate, 60, 0, HomeActivity.this);
				mHandler.postDelayed(new Runnable() {

					@Override
					public void run() {
						if (mPullToRefreshMainView.isRefreshing()) {
							if (mRequest != null)
								mRequest.cancel();
							mPullToRefreshMainView.onRefreshComplete();
							UITools.showToast("链接超时");
						}
					}
				}, 10000);
			}

			@Override
			public void onPullUpToRefresh(PullToRefreshBase<HomeView> refreshView) {
				long lastDate = mAdapter.getLastDate();
				mRequest = mLogic.requestPatients(lastDate, 0, 60, HomeActivity.this);
				mHandler.postDelayed(new Runnable() {

					@Override
					public void run() {
						if (mPullToRefreshMainView.isRefreshing()) {
							if (mRequest != null)
								mRequest.cancel();
							mPullToRefreshMainView.onRefreshComplete();
							UITools.showToast("链接超时");
						}
					}
				}, 10000);
			}

		});

		mHomeMain = mFrameLayout;
		mImgMarks = (ImageView) findViewById(R.id.iv_home_marks);
		mContentView = findViewById(R.id.ll_home_content);
		mTodayView = findViewById(R.id.iv_home_to_today);

		mUnReadView = findViewById(R.id.ll_home_unread);
		mHomeMenu = new HomeRightMenu(this, (ViewGroup) findViewById(R.id.view_home_right_menu));
		findViewById(R.id.btn_home_test_menu).setOnClickListener(this);
		findViewById(R.id.btn_home_arrow_right_red).setOnClickListener(this);
		findViewById(R.id.btn_home_new_record).setOnClickListener(this);
		findViewById(R.id.btn_home_new_timer).setOnClickListener(this);

		/**
		 * 将菜单栏加入抽屉
		 */
		mMultiDirectionSlidingDrawerContent = (LinearLayout) findViewById(R.id.content);
		multiDirectionSlidingDrawer = (MultiDirectionSlidingDrawer) findViewById(R.id.drawer);
		mMultiDirectionSlidingDrawerContent.addView(mHomeMenu.getView());
		final ImageView ImageBtn = (ImageView) findViewById(R.id.handle_btn);
		mMultiDirectionSlidingDrawerContent.setOnTouchListener(new OnTouchListener() {

			@Override
			public boolean onTouch(View v, MotionEvent event) {
				return true;
			}
		});

		multiDirectionSlidingDrawer.setOnDrawerCloseListener(new OnDrawerCloseListener() {

			@Override
			public void onDrawerClosed() {
				ImageBtn.setSelected(false);
			}
		});

		multiDirectionSlidingDrawer.setOnDrawerOpenListener(new OnDrawerOpenListener() {

			@Override
			public void onDrawerOpened() {
				ImageBtn.setSelected(true);
			}
		});

		mHomeMessageTittle = (FrameLayout) findViewById(R.id.home_message);
		mMessageTv = (com.fq.library.CustomView.CustomTextView) findViewById(R.id.tv_message);

		mMainView = mPullToRefreshMainView.getRefreshableView();
		mAdapter = new HomeMainAdapter(mMainView);
		mMainView.setAdapter(mAdapter);
		mMainView.setItemClickListener(mAdapter);
		mAdapter.setOnMonthViewClickListener(this);

		mLogic = new DoctorHomeLogic();
		mLogic.requestPatientMonth(this);
		showOnLoginAnimation();
		mMainView.setOnScrollStateChangedListener(new OnScrollStateChangedListener() {

			@Override
			public void onScrollStateChanged(ScrollState scrollState) {
				if (scrollState == ScrollState.SCROLL_STATE_IDLE) {
					int today = mAdapter.getCurrentDayIndex();
					if (today == -2) {
						showToadyButton(View.GONE);
					} else {
						showToadyButton(mMainView.isInCenter(today)? View.GONE : View.VISIBLE);
					}
				}
			}
		});
		mHomeViewLayout = (HomeViewLayout) findViewById(R.id.hl_home);
		mHomeViewLayout.setGestureListener(mGestureDetector, mGestureListener);
		
		if(mIsFirstLoading){
			final View view = findViewById(R.id.ll_home_teacher_container); 
			view.setVisibility(View.VISIBLE);
			findViewById(R.id.ll_home_teacher_out).setOnClickListener(new OnClickListener() {
				public void onClick(View v) {
					view.setClickable(false);
					view.setVisibility(View.GONE);
					Animation animation = AnimationUtils.loadAnimation(HomeActivity.this, R.anim.fade_out);
					animation.setDuration(400);
					animation.setFillAfter(true);
					view.startAnimation(animation);
				}
			});
			findViewById(R.id.ll_home_teacher_in).setOnClickListener(new OnClickListener() {
				public void onClick(View v) {
					view.setClickable(false);
					Intent intent = new Intent(HomeActivity.this, TeacherActivity.class);
					startActivity(intent);
					view.setVisibility(View.GONE);
				}
			});
		}
	}

	/**
	 * 获取动态消息
	 */
	private void getDynamicMessage() {
		if (mIsFirstLoading) {
			mIsFirstLoading = false;
			ArrayList<String> mMessageList = new ArrayList<String>();
			mMessageList.add("欢迎使用医加，助力好医生 Solution For Life!");
			mMessageTv.setDirection(CustomTextView.DIRECTION_RIGHT_TO_LEFT);
			mMessageTv.initText(mMessageList, mHomeMessageTittle);
		} else {
			HomeMessageLogic mHomeMessageLogic = new HomeMessageLogic(new HomeMessageLogicInterface() {
				@Override
				public void onError(int code, Throwable error) {
					FQLog.i("获取动态消息出错！");
				}

				@Override
				public void onHomeMessageDataReturn(ArrayList<String> messageList) {
					/*
					 * 测试使用数据 ArrayList<String> nList = new ArrayList<String>();
					 * nList.add("第一条第一条都咿呀ioada"); nList.add("第2条第2条都咿呀ioada");
					 * nList.add("第3条第3条都咿呀ioada"); nList.add("第4条第4条都咿呀ioada");
					 * nList.add("第5条第5条都咿呀ioada");
					 */
					mMessageTv.setDirection(CustomTextView.DIRECTION_RIGHT_TO_LEFT);
					mMessageTv.initText(messageList, mHomeMessageTittle);
				}

				@Override
				public void onHomeMessageDataError(int responseCode, String msg) {
					FQLog.i("获取动态消息出错！");
				}
			});
			mHomeMessageLogic.getMessages();
		}

	}

	/**
	 * 登陆后主页时间轴除头像外的元素淡入淡出,时间为500毫秒，之后头像出现方式为缩放，时间为500毫秒
	 */
	private void showOnLoginAnimation() {
		Animation animation = new AlphaAnimation(0.1f, 1);
		// 主页登陆后淡入淡出的时间
		animation.setDuration(2000);
		animation.setAnimationListener(new AnimationListener() {
			@Override
			public void onAnimationStart(Animation arg0) {
			}

			@Override
			public void onAnimationRepeat(Animation arg0) {
			}

			@Override
			public void onAnimationEnd(Animation arg0) {
				mAdapter.setShouldScaleInHeadIcon(false);
			}
		});
		mFrameLayout.startAnimation(animation);
	}

	protected long getMinMonthTime() {
		// 初始化没有网络数据时mMonth = null, 所以需判断一下
		if (mMonth == null || mMonth.isEmpty())
			return new Date().getTime();
		Iterator<Integer> keys = mMonth.keySet().iterator();
		int year = 0;
		while (keys.hasNext()) {
			int key = (Integer) keys.next();
			if (year == 0 || key < year) {
				year = key;
			}
		}
		ArrayList<Integer> monthArray = mMonth.get(year);
		int month = 0;
		for (int i = 0; i < monthArray.size(); i++) {
			int tmp = monthArray.get(i);
			if (month == 0 || month > tmp) {
				month = tmp;
			}
		}
		Calendar calendar = Calendar.getInstance();
		calendar.set(year, month - 1, 0);
		return calendar.getTimeInMillis();
	}

	@Override
	protected void onResume() {
		super.onResume();
		BaiDuTJSDk.onResume(this);
		getDynamicMessage();
		mHomeMenu.onResume();
		if (mAdapter.getFirstDate() != 0) {
			if(mAdapter.getCount() > 150){//数据量过大，从新回回到当前天
				mLogic.requestPatients(System.currentTimeMillis(), this); 
			}else{
				mLogic.requestPatients(mAdapter.getFirstDate(), 0, mAdapter.getCount(), this);
			}
		} else {
			mLogic.requestPatients(System.currentTimeMillis(), this);
		}
	}

	public void stop() {
		TranslateAnimation tran = new TranslateAnimation(Animation.RELATIVE_TO_SELF, 0, Animation.RELATIVE_TO_SELF, -0.3F, 1, Animation.RELATIVE_TO_SELF, 1, Animation.RELATIVE_TO_SELF);
		tran.setDuration(150);
		mHomeMain.startAnimation(tran);
	}

	@Override
	protected void onPause() {
		super.onPause();
		BaiDuTJSDk.onPause(this);
	}
	
	@Override
	protected void onStop() {
		super.onStop();
	}

	public void onTopRightBtnClick(View view) {
		// if(mAddNewView != null && mAddNewView.isShow()) {
		// mAddNewView.dismiss();;
		// }
		// mAddNewView.show((ViewGroup) mHomeMain);
		Intent mIntent = new Intent();
		mIntent.setClass(HomeActivity.this, FollowUpActivity.class);
		startActivity(mIntent);
	}

	public void onNoReadDataClick(View v) {
		// int id = mAdapter.findUnreaderIndex();
		// mAdapter.scrollToIndex(id);
	}

	public void onCloudRecord(View v) {
		startActivity(new Intent(this, PatientListActivity.class));
	}

	public void setUnReadVisibility(final int visibility) {
		mUnReadView.setVisibility(visibility);
	}

	private long lastCloseTime;

	@Override
	public void onBackPressed() {

		if (mAddNewView.isShow()) {
			mAddNewView.dismiss();
			return;
		}
		if (mHomeMenu.isShow()) {
			// mHomeMenu.dismiss();
			multiDirectionSlidingDrawer.animateToggle();
			return;
		}
		if (mSelectMainTimeView != null && mSelectMainTimeView.isShown()) {
			onCloseBtnClick(null);
			return;
		}

		if (System.currentTimeMillis() - lastCloseTime > 2000) {
			UITools.showToast("再按一次退出");
			lastCloseTime = System.currentTimeMillis();
			return;
		}
		super.onBackPressed();
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_home_test_menu:
		case R.id.btn_home_arrow_right_red:
			// btn_home_test_menu为加大的点击区域，btn_home_arrow_right_red为实际的按钮点击区域
			mHomeMenu.showChange();
			break;
		case R.id.btn_home_new_record:
			startActivity(new Intent(this, UploadStateActivity.class));
			break;
		case R.id.btn_home_new_timer:
			mAddNewView.newTimer();
			break;
		}
	}

	public void blur() {
		AlphaAnimation alpha = new AlphaAnimation(0, 1);
		alpha.setDuration(ANIMATION_TIME);
		Bitmap bmp = FastBlur.doBlurBitmap(mFrameLayout.getBitmap(), true);
		mImgMarks.setImageBitmap(bmp);
		alpha.setFillAfter(true);
		mImgMarks.startAnimation(alpha);
		mImgMarks.setVisibility(View.VISIBLE);
		mImgMarks.setClickable(true);
	}

	public void unblur() {
		AlphaAnimation alpha = new AlphaAnimation(1, 0);
		alpha.setDuration(ANIMATION_TIME);
		alpha.setFillAfter(true);
		mImgMarks.startAnimation(alpha);
		mImgMarks.setVisibility(View.GONE);
		mImgMarks.setClickable(false);
	}

	private void reSet(final ICallback callback) {
		Runnable runnable = new Runnable() {
			@Override
			public void run() {
				if (mContentView.getScrollY() != 0) {
					int y = mContentView.getScrollY();
					int speed = UITools.dip2px(15);
					if (y < 0) {
						if (y + speed >= 0) {
							doTrans(y);
						} else {
							doTrans(-speed);
						}
					} else {
						if (y - speed <= 0) {
							doTrans(y);
						} else {
							doTrans(speed);
						}
					}
					mHandler.postDelayed(this, (long) (1000 / 60.f));
				} else {
					if (callback != null) {
						callback.doCallback(null);
					}
				}
			}
		};
		mHandler.post(runnable);
		mUpOffseted = false;
	}

	private void doTrans(float offsetY) {
		mContentView.scrollBy(0, (int) -offsetY);
	}

	private void doTransTo(float offsetY) {
		mContentView.scrollTo(0, (int) offsetY);
	}

	public class MyOnGestureListener extends GestureListener {

		private float mBeginTrans;// mKeyDownPointY
		private float mLastPointY;

		@Override
		public boolean onSingleTapUp(MotionEvent e) {
			return false;
		}

		@Override
		public void onLongPress(MotionEvent e) {
		}

		@Override
		public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
			mSumOffsetX += distanceX;
			mSumOffsetY += distanceY;
			if (!mCalculateDirection) {
				int fiveDP = UITools.dip2px(5);
				float absX = Math.abs(mSumOffsetX);
				float absY = Math.abs(mSumOffsetY);
				if (absX > fiveDP || absY > fiveDP) {
					mCalculateDirection = true;
					if (absX > absY) {
						mUpOffseted = false;
					} else {
						mUpOffseted = true;
					}
				}
			}
			/*
			 * if (mPullToRefreshMainView.getMode() != Mode.BOTH &&distanceX >
			 * 50 && Math.abs(distanceX) > Math.abs(distanceY) &&
			 * !mHomeMenu.isShow() && mMainView.isReadyForPullEnd()) {
			 * mHomeMenu.show(); }
			 */
			return false;
		}

		@Override
		public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
			return false;
		}

		@Override
		public void onShowPress(MotionEvent e) {
		}

		public boolean onDown(MotionEvent e) {
			mCalculateDirection = false;
			mSumOffsetX = 0;
			mSumOffsetY = 0;
			mOffsetY = 0;
			return true;
		}

		@Override
		public boolean onMove(MotionEvent e) {
			if (mUpOffseted) {
				float currenY = e.getRawY();
				if (currenY > mBeginTrans) {
					return super.onMove(e);
				}
				mLastPointY = currenY;
				mOffsetY = currenY - mBeginTrans;
				doTransTo(-mOffsetY);
				int border = mMainView.getHeight() * 2 / 5;
				if (mOffsetY <= -border) {
					// 显示close
					reSet(new ICallback() {
						@Override
						public void doCallback(Object obj) {
							if (view == null || !view.isShown()) {
								view = new CloseView(HomeActivity.this);
								((ViewGroup) mHomeMain).addView(view);
								view.scrollToBottom();
							}
						}
					});
				} else if (mOffsetY >= border) {
				}
			} else {
				mBeginTrans = mLastPointY = e.getRawY();

			}
			return true;
		}

		@Override
		public boolean onUp(MotionEvent e) {
			reSet(null);
			mCalculateDirection = false;
			mSumOffsetX = 0;
			mSumOffsetY = 0;
			return super.onUp(e);
		}

		@Override
		public boolean canScroll() {
			if( mContentView.getScrollY() != 0) return false;
			if (mCalculateDirection) {
				return !mUpOffseted;
			} else {
				return false;
			}
		}
		
		public boolean canFling() {
			return mContentView.getScrollY() == 0;
		}

		@Override
		public boolean onDoubleTap(MotionEvent e) {
			return false;
		}

		@Override
		public boolean onDoubleTapEvent(MotionEvent e) {
			// e.getAction());
			return false;
		}

		@Override
		public boolean onSingleTapConfirmed(MotionEvent e) {
			// "onSingleTapConfirmed-----" + e.getAction());
			return false;
		}
	}

	@Override
	public void error(String msg) {
		UITools.showToast(msg);
	}

	@Override
	public void errorMonth(String msg) {
		UITools.showToast(msg);
	}

	@Override
	public void feedMonth(Map<Integer, ArrayList<Integer>> month) {
		mMonth = month;
	}

	public void onCloseBtnClick(View v) {
		if (mSelectMainTimeView != null && mSelectMainTimeView.isShown()) {
			mSelectMainTimeView.fadeOut(new ICallback() {
				public void doCallback(Object obj) {
					((ViewGroup) mHomeMain).removeView(mSelectMonthView);
					mSelectMonthView = null;
					mSelectMainTimeView = null;
				}
			});
			unblur();
			return;
		}
	}

	public void onBack2Today(View v) {
		int index = mAdapter.getCurrentDayIndex();
		if (index != -1) {
			mMainView.scrollTo(index, true);
			showToadyButton(View.GONE);
		}else{
			mSlectCalendar = Calendar.getInstance();
			mSlectCalendar.setTimeInMillis(System.currentTimeMillis());
			mLogic.requestPatients(System.currentTimeMillis(), this);
		}
	}

	private void showToadyButton(int visible) {
		int v = mTodayView.getVisibility();
		if (v == visible)
			return;

		Animation animation = null;
		if (visible == View.GONE) {
			animation = AnimationUtils.loadAnimation(this, R.anim.scale_alpha_out);
		} else {
			animation = AnimationUtils.loadAnimation(this, R.anim.scale_alpha_in);
		}
		mTodayView.setVisibility(visible);
		mTodayView.startAnimation(animation);
	}

	@Override
	public void onSelectTime(String time, String format) {
		if (mSelectMainTimeView == null)
			return;
		final Date currDate = TimeFormatUtils.getDate4Str(time, format);
		unblur();
		final Calendar cal = TimeFormatUtils.getCalendar4Str(time, format);
		// final int month = currDate.getMonth();

		mSelectMainTimeView.fadeOut(new ICallback() {
			public void doCallback(Object obj) {
				int index = mAdapter.getFirstDayIndexInMonth(cal);// month
				if (index == -1) {
					mSlectCalendar = cal;
					mLogic.requestPatients(cal.getTimeInMillis(), HomeActivity.this);
				} else {
					mMainView.scrollTo(index, ScrollAligment.LEFT, true);
				}
				((ViewGroup) mHomeMain).removeView(mSelectMonthView);
				mSelectMonthView = null;
				mSelectMainTimeView = null;
			}
		});
	}

	@Override
	public void feedHomeDatas(ArrayList<HomeOneDayData> datas) {
		if (mPullToRefreshMainView.isRefreshing()) {
			mPullToRefreshMainView.onRefreshComplete();
			mAdapter.appendData(datas);
		} else {
			mAdapter.setData(datas);
			onBack2Today(null);
		}
		if (mAdapter.getLastDate() < new Date().getTime()) {
			mPullToRefreshMainView.setMode(Mode.BOTH);
		} else {
			mPullToRefreshMainView.setMode(Mode.PULL_FROM_START);
		}

		if (mSlectCalendar != null) {
			int index = mAdapter.getFirstDayIndexInMonth(mSlectCalendar);
			if (index != -1) {
				Calendar calendar = Calendar.getInstance();
				if(calendar.get(Calendar.DAY_OF_YEAR) == mSlectCalendar.get(Calendar.DAY_OF_YEAR) && calendar.get(Calendar.YEAR) == mSlectCalendar.get(Calendar.YEAR)){ //当天
					int current = mAdapter.getCurrendIndex();
					if(current > 0){
						mMainView.scrollTo(current, ScrollAligment.CENTER, true);
					}
				}else{
					mMainView.scrollTo(index, ScrollAligment.LEFT, true);
				}
				return;
			}
			mSlectCalendar = null;
		}
	}

	@Override
	public void onMonthTitleClick() {
		if(mSelectMonthView != null) return;
		if (mMonth == null)
			mMonth = new HashMap<Integer, ArrayList<Integer>>();
		if (mMonth.size() == 0) {
			Calendar cal = Calendar.getInstance();
			int year = cal.get(Calendar.YEAR);
			mMonth.put(year, new ArrayList<Integer>());
		}
		blur();
		mSelectMonthView = getLayoutInflater().inflate(R.layout.view_select_time_month, null);
		((ViewGroup) mHomeMain).addView(mSelectMonthView);
		mSelectMainTimeView = new SelectMainTimeView(HomeActivity.this);
		mSelectMainTimeView.setData(mMonth);
		mSelectMainTimeView.setOnSelectTimeListener(HomeActivity.this);
		FrameLayout layout = (FrameLayout) mSelectMonthView.findViewById(R.id.fl_parent_container);
		layout.addView(mSelectMainTimeView);
		AlphaAnimation animation = new AlphaAnimation(0, 255);
		animation.setDuration(300);
		layout.startAnimation(animation);
	}
}
