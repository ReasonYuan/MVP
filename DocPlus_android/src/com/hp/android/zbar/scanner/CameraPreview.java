package com.hp.android.zbar.scanner;

import java.io.IOException;
import java.util.List;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Paint;
import android.graphics.Rect;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.Parameters;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
import android.util.AttributeSet;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;

import com.fq.android.plus.R;
import com.hp.android.halcyon.util.UITools;

class CameraPreview extends ViewGroup implements SurfaceHolder.Callback {
	private final String TAG = "CameraPreview";

	SurfaceView mSurfaceView;
	SurfaceHolder mHolder;
	Size mPreviewSize;
	List<Size> mSupportedPreviewSizes;
	Camera mCamera;
	PreviewCallback mPreviewCallback;
	AutoFocusCallback mAutoFocusCallback;
	private boolean mPreviewing = true;

	public CameraPreview(Context context) {
		super(context);
		init(context);
	}

	public CameraPreview(Context context, AttributeSet attrs) {
		super(context, attrs);
		init(context);
	}

	public CameraPreview(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init(context);
	}

	private void init(Context context) {
		mSurfaceView = new SurfaceView(context);
		addView(mSurfaceView);
		mHolder = mSurfaceView.getHolder();
		mHolder.addCallback(this);
		mHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
		mAutoFocusCallback = autoFocusCB;

		BoardView board = new BoardView(context);
		addView(board);
	}

	public void setPreviewCallback(PreviewCallback previewCallback) {
		mPreviewCallback = previewCallback;
	}

	public boolean onResume() {
		mCamera = Camera.open();
		if (mCamera == null) {
			// Cancel request if mCamera is null.
			return false;
		}
		mCamera.setDisplayOrientation(90);
		Parameters parameters = mCamera.getParameters();
		if (parameters.isZoomSupported()) {
			parameters.setZoom((int) (parameters.getMaxZoom() / 8));// 相机的焦点
			mCamera.setParameters(parameters);
		}
		mSupportedPreviewSizes = mCamera.getParameters()
				.getSupportedPreviewSizes();
		mSurfaceView.setVisibility(View.VISIBLE);
		mPreviewing = true;
		return true;
	}

	public void onPause() {
		// Because the Camera object is a shared resource, it's very
		// important to release it when the activity is paused.
		if (mCamera != null) {
			mCamera.cancelAutoFocus();
			mCamera.setPreviewCallback(null);
			mCamera.stopPreview();
			mCamera.release();
			mSurfaceView.setVisibility(View.VISIBLE);
			mPreviewing = false;
			mCamera = null;
		}
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		// We purposely disregard child measurements because act as a
		// wrapper to a SurfaceView that centers the camera preview instead
		// of stretching it.
		final int width = resolveSize(getSuggestedMinimumWidth(),
				widthMeasureSpec);
		 final int height = resolveSize(getSuggestedMinimumHeight(),heightMeasureSpec);
		 //final int height = width;
		setMeasuredDimension(width, height);

		if (mSupportedPreviewSizes != null) {
			mPreviewSize = getOptimalPreviewSize(mSupportedPreviewSizes, width,
					height);
		}
	}

	@Override
	protected void onLayout(boolean changed, int l, int t, int r, int b) {
//		if (changed && getChildCount() > 0) {
//			final View child = getChildAt(0);
//			// child.layout((r-l-600)/2, t,(r-l-600)/2+600, t+600);
//			child.layout(0, 0, r - l, b - t);
//
//			View board = getChildAt(1);
//			board.layout(0, 0, r - l, r - l);
//		}

		 if (changed && getChildCount() > 0) {
		 final View child = getChildAt(0);
		
		 final int width = r - l;
		 final int height = b - t;
		
		 int previewWidth = width;
		 int previewHeight = height;
		 if (mPreviewSize != null) {
		 previewWidth = Math.min(mPreviewSize.width, mPreviewSize.height);
		 previewHeight = Math.max(mPreviewSize.width, mPreviewSize.height);
		 }
		
		 // Center the child SurfaceView within the parent.
		 if (width * previewHeight > height * previewWidth) {
		 final int scaledChildWidth = previewWidth * height / previewHeight;
		 child.layout((width - scaledChildWidth) / 2, 0,
		 (width + scaledChildWidth) / 2, height);
		 } else {
		 final int scaledChildHeight = previewHeight * width / previewWidth;
		 child.layout(0, (height - scaledChildHeight) / 2,width, (height + scaledChildHeight) / 2);
		 }
		 }
		 
		 //getChildAt(1).layout(0, 0, r - l, r - l);
	}

	public void surfaceCreated(SurfaceHolder holder) {
		// The Surface has been created, acquire the camera and tell it where
		// to draw.
		try {
			if (mCamera != null) {
				mCamera.setPreviewDisplay(holder);
			}
		} catch (IOException exception) {
			Log.e(TAG, "IOException caused by setPreviewDisplay()", exception);
		}
	}

