package com.hp.android.halcyon;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff.Mode;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.net.Uri;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.CertificationStatus;
import com.fq.halcyon.entity.CertificationStatus.AuthImage;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic.DoctorAuthLogic.OnRequestAuthCallback;
import com.fq.halcyon.uilogic.UIAuthLogic;
import com.fq.lib.tools.Constants;
import com.hp.android.halcyon.util.BitmapManager;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CircleImageView;
import com.hp.android.halcyon.widgets.CustomProgressDialog;
import com.hp.android.halcyon.widgets.MyPopupWindow;
import com.hp.android.halcyon.widgets.RoundedImageView;

public class CertificationActivity extends BaseActivity implements
		OnRequestAuthCallback {

	private static final int CERTIFICATE_IMAGE = 1;
	private static final int CARD_ZHENG_IMAGE = 2;
	private static final int CARD_FAN_IMAGE = 3;

	private int status = 0; // 1:选择的相机，2:选择的相册

	private FrameLayout mPicCertification;
	private FrameLayout mPicCardZheng;
	private FrameLayout mPicCardFan;
	private RoundedImageView mImgCertification;
	private CircleImageView mImgCardZheng;
	private CircleImageView mImgCardFan;
	// private TextView mTextNotice;
	// private TextView mTextStatus;
	private Button mButtonApply;// TODO use image button

	// private boolean[] mBmps = new boolean[3];
	// private ArrayList<Integer> mTypes = new ArrayList<Integer>();

	private CertificationStatus mAuthStatus = CertificationStatus.getInstance();

	private UIAuthLogic mUIAuthLogic;

	private CustomProgressDialog mDialog;

	private boolean mIsDoctor;

	private int mPicMode;

	private MyPopupWindow mHeadWindow;
	private OnClickListener mHeadItemOnClick = new OnClickListener() {
		public void onClick(View view) {
			mHeadWindow.dismiss();
			switch (view.getId()) {
			case R.id.btn_me_carmera:// 选择相机
				status = 1;
				Intent intent = new Intent("android.media.action.IMAGE_CAPTURE");
				switch (mPicMode) {
				case CERTIFICATE_IMAGE:
					startActivityForResult(intent, CERTIFICATE_IMAGE);
					break;
				case CARD_ZHENG_IMAGE:
					startActivityForResult(intent, CARD_ZHENG_IMAGE);
					break;
				case CARD_FAN_IMAGE:
					startActivityForResult(intent, CARD_FAN_IMAGE);
					break;
				default:
					break;
				}
				break;
			case R.id.btn_me_album:// 选择本地相册
				Intent intent2 = new Intent();
				intent2.putExtra("is_single_slection", true);
				intent2.setClass(CertificationActivity.this,
						SelectPhotoBucketListActivity.class);
				status = 2;
				switch (mPicMode) {
				case CERTIFICATE_IMAGE:
					startActivityForResult(intent2, CERTIFICATE_IMAGE);
					break;
				case CARD_ZHENG_IMAGE:
					startActivityForResult(intent2, CARD_ZHENG_IMAGE);
					break;
				case CARD_FAN_IMAGE:
					startActivityForResult(intent2, CARD_FAN_IMAGE);
					break;
				default:
					break;
				}
				break;
			case R.id.btn_me_cancel:
				mHeadWindow.dismiss();
				break;
			default:
				break;
			}
		}
	};

	public void showSelectPicView() {
		if (mHeadWindow == null) {
			mHeadWindow = new MyPopupWindow(this,
					R.layout.dialog_me_popupwindow);
			mHeadWindow.setWindow(LayoutParams.MATCH_PARENT,
					LayoutParams.MATCH_PARENT, R.style.popupAnimation);
			mHeadWindow.getView().findViewById(R.id.btn_me_carmera)
					.setOnClickListener(mHeadItemOnClick);
			mHeadWindow.getView().findViewById(R.id.btn_me_album)
					.setOnClickListener(mHeadItemOnClick);
			mHeadWindow.getView().findViewById(R.id.btn_me_cancel)
					.setOnClickListener(mHeadItemOnClick);
		}
		mHeadWindow.showAtLocation(findViewById(R.id.tv_certificate_notice),
				Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL, 0, 0);
	}

	@Override
	public int getContentId() {
		return R.layout.activity_certification;
	}

	@Override
	public void init() {
		mIsDoctor = Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR;

		mUIAuthLogic = new UIAuthLogic();
		initWdiget();

		// if(mIsDoctor){
		setTitle("医生认证");
		((TextView) findViewById(R.id.tv_certificate_notice))
				.setText(getString(R.string.certification_notice, "医师执业证书"));
		// }else{
		// setTitle("学生认证");
		// ((TextView)findViewById(R.id.tv_auth_zhizhao)).setText(R.string.certification_doctor_student);
		// ((TextView)findViewById(R.id.tv_certificate_notice)).setText(getString(R.string.certification_notice,
		// "学生证"));
		// }

		mButtonApply = (Button) findViewById(R.id.bt_do_cert);
		setAuthStatus();

		mButtonApply.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				if (mUIAuthLogic.getTypes().size() == 0) {
					UITools.showToast("请选择照片");
					return;
				}
				mDialog = new CustomProgressDialog(CertificationActivity.this);
				mDialog.setMessage("正在上传照片,请稍候！");
				mUIAuthLogic.applyAuth(CertificationActivity.this);
				setAuthStatus();
			}
		});

		mPicCertification.setOnClickListener(new OnClickListener() {
			// 医师执业证书点击事件
			@Override
			public void onClick(View arg0) {
				selectPic(CERTIFICATE_IMAGE);
			}
		});

		mPicCardZheng.setOnClickListener(new OnClickListener() {
			// 身份证正面点击事件
			@Override
			public void onClick(View arg0) {
				selectPic(CARD_ZHENG_IMAGE);
			}
		});

		mPicCardFan.setOnClickListener(new OnClickListener() {
			// 身份证反面点击事件
			@Override
			public void onClick(View arg0) {
				selectPic(CARD_FAN_IMAGE);
			}
		});

		if (CertificationStatus.getInstance().getState() == CertificationStatus.CERTIFICATION_PASS) {
			mButtonApply.setEnabled(false);
			mPicCertification.setEnabled(false);
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Bitmap bm = null;
		if (resultCode == RESULT_OK && data != null && status == 1) {
			bm = (Bitmap) data.getExtras().get("data");// 获取相机返回的数据，并转换为Bitmap图片格式
		} else if (resultCode == SelectPhotoActivity.TO_ALBUM_RESULT) {
			try {
				Uri uri = Uri.parse(data
						.getStringExtra(SelectPhotoActivity.EXTRA_PHOTO_NAMES));
				byte[] mContent = readStream(new FileInputStream(new File(
						uri.getPath())));// resolver.openInputStream(uri)
				bm = getPicFromBytes(mContent);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		if (bm != null) {
			String path = FileSystem.getInstance().getUserImagePath();
			String name = "";
			switch (requestCode) {
			case CertificationActivity.CERTIFICATE_IMAGE:
				mUIAuthLogic.setBmpReady(1, true);
				if (bm != null) {
					mImgCertification.setBackgroundColor(getResources().getColor(android.R.color.transparent));
				}
				mImgCertification.setImageBitmap(toRoundCorner(bm, 15));

				name = FileSystem.getInstance().getAuthImgNameByType(
						AuthImage.CERTYPE_DOCTOR);
				mUIAuthLogic.addIfTypeNotExits(AuthImage.CERTYPE_DOCTOR);
				// if(!mTypes.contains(AuthImage.CERTYPE_DOCTOR))mTypes.add(AuthImage.CERTYPE_DOCTOR);
				break;
			case CertificationActivity.CARD_ZHENG_IMAGE:
				mUIAuthLogic.setBmpReady(2, true);
				mImgCardZheng.setImageBitmap(bm);
				// findViewById(R.id.tv_label_card_zheng).setVisibility(View.GONE);
				name = FileSystem.getInstance().getAuthImgNameByType(
						AuthImage.CERTYPE_CARD_Z);
				mUIAuthLogic.addIfTypeNotExits(AuthImage.CERTYPE_CARD_Z);
				// if(!mTypes.contains(AuthImage.CERTYPE_CARD_Z))mTypes.add(AuthImage.CERTYPE_CARD_Z);
				break;
			case CertificationActivity.CARD_FAN_IMAGE:
				mUIAuthLogic.setBmpReady(3, true);
				mImgCardFan.setImageBitmap(bm);
				// findViewById(R.id.tv_label_card_fan).setVisibility(View.GONE);
				name = FileSystem.getInstance().getAuthImgNameByType(
						AuthImage.CERTYPE_CARD_F);
				mUIAuthLogic.addIfTypeNotExits(AuthImage.CERTYPE_CARD_F);
				// if(!mTypes.contains(AuthImage.CERTYPE_CARD_F))mTypes.add(AuthImage.CERTYPE_CARD_F);
				break;
			default:
				break;
			}

			if (!"".equals(name))
				BitmapManager.saveToLocal(bm, path, name);

			if (mUIAuthLogic.isAllImgReady()) {
				mButtonApply.setEnabled(true);
			}
		}
	}

	public static Bitmap toRoundCorner(Bitmap bitmap, int pixels) {
		Bitmap output = null;
		if (bitmap == null) {
			return null;
		}
		if (bitmap.getWidth() > bitmap.getHeight()) {
			output = Bitmap.createBitmap(bitmap.getHeight(),
					bitmap.getHeight(), Config.ARGB_8888);
		}
		if (bitmap.getWidth() <= bitmap.getHeight()) {
			output = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getWidth(),
					Config.ARGB_8888);
		}
		Canvas canvas = new Canvas(output);
		final int color = 0xff424242;
		final Paint paint = new Paint();
		final Rect rect = new Rect(0, 0, output.getWidth(), output.getHeight());
		final RectF rectF = new RectF(rect);
		final float roundPx = pixels;
		paint.setAntiAlias(true);
		canvas.drawARGB(0, 0, 0, 0);
		paint.setColor(color);
		canvas.drawRoundRect(rectF, roundPx, roundPx, paint);
		paint.setXfermode(new PorterDuffXfermode(Mode.SRC_IN));
		canvas.drawBitmap(bitmap, rect, rect, paint);
		return output;
	}

	/**
	 * 初始化控件
	 */
	private void initWdiget() {
		mPicCertification = (FrameLayout) findViewById(R.id.fl_certificate);
		mPicCardZheng = (FrameLayout) findViewById(R.id.fl_card_zheng);
		mPicCardFan = (FrameLayout) findViewById(R.id.fl_card_fan);
		mImgCertification = (RoundedImageView) findViewById(R.id.iv_certificate);
		mImgCardZheng = (CircleImageView) findViewById(R.id.iv_card_zheng);
		mImgCardFan = (CircleImageView) findViewById(R.id.iv_card_fan);
		// mTextNotice = (TextView) findViewById(R.id.tv_certificate_notice);
		// mTextNotice.setText(getClickableSpan());
		// mTextStatus = (TextView) findViewById(R.id.tv_certification_status);

		FileSystem filsys = FileSystem.getInstance();
		mUIAuthLogic.initTypes(AuthImage.CERTYPE_DOCTOR);
//		String name = filsys.getUserImagePath() + "/"
//				+ filsys.getAuthImgNameByType(AuthImage.CERTYPE_DOCTOR);
		String name = filsys.getAuthImgPathByType(AuthImage.CERTYPE_DOCTOR);
		Bitmap bmp = UITools.getBitmapWithPath(name);
		mUIAuthLogic.setBmpReady(1, true);
		if (bmp != null) {
			mImgCertification.setBackgroundColor(getResources().getColor(android.R.color.transparent));
		}
		mImgCertification.setImageBitmap(toRoundCorner(bmp, 15));

		/*
		 * for(int i = 1; i < 4; i++){ //initTypes(i);
		 * mUIAuthLogic.initTypes(i); String name =
		 * filsys.getUserImagePath()+"/"+filsys.getAuthImgNameByType(i); Bitmap
		 * bmp = loadBmpByName(name); if(bmp != null){ switch (i) { case
		 * CERTIFICATE_IMAGE: mUIAuthLogic.setBmpReady(1, true);
		 * mImgCertification.setImageBitmap(bmp); break; case CARD_ZHENG_IMAGE:
		 * mUIAuthLogic.setBmpReady(2, true); mImgCardZheng.setImageBitmap(bmp);
		 * break; case CARD_FAN_IMAGE: mUIAuthLogic.setBmpReady(3, true);
		 * mImgCardFan.setImageBitmap(bmp); break; } } }
		 */
	}

	/**
	 * 获取bitmap
	 */
	private Bitmap loadBmpByName(String bmpName) {
		File file = new File(bmpName);
		if (!file.exists())return null;
		BitmapFactory.Options opts = new BitmapFactory.Options();
		opts.inJustDecodeBounds = true;
		BitmapFactory.decodeFile(bmpName, opts);
		int srcWidth = opts.outWidth;
		BitmapFactory.Options newOpts = new BitmapFactory.Options();
		int ratio = srcWidth / 150;
		if (ratio <= 0)ratio = 1;
		newOpts.inSampleSize =  ratio;
		newOpts.inJustDecodeBounds = false;
		newOpts.inPreferredConfig = Bitmap.Config.RGB_565;
		return BitmapFactory.decodeFile(bmpName, newOpts);
	}

	/**
	 * 设置文字颜色
	 */
	/*
	 * private SpannableString getClickableSpan() { boolean isb =
	 * Constants.getUser().getRole_type() == Constants.ROLE_DOCTOR; String
	 * zhengshu = isb?"医师执业证书":"学生证"; SpannableString spanStr = new
	 * SpannableString( "为了保证您的权益和平台的专业性，需要认证您的行医资质，请上传"+zhengshu+
	 * "和身份证照片。谢谢支持！上传资料仅用于身份认证，患者及第三方不可见，您的信息会得到有效保护。");
	 * 
	 * int fir_end = isb?36:33; int sec_bef = isb?37:34; int sen_end =
	 * isb?42:39;
	 * 
	 * // 设置文字的前景色 spanStr.setSpan( new
	 * ForegroundColorSpan(getResources().getColor( R.color.topbar_bg_normal)),
	 * 30, fir_end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE); spanStr.setSpan( new
	 * ForegroundColorSpan(getResources().getColor( R.color.topbar_bg_normal)),
	 * sec_bef, sen_end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE); return spanStr; }
	 */

	/**
	 * 设置认证状态文本
	 */
	private void setAuthStatus() {
		/*
		 * if (mAuthStatus.getState() ==
		 * CertificationStatus.CERTIFICATION_INITIALIZE ||
		 * mAuthStatus.getState() ==
		 * CertificationStatus.CERTIFICATION_NOT_PASS){ isCardEnabled(true);
		 * mButtonApply.setVisibility(View.VISIBLE);
		 * if(!mUIAuthLogic.isAllImgReady())mButtonApply.setEnabled(false);
		 * }else { isCardEnabled(false); mButtonApply.setEnabled(false);
		 * //mTextStatus.setVisibility(View.VISIBLE); }
		 * if(mAuthStatus.getState() ==
		 * CertificationStatus.CERTIFICATION_INITIALIZE){ isCardEnabled(true); }
		 */

		// TODO ==YY==当前的流程是任何情况都可修改认证图片，所以上方的以前的流程注销掉
		if (mAuthStatus.getState() == CertificationStatus.CERTIFICATION_INITIALIZE
				|| mAuthStatus.getState() == CertificationStatus.CERTIFICATION_NOT_PASS) {
			// mPicCertification.setSelected(true);
			// mPicCardZheng.setSelected(true);
			// mPicCardFan.setSelected(true);
		} else {
			// mPicCertification.setSelected(false);
			// mPicCardZheng.setSelected(false);
			// mPicCardFan.setSelected(false);
		}
	}

	/**
	 * 更新照片说明，如果有了照片则无需再显示
	 */
	/*
	 * private void updatePhotoLabels() { ArrayList<AuthImage> imgs =
	 * mCertificationStatus.getImgs(); for(int i = 0; i < imgs.size(); i++){
	 * AuthImage img = imgs.get(i); String path = ""; if(img.hayImage !=
	 * null)path = img.hayImage.getUri(); View view = null; switch
	 * (img.certType) { case AuthImage.CERTYPE_DOCTOR: view =
	 * findViewById(R.id.iv_certificate_label); break; case
	 * AuthImage.CERTYPE_CARD_Z: view = findViewById(R.id.tv_label_card_zheng);
	 * break; case AuthImage.CERTYPE_CARD_F: view =
	 * findViewById(R.id.tv_label_card_fan); break; } if(!"".equals(path) &&
	 * view != null)view.setVisibility(View.GONE); } }
	 */

	/**
	 * 设置Activity界面可编辑
	 */
	private void isCardEnabled(boolean isb) {
		findViewById(R.id.fl_certificate).setEnabled(isb);
		findViewById(R.id.fl_card_zheng).setEnabled(isb);
		findViewById(R.id.fl_card_fan).setEnabled(isb);
		mPicCertification.setEnabled(isb);
		mPicCardZheng.setEnabled(isb);
		mPicCardFan.setEnabled(isb);
	}

	private void selectPic(final int mode) {
		mPicMode = mode;
		showSelectPicView();
		/*
		 * final CustomDialog dialog = new
		 * CustomDialog(CertificationActivity.this);
		 * dialog.setMessage("请选择获取图片方式");
		 * dialog.setNegativeButton(R.string.select_pic_cramer, new
		 * OnClickListener() {
		 * 
		 * @Override public void onClick(View arg0) { // 从相机获取 status = 1;
		 * Intent intent = new Intent( "android.media.action.IMAGE_CAPTURE");
		 * switch (mode) { case CERTIFICATE_IMAGE:
		 * startActivityForResult(intent, CERTIFICATE_IMAGE); break; case
		 * CARD_ZHENG_IMAGE: startActivityForResult(intent, CARD_ZHENG_IMAGE);
		 * break; case CARD_FAN_IMAGE: startActivityForResult(intent,
		 * CARD_FAN_IMAGE); break; default: break; } dialog.dismiss(); } });
		 * dialog.setPositiveListener(R.string.select_pic_album, new
		 * OnClickListener() {
		 * 
		 * @Override public void onClick(View arg0) { // 选择本地相册 status = 2;
		 * Intent intent = new Intent( Intent.ACTION_PICK,
		 * android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
		 * intent.setType("image/*"); switch (mode) { case CERTIFICATE_IMAGE:
		 * startActivityForResult(intent, CERTIFICATE_IMAGE); break; case
		 * CARD_ZHENG_IMAGE: startActivityForResult(intent, CARD_ZHENG_IMAGE);
		 * break; case CARD_FAN_IMAGE: startActivityForResult(intent,
		 * CARD_FAN_IMAGE); break; default: break; } dialog.dismiss(); } });
		 */
	}

	public static byte[] readStream(InputStream inStream) throws Exception {
		byte[] buffer = new byte[1024];
		int len = -1;
		ByteArrayOutputStream outStream = new ByteArrayOutputStream();
		while ((len = inStream.read(buffer)) != -1) {
			outStream.write(buffer, 0, len);
		}
		byte[] data = outStream.toByteArray();
		outStream.close();
		inStream.close();
		return data;

	}

	public static Bitmap getPicFromBytes(byte[] bytes) {
		if (bytes != null) {
			// 缩放图片, width, height 按相同比例缩放图片
			BitmapFactory.Options options = new BitmapFactory.Options();
			// options 设为true时，构造出的bitmap没有图片，只有一些长宽等配置信息，但比较快，设为false时，才有图片
			options.inJustDecodeBounds = true;
			Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0,
					bytes.length, options);
			int scale = (int) (options.outWidth / (float) 150);
			if (scale <= 0)
				scale = 1;
			options.inSampleSize = scale;
			options.inJustDecodeBounds = false;
			bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length,
					options);
			return bitmap;
		}
		return null;
	}

	@Override
	public void onFileLost() {
		if (mDialog != null)
			mDialog.dismiss();
		UITools.showToast("文件丢失");
	}

	@Override
	public void onAuthFail(final int code, final String msg) {
		if (mDialog != null)
			mDialog.dismiss();
		mDialog = null;
		// mAuthStatus.setState(CertificationStatus.CERTIFICATION_NOT_PASS);
		runOnUiThread(new Runnable() {
			public void run() {
				setAuthStatus();
				if (code > 0) {
					UITools.showToast(msg);
				}
			}
		});
	}

	@Override
	public void onAuthSuccess() {
		if (mDialog != null)
			mDialog.dismiss();
		mDialog = null;
		// FileSystem.getInstance().saveEntity(mAuthStatus);
		CertificationStatus.initCertification();
		runOnUiThread(new Runnable() {
			public void run() {
//				mUIAuthLogic.dataClear();
				setAuthStatus();
				UITools.showToast("上传成功，等待认证");
				mButtonApply.setEnabled(false);
				mPicCertification.setEnabled(false);
			}
		});
	}

	@Override
	public void onBackPressed() {
		if (mDialog != null) {
			mDialog.dismiss();
			mDialog = null;
		} else {
			super.onBackPressed();
		}
	}
}
