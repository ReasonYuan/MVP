package com.hp.halcyon.widgets.main;

import java.util.LinkedList;
import java.util.Queue;

import android.content.Context;
import android.graphics.Rect;
import android.widget.LinearLayout;

import com.hp.halcyon.widgets.main.FQBaseViewAdapter.FQBaseViewAdapterObserver;

public class FQListView extends FQScrollView implements FQBaseViewAdapterObserver {

	protected Queue<FQView> mRemoveQueue;
	protected FQView mFirstView;
	protected FQView mLastView;
	protected Rect mConmputeRect;
	protected int mSumChildHeight;
	protected FQBaseViewAdapter mAdapter;
	
	
	public FQListView(Context context) {
		super(context);
	}

	@Override
	protected void init(Context context, Rect frame) {
		super.init(context, frame);
		mClipsubviews = false;
		mRemoveQueue = new LinkedList<FQView>();
		mConmputeRect = new Rect();
	}

	
	@Override
	protected void onFrameChanged() {
		if (mFrame.width() == 0 || mFrame.height() == 0)
			return;
		resetChild();
	}

	@Override
	protected void onComputeScroll() {
		for (int i = 0; i < mChild.size(); i++) {
			mChild.get(i).onComputeScroll();
		}
	}

	private void computeScrollVertical(boolean finished){
		int currnetScrollY = -mScroller.getCurrY();
		do {
			int mWidth = getWidth();
			int mHeight = getHeight();
			mConmputeRect.set(0, currnetScrollY, mWidth, currnetScrollY + mHeight);
			if(mSumChildHeight < mHeight){
				mConmputeRect.set(0, currnetScrollY, mWidth, currnetScrollY + mSumChildHeight);
			}
			if (!mPressed && finished && mAdapter != null) {
				if (mFirstView != null && mConmputeRect.top != mFirstView.mFrame.top) {
					adjust();
				}
			}
			if (mFirstView == null || mLastView == null)
				break;
			if (mConmputeRect.top == mFirstView.mFrame.top) {
			}
			if (mFirstView.mFrame.top > mConmputeRect.top) {
				while (mFirstView.mFrame.top > mConmputeRect.top) {
					FQView child = mRemoveQueue.poll();
					child = mAdapter.getView(mFirstView.mPosition - 1, child, mWidth, mHeight);
					int childHeight = child.getHeight();
					int height = mFirstView.mFrame.top - childHeight;
					child.setFrame(0, height, mWidth, height + childHeight);
					addView(child);
					child.mPosition = mFirstView.mPosition - 1;
					mFirstView = child;
				}
			}
			if (mLastView.mFrame.bottom < mConmputeRect.bottom) {
				while (mLastView.mFrame.bottom < mConmputeRect.bottom) {
					FQView child = mRemoveQueue.poll();
					child = mAdapter.getView(mLastView.mPosition + 1, child, mWidth, mHeight);
					int childHeight = child.getHeight();
					int height = mLastView.mFrame.bottom;
					child.setFrame(0, height, mWidth, height + childHeight);
					addView(child);
					child.mPosition = mLastView.mPosition + 1;
					mLastView = child;
				}
			}
			FQView tmpFirst = null,tmpLast = null;
			for (int i = 0; i < mChild.size(); i++) {
				FQView child = mChild.get(i);
				if (!intersects(mConmputeRect, child.mFrame)) {
					child.mParent = null;
					mRemoveQueue.add(child);
				}else {
					if (contains(child.mFrame,0,mConmputeRect.top) && (tmpFirst == null || child.mFrame.top <= tmpFirst.mFrame.top)){
						tmpFirst = child;
					}
					if (contains(child.mFrame,0,mConmputeRect.bottom) && (tmpLast == null || child.mFrame.bottom >= tmpLast.mFrame.bottom)){
						tmpLast = child;
					}
				}
			}
			mChild.removeAll(mRemoveQueue);
			mFirstView = tmpFirst;
			mLastView = tmpLast;
		} while (false);
		super.computeScroll(finished);
	}
	
