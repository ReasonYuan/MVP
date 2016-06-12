package com.fq.halcyon.practice;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;

import com.fq.halcyon.entity.practice.PatientAbstract;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.tools.FQLog;

/**
 * 管理病案浏览记录的工具，最多保存20条记录，分为[今天]、[昨天]、[一周]、[更早]四块
 * 
 * 注意：因为不用本地历史记录了，所以现在这个工具只用作病案列表第一页数据的缓存
 * 
 * @author reason
 *
 */
public class ReadHistoryManager {
	
	
	private static final String[] HISTORY_TITLES = {"今日","昨日","一周","更早"};
	
//	private JSONArray mPatientArray;
	/**病案历史记录的线型列表*/
	private ArrayList<PatientAbstract> mPatientAbsList;
	
	/**病案历史记录的树型列表，分为今天、昨天、一周、更早四块，若某模块没有则无*/
	private HashMap<String,ArrayList<PatientAbstract>> mPatientMap;
	
	/**管理工具的单例*/
	private static ReadHistoryManager mInstance;
	
	public static String getTitleByindex(int index){
		try{
			return HISTORY_TITLES[index];
		}catch(Exception e){
			return "";
		}
	}
	
	/**
	 * 获得病案历史记录管理工具的单例
	 * 注意：这个现阶段废弃了，不用浏览历史记录了
	 * @return
	 */
//	public static ReadHistoryManager getInstance(){
//		if(mInstance == null){
//			mInstance = new ReadHistoryManager();
//		}
//		return mInstance;
//	}
	
	/**
	 * 注销时清除数据
	 */
	public void clear(){
		mPatientMap = null;
		mPatientAbsList = null;
		mInstance = null;
	}
	
	/**
	 * 初始化历史浏览的工具类
	 */
	private ReadHistoryManager(){
		mPatientAbsList = new ArrayList<PatientAbstract>();
		mPatientMap = new HashMap<String, ArrayList<PatientAbstract>>();
		
		String txt = FileSystem.getInstance().loadUserReadHistory();
		if(txt != null && !"".equals(txt)){
			try {
				JSONArray array = new JSONArray(txt);
				for(int i = 0; i < array.length(); i++){
					PatientAbstract patient = new PatientAbstract();
					patient.setAtttributeByjson(array.optJSONObject(i));
					mPatientAbsList.add(patient);
				}
			} catch (JSONException e) {
				FQLog.i("解析历史浏览记录的json文本出错");
				e.printStackTrace();
			}
			initMap();
		}
	}
	
//	/**
//	 * 服务器太坑了，自己构建假数据
//	 */
//	private void loadJiaShuJu(){
//		Random random = new Random();
//		for(int i = 0; i < 20; i++){
//			PatientAbstract patient = new PatientAbstract();
//			patient.setPatientId(random.nextInt(1988)+1);
//			patient.setPatientName("做点假数据，测试测试"+i);
//			patient.setUserImageId(random.nextInt(200)+1);
//			patient.setRecordCount(random.nextInt(3000)+1);
//			Calendar cal = Calendar.getInstance();
//			cal.add(Calendar.DAY_OF_YEAR, -i);
//			patient.setReadCalender(cal);
//			mPatientAbsList.add(patient);
//		}
//	}
	
	
	/**
	 * 保存历史记录到本地，当记录发生变化是调用
	 */
	private void saveHistory2Local(){
		final String history = getHistoryJsonStr();
		if(history == null)return;
		new Thread(new Runnable() {
			public void run() {
				FileSystem.getInstance().saveUserReadHistory(history);
			}
		}).start();
	}
	
	/**
	 * 初始化病案记录树型列表
	 * @return
	 */
	private void initMap(){
		if(mPatientAbsList.size() == 0)return;
		long currentZeroTime = getCurrentZeroTime();
		for(PatientAbstract patient:mPatientAbsList){
			String time = getHeadByTime(currentZeroTime, patient.getReadCalender());
			ArrayList<PatientAbstract> pts = mPatientMap.get(time);
			if(pts == null){
				pts = new ArrayList<PatientAbstract>();
				mPatientMap.put(time, pts);
			}
			pts.add(patient);
		}
	}
	
	/**
	 * 获得病历浏览历史记录的线型结构
	 * @return
	 */
	public ArrayList<PatientAbstract> getPatientList(){
		return mPatientAbsList;
	}
	
