package com.hp.android.halcyon;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.HalcyonUploadLooper;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.logic.UploadStateLogic;
import com.fq.halcyon.logic.UploadStateLogic.OnGetOnlineStateListener;
import com.fq.halcyon.logic.UploadStateLogic.RecordsState;
import com.fq.halcyon.logic.UploadStateLogic.StateItem;
import com.fq.http.async.uploadloop.LoopCell;
import com.fq.http.async.uploadloop.LoopCellHandle;
import com.fq.http.async.uploadloop.LoopUpLoadCell;
import com.fq.http.async.uploadloop.LoopUpLoadCell.OnUpLoadStateChangedListener;
import com.fq.lib.record.RecordConstants;
import com.hp.android.halcyon.server.HalcyonService;
import com.hp.android.halcyon.server.HalcyonService.OnNetWorkChangedListener;
import com.hp.android.halcyon.util.BitmapCache;
import com.hp.android.halcyon.util.TextFontUtils;
import com.hp.android.halcyon.util.UIRecordImageTool;

public class UploadStateActivity extends BaseActivity implements OnGetOnlineStateListener,OnNetWorkChangedListener{

	public static final String FROME_UPLOADSTATE_ACTIVITY = "form_upload_activity";	

	private ListView mListView;

	private UploadStateAdaper mAdaper;

	private ArrayList<UploadStateLogic.StateItem> mItems;

	private UploadStateLogic mLogic;

	private Comparator<StateItem> mComparator;
	
	@Override
	public int getContentId() {
		return R.layout.activity_upload_statue;
	}
	
	/*@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
	}*/

	@Override
	protected void onResume() {
		super.onResume();
		mItems.clear();
		mAdaper.notifyDataSetChanged();
		ArrayList<LoopCellHandle> loopCellHandles = HalcyonUploadLooper.getInstance().getUploadArray();
		for (int i = 0; i < loopCellHandles.size(); i++) {
			final LoopCellHandle handle = loopCellHandles.get(i);
			LoopCell cell = handle.cell;
			LoopUpLoadCell upLoadCell = (LoopUpLoadCell) cell;
			if (cell instanceof LoopUpLoadCell) {
				Iterator<Integer> iter = cell.records.keySet().iterator();
				while (iter.hasNext()) {
					int key = iter.next();
					final StateItem item = mLogic.new StateItem();
					item.mRecordType = key;
					item.mState = RecordsState.UPLOADING;
					if(handle.mIsPause){
						item.mState = RecordsState.UPLOADING_FAILED;
					}
					item.mTitle = RecordConstants.getTypeTitleByRecordType(key);
					ArrayList<ArrayList<Photo>> photos = cell.records.get(key);
					for (int j = 0; j < photos.size(); j++) {
						for (int j2 = 0; j2 < photos.get(j).size(); j2++) {
							item.mImages.add(photos.get(j).get(j2));
						}
					}
					upLoadCell.setOnUpLoadStateChangedListener(new OnUpLoadStateChangedListener() {

						@Override
						public void onSuccessUpLoadAFile() {
							item.mUploadedCount++;
							if (item.mUploadedCount == item.mTotalCount) {
								item.mState = RecordsState.UPLOADED;
								Collections.sort(mItems, mComparator);
							}
							mAdaper.notifyDataSetChanged();
						}

						@Override
						public void onFaildUpLoadAFile() {
							item.mUpLoadHandle = handle;
							item.mState = RecordsState.UPLOADING_FAILED;
							Collections.sort(mItems, mComparator);
							mAdaper.notifyDataSetChanged();
						}
					});
					mItems.add(item);
					item.mTotalCount = upLoadCell.allFileCount;
					item.mUploadedCount = upLoadCell.uploadedFileCount;
				}
			}
		}
		mLogic.getOnLineStates();
	}
	
	
	@Override
	public void init() {
		HalcyonService.mNetWorkChangedListener = this;
		mComparator = new Comparator<StateItem>() {

			@Override
			public int compare(StateItem lhs, StateItem rhs) {
				if (lhs.mState.ordinal() > rhs.mState.ordinal()) {
					return 1;
				} else if (lhs.mState.ordinal() < rhs.mState.ordinal()) {
					return -1;
				}
				if(lhs.mTime > rhs.mTime){
					return -1;
				}else if(lhs.mTime < rhs.mTime){
					return 1;
				}
				return 0;
			}
		};
		mLogic = new UploadStateLogic(this);
		mItems = new ArrayList<UploadStateLogic.StateItem>();
		mListView = (ListView) findViewById(R.id.lv_education_title);
		mAdaper = new UploadStateAdaper();
		mListView.setAdapter(mAdaper);
	}

