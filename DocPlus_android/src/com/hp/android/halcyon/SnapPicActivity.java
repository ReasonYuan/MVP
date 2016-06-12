package com.hp.android.halcyon;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.ColorMatrix;
import android.graphics.ColorMatrixColorFilter;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.Rect;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.PictureCallback;
import android.hardware.Camera.ShutterCallback;
import android.hardware.Camera.Size;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.uimodels.OneCopy;
import com.fq.lib.record.RecordCache;
import com.fq.lib.record.RecordConstants;
import com.fq.lib.record.SnapPhotoManager;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.util.BitmapManager;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.util.mail.SendMail;
import com.hp.android.halcyon.widgets.CustomDialog;

/**
 * 拍摄病历图片界面，由浏览病历界面进,入<br/>
 * 作用给这份病历拍摄图片(用于上传到服务器识别).<br/>
 * 需要传入病历的id.<br/>
 * 
 * @author reason
 * @version v3.0.2 2015-03-25
 */
@SuppressLint("NewApi")
public class SnapPicActivity extends Activity implements SurfaceHolder.Callback {

	protected static final String LOG_TAG = SnapPicActivity.class
			.getSimpleName();

	public static final int MIN_PREVIEW_WIDTH = 480;

	public static final int ON_PHOTO_SELECTED = 0xff;

	/**到相册选择图片*/
	public static final int REQUEST_CODE_SELECT_PHOTO = 1;
	
	/**拍完照后到浏览所拍照片的界面*/
	public static final int REQUEST_CODE_PREVIEW_TAKING_PHOTO = 3;

	/**浏览所拍摄、选择的病历图片*/
	public static final int REQUEST_CODE_BROW_PHOTO = 4;

	public static final String EXTRA_PREVIEW_PHOTO_NAMES = "extra_preview_photo_name";
	public static final String EXTRA_BROW_PHOTO_NAMES = "extra_brow_photo_names";
	public static final String EXTRA_BROW_PHOTO_TYPES = "extra_brow_photo_types";

	private String TAG = SnapPicActivity.class.getSimpleName();
	private ImageView mTakePhotoBtn;
	private ImageView mBrowseImg;
	private View mAlbumBtn;
	private View mTypeSelectView;

	private TextView mTitleText;
	private TextView mTypeText;
	/*** 第几份的文本 */
	private TextView mFenCurrent;
	/*** 下一份的按钮 */
	private Button mFenNextBtn;
	/*** 上一份的按钮 */
	private Button mFenLastBtn;

	private Camera camera = null;
	private SurfaceHolder mSurfaceHolder;
	private SurfaceView mSurfaceView01;
	private boolean bPreviewing = false;
	private int intScreenWidth;
//	private FrameLayout mFrameLayout01;
	// private int intScreenHeight;

	public static Activity mActivity;

	private boolean mSurfaceCreated = false;

	/**
	 * please refer to: http://114.215.196.3:7080/browse/DOCTORPLUS-74
	 * 显示view需要和实际视频一样的长宽比
	 */
	private boolean mIsInitedSurfaceViewSize = false;

	private Size mOptiminalPhotoSize;

	private int mRecordId;
	private boolean isAdmissionEnough;
	private boolean isDisChargeEnouth;

	private SnapPhotoManager mSnapManager;

	/**
	 * 目标拍摄图片的大小，80W像素
	 */
	private final Point mTargetPicSize = new Point(1080, 1920);

	/**
	 * 模式 NONE：无 FOCUSING：正在聚焦. FOCUSED:聚焦成功 FOCUSFAIL：聚焦失败
	 */
	// private enum MODE {
	// NONE, FOCUSING, FOCUSED, FOCUSFAIL
	// };

	// private MODE mode = MODE.NONE;// 默认模式

	/***/
	private RelativeLayout mSufaceParentLayout;

	private View mFocusView;

	@SuppressLint("NewApi")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		int docType = RecordCache.getInstance().getDocType();
		mRecordId = RecordCache.getInstance().getRecordId();
		isAdmissionEnough = getIntent().getBooleanExtra("is_admissin_enough",false);
		isDisChargeEnouth = getIntent().getBooleanExtra("is_discharge_enough",false);

		setContentView(R.layout.activity_snapphoto);

		// 为了从病历记录里面找出已经有l一份的入院记录和出院记录
		int currType = getIntent().getIntExtra("itemType",
				RecordConstants.TYPE_EXAMINATION);
		mSnapManager = SnapPhotoManager.instance(mRecordId, docType, currType,
				isAdmissionEnough, isDisChargeEnouth);

