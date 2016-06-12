package com.hp.android.halcyon.zxing;

import java.util.Hashtable;

import net.sourceforge.zbar.Config;
import net.sourceforge.zbar.Image;
import net.sourceforge.zbar.ImageScanner;
import net.sourceforge.zbar.Symbol;
import net.sourceforge.zbar.SymbolSet;
import android.app.Activity;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.text.TextUtils;

import com.fq.android.plus.R;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.ChecksumException;
import com.google.zxing.DecodeHintType;
import com.google.zxing.EncodeHintType;
import com.google.zxing.FormatException;
import com.google.zxing.NotFoundException;
import com.google.zxing.Result;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.QRCodeReader;
import com.google.zxing.qrcode.QRCodeWriter;
import com.hp.android.halcyon.util.UITools;

public class ZxingTools {
	// 图片宽度的一般
    private static int mImageWidth = 40;
 // 插入到二维码里面的图片对象
    private static Bitmap mBitmap;
    // 需要插图图片的大小 这里设定为40*40
    int[] pixels = new int[2*mImageWidth * 2*mImageWidth];
    
    public static void initMinBitmap(Activity mContext){
    	float scale = UITools.dip2px(1);
    	if (scale >= 3) {
    		mImageWidth = 55;//50
		}else if(scale < 3 && scale >=2){
			mImageWidth = 30;//25
		}else{
			mImageWidth = 20;//20
		}
    	// 构造需要插入的图片对象
    	Resources res= mContext.getResources();
    	mBitmap = BitmapFactory.decodeResource(res, R.drawable.icon_doctor_plus_twocode);
    	
        // 缩放图片
        Matrix m = new Matrix();
        float sx = (float) 2*mImageWidth / mBitmap.getWidth();
        float sy = (float) 2*mImageWidth / mBitmap.getHeight();
        m.setScale(sx, sy);
        // 重新构造一个40*40的图片
        mBitmap = Bitmap.createBitmap(mBitmap, 0, 0, mBitmap.getWidth(),
                mBitmap.getHeight(), m, false);
    }
    
	// 解析QR图片
    public static String scanningImage(Bitmap bitmap) {
        Hashtable<DecodeHintType, String> hints = new Hashtable<DecodeHintType, String>();
        hints.put(DecodeHintType.CHARACTER_SET, "utf-8");
        
        RGBLuminanceSource source = new RGBLuminanceSource(bitmap);
        BinaryBitmap bitmap1 = new BinaryBitmap(new HybridBinarizer(source));
        QRCodeReader reader = new QRCodeReader();
        Result result;
        try {
            result = reader.decode(bitmap1, hints);
            // 得到解析后的文字
            return result.getText();
        } catch (NotFoundException e) {
            e.printStackTrace();
        } catch (ChecksumException e) {
            e.printStackTrace();
        } catch (FormatException e) {
            e.printStackTrace();
        }
        return "";
    }
	
    public static String scanBitmap(Bitmap bitmap){
    	ImageScanner scanner = new ImageScanner();
		scanner.setConfig(0, Config.X_DENSITY, 3);
		scanner.setConfig(0, Config.Y_DENSITY, 3);
		
		/*int[] symbols = getIntent().getIntArrayExtra(SCAN_MODES);
        if (symbols != null) {
        	scanner.setConfig(Symbol.NONE, Config.ENABLE, 0);
            for (int symbol : symbols) {
            	scanner.setConfig(symbol, Config.ENABLE, 1);
            }
        }*/
    	
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
    
    
    public static Bitmap createQRImage(String url) {
    	return createQRImage(url,540,540);
	}
    
    public static Bitmap createQRImage(String url,int width,int height) {
		try {
			// 判断URL合法性
			if (url == null || "".equals(url) || url.length() < 1) {
				return null;
			}
			Hashtable<EncodeHintType, String> hints = new Hashtable<EncodeHintType, String>();
			hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
			// 图像数据转换，使用了矩阵转换
			BitMatrix bitMatrix = new QRCodeWriter().encode(url,
					BarcodeFormat.QR_CODE, width, height, hints);
			int[] pixels = new int[width * height];
			int halfW = width / 2;
		    int halfH = height / 2;
			// 下面这里按照二维码的算法，逐个生成二维码的图片，
			// 两个for循环是图片横列扫描的结果
			for (int y = 0; y < height; y++) {
				for (int x = 0; x < width; x++) {
//					if (bitMatrix.get(x, y)) {
////						pixels[y * width + x] = 0xff66BAA8;
//						pixels[y * width + x] = 0xff000000;
//					} else {
//						pixels[y * width + x] = 0x00ffffff;
//					}
					 if (x > halfW - mImageWidth && x < halfW + mImageWidth && y > halfH - mImageWidth
		                        && y < halfH + mImageWidth) {
		                    pixels[y * width + x] = mBitmap.getPixel(x - halfW + mImageWidth, y
		                            - halfH + mImageWidth);
		                }else {
		                	pixels[y * width + x] = bitMatrix.get(x, y)?0xff000000:0x00fffff;
					}
				}
			}
			// 生成二维码图片的格式，使用ARGB_8888
			Bitmap bitmap = Bitmap.createBitmap(width, height,
					Bitmap.Config.ARGB_8888);
			bitmap.setPixels(pixels, 0, width, 0, 0, width, height);
			// 显示到一个ImageView上面
			return bitmap;
		} catch (WriterException e) {
			e.printStackTrace();
		}
		return null;
	}
}
