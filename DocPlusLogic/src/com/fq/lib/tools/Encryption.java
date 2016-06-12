package com.fq.lib.tools;

public class Encryption {

	/**
	 * 加密
	 * @param str 需要加密的字符串
	 * @param key 
	 * @return
	 */
	public static String encryption(String str ,String key){
		 String miwen = "";
		    int ch;
		    if(key.length() == 0){
		        return str;
		    }
		    else if(!str.equals(null)){
		        for(int i = 0,j = 0;i < str.length();i++,j++){
		          if(j > key.length() - 1){
		            j = j % key.length();
		          }
		          ch = str.codePointAt(i) + key.codePointAt(j);
		          if(ch > 65535){
		            ch = ch % 65535;
		          }
		          miwen += (char)ch;
		        }
		    }
		    return miwen;
		
	}
	
	/**
	 * 解密
	 * @param str 密文
	 * @param key 
	 * @return
	 */
	public static String dencryption(String str,String key){
		 String minwen = "";
		    int ch;
		    if(key.length() == 0){
		        return str;
		    }
		    else if(!str.equals(key)){
		        for(int i = 0,j = 0;i < str.length();i++,j++){
		          if(j > key.length() - 1){
		            j = j % key.length();
		          }
		          ch = (str.codePointAt(i) + 65535 - key.codePointAt(j));
		          if(ch > 65535){
		            ch = ch % 65535;
		          }
		          minwen += (char)ch;
		        }
		    }
		    return minwen;
	}
}