		mTypeText = (TextView) findViewById(R.id.tv_tp_pagenum);
		mTitleText = (TextView) findViewById(R.id.tv_take_photo_title);
		mTakePhotoBtn = (ImageView) findViewById(R.id.btn_capture);
		mBrowseImg = (ImageView) findViewById(R.id.btn_sum);
		mAlbumBtn = findViewById(R.id.btn_album);
		mTypeSelectView = findViewById(R.id.fl_snap_type_select);
		mSufaceParentLayout = (RelativeLayout) findViewById(R.id.mSurfaceView01Parent);
		mFocusView = findViewById(R.id.view_focus);

		mFenCurrent = (TextView) findViewById(R.id.tv_snap_current_fen);
		mFenLastBtn = (Button) findViewById(R.id.btn_snap_last_fen);
		mFenNextBtn = (Button) findViewById(R.id.btn_snap_next_fen);
		
		
		//如果还有之前没上传的图片
		if(mSnapManager.getTypes().size() > 0){
			updatePhotoCounter(mSnapManager.getLastPhoto().getPath());//初始化最后一张图片
			if(currType == RecordConstants.TYPE_ADMISSION&&mSnapManager.isHaveType(currType)){
				mTypeSelectView.setVisibility(View.GONE);
				mSnapManager.setToTypeInFirst(currType);
			}else if(currType == RecordConstants.TYPE_DISCHARGE&&mSnapManager.isHaveType(currType)){
				mTypeSelectView.setVisibility(View.GONE);
				mSnapManager.setToTypeInFirst(currType);
			}else {
				onNextOne(null);
			}
		}
		
		String typeName = RecordConstants.getTypeNameByRecordType(currType);
		mTitleText.setText(typeName);
		setTypeName(typeName);
		checkFenButton();
		checkCurren();

		// 取得屏幕解析像素
		getDisplayMetrics();
		// 以SurfaceView作为相机Preview之用
		mSurfaceView01 = (SurfaceView) findViewById(R.id.mSurfaceView01);
		getSurfaceHolder();
		mSurfaceView01.setOnTouchListener(new OnTouchListener() {
			public boolean onTouch(View v, MotionEvent event) {
				if (event.getAction() == MotionEvent.ACTION_DOWN) {
					int width = mFocusView.getWidth();
					int height = mFocusView.getHeight();
					mFocusView.setBackgroundResource(R.drawable.ic_focus_focusing);
					mFocusView.setX(event.getX() - (width / 2));
					mFocusView.setY(event.getY() - (height / 2));
				} else if (event.getAction() == MotionEvent.ACTION_UP) {
					// mode = MODE.FOCUSING;
					focusOnTouch(event);
				}
				camera.cancelAutoFocus();
				camera.autoFocus(new AutoFocusCallback() {
					@Override
					public void onAutoFocus(boolean success, Camera c) {
						if (success) {
							// mode = MODE.FOCUSED;
							mFocusView.setBackgroundResource(R.drawable.ic_focus_focused);
						} else {
							// mode = MODE.FOCUSFAIL;
							mFocusView.setBackgroundResource(R.drawable.ic_focus_failed);
						}
						setFocusView();
					}
				});
				return true;
			}
		});
		mTakePhotoBtn.setOnClickListener(new Button.OnClickListener() {
			@Override
			public void onClick(View v) {
				if (mSnapManager.isAllowCatch()) {
					takeAPicture();
				} else {
					UITools.showToast("一份化验单只能拍摄一张图片");
				}
			}
		});

