package com.hp.halcyon.widgets.home;

import android.content.Context;
import android.util.AttributeSet;

import com.handmark.pulltorefresh.library.PullToRefreshBase;

public class PullToRefreshHomeView extends PullToRefreshBase<HomeView> {

	public PullToRefreshHomeView(Context context) {
		super(context,Mode.BOTH);
	}

	public PullToRefreshHomeView(Context context, AttributeSet attrs) {
		super(context, attrs);
		setMode(Mode.BOTH);
	}

	public PullToRefreshHomeView(Context context, Mode mode) {
		super(context, mode);
	}

	public PullToRefreshHomeView(Context context, Mode mode, AnimationStyle style) {
		super(context,Mode.BOTH, style);
	}

	@Override
	public final Orientation getPullToRefreshScrollDirection() {
		return Orientation.HORIZONTAL;
	}

	@Override
	protected HomeView createRefreshableView(Context context, AttributeSet attrs) {
		HomeView hListView;
		hListView = new HomeView(context);
		return hListView;
	}

	@Override
	protected boolean isReadyForPullStart() {
		return mRefreshableView.isReadyForPullStart();
	}

	@Override
	protected boolean isReadyForPullEnd() {
		return mRefreshableView.isReadyForPullEnd();
	}

}
