package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationUtils;
import android.view.animation.TranslateAnimation;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.fq.halcyon.HalcyonUploadLooper;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.halcyon.entity.RecordType;
import com.fq.halcyon.logic2.GetRecordTypeListLogic;
import com.fq.halcyon.logic2.GetRecordTypeListLogic.LoadRecordTypesCallBack;
import com.fq.halcyon.logic2.UploadRecordLogic;
import com.fq.halcyon.uimodels.OneType;
import com.fq.lib.record.RecordCache;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.record.RecordTool;
import com.fq.lib.record.RecordUploadNotify;
import com.fq.lib.record.SnapPhotoManager;
import com.fq.lib.tools.BaiduAnalysis;
import com.hp.android.halcyon.util.BaiDuTJSDk;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.view.PatientCtrlView;
import com.hp.android.halcyon.view.PatientCtrlView.PatiantCtrlViewClickListener;
import com.hp.android.halcyon.view.RecordItemCardView;
import com.hp.android.halcyon.view.RecordItemCardView.DelItemCallBack;
import com.hp.android.halcyon.view.RecordItemCardView.OnCardItemClickListener;
import com.hp.android.halcyon.view.RecordItemCardView.OnCardItemSelectedListener;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

/**
 * 浏览病历界面，用于显示一份病历下面的所有病历记录（按类型分类），需要传入参数：<br/>
 *  docId:病历的id；<br/>
 * docType:病历的类型（住院、门诊）<br/>
 * docName:病历名称；
 * <br/>isOnlyInfo:是否只看信息（用于查看分享病历时）<br/>
 * 
 * @author reason
 * @version v3.0.2 2015-03-26
 */
public class BrowRecordActivity2 extends BaseActivity implements LoadRecordTypesCallBack{

	/**从浏览病历界面到拍照的request_code*/
	private static final int REQUESTCODE_TAKE_PHOTO = 1;
	
	/**该病历的id*/
	private int mRecordId;
	
	/**该病历的类型：住院|门诊*/
	private int mRecordType;
	
	/**是否是查看分享状态的病历*/
	private boolean isShareModel;
	
	/**获取到的病历下病历记录的列表*/
	private ArrayList<RecordType> mRecordTypes;
	
	/**用于显示并切换病历（记录的）类型*/
	private ViewPager mViewPager;
	private CustomProgressDialog mProgressDialog;
	
	/**病历类型适配器，用于最上方ViewPager*/
	private PageAdapter mAdapter;
	
	/**病历记录的父控件*/
	private FrameLayout mItemCard;
	/**病历记录卡片切换控件*/
	private RecordItemCardView cardView;
	/**操作病历记录控件*/
	private PatientCtrlView mCtrlView;
	
	/**上传病历（记录）逻辑*/
	private UploadRecordLogic mUploadLogic;
	
	@Override
	public int getContentId() {
		return R.layout.activity_brow_record2;
	}

	@Override
	public void init() {
		mRecordId = getIntent().getIntExtra("docId", 0);
		mRecordType = getIntent().getIntExtra("docType",RecordConstants.RECORD_TYPE_ADMISSION);
		isShareModel = getIntent().getBooleanExtra("isOnlyInfo", false);
		
		setTitle(getIntent().getStringExtra("docName"));
		mItemCard = getView(R.id.fl_brow_recordItem_card);
		
		cardView = new RecordItemCardView(BrowRecordActivity2.this);
		mItemCard.addView(cardView);

		//---------------------------------------------------------------------------
		mViewPager = (ViewPager) findViewById(R.id.vp_brow_recordItem_content);
		if(mRecordId != 0){
			mProgressDialog = new CustomProgressDialog(this);
			mProgressDialog.setMessage("正在加载数据...");
			GetRecordTypeListLogic logic = new GetRecordTypeListLogic(this);
			logic.loadRecordTypes(mRecordId,isShareModel);
		}
		
		//为实现无限循环
		mViewPager.setOnPageChangeListener(new OnPageChangeListener() {
			public void onPageScrolled(int arg0, float arg1, int arg2) {}
			public void onPageScrollStateChanged(int arg0) {}
			public void onPageSelected(int i) {
				int pageIndex = i;  
		        if (i == 0) {// 当视图在第一个时，将页面号设置为图片的最后一张。  
		            pageIndex = mRecordTypes.size();  
		        } else if (i == mRecordTypes.size() + 1) { //当视图在最后一个是,将页面号设置为图片的第一张。  
		            pageIndex = 1;  
		        }  
		        if (i != pageIndex) {  
		            mViewPager.setCurrentItem(pageIndex, false);  
		            return;  
		        }  
		        cardView.scrollToSelectType(mRecordTypes.get(pageIndex-1));
			}
		});
		
		//初始化病历记录数据缓存
		RecordCache.initCache(mRecordId,mRecordType);
		
		//初始化病历记录图片上传完成后通知
		RecordUploadNotify.inistance();
	}
	
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		//退出这个病历浏览界面时，BrowRecordItemActivity里面缓存的这个病历下的所有记录数据
		RecordCache.clearCache();
		