		mBrowseImg.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {
				if (mSnapManager.getTypes().size() < 1)
					return;
				Intent intent = new Intent(SnapPicActivity.this, BrowTakePhotoActivity.class);
				startActivityForResult(intent, REQUEST_CODE_BROW_PHOTO);
			}
		});

		mAlbumBtn.setOnClickListener(new Button.OnClickListener() {
			public void onClick(View v) {
				if (mSnapManager.isAllowCatch()) {
					Intent intent = new Intent(SnapPicActivity.this,
							SelectPhotoBucketListActivity.class);

					// 化验只能选一张
					intent.putExtra("is_single_slection",
							mSnapManager.isSignlePhoto());
					startActivityForResult(intent, REQUEST_CODE_SELECT_PHOTO);
				} else {
					UITools.showToast("一份化验单只能拍摄一张图片");
				}
			}
		});
		mActivity = this;
	}

	@Override
	protected void onPause() {
		releaseCamera();
		super.onPause();
	}

	@Override
	public void onStop() {
		releaseCamera();
		super.onStop();
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		mActivity = null;
	}

	@Override
	protected void onResume() {
		if (mSurfaceCreated) {
			try {
				getSurfaceHolder();
				initCamera();
			} catch (IOException e) {
				Log.e(TAG, "initCamera() in Resume() erorr!");
				SendMail.send_qqmail("not app crash, just for camera", e,getApplicationContext());
			}
		}
		super.onResume();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

		// 从相册选择了照片返回
		if (requestCode == REQUEST_CODE_SELECT_PHOTO && resultCode == SelectPhotoActivity.TO_ALBUM_RESULT) {
			ArrayList<String> photoFiles = data.getStringArrayListExtra(SelectPhotoActivity.EXTRA_PHOTO_NAMES);

			// 化验单是单选
			if (photoFiles == null) {
				String path = data.getStringExtra(SelectPhotoActivity.EXTRA_PHOTO_NAMES);
				if (path != null) {
					initCurrentCopy();
					currentCopyAddPhoto(path);
					updatePhotoCounter(path);
					return;
				}
			}
			// 多选的情况
			if (photoFiles != null && photoFiles.size() > 0) {
				initCurrentCopy();
				for (int i = 0; i < photoFiles.size(); i++) {// 把相册的照片拷贝到缓存目录
					final String srcPath = photoFiles.get(i);
					currentCopyAddPhoto(srcPath);
				}
				// 更新数字，如果是不显示预览，则在jpgCallback的runOnUiThread里调用
				String lastName = photoFiles.get(photoFiles.size() - 1);
				updatePhotoCounter(lastName);
			}
		} else if (requestCode == REQUEST_CODE_PREVIEW_TAKING_PHOTO) {
			if (resultCode == PreviewPhotoActivity.RESULT_CODE_APPLY) {
				String imagePath = data.getStringExtra(EXTRA_PREVIEW_PHOTO_NAMES);
				// 如果是拍照过去的，必定只有一张照片
				initCurrentCopy();
				currentCopyAddPhoto(imagePath);

				// 更新数字，如果是不显示预览，则在jpgCallback的runOnUiThread里调用
				updatePhotoCounter(imagePath);
			}
		} else if (requestCode == REQUEST_CODE_BROW_PHOTO) {// 重浏览照片页面返回
			if (resultCode == BrowTakePhotoActivity.RESULT_CODE_BROW_TAKE_PHOTO) {// 一般返回
				updatePhotoCounter(null);
				mSnapManager.reSetData();
				checkFenButton();
				checkCurren();
			} else if (resultCode == 333) {// 需要拍照
				updatePhotoCounter(null);
				int index = data.getIntExtra("type_index", -1);
				selectIndex(index);
			} else if (resultCode == BrowTakePhotoActivity.RESULT_CODE_BROW_UPLOAD) {// 上传病历
				setResult(ON_PHOTO_SELECTED, data);
				finish();
			}
		}
	}

	private void selectIndex(int index) {
		mSnapManager.selectIndex(index);

		checkFenButton();
		checkCurren();
		mTypeSelectView.setVisibility(View.GONE);
		mTitleText.setText(mSnapManager.getCurrenTypeName());
	}

	/**
	 * 更新左下角的图片统计数字
	 * 
	 * @param bmpName
	 *            图片路径，如果没有则返回null
	 */
	private void updatePhotoCounter(String bmpPath) {
		int counter = mSnapManager.getPhotoCount();
		if (counter > 0) {
			findViewById(R.id.fl_brow_view).setVisibility(View.VISIBLE);
			TextView tvPhotoCounter = (TextView) findViewById(R.id.tv_photo_counter);
			tvPhotoCounter.setText("" + counter);

			String imgPath = null;
			if (bmpPath != null) {
				imgPath = bmpPath;
			} else {
				PhotoRecord photo = mSnapManager.getLastPhoto();
				if (photo != null)
					imgPath = photo.getLocalPath();
			}
			if (imgPath != null) {
				mBrowseImg.setImageBitmap(BitmapManager.decodeBitmap2ScaleTo(
						imgPath, 30));
			}
		} else {
			findViewById(R.id.fl_brow_view).setVisibility(View.GONE);
		}
	}

	/*
	 * function: 非preview时：实例化Camera,开始preview 非preview时and相机打开时：再设置一次preview
	 * preview时：不动作
	 */
	private void initCamera() throws IOException {
		if (!bPreviewing) {
			/* 若相机非在预览模式，则打开相机 */
			try {
				camera = Camera.open();
				camera.setDisplayOrientation(90);
				Camera.Parameters parameters = camera.getParameters();
				List<Size> sizes = parameters.getSupportedPictureSizes();
				int width = 0;
				Size size = null;
				for (Size tSize : sizes) {
					if (tSize.width > width) {
						size = tSize;
						width = size.width;
					}
				}
				// parameters.setPictureSize(size.width, size.height);
				camera.setParameters(parameters);
			} catch (Exception e) {
				e.printStackTrace();
				SendMail.send_qqmail("not crash, just for camera", e,
						getApplicationContext());
			}
		}
		// 非预览时and相机打开时，开启preview
		if (camera != null && !bPreviewing) {
			startPreview(mSurfaceHolder);
			// /* 创建Camera.Parameters对象 */
			// // Camera.Parameters parameters = camera.getParameters();
			// // /* 设置相片格式为JPEG */
			// // parameters.setPictureFormat(PixelFormat.RGB_888);
			// // /* 指定preview的屏幕大小 */
			// // parameters.setPreviewSize(intScreenWidth, intScreenHeight);
			// /* 设置图片分辨率大小 */
			// /* 将Camera.Parameters设置予Camera */
			// // camera.setParameters(parameters);
			// /* setPreviewDisplay唯一的参数为SurfaceHolder */
			// // parameters.getSupportedPreviewSizes();
			// camera.setPreviewDisplay(mSurfaceHolder);
			// /* 立即运行Preview */
			// camera.startPreview();
			bPreviewing = true;
		}
	}

	/* func:停止preview,释放Camera对象 */
	private void releaseCamera() {
		if (camera != null && bPreviewing) {
			camera.stopPreview();
			/* 释放Camera对象 */
			camera.release();
			camera = null;
			bPreviewing = false;
		}
	}

	/* func:停止preview */
	/*private void stopPreview() {
		if (camera != null && bPreviewing) {
			camera.stopPreview();
		}
	}*/

	private void takeAPicture() {
		if (camera != null && bPreviewing) {
			camera.takePicture(shutterCallback, rawCallback, jpegCallback);
			/*
			 * camera.cancelAutoFocus(); camera.autoFocus(new
			 * AutoFocusCallback() {
			 * 
			 * @Override public void onAutoFocus(boolean success, Camera c) {
			 * 调用takePicture()方法拍照 camera.takePicture(shutterCallback,
			 * rawCallback, jpegCallback);// 调用PictureCallback //
			 * interface的对象作为参数 } });
			 */
		}
	}

	/* func:获取屏幕分辨率 */
	private void getDisplayMetrics() {
		DisplayMetrics dm = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(dm);
		intScreenWidth = dm.widthPixels;
		// intScreenHeight = dm.heightPixels;
		if (Constants.DEBUG) {
			Log.i(TAG, Integer.toString(intScreenWidth));
		}
	}

	private ShutterCallback shutterCallback = new ShutterCallback() {
		public void onShutter() {
		}
	};

	private PictureCallback rawCallback = new PictureCallback() {
		public void onPictureTaken(byte[] _data, Camera _camera) {
		}
	};

	private PictureCallback jpegCallback = new PictureCallback() {
		public void onPictureTaken(byte[] _data, Camera _camera) {
			// 保存
			Bitmap bitmap23 = BitmapFactory.decodeByteArray(_data, 0,
					_data.length);

			Matrix m = new Matrix();
			m.setRotate(90);
			// float scale = 1f;
			// m.setRotate(90, (float) bitmap23.getWidth() / scale,
			// (float) bitmap23.getHeight() / scale);
			final Bitmap bitmap = Bitmap.createBitmap(bitmap23, 0, 0,
					bitmap23.getWidth(), bitmap23.getHeight(), m, true);

			// 新增加代码 发现以前的图片比拍出来的图片有点饱和度这些差异，稍微调整了下
			// Bitmap mTmpBitmap = null;
			// mTmpBitmap = Bitmap.createBitmap(bitmap.getWidth(),
			// bitmap.getHeight(), Config.ARGB_8888);
			// ColorMatrix matrix = new ColorMatrix();
			// //设置饱和度
			// matrix.setSaturation(0.8f);
			// // 设置亮度 和 对比度为最高 第 5、10、15 填20的表示亮度 第 1、7、13位表示对比度
			// matrix.set(new float[] { 1, 0, 0, 0, 15, 0, 1,
			// 0, 0, 15,
			// 0, 0, 1, 0, 15, 0, 0, 0, 1, 0 });
			// Paint mPaint = new Paint();
			// mPaint.setColorFilter(new ColorMatrixColorFilter(matrix));
			// Canvas mCanvas = new Canvas(mTmpBitmap);
			// mCanvas.drawBitmap(bitmap, 0, 0, mPaint);
			// bitmap = mTmpBitmap;

			if (bitmap != null) {
				try {
					// 拍照完后需要处理的事情
					Intent intent = new Intent(SnapPicActivity.this,PreviewPhotoActivity.class);
					mSnapManager.setTakePhoto(bitmap);
					startActivityForResult(intent,REQUEST_CODE_PREVIEW_TAKING_PHOTO);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			releaseCamera();
			try {
				initCamera();
			} catch (Exception e) {
				Log.e(TAG, "initCamera Error after snapping");
				SendMail.send_qqmail("initCamera Error after snapping", e,
						getApplicationContext());
			}
		}
	};
	
	/* get a fully initialized SurfaceHolder */
	private void getSurfaceHolder() {
		mSurfaceHolder = mSurfaceView01.getHolder();
		mSurfaceHolder.addCallback(this);
		mSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
	}

	/* 把SurfaceView 加到FrameLayout 里 */
	/*private void addSurfaceViewToFrameLayout() {
		mFrameLayout01.addView(mSurfaceView01);
	}*/

	/* func:弹出toast,主要做测试用 */
	/*private void jumpOutAToast(String string) {
		Toast.makeText(this, string, Toast.LENGTH_SHORT).show();
	}*/

	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		if (!bPreviewing) {
			Camera c = Camera.open();
			if (c != null) {
				camera = c;
				camera.setDisplayOrientation(90);
			}
			if (camera == null) {
				Log.e("", "打开相机失败 ... 可能没有相机");
			}
		}
		mSurfaceCreated = true;
	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {
		if (camera == null) {
			return;
		}
		if (bPreviewing) {
			camera.stopPreview();
		}
		boolean changed = false;
		if (!mIsInitedSurfaceViewSize) {
			changed = changeSurfaceViewSize();
			mIsInitedSurfaceViewSize = true;
		}
		if (!changed) {
			try {
				startPreview(mSurfaceHolder);
			} catch (IOException e) {
				e.printStackTrace();
				throw new RuntimeException(e);
			}
			bPreviewing = true;
		}
	}

	private boolean changeSurfaceViewSize() {
		Camera.Parameters cameraParameters = camera.getParameters();
		final List<Camera.Size> sizes = cameraParameters
				.getSupportedPreviewSizes();
		// 获得最优预览大小
		Point viewSize = new Point(mSurfaceView01.getWidth(),
				mSurfaceView01.getHeight());
		int height = mSurfaceView01.getHeight();
		// int width = mSurfaceView01.getHeight()*9/16;
		int width = mSurfaceView01.getWidth();
		mOptiminalPhotoSize = getOptimalPreviewSize3(sizes, viewSize); 
		
		// resize the SurfaceView according preview size
		if (!mIsInitedSurfaceViewSize) {
			mIsInitedSurfaceViewSize = true;
			double ratioOpt = (double) mOptiminalPhotoSize.width
					/ mOptiminalPhotoSize.height;
			double ratioView = (double) viewSize.y / viewSize.x;
			Point newViewSize = null;
			if (ratioOpt == ratioView) {
				return false;
			} else if (ratioOpt > ratioView) {
				// 两边黑边
				double scale = (double) viewSize.y / mOptiminalPhotoSize.width;
				newViewSize = new Point(
						(int) (mOptiminalPhotoSize.height * scale),
						(int) (mOptiminalPhotoSize.width * scale));
			} else {
				// 上下黑边
				double scale = (double) viewSize.x / mOptiminalPhotoSize.height;
				newViewSize = new Point(
						(int) (mOptiminalPhotoSize.height * scale),
						(int) (mOptiminalPhotoSize.width * scale));
			}
			// mSurfaceView01.setLayoutParams(new
			// RelativeLayout.LayoutParams(newViewSize.x, newViewSize.y));
			mSurfaceView01.setLayoutParams(new RelativeLayout.LayoutParams(
					width, height));
		}
		return false;
	}

	/*private float distance(int x1, int y1, int x2, int y2) {
		int disX = x2 - x1;
		int disY = y2 - y1;
		return (float) Math.sqrt(disX * disX + disY * disY);
	}*/

	/**
	 * 计算宽高比例最为接近的用为preview的宽高 x1,y1为当前size x2，y2为目标size
	 */
	private float calculateScale(int x1, int y1, int x2, int y2) {
		float currentScale = (float) y1 / x1;
		float targetScale = (float) y2 / x2;
		float difference = -1;
		if (x1 * y1 <= mTargetPicSize.x * mTargetPicSize.y) {
			difference = Math.abs(targetScale - currentScale);
		} else {
			difference = -1;
		}
		return difference;
	}

	private Size findingBestSizeWithScale(Size tmpSize, List<Size> Sizes) {
		Size mSize = null;
		Size mReturnSize = null;
		int area = tmpSize.height * tmpSize.width;
		float scale = (float) tmpSize.width / tmpSize.height;
		int tmpArea = 0;
		float tmpScale = 0;

		for (int i = 0; i < Sizes.size(); i++) {
			mSize = Sizes.get(i);
			tmpScale = (float) mSize.width / mSize.height;
			tmpArea = mSize.width * mSize.height;
			if (tmpArea <= mTargetPicSize.x * mTargetPicSize.y) {
				if (scale == tmpScale) {
					if (tmpArea > area) {
						mReturnSize = mSize;
					} else {
						mReturnSize = tmpSize;
					}
				}
			} else {
				if (mReturnSize == null) {
					mReturnSize = tmpSize;
				}
			}

		}
		return mReturnSize;
	}

	/**
	 * configure camera, start preview and pipe it to surface holder use it to
	 * whenever you are starting preview - in resume - when surface changed - on
	 * config changes etc
	 * 
	 * @param holder
	 */
	private void startPreview(SurfaceHolder holder) throws IOException {
		Camera.Parameters cameraParameters = camera.getParameters();

		List<Size> perviewSizes = cameraParameters.getSupportedPreviewSizes();
		Size perviewSize = null;
		float minDis = Float.MAX_VALUE;
		float minDifference = 0;
		for (int i = 0; i < perviewSizes.size(); i++) {
			Size currentSize = perviewSizes.get(i);
			float differrence = calculateScale(currentSize.height,
					currentSize.width, mSurfaceView01.getWidth(),
					mSurfaceView01.getHeight());
			if (differrence > 0) {
				if (minDifference == 0) {
					minDifference = differrence;
					perviewSize = currentSize;
				} else {
					if (minDifference > differrence) {
						minDifference = differrence;
						perviewSize = currentSize;
					}
				}

			} else if (differrence == 0) {
				minDifference = differrence;
				perviewSize = currentSize;
				break;
			}
		}
		perviewSize = findingBestSizeWithScale(perviewSize, perviewSizes);
		if (perviewSize != null)
			cameraParameters.setPreviewSize(perviewSize.width,
					perviewSize.height);
		System.out.println(perviewSize.width + "------" + perviewSize.height);
		List<Size> pictureSizes = cameraParameters.getSupportedPictureSizes();
		Size pictureSize = null;
		float minPicDifference = 0;
		for (int i = 0; i < pictureSizes.size(); i++) {
			Size currentSize = pictureSizes.get(i);
			float picdifferrence = calculateScale(currentSize.height,
					currentSize.width, mSurfaceView01.getWidth(),
					mSurfaceView01.getHeight());
			if (picdifferrence > 0) {
				if (minPicDifference == 0) {
					minPicDifference = picdifferrence;
					pictureSize = currentSize;
				} else {
					if (minPicDifference > picdifferrence) {
						minPicDifference = picdifferrence;
						pictureSize = currentSize;
					}
				}

			} else if (picdifferrence == 0) {
				minPicDifference = picdifferrence;
				pictureSize = currentSize;
				break;
			}

		}
		pictureSize = findingBestSizeWithScale(pictureSize, pictureSizes);

		if (pictureSize != null)
			cameraParameters.setPictureSize(pictureSize.width,
					pictureSize.height);
		System.out.println(pictureSize.width + "------" + pictureSize.height);
		camera.setParameters(cameraParameters);

		// set preview display destination
		camera.setPreviewDisplay(holder);

		camera.startPreview();
		// in case it was modified
		// Camera.Size previewSize = cameraParameters.getPreviewSize();
	}

	public static Size getOptimalPreviewSize3(List<Size> sizes, Point viewSize) {
		// 取面积最接近的
		int targetArea = viewSize.x * viewSize.y;
		int minDif = Integer.MAX_VALUE;
		int sizeIndex = 0;
		for (int i = 0; i < sizes.size(); i++) {
			Size size = sizes.get(i);
			int area = size.width * size.height;
			int diff = Math.abs(area - targetArea);
			if (diff < minDif) {
				minDif = diff;
				sizeIndex = i;
			}
		}
		return sizes.get(sizeIndex);
	}

	public static Size getOptimalPreviewSize2(Activity currentActivity,
			List<Size> sizes, double targetRatio) {
		// Use a very small tolerance because we want an exact match.
		final double ASPECT_TOLERANCE = 0.001;
		if (sizes == null)
			return null;

		Size optimalSize = null;
		double minDiff = Double.MAX_VALUE;

		// Because of bugs of overlay and layout, we sometimes will try to
		// layout the viewfinder in the portrait orientation and thus get the
		// wrong size of preview surface. When we change the preview size, the
		// new overlay will be created before the old one closed, which causes
		// an exception. For now, just get the screen size.
		Point point = getDefaultDisplaySize(currentActivity, new Point());
		int targetHeight = Math.max(point.x, point.y); // min to max
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
		// Cannot find the one match the aspect ratio. This should not happen.
		// Ignore the requirement.
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

	@SuppressLint("NewApi")
	private static Point getDefaultDisplaySize(Activity activity, Point size) {
		Display d = activity.getWindowManager().getDefaultDisplay();
		if (Build.VERSION.SDK_INT >= 13) { // ApiHelper.VERSION_CODES.HONEYCOMB_MR2
			d.getSize(size);
		} else {
			size.set(d.getWidth(), d.getHeight());
		}
		return size;
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		if (camera != null) {
			try {
				camera.stopPreview();
				camera.release();
			} catch (Exception e) {
				Log.e(TAG, "", e);
			}
		}
		bPreviewing = false;
		mSurfaceHolder = null;
	}

	/**
	 * 图片去色,返回灰度图片， 感觉比 {@link #convertGreyImg(Bitmap)} 清晰度高一点
	 * 
	 * @param bmpOriginal
	 *            传入的图片
	 * @return 去色后的图片
	 */
	private static Bitmap toGrayscale(Bitmap bmpOriginal) {
		int width, height;
		height = bmpOriginal.getHeight();
		width = bmpOriginal.getWidth();
		Bitmap bmpGrayscale = Bitmap.createBitmap(width, height,
				Bitmap.Config.RGB_565);
		Canvas c = new Canvas(bmpGrayscale);
		Paint paint = new Paint();
		ColorMatrix cm = new ColorMatrix();
		cm.setSaturation(0);
		ColorMatrixColorFilter f = new ColorMatrixColorFilter(cm);
		paint.setColorFilter(f);
		c.drawBitmap(bmpOriginal, 0, 0, paint);
		// c.drawBitm
		return bmpGrayscale;
	}

	@Override
	public void onBackPressed() {
		
		//如果没有选择上传图片就退出，则将拍好的图片保存在内存当中，用于下次进入时再显示
		if(mSnapManager.getTypes().size() > 0){
			RecordCache.getInstance().setUnUploadTypes(mSnapManager.getTypes());
		}
		
		mSnapManager.clear();
		super.onBackPressed();
	}

	public void onTopRightBtnClick(View view) {
		if (Constants.getUser().isOnlyWifi()) {
			if (!UITools.isWifiConnected(SnapPicActivity.this)) {
				settingWifiDialog();
				return;
			}
		}
		Intent tIntent = new Intent();
		setResult(ON_PHOTO_SELECTED, tIntent);
		finish();
	}

	public void onBrowImgClick(View v) {
		if (mSnapManager.getTypes().size() < 1)
			return;
		Intent intent = new Intent(this, BrowTakePhotoActivity.class);
		startActivityForResult(intent, REQUEST_CODE_BROW_PHOTO);
	}

	/**
	 * 上一份病历类型
	 * 
	 * @param view
	 */
	public void onClickedPreCategory(View view) {
		mSnapManager.lastRecordType();
		String typeName = mSnapManager.getSelectTypeName();
		mTitleText.setText(typeName);
		setTypeName(typeName);
	}

	/**
	 * 下一份病历类型
	 * 
	 * @param view
	 */
	public void onClickedNextCategory(View view) {
		mSnapManager.nextRecordType();
		String typeName = mSnapManager.getSelectTypeName();
		mTitleText.setText(typeName);
		setTypeName(typeName);
	}

	/**
	 * 下一份
	 */
	public void onNextOne(View v) {
		mSnapManager.nextRecordItem();
		if (mSnapManager.getCurrentIndex() < mSnapManager.getTypeCount()) {
			initCurrentCopy();
			mTypeSelectView.setVisibility(View.GONE);
			mTitleText.setText(mSnapManager.getCurrenTypeName());
		} else {
			if (mSnapManager.isChangeType()) {
//				String typeName = mSnapManager.getSelectTypeName();
//				mTitleText.setText(typeName);
//				setTypeName(typeName);
			}
			String typeName = mSnapManager.getSelectTypeName();
			mTitleText.setText(typeName);
			setTypeName(typeName);
			mTypeSelectView.setVisibility(View.VISIBLE);
		}

		checkFenButton();
		checkCurren();
	}

	/**
	 * 上一份
	 */
	public void onLastOne(View v) {
		mSnapManager.lastRecordItem();
		initCurrentCopy();
		mTypeSelectView.setVisibility(View.GONE);
		mTitleText.setText(mSnapManager.getCurrenTypeName());

		checkFenButton();
		checkCurren();
	}

	/**
	 * 检查上一份、下一份按钮使用情况
	 */
	private void checkFenButton() {
		if (mSnapManager.getTypeCount() == 0
				|| mSnapManager.getCurrentIndex() == 0) {
			mFenLastBtn.setVisibility(View.GONE);
		} else {
			mFenLastBtn.setVisibility(View.VISIBLE);
		}

		if (mSnapManager.getCurrentCopy() != null) {
			mFenNextBtn.setVisibility(View.VISIBLE);
		} else {
			mFenNextBtn.setVisibility(View.GONE);
		}
	}

	/**
	 * 检查中间当前份数的情况
	 */
	private void checkCurren() {
		int count = mSnapManager.getCurrentTypePhotoCount();
		mFenCurrent.setText("第" + (mSnapManager.getCurrentIndex() + 1) + "份("
				+ count + ")");
	}

	private void initCurrentCopy() {
		OneCopy copy = mSnapManager.getCurrentCopy();
		if (copy != null)
			return;
		if (mSnapManager.getCurrentType() == null) {
			mTypeSelectView.setVisibility(View.GONE);
		}
		mSnapManager.initCurrentType();
	}

	private void currentCopyAddPhoto(String path) {
		mSnapManager.currentCopyAddPhoto(path);
		checkFenButton();
		checkCurren();
	}

	private void setTypeName(String typeName) {
		mTypeText.setText(typeName);
		// mTypeText.setClickable(false);
		// mTypeText.setVisibility(View.VISIBLE);
	}

	/** 返回键点击时后的提醒 */
	protected void dialog() {
		AlertDialog.Builder builder = new AlertDialog.Builder(
				SnapPicActivity.this);
		builder.setTitle("是否放弃已拍摄照片？");
		builder.setPositiveButton("确认", new DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				finish();
			}
		});
		builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {

			}
		});
		builder.create().show();
	}


	// 提示是否设置Wifi的dialog
	private void settingWifiDialog() {
		final CustomDialog dialog = new CustomDialog(this);
		dialog.setMessage("您的wifi处于关闭状态，是否要打开wifi？");

		dialog.setPositiveListener(R.string.btn_sure_ren,
				new View.OnClickListener() {

					@Override
					public void onClick(View arg0) {
						// TODO Auto-generated method stub
						dialog.dismiss();
						Intent wifiSettingsIntent = new Intent(
								"android.settings.WIFI_SETTINGS");
						startActivity(wifiSettingsIntent);
					}
				});
		dialog.setNegativeButton(R.string.btn_cancel,
				new View.OnClickListener() {
					@Override
					public void onClick(View arg0) {
						dialog.dismiss();

					}
				});
		dialog.show();
	}

	private void setFocusView() {
		new Handler().postDelayed(new Runnable() {

			@SuppressWarnings("deprecation")
			@Override
			public void run() {
				mFocusView.setBackgroundDrawable(null);

			}
		}, 1 * 1000);
	}

	/**
	 * 设置焦点和测光区域
	 * 
	 * @param event
	 */
	public void focusOnTouch(MotionEvent event) {

		int[] location = new int[2];
		mSufaceParentLayout.getLocationOnScreen(location);

		Rect focusRect = calculateTapArea(mFocusView.getWidth(),
				mFocusView.getHeight(), 1f, event.getRawX(), event.getRawY(),
				location[0], location[0] + mFocusView.getWidth(), location[1],
				location[1] + mFocusView.getHeight());
		Rect meteringRect = calculateTapArea(mFocusView.getWidth(),
				mFocusView.getHeight(), 1.5f, event.getRawX(), event.getRawY(),
				location[0], location[0] + mFocusView.getWidth(), location[1],
				location[1] + mFocusView.getHeight());

		Camera.Parameters parameters = camera.getParameters();
		parameters.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);

		// System.out.println("CustomCameraView getMaxNumFocusAreas = " +
		// parameters.getMaxNumFocusAreas());
		if (parameters.getMaxNumFocusAreas() > 0) {
			List<Camera.Area> focusAreas = new ArrayList<Camera.Area>();
			focusAreas.add(new Camera.Area(focusRect, 1000));

			parameters.setFocusAreas(focusAreas);
		}

		// System.out.println("CustomCameraView getMaxNumMeteringAreas = " +
		// parameters.getMaxNumMeteringAreas());
		if (parameters.getMaxNumMeteringAreas() > 0) {
			List<Camera.Area> meteringAreas = new ArrayList<Camera.Area>();
			meteringAreas.add(new Camera.Area(meteringRect, 1000));

			parameters.setMeteringAreas(meteringAreas);
		}

		try {
			camera.setParameters(parameters);
		} catch (Exception e) {
		}
		// camera.autoFocus(this);
	}

	/**
	 * 计算焦点及测光区域
	 * 
	 * @param focusWidth
	 * @param focusHeight
	 * @param areaMultiple
	 * @param x
	 * @param y
	 * @param previewleft
	 * @param previewRight
	 * @param previewTop
	 * @param previewBottom
	 * @return Rect(left,top,right,bottom) : left、top、right、bottom是以显示区域中心为原点的坐标
	 */
	public Rect calculateTapArea(int focusWidth, int focusHeight,
			float areaMultiple, float x, float y, int previewleft,
			int previewRight, int previewTop, int previewBottom) {
		int areaWidth = (int) (focusWidth * areaMultiple);
		int areaHeight = (int) (focusHeight * areaMultiple);
		int centerX = (previewleft + previewRight) / 2;
		int centerY = (previewTop + previewBottom) / 2;
		double unitx = ((double) previewRight - (double) previewleft) / 2000;
		double unity = ((double) previewBottom - (double) previewTop) / 2000;
		int left = clamp((int) (((x - areaWidth / 2) - centerX) / unitx),
				-1000, 1000);
		int top = clamp((int) (((y - areaHeight / 2) - centerY) / unity),
				-1000, 1000);
		int right = clamp((int) (left + areaWidth / unitx), -1000, 1000);
		int bottom = clamp((int) (top + areaHeight / unity), -1000, 1000);

		return new Rect(left, top, right, bottom);
	}

	public int clamp(int x, int min, int max) {
		if (x > max)
			return max;
		if (x < min)
			return min;
		return x;
	}
	
	public void onTopLeftBtnClick(View view){
		onBackPressed();
	}
}