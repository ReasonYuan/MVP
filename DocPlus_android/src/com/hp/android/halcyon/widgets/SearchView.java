package com.hp.android.halcyon.widgets;

import java.util.ArrayList;

import android.content.Context;
import android.content.res.TypedArray;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.HalcyonEntity;
import com.fq.lib.ChinesetSortHelper;
import com.fq.library.utils.KeyBoardUtils;

public class SearchView extends FrameLayout implements OnFocusChangeListener{
	
	/**
	 * 记录search的状态，false：关闭状态，true：打开状态
	 */
	private boolean searchStatus = false;
	/**
	 * 搜索编辑框
	 */
	protected EditText mEdit;
	/**
	 * 用于焦点获取和释放的编辑框
	 */
	private EditText mEdit2;
	protected ArrayList<? extends HalcyonEntity> mArrayLists;
	
	protected SearchFilterArrayListener mSearchFilterListener; 
	
	protected SearchListener mSearchListener;
	
	public SearchView(Context context) {
		super(context);
		initViewById();
	}

	public SearchView(Context context, AttributeSet attrs) {
		super(context, attrs);
		initView(context, attrs);
	}

	public SearchView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		initView(context, attrs);
	}

	public void setSearchStatus(boolean searchStatus) {
		this.searchStatus = searchStatus;
	}
	
	/**
	 * 获取search的状态
	 * @return  false：关闭状态，true：打开状态
	 */
	public boolean getSearchStatus() {
		return searchStatus;
	}
	
	public void initView(Context context, AttributeSet attrs) {

		TypedArray tay = context.obtainStyledAttributes(attrs,R.styleable.SearchViewType);
		int hint = tay.getResourceId(R.styleable.SearchViewType_search_edit_hint, -1);
		initViewById();
		if(hint != -1)mEdit.setHint(hint);
		tay.recycle();
		
		mEdit.addTextChangedListener(new TextWatcher() {
			public void onTextChanged(CharSequence s, int start, int before, int count) {}
			public void beforeTextChanged(CharSequence s, int start, int count,int after) {}
			
			@Override
			public void afterTextChanged(Editable s) {
				if(mSearchFilterListener != null){
					if(mArrayLists == null)return;
					String searchStr = s.toString().trim(); 
					if("".equals(searchStr)){
						//只要else块也能实现，不过可能会增加计算量
						mSearchFilterListener.searchChange(mArrayLists);
					}else{
						mSearchFilterListener.searchChange(getFilterArrayList(searchStr));
					}
				}else if(mSearchListener != null){
					mSearchListener.searchChange(s.toString().trim());
				}
			}
		});
		
			findViewById(R.id.img_search_btn).setOnClickListener(new OnClickListener() {
				public void onClick(View v) {
					KeyBoardUtils.closeKeybord(mEdit, getContext());
					if(mSearchFilterListener != null){
						mSearchFilterListener.searchCallback(getFilterArrayList(mEdit.getText().toString()));
					}else if(mSearchListener != null){
						mSearchListener.searchCallback(mEdit.getText().toString());
					}
				}
			});
	}

	public void setSearchFilterListener(ArrayList<? extends HalcyonEntity> list, SearchFilterArrayListener listener){
		mArrayLists = list;
		mSearchFilterListener = listener;
	}
	
	public void setSearchListener(SearchListener listener){
		mSearchListener = listener;
	}
	
	@SuppressWarnings("unchecked")
	public <T extends HalcyonEntity>ArrayList<T> getFilterArrayList(String str){
		ArrayList<T> filterArrayList = new ArrayList<T>();
		String pinyin = ChinesetSortHelper.getPingYin(str).toUpperCase();
		for(HalcyonEntity entity : mArrayLists){
			String pinyinName = entity.getPinyinName().toUpperCase(); 
			boolean isExist = true;
			for(int i = 0; i < pinyin.length(); i++){
				int index = pinyinName.indexOf(pinyin.charAt(i));
				if(index != -1){
					pinyinName = pinyinName.substring(index+1);
				}else {
					isExist = false;
					break;
				}
			}
			if(isExist){
				filterArrayList.add((T)entity);
			}
		}
		return filterArrayList;
	}
	
	protected void initViewById() {
		int id = R.layout.item_search_view;
		addView(LayoutInflater.from(getContext()).inflate(id, null));
		mEdit2 = (EditText) findViewById(R.id.et_search22); 
		mEdit = (EditText) findViewById(R.id.et_search);
		mEdit.setOnFocusChangeListener(this);
		
		findViewById(R.id.fl_search_frame).setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				setSearchStatus(true);
				startViewAnimIn();
				v.setClickable(false);
			}
		});
		
		findViewById(R.id.ib_search_cancel).setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				setSearchStatus(false);
				mEdit.setText("");
				startViewAnimOut();
				if(onCloseCallBack != null){
					onCloseCallBack.onClick();
				}
			}
		});
		
		mEdit.setOnKeyListener(new OnKeyListener() {
			
			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				if(keyCode==KeyEvent.KEYCODE_ENTER && event.getAction() == KeyEvent.ACTION_DOWN){
					String key = mEdit.getText().toString().trim();
					KeyBoardUtils.closeKeybord(mEdit, getContext());
					if (mSearchListener != null) {
						mSearchListener.searchCallback(key);
					}
					return true;
				}
				return false;
			}
		});
	}


	@Override
	public void onFocusChange(View v, boolean hasFocus) {
		if(!hasFocus && "".equals(mEdit.getText().toString())){
			startViewAnimOut();
		}
	}
	
	public EditText getEditText(){
		return mEdit;
	}
	
	public String getSearchText(){
		if(TextUtils.isEmpty(mEdit.getEditableText())){
			return "";
		}else{
			return mEdit.getText().toString().trim();
		}
	}
	
	public interface SearchFilterArrayListener{
		/**
		 * 点击搜索按钮时
		 * @param searchKey
		 */
		public void searchCallback(ArrayList<? extends HalcyonEntity> arraylist);
		
		/**
		 * 搜索文字变化时
		 * @param key
		 */
		public void searchChange(ArrayList<? extends HalcyonEntity> arraylist);
	}
	
	public interface SearchListener{
		/**
		 * 点击搜索按钮时
		 * @param searchKey
		 */
		public void searchCallback(String key);
		
		/**
		 * 搜索文字变化时
		 * @param key
		 */
		public void searchChange(String key);
	}
	
	/**
	 * 修改hint文字
	 * @param text
	 */
	public void setSearchHintText(String text){
		((TextView)findViewById(R.id.tv_search_hint_text)).setText(text);
	}
	
	public void startViewAnimIn(){
		final View view = findViewById(R.id.ll_search_middle);
		TranslateAnimation animation = new TranslateAnimation(0, -view.getLeft(), view.getTop(), view.getTop());
		animation.setDuration(300);
		animation.setStartOffset(0);
		animation.setFillAfter(true);
		animation.setAnimationListener(new Animation.AnimationListener() {
			@Override
			public void onAnimationStart(Animation animation) {
			}

			@Override
			public void onAnimationEnd(Animation animation) {
				mEdit.requestFocus();
				mEdit.findFocus();
				findViewById(R.id.ll_search_middle).setVisibility(View.GONE);
				findViewById(R.id.ll_edit_view).setVisibility(View.VISIBLE);
				view.clearAnimation();
				KeyBoardUtils.openKeybord(mEdit, getContext());
				mEdit2.setVisibility(View.VISIBLE);
			}

			@Override
			public void onAnimationRepeat(Animation animation) {
			}
		});
		view.startAnimation(animation);	
	}
	
	public void startViewAnimOut(){
		setSearchStatus(false);
		InputMethodManager imm = (InputMethodManager) mEdit.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
		
		if (imm.isActive()) { 
			imm.hideSoftInputFromWindow(mEdit.getWindowToken(), 0);  
		} 
		final View view = findViewById(R.id.ll_search_middle);
		TranslateAnimation animation = new TranslateAnimation(-view.getLeft(), 0, view.getTop(), view.getTop());
		animation.setDuration(300);
		animation.setStartOffset(0);
		animation.setFillAfter(true);
		animation.setAnimationListener(new Animation.AnimationListener() {
			@Override
			public void onAnimationStart(Animation animation) {
			}

			@Override
			public void onAnimationEnd(Animation animation) {
				findViewById(R.id.ll_search_middle).setVisibility(View.VISIBLE);
				findViewById(R.id.fl_search_frame).setClickable(true);
				view.clearAnimation();
				mEdit.setText("");
				mEdit2.setVisibility(View.GONE);
			}

			@Override
			public void onAnimationRepeat(Animation animation) {
			}
		});
		findViewById(R.id.ll_edit_view).setVisibility(View.GONE);
		findViewById(R.id.ll_search_middle).requestFocus();
		view.startAnimation(animation);	
	}
	
	public interface CloseClickListenerCallBack{
		public void onClick();
	}
	public CloseClickListenerCallBack onCloseCallBack;
	
	public void onCloseClickListener(CloseClickListenerCallBack onClick){
		this.onCloseCallBack = onClick;
	}
}
