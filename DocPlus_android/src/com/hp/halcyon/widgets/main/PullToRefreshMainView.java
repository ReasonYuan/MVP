package com.hp.halcyon.widgets.main;

import android.content.Context;
import android.util.AttributeSet;

import com.handmark.pulltorefresh.library.PullToRefreshBase;

public class PullToRefreshMainView extends PullToRefreshBase<MainView2> {

	public PullToRefreshMainView(Context context) {
		super(context,Mode.BOTH);
	}

	public PullToRefreshMainView(Context context, AttributeSet attrs) {
		super(context, attrs);
		setMode(Mode.BOTH);
	}

	public PullToRefreshMainView(Context context, Mode mode) {
		super(context, mode);
	}

	public PullToRefreshMainView(Context context, Mode mode, AnimationStyle style) {
		super(context,Mode.BOTH, style);
	}

	@Override
	public final Orientation getPullToRefreshScrollDirection() {
		return Orientation.HORIZONTAL;
	}

	@Override
	protected MainView2 createRefreshableView(Context context, AttributeSet attrs) {
		MainView2 hListView;
		hListView = new MainView2(context);
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
