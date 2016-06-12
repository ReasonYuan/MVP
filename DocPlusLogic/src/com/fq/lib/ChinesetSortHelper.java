package com.fq.lib;

import java.util.Comparator;

import com.fq.lib.pinyin4j.BadHanyuPinyinOutputFormatCombination;
import com.fq.lib.pinyin4j.HanyuPinyinCaseType;
import com.fq.lib.pinyin4j.HanyuPinyinOutputFormat;
import com.fq.lib.pinyin4j.HanyuPinyinToneType;
import com.fq.lib.pinyin4j.HanyuPinyinVCharType;
import com.fq.lib.pinyin4j.PinyinHelper;

public class ChinesetSortHelper {

	/**
	 * 将字符串中的中文转化为拼音,其他字符不变
	 * 
	 * @param inputString
	 * @return
	 */
	public static String getPingYin(String inputString) {
		HanyuPinyinOutputFormat format = new HanyuPinyinOutputFormat();
		format.setCaseType(HanyuPinyinCaseType.UPPERCASE);
		format.setToneType(HanyuPinyinToneType.WITHOUT_TONE);
		format.setVCharType(HanyuPinyinVCharType.WITH_V);

		char[] input = inputString.trim().toCharArray();
		String output = "";

		try {
			for (int i = 0; i < input.length; i++) {
				if (java.lang.Character.toString(input[i]).matches(
						"[\\u4E00-\\u9FA5]+")) {
					String[] temp = PinyinHelper.toHanyuPinyinStringArray(input[i], format);
					if(temp != null && temp.length > 0){
						output += temp[0];
					}
				} else
					output += java.lang.Character.toString(input[i]);
			}
		} catch (BadHanyuPinyinOutputFormatCombination e) {
			e.printStackTrace();
		}
		return output;
	}

	/**
	 * 汉字转换为汉语拼音首字母，英文字符不变
	 * 
	 * @param chines
	 *            汉字
	 * @return 拼音
	 */
	public static String converterToFirstSpell(String chines) {
		String pinyinName = "";
		char[] nameChar = chines.toCharArray();
		HanyuPinyinOutputFormat defaultFormat = new HanyuPinyinOutputFormat();
		defaultFormat.setCaseType(HanyuPinyinCaseType.UPPERCASE);
		defaultFormat.setToneType(HanyuPinyinToneType.WITHOUT_TONE);
		for (int i = 0; i < nameChar.length; i++) {
			if (nameChar[i] > 128) {
				try {
					pinyinName += PinyinHelper.toHanyuPinyinStringArray(
							nameChar[i], defaultFormat)[0].charAt(0);
				} catch (BadHanyuPinyinOutputFormatCombination e) {
					e.printStackTrace();
				}
			} else {
				pinyinName += nameChar[i];
			}
		}
		return pinyinName;
	}

	/**
	 * 得到汉字转拼音后的第一个字母
	 * 
	 * @param chines
	 *            汉字
	 * @return 拼音
	 */
	public static String getFirstSpell(String chines) {
		String pinyinName = "";
		char firstChar = chines.toCharArray()[0];
		HanyuPinyinOutputFormat defaultFormat = new HanyuPinyinOutputFormat();
		defaultFormat.setCaseType(HanyuPinyinCaseType.UPPERCASE);
		defaultFormat.setToneType(HanyuPinyinToneType.WITHOUT_TONE);

		if (firstChar > 128) {
			try {
				pinyinName = PinyinHelper.toHanyuPinyinStringArray(firstChar,
						defaultFormat)[0].substring(0, 1);
			} catch (BadHanyuPinyinOutputFormatCombination e) {
				e.printStackTrace();
			}
		} else {
			pinyinName = String.valueOf(firstChar);
		}
		return pinyinName;
	}

	public static class PinyinComparator implements Comparator<Object> {
		public int compare(Object o1, Object o2) {
			String str1 = ChinesetSortHelper.getPingYin((String) o1);
			String str2 = ChinesetSortHelper.getPingYin((String) o2);
			return str1.compareTo(str2);
		}
	}
}
