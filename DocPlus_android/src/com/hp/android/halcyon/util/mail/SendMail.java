package com.hp.android.halcyon.util.mail;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Build;

import com.fq.halcyon.entity.User;
import com.fq.lib.tools.Constants;

public class SendMail {

	// 163邮箱
	public static void send_qqmail(String contents, Context context) {
		// 这个类主要是设置邮件
		MailSenderInfo mailInfo = new MailSenderInfo();
		mailInfo.setMailServerHost("smtp.qq.com");
		mailInfo.setMailServerPort("25");
		mailInfo.setValidate(true);
		mailInfo.setUserName("crash_reporter@hotpepperapps.com"); // 实际发送者
		mailInfo.setPassword("YYhealth1234");// 您的邮箱密码
		mailInfo.setFromAddress("crash_reporter@hotpepperapps.com"); // 设置发送人邮箱地址
		mailInfo.setToAddress("crash.android@yiyihealth.com"); // 设置接受者邮箱地址
		mailInfo.setSubject("Yiyi health crash reports!");
		mailInfo.setContent(getUser_Agent(context) + contents);
		// 这个类主要来发送邮件
		SimpleMailSender sms = new SimpleMailSender();
		sms.sendTextMail(mailInfo); // 发送文体格式
		// sms.sendHtmlMail(mailInfo); // 发送html格式
	}
	
	public static void send_qqmail(String message, Exception ex, Context context){
		SendMail.send_qqmail(message + "\n" + ex.toString() + "\n" + getStackTraceString(ex.getStackTrace()), context);
	}

	public static String getStackTraceString(StackTraceElement[] es){
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < es.length; i++) {
			sb.append(es[i].toString()).append("\n");
		}
		return sb.toString();
	}
	
	/**
	 * User-Agent
	 * 
	 * @return user-agent
	 */
	public static String getUser_Agent(Context context) {
		User user = Constants.getUser();
		String ua = "Android device UUID: " + new DeviceUuidFactory(context).getDeviceUuid().toString() + "; osversion: " + getOSVersion() + "; app version: " + getVersion(context) + "; 型号: "
				+ getVendor() + "-" + getDevice() + "\n\n"; //new SimpleDateFormat("YYYY-mm-dd HH:mm:ss").format(new Date()) + 
		ua += "User:"+user.getName()+"("+user.getRole()+")-id:"+user.getUserId()+"\n\n";
		return ua;
	}

	/**
	 * device model name, e.g: GT-I9100
	 * 
	 * @return the user_Agent
	 */
	public static String getDevice() {
		return Build.MODEL;
	}

	/**
	 * device factory name, e.g: Samsung
	 * 
	 * @return the vENDOR
	 */
	public static String getVendor() {
		return Build.BRAND;
	}

	/**
	 * @return the SDK version
	 */
	public static int getSDKVersion() {
		return Build.VERSION.SDK_INT;
	}

	/**
	 * @return the OS version
	 */
	public static String getOSVersion() {
		return Build.VERSION.RELEASE;
	}

	/**
	 * Retrieves application's version number from the manifest
	 * 
	 * @return versionName
	 */
	public static String getVersion(Context context) {
		String version = "0.0.0";
		try {
			PackageInfo packageInfo = context.getPackageManager().getPackageInfo(
					context.getPackageName(), 0);
			version = packageInfo.versionName;
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}

		return version;
	}
}