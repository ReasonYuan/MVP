package com.hp.android.halcyon.view;

import java.util.ArrayList;
import java.util.HashMap;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.lib.record.RecordConstants;
import com.hp.android.halcyon.BrowTakePhotoActivity;
import com.hp.android.halcyon.adapter.RecordTitleAdapter;
import com.hp.android.halcyon.adapter.YingXiangAdapter;

/**
 * 病历内容视图 
 */
public class RecordNormalView extends RecordInfoView{

	private Context mContext;
//	private View mView;
	
	/**选项卡的Title*/
	private ListView mTitleListView;
	/**选项卡的Adapter*/
	private RecordTitleAdapter mAdapter;
	/**显示影像缩略图*/
	private GridView mYingXiangAlbum;
	/**影像缩略图的Adapter*/
	private YingXiangAdapter mAlbumAdapter;
	/**显示病历详细内容*/
	private TextView mTextRecord;
	/**被选中的标签*/
	private String mTag;
	/**病历类型  1：入院   3：手术  4：影像  5：出院*/
	private int mType;
	/**影像的图片地址集合*/
	private ArrayList<String> mUrl = new ArrayList<String>();
	/**病历详细信息的Map*/
	private HashMap<String, Object> mContentMap = new HashMap<String, Object>();
	
	private String mImgDes;
	
	private View mScrollView;
	
	public void setContentMap(HashMap<String, Object> mContentMap) {
		this.mContentMap = mContentMap;
		mAdapter.setMap(mContentMap);
		if(mAdapter.getCount() > 0 && mTag == null){
			mTextRecord.setText((String)mContentMap.get(mAdapter.getItem(0)));
		}else if(mAdapter.getCount() > 0 && mTag != null){
			mTextRecord.setText((String)mContentMap.get(mTag));
		}
	}
	
	public RecordNormalView(Context mContext, int mType) {
		this.mContext = mContext;
		this.mType = mType;
		mView = LayoutInflater.from(mContext).inflate(R.layout.view_record_normal, null);
		initWidgets();
		initListener();
	}
	
	/**初始化控件*/
	private void initWidgets() {
		mTitleListView = (ListView) mView.findViewById(R.id.view_record_normal_list);
		mYingXiangAlbum = (GridView) mView.findViewById(R.id.view_record_normal_album);
		mScrollView = mView.findViewById(R.id.scroll_noremal_view);
		mTextRecord = (TextView) mView.findViewById(R.id.view_record_normal_text_content);
		mAdapter = new RecordTitleAdapter(mContext);
		mAlbumAdapter = new YingXiangAdapter(mContext);
		mTitleListView.setAdapter(mAdapter);
		mYingXiangAlbum.setAdapter(mAlbumAdapter);
		if(mType == RecordConstants.TYPE_MEDICAL_IMAGING){
			//当病历类型为影像时，默认影像缩略图可见
			mYingXiangAlbum.setVisibility(View.VISIBLE);
			mScrollView.setVisibility(View.GONE);
		}else{
			mYingXiangAlbum.setVisibility(View.GONE);
			mScrollView.setVisibility(View.VISIBLE);
		}
	}
	
	public void setImageInfo(ArrayList<PhotoRecord> images,String text){
		mAlbumAdapter.addList(images);
		mImgDes = text == null?"":text;
		ArrayList<String> imgTitles = new ArrayList<String>();
		imgTitles.add("影像缩略图");
		imgTitles.add("影像报告");
		mAdapter.addList(imgTitles);
		mYingXiangAlbum.setVisibility(View.VISIBLE);
	}
	
	private void initListener(){
		mTitleListView.setOnItemClickListener(new OnItemClickListener() {
			//标签选项的点击事件
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int position,
					long arg3) {
				if(mType == RecordConstants.TYPE_MEDICAL_IMAGING){
					if(position == 0){
						mYingXiangAlbum.setVisibility(View.VISIBLE);
						mScrollView.setVisibility(View.GONE);
					}else{
						mYingXiangAlbum.setVisibility(View.GONE);
						mScrollView.setVisibility(View.VISIBLE);
						mTextRecord.setText(mImgDes);
					}
				}else{
					mYingXiangAlbum.setVisibility(View.GONE);
					mScrollView.setVisibility(View.VISIBLE);
					mTextRecord.setText((String)mContentMap.get(mAdapter.getItem(position)));
					mTag = mAdapter.getItem(position);
				}
				mAdapter.setSelectedPosition(position);
				mAdapter.notifyDataSetChanged();
			}
		});
		
		mYingXiangAlbum.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int position,
					long arg3) {
				//ArrayList<OneType> mTypes = new ArrayList<OneType>();
				Intent intent = new Intent(mContext, BrowTakePhotoActivity.class);
				intent.putExtra(BrowTakePhotoActivity.EXTRA_BROW_NAMES, mAlbumAdapter.getImgLocalPath());
				intent.putExtra(BrowTakePhotoActivity.EXTRA_BROW_UPLOAD, true);
				mContext.startActivity(intent);
			}
		});
	}
}