	private void computeScrollHorizontal(boolean finished){
		int currnetScrollX = -mScroller.getCurrX();
		do {
			int mWidth = getWidth();
			int mHeight = getHeight();
			mConmputeRect.set(currnetScrollX, 0, currnetScrollX+mWidth,mHeight);
			if(mSumChildHeight < mWidth){
				mConmputeRect.set(currnetScrollX, 0, currnetScrollX+mSumChildHeight,mHeight);
			}
			if (!mPressed && finished && mAdapter != null) {
				if (mFirstView != null && mConmputeRect.left != mFirstView.mFrame.left) {
					adjust();
				}
			}
			if (mFirstView == null || mLastView == null)
				break;
			if (mConmputeRect.left == mFirstView.mFrame.left) {
			}
			if (mFirstView.mFrame.left > mConmputeRect.left) {
				while (mFirstView.mFrame.left > mConmputeRect.left) {
					FQView child = mRemoveQueue.poll();
					child = mAdapter.getView(mFirstView.mPosition - 1, child, mWidth, mHeight);
					int childWidth = child.getWidth();
					int width = mFirstView.mFrame.left - childWidth;
					child.setFrame(width, 0, width + childWidth, mHeight);
					addView(child);
					child.mPosition = mFirstView.mPosition - 1;
					mFirstView = child;
				}
			}
			if (mLastView.mFrame.right < mConmputeRect.right) {
				while (mLastView.mFrame.right < mConmputeRect.right) {
					FQView child = mRemoveQueue.poll();
					child = mAdapter.getView(mLastView.mPosition + 1, child, mWidth, mHeight);
					int childWidth = child.getWidth();
					int width = mLastView.mFrame.right ;
					child.setFrame(width, 0, width + childWidth, mHeight);
					addView(child);
					child.mPosition = mLastView.mPosition + 1;
					mLastView = child;
				}
			}
			FQView tmpFirst = null,tmpLast = null;
			for (int i = 0; i < mChild.size(); i++) {
				FQView child = mChild.get(i);
				if (!intersects(mConmputeRect, child.mFrame)) {
					child.mParent = null;
					mRemoveQueue.add(child);
				}else {
					if (contains(child.mFrame,mConmputeRect.left,0) && (tmpFirst == null || child.mFrame.left <= tmpFirst.mFrame.left)){
						tmpFirst = child;
					}
					if (contains(child.mFrame,mConmputeRect.right,0) && (tmpLast == null || child.mFrame.right >= tmpLast.mFrame.right)){
						tmpLast = child;
					}
				}
			}
			mChild.removeAll(mRemoveQueue);
			mFirstView = tmpFirst;
			mLastView = tmpLast;
		} while (false);
		super.computeScroll(finished);
	}
	
	private static boolean contains(Rect r ,int x, int y) {
        return r.left < r.right && r.top < r.bottom && x >= r.left && x <= r.right && y >= r.top && y <= r.bottom;
     }
	
    public static boolean intersects(Rect a, Rect b) {
        return a.left < b.right && b.left < a.right && a.top < b.bottom && b.top < a.bottom;
    }
	
	@Override
	protected void computeScroll(boolean finished) {
		if(mOrientation == LinearLayout.VERTICAL){
			computeScrollVertical(finished);
		}else {
			computeScrollHorizontal(finished);
		}
		
	}

	protected void resetChild() {
		if (mFrame.width() == 0 || mFrame.height() == 0)
			return;
		mScroller.abortAnimation();
		mSumChildHeight = 0;
		int height = 0;
		boolean isFinished = false;
		int index = 0;
		for (int i = 0; i < mChild.size(); i++) {
			FQView child = mChild.get(i);
			mRemoveQueue.add(child);
			child.mParent = null;
		}
		if (mAdapter == null || mAdapter.getCount() == 0) {
			return;
		}
		for (int i = 0; i < mAdapter.getCount(); i++) {
			FQView view = mRemoveQueue.poll();
			view = mAdapter.getView(i, view, getWidth(), getHeight());
			if(mOrientation == LinearLayout.VERTICAL){
				mSumChildHeight += view.getHeight();
			}else {
				mSumChildHeight += view.getWidth();
			}
			view.mParent = null;
			mRemoveQueue.add(view);
		}
		mChild.clear();
		while (!isFinished) {
			if(index >= mAdapter.getCount()){
				isFinished = true;
				break;
			}
			FQView view = mRemoveQueue.poll();
			view = mAdapter.getView(index, view, getWidth(), getHeight());
			if(mOrientation == LinearLayout.VERTICAL){
				view.setFrame(0, height, mFrame.width(), height + view.getHeight());
				height += view.getHeight();
				if (height > mFrame.height()) {
					isFinished = true;
				}
			}else {
				view.setFrame(height, 0, view.getWidth()+height,mFrame.height());
				height += view.getWidth();
				if (height > mFrame.width()) {
					isFinished = true;
				}
			}
			
			addView(view);
			view.mPosition = index;
			mLastView = view;
			index++;
		}
		mFirstView = mChild.get(0);
	}

	public void setAdapter(FQBaseViewAdapter adapter) {
		mAdapter = adapter;
		mAdapter.registerObserver(this);
		resetChild();
	}

	@Override
	public void onDataSetChanged() {
		resetChild();
		mScroller.abortAnimation();
		mScroller.setFinalX(mScroller.getCurrX());
		mScroller.setFinalY(mScroller.getCurrY());
		invalidate();
	}
	
	@Override
	protected int getMax() {
		if(mOrientation == LinearLayout.VERTICAL){
			if(mSumChildHeight <= getHeight()) return 0;
			return mSumChildHeight - getHeight();
		}else {
			if(mSumChildHeight <= getWidth()) return 0;
			return mSumChildHeight - getWidth();
		}
	}
	
}