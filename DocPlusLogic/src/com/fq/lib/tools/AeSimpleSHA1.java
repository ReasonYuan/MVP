package com.fq.lib.tools;

import com.fq.lib.platform.Platform;

public class AeSimpleSHA1 {
	
	public static String SHA1(String text) {
		return Platform.getInstance().SHA1(text);
	}
	
	public static String repeat20Times(String text){
		String str = "";
		for (int i = 0; i < 20; i++) {
			str = str + text;
		}
		return str;
	}
	
	/**
	 * 把明文重复20次再取sha1摘要
	 * @param text
	 * @return
	 */
	public static String repeat20TimesAndSHA1(String text){
		return SHA1(repeat20Times(text));
	}
}