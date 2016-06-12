package com.fq.lib.tools;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Random;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.fq.halcyon.HalcyonUploadLooper;
import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.halcyon.entity.Tag;
import com.fq.halcyon.entity.User;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.ChinesetSortHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;

public class Tool {

	public static String getNameByURL(String url){
		int index = url.lastIndexOf('/');
		return url.substring(index+1);
	}
	
	@SuppressWarnings("unchecked")
	public static <T extends HalcyonEntity>TreeMap<String, ArrayList<T>> getSortList(ArrayList<? extends HalcyonEntity> userList){
		Collections.sort(userList);
		TreeMap<String, ArrayList<T>> map = new TreeMap<String, ArrayList<T>>();
		for(HalcyonEntity user:userList){
			char headChar = user.getPinyinName().toUpperCase().charAt(0);
			String head = String.valueOf(headChar);//.toUpperCase();;
			if(headChar > 90 || headChar < 65){
				head = "#";
			}
			
			if(!map.containsKey(head)){
				ArrayList<T> arrays = new ArrayList<T>(); 
				map.put(head, arrays);
			}
			ArrayList<T> arrays = map.get(head);
			arrays.add((T) user);
		}
		return map;
	}
	
	/*@SuppressWarnings("unchecked")
	public <T extends HalcyonEntity>ArrayList<T> getFilterArrayList(ArrayList<T> oldList,String str){
		ArrayList<T> filterArrayList = new ArrayList<T>();
		String pinyin = ChinesetSortHelper.getPingYin(str).toUpperCase();
		for(HalcyonEntity entity : oldList){
			String pinyinName = entity.getPinyinName().toUpperCase(); 
			boolean isExist = true;
			for(int i = 0; i < pinyin.length(); i++){
				int index = pinyinName.indexOf(pinyin.charAt(i));
				if(index != -1){
					pinyinName = pinyinName.substring(index+1);//pinyinName.substring(0, index)+
				}else {
					isExist = false;
					break;
				}
			}
			if(isExist){
				filterArrayList.add((T)entity);
			}
			
			if(pinyinName.contains(pinyin)){
				filterArrayList.add((T)entity);
			}
		}
		return filterArrayList;
	}*/
	
	@SuppressWarnings("unchecked")
	public static <T extends HalcyonEntity>ArrayList<T> getFilterArrayListAll(ArrayList<T> oldList,String str){
		ArrayList<T> filterArrayList = new ArrayList<T>();
		String pinyin = ChinesetSortHelper.getPingYin(str).toUpperCase();
		for(HalcyonEntity entity : oldList){
			String pinyinName = entity.getPinyinName().toUpperCase(); 
			boolean isExist = true;
			for(int i = 0; i < str.length(); i++){
				int index = pinyinName.indexOf(pinyin.charAt(i));
				if(index != -1){
					pinyinName = pinyinName.substring(index+1);//pinyinName.substring(0, index)+
				}else {
					isExist = false;
					break;
				}
			}
			if(isExist){
				filterArrayList.add((T)entity);
			}
		}
		return filterArrayList;
	}
	
	public static boolean checkPassword(String password) {
		if(password == null)return false;
		String reg = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
		if (password.matches(reg)) {
			return true;
		} 
		return false;
	}
	
	public static boolean checkInvite(String invite){
		if(invite == null)return false;
		String reg = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{4}$";
		if (invite.matches(reg)) {
			return true;
		} 
		return false;
	}
	
	
	public static String getSize(long size){
		if(size < 1204){
			return  size+"B";
		}else if(size < 1024*1024){
			return DecimalFloat( (float)size/1024)+"k";
		}else{
			return DecimalFloat( (float)size/1024/1024f)+"M";
		}
	}
	
	public static String DecimalFloat(float scale){
		DecimalFormat fnum = new DecimalFormat("##0.0"); 
		return fnum.format(scale); 
	}
	
	public static String encrypt(String key) {
		return AeSimpleSHA1.repeat20TimesAndSHA1(key);
	}
	
	public static Tag getTagById(int id){
		if(id == 0)return new Tag();
		for(Tag tag:Constants.tagList){
			if(tag.getId() == id){
				return tag;
			}
		}
		return new Tag();
	}
	
	/*public static ArrayList<PatientRecord> getPatinetRcord4Tag(Tag tag){
		ArrayList<PatientRecord> patRecords = new ArrayList<PatientRecord>();
		if(tag == null)return patRecords;
		ArrayList<PatientRecord> patientRecords = Constants.patientRecords;
		for(int i = 0, count = patientRecords.size(); i < count ; i++){
			PatientRecord record = patientRecords.get(i);
			ArrayList<String> tagList = new ArrayList<String>();
			tagList = record.getTags();
			for(int j = 0, countTag = tagList.size(); j < countTag; j++){
				if(tag.getTitle().equals(tagList.get(j))){
					patRecords.add(record);
					break;
				}
			}
		}
		
		return patRecords;
	}
	
	public static int getPatinetCount4Tag(Tag tag){
		int count = 0;
		if(tag == null)return 0;
		ArrayList<PatientRecord> patientRecords = Constants.patientRecords;
		for(int i = 0; i < patientRecords.size() ; i++){
			PatientRecord record = patientRecords.get(i);
			ArrayList<String> tagList = new ArrayList<String>();
			tagList = record.getTags();
			for(int j = 0, countTag = tagList.size(); j < countTag; j++){
				if(tag.getTitle().equals(tagList.get(j))){
					count++;
					break;
				}
			}
		}
		return count;
	}
	
	public static void freshTagList(){
		new TagLogic().getListAllTags(null);
	}
	
	public static int getRecordIndexByRecord(PatientRecord rd){
		for(int i = 0; i < Constants.patientRecords.size(); i++){
			if(rd.getDoctorPatientId() == Constants.patientRecords.get(i).getDoctorPatientId()){
				return i;
			}
		}
		return 0;
	}*/
	
	/*public static int getRecordIndexByLocalRecord(ArrayList<LocalPaticenRecord>records, LocalPaticenRecord rd){
		for(int i = 0; i < records.size(); i++){
			if(rd.getLoalCreateTime() == records.get(i).getLoalCreateTime()){
				return i;
			}
		}
		return 0;
	}*/
	
	/**
	 * 得到千分制数字
	 * @param numbaer 需要转换的数字
	 * @return  转换后的数字（string）
	 */
	public static String get3Th(int numbaer){
		return String.valueOf(numbaer).replaceAll("(?<=\\d)(?=(?:\\d{3})+$)", ",");
	}
	
	/**
	 * 千分制数字转换为一般数字
	 * @param numbaer 需要转换的千分制数字
	 * @return  转换后的数字(int)
	 */
	public static int parse3Th(String numbaer){
		return Integer.parseInt(String.valueOf(numbaer).replaceAll(",", ""));
	}
	
	public static HashMap<String, Object> getMapByJsonObject(JSONObject obj){
		HashMap<String, Object> map = new HashMap<String, Object>();
		if(obj != null){
			Iterator<String> it = obj.keys();
			while(it.hasNext()){
				String key = it.next();
				map.put(key, obj.opt(key));
			}
		}
		return map;
	}
	
	/**
	 * 游客登录时，不联网登录，直接创建用户
	 */
	public static void createVisitorUser(){
		User user = new User();
		user.setUserId(0);
		user.setPhone_number("18602106473");
		user.setPassword("lin2992");
		Constants.setUser(user);
	}
	
	/**
	 * 清除用户数据，用于用户注销时（设置界面退出登录时）
	 */
	public static void clearUserData(){
		HalcyonUploadLooper.getInstance().stop();
		FileSystem.getInstance().saveLoginUser(Constants.getUser().getPhoneNumber(), "",Constants.getUser().getUserId());
		Constants.setUser(null);
//		CertificationStatus.getInstance().clear();
//		ReadHistoryManager.getInstance().clear();//不用历史记录了
		
		if(Platform.getInstance() != null)Platform.getInstance().clearUser();
		
	}
	
	/**
	 *判断是否是手机号 
	 */
	public static boolean isMobileNO(String mobiles){  
//		  Pattern p = Pattern.compile("^((13[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$");  
		  Pattern p = Pattern.compile("^1\\d{10}$");
		  Matcher m = p.matcher(mobiles);  
		  return m.matches();  
	}
	
	/**
	 * 阿拉伯数字转成汉语
	 * @param number
	 * @return
	 */
	public static String numToCHN(int number){
		String[] bigNum={"","一","二","三","四","五","六","七","八","九"};
		if(number < 10){
			return bigNum[number];
		}else if(number >= 10){
			return bigNum[number/10]+"十"+bigNum[number%10];
		}
		return "";
	}
	
	/**
	 * 检查用户信息是否完整，用于用户注册后填写信息时判断
	 * @return 信息全返回true，否则返回false
	 */
	public static boolean isUserInfoFull(User user){
		if(user == null)return false;
		if ("".equals(user.getName())|| "".equals(user.getGenderStr()) ||
			"".equals(user.getDepartment()) || "".equals(user.getHospital())||
			"".equals(user.getTitleStr())){
					return false;
			}
		return true;
	}
	
	/**
	 * 随机生成一组秘钥，主要用于注册时传给服务器保存
	 * @return
	 */
	public static String getRandomkey(){
		StringBuffer sb = new StringBuffer();
		Random random = new Random();
		int count = random.nextInt(20)+40;
		for(int i = 0; i < count; i++){
			sb.append((random.nextInt(97)+26));
		}
		return sb.toString();
	}
}
