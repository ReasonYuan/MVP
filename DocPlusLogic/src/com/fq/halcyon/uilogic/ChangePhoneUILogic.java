package com.fq.halcyon.uilogic;

public class ChangePhoneUILogic extends RegisterUILogic{

	/**
	 * 检测输入的各项是否完整
	 * @param phone   手机号码输入项
	 * @param password   密码输入项
	 * @param vertification  验证码输入项
	 * @param messageCallBack   返回信息的回调函数，可以为null
	 * @return  true  所有输入符合要求，false  输入有误
	 */
	public boolean checkInput(String phone, String password, String vertification,MessageCallBack messageCallBack) {
		if(!checkPhone(phone)){
			if(messageCallBack != null){
				messageCallBack.message("请输入11位手机号码");
			}
			return false;
		}else if(password == null || "".equals(password)){
			if(messageCallBack != null){
				messageCallBack.message("请输入密码");
			}
			return false;
		}else if(!checkVertification(vertification)){
			if(messageCallBack != null){
				messageCallBack.message("请输入验证码");
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
