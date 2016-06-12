package com.hp.android.halcyon;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.Tool;
import com.hp.android.halcyon.util.TextFontUtils;

public class AnnualFeeActivity extends BaseActivity{

	private ListView mFeeChose;
	private AnnualFeeAdapter mAdapter;
	
	private int mSelectId = -1;
	private View mSelectView;
	
	@Override
	public int getContentId() {
		return R.layout.activity_annual_fee;
	}

	@Override
	public void init() {
//		((TextView) findViewById(R.id.tv_topbar_text)).setTextColor(Color
//				.parseColor("#535353"));
//		Typeface mFont = Typeface.createFromAsset(getAssets(),
//				"lantingchuheijian.TTF");
//		((TextView) findViewById(R.id.tv_topbar_text)).setTypeface(mFont);
		setTitle("年费选择");

		mSelectId = Constants.getUser().getAnnual()/1000;
		
		mFeeChose = (ListView) findViewById(R.id.lv_annual_fee_chose);
		mAdapter = new AnnualFeeAdapter();
		mFeeChose.setAdapter(mAdapter);
		
		mFeeChose.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				view.findViewById(R.id.ll_annual_bg).setEnabled(false);
				if(mSelectId != position){
					if(mSelectView != null)mSelectView.setEnabled(true);
					mSelectId = position;
				}
				mSelectView = view.findViewById(R.id.ll_annual_bg);
			}
		});
	}
	
	public static String getAnnualStr(){
		int cont =  Constants.getUser().getAnnual();
		return (cont == 0?"免费义诊":Tool.get3Th(cont)+"医家币/年");
	}
	
	@Override
	public void onBackPressed() {
		if(mSelectId*1000 != Constants.getUser().getAnnual()){
			Intent intent = new Intent();
			intent.putExtra("annualFee", mSelectId*1000);
			setResult(RESULT_OK, intent);
			finish();
		}else{
			super.onBackPressed();
		}
	}
	
	
	/**显示年费列表的Adapter*/
	public class AnnualFeeAdapter extends BaseAdapter{
		
		@Override
		public int getCount() {
			return 6;
		}

		@Override
		public String getItem(int position) {
			return null;
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			if(convertView == null){
				convertView = LayoutInflater.from(AnnualFeeActivity.this).inflate(R.layout.item_annual_fee,null);
				TextView textFee = (TextView) convertView.findViewById(R.id.tv_item_annual_fee);
				textFee.setTypeface(TextFontUtils.getTypeface(TextFontUtils.FONT_ELLE_BOO));
				textFee.setTextColor(0x773f3b3a);
			}
			TextView mTextFee = (TextView) convertView.findViewById(R.id.tv_item_annual_fee);
			TextView desText = (TextView) convertView.findViewById(R.id.tv_item_annual_des);
			if(position == 0){
				mTextFee.setText("Free");
				desText.setText("免费义诊");
			}else{
				mTextFee.setText(Tool.get3Th(position*1000));
				desText.setText("医家币/年");
			}
			if(mSelectId == position){
				mSelectView = convertView.findViewById(R.id.ll_annual_bg);
				mSelectView.setEnabled(false);
			}else{
				convertView.findViewById(R.id.ll_annual_bg).setSelected(false);
			}
			
			return convertView;
		}
	}
}
