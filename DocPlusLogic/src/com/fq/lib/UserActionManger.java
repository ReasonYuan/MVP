package com.fq.lib;

import java.util.ArrayList;
import java.util.Collections;

import com.fq.halcyon.entity.UserAction;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.DES3Utils;
import com.fq.lib.tools.Constants;

public class UserActionManger {

	private static UserActionManger mInstance;
	
	private UserActionManger(){};
	
	private ArrayList<UserAction> mActions;
	
	public static UserActionManger getInstance(){
		if(mInstance == null){
			mInstance = new UserActionManger();
			
			mInstance.mActions = new ArrayList<UserAction>();
			mInstance.mActions.clear();
			JSONArray array = null;
			try {
				//数据被加密，需要解密
				String str = FileHelper.readString(FileSystem.getInstance().getUserActionPath(),false);
				if(str != null&& !"".equals(str)){
					String miwen = new String(DES3Utils.decryptMode(str.getBytes(), Constants.KEY_STRING));
					array = new JSONArray(miwen);
				}
			} catch (JSONException e1) {
				e1.printStackTrace();
				array = new JSONArray();
			}
			if(array != null){
				for(int i = 0; i < array.length(); i++){
					try {
						JSONObject obj = array.getJSONObject(i);
						UserAction action = new UserAction();
						action.setAtttributeByjson(obj);
						mInstance.mActions.add(action);
					} catch (JSONException e) {
						e.printStackTrace();
					} 
				}
			}
		}
		return mInstance;
	}
	
	/**添加操作动作*/
	public void addAction(UserAction action){
		mActions.add(0, action);
		if(mActions.size() > 10){
			mActions.remove(10);
		}
		
		JSONArray array = new JSONArray();
		for(UserAction act:mActions){
			JSONObject obj = act.getJson();
			if(obj != null){
				array.put(obj);
			}
		}
		//数据加密保存
		String miwen = new String(DES3Utils.encryptMode(array.toString().getBytes(), Constants.KEY_STRING));
		FileHelper.saveFile(miwen, FileSystem.getInstance().getUserActionPath(),false);
	}
	
	/**添加查看病历的动作*/
	public void addViewPatientAction(String patientName){
		if(patientName == null || "".equals(patientName)){
			return;
		}
		int count = mActions.size();
		boolean isNotExist = true;
		for(int i = 0; i < count && isNotExist; i++){
			UserAction userAction = mActions.get(i);
			if(userAction.getAction() != UserAction.ACTION_VIEW_PATIENT){
				continue;
			}else{
				if(patientName.equals(userAction.getDes())){
					isNotExist = false;
					return;
				}
			}
		}
		if(isNotExist){
			UserAction action = new UserAction(System.currentTimeMillis(),UserAction.ACTION_VIEW_PATIENT, patientName);
			addAction(action);
		}
	}
	
	/**
	 * 获取关闭动画时显示的内容
	 */
	public ArrayList<UserAction> getCloseViewActions(){
		/**
		 * {"注册","上传病历","添加病人","添加医生","设置提醒","提醒留言","看过患者"} 
		 */
		ArrayList[] actionKinds = {new ArrayList<UserAction>(),new ArrayList<UserAction>(),new ArrayList<UserAction>(),new ArrayList<UserAction>(),new ArrayList<UserAction>(),new ArrayList<UserAction>(),new ArrayList<UserAction>()};
		ArrayList<UserAction> closeViewActions = new ArrayList<UserAction>();
		if(mActions != null){
			int count = mActions.size();
			for(int i = 0 ; i < count; i ++){
				UserAction userAction = mActions.get(i);
				int actionType = userAction.getAction();
				if(actionType < actionKinds.length){
					actionKinds[actionType].add(userAction);
				}
			}
			for(int i = 0; i < actionKinds.length; i++){
				//打乱所有的数据，（用于随机取数据）
				Collections.shuffle(actionKinds[i]);
			}
			//随机获取三个查看过的病历患者的名字
			if(actionKinds[UserAction.ACTION_VIEW_PATIENT].size() > 3){
				closeViewActions.add((UserAction) actionKinds[UserAction.ACTION_VIEW_PATIENT].get(0));
//				closeViewActions.add((UserAction) actionKinds[UserAction.ACTION_VIEW_PATIENT].get(1));
//				closeViewActions.add((UserAction) actionKinds[UserAction.ACTION_VIEW_PATIENT].get(2));
			}else{
				closeViewActions.addAll(actionKinds[UserAction.ACTION_VIEW_PATIENT]);
			}
			//随机获取两条留言
			if(actionKinds[UserAction.ACTION_ADD_REMARK].size() > 2){
				closeViewActions.add((UserAction) actionKinds[UserAction.ACTION_ADD_REMARK].get(0));
//				closeViewActions.add((UserAction) actionKinds[UserAction.ACTION_ADD_REMARK].get(1));
			}else{
				closeViewActions.addAll(actionKinds[UserAction.ACTION_ADD_REMARK]);
			}
			//随机获取两个新添加的医生朋友
			if(actionKinds[UserAction.ACTION_ADD_DEOCTOR].size() > 2){
				closeViewActions.add((UserAction) actionKinds[UserAction.ACTION_ADD_DEOCTOR].get(0));
//				closeViewActions.add((UserAction) actionKinds[UserAction.ACTION_ADD_DEOCTOR].get(1));
			}else{
				closeViewActions.addAll(actionKinds[UserAction.ACTION_ADD_DEOCTOR]);
			}
			
			//随机获取两个新添加的病人朋友
			if(actionKinds[UserAction.ACTION_ADD_PATIENT].size() > 2){
				closeViewActions.add((UserAction) actionKinds[UserAction.ACTION_ADD_PATIENT].get(0));
//				closeViewActions.add((UserAction) actionKinds[UserAction.ACTION_ADD_DEOCTOR].get(1));
			}else{
				closeViewActions.addAll(actionKinds[UserAction.ACTION_ADD_PATIENT]);
			}
		}
		Collections.shuffle(closeViewActions);//打算返回的结果数据的顺序
		//添加上传的病历份数
		int upCount = actionKinds[UserAction.ACTION_UP_RECORD].size();
		UserAction upCountAction = new UserAction(System.currentTimeMillis(), UserAction.ACTION_UP_RECORD, upCount + "份"); 
		closeViewActions.add(0, upCountAction);
		return closeViewActions;
	}
	
	public ArrayList<UserAction> getActions(){
		return mActions;
	}
}
