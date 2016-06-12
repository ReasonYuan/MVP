package com.fq.lib.tools;

import java.io.Serializable;

public class Data implements Serializable {
	private static final long serialVersionUID = 1L;
	public String mLocalJson;

	@Override
	public String toString() {
		return mLocalJson;
	}
}