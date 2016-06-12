package com.hp.android.halcyon.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.android.plus.R.color;
import com.fq.halcyon.entity.Patient;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.TimeFormatUtils;

public class PatientListAdapter extends BaseAdapter {

	private LayoutInflater inflater;
	private ArrayList<Patient> mPatientList;
	private final int NO_UNREC = 0;
	private final int HAVE_UNREC = 1;
	private int itemSelected = -1;
	private OverviewClickListener onClickListener;
	private Context context;
	
	public PatientListAdapter(Context context) {
		this.context = context;
		mPatientList = new ArrayList<Patient>();
		inflater = LayoutInflater.from(context);
	}

	public void addDatas(ArrayList<Patient> mPatientList) {
		this.mPatientList = mPatientList;
		notifyDataSetChanged();
	}

	public void clearDatas(){
		this.mPatientList.clear();
	}
	
	public void setItemSelected(int position) {
		itemSelected = position;
		notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		return mPatientList.size();
	}

	@Override
	public Object getItem(int position) {
		return mPatientList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		int type = getItemViewType(position);
		final Patient patient = (Patient) getItem(position);
		ViewHolder viewHolder = null;
		if (convertView == null) {

			viewHolder = new ViewHolder();
			convertView = inflater.inflate(R.layout.item_patient_normal,parent, false);
			viewHolder.headView = convertView.findViewById(R.id.item_pn_header_view);
			viewHolder.bottomView = convertView.findViewById(R.id.item_pn_bottom_view);
			viewHolder.textShareFrom = (TextView) convertView.findViewById(R.id.item_pn_share_from);
			viewHolder.textRecordName = (TextView) convertView.findViewById(R.id.item_tv_pn_name);
			viewHolder.textCreateTime = (TextView) convertView.findViewById(R.id.item_pn_create_time);
			viewHolder.textRecordNum = (TextView) convertView.findViewById(R.id.item_pn_record_count);
			viewHolder.shareCutLine = convertView.findViewById(R.id.view_pn_share_from_cutline);
			viewHolder.timeCutLine = convertView.findViewById(R.id.view_pn_create_time_cutline);
			viewHolder.textUnrecNum = (TextView) convertView.findViewById(R.id.tv_pn_unrecong_count);
			viewHolder.imgBackground = (ImageView) convertView.findViewById(R.id.img_pn_bg);
			viewHolder.btnView = (TextView) convertView.findViewById(R.id.item_tv_pn_overview);
			viewHolder.patientCutLine = convertView.findViewById(R.id.view_item_patient_cutline);
			convertView.setTag(viewHolder);
		} else {
			viewHolder = (ViewHolder) convertView.getTag();
		}

		if (type == HAVE_UNREC) {
			viewHolder.imgBackground.setBackgroundResource(R.drawable.selector_img_patient_have_unrec);
			viewHolder.textUnrecNum.setVisibility(View.VISIBLE);
			if(patient.getNotRecCount() > 99){
				viewHolder.textUnrecNum.setText("99");
			}else{
				viewHolder.textUnrecNum.setText(patient.getNotRecCount() + "");
			}
		}else{
			viewHolder.imgBackground.setBackgroundResource(R.drawable.selector_img_patient_normal);
			viewHolder.textUnrecNum.setVisibility(View.GONE);
		}
		
		if (position == 0) {
			viewHolder.headView.setVisibility(View.VISIBLE);
		}else{
			viewHolder.headView.setVisibility(View.GONE);
		}
		if (position == getCount() - 1) {
			viewHolder.bottomView.setVisibility(View.VISIBLE);
		}else{
			viewHolder.bottomView.setVisibility(View.GONE);
		}
		if (position == itemSelected) {
			viewHolder.imgBackground.setSelected(true);
			viewHolder.patientCutLine.setBackgroundColor(context.getResources().getColor(R.color.app_color_green));
		} else {
			viewHolder.imgBackground.setSelected(false);
			viewHolder.patientCutLine.setBackgroundColor(color.line_divide);
		}
		if (patient.getMedicalFromType() == RecordConstants.MEDICAL_FROM_OWN) {
			viewHolder.textShareFrom.setVisibility(View.GONE);
			viewHolder.shareCutLine.setVisibility(View.GONE);
			viewHolder.timeCutLine.setVisibility(View.GONE);
		} else if (patient.getMedicalFromType() == RecordConstants.MEDICAL_FROM_SHARE) {
			viewHolder.textShareFrom.setVisibility(View.VISIBLE);
			viewHolder.shareCutLine.setVisibility(View.VISIBLE);
			viewHolder.timeCutLine.setVisibility(View.VISIBLE);
			if (patient.getFromUserType() == Constants.ROLE_DOCTOR) {
				viewHolder.textShareFrom.setText(patient.getMedicalFrom()+ "医生分享");
			} else if (patient.getFromUserType() == Constants.ROLE_PATIENT) {
				viewHolder.textShareFrom.setText(patient.getMedicalFrom()+ "病人分享");
			}
		}
		viewHolder.textRecordName.setText(patient.getMedicalName());
		String time = ("".equals(patient.getCreateTime()))?"":patient.getCreateTime().substring(0, 10);
		viewHolder.textCreateTime.setText(TimeFormatUtils.getTimeByStr(time, "yyyy/MM/dd"));
		viewHolder.textRecordNum.setText("("+patient.getRecordCount() + ")");
		viewHolder.btnView.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				onClickListener.onClickListener(patient);
			}
		});
		return convertView;
	}

	@Override
	public int getItemViewType(int position) {
		Patient patient = (Patient) getItem(position);
		if (patient.getNotRecCount() > 0) {
			return HAVE_UNREC;
		} else {
			return NO_UNREC;
		}
	}

	class ViewHolder {
		View headView;
		View bottomView;
		TextView textShareFrom;
		TextView textRecordName;
		TextView textCreateTime;
		TextView textRecordNum;
		TextView textUnrecNum;
		TextView btnView;
		View shareCutLine;
		View timeCutLine;
		View patientCutLine;
		ImageView imgBackground;
	}
	
	public interface OverviewClickListener{
		public void onClickListener(Patient patient);
	}
	
	public void onOverviewClickListener(OverviewClickListener onClickListener){
		this.onClickListener = onClickListener;
	}
}
