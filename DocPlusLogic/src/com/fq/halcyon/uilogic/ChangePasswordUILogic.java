package com.fq.halcyon.uilogic;


public class ChangePasswordUILogic extends RegisterUILogic{

	/**
	 * 检测输入的各项是否完整
	 * @param oldPassword   手机号码输入项
	 * @param password   密码输入项
	 * @param rePassword  确认密码项
	 * @param messageCallBack   返回信息的回调函数，可以为null
	 * @return  true  所有输入符合要求，false  输入有误
	 */
	public boolean checkInput(String oldPassword, String password, String rePassword ,final MessageCallBack messageCallBack){
		if(oldPassword == null || "".equals(oldPassword)){
			if(messageCallBack != null){
				messageCallBack.message("请输入原密码");
			}
			return false;
		}else if(!checkPassword(password)){
			if(messageCallBack != null){
				messageCallBack.message("请输入不少于6位的数字字母密码组合");
			}
			return false;
		}else if(!isSamePwd(password, rePassword)){
			if(messageCallBack != null){
				messageCallBack.message("两次密码不相同");
			}
			return false;
		}else{
			return true;
		}
	}
	
	/**
	 *返回信息的回调函数 
	 */
	public static interface MessageCallBack{
		public void message(String msg);
	}
}
