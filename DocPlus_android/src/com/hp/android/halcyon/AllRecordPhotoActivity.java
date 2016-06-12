package com.hp.android.halcyon;

import java.util.ArrayList;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.uimodels.OneType;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.record.SnapPhotoManager;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.Tool;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.ClickGridView;
import com.hp.android.halcyon.widgets.ClickGridView.OnTouchBlankPositionListener;
import com.hp.android.halcyon.widgets.CustomDialog;

/**
 * 以份的形式浏览所有拍摄的病历<br/>
 * 浏览所拍摄的病历图片界面，右上角点击后进入该界面
 * @author reason
 *
 */
public class AllRecordPhotoActivity extends BaseActivity implements OnItemClickListener,OnItemLongClickListener{

	public enum STATE{
		NORMAL,DEL
	}
	
	/**浏览每份病历的列表*/
	private ListView mListView;
	/**病历的列表ListView的适配器*/
	private ListAdapter mListAdapter;
	/**装载每份病历数据的GridView的适配器的List容器*/
	private ArrayList<RecordTypeAdapter> mAdapterList;
	
	/**拍摄的所有病历图片的数据*/
	private ArrayList<OneType> mTypes;
	
	/**当前状态：删除|普通，默认为普通*/
	private STATE mState;
	
	@Override
	public int getContentId() {
		return R.layout.activity_all_record_photos;
	}

	@Override
	public void init() {
		setTitle("所有图片");
		mTypes = SnapPhotoManager.getInstance().getTypes();

		mListView = (ListView) findViewById(R.id.lv_all_record_photos);
	}

	@Override
	protected void onResume() {
		super.onResume();
		if(mListAdapter == null && SnapPhotoManager.getInstance().getTypes().size() > 0){
			mListAdapter = new ListAdapter();
			mAdapterList = new ArrayList<RecordTypeAdapter>();
			mListView.setAdapter(mListAdapter);
			setTopRightText("全部上传");
		}else{
			if(SnapPhotoManager.getInstance().getTypes().size() > 0){
				mListAdapter.notifyDataSetChanged();
			}else{
				mListView.setVisibility(View.INVISIBLE);
				setTopRightTextShow(false);
			}
		}
	}
	
	@Override
	public void onTopRightBtnClick(View view) {
		if(Constants.getUser().isOnlyWifi() && !UITools.isWifiConnected(this)){
			final CustomDialog customDialog = new CustomDialog(this);
			customDialog.setMessage("请连接wifi或者关闭设置中“仅wifi状态下上传病历”");
			customDialog.setPositiveBtnSignle(R.string.btn_sure_ren, new View.OnClickListener() {
				@Override
				public void onClick(View arg0) {
					customDialog.dismiss();
				}
			} );
			customDialog.show();
			return;
		}
		SnapPhotoManager snap = SnapPhotoManager.getInstance();
		if(snap.getRecordId() == 0){
			final CustomDialog customDialog = new CustomDialog(this);
			customDialog.setMessage("上传病历出现失败！");
			customDialog.setPositiveListener(R.string.btn_sure_ren, new View.OnClickListener() {
				public void onClick(View arg0) {
					customDialog.dismiss();
					
				}
			} );
			customDialog.setPositiveBackground(R.drawable.selector_btn_dialog);
			customDialog.show();
			return;
		}
//		new UploadRecordLogic().upLoad("", snap.getRecordId(), mTypes);
		Intent intent = new Intent();
		setResult(777, intent);
		finish();
	}
	
	/**
	 * 浏览拍摄病历所有份的ListView的适配器
	 */
	class ListAdapter extends BaseAdapter implements OnClickListener{

		@Override
		public int getCount() {
			return mTypes.size();
		}

		@Override
		public Object getItem(int position) {
			return null;
		}

		@Override
		public long getItemId(int position) {
			return 0;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			OneType type = mTypes.get(position);
			
			if(convertView == null){
				convertView = LayoutInflater.from(AllRecordPhotoActivity.this)
						.inflate(R.layout.item_brow_record_onecopy_layout, null);
			}
			
			TextView tv = (TextView) convertView.findViewById(R.id.tv_brow_record_title);
			tv.setText("第"+Tool.numToCHN(position+1)+"份");
			
			//查看更多按钮，照片数量大于3时显示
			View moreBtn = convertView.findViewById(R.id.btn_expand_add_copy);
			moreBtn.setVisibility(type.getPhotoCounter() > 3?View.VISIBLE:View.GONE);
			moreBtn.setTag(position);
			moreBtn.setOnClickListener(this);
			
			//得到adapter
			RecordTypeAdapter adapter = null;
			try{
				adapter = mAdapterList.get(position);
			}catch(Exception e){
				adapter = new RecordTypeAdapter(type);
				mAdapterList.add(position, adapter);
			}
			//下方GridView
			ClickGridView gridView = (ClickGridView) convertView.findViewById(R.id.gv_brow_record_types);
			gridView.setAdapter(adapter);
			gridView.setOnItemClickListener(AllRecordPhotoActivity.this);
			gridView.setOnItemLongClickListener(AllRecordPhotoActivity.this);
			gridView.setOnTouchBlankPositionListener(new OnTouchBlankPositionListener() {
				public boolean onTouchBlankPosition() {
					onCancel(null);
					return true;
				}
			});
			
			return convertView;
		}

		@Override
		public void onClick(View v) {
			int index = (Integer) v.getTag();
			Intent intent = new Intent(AllRecordPhotoActivity.this, SnapItemPhotoMoreActivity.class);
			intent.putExtra("snap_item_index", index);
			startActivity(intent);
		}
	}
	
	/**
	 * 拍摄的一份的病历照片的GridView的适配器
	 */
	class RecordTypeAdapter extends BaseAdapter{
		private OneType mOneType;
		private ArrayList<PhotoRecord> mPhotos;
		
		
		public RecordTypeAdapter(OneType type){
			mOneType = type;
			mPhotos = mOneType.getCopyById(0).getPhotos();
		}
		
		public void initPhotos(){
			mPhotos = mOneType.getCopyById(0).getPhotos();
		}
		
		@Override
		public int getCount() {
			return mPhotos.size()+1;
		}

		@Override
		public Object getItem(int position) {
			return null;
		}

		@Override
		public long getItemId(int position) {
			return 0;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			if(convertView == null){
				convertView = LayoutInflater.from(AllRecordPhotoActivity.this).inflate(R.layout.item_record_snap_photo_view, null);
			}
			
			View state = convertView.findViewById(R.id.fl_brow_record_delete);
			View addImg = convertView.findViewById(R.id.iv_brow_photo);
			TextView tv = (TextView) convertView.findViewById(R.id.tv_snap_record_type);
			if(position == mPhotos.size()){//最后一个是添加图片的按钮
				tv.setVisibility(View.GONE);
				state.setVisibility(View.GONE);
				addImg.setVisibility(View.VISIBLE);
				
				//化验类型的不能添加
				if(mOneType.getType() == RecordConstants.TYPE_EXAMINATION){
					convertView.setVisibility(View.GONE);
				}
			}else{//其他的是正常项
				tv.setVisibility(View.VISIBLE);
				addImg.setVisibility(View.GONE);
				String title = RecordConstants.getTypeTitleByRecordType(mOneType.getType());
				tv.setText(title);
				state.setVisibility(mState == STATE.DEL?View.VISIBLE:View.GONE);
			}
			convertView.setTag(mOneType);
			return convertView;
		}
	}

	@Override
	public void onBackPressed() {
		if (mState == STATE.DEL && mTypes.size() > 0){
			mState = STATE.NORMAL;
			mListAdapter.notifyDataSetChanged();
			return;
		}
		super.onBackPressed();
	}
	
	/**
	 * 退出编辑模式
	 * @param v
	 */
	public void onCancel(View v){
		if (mState == STATE.DEL){
			mState = STATE.NORMAL;
			mListAdapter.notifyDataSetChanged();
		}
	}
	
	/**
	 * 点击图片方块
	 */
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		OneType type = (OneType) view.getTag();
		if (mState == STATE.DEL) {
			deleteRecordPhoto(type, position);
		} else {
			if(position != type.getCopyById(0).getPhotos().size()){
				Intent intent = new Intent(this,BrowImageActivity.class);
				intent.putExtra("photo_array", type.getAllPhotos());
				intent.putExtra("image_title", RecordConstants.getTypeNameByRecordType(type.getType()));
				startActivity(intent);
			}else{
				int index = mTypes.indexOf(type);
				addPhoto(index);
			}
		}
	}

	public void addPhoto(int index){
		Intent intent = new Intent();
		intent.putExtra("type_index", index);
		setResult(998, intent);
		finish();
	}
	
	
	
	/**
	 * 长按病历图片方块
	 */
	@Override
	public boolean onItemLongClick(AdapterView<?> parent, View view,
			int position, long id) {
		if (mState == STATE.DEL)return true;
		mState = STATE.DEL;
		mListAdapter.notifyDataSetChanged();
		return true;
	}
	
	/**
	 * 删除一份病历的一张图片
	 * @param type 一个病历
	 * @param index 要删除图片的序号
	 */
	private void deleteRecordPhoto(OneType type, int index) {
		if(type == null)return;
		if(index == type.getCopyById(0).getPhotos().size())return;
		int id = mTypes.indexOf(type);
		type.getCopyById(0).getPhotos().remove(index);
		if(type.getPhotoCounter() <= 0){
			mTypes.remove(type);
			mAdapterList.remove(id);
			mListAdapter.notifyDataSetChanged();
		}else{
			if(id < 0){
				mListAdapter.notifyDataSetChanged();
			}else{
				mAdapterList.get(id).notifyDataSetChanged();
			}
		}
	}
}