	class UploadStateAdaper extends BaseAdapter {
		
		@Override
		public void notifyDataSetChanged() {
			Collections.sort(mItems, mComparator);
//			for (int i = 0; i < mItems.size(); i++) {
//				mItems.get(i).mState = RecordsState.IDENTIFUCATION_FAILED;
//			}
			super.notifyDataSetChanged();
		}

		@Override
		public int getCount() {
			return mItems.size();
		}

		@Override
		public Object getItem(int position) {
			return mItems.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			if (convertView == null) {
				convertView = getLayoutInflater().inflate(R.layout.item_upload_state, null);
				TextView text = (TextView) convertView.findViewById(R.id.item_title);
				Button sureButton = (Button) convertView.findViewById(R.id.bt_sure);
				Button deleButton = (Button) convertView.findViewById(R.id.bt_delete);
				Typeface typeface = TextFontUtils.getTypeface(TextFontUtils.FONT_FZLTJT);
				text.setTypeface(typeface);
				sureButton.setTypeface(typeface);
				deleButton.setTypeface(typeface);
			}
			final StateItem item = mItems.get(position);
			GridView gridView = (GridView) convertView.findViewById(R.id.gridview);
			TextView titleView = (TextView) convertView.findViewById(R.id.item_title);
			TextView countView = (TextView) convertView.findViewById(R.id.textView1);
			TextView stateView = (TextView) convertView.findViewById(R.id.text_state);
			TextView wifiStatueTextView = (TextView) convertView.findViewById(R.id.item_wifi_statue);
			wifiStatueTextView.setVisibility(View.GONE);
			Button sureButton = (Button) convertView.findViewById(R.id.bt_sure);
			Button deleButton = (Button) convertView.findViewById(R.id.bt_delete);
			stateView.setTextColor(Color.DKGRAY);
			sureButton.setText("重试");
			boolean showButtons = false;
			boolean showCount = true;
			if (item.mState == RecordsState.UPLOADED ) {
				showCount = false;
				showButtons = false;
				stateView.setText("等待识别···");
				stateView.setTextColor(0xFF9f9fa0);
			} else if (item.mState == RecordsState.UPLOADING) {
				showCount = true;
				showButtons = false;
				stateView.setText("上传中···");
				if(!HalcyonService.mCurrnetWifiConnected){
					wifiStatueTextView.setVisibility(View.VISIBLE);
				}
				stateView.setTextColor(0xFF9f9fa0);
			} else if (item.mState == RecordsState.UPLOADING_FAILED) {
				showCount = true;
				showButtons = true;
				stateView.setText("上传失败···");
				if(!HalcyonService.mCurrnetWifiConnected){
					wifiStatueTextView.setVisibility(View.VISIBLE);
				}
				stateView.setTextColor(0xFFE95383);
			} else if (item.mState == RecordsState.IDENTIFUCATION) {
				showCount = false;
				showButtons = false;
				stateView.setText("识别中···");
				stateView.setTextColor(0xFF888888);
			} else if (item.mState == RecordsState.IDENTIFUCATION_COMPLETED) {
				showCount = false;
				showButtons = false;
				stateView.setText("已识别");
				stateView.setTextColor(0xFF888888);
			} else if  (item.mState == RecordsState.IDENTIFUCATION_FAILED || item.mState == RecordsState.CANT_IDENTIFUCATION) {
				if(item.mState == RecordsState.CANT_IDENTIFUCATION){
					stateView.setText("无法识别...");
				}else {
					stateView.setText("识别失败...");
				}
				sureButton.setText("重拍");
				stateView.setTextColor(0xFFE95383);
				showCount = false;
				showButtons = true;
			}
			
			if (showCount) {
				countView.setVisibility(View.VISIBLE);
				countView.setText(String.format("%d/%d", item.mUploadedCount, item.mTotalCount));
			} else {
				countView.setVisibility(View.GONE);
			}
			if (showButtons) {
				sureButton.setVisibility(View.VISIBLE);
				deleButton.setVisibility(View.VISIBLE);
				OnClickListener clickListener = new OnClickListener() {
					
					@Override
					public void onClick(View v) {
						if(v.getId() == R.id.bt_sure){
							if(item.mState == RecordsState.UPLOADING_FAILED){
								//重传
								if(item.mUpLoadHandle != null) item.mUpLoadHandle.resume();
								item.mState = RecordsState.UPLOADING;
								mAdaper.notifyDataSetChanged();
							}else if (item.mState == RecordsState.IDENTIFUCATION_FAILED
									||item.mState == RecordsState.CANT_IDENTIFUCATION) {
								//重拍
								mLogic.delete(item);
								Intent intent = new Intent(UploadStateActivity.this,SnapPicActivity.class);
								intent.putExtra(FROME_UPLOADSTATE_ACTIVITY, true);
								startActivity(intent);
							}
						}else if(v.getId() == R.id.bt_delete){
							mItems.remove(position);
							if(item.mState == RecordsState.UPLOADING_FAILED){
								if(item.mUpLoadHandle != null) {
									item.mUpLoadHandle.remove();
								}
							}else {
								mLogic.delete(item);
							}
							mAdaper.notifyDataSetChanged();
						}
					}
				};
				sureButton.setOnClickListener(clickListener);
				deleButton.setOnClickListener(clickListener);
			} else {
				sureButton.setVisibility(View.GONE);
				deleButton.setVisibility(View.GONE);
			}
			String title = item.mTitle.equals("")?RecordConstants.getTypeTitleByRecordType(item.mRecordType):item.mTitle;
			titleView.setText(title);
			gridView.setOnItemClickListener(new OnItemClickListener() {

				@Override
				public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
					ArrayList<String> paths = new ArrayList<String>();
					for (int i = 0; i < item.mImages.size(); i++) {
						Photo photo = item.mImages.get(i);
						String path  = photo.getLocalPath();
						if(path != null && !path.equals("")){
							paths.add(photo.getLocalPath());
						}
					}
					if(paths.isEmpty()) return;
					Intent intent = new Intent(UploadStateActivity.this, BrowTakePhotoActivity.class);
					intent.putExtra(BrowTakePhotoActivity.EXTRA_BROW_UPLOAD,true);
					intent.putExtra(FROME_UPLOADSTATE_ACTIVITY,true);
					intent.putExtra(BrowTakePhotoActivity.EXTRA_BROW_NAMES, paths);
					startActivity(intent);
				}
			});
			gridView.setAdapter(new BaseAdapter() {

				@Override
				public View getView(int position, View convertView, ViewGroup parent) {
					if (convertView == null) {
						convertView = getLayoutInflater().inflate(R.layout.item_upload_grid, null);
					}
					ImageView imageView = (ImageView) convertView.findViewById(R.id.image_view);
					if (position != 5) { // ==5 显示more按钮
						UIRecordImageTool.loadImage(Thread.currentThread().getId(), item.mImages, position, imageView);
					}else{
						imageView.setBackgroundResource(R.drawable.icon_upload_img_more);
					}
					return convertView;
				}

				@Override
				public long getItemId(int position) {
					return 0;
				}

				@Override
				public Object getItem(int position) {
					return null;
				}

				@Override
				public int getCount() {
					return item.mImages.size() > 6 ? 6 : item.mImages.size();
				}
			});
			return convertView;
		}
	}
	

	@Override
	public void OnGetOnlineState(ArrayList<StateItem> items) {
		mItems.addAll(items);
		Collections.sort(mItems, mComparator);
		mAdaper.notifyDataSetChanged();
	}

	@Override
	public void onError(int code, Throwable e) {
	}

	@Override
	protected void onStop() {
		BitmapCache.clean();
		super.onStop();
	}
	
	@Override
	protected void onDestroy() {
		HalcyonService.mNetWorkChangedListener = null;
		super.onDestroy();
	}
	
	@Override
	public void onNetWorkChanged(boolean isWifiConnect) {
		mAdaper.notifyDataSetChanged();
	}
	
	@Override
	public void onTopLeftBtnClick(View view) {
		super.onTopLeftBtnClick(view);
//		overridePendingTransition(R.anim.activity_close_push_left_in,R.anim.activity_close_push_left_out);
	}
}
