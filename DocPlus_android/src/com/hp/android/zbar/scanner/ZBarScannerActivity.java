package com.hp.android.zbar.scanner;

import net.sourceforge.zbar.Config;
import net.sourceforge.zbar.Image;
import net.sourceforge.zbar.ImageScanner;
import net.sourceforge.zbar.Symbol;
import net.sourceforge.zbar.SymbolSet;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.hardware.Camera;
import android.net.Uri;
import android.text.TextUtils;
import android.view.View;

import com.fq.android.plus.R;
import com.fq.lib.tools.UriConstants;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.SelectPhotoActivity;
import com.hp.android.halcyon.SelectPhotoBucketListActivity;
import com.hp.android.halcyon.UserInfoActivity;
import com.hp.android.halcyon.util.BitmapManager;
import com.hp.android.halcyon.util.UITools;

public class ZBarScannerActivity extends BaseActivity implements Camera.PreviewCallback, ZBarConstants {
	
	public static final int REQUEST_CODE_SELECTPHOTO = 998;
	
    protected static final String TAG = "ZBarScannerActivity";
    private CameraPreview mPreview;
    private ImageScanner mScanner;

    static {
        System.loadLibrary("iconv");
    }

    @Override
    public int getContentId() {
    	return R.layout.activity_zxing_scan;
    }
    
    @Override
    public void init() {
    	setTitle("二维码");
        if(!isCameraAvailable()) {
            cancelRequest();
            return;
        }
        //requestWindowFeature(Window.FEATURE_NO_TITLE);
        //getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        
        setupScanner();

        //setContentView(R.layout.activity_zxing_scan);
        mPreview = (CameraPreview) findViewById(R.id.preview_view);
        mPreview.setPreviewCallback(this);
    }

    public void setupScanner() {
        mScanner = new ImageScanner();
        mScanner.setConfig(0, Config.X_DENSITY, 3);
        mScanner.setConfig(0, Config.Y_DENSITY, 3);

        int[] symbols = getIntent().getIntArrayExtra(SCAN_MODES);
        if (symbols != null) {
            mScanner.setConfig(Symbol.NONE, Config.ENABLE, 0);
            for (int symbol : symbols) {
                mScanner.setConfig(symbol, Config.ENABLE, 1);
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (!mPreview.onResume()) {
        	cancelRequest();
		}
    }

    @Override
    protected void onPause() {
        super.onPause();
        mPreview.onPause();
    }

    public boolean isCameraAvailable() {
        PackageManager pm = getPackageManager();
        return pm.hasSystemFeature(PackageManager.FEATURE_CAMERA);
    }

    public void cancelRequest() {
        Intent dataIntent = new Intent();
        dataIntent.putExtra(ERROR_INFO, "Camera unavailable");
        setResult(Activity.RESULT_CANCELED, dataIntent);
        finish();
    }

    public void onPreviewFrame(byte[] data, Camera camera) {
        Camera.Parameters parameters = camera.getParameters();
        Camera.Size size = parameters.getPreviewSize();

        Image barcode = new Image(size.width, size.height, "Y800");
        barcode.setData(data);
        
        int result = mScanner.scanImage(barcode);

        if (result != 0) {
        	mPreview.onPause();
            SymbolSet syms = mScanner.getResults();
            for (Symbol sym : syms) {
                String symData = sym.getData();
                if (!TextUtils.isEmpty(symData)) {
//                    Intent dataIntent = new Intent();
//                    dataIntent.putExtra(SCAN_RESULT, symData);
//                    dataIntent.putExtra(SCAN_RESULT_TYPE, sym.getType());
//                    setResult(Activity.RESULT_OK, dataIntent);
//                    finish();
                	doScanResult(symData);
                    break;
                }
            }
        }
    }
    
    public void onToAlbumClick(View v){
		Intent intent = new Intent(this,SelectPhotoBucketListActivity.class);
		intent.putExtra("is_single_slection", true);
		startActivityForResult(intent, REQUEST_CODE_SELECTPHOTO);
	}
    
    @Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(requestCode == REQUEST_CODE_SELECTPHOTO && resultCode == SelectPhotoActivity.TO_ALBUM_RESULT){
			String name = data.getStringExtra(SelectPhotoActivity.EXTRA_PHOTO_NAMES);
			if(name != null && !"".equals(name)){
				Bitmap bmp = BitmapManager.decodeSampledBitmapFromFile(name, 1);
				doScanResult(scanBitmap(bmp, mScanner));//ZxingTools.scanningImage(bmp)
			}else{
				doScanResult("");
			}
		}
	}
    
    public static String scanBitmap(Bitmap bitmap, ImageScanner scanner){
    	int width = bitmap.getWidth();
    	int height = bitmap.getHeight();
    	int[] pixels = new int[width*height];
    	bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
    	Image barcode = new Image(width, height, "RGB4");
    	barcode.setData(pixels);
    	int result = scanner.scanImage(barcode.convert("Y800"));
    	if(result !=0){
    		 SymbolSet syms = scanner.getResults();
    		 for (Symbol sym : syms) {
                 String symData = sym.getData();
                 if (!TextUtils.isEmpty(symData)) {
                	 return symData;
                 }
             }
    	}
    	return "";
    }

    private void doScanResult(final String result){
		if("".equals(result)){
			UITools.showToast("不是有效的二维码");
		}else{
			if(result.startsWith(UriConstants.getInvitationURL())){
				result.replace(UriConstants.getInvitationURL(), UriConstants.getUserURL());
				Intent intent = new Intent(this, UserInfoActivity.class);
				intent.putExtra("scan_url", result);
				startActivity(intent);
				finish();
			}else{
				if(!result.startsWith("http://")&&!result.startsWith("https://")){
					UITools.showToast(result);
					return;
				}
				new AlertDialog.Builder(this)
				.setMessage("打开："+result+"?")
				.setPositiveButton("确定", new OnClickListener() {
					public void onClick(DialogInterface dialog, int which) {
						dialog.dismiss();
						Intent it = new Intent(Intent.ACTION_VIEW, Uri.parse(result));  
				        startActivity(it);  
					}
				})
				.setNegativeButton("取消", new OnClickListener() {
					public void onClick(DialogInterface dialog, int which) {
						dialog.dismiss();
					}
				}).show();
			}
		}
	}
}
