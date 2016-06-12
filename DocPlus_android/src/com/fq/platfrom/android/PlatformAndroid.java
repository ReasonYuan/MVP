package com.fq.platfrom.android;

import java.security.MessageDigest;

import android.util.Log;

import com.fq.lib.HttpHelper;
import com.fq.lib.platform.DES3Utils;
import com.fq.lib.platform.HMACSHA1;
import com.fq.lib.platform.Platform;
import com.hp.android.halcyon.util.UITools;

public class PlatformAndroid extends Platform {

	@Override
	public void scanFile(String path) {
		UITools.scanFile(path);
	}
	
	@Override
	public void scanFile(String oldPath, String newPath) {
		UITools.scanFile(oldPath,newPath);
	}

	@Override
	public void initNetWorkLibrary() {
		HttpHelper.setHttpClient(new FQAsyncHttpClient());
	}

	@Override
	public void initDes3Utils() {
		DES3Utils.setDES3(new DES3Utils_Android());
	}

	@Override
	public void initHMACSHA1() {
		HMACSHA1.setHMACSHA1(new HMACSHA1_Android());
	}
	
	@Override
	public byte[] getRecord3DesKey() {
		return FQSecuritySession.getInstance().get3DesKeyBytes();
	}

	@Override
	public int getTargetPlatform() {
		return Platform.PLANTFORM_ANDROID;
	}

	private static String convertToHex(byte[] data) {
		StringBuilder buf = new StringBuilder();
		for (byte b : data) {
			int halfbyte = (b >>> 4) & 0x0F;
			int two_halfs = 0;
			do {
				buf.append((0 <= halfbyte) && (halfbyte <= 9) ? (char) ('0' + halfbyte) : (char) ('a' + (halfbyte - 10)));
				halfbyte = b & 0x0F;
			} while (two_halfs++ < 1);
		}
		return buf.toString();
	}
	
	@Override
	public String SHA1(String text) {
		try {
			MessageDigest md = MessageDigest.getInstance("SHA-1");
			md.update(text.getBytes("iso-8859-1"), 0, text.length());
			byte[] sha1hash = md.digest();
			return convertToHex(sha1hash);
		} catch (Exception e) {
			Log.e("", "", e);
		}
		return "";
	}
}
