package com.hp.android.halcyon;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.record.SnapPhotoManager;
import com.hp.android.halcyon.util.BitmapManager;
import com.hp.android.halcyon.util.UITools;

public class PreviewPhotoActivity extends Activity {
	

	/**重新拍摄*/
	public static final int RESULT_CODE_RETAKE = 1;
	
	/**使用所拍照片*/
	public static final int RESULT_CODE_APPLY = 2;
	
	public static final int MAX_PHOTO_WIDTH = 600; //in pixel

	private ImageView imgPhoto;
	private TextView btnApplyPhoto;
	private TextView btnRetakePotho;

	private Bitmap mSelectBmp;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_preview_photo);
		btnApplyPhoto = (TextView) findViewById(R.id.btn_preview_photo_apply);
		btnRetakePotho = (TextView) findViewById(R.id.btn_preview_photo_retake);
		imgPhoto = (ImageView) findViewById(R.id.img_preview_photo);

		btnApplyPhoto.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				// 使用照片
				if(mSelectBmp == null){
					setResult(RESULT_CODE_RETAKE);
					imgPhoto.setImageURI(null);
					finish();
					return;
				}
				
				//如果选择使用图片，则需要将该图片保存到本地并通知系统扫描文件
				final String name = System.currentTimeMillis()+FileSystem.RED_IMG_FT;
				final String fileName = FileSystem.getInstance().getRecordImgPath() + name;
				BitmapManager.saveToLocal(mSelectBmp, FileSystem.getInstance().getRecordImgPath(), name);
				UITools.scanFile(fileName);
				
				Intent data = new Intent();
				data.putExtra(SnapPicActivity.EXTRA_PREVIEW_PHOTO_NAMES, fileName);
				setResult(RESULT_CODE_APPLY, data);
				imgPhoto.setImageURI(null);
				finish();
				
				mSelectBmp.recycle();
				mSelectBmp = null;
			}
		});

		btnRetakePotho.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				// 重新拍摄
				setResult(RESULT_CODE_RETAKE);
				imgPhoto.setImageURI(null);
				finish();
				
				mSelectBmp.recycle();
				mSelectBmp = null;
			}
		});

		//拍摄的图片缓存在 SnapPhotoManager 里面，得到后就需要置为空
		SnapPhotoManager snap = SnapPhotoManager.getInstance();
		mSelectBmp = (Bitmap) snap.getTakePhoto();
		if(mSelectBmp != null){
			imgPhoto.setImageBitmap(mSelectBmp);
			snap.setTakePhoto(null);
		}
	}
}
