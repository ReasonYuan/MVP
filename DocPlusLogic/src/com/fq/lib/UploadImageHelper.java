package com.fq.lib;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.lib.tools.UriConstants;

/**
 * 上传图片到服务器工具类
 * @author reason
 */
public class UploadImageHelper {
	/**
	 * 上传图片，需要服务器对图片进行OCR识别
	 * @param path 图片路径
	 * @param handle 图片回调
	 */
	public static void upLoadImg(String path,HalcyonHttpResponseHandle handle){
		HttpHelper.upLoadImage(UriConstants.Conn.URL_PUB+"/pub/upload_images.do", path,true,handle);
	}
	
	/**
	 * 上传图片，不需要服务器对图片进行OCR识别
	 * @param path 图片路径
	 * @param handle 图片回调
	 */
	public static void upLoadImgUnOCR(String path,HalcyonHttpResponseHandle handle){
		HttpHelper.upLoadImage(UriConstants.Conn.URL_PUB+"/pub/upload_images.do", path,false,handle);
	}
}
