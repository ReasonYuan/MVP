package com.fq.lib.tools;

import java.util.Comparator;

public class StrDataComparator implements Comparator<String>{
	@Override
	public int compare(String arg0, String arg1) {
		return -(arg0.compareTo(arg1));
	}
}
