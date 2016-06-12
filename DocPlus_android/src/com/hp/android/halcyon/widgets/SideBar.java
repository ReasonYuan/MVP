package com.hp.android.halcyon.widgets;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.FontMetrics;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import com.fq.android.plus.R;
import com.hp.android.halcyon.util.HppLog;

/**
 * 联系人右侧的检索条
 */
public class SideBar extends View {
    public static final String TAG = SideBar.class.getName();
    
    private String[] mLetters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N",
		"O","P","Q","R","S","T","U","V","W","X","Y","Z"};
    
    private OnLetterTouchListener mLetterTouchListener;

    private int mTextSizeCha = 8;
    
    public SideBar(Context context) {
        super(context);
        init(context);
    }

    public SideBar(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public SideBar(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context);
    }

    public void setTextSizeCha(int cha){
    	mTextSizeCha = cha;
    }
    
    public void init(Context context){
    	
    }

    /**
     * 每一项的高度
     */
    private float itemHeight = -1;
    private Paint paint;
    private Bitmap letterBitmap;
    @Override
    protected void onDraw(Canvas canvas) {
        if(mLetters == null){
            return ;
        }
        if(itemHeight == -1){
            itemHeight = getHeight() /(float)mLetters.length;
        }
        if(paint == null){
            //初始化画笔
            paint = new Paint();
            paint.setTextSize(itemHeight - mTextSizeCha);
            //字体颜色
            paint.setColor(getResources().getColor(R.color.topbar_bg_normal));
            paint.setFlags(Paint.ANTI_ALIAS_FLAG);

            //创建一张包含所有列表的图
            Canvas mCanvas = new Canvas();
            letterBitmap = Bitmap.createBitmap(getMeasuredWidth(), getMeasuredHeight(),
                    Bitmap.Config.ARGB_8888);
            mCanvas.setBitmap(letterBitmap);
            float widthCenter = getMeasuredWidth() / 2.0f;
            paint.setTextAlign(Paint.Align.CENTER);
            FontMetrics fm = paint.getFontMetrics();
            //HppLog.i(TAG, "~~top:"+fm.top+" ascent:"+fm.ascent+" descent:"+fm.descent+" bottom:"+fm.bottom);
            //画字符上图片中
            for(int i = 0 ; i < mLetters.length; i ++){
                mCanvas.drawText(mLetters[i], widthCenter,itemHeight * (i+0.5f)+fm.bottom+2.5f,paint);
            }
        }
        if(letterBitmap != null){//图片不为空就画图
            canvas.drawBitmap(letterBitmap,0,0,paint);
        }
        super.onDraw(canvas);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        super.onTouchEvent(event);
        if(mLetterTouchListener == null || mLetters == null){
            return false;
        }
        switch (event.getAction()){
            case MotionEvent.ACTION_DOWN:
            case MotionEvent.ACTION_MOVE:
                HppLog.v(TAG, "action down or move");
                int position = (int) (event.getY() / itemHeight);
                if(position >= 0 && position < mLetters.length){
                    mLetterTouchListener.onLetterTouch(mLetters[position],position);
                }
                return true;
            case MotionEvent.ACTION_OUTSIDE:
            case MotionEvent.ACTION_UP:
            	HppLog.v(TAG, "action up");
                mLetterTouchListener.onActionUp();
                return true;
        }
        return false;
    }

    /**
     * 设置显示在边栏上的字母
     * @param letters
     */
    public void setShowString(String[] letters){
        this.mLetters = letters;
    }
    
    /**
     * 设置显示在边栏上的字母
     * @param letters
     */
    public void setShowString(ArrayList<String> letters){
    	this.mLetters = new String[letters.size()];
    	for(int i = 0; i < letters.size(); i++){
    		this.mLetters[i] = letters.get(i);
    	}
    }


    /**
     * 设置点击某个字母的时候
     * @param listener
     */
    public void setOnLetterTouchListener (OnLetterTouchListener listener){
        this.mLetterTouchListener = listener;
    }

    public interface OnLetterTouchListener{

        /**
         * 某个字母被按下的时候
         * @param letter
         * @param position
         */
        public void onLetterTouch(String letter, int position);

        /**
         * 触控手指离开的时候
         */
        public void onActionUp();
    }
}
