package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import android.app.Activity;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.Button;
import android.widget.GridView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.RecordItemSamp;
import com.fq.halcyon.entity.RecordType;
import com.fq.halcyon.logic2.GetRecordTypeListLogic;
import com.fq.halcyon.logic2.GetRecordTypeListLogic.LoadRecordTypesCallBack;
import com.fq.halcyon.logic2.RemoveRecordItemLogic;
import com.fq.halcyon.logic2.RemoveRecordItemLogic.RemoveItemCallBack;
import com.fq.halcyon.logic2.UploadRecordLogic;
import com.fq.halcyon.uimodels.OneCopy;
import com.fq.halcyon.uimodels.OneType;
import com.fq.lib.record.RecordCache;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.record.RecordTool;
import com.fq.lib.record.SnapPhotoManager;
import com.fq.lib.tools.TimeFormatUtils;
import com.hp.android.halcyon.adapter.RecordOneCopyAdapter;
import com.hp.android.halcyon.widgets.ClickGridView;
import com.hp.android.halcyon.widgets.ClickGridView.OnTouchBlankPositionListener;
import com.hp.android.halcyon.widgets.LoadingView;

public class BrowRecordActivity extends BaseActivity implements
		OnClickListener, OnItemClickListener, OnItemLongClickListener,
		LoadRecordTypesCallBack, RemoveItemCallBack {

	private static final int REQUESTCODE_TAKE_PHOTO = 1;
	private static final int REQUESTCODE_BROWSE_MORE = 2;

	public static final int STATE_NORMAL = 0;
	public static final int STATE_DEL = 1;

	private int STATE;

	private GetRecordTypeListLogic mLogic;
	private UploadRecordLogic mUploadLogic;
	private RemoveRecordItemLogic mRemoveLogic;

	private static ArrayList<RecordType> mRecordTypes;
	
	private int mRecordType;
	private static int mRecordId;
	
	private LoadingView mLoadingView;
	
//	private PatientCtrlView mCtrlView;
	/**
	 * 是否为去身份化查看数据(分享模式)
	 * false：不去身份化
	 * true：去身份化
	 */
	private static boolean isShareModel = false;

	HashMap<RecordType, RecordOneCopyAdapter> mAdapterMaps = new HashMap<RecordType, RecordOneCopyAdapter>();
	HashMap<RecordType, Button> mMoreButtons = new HashMap<RecordType, Button>();

	private LinearLayout mContainerLinear;

	@Override
	public int getContentId() {
		return R.layout.activity_brow_record;
	}

	public static ArrayList<RecordType> getRecordTypes(){
		return mRecordTypes;
	}
	
	@Override
	public void init() {
		mRecordId = getIntent().getIntExtra("docId", 0);
		mRecordType = getIntent().getIntExtra("docType",RecordConstants.RECORD_TYPE_ADMISSION);
		isShareModel = getIntent().getBooleanExtra("isOnlyInfo", false);
		
		String recordName = getIntent().getStringExtra("docName");
		setTitle(recordName);
		
		mLoadingView = (LoadingView) findViewById(R.id.ldv_brow_record_progress);
		// String title = "住院病历";
		// if (mRecordType == RecordConstants.RECORD_TYPE_DOORCASE) title =
		// "门诊病历";
		// ((TextView)
		// findViewById(R.id.tv_brow_record_doc_title)).setText(title);
		mLogic = new GetRecordTypeListLogic(this);
		mLogic.loadRecordTypes(mRecordId,isShareModel);
		
		RecordCache.initCache(mRecordId,mRecordType);
	}

	/**
	 * 加载数据后，初始化UI
	 */
	public void updateUI() {
		if (mContainerLinear == null) {
			mContainerLinear = (LinearLayout) findViewById(R.id.ll_brow_record_container);
			// 点击空白处退出删除模式
			mContainerLinear.setOnClickListener(new OnClickListener() {
				public void onClick(View v) {
					if (STATE == STATE_DEL) {
						STATE = STATE_NORMAL;
						updateUIState();
					}
				}
			});
		}
		mContainerLinear.removeAllViews();
		for (int i = 0; i < mRecordTypes.size(); i++) {
			RecordType type = mRecordTypes.get(i);

			View view = LayoutInflater.from(BrowRecordActivity.this).inflate(
					R.layout.item_brow_record_onecopy_layout, null);

			((TextView) view.findViewById(R.id.tv_brow_record_title))
					.setText(RecordConstants.getTypeNameByRecordType(type
							.getRecordType()));

			RecordOneCopyAdapter adapter = mAdapterMaps.get(type);
			if (adapter == null) {
				adapter = new RecordOneCopyAdapter(BrowRecordActivity.this,
						type);
				mAdapterMaps.put(type, adapter);
			}

			ClickGridView gridView = (ClickGridView) view
					.findViewById(R.id.gv_brow_record_types);
			gridView.setTag(type);
			gridView.setAdapter(adapter);
			gridView.setOnItemClickListener(this);
			gridView.setOnItemLongClickListener(this);
			gridView.setOnTouchBlankPositionListener(new OnTouchBlankPositionListener() {
				public boolean onTouchBlankPosition() {
					onCancel(null);
					return true;
				}
			});

			Button btn = mMoreButtons.get(type);
			if (btn == null) {
				btn = (Button) view.findViewById(R.id.btn_expand_add_copy);
				mMoreButtons.put(type, btn);
			}
			btn.setOnClickListener(this);
			btn.setTag(i);
			if (type.getItemList().size() > RecordOneCopyAdapter.SHOW_NUM) {
				btn.setVisibility(View.VISIBLE);
			} else {
				btn.setVisibility(View.GONE);
			}
			mContainerLinear.addView(view);
		}
	}

	/**
	 * 检查显示[查看更多]按钮<br/>
	 * 如果病历类型里的记录大于3条，则显示[查看更多]按钮
	 * 
	 * @param type
	 *            病历的类型
	 */
	private void checkMoreButton(RecordType type) {
		Button btn = mMoreButtons.get(type);
		if (type.getItemList().size() > RecordOneCopyAdapter.SHOW_NUM) {
			btn.setVisibility(View.VISIBLE);
		} else {
			btn.setVisibility(View.GONE);
		}
	}

	@Override
	protected void onResume() {
		super.onResume();
//		mLogic.loadRecordTypes(mRecordId);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		
		mRecordTypes = null;
		//退出这个病历浏览界面时，BrowRecordItemActivity里面缓存的这个病历下的所有记录数据
		RecordCache.clearCache();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		//从照相界面返回
		if (requestCode == REQUESTCODE_TAKE_PHOTO && resultCode == SnapPicActivity.ON_PHOTO_SELECTED) {
			synchronized (BrowRecordActivity.this) {
				SnapPhotoManager snap = SnapPhotoManager.getInstance();
				ArrayList<OneType> tps = snap.getTypes();//(ArrayList<OneType>) data.getSerializableExtra("types");
				boolean isUPload = updateDateUIFromSnapActivity(tps);
				if (isUPload)upLoadRecord(tps);
				STATE = STATE_NORMAL;
				updateUIState();
				snap.clear();
			}
		}
		//从更多界面返回
		else if(requestCode == REQUESTCODE_BROWSE_MORE && resultCode == BrowRecordItemSampMore.RESULT_CODE){
			STATE = STATE_NORMAL;
			updateUIState();
//			RecordType type = (RecordType) data.getSerializableExtra("record_types");
			for(int i = 0; i < mRecordTypes.size(); i++){
				RecordType oldType = mRecordTypes.get(i);
				checkMoreButton(oldType);
				//因为mRecordTypes改为静态参数，所以下方的代码不需要了
//				if(oldType.getRecordType() == type.getRecordType()){
//					oldType.getItemList().clear();
//					oldType.getItemList().addAll(type.getItemList());
//					checkMoreButton(oldType);
//					break;
//				}
			}
		}
	}

	/**
	 * 从拍摄界面界面返回, 返回数据ArrayList<oneType>,将oneType里面的oneCopy<br>
	 * 添加到对应RecordType的ArrayList<RecordItemSamp>里,因为OneCopy与RecordItemSamp<br/>
	 * 不同类型，所以需要new一个RecordItemSamp，然后把参数复制过去。复制完数据后刷新界面...
	 */
	private boolean updateDateUIFromSnapActivity(ArrayList<OneType> tps){
		boolean isUPload = false;
		for (int i = 0; i < tps.size(); i++) {
			OneType type = tps.get(i);
			if (type.getPhotoCounter() > 0) {
				for (int j = 0; j < mRecordTypes.size(); j++) {
					RecordType oldType = mRecordTypes.get(j);

					if (oldType.getRecordType() == type.getType()) {
						ArrayList<OneCopy> copys = type.getAllCopies();
						for (int k = 0; k < copys.size(); k++) {
							if (copys.get(k).getPhotos().size() > 0) {
								isUPload = true;
								upLoadRecord(tps);
								RecordItemSamp item = new RecordItemSamp();
								item.setRecStatus(RecordItemSamp.REC_UPLOAD);
								item.setPhotos(copys.get(k).getPhotos());
								item.setImageCount(copys.get(k).getPhotos().size());
								item.setUploadTime(TimeFormatUtils
										.getTimeByFormat(System
												.currentTimeMillis(),
												"yyyyMMdd HH:mm"));
								oldType.getItemList().add(0, item);

								checkMoreButton(oldType);
							}
						}
						break;
					}
				}
			}
		}
		return isUPload;
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
	 * 一个病历记录子项被点击
	 */
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		RecordType type = (RecordType) ((GridView) parent).getTag();
		// add按钮，去拍照
		if (position == type.getItemList().size()
				|| position == RecordOneCopyAdapter.SHOW_NUM) {
			Intent intent = new Intent(BrowRecordActivity.this,SnapPicActivity.class);
			intent.putExtra("docType", mRecordType);// 病案类型
			intent.putExtra("itemType", type.getRecordType());// 病历记录类型
			intent.putExtra("record_id", mRecordId);
			for(int i = 0; i < mRecordTypes.size(); i++){
				RecordType rtp = mRecordTypes.get(i);
				if(rtp.getRecordType() == RecordConstants.TYPE_ADMISSION 
						&& rtp.getItemList().size() > 0){
					intent.putExtra("is_admissin_enough", true);
				}else if(rtp.getRecordType() == RecordConstants.TYPE_DISCHARGE 
						&& rtp.getItemList().size() > 0)
					intent.putExtra("is_discharge_enough", true);
			}
			
			startActivityForResult(intent, REQUESTCODE_TAKE_PHOTO);
			return;
		}

		RecordItemSamp item = type.getItem(position);
		if (STATE == STATE_DEL) {
			deleteRecordItem(type, item);
		} else {
			onSampClick(this, item);
		}
	}

	/**
	 * 因为更多界面也有这个功能，所以写成静态的 病历记录的子项被点击后实现跳转，分四种情况：<br/>
	 * 1.病历记录在上传阶段；2.病历记录正在识别；<br/>
	 * 3.病历记录识别失败；4病历记录识别通过
	 * 
	 * @param context
	 * @param itemSamp
	 *            病历记录（简洁）子项
	 *  @param type
	 *  @param position 
	 */
	public static void onSampClick(Activity context, RecordItemSamp itemSamp) {
		Intent intent = new Intent();
		if (itemSamp.getRecStatus() == RecordItemSamp.REC_FAIL) {
			intent.putExtra("record_type_item", itemSamp);
			intent.setClass(context, BrowImageRecordActivity.class);
		} else if (itemSamp.getRecStatus() == RecordItemSamp.REC_SUCC) {
			ArrayList<RecordItemSamp> itemList = RecordTool.getAllRecRecord(mRecordTypes);
			intent.putExtra("record_id", mRecordId);
			intent.putExtra("record_type_item", itemList);
			intent.putExtra("clickPosition", itemList.indexOf(itemSamp));
			intent.putExtra("isOnlyInfo", isShareModel);
			intent.setClass(context, BrowRecordItemActivity.class);
		} else if (itemSamp.getRecStatus() == RecordItemSamp.REC_UPLOAD) {
			intent.putExtra("photo_array", itemSamp.getPhotos());
			intent.putExtra("image_title", "浏览识别中病历");
			intent.setClass(context, BrowImageActivity.class);
		} else {
			intent.putExtra("record_item_id", itemSamp.getRecordItemId());
			intent.putExtra("image_title", "浏览识别中病历");
			intent.setClass(context, BrowImageActivity.class);
			context.startActivityForResult(intent, REQUESTCODE_TAKE_PHOTO);
			return;
		}
		context.startActivity(intent);
	}

	/**
	 * 长按病历记录（简洁）时调用
	 */
	@Override
	public boolean onItemLongClick(AdapterView<?> parent, View view,
			int position, long id) {
		if (STATE == STATE_DEL)
			return true;
		STATE = STATE_DEL;
		updateUIState();
		return true;
	}

	public void onCancel(View v){
		if (STATE == STATE_DEL){
			STATE = STATE_NORMAL;
			updateUIState();
		}
	}
	
	/**
	 * 点击[查看更多]按钮时调用
	 */
	@Override
	public void onClick(View v) {
//		RecordType type = (RecordType) v.getTag();
		int id = (Integer) v.getTag();
		Intent intent = new Intent(BrowRecordActivity.this,
				BrowRecordItemSampMore.class);
//		intent.putExtra("recordItemType", type);
		intent.putExtra("recordItemTypeId", id);
		startActivityForResult(intent, REQUESTCODE_BROWSE_MORE);
	}

	/**
	 * 进入界面时调用，初始化数据失败
	 */
	@Override
	public void loadRecordTypesError(int code, String msg) {
		mLoadingView.dismiss();
		Toast.makeText(this, "加载数据失败...", Toast.LENGTH_SHORT).show();
	}

	/**
	 * 进入界面时调用，初始化数据
	 */
	@Override
	public void loadRecordTypesResult(int code,
			ArrayList<RecordType> mResultList) {
		mLoadingView.dismiss();
		mRecordTypes = mResultList;
		int[] types = RecordConstants.getTypesByRecordType(mRecordType);
		// 补充数据
		for (int i = 0; i < types.length; i++) {
			int id = types[i];
			boolean isExits = false;
			for (int j = 0; j < mRecordTypes.size(); j++) {
				RecordType type = mRecordTypes.get(j);
				if (type.getRecordType() == id) {
					mRecordTypes.remove(type);
					mRecordTypes.add(i, type);
					isExits = true;
					break;
				}
			}
			if (!isExits) {
				RecordType type = new RecordType();
				type.setRecordType(id);
				mRecordTypes.add(i, type);
			}
		}
		updateUI();
	}

	@Override
	public void onBackPressed() {
		if (STATE == STATE_DEL) {
			STATE = STATE_NORMAL;
			updateUIState();
			return;
		}
		super.onBackPressed();
	}

	/**
	 * 更新UI的状态：普通模式还是删除模式
	 */
	private void updateUIState() {
		Iterator<RecordType> itor = mAdapterMaps.keySet().iterator();
		while (itor.hasNext()) {
			RecordOneCopyAdapter adaptar = mAdapterMaps.get(itor.next());
			adaptar.setState(STATE);
			adaptar.notifyDataSetChanged();
		}
	}

	/**
	 * 删除一个病历记录（简介）
	 * 
	 * @param type
	 *            病历记录（简介）属于哪一个病历
	 * @param item
	 *            需要删除的病历记录（简介）
	 */
	private void deleteRecordItem(RecordType type, RecordItemSamp item) {
		if (mRemoveLogic == null) {
			mRemoveLogic = new RemoveRecordItemLogic(this);
		}
		mRemoveLogic.removeRecordItem(item.getRecordItemId());

		type.getItemList().remove(item);
		mAdapterMaps.get(type).notifyDataSetChanged();
	}

	@Override
	public void doRemoveback(int record, boolean isSuccess) {

	}
}
