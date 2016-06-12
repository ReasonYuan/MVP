package com.fq.halcyon;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;

public abstract class SequenceHandel {

	/**
	 * handle a element if the sequence no't null， then element will be remove
	 * form sequence after this function
	 * 
	 * @param element
	 */
	public abstract void onHandle(Object element);

	ArrayList<Object> mSequence;
	private String filePath;

	/**
	 * 
	 * @param path
	 *            the path use to save sequence if path no't null
	 */
	public SequenceHandel(String path) {
		mSequence = new ArrayList<Object>();
		filePath = path;
		if(filePath != null){
			ObjectInputStream ois = null;
			try {
				File dataFile = new File(filePath);
				 ois = new ObjectInputStream(new FileInputStream(dataFile));
				 ois.readObject();
			} catch (Exception e) {
				e.printStackTrace();
			}finally{
				try {
					 ois.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}

	/**
	 * push a element to sequence if sequence no't contains element
	 * 
	 * @param element
	 */
	public void push(Object element) {
		if (element != null && !mSequence.contains(element)) {
			mSequence.add(element);
			save();
		}
	}

	public Object pop() {
		if (!mSequence.isEmpty())
			return mSequence.remove(0);
		return null;
	}

	private void save() {
		if (filePath != null) {
			ObjectOutputStream oos = null;
			try {
				File dataFile = new File(filePath);
				oos = new ObjectOutputStream(new FileOutputStream(dataFile));
				oos.writeObject(mSequence);
			} catch (Exception e) {
				e.printStackTrace();
			}finally{
				try {
					oos.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
