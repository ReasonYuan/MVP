package com.fq.lib.platform;

import java.util.Random;

/**
 * 
 * @Description: 3DES加密解密工具类
 * 
 */
public abstract class DES3Utils {
	
	public interface  DES3Potocol{
		/**
		 * // 加密字符串
		 * @param src
		 * @param keybyte
		 * @return
		 */
		public String encryptMode(byte[] src,byte[] keybyte);
		
		/**
		 *  解密字符串
		 * @param src
		 * @param keybyte
		 * @return
		 */
		public String decryptMode(byte[] src,byte[] keybyte);
		
	}

	private static DES3Potocol mDES3;
	
	public static void setDES3(DES3Potocol des3){
		mDES3 = des3;
	}

	 // 加密字符串
    public static String encryptMode(byte[] src,byte[] keybyte) {
    	if(mDES3 != null){
    		return mDES3.encryptMode(src, keybyte);
    	}
        return null;
    }
 
    // 解密字符串
    public static String decryptMode(byte[] src,byte[] keybyte) {
    	if(mDES3 != null){
    		return mDES3.decryptMode(src, keybyte);
    	}
        return null;
    }

    
	private static Random randGen = null;
	private static char[] numbersAndLetters = null;

	/**
	 * 产生一个随机的字符串
	 * 
	 * @param length
	 *            字符串的长度
	 * @return
	 */
	public static final String randomString(int length) {
		if (length < 1) {
			return null;
		}
		if (randGen == null) {
			randGen = new Random();
			numbersAndLetters = ("0123456789abcdefghijklmnopqrstuvwxyz" + "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ").toCharArray();
		}
		char[] randBuffer = new char[length];
		for (int i = 0; i < randBuffer.length; i++) {
			randBuffer[i] = numbersAndLetters[randGen.nextInt(71)];
		}
		return new String(randBuffer);
	}
	

}