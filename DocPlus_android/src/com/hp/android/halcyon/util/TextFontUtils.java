package com.hp.android.halcyon.util;

import android.content.Context;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.widget.TextView;

public class TextFontUtils {

	/**
	 * 方正兰亭简体纤黑
	 */
	public static final int FONT_FZLTJT = 0;

	/**
	 * 方正兰亭简体纯黑
	 */
	public static final int FONT_FZLTJT_BLOD = 1;
	
	/**
	 * ElleNovC_Med
	 */
	public static final int FONT_ELLE = 2;

	/**
	 * ElleNovC_Bol
	 */
	public static final int FONT_ELLE_BOL = 3;
	
	/**
	 * ElleNovCBoo
	 */
	public static final int FONT_ELLE_BOO = 4;
	
	/**
	 * Hiragino Sans GB W3
	 */
	public static final int FONT_HIRAGINO_SANS_GB_W3 = 5;
	
	/**
	 * Hiragino Sans GB W6
	 */
	public static final int FONT_HIRAGINO_SANS_GB_W6 = 6;
	
//	private static final String[] mFonts = {"fangzhenglantingxianheijian.ttf",
//		"lantingchuheijian.TTF","ElleNovCMed.otf","ElleNovCUltBol.otf","ElleNovCBoo.otf","Hiragino Sans GB W3.otf","Hiragino Sans GB W6.otf"};
	private static final String[] mFonts = {"fangzhenglantingxianheijian.ttf",
		"lantingchuheijian.TTF","ElleNovCMed.otf","Hiragino Sans GB W6.otf","ElleNovCBoo.otf","Hiragino Sans GB W3.otf","ElleNovCUltBol.otf"};
	
	private static Context mContext;
	
	private static Typeface [] mTypeFace;
	
	private static final int TYPE_FACE_SIZE = 6;
	
	public static void init(Context context){
		mContext = context;
		initAllFont();
	}
	
	public static void setFont(TextView textView,int type,int color){
//		Typeface mFont = Typeface.createFromAsset(mContext.getAssets(),mFonts[type]);
		textView.setTextColor(color);
		textView.setTypeface(mTypeFace[type]);
		
	}
	public static void setFont(TextView textView,int type){
//		Typeface mFont = Typeface.createFromAsset(mContext.getAssets(),mFonts[type]);
		textView.setTypeface(mTypeFace[type]);
	}
	
	public static Typeface getTypeface(int type){
		return mTypeFace[type];
	}
	
	public static void setPaintFont(Paint paint,int type){
//		Typeface mFont = Typeface.createFromAsset(mContext.getAssets(),mFonts[type]);
		if(mTypeFace != null && mTypeFace[type] != null)
		paint.setTypeface( mTypeFace[type]);
	}
	
	public static void initAllFont(){
		mTypeFace = new Typeface[TYPE_FACE_SIZE];
		for (int i = 0; i < TYPE_FACE_SIZE; i++) {
			mTypeFace[i] = Typeface.createFromAsset(mContext.getAssets(),mFonts[i]);
		}
	}
}	