	/**
	 * 获得病历列表的map
	 */
	public HashMap<String,ArrayList<PatientAbstract>> getPatientListMap(){
		if(mPatientMap == null){
			mPatientMap = new HashMap<String, ArrayList<PatientAbstract>>();
			
			long time = getCurrentZeroTime();
			for(int i = 0; i < mPatientAbsList.size(); i++){
				PatientAbstract patient = mPatientAbsList.get(i);
				String group = getHeadByTime(time,patient.getReadCalender());
				
				ArrayList<PatientAbstract> patients = mPatientMap.get(group);
				if(patients == null){
					patients = new ArrayList<PatientAbstract>();
					mPatientMap.put(group, patients);
				}
				patients.add(patient);
			}
		}
		return mPatientMap;
	}
	
	/**
	 * 将某个病案从历史记录中移除,此时记录会发生变化<br/>
	 * 历史记录变化后需要更新本地保存的文件
	 * @param paticent
	 */
	public void removePatientAbs(PatientAbstract paticent){
		for(int i = 0; i < mPatientAbsList.size(); i++){
			if(mPatientAbsList.get(i).getPatientId() == paticent.getPatientId()){
				mPatientAbsList.remove(i);
				mPatientMap = null;
				saveHistory2Local();
				break;
			}
		}
	}
	
	/**
	 * 新增一条病案历史记录，最多20条，如果大于20条则删除最后一条。此时记录会发生变化。<br/>
	 * 历史记录变化后需要更新本地保存的文件
	 * @param paticent 要添加的病案
	 * @return boolean 如果病案是新增的则返回true,如果病案以前存在则返回false
	 */
	public boolean addPatientAbs(PatientAbstract paticent){
		for(int i = 0; i < mPatientAbsList.size(); i++){
			if(mPatientAbsList.get(i).getPatientId() == paticent.getPatientId()){
				mPatientAbsList.remove(i);
				paticent.setReadCalender(Calendar.getInstance());
				mPatientAbsList.add(0, paticent);
				mPatientMap = null;
				saveHistory2Local();
				return false;
			}
		}
		
		//最多只有20条，所以大于20条会删除后面的
		if(mPatientAbsList.size() == 20){
			mPatientAbsList.remove(19);
		}
		
		//加入新数据，肯定只会加到今天
		paticent.setReadCalender(Calendar.getInstance());
		mPatientAbsList.add(0,paticent);
		ArrayList<PatientAbstract> today = mPatientMap.get(HISTORY_TITLES[0]);
		if(today == null){
			today = new ArrayList<PatientAbstract>();
			mPatientMap.put(HISTORY_TITLES[0], today);
		}
		today.add(0,paticent);
		saveHistory2Local();
		return true;
	}

	/**
	 * 得到系统当天的零时的毫秒数
	 * @return 当天零时的毫秒数
	 */
	private long getCurrentZeroTime(){
		Calendar today = Calendar.getInstance();
        today.set(Calendar.HOUR_OF_DAY,0);
		today.set(Calendar.SECOND, 0);
		today.set(Calendar.MILLISECOND, 0);
		return today.getTimeInMillis();
	}
	
	
	/**
	 * 根据日期时间获得属于哪一个类型的
	 * @param todayMills 判断所依据的日期的毫秒数
	 * @param cal 需要判断的日期
	 * @return 属于哪一个类型：今日、昨日、一周、更早
	 */
	private String getHeadByTime(long todayMills,Calendar cal){
		long time = cal.getTimeInMillis();	
		
		if(time >= todayMills)return HISTORY_TITLES[0];
		else if(time >= todayMills-24*3600000)return HISTORY_TITLES[1];
		else if(time >= todayMills-6*24*3600000)return HISTORY_TITLES[2];
		else return HISTORY_TITLES[3];
	}
	
	/**
	 * 得到json数据类型的历史记录
	 * @return
	 */
	public String getHistoryJsonStr(){
		if(mPatientAbsList.size() != 0){
			JSONArray array = new JSONArray();
			for(int i = 0; i < mPatientAbsList.size(); i++){
				array.put(mPatientAbsList.get(i).getJson());
			}
			return array.toString();
		}
		
		return null;
	}
}


