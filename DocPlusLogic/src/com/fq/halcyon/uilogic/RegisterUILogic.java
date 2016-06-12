package com.fq.halcyon.uilogic;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.fq.lib.tools.Tool;

/**
 * 注册界面校验各项输入是否符合要求的逻辑
 * 
 * @version 1.0
 * @history 2014/9/24 create
 */
public class RegisterUILogic {

	public static final int LEVEL_STRONG = 3;
	public static final int LEVEL_MIDDLE = 2;
	public static final int LEVEL_WEAK = 1;
	public static final int LEVEL_ERROR = 0;

	/**
	 * 检测密码的强弱
	 * 
	 * @param password
	 *            输入的 密码
	 * @return 0: 密码小于6位 ， 1：密码强度为弱，2：密码强度为中，3：密码强度为强
	 */
	public int checkPwdLevel(String password) {
		if (password.length() > 12) {
			return LEVEL_STRONG;
		} else if (password.length() > 8) {
			return LEVEL_MIDDLE;
		} else if (password.length() >= 6) {
			return LEVEL_WEAK;
		} else {
			return LEVEL_ERROR;
		}
	}

	/**
	 * 检测手机号码输入是否符合要求
	 * 
	 * @param phone
	 * @return boolean
	 */
	public boolean checkPhone(String phone) {
		if (phone == null || phone.length() != 11) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * 检测输入的密码是否符合要求
	 * 
	 * @param password
	 *            输入的密码
	 * @return boolean
	 */
	public static boolean checkPassword(String password) {
		if (password == null || "".equals(password)
				|| !Tool.checkPassword(password)) {
			return false;
		} else {
			return true;
		}
	}
	
	/**
	 * 检测输入的邀请码是否符合要求
	 * 
	 * @param password
	 *            输入的邀请码
	 * @return boolean
	 */
	public static boolean checkInvite(String invite) {
		if (invite == null || "".equals(invite)
				|| !Tool.checkInvite(invite)) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * 检测验证码是否符合要求
	 * 
	 * @param vertification
	 *            输入的验证码
	 * @return boolean
	 */
	public boolean checkVertification(String vertification) {
		if (vertification == null || "".equals(vertification)) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * 检测两次输入的密码是否相等
	 * 
	 * @param password
	 *            输入的密码
	 * @param rePassword
	 *            再次输入的密码
	 * @return boolean
	 */
	public boolean isSamePwd(String password, String rePassword) {
		if (password != null && password.equals(rePassword)) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 检测输入的各项是否完整
	 * 
	 * @param phone
	 *            手机号码输入项
	 * @param password
	 *            密码输入项
	 * @param rePassword
	 *            确认密码项
	 * @param vertification
	 *            验证码输入项
	 * @param messageCallBack
	 *            返回信息的回调函数，可以为null
	 * @return true 所有输入符合要求，false 输入有误
	 */
	public boolean checkInput(String phone, String password, String rePassword,
			String vertification, final MessageCallBack messageCallBack) {
		if (!checkPhone(phone)) {
			if (messageCallBack != null) {
				messageCallBack.message("请输入11位手机号码");
			}
			return false;
		} else if (!checkPassword(password)) {
			if (messageCallBack != null) {
				messageCallBack.message("请输入不少于6位的数字字母密码组合");
			}
			return false;
		} else if (!checkVertification(vertification)) {
			if (messageCallBack != null) {
				messageCallBack.message("请输入验证码");
			}
			return false;
		} else {
			return true;
		}
	}

	/**
	 * 返回信息的回调函数
	 */
	public static interface MessageCallBack {
		public void message(String msg);
	}

	/**
	 *判断手机号格式是否正确
	 *@param mobiles   
	 *                -需要检测的手机号码 
	 */
	public static boolean isMobileNO(String mobiles) {

		//Pattern p = Pattern.compile("^((13[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$");
		Pattern p = Pattern.compile("^1\\d{10}$");
		Matcher m = p.matcher(mobiles);
//		System.out.println(m.matches() + "---");
		return m.matches();
	}
}
