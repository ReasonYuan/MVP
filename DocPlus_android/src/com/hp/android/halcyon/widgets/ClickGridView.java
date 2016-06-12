package com.hp.android.halcyon.widgets;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.GridView;

public class ClickGridView extends GridView{

	public ClickGridView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	private static final int Blank_POSITION = -1;
	
	private OnTouchBlankPositionListener mTouchBlankPosListener;
	
	public ClickGridView(Context context) {
		super(context);
	}

	public interface OnTouchBlankPositionListener {
	       /**
	        * 
	        * @return 是否要终止事件的路由
	        */
	       boolean onTouchBlankPosition();
	   }
	    
	   public void setOnTouchBlankPositionListener(OnTouchBlankPositionListener listener) {
	       mTouchBlankPosListener = listener;
	   }
	    
	   @Override
	   public boolean onTouchEvent(MotionEvent event) {
	       if(mTouchBlankPosListener != null) {
	           if (!isEnabled()) {
	               // A disabled view that is clickable still consumes the
	               // events, it just doesn't respond to them.
	               return isClickable() || isLongClickable();
	           }
	                
	           if(event.getActionMasked() == MotionEvent.ACTION_UP) {
	               final int motionPosition = pointToPosition((int)event.getX(), (int)event.getY());
	               if( motionPosition == Blank_POSITION ) {
	                   return mTouchBlankPosListener.onTouchBlankPosition();
	               }
	           }
	       }
	 
	       return super.onTouchEvent(event);
	   }
	
}
