package com.hp.android.halcyon.view;

import java.util.ArrayList;
import java.util.Iterator;

import uk.co.senab.photoview.ViewPagerActivity;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.android.plus.recorditem.factory.SampleFactory;
import com.fq.android.plus.recorditem.view.IRecordItemView;
import com.fq.android.plus.recorditem.view.IRecordItemView.JoinEditStateCallBack;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.entity.RecordItem;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.halcyon.logic2.GetRecordItemLogic;
import com.fq.halcyon.logic2.GetRecordItemLogic.ModifyItemCallBack;
import com.fq.halcyon.logic2.GetRecordItemLogic.RecordItemCallBack;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONException;
import com.fq.lib.json.JSONObject;
import com.fq.lib.record.RecordCache;
import com.fq.lib.record.RecordConstants;
import com.fq.library.adapter.CommonAdapter;
import com.fq.library.adapter.ViewHolder;
import com.hp.android.halcyon.BrowRecordItemActivity;
import com.hp.android.halcyon.util.BitmapManager;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.widgets.CustomProgressDialog;
import com.hp.android.halcyon.widgets.HorizontalListView;
import com.hp.android.halcyon.widgets.PhotoView;

/**
 * 浏览病历记录的View
 * 
 * @author niko
 */
@SuppressLint("NewApi")
public class BrowRecordItemView extends FrameLayout implements
		ModifyItemCallBack {

	private BrowRecordItemActivity mContext;
	private View mView;
	/** 显示“基本信息，既往史”等title */
	private TextView mBaseInfoTitle;
	/** 控制基本信息显示和隐藏的按钮 */
	private Button mOpenBtn;
	/** 显示基本信息内容的Frame */
	private FrameLayout mBaseInfoFrame;
	/** 显示详细信息内容的Frame */
	private FrameLayout mDetailInfoFrame;
	/** 显示基本信息内容 */
	private TextView mBaseInfo;
	/** 显示病历记录缩略图的ListView */
	private HorizontalListView mImagesListView;
	/** 显示病历记录缩略图的adapter */
	private CommonAdapter<PhotoRecord> mImagesAdapter;

	private View mContentView;
	private View mBaseInfoButton;
	private View mSaveButton;

	private RecordItem mRecordItem;
//	private ArrayList<PhotoRecord> mPhotos;

//	private GetImagePathLogic mGetImageLogic;
	private GetRecordItemLogic mGetDataLogic;

	private CustomDialog mEditDialog;
	private IRecordItemView mRecordItemView;
//	private RecordItemSamp recordSamp;

	// private ImageLoader mImageLoader;
	private boolean isShowBaseInfo;

	/** 把服务器返回的address等key转换成"地址"等人类能识别的名称 */
	// private static HashMap<String, String> baseInfoKeyToHumanTitle = new
	// HashMap<String, String>();

	public BrowRecordItemView(Context context) {
		super(context);
		this.mContext = (BrowRecordItemActivity) context;
		mView = LayoutInflater.from(mContext).inflate(
				R.layout.view_brow_recorditem_detail, null);
		// mImageLoader = ImageLoader.getInstance(3, Type.LIFO);
		// mRecordItemView = SampleFactory.getInstance(mContext, 0);
		isShowBaseInfo = false;
		initWidgets();
		initListener();
		addView(mView);
	}

	public void showContent(boolean isShow) {
		mContentView.setVisibility(isShow ? View.VISIBLE : View.GONE);
	}

	public void initData(final RecordItemSamp recordSamp) {
//		this.recordSamp = recordSamp;

		//无论是否属于分享的记录，都显示出来
//		if(recordSamp.isShared()){
//			mBaseInfoButton.setVisibility(View.GONE);
//		}
		
		// 设置标题
		int type = RecordConstants.getBigType(recordSamp);

		((TextView) mView.findViewById(R.id.tv_topbar_text))
				.setText(RecordConstants.getTypeNameByRecordType(type));

		mRecordItem = RecordCache.getInstance().getCache(recordSamp.getRecordInfoId());
		
		if(mRecordItem != null && (mRecordItem.isShareModel() != mContext.isShareModel())){
			RecordCache.getInstance().addCache(mRecordItem);
			mRecordItem = null;
		}
		// 加载数据
		if (mRecordItem != null) {
//			mRecordItem.setShared(recordSamp.isShared()|| mContext.isShareModel());//别人分享的或者自己查看分享模式的
			initAllInfo();
		} else {
			if (mGetDataLogic == null) {
				mGetDataLogic = new GetRecordItemLogic(
					new RecordItemCallBack() {
						public void doRecordItemBack(RecordItem recordItem) {
							if (recordItem == null) {
								// UITools.showToast("网络异常，获取数据失败");
							} else {
								mRecordItem = recordItem;
//								mRecordItem.setShared(recordSamp.isShared()||mContext.isShareModel());//别人分享的或者自己查看分享模式的
								if(mRecordItem.getPhotos().size() == 0){
									mRecordItem.setPhotos(recordSamp.getPhotos());
								}
								if (mRecordItem.getRecordType() != 0)
									RecordCache.getInstance().addCache(mRecordItem);
								initAllInfo();
							}
						}
					});
			}
			mGetDataLogic.loadRecordItem(recordSamp.getRecordInfoId(),mContext.isShareModel());
		}

	}

	private void initWidgets() {
		mContentView = mView.findViewById(R.id.ll_recorditem_content);
		mBaseInfoTitle = (TextView) mView
				.findViewById(R.id.tv_brow_recorditem_title);
		mOpenBtn = (Button) mView.findViewById(R.id.btn_brow_open_base_info);
		mBaseInfo = (TextView) mView.findViewById(R.id.tv_brow_item_base_info);
		mBaseInfoButton = mView.findViewById(R.id.fl_recorditem_basebtn);
		mDetailInfoFrame = (FrameLayout) mView
				.findViewById(R.id.fl_brow_item_detail_info);
		mBaseInfoFrame = (FrameLayout) mView
				.findViewById(R.id.fl_brow_item_base_info);
		mImagesListView = (HorizontalListView) mView
				.findViewById(R.id.lv_master_introduce_food);
		mSaveButton = mView.findViewById(R.id.tv_topbar_right);
		mImagesListView
				.setAdapter(mImagesAdapter = new CommonAdapter<PhotoRecord>(
						mContext, R.layout.item_recorditem_photo_thumb) {
					@Override
					public void convert(int position, final ViewHolder helper,
							final PhotoRecord photo) {
						final PhotoView photoView = ((PhotoView) helper.getView(R.id.iv_brow_photo));
						if(photo.isShared()){//mRecordItem.isShareModel() || mRecordItem.isShared()||
							Bitmap bm = BitmapManager.decodeSampledBitmapFromFile(R.drawable.btn_record_album, 2);
							photoView.setImageBitmap(bm);
						}else{
							photoView.setScaleType(ScaleType.CENTER_CROP);
							photoView.loadImageThumbByPhoto(photo);
						}
					}
				});
	}

	public boolean isShowBaseInfo() {
		return isShowBaseInfo;
	}

	public void showBaseInfo(boolean isShow) {
		mOpenBtn.setSelected(isShow);
		mBaseInfoFrame.setVisibility(isShow?View.VISIBLE:View.GONE);
		isShowBaseInfo = isShow;
	}

	private void initListener() {
		OnClickListener baseBtnListener = new OnClickListener() {
			public void onClick(View v) {
				if (mOpenBtn.isSelected()) {
					showBaseInfo(false);
				} else {
					showBaseInfo(true);
				}
			}
		};
		mView.findViewById(R.id.ll_brow_recorditem_baseinfo)
				.setOnClickListener(baseBtnListener);
		mOpenBtn.setOnClickListener(baseBtnListener);

		mImagesListView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				Intent intent = new Intent(mContext, ViewPagerActivity.class);
//				intent.putExtra("record_id", mContext.getRecordId());
//				intent.putExtra("image_title", "查看原图");
				intent.putExtra("record_info_id", mRecordItem.getRecordInfoId());

				int imageId = mRecordItem.getPhotos().get(position).getImageId();
				intent.putExtra("iamge_id", imageId);
				
				ArrayList<PhotoRecord> photos = new ArrayList<PhotoRecord>();
				ArrayList<RecordItemSamp> items = mContext.getItemSamps();
				
				for(int i = 0; i < items.size(); i++){
					/*if(mContext.isShareModel() && !items.get(i).isShared()){
						PhotoRecord photo = new PhotoRecord();
						photo.setIsShared(true);
						photos.add(photo);
					}else{
					}*/
					photos.addAll(items.get(i).getPhotos());
				}
				intent.putExtra("record_images", photos);
				
				mContext.startActivityForResult(intent,
						BrowRecordItemActivity.INTENT_REQ_IMAGE);
			}
		});

		mSaveButton.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				saveEdit();
			}
		});

		mView.findViewById(R.id.img_topbar_left).setOnClickListener(
			new OnClickListener() {
				public void onClick(View v) {
					onBack();
				}
			});
		}

	public boolean isEdit() {
		return mRecordItemView == null ? false : mRecordItemView.isEdit();
	}

	/**
	 * 设置基本信息显示的title
	 * 
	 * @param title
	 */
	public void setBaseInfoTitle(String title) {
		mBaseInfoTitle.setText(title);
	}

	/**
	 * 设置基本信息显示的title
	 * 
	 * @param id
	 */
	public void setBaseInfoTitle(int id) {
		mBaseInfoTitle.setText(id);
	}

	/**
	 * 是否隐藏基本信息
	 * 
	 * @param isHint
	 */
	public void isHintBaseInfo(boolean isHint) {
		LinearLayout baseInfoLayout = (LinearLayout) mView
				.findViewById(R.id.fl_recorditem_basebtn);
		if (isHint) {
			baseInfoLayout.setVisibility(View.GONE);
		} else {
			baseInfoLayout.setVisibility(View.VISIBLE);
		}
	}

	/**
	 * 设置基本信息显示的内容
	 * 
	 * @param info
	 */
	public void setBaseInfo(String info) {
		mBaseInfo.setText(info);
	}

	public void setBaseInfo(JSONArray jsonInfo) {
		for (int i = 0; i < jsonInfo.length(); i++) {
			try {
				JSONObject json = jsonInfo.getJSONObject(i);
				Iterator<String> keys = json.keys();
				while (keys.hasNext()) {
					String key = keys.next();
					if("index".equals(key))continue;//这个字段只是用于排序，不需要显示出来
					String value = json.getString(key);
					if (value != null) {
						value = value.replace("：", "");// 临时解决服务器返回数据多一个“：”
					}
					mBaseInfo.append(key + ":" + value + "\n");
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
	}

	/**
	 * 设置图片adapter的数据集
	 * 
	 * @param mList
	 *//*
	public void setImgDatas(ArrayList<PhotoRecord> mList) {
		mImagesAdapter.addDatas(mList);
		if (mRecordItem != null && mRecordItem.getPhotos().size() == 0) {
			mRecordItem.setPhotos(mList);
		}
	}*/

	/**
	 * 设置所有需要显示的信息
	 */
	public void initAllInfo() {
		showContent(true);

		mImagesAdapter.addDatas(mRecordItem.getPhotos());
//		setImgDatas(mRecordItem.getPhotos());

		//无论是否属于分享记录，都显示出来
//		if(!recordSamp.isShared()){
		setBaseInfo(mRecordItem.getBaseInfo());
		if (mRecordItem.getRecordType() == RecordConstants.TYPE_MEDICAL_IMAGING) {// 检查
			setBaseInfoTitle("报告内容");
		}
//		}
		
		mRecordItemView = SampleFactory.getInstance(mContext,mRecordItem);
		mDetailInfoFrame.removeAllViews();
		mDetailInfoFrame.addView(mRecordItemView.getRecordItemView());
		mRecordItemView.OnJoinEditListener(new JoinEditStateCallBack() {
			public void joinEditState() {
				mRecordItemView.setEditState(true);
				mContext.setViewPagerScroll(false);
				mSaveButton.setVisibility(View.VISIBLE);
				if (mOpenBtn.isSelected()) {
					showBaseInfo(false);
				}
			}
			public void showMuLuView(){
				if (mOpenBtn.isSelected()) {
					showBaseInfo(false);
				}
			}
		});
		mRecordItemView.setDatas(mRecordItem);
	}

	/*
	 * public void getImages(int recordItemId, final BrowRecordItemView
	 * itemView) { if (mGetImageLogic == null) { mGetImageLogic = new
	 * GetImagePathLogic(new ImagePathCallBack() {
	 * 
	 * @Override public void doback(ArrayList<PhotoRecord> photos) {
	 * itemView.setImgDatas(photos); } }); }
	 * mGetImageLogic.getImagePath(recordItemId); }
	 */

	public void setHorizontalTouch(ViewPager viewPager) {
		mImagesListView.setViewPager(viewPager);
	}

	public void exitEditState() {
		mRecordItemView.setEditState(false);
		mContext.setViewPagerScroll(true);
		mSaveButton.setVisibility(View.GONE);
	}

	public void saveEdit() {
		mRecordItemView.saveEdit();
		exitEditState();
		if (mRecordItem.getRecordType() == RecordConstants.TYPE_EXAMINATION) {
			modify(3, mRecordItem.getExams());
		} else {
			modify(2, mRecordItem.getNoteInfo().toString());
		}
	}

	public void onBack() {
		if (mOpenBtn.isSelected()) {
			showBaseInfo(false);
			return;
		}
		if (mRecordItemView != null && mRecordItemView.isEdit()) {
			showEditDialog();
		} else {
			mContext.finish();
		}
	}

	public void showEditDialog() {
		mRecordItemView.exitEdit();
		mEditDialog = new CustomDialog(mContext);
		mEditDialog.setMessage("是否保存正在编辑的病历？");
		mEditDialog.setPositiveListener(R.string.btn_save,
				new OnClickListener() {
					public void onClick(View v) {
						dismissEditDialog();
						saveEdit();
					}
				});
		mEditDialog.setNegativeButton(R.string.btn_cancel,
				new OnClickListener() {
					public void onClick(View v) {
						dismissEditDialog();
						mRecordItemView.cancelEdit();
						exitEditState();
					}
				});
	}

	public void dismissEditDialog() {
		if (mEditDialog == null)
			return;
		mEditDialog.dismiss();
		mEditDialog = null;
	}

	private CustomProgressDialog dialog;

	/**
	 * 修改病历记录数据
	 * 
	 * @param type
	 *            修改数据的类型 1基本信息 2详细信息(note_info) 3化验数据
	 * @param obj
	 *            如果type为1、2则是String 3则是JsonArray
	 */
	public void modify(int type, Object obj) {
		dialog = new CustomProgressDialog(mContext);
		dialog.setMessage("正在提交数据");
		new GetRecordItemLogic().modifyRecordItem(
				mRecordItem.getRecordInfoId(), type, obj, this);
	}

	@Override
	public void doBack(boolean isb) {
		if (dialog != null) {
			dialog.dismiss();
			dialog = null;
		}
		if (!isb) {
			UITools.showToast("提交失败");
		}
	}

}
