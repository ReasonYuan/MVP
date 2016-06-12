package com.fq.platfrom.android;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import com.fq.lib.platform.DES3Utils.DES3Potocol;
import com.fq.lib.tools.Base64Util;

public class DES3Utils_Android implements DES3Potocol {

	// 定义加密算法，DESede即3DES
	private static final String Algorithm = "DESede";



	// 加密字符串
	@Override
	public String encryptMode(byte[] src, byte[] keybyte) {
		try { // 生成密钥
			SecretKey deskey = new SecretKeySpec(keybyte, Algorithm); // 加密
			Cipher c1 = Cipher.getInstance(Algorithm);
			c1.init(Cipher.ENCRYPT_MODE, deskey);
			return Base64Util.encode(c1.doFinal(src));
		} catch (java.security.NoSuchAlgorithmException e1) {
			e1.printStackTrace();
		} catch (javax.crypto.NoSuchPaddingException e2) {
			e2.printStackTrace();
		} catch (java.lang.Exception e3) {
			e3.printStackTrace();
		}
		return null;
	}

	// 解密字符串
	@Override
	public String decryptMode(byte[] src, byte[] keybyte) {
		src = Base64Util.decode(new String(src));
		try { // 生成密钥
			SecretKey deskey = new SecretKeySpec(keybyte, Algorithm); // 解密
			Cipher c1 = Cipher.getInstance(Algorithm);
			c1.init(Cipher.DECRYPT_MODE, deskey);
			return new String(c1.doFinal(src));
		} catch (java.security.NoSuchAlgorithmException e1) {
			e1.printStackTrace();
		} catch (javax.crypto.NoSuchPaddingException e2) {
			e2.printStackTrace();
		} catch (java.lang.Exception e3) {
			e3.printStackTrace();
		}
		return null;
	}


}
