package com.hp.android.halcyon.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.ColorMatrix;
import android.graphics.ColorMatrixColorFilter;
import android.graphics.Paint;

import com.fq.lib.HttpHelper;
import com.fq.lib.callback.ICallback;
import com.hp.android.halcyon.HalcyonApplication;

public class BitmapManager {

	public static final int MAX_PHOTO_WIDTH = 600; //in pixel
	
	public static void getBitmap(String url,String path,ICallback callback){
		Bitmap mBitmap = readImage(url,path);
		if(mBitmap != null) {
			callback.doCallback(mBitmap);
			return;
		}
		downLoadImage(url,path,callback);
	}
	
	public static void downLoadImage(final String url,final String path,final ICallback callback){
		File mFile = new File(getImageName(url,path));
		if(!mFile.exists()){
			HttpHelper.sendGetRequestImage(url, path, new ICallback() {
				
				@Override
				public void doCallback(Object obj) {
					Bitmap mBitmap = readImage(url,path);
					callback.doCallback(mBitmap);
				}
			});
		}
	}
	
	public static Bitmap readImage(String url,String path){
		Bitmap mBitmap = null;
		try {
			FileInputStream mFileInputStream = new FileInputStream(getImageName(url,path));
			mBitmap = BitmapFactory.decodeStream(mFileInputStream);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		return mBitmap;
	}
	

	public static String getImageName(String url,String path){
		String mPathPhoto = FileManager.getInstance().getBackupPhotoPath("");
		int indexEnd = url.lastIndexOf('?');
		int indexStart = url.lastIndexOf('/')+1;
		String mImageName = url.substring(indexStart, indexEnd);
		return mPathPhoto+"/"+mImageName;
	}
	
	public static Bitmap decodeSampledBitmapFromFile(String path, int size)
	{
	    final BitmapFactory.Options options = new BitmapFactory.Options();
	    options.inJustDecodeBounds = true;
	    BitmapFactory.decodeFile(path, options);
	    options.inPreferredConfig = Bitmap.Config.RGB_565;
	    options.inSampleSize = size;
	    options.inJustDecodeBounds = false;
	    try {
	    	return BitmapFactory.decodeFile(path, options);
		} catch (java.lang.OutOfMemoryError e) {
			//递归每次x2,保证能装在图片
			return decodeSampledBitmapFromFile(path, size*2);
		}
	}
	
	public static Bitmap decodeSampledBitmapFromFile(int resId)
	{
	    return BitmapFactory.decodeResource(HalcyonApplication.getAppContext().getResources(), resId);
	}
	
	public static Bitmap decodeSampledBitmapFromFile(int resId, int size)
	{
	    final BitmapFactory.Options options = new BitmapFactory.Options();
	    options.inJustDecodeBounds = true;
	    BitmapFactory.decodeResource(HalcyonApplication.getAppContext().getResources(), resId, options);
	    options.inPreferredConfig = Bitmap.Config.RGB_565;
	    options.inSampleSize = size;
	    options.inJustDecodeBounds = false;
	    try {
	    	return BitmapFactory.decodeResource(HalcyonApplication.getAppContext().getResources(), resId, options);
		} catch (java.lang.OutOfMemoryError e) {
			//递归每次x2,保证能装在图片
			return decodeSampledBitmapFromFile(resId, size*2);
		}
	}
	
	/**
	 * @return 等比例缩放后的图片
	 */
	public static Bitmap decodeBitmap2Scale(String path){
		//如果图片太大，缩放图片
		int[] wh = getImageWH(path);
		if (wh[0] != -1 && wh[1] != -1) {
			int width = wh[0] < wh[1] ? wh[0] : wh[1];
			//int height = wh[0] > wh[1] ? wh[0] : wh[1];
			int scale = 1;
			if (width > MAX_PHOTO_WIDTH) {
				//需要缩放
				scale = width/MAX_PHOTO_WIDTH;
				if(scale%2!=0)scale++;
			}
			BitmapFactory.Options options = new BitmapFactory.Options();
			options.inScaled = true;
			options.inSampleSize = scale;
			options.inPreferredConfig = Bitmap.Config.ARGB_8888;
			Bitmap bitmap = BitmapFactory.decodeFile(path, options);
			return bitmap;
		}
		return null;
	}
	
	/**
	 * @return 等比例缩放后的图片 定为小于widthSacle的才缩放
	 */
	public static Bitmap decodeBitmap2ScaleForTakePic(String path,int widthSacle){
		//如果图片太大，缩放图片
		int[] wh = getImageWH(path);
		if (wh[0] != -1 && wh[1] != -1) {
			int width = wh[0] < wh[1] ? wh[0] : wh[1];
			//int height = wh[0] > wh[1] ? wh[0] : wh[1];
			int scale = 1;
			if (width > widthSacle) {
				//需要缩放
				scale = width/widthSacle;
				if(scale%2!=0)scale++;
			}
			BitmapFactory.Options options = new BitmapFactory.Options();
			options.inScaled = true;
			options.inSampleSize = scale;
			options.inPreferredConfig = Bitmap.Config.ARGB_8888;
			Bitmap bitmap = BitmapFactory.decodeFile(path, options);
			return bitmap;
		}
		return null;
	}
	
	/**
	 * 图片宽度大于某个值时，固定缩放到600
	 * @param path
	 * @param size 
	 * @return
	 */
	public static Bitmap decodeBitmap2Scale(String path,int size){
		Bitmap mTmpBitmap = null;
		//如果图片太大，缩放图片
		int[] wh = getImageWH(path);
		if (wh[0] != -1 && wh[1] != -1) {
			int width = wh[0] < wh[1] ? wh[0] : wh[1];
			//int height = wh[0] > wh[1] ? wh[0] : wh[1];
			int scale = 1;
			if (width > size) {
				//需要缩放
				scale = width/MAX_PHOTO_WIDTH;
				if(scale%2!=0)scale++;
			}
			BitmapFactory.Options options = new BitmapFactory.Options();
			options.inScaled = true;
			options.inSampleSize = scale;
			options.inPreferredConfig = Bitmap.Config.ARGB_8888;
			Bitmap bitmap = BitmapFactory.decodeFile(path, options);
			
			mTmpBitmap = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(), Config.ARGB_8888);	
			ColorMatrix matrix = new ColorMatrix();
			//设置饱和度
			matrix.setSaturation(0.8f);
			// 设置亮度 和 对比度为最高   第 5、10、15 填20的表示亮度   第 1、7、13位表示对比度
			matrix.set(new float[] { 1, 0, 0, 0, 15, 0, 1,  
                     0, 0, 15, 
                     0, 0, 1, 0, 15, 0, 0, 0, 1, 0 });  
			Paint mPaint = new Paint();
			mPaint.setColorFilter(new ColorMatrixColorFilter(matrix));
			Canvas mCanvas = new Canvas(mTmpBitmap);
			mCanvas.drawBitmap(bitmap, 0, 0, mPaint);
			
			return mTmpBitmap;
		}
		return mTmpBitmap;
	}
	
	/**
	 * 图片宽度大于某个值时，固定缩放到需要的宽度
	 * @param path
	 * @param imageWidth
	 * @param size
	 * @return
	 */
	public static Bitmap decodeBitmap2ScaleTo(String path,int imageWidth){
		//如果图片太大，缩放图片
		if(imageWidth == 0) imageWidth = 300;
		int[] wh = getImageWH(path);
		if (wh[0] != -1 && wh[1] != -1) {
			int width = wh[0] < wh[1] ? wh[0] : wh[1];
			//int height = wh[0] > wh[1] ? wh[0] : wh[1];
			int scale = 1;
			if (width > imageWidth) {
				//需要缩放
				scale = width/imageWidth;
				if(scale%2!=0)scale++;
			}
			BitmapFactory.Options options = new BitmapFactory.Options();
			options.inScaled = true;
			options.inSampleSize = scale;
			options.inPreferredConfig = Bitmap.Config.RGB_565;
			Bitmap bitmap = BitmapFactory.decodeFile(path, options);
			return bitmap;
		}
		return null;
	}
	
	/** 获取图像的宽高 **/
	public static int[] getImageWH(String path) {
		int[] wh = { -1, -1 };
		if (path == null) {
			return wh;
		}
		File file = new File(path);
		if (file.exists() && !file.isDirectory()) {
			try {
				BitmapFactory.Options options = new BitmapFactory.Options();
				options.inJustDecodeBounds = true;
				InputStream is = new FileInputStream(path);
				BitmapFactory.decodeStream(is, null, options);
				wh[0] = options.outWidth;
				wh[1] = options.outHeight;
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return wh;
	}
	
	/**
	 * 图片设置成灰色
	 */
	public static Bitmap convertGreyImg(Bitmap img) {    
        int width = img.getWidth();         //获取位图的宽    
        int height = img.getHeight();       //获取位图的高    
            
        int []pixels = new int[width * height]; //通过位图的大小创建像素点数组    
            
        img.getPixels(pixels, 0, width, 0, 0, width, height);    
        int alpha = 0xFF << 24;     
        for(int i = 0; i < height; i++)  {    
            for(int j = 0; j < width; j++) {    
                int grey = pixels[width * i + j];    
                    
                int red = ((grey  & 0x00FF0000 ) >> 16);    
                int green = ((grey & 0x0000FF00) >> 8);    
                int blue = (grey & 0x000000FF);    
                    
                grey = (int)((float) red * 0.3 + (float)green * 0.59 + (float)blue * 0.11);    
                grey = alpha | (grey << 16) | (grey << 8) | grey;    
                pixels[width * i + j] = grey;    
            }    
        }    
        Bitmap result = Bitmap.createBitmap(width, height, Config.ARGB_8888); //RGB_565   ARGB_8888
        result.setPixels(pixels, 0, width, 0, 0, width, height);   
        return result;    
    }
	
	/** 
     * 根据原图和变长绘制圆形图片 
     *  
     * @param source 
     * @param min 
     * @return 
     */  
    /*private Bitmap createCircleImage(Bitmap source, int min){  
        final Paint paint = new Paint();  
        paint.setAntiAlias(true);  
        Bitmap target = Bitmap.createBitmap(min, min, Config.ARGB_8888);  
        *//** 
         * 产生一个同样大小的画布 
         *//*  
        Canvas canvas = new Canvas(target);  
        *//** 
         * 首先绘制圆形 
         *//*  
        canvas.drawCircle(min / 2, min / 2, min / 2, paint);  
        *//** 
         * 使用SRC_IN 
         *//*  
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));  
        *//** 
         * 绘制图片 
         *//*  
        canvas.drawBitmap(source, 0, 0, paint);  
        return target;  
    }*/
    
    
    /**
	 *将图片保存到本地 
	 *@param bm  需要保存的bitmap
	 *@param path 保存的目录
	 *@param name 保存的图片的名字
	 */
	public static String saveToLocal(Bitmap bm, String path, String name) {
		return saveToLocal(bm, path, name,false);
	}
	
	/**
	 *将图片保存到本地 
	 *@param bm  需要保存的bitmap
	 *@param path 保存的目录
	 *@param name 保存的图片的名字
	 *@param isBitmapRecycle 是否回收图片
	 */
	public static String saveToLocal(Bitmap bm, String path, String name,boolean isBitmapRecycle) {
		File filePath = new File(path);
		File imagePath = new File(path + "/" + name);
		if(!filePath.exists()){
			filePath.mkdirs();
		}
		if(!imagePath.exists()){
			try {
				imagePath.createNewFile();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		try {
			FileOutputStream fos = new FileOutputStream(imagePath);
			bm.compress(Bitmap.CompressFormat.JPEG, 90, fos);
			fos.flush();
			fos.close();
			if(isBitmapRecycle){
				bm.recycle();
				bm = null;
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return null;
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}

		return imagePath.toString();
	}
    
}
