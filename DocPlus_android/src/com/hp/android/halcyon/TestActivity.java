//package com.hp.android.halcyon;
//
//import java.util.ArrayList;
//import java.util.Calendar;
//import java.util.Map;
//
//import android.app.Activity;
//import android.os.Bundle;
//import android.widget.ListView;
//
//import com.fq.android.plus.R;
//import com.fq.halcyon.entity.PatientInfo;
//import com.fq.halcyon.logic2.DoctorHomeLogic;
//import com.fq.halcyon.logic2.DoctorHomeLogic.OnDoctorHomeCallback;
//import com.hp.halcyon.widgets.main.HorizontalMainView;
//import com.hp.halcyon.widgets.main.HorizontalMainViewAdapter;
//import com.hp.halcyon.widgets.main.MainView;
//
//public class TestActivity extends Activity implements OnDoctorHomeCallback{
//
//	private HorizontalMainView mMainView;
//	
//	private HorizontalMainViewAdapter mAdapter;
//	
//	private DoctorHomeLogic mLogic;
//	
//	@Override
//	protected void onCreate(Bundle savedInstanceState) {
//		super.onCreate(savedInstanceState);
//		setContentView(R.layout.activity_main);
//		mMainView = (HorizontalMainView) findViewById(R.id.hlvSimpleList);
//		mAdapter = new HorizontalMainViewAdapter(this);
//		mMainView.setAdapter(mAdapter);
//		mMainView.setMonthAdapter(mAdapter);
//		mLogic = new DoctorHomeLogic();
//		Calendar calendar = Calendar.getInstance();
//		calendar.set(Calendar.YEAR, 2014);
//		calendar.set(Calendar.MONTH, 11);
//		calendar.set(Calendar.DAY_OF_MONTH, 30);
//		mLogic.requestPatients(calendar.getTimeInMillis(), 60, 0, this);
//	}
//
//	@Override
//	public void errorMonth(String msg) {
//		// TODO Auto-generated method stub
//		
//	}
//
//	@Override
//	public void feedMonth(Map<Integer, ArrayList<Integer>> data) {
//		// TODO Auto-generated method stub
//		
//	}
//
//	@Override
//	public void error(String msg) {
//		// TODO Auto-generated method stub
//		
//	}
//
//	@Override
//	public void feedHomePatients(ArrayList<PatientInfo> infos) {
//		mAdapter.setData(infos);
//	}
//	
//}
