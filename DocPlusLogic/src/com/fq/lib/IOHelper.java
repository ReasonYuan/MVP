package com.fq.lib;

import java.io.InputStream;

public class IOHelper {

	protected static final String TAG = "IOHelper";
	
	public static interface DowloadProgressListener {
		/**
		 * @param percent
		 */
		public void inProcess(int percent);

		/**
		 * @param success
		 *            - success or not
		 */
		public void onComplete(boolean success);
	}

	public static byte[] readFull(InputStream is) {
		byte[] buf = new byte[1024];
		byte[] total = new byte[1024 * 2];
		int offset = 0;
		int rlen = 0;
		while (rlen >= 0) {
			try {
				rlen = is.read(buf);
				if (rlen > 0) {
					if (offset + rlen > total.length) {
						byte[] old = total;
						total = new byte[total.length + 1024 * 2];
						System.arraycopy(old, 0, total, 0, offset);
					}
					System.arraycopy(buf, 0, total, offset, rlen);
					offset += rlen;
				}
			} catch (Exception e) {
				System.out.println(TAG + "->readFull wrong " + e.getMessage());
				break;
			}
		}
		System.out.println(TAG + "->read bytes: " + offset);
		byte[] respContent = new byte[offset];
		System.arraycopy(total, 0, respContent, 0, offset);
		total = null;
		return respContent;
	}
}