	public void surfaceDestroyed(SurfaceHolder holder) {
		// Surface will be destroyed when we return, so stop the preview.
		if (mCamera != null) {
			mCamera.cancelAutoFocus();
			mCamera.stopPreview();
		}
	}
	
	
	private Size getOptimalPreviewSize(List<Size> sizes, int w, int h) {
		final double ASPECT_TOLERANCE = 0.1;
		double targetRatio = (double) w / h;
		if (sizes == null)
			return null;

		Size optimalSize = null;
		double minDiff = Double.MAX_VALUE;

		int targetHeight = h;

		// Try to find an size match aspect ratio and size
		for (Size size : sizes) {
			double ratio = (double) size.width / size.height;
			if (Math.abs(ratio - targetRatio) > ASPECT_TOLERANCE)
				continue;
			if (Math.abs(size.height - targetHeight) < minDiff) {
				optimalSize = size;
				minDiff = Math.abs(size.height - targetHeight);
			}
		}

		// Cannot find the one match the aspect ratio, ignore the requirement
		if (optimalSize == null) {
			minDiff = Double.MAX_VALUE;
			for (Size size : sizes) {
				if (Math.abs(size.height - targetHeight) < minDiff) {
					optimalSize = size;
					minDiff = Math.abs(size.height - targetHeight);
				}
			}
		}
		return optimalSize;
	}

	public void surfaceChanged(SurfaceHolder holder, int format, int w, int h) {
		if (holder.getSurface() == null) {
			// preview surface does not exist
			return;
		}
		if (mCamera != null) {
			// Now that the size is known, set up the camera parameters and
			// begin
			// the preview.
			Camera.Parameters parameters = mCamera.getParameters();
			parameters.setPreviewSize(mPreviewSize.width, mPreviewSize.height);
			requestLayout();

			mCamera.setParameters(parameters);
			mCamera.setPreviewCallback(mPreviewCallback);
			mCamera.startPreview();
			mCamera.autoFocus(mAutoFocusCallback);
		}
	}

	private Runnable doAutoFocus = new Runnable() {
		public void run() {
			if (mCamera != null && mPreviewing) {
				mCamera.autoFocus(autoFocusCB);
			}
		}
	};

	// Mimic continuous auto-focusing
	Camera.AutoFocusCallback autoFocusCB = new Camera.AutoFocusCallback() {
		public void onAutoFocus(boolean success, Camera camera) {
			postDelayed(doAutoFocus, 1000);
		}
	};

	class BoardView extends View {
		
		private static final long ANIMATION_DELAY = 10L;
		private static final int SPEEN_DISTANCE = 8;
		private static final int MIDDLE_LINE_WIDTH = 6;
		private static final int MIDDLE_LINE_PADDING = 5;
		
		Paint paint;
		private int width;
		private int height;

		private int boderLineWidth;

		//四个角的高
		private int CORNER_HEIGHT;
		 //四个角的宽
		private int CORNER_WIDTH;
		
		private Bitmap mScanLine;
		private Rect mScanLineRect;
		private int mScanLineTop;

		public BoardView(Context context) {
			super(context);
			paint = new Paint();
			paint.setColor(0xffea5283);
			boderLineWidth = UITools.dip2px(1);
			CORNER_WIDTH = UITools.dip2px(8);
			
			mScanLine = BitmapFactory.decodeResource(getResources(), R.drawable.line_zxing);
			mScanLineRect = new Rect(0, 0, mScanLine.getWidth(), mScanLine.getHeight());
		}

		@Override
		protected void onLayout(boolean changed, int left, int top, int right,
				int bottom) {
			super.onLayout(changed, left, top, right, bottom);
			width = getWidth();
			height = getHeight();
			CORNER_HEIGHT = (int) (width*0.14f);
		}

		protected void onDraw(android.graphics.Canvas canvas) {

			//边框线
			canvas.drawRect(0, 0, boderLineWidth, height, paint);
			canvas.drawRect(0, 0, width, boderLineWidth, paint);
			canvas.drawRect(width - boderLineWidth, 0, width, height, paint);
			canvas.drawRect(0, height - boderLineWidth, width, height, paint);

			//四个角
			canvas.drawRect(0, 0, CORNER_HEIGHT, CORNER_WIDTH,paint);
			canvas.drawRect(0, 0, CORNER_WIDTH, CORNER_HEIGHT,paint);
			
			canvas.drawRect(width-CORNER_HEIGHT, 0, width, CORNER_WIDTH,paint);
			canvas.drawRect(width-CORNER_WIDTH, 0, width, CORNER_HEIGHT,paint);
			
			canvas.drawRect(width-CORNER_WIDTH, height-CORNER_HEIGHT, width, height,paint);
			canvas.drawRect(width-CORNER_HEIGHT, height-CORNER_WIDTH, width, height,paint);
			
			canvas.drawRect(0, height-CORNER_HEIGHT, CORNER_WIDTH, height,paint);
			canvas.drawRect(0, height-CORNER_WIDTH, CORNER_HEIGHT, height,paint);
			
			//扫描框中，扫描的线
			mScanLineTop += SPEEN_DISTANCE;
			if(mScanLineTop >= height){
				mScanLineTop = 0;
			}
			Rect dst = new Rect(50 , mScanLineTop, width-50,mScanLineTop+8);
			canvas.drawBitmap(mScanLine, mScanLineRect, dst, paint);
			
			invalidate();
			//postInvalidateDelayed(ANIMATION_DELAY, 0, 0,width, height);
		}
	}
}
