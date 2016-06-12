package com.fq.android.visualization;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.VisualizeCard;
import com.fq.library.cardview.FancyCoverFlow;
import com.fq.library.cardview.FancyCoverFlowAdapter;
import com.fq.library.utils.ScreenUtils;
import com.hp.android.halcyon.util.BitmapManager;

public class VisualizeCardAdapter extends FancyCoverFlowAdapter{

	private Context mContext;
	private ArrayList<VisualizeCard> mDatas;
	
	public VisualizeCardAdapter(Context context) {
		this.mContext = context;
		mDatas = new ArrayList<VisualizeCard>();
	}
	
	public void addDatas(ArrayList<VisualizeCard> datas){
		this.mDatas = datas;
		notifyDataSetChanged();
	}
	
	@Override
	public int getCount() {
		return mDatas.size();
	}

	@Override
	public Object getItem(int position) {
		return mDatas.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getCoverFlowItem(int position, View reusableView,
			ViewGroup parent) {
		View view = null;
		ViewHolder viewHolder = null;
		if (reusableView != null) {
			view = reusableView;
			viewHolder = (ViewHolder) view.getTag();
		}else{
			viewHolder = new ViewHolder();
			int viewWidth = ScreenUtils.getScreenWidth(mContext)/4*3;
			int viewHeight = ScreenUtils.getScreenHeight(mContext)/3*2;
			view = LayoutInflater.from(mContext).inflate(R.layout.view_visualize_card, parent, false);
			view.setLayoutParams(new FancyCoverFlow.LayoutParams(viewWidth , viewHeight));
			viewHolder.title = (TextView) view.findViewById(R.id.tv_view_visualize_title);
			viewHolder.img = (ImageView) view.findViewById(R.id.img_view_visualize_card_bg);
			view.setTag(viewHolder);
		}
		
		VisualizeCard visualizeCard = (VisualizeCard) getItem(position);
		viewHolder.title.setText(visualizeCard.getCardName());

		Bitmap bmp = BitmapManager.decodeSampledBitmapFromFile(visualizeCard.getImageId(),1);
		viewHolder.img.setImageBitmap(bmp);
		return view;
	}

	class ViewHolder{
		
		TextView title;
		ImageView img;
	}
}
