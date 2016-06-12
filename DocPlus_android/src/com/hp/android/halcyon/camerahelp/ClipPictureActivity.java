package com.hp.android.halcyon.camerahelp;

//javaapk.com�ṩ����

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.graphics.PointF;
import android.graphics.Rect;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.FloatMath;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;

import com.fq.android.plus.R;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.hp.android.halcyon.UserProfileActivity;
import com.hp.android.halcyon.util.BitmapManager;
import com.hp.halcyon.widgets.main.Tools;

public class ClipPictureActivity extends Activity implements OnTouchListener,
		OnClickListener {
	ImageView srcPic;
	Button sure;
	Button cancle;
	ClipView clipview;
	String mPath;
	private Bitmap mBitmap;
	public int screenWidth = 0;
	public int screenHeight = 0;

	// These matrices will be used to move and zoom image
	Matrix matrix = new Matrix();
	Matrix savedMatrix = new Matrix();

	// We can be in one of these 3 states
	static final int NONE = 0;
	static final int DRAG = 1;
	static final int ZOOM = 2;
	private static final String TAG = "11";
	int mode = NONE;

	// Remember some things for zooming
	PointF start = new PointF();
	PointF mid = new PointF();
	float oldDist = 1f;

	int clipL, clipR, clipT, clipB;

	int clipWidth, clipHeight;

	int clipViewWidth, clipViewHeight;

	// 小图片放大
	int destWidth = 0, destHeight = 0;
	Boolean isSmall;
	float multiple;

	int tempWidth = 0, tempHeight = 0;
	float scale;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.acitivity_clip);
		getWindowWidHe();
		mPath = getIntent().getStringExtra("path");
		isSmall = false;
		clipview = (ClipView) this.findViewById(R.id.clipview);
		ViewTreeObserver vto = clipview.getViewTreeObserver();
		vto.addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
			public boolean onPreDraw() {

				if (clipL == 0 && clipR == 0) {
					clipViewHeight = clipview.getMeasuredHeight();
					clipViewWidth = clipview.getMeasuredWidth();
					clipL = (int) ((clipViewWidth - clipViewHeight / 2.5f) / 2);
					clipT = clipViewHeight / 5;
					clipR = (int) ((clipViewWidth + clipViewHeight / 2.5f) / 2);
					clipB = clipViewHeight * 3 / 5;
					clipWidth = clipR - clipL;
					clipHeight = clipB - clipT;
					System.out.println("111111111    "+clipWidth + "   "+ clipHeight);
					mBitmap = createBitmap(mPath, clipWidth, clipHeight);
					srcPic = (ImageView) ClipPictureActivity.this
							.findViewById(R.id.src_pic);
					srcPic.setImageBitmap(mBitmap);
					srcPic.setOnTouchListener(ClipPictureActivity.this);
					if (!isSmall) {
						matrix.postTranslate(clipL
								- (mBitmap.getWidth() - clipWidth) / 2, clipT
								- (mBitmap.getHeight() - clipHeight) / 2);
						srcPic.setImageMatrix(matrix);
					} else {
						matrix.postScale(multiple, multiple, 0, 0);
						matrix.postTranslate(clipL - (destWidth - clipWidth)
								/ 2, clipT - (destHeight - clipHeight) / 2);
						srcPic.setImageMatrix(matrix);
					}
				}
				return true;
			}
		});

		sure = (Button) this.findViewById(R.id.gl_modify_avatar_save);
		sure.setOnClickListener(this);
		cancle = (Button) this.findViewById(R.id.gl_modify_avatar_cancel);
		cancle.setOnClickListener(this);
	}

	public boolean onTouch(View v, MotionEvent event) {
		ImageView view = (ImageView) v;
		// Handle touch events here...
		switch (event.getAction() & MotionEvent.ACTION_MASK) {
		case MotionEvent.ACTION_DOWN:
			savedMatrix.set(matrix);
			// �O�ó�ʼ�cλ��
			start.set(event.getX(), event.getY());
			if(Constants.DEBUG){
			Log.d(TAG, "mode=DRAG");
			}
			mode = DRAG;
			break;
		case MotionEvent.ACTION_POINTER_DOWN:
			oldDist = spacing(event);
			if(Constants.DEBUG){
			Log.d(TAG, "oldDist=" + oldDist);
			}
			if (oldDist > 10f) {
				savedMatrix.set(matrix);
				midPoint(mid, event);
				mode = ZOOM;
				if(Constants.DEBUG){
				Log.d(TAG, "mode=ZOOM");
				}
			}
			break;
		case MotionEvent.ACTION_UP:
		case MotionEvent.ACTION_POINTER_UP:
			mode = NONE;
			if(Constants.DEBUG){
			Log.d(TAG, "mode=NONE");
			}
			break;
		case MotionEvent.ACTION_MOVE:
			if (mode == DRAG) {
				matrix.set(savedMatrix);

				float moveX = event.getX() - start.x;
				float moveY = event.getY() - start.y;

				Rect rect = getImageRect(matrix, (ImageView) view);
				if (rect.width() > (clipR - clipL)
						&& rect.height() > (clipB - clipT)) {

				}
				if (rect.width() < (clipR - clipL)) {// 图片宽小于框的宽度时
					if (rect.left + moveX < clipL) {
						moveX = clipL - rect.left - 0.5f;
					} else if (rect.right + moveX > clipR) {
						moveX = clipR - rect.right - 0.5f;
					}
				} else {// 图片宽大于框的宽度时
					if (rect.left + moveX > clipL) {
						moveX = clipL - rect.left - 0.5f;
					} else if (rect.right + moveX < clipR) {
						moveX = clipR - rect.right + 0.5f;
					}
				}

				if (rect.height() < (clipB - clipT)) {// 图片高小于框的高度时
					if (rect.top + moveY < clipT) {
						moveY = clipT - rect.top - 0.5f;
					} else if (rect.bottom + moveY > clipB) {
						moveY = clipB - rect.bottom - 0.5f;
					}
				} else {// 图片高大于框的高度时
					if (rect.top + moveY > clipT) {
						moveY = clipT - rect.top - 0.5f;
					} else if (rect.bottom + moveY < clipB) {
						moveY = clipB - rect.bottom + 0.5f;
					}
				}

				matrix.postTranslate(moveX, moveY);
			} else if (mode == ZOOM) {
				float newDist = spacing(event);
				if(Constants.DEBUG){
				Log.d(TAG, "newDist=" + newDist);
				}
				if (newDist > 10f) {
					matrix.set(savedMatrix);
					scale = newDist / oldDist;
					Rect rect = getImageRect(matrix, (ImageView) view);
					tempWidth = rect.width();
					tempHeight = rect.height();

					float x, y;
					float y1, x1;

					// 判断缩放的最中心点,长图用x做水平点，宽图用y做竖直点
					if (clipR + rect.left - rect.right - clipL == 0) {
						x = (clipR - clipL) / 2;
					} else {
						x = (float) (rect.left * clipR - rect.right * clipL)
								/ (float) (clipR + rect.left - rect.right - clipL);
					}

					if (clipB + rect.top - rect.bottom - clipT == 0) {
						y = (clipB - clipT) / 2;
					} else {
						y = (float) (rect.top * clipB - rect.bottom * clipT)
								/ (float) (clipB + rect.top - rect.bottom - clipT);
					}
					// 最小图片比例
					float scw = (float) clipWidth / (float) tempWidth;
					float sch = (float) clipHeight / (float) tempHeight;
					multiple = Math.max(scw, sch);

					if (scale >= 1) {
						if (mid.x <= rect.left && mid.y <= rect.top) {
							matrix.postScale(scale, scale, rect.left, rect.top);
							view.setImageMatrix(matrix);
							return true;
						}else if (mid.x <= rect.left && mid.y >= rect.bottom) {
							matrix.postScale(scale, scale, rect.left, rect.bottom);
							view.setImageMatrix(matrix);
							return true;
						}else if (mid.x >= rect.right && mid.y >= rect.bottom) {
							matrix.postScale(scale, scale, rect.right, rect.bottom);
							view.setImageMatrix(matrix);
							return true;
						}else if (mid.x >= rect.right && mid.y <= rect.top) {
							matrix.postScale(scale, scale, rect.right, rect.top);
							view.setImageMatrix(matrix);
							return true;
						}else if (mid.x <= rect.left && mid.y > rect.top && mid.y <rect.bottom) {
							matrix.postScale(scale, scale, rect.left, mid.y);
							view.setImageMatrix(matrix);
							return true;
						}else if (mid.x >= rect.right && mid.y > rect.top && mid.y <rect.bottom) {
							matrix.postScale(scale, scale, rect.right, mid.y);
							view.setImageMatrix(matrix);
							return true;
						}else if (mid.x > rect.left && mid.x < rect.right && mid.y <= rect.top) {
							matrix.postScale(scale, scale, mid.x, rect.top);
							view.setImageMatrix(matrix);
							return true;
						}else if (mid.x > rect.left && mid.x < rect.right && mid.y >= rect.bottom) {
							matrix.postScale(scale, scale, mid.x, rect.bottom);
							view.setImageMatrix(matrix);
							return true;
						}else {
							matrix.postScale(scale, scale, mid.x, mid.y);
							view.setImageMatrix(matrix);
							return true;
						}
						
					} else {
						// 缩放当前高宽缩放后大于截图边框的高宽
						if (tempWidth * scale > clipWidth
								&& tempHeight * scale > clipHeight) {
							// 长图
							if (multiple == scw) {
								if (((clipB + clipT) / 2 - ((clipB + clipT) / 2 - rect.top)
										* multiple) > clipT) {
									y1 = (float) (clipT - multiple * rect.top)
											/ (float) (1 - multiple);
									matrix.postScale(scale, scale, x, y1);
									view.setImageMatrix(matrix);
									return true;
								} else if (((clipB + clipT) / 2 + (rect.bottom - (clipB + clipT) / 2)
										* multiple) < clipB) {
									y1 = (float) (clipB - multiple
											* rect.bottom)
											/ (float) (1 - multiple);
									matrix.postScale(scale, scale, x, y1);
									view.setImageMatrix(matrix);
									return true;
								} else {
									matrix.postScale(scale, scale, x,
											(clipB + clipT) / 2);
									view.setImageMatrix(matrix);
									return true;
								}
							} else {// 宽图
								if (((clipR + clipL) / 2 - ((clipR + clipL) / 2 - rect.left)
										* multiple) > clipL) {
									x1 = (float) (clipL - multiple * rect.left)
											/ (float) (1 - multiple);
									matrix.postScale(scale, scale, x1, y);
									view.setImageMatrix(matrix);
									return true;
								} else if (((clipR + clipL) / 2 + (rect.right - (clipR + clipL) / 2)
										* multiple) < clipR) {
									x1 = (float) (clipR - multiple
											* rect.right)
											/ (float) (1 - multiple);
									matrix.postScale(scale, scale, x1, y);
									view.setImageMatrix(matrix);
									return true;
								} else {
									matrix.postScale(scale, scale, (clipR + clipL) / 2,
											y);
									view.setImageMatrix(matrix);
									return true;
								}
							}

						} else {// 缩放当前高宽缩放后小于等于截图边框的高宽
							if (multiple == scw) {// 长图
								if (((clipB + clipT) / 2 - ((clipB + clipT) / 2 - rect.top)
										* multiple) > clipT) {
									y1 = (float)(clipT - multiple * rect.top)
											/ (float)(1 - multiple);
									matrix.postScale(multiple, multiple, x, y1);
									System.out.println(1);
									view.setImageMatrix(matrix);
									return true;
								} else if (((clipB + clipT) / 2 + (rect.bottom - (clipB + clipT) / 2)
										* multiple) < clipB) {
									y1 = (float)(clipB - multiple * rect.bottom)
											/ (float)(1 - multiple);
									matrix.postScale(multiple, multiple, x, y1);
									view.setImageMatrix(matrix);
									return true;
								} else {
									matrix.postScale(multiple, multiple, x,
											(clipB + clipT) / 2);
									System.out.println(2);
									view.setImageMatrix(matrix);
									return true;
								}
							} else {// 宽图
								if (((clipR + clipL) / 2 - ((clipR + clipL) / 2 - rect.left)
										* multiple) > clipL) {
									x1 = (float) (clipL - multiple * rect.left)
											/ (float) (1 - multiple);
									matrix.postScale(multiple, multiple, x1, y);
									view.setImageMatrix(matrix);
									return true;
								} else if (((clipR + clipL) / 2 + (rect.right - (clipR + clipL) / 2)
										* multiple) < clipR) {
									x1 = (float) (clipR - multiple
											* rect.right)
											/ (float) (1 - multiple);
									matrix.postScale(multiple, multiple, x1, y);
									view.setImageMatrix(matrix);
									return true;
								} else {
									matrix.postScale(multiple, multiple, (clipR + clipL) / 2,
											y);
									view.setImageMatrix(matrix);
									return true;
								}
							}

						}
					}
				}
			}
			break;
		}
		view.setImageMatrix(matrix);

		return true;
	}

	public Rect getImageRect(Matrix matrix, ImageView imageView) {
		Rect rectBound = imageView.getDrawable().getBounds();
		float[] values = new float[9];
		matrix.getValues(values);
		Rect rect = new Rect();
		rect.left = (int) values[2];
		rect.top = (int) values[5];
		rect.right = (int) (rect.left + rectBound.width() * values[0]);
		rect.bottom = (int) (rect.top + rectBound.height() * values[0]);
		return rect;
	}

	/** Determine the space between the first two fingers */
	private float spacing(MotionEvent event) {
		float x = event.getX(0) - event.getX(1);
		float y = event.getY(0) - event.getY(1);
		return FloatMath.sqrt(x * x + y * y);
	}

	/** Calculate the mid point of the first two fingers */
	private void midPoint(PointF point, MotionEvent event) {
		float x = event.getX(0) + event.getX(1);
		float y = event.getY(0) + event.getY(1);
		point.set(x / 2, y / 2);
	}

	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.gl_modify_avatar_save:
			UserProfileActivity.mIsHeadChanged = true;
			String path = BitmapManager.saveToLocal(getBitmap(), FileSystem
					.getInstance().getUserImagePath(), FileSystem.getInstance()
					.getUserHeadName());
			if(Constants.DEBUG){
			Log.i(TAG, "截取后图片的路径是 = " + path);
			}
			Intent intent = new Intent();
			intent.putExtra("path", path);
			setResult(RESULT_OK, intent);
			
			/*if(mPath.contains("head_temp")){
				new Thread(new Runnable() {
					public void run() {
						FileHelper.deleteFile(new File(mPath), false);
					}
				}).start();
			}*/
			
			finish();
			break;
		case R.id.gl_modify_avatar_cancel:
			finish();
			break;
		default:
			break;
		}
	}

	/* ��ȡ���������ڵĽ�ͼ */
	private Bitmap getBitmap() {
		getBarHeight();
		Bitmap screenShoot = takeScreenShot();

		clipview = (ClipView) this.findViewById(R.id.clipview);
		int width = clipview.getWidth();
		int height = clipview.getHeight();
		int x = (int) ((width - height / 2.5f) / 2)
				+ Tools.dip2px(ClipPictureActivity.this, 10);
		int y = height / 5-1 + titleBarHeight + statusBarHeight
				+ Tools.dip2px(ClipPictureActivity.this, 10);
		int bitmapWid = width - x * 2 - 2;
		Bitmap finalBitmap = Bitmap.createBitmap(screenShoot, x, y, bitmapWid,
				bitmapWid);
		return finalBitmap;
	}

	int statusBarHeight = 0;
	int titleBarHeight = 0;

	private void getBarHeight() {
		// ��ȡ״̬���߶�
		Rect frame = new Rect();
		this.getWindow().getDecorView().getWindowVisibleDisplayFrame(frame);
		statusBarHeight = frame.top;

		int contenttop = this.getWindow()
				.findViewById(Window.ID_ANDROID_CONTENT).getTop();
		// statusBarHeight�����������״̬���ĸ߶�
		titleBarHeight = contenttop - statusBarHeight;
		if(Constants.DEBUG){
		Log.v(TAG, "statusBarHeight = " + statusBarHeight
				+ ", titleBarHeight = " + titleBarHeight);
		}
	}

	// ��ȡActivity�Ľ���
	private Bitmap takeScreenShot() {
		View view = this.getWindow().getDecorView();
		view.setDrawingCacheEnabled(true);
		view.buildDrawingCache();
		return view.getDrawingCache();
	}

	public void getWindowWidHe() {
		DisplayMetrics dm = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(dm);
		screenWidth = dm.widthPixels;
		screenHeight = dm.heightPixels;
	}

	public Bitmap createBitmap(String path, int w, int h) {
		try {
			BitmapFactory.Options opts = new BitmapFactory.Options();
			opts.inJustDecodeBounds = true;
			// 这里是整个方法的关键，inJustDecodeBounds设为true时将不为图片分配内存。
			BitmapFactory.decodeFile(path, opts);
			int srcWidth = opts.outWidth;// 获取图片的原始宽度
			int srcHeight = opts.outHeight;// 获取图片原始高度
			// 缩放的比例
			double ratio = 0.0;
			BitmapFactory.Options newOpts = new BitmapFactory.Options();
			if (srcWidth >= clipViewWidth && srcHeight >= clipViewHeight) {
				Double radiow = (double) (srcWidth / clipViewWidth);
				Double radioh = (double) (srcHeight / clipViewHeight);
				ratio = Math.max(radiow, radioh);
				destWidth = (int) (srcWidth / ratio);
				destHeight = (int) (srcHeight / ratio);

				newOpts.inSampleSize = (int) ratio;
				newOpts.outHeight = destHeight;
				newOpts.outWidth = destWidth;
				newOpts.inJustDecodeBounds = false;
				newOpts.inPreferredConfig = Bitmap.Config.RGB_565;
				// 获取缩放后图片
				return BitmapFactory.decodeFile(path, newOpts);
			} else if ((srcWidth >= w && srcHeight >= h)
					&& (srcWidth < clipViewWidth || srcHeight < clipViewHeight)) {
				ratio = 0.0;
				destWidth = srcWidth;
				destHeight = srcHeight;

				newOpts.inSampleSize = 1;
				newOpts.outHeight = destHeight;
				newOpts.outWidth = destWidth;
				newOpts.inJustDecodeBounds = false;
				newOpts.inPreferredConfig = Bitmap.Config.RGB_565;
				// 获取缩放后图片
				return BitmapFactory.decodeFile(path, newOpts);
			} else if (srcWidth < w || srcHeight < h) {
				isSmall = true;
				Double radiow = (double) srcWidth / (double) w;
				Double radioh = (double) srcHeight / (double) h;
				ratio = Math.min(radiow, radioh);
				destWidth = (int) (srcWidth / ratio);
				destHeight = (int) (srcHeight / ratio);
				multiple = (float) 1 / (float) ratio;
			}
			// BitmapFactory.Options newOpts = new BitmapFactory.Options();
			// 缩放的比例，缩放是很难按准备的比例进行缩放的，目前我只发现只能通过inSampleSize来进行缩放，其值表明缩放的倍数，SDK中建议其值是2的指数值
			// 设置大小，这个一般是不准确的，是以inSampleSize的为准，但是如果不设置却不能缩放
			newOpts.inSampleSize = 1;
			newOpts.outHeight = destHeight;
			newOpts.outWidth = destWidth;
			newOpts.inJustDecodeBounds = false;
			newOpts.inPreferredConfig = Bitmap.Config.RGB_565;
			// 获取缩放后图片
			return BitmapFactory.decodeFile(path, newOpts);
		} catch (Exception e) {
			FQLog.e("ClipPictureAction", "clip head error");
			e.printStackTrace();
			if (!"".equals(path))
				return BitmapManager.decodeBitmap2Scale(path);
			return null;
		}
	}
}