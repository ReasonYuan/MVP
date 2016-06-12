package com.hp.android.halcyon;

import java.io.IOException;
import java.util.Vector;

import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.net.Uri;
import android.os.Handler;
import android.os.Vibrator;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Toast;

import com.fq.android.plus.R;
import com.fq.lib.tools.UriConstants;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.Result;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomDialog;
import com.hp.android.halcyon.zxing.CameraManager;
import com.hp.android.halcyon.zxing.CaptureActivityHandler;
import com.hp.android.halcyon.zxing.InactivityTimer;
import com.hp.android.halcyon.zxing.ViewfinderView;
import com.hp.android.halcyon.zxing.ZxingTools;

/**
 * Initial the camera
 * 
 * @author Ryan.Tang
 */
public class ZxingScanActivity extends BaseActivity implements Callback {

	public static final int REQUEST_CODE_SELECTPHOTO = 998;

	public static final String SCAN_MODES = "SCAN_MODES";

	private CaptureActivityHandler handler;
	private ViewfinderView viewfinderView;
	private boolean hasSurface;
	private Vector<BarcodeFormat> decodeFormats;
	private String characterSet;
	private InactivityTimer inactivityTimer;
	private MediaPlayer mediaPlayer;
	private boolean playBeep;
	private static final float BEEP_VOLUME = 0.10f;
	private boolean vibrate;

	@Override
	public int getContentId() {
		return R.layout.activity_zxing_scan;
	}

	@Override
	public void init() {
		setTitle("二维码");
		setContainerTop();
		findViewById(R.id.v_title_topbar_view).setVisibility(View.VISIBLE);
		CameraManager.init(getApplication());
		viewfinderView = (ViewfinderView) findViewById(R.id.viewfinder_view);
		// DecodeHandler.imageView = (ImageView) findViewById(R.id.imaage);
		hasSurface = false;
		inactivityTimer = new InactivityTimer(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
		SurfaceView surfaceView = (SurfaceView) findViewById(R.id.preview_view);
		CameraManager.mPreview = surfaceView;
		SurfaceHolder surfaceHolder = surfaceView.getHolder();
		if (hasSurface) {
			initCamera(surfaceHolder);
		} else {
			surfaceHolder.addCallback(this);
			surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
		}
		decodeFormats = null;
		characterSet = null;

		playBeep = true;
		AudioManager audioService = (AudioManager) getSystemService(AUDIO_SERVICE);
		if (audioService.getRingerMode() != AudioManager.RINGER_MODE_NORMAL) {
			playBeep = false;
		}
		initBeepSound();
		vibrate = true;

		// DisplayMetrics dm = new DisplayMetrics();
		// getWindowManager().getDefaultDisplay().getMetrics(dm);
		// int width = dm.widthPixels*2/4;
		// if (width < 160) {
		// width = 160;
		// } else if (width > 427) {
		// width = 427;
		// }
		// findViewById(R.id.btn_zxing_scan_alum).getLayoutParams().width =
		// width;
		// findViewById(R.id.view_zxing_scan_alum).getLayoutParams().width =
		// width;
	}

	@Override
	protected void onPause() {
		super.onPause();
		if (handler != null) {
			handler.quitSynchronously();
			handler = null;
		}
		CameraManager.get().closeDriver();
	}

	@Override
	protected void onDestroy() {
		CameraManager.mPreview = null;
		inactivityTimer.shutdown();
		super.onDestroy();
	}

	public void restartPreviewAfterDelay(long delayMS) {
		if (handler != null) {
			handler.sendEmptyMessageDelayed(R.id.restart_preview, delayMS);
		}
	}

	/**
	 * ����ɨ����
	 * 
	 * @param result
	 * @param barcode
	 */
	public void handleDecode(Result result, Bitmap barcode) {
		inactivityTimer.onActivity();
		playBeepSoundAndVibrate();
		String resultString = result.getText();
		if (resultString.equals("")) {
			Toast.makeText(this, "扫描失败!", Toast.LENGTH_SHORT).show();
		} else {
			// Intent intent = new Intent(this, ZxingResultActivity.class);
			// intent.putExtra("result", resultString);
			// intent.putExtra("bitmap", barcode);
			// startActivity(intent);
			doScanResult(resultString);
		}
	}

	private void initCamera(SurfaceHolder surfaceHolder) {
		try {
			CameraManager.get().openDriver(surfaceHolder);
		} catch (IOException ioe) {
			return;
		} catch (RuntimeException e) {
			return;
		}
		if (handler == null) {
			handler = new CaptureActivityHandler(this, decodeFormats,
					characterSet);
		}
	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {

	}

	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		if (!hasSurface) {
			hasSurface = true;
			initCamera(holder);
		}

	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		hasSurface = false;

	}

	public ViewfinderView getViewfinderView() {
		return viewfinderView;
	}

	public Handler getHandler() {
		return handler;
	}

	public void drawViewfinder() {
		viewfinderView.drawViewfinder();
	}

	private void initBeepSound() {
		if (playBeep && mediaPlayer == null) {
			// The volume on STREAM_SYSTEM is not adjustable, and users found it
			// too loud,
			// so we now play on the music stream.
			setVolumeControlStream(AudioManager.STREAM_MUSIC);
			mediaPlayer = new MediaPlayer();
			mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
			mediaPlayer.setOnCompletionListener(beepListener);

			AssetFileDescriptor file = getResources().openRawResourceFd(
					R.raw.beep);
			try {
				mediaPlayer.setDataSource(file.getFileDescriptor(),
						file.getStartOffset(), file.getLength());
				file.close();
				mediaPlayer.setVolume(BEEP_VOLUME, BEEP_VOLUME);
				mediaPlayer.prepare();
			} catch (IOException e) {
				mediaPlayer = null;
			}
		}
	}

	private static final long VIBRATE_DURATION = 200L;

	private void playBeepSoundAndVibrate() {
		if (playBeep && mediaPlayer != null) {
			mediaPlayer.start();
		}
		if (vibrate) {
			Vibrator vibrator = (Vibrator) getSystemService(VIBRATOR_SERVICE);
			vibrator.vibrate(VIBRATE_DURATION);
		}
	}

	/**
	 * When the beep has finished playing, rewind to queue up another one.
	 */
	private final OnCompletionListener beepListener = new OnCompletionListener() {
		public void onCompletion(MediaPlayer mediaPlayer) {
			mediaPlayer.seekTo(0);
		}
	};

	public void onToAlbumClick(View v) {
		Intent intent = new Intent(this, SelectPhotoBucketListActivity.class);
		intent.putExtra("is_single_slection", true);
		startActivityForResult(intent, REQUEST_CODE_SELECTPHOTO);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == REQUEST_CODE_SELECTPHOTO
				&& resultCode == SelectPhotoActivity.TO_ALBUM_RESULT) {
			String name = data
					.getStringExtra(SelectPhotoActivity.EXTRA_PHOTO_NAMES);
			if (name != null && !"".equals(name)) {
				// Bitmap bmp = BitmapManager.decodeSampledBitmapFromFile(name,
				// 1);
				// doScanResult(ZxingTools.scanningImage(bmp));
				Bitmap bmp = null;
				BitmapFactory.Options opt = new BitmapFactory.Options();
				opt.inSampleSize = 1;
				opt.inJustDecodeBounds = true;
				BitmapFactory.decodeFile(name, opt);
				int bitmapSize = opt.outHeight * opt.outWidth * 2;
				opt.inSampleSize = bitmapSize / (1000 * 2000);
				opt.inJustDecodeBounds = false;
				bmp = BitmapFactory.decodeFile(name, opt);
				doScanResult(ZxingTools.scanBitmap(bmp));
			} else {
				doScanResult("");
			}
		}
	}

	private void doScanResult(final String result) {
		if ("".equals(result)) {
			UITools.showToast("不是有效的二维码");
			restartPreviewAfterDelay(0);
		} else {
			if (result.startsWith(UriConstants.getInvitationURL())) {
				String params = result.substring(result.indexOf("?"));
				String url = UriConstants.getUserURL() + params;
				Intent intent = new Intent(this, UserInfoActivity.class);
				intent.putExtra("scan_url", url);
				startActivity(intent);
				finish();
			} else {
				if (!result.startsWith("http://")
						&& !result.startsWith("https://")) {
					UITools.showToast(result);
					restartPreviewAfterDelay(0);
					return;
				}
				final CustomDialog dialog = new CustomDialog(this);
				dialog.setMessage("打开：" + result + "?");// 提示：收藏的文件不会被清除
				dialog.setNegativeButton(R.string.btn_cancel,
					new OnClickListener() {
						public void onClick(View arg0) {
							dialog.dismiss();
							restartPreviewAfterDelay(0);
						}
					});
				dialog.setPositiveListener(R.string.btn_sure_ren,
					new OnClickListener() {
						public void onClick(View arg0) {
							dialog.dismiss();
							Intent it = new Intent(Intent.ACTION_VIEW, Uri
									.parse(result));
							startActivity(it);
							restartPreviewAfterDelay(0);
						}
					});
			}
		}
	}
}