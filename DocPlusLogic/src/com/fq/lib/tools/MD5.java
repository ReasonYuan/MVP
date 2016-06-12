package com.fq.lib.tools;


public class MD5 {
	
	//ios找不到MessageDigest对应的方法，使用sha1加密
	public static String Md5(String plainText) {
//		StringBuffer buf = new StringBuffer("");
//		try {
//			MessageDigest md = MessageDigest.getInstance("MD5");
//			md.update(plainText.getBytes());
//			byte b[] = md.digest();
//
//			int i;
//
//			for (int offset = 0; offset < b.length; offset++) {
//				i = b[offset];
//				if (i < 0)
//					i += 256;
//				if (i < 16)
//					buf.append("0");
//				buf.append(Integer.toHexString(i));
//			}
//			//System.out.println("result: " + buf.toString());// 32位的加密
//			//System.out.println("result: " + buf.toString().substring(8, 24));// 16位的加密
//		} catch (NoSuchAlgorithmException e) {
//			e.printStackTrace();
//		}
//		return buf.toString().substring(8,24).toUpperCase();
		return SHA1.getDigestOfString(plainText.getBytes());
	}
	
	public static String getMD5FlieName(String filePath,String url){
		String md5 = Md5(url);
		String fileSuffix = filePath.substring(filePath.lastIndexOf('.')+1);
		return md5+fileSuffix;
	}
}