		//退出这个病历浏览界面时，取消监听这个病历下记录正在上传的图片上传完成后的事件
		RecordUploadNotify.getInstance().clear();
	}
	
	
	/**
	 * 点击上方拍照
	 */
	public void onPhoto(View v){
		RecordType type = mAdapter.getCurrenItem();
		
		if(type.getItem(0).getRecStatus() != RecordItemSamp.REC_NONE_DATA && !RecordTool.isTypeCatch(type)){
			String msg = null;
			if(type.getRecordType() == RecordConstants.TYPE_ADMISSION){
				msg = "一份病历只能拍摄一份入院记录";
			}else if(type.getRecordType() == RecordConstants.TYPE_DISCHARGE){
				msg = "一份病历只能拍摄一份出院记录";
			}
			UITools.showToast(msg);
		}else{
			Intent intent = new Intent(BrowRecordActivity2.this,SnapPicActivity.class);
			intent.putExtra("itemType", type.getRecordType());// 病历记录类型
			for(int i = 0; i < mRecordTypes.size(); i++){
				RecordType rtp = mRecordTypes.get(i);
				if(rtp.getRecordType() == RecordConstants.TYPE_ADMISSION 
						&& rtp.getItem(0).getRecStatus() != RecordItemSamp.REC_NONE_DATA){
					intent.putExtra("is_admissin_enough", true);
				}else if(rtp.getRecordType() == RecordConstants.TYPE_DISCHARGE 
						&& rtp.getItem(0).getRecStatus() != RecordItemSamp.REC_NONE_DATA)
					intent.putExtra("is_discharge_enough", true);
			}
			startActivityForResult(intent, REQUESTCODE_TAKE_PHOTO);
		}
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == REQUESTCODE_TAKE_PHOTO && resultCode == SnapPicActivity.ON_PHOTO_SELECTED) {
			synchronized (BrowRecordActivity2.this) {
				SnapPhotoManager snap = SnapPhotoManager.getInstance();
				ArrayList<OneType> tps = snap.getRealyTypes();//(ArrayList<OneType>) data.getSerializableExtra("types");
				if(tps.size() > 0){
					//百度统计，上传病历记录事件，label为上传记录的份数
					BaiDuTJSDk.onEvent(BaiduAnalysis.EVENT_UPLOAD_RECORD, tps.size()+"");
					
					RecordTool.updateDataFromSnap(mRecordTypes, tps);
					mAdapter.refreshCurrenView();
					cardView.addDatas(mRecordTypes);
					upLoadRecord(tps);
					RecordCache.getInstance().setUnUploadTypes(null);
					snap.clear();
				}
			}
		}
	}
	
	/**
	 * 上传拍摄的病历到服务器
	 * 
	 * @param types
	 */
	private void upLoadRecord(ArrayList<OneType> types) {
		if (mUploadLogic == null) {
			mUploadLogic = new UploadRecordLogic();
		}
		mUploadLogic.upLoad("", mRecordId, types);
	}
	
	/**
	 * 病历下类型的适配器
	 * @author reason
	 */
	class PageAdapter extends PagerAdapter{
		private ArrayList<View> mViews = new ArrayList<View>();
		
		public PageAdapter(){
			for(int i = 0; i < mRecordTypes.size()+2; i++){
				View v = LayoutInflater.from(BrowRecordActivity2.this).inflate(R.layout.item_brow_record_type, null);
				mViews.add(v);
			}
		}
		
		public int getDataIndex(int position){
			if (position == 0) {  
				return mRecordTypes.size()-1;
            } else if (position == (mViews.size() - 1)) { 
            	return 0;
            }
			return position - 1;
		}
		
		public RecordType getCurrenItem(){
			return mRecordTypes.get(getDataIndex(mViewPager.getCurrentItem()));
		}
		
		@Override
		public int getCount() {
			return mViews.size();
		}

		@Override
		public boolean isViewFromObject(View arg0, Object arg1) {
			return arg0 == arg1;
		}
		
		public void refreshCurrenView(){
			int position = mViewPager.getCurrentItem();
			fillData2View(getDataIndex(position),mViews.get(position));
			fillData2View(getDataIndex(position-1),mViews.get(position-1));
			fillData2View(getDataIndex(position+1),mViews.get(position+1));
		}
		
		@Override
		public Object instantiateItem(ViewGroup container, int position) {
			View v = mViews.get(position);

			int index = getDataIndex(position);
			fillData2View(index, v);
			
			container.addView(v);
			return v;
		}
		
		@Override  
        public void destroyItem(ViewGroup container, int position, Object object) {  
            container.removeView(mViews.get(position));  
        }  
		
		public void fillData2View(int index,View v){
			TextView middle = (TextView)v.findViewById(R.id.tv_brow_record_middle);
			TextView befo = (TextView)v.findViewById(R.id.tv_brow_record_befo);
			TextView after = (TextView)v.findViewById(R.id.tv_brow_record_after);
			
			RecordType type = mRecordTypes.get(index);
			String count = "("+type.getItemList().size()+")";
			if(type.getItem(0).getRecStatus() == RecordItemSamp.REC_NONE_DATA)count = "(0)";
			middle.setText(RecordConstants.getTypeTitleByRecordType(type.getRecordType())+count);
			
			int bf = index - 1;
			if(bf < 0) bf = mRecordTypes.size() - 1;
			befo.setText(RecordConstants.getTypeTitleByRecordType(mRecordTypes.get(bf).getRecordType()));
			
			int af = index + 1;
			if(af == mRecordTypes.size()) af = 0;
			after.setText(RecordConstants.getTypeTitleByRecordType(mRecordTypes.get(af).getRecordType()));
		}
	}
	
	

	/**
	 * 隐藏加载对话框
	 */
	private void dismissDialog(){
		if(mProgressDialog != null){
			runOnUiThread(new Runnable() {
				public void run() {
					mProgressDialog.dismiss();
					mProgressDialog = null;
				}
			});
		}
	}
	
	/**
	 * 获得病历下记录数据失败后回调
	 */
	@Override
	public void loadRecordTypesError(int code, String msg) {
		dismissDialog();
		Toast.makeText(this, "加载数据失败...", Toast.LENGTH_SHORT).show();
	}

	/**
	 * 获得病历下记录数据成功后回调
	 */
	@Override
	public void loadRecordTypesResult(int code,
			ArrayList<RecordType> mResultList) {
		mRecordTypes = mResultList;
		
		// 补充并格式化数据,主要是排序和添加没有的病历类型（入院、出院、检查等）
		RecordTool.addAndFormatTypes(mRecordType, mRecordTypes);
		
		// 把正在上传的也加入进来，并放到每份的最前面
		RecordTool.addUploadReocrd(mRecordId, mRecordTypes);
		
		//如果有的类型的病历里面没有记录，则构造一个假的记录用于UI显示
		for(int i = 0; i < mRecordTypes.size(); i++){
			RecordTool.checkNewTypes(mRecordTypes.get(i));
		}
		cardView.addDatas(mRecordTypes);
		//初始化适配器
		mAdapter = new PageAdapter();
		mViewPager.setAdapter(mAdapter);
		mViewPager.setCurrentItem(1);
		
		mCtrlView = (PatientCtrlView)findViewById(R.id.pc_brow_record);
		mCtrlView.hintBtnReName();
		mCtrlView.show();
		
		TranslateAnimation animation = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0.0f, Animation.RELATIVE_TO_SELF,
				0.0f, Animation.RELATIVE_TO_SELF, -1.0f,
				Animation.RELATIVE_TO_SELF, 0.0f);
		animation.setDuration(300);
		mViewPager.startAnimation(animation);
		mViewPager.setVisibility(View.VISIBLE);
		
		animation.setAnimationListener(new AnimationListener() {
			public void onAnimationStart(Animation animation) {}
			public void onAnimationRepeat(Animation animation) {}
			public void onAnimationEnd(Animation animation) {
				View carme = findViewById(R.id.fl_brow_record_carmea);
				Animation anim = AnimationUtils.loadAnimation(BrowRecordActivity2.this, R.anim.scale_alpha_in);
				anim.setDuration(400);
				carme.startAnimation(anim);
				carme.setVisibility(View.VISIBLE);
			}
		});
		
		dismissDialog();
		
		mCtrlView.setPatiantCtrlViewClickListener(new PatiantCtrlViewClickListener() {
			//控制点击事件
			@Override
			public void shareCallBack() {
				if (cardView.isScroll()) {
					return;
				}
				//分享
				if (cardView.getSelectedItem().getRecStatus() != RecordItemSamp.REC_SUCC) {
					return;
				}
				Intent intent = new Intent();
				intent.setClass(BrowRecordActivity2.this, SelectShareFriendActivity.class);
				intent.putExtra("shareType", RecordConstants.SHARE_RECORD_ITEM);
				intent.putExtra("shareItem", cardView.getSelectedItem());
				intent.putExtra("record_id", mRecordId);
				startActivity(intent);
			}
			
			@Override
			public void renameCallBack() {
			}
			
			@Override
			public void deleteCallBack() {
				if (cardView.isScroll()) {
					return;
				}
				if (cardView.getSelectedItem().getRecStatus() == RecordItemSamp.REC_NONE_DATA) {
					return;
				}
				cardView.delItem(new DelItemCallBack() {
					//删除记录的回调
					@Override
					public void onDeleteItem(RecordItemSamp itemSamp, boolean isDelSuccess) {
						int type = itemSamp.getRecordType();
						for(RecordType rt:mRecordTypes){
							if(rt.getRecordType() == type){
								if(itemSamp.getUuid() != null && !itemSamp.getUuid().equals("")){
									HalcyonUploadLooper.getInstance().cancelUploadCell(mRecordId, itemSamp.getUuid());
								}
								rt.getItemList().remove(itemSamp);
								RecordTool.checkNewTypes(rt);
								mAdapter.refreshCurrenView();
								cardView.addDatas(mRecordTypes);
								break;
							}
						}
					}
				});
			}
		});
		
		//下方病历记录滑动选中的回调（用于更改上方title类型）
		cardView.setItemSelectedListener(new OnCardItemSelectedListener() {
			public void onItemSelected(RecordItemSamp itemSamp) {
				int currentType = mAdapter.getCurrenItem().getRecordType();
				if(currentType != itemSamp.getRecordType()){
					for(int i = 0; i < mRecordTypes.size(); i++){
						if(mRecordTypes.get(i).getRecordType() == itemSamp.getRecordType()){
							mViewPager.setCurrentItem(++i,false);
							break;
						}
					}
				}
			}
		});
		
		cardView.setCardItemClickListener(new OnCardItemClickListener() {
			//被选中的ITEM的点击事件
			@Override
			public void onItemClick(int position, RecordItemSamp itemSamp) {
				if (itemSamp.getRecStatus() == RecordItemSamp.REC_NONE_DATA) {
					return;
				}
				Intent intent = new Intent();
				if (itemSamp.getRecStatus() == RecordItemSamp.REC_FAIL) {//识别失败的病历记录
					intent.putExtra("record_type_item", itemSamp);
					intent.setClass(BrowRecordActivity2.this, BrowImageRecordActivity.class);
				} else if (itemSamp.getRecStatus() == RecordItemSamp.REC_SUCC) {//识别成功的病历记录
					ArrayList<RecordItemSamp> itemList = RecordTool.getAllRecRecord(mRecordTypes);
					intent.putExtra("record_id", mRecordId);
					intent.putExtra("record_type_item", itemList);
					intent.putExtra("clickPosition", itemList.indexOf(itemSamp));
					intent.putExtra("isOnlyInfo", isShareModel);
					intent.setClass(BrowRecordActivity2.this, BrowRecordItemActivity.class);
				} else if (itemSamp.getRecStatus() == RecordItemSamp.REC_UPLOAD) {//识别中的病历记录
					intent.putExtra("photo_array", itemSamp.getPhotos());
					intent.putExtra("image_title", "浏览识别中病历");
					intent.setClass(BrowRecordActivity2.this, BrowImageActivity.class);
				} else {
					intent.putExtra("record_item_id", itemSamp.getRecordItemId());
					intent.putExtra("image_title", "浏览识别中病历");
					intent.setClass(BrowRecordActivity2.this, BrowImageActivity.class);
					startActivityForResult(intent, REQUESTCODE_TAKE_PHOTO);
					return;
				}
				startActivity(intent);
			}
		});
	}
}
