package com.fq.http.async.uploadloop;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * 
 * 实现线程安全的循环队列
 * 
 * @author liaomin
 * @param <T>
 */
public class FQLoopQueue<T> implements Serializable {
	private static final long serialVersionUID = 1L;

	private ArrayList<T> mData;

	private Object mLock;

	private int mCurrentIndex;

	public FQLoopQueue() {
		mLock = new Object();
		mData = new ArrayList<T>();
		mCurrentIndex = 0;
	}

	public void add(T object) {
		if (object != null) {
			synchronized (mLock) {
				mData.add(object);
			}
		}
	}

	/**
	 * @return nextValue or null if then quene is empty
	 */
	public T getNext() {
		synchronized (mLock) {
			int size = mData.size();
			if (mData.size() > 0) {
				T data = mData.get(mCurrentIndex++);
				if (mCurrentIndex == size)
					mCurrentIndex = 0;
				return data;
			}
		}
		return null;
	}
	

	public T remove(int index) {
		synchronized (mLock) {
			T data = mData.remove(index);
			if (mCurrentIndex > 0 && mCurrentIndex >= index) {
				mCurrentIndex--;
			}
			if (mCurrentIndex == mData.size())
				mCurrentIndex = 0;
			return data;
		}
	}

	public boolean remove(Object object) {
		int index = mData.indexOf(object);
		if (index >= 0) {
			synchronized (mLock) {
				boolean success = mData.remove(object);
				if (mCurrentIndex > 0 && mCurrentIndex >= index) {
					mCurrentIndex--;
				}
				if (mCurrentIndex == mData.size())
					mCurrentIndex = 0;
				return success;
			}
		}
		return false;
	}

	public int size() {
		return mData.size();
	}

	public boolean isEmpty() {
		return mData.isEmpty();
	}
	
	public ArrayList<T> getAll(){
		return mData;
	}
}
