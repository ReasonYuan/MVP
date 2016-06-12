package com.fq.halcyon.uilogic;

import java.util.ArrayList;

import com.fq.halcyon.entity.Contacts;
import com.fq.halcyon.entity.Tag;
import com.fq.lib.tools.Constants;

/**
 * 标签工具类
 * @author niko
 *
 */
public class TagUtils {
	
	
	private ArrayList<Integer> mAddTagWithIdList = new ArrayList<Integer>();
	
	private ArrayList<String> mAddTagWithStrList = new ArrayList<String>();
	
	private ArrayList<Integer> mDelTagList = new ArrayList<Integer>();
	
	/**添加系统已经存在的标签的列表*/
	public ArrayList<Integer> getAddTagWithIdList() {
		return mAddTagWithIdList;
	}

	/**添加新建的标签的列表*/
	public ArrayList<String> getAddTagWithStrList() {
		return mAddTagWithStrList;
	}

	/**删除标签的列表*/
	public ArrayList<Integer> getDelTagList() {
		return mDelTagList;
	}

	/**
	 * 获取当前联系人下的所有标签
	 * @param contact  当前联系人
	 */
	public ArrayList<Tag> getMyContactTagList(Contacts contact){
		ArrayList<Tag> mContactTagList = new ArrayList<Tag>();
		ArrayList<String> tempTagList = new ArrayList<String>();
		tempTagList.addAll(contact.getTags());
		for(int i = 0; i < tempTagList.size(); i++){
			boolean b = true;
			String tagKey = tempTagList.get(i);
			for(int j = 0; j < Constants.tagList.size() && b; j++){
				Tag tag = Constants.tagList.get(j);
				if(tagKey.equals(tag.getTitle())){
					mContactTagList.add(tag);
					b = false;
				}
			}
		}
		return mContactTagList;
	}
	
	/**
	 * 获取改变的列表 
	 * @param contactTagList  标签列表变动前，联系人绑定的标签
	 * @param resultTagList     最终修改之后的标签列表
	 */
	public void getChangeList(ArrayList<Tag> contactTagList , ArrayList<Tag> resultTagList){
		
		for(int i = 0; i < contactTagList.size(); i++){
			Tag tag = contactTagList.get(i);
			if(resultTagList.contains(tag)){
				continue;
			}else{
				mDelTagList.add(tag.getId());
			}
		}
		
		for(int i = 0; i < resultTagList.size(); i++){
			Tag tag = resultTagList.get(i);
			if(contactTagList.contains(tag)){
				continue;
			}else{
				if(tag.getId() == -1){
					mAddTagWithStrList.add(tag.getTitle());
				}else{
					mAddTagWithIdList.add(tag.getId());
				}
			}
		}
	}
}
