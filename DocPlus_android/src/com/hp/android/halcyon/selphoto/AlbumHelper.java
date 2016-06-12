package com.hp.android.halcyon.selphoto;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.provider.MediaStore.Audio.Albums;
import android.provider.MediaStore.Images.Media;
import android.provider.MediaStore.Images.Thumbnails;
import android.util.Log;

import com.fq.lib.tools.Constants;

/**
 * 专辑帮助类
 * 
 * @author Administrator
 * 
 */
public class AlbumHelper {
	final String TAG = getClass().getSimpleName();
	Context context;
	ContentResolver cr;

	// 缩略图列表
	HashMap<String, String> thumbnailList = new HashMap<String, String>();
	// 专辑列表
	List<HashMap<String, String>> albumList = new ArrayList<HashMap<String, String>>();
	HashMap<String, ImageBucket> bucketList = new HashMap<String, ImageBucket>();

	private static AlbumHelper instance;

	private AlbumHelper() {
	}

	public static AlbumHelper getHelper() {
		if (instance == null) {
			instance = new AlbumHelper();
		}
		return instance;
	}

	public void clear() {
		instance = null;
	}

	/**
	 * 初始化
	 * 
	 * @param context
	 */
	public void init(Context context) {
		if (this.context == null) {
			this.context = context;
			cr = context.getContentResolver();
			// ==YY==感觉没必要每次都得到这个缩略图，所以就放在第一次
			getThumbnail();
		}
	}

	/**
	 * 得到缩略图
	 */
	private void getThumbnail() {
		String[] projection = { Thumbnails._ID, Thumbnails.IMAGE_ID,
				Thumbnails.DATA };
		Cursor cursor = cr.query(Thumbnails.EXTERNAL_CONTENT_URI, projection,
				null, null, null);
		getThumbnailColumnData(cursor);
	}

	/**
	 * 从数据库中得到缩略图
	 * 
	 * @param cur
	 */
	private void getThumbnailColumnData(Cursor cur) {
		if (cur.moveToFirst()) {
//			int _id;
			int image_id;
			String image_path;
//			int _idColumn = cur.getColumnIndex(Thumbnails._ID);
			int image_idColumn = cur.getColumnIndex(Thumbnails.IMAGE_ID);
			int dataColumn = cur.getColumnIndex(Thumbnails.DATA);

			do {
				// Get the field values
//				_id = cur.getInt(_idColumn);
				image_id = cur.getInt(image_idColumn);
				image_path = cur.getString(dataColumn);

				// Do something with the values.
				// Log.i(TAG, _id + " image_id:" + image_id + " path:"
				// + image_path + "---");
				// HashMap<String, String> hash = new HashMap<String, String>();
				// hash.put("image_id", image_id + "");
				// hash.put("path", image_path);
				// thumbnailList.add(hash);
				thumbnailList.put("" + image_id, image_path);
			} while (cur.moveToNext());
		}
	}

	/**
	 * 得到原图
	 */
	void getAlbum() {
		String[] projection = { Albums._ID, Albums.ALBUM, Albums.ALBUM_ART,
				Albums.ALBUM_KEY, Albums.ARTIST, Albums.NUMBER_OF_SONGS };
		Cursor cursor = cr.query(Albums.EXTERNAL_CONTENT_URI, projection, null,
				null, null);
		getAlbumColumnData(cursor);

	}

	/**
	 * 从本地数据库中得到原图
	 * 
	 * @param cur
	 */
	private void getAlbumColumnData(Cursor cur) {
		if (cur.moveToFirst()) {
			int _id;
			String album;
			String albumArt;
			String albumKey;
			String artist;
			int numOfSongs;

			int _idColumn = cur.getColumnIndex(Albums._ID);
			int albumColumn = cur.getColumnIndex(Albums.ALBUM);
			int albumArtColumn = cur.getColumnIndex(Albums.ALBUM_ART);
			int albumKeyColumn = cur.getColumnIndex(Albums.ALBUM_KEY);
			int artistColumn = cur.getColumnIndex(Albums.ARTIST);
			int numOfSongsColumn = cur.getColumnIndex(Albums.NUMBER_OF_SONGS);

			do {
				// Get the field values
				_id = cur.getInt(_idColumn);
				album = cur.getString(albumColumn);
				albumArt = cur.getString(albumArtColumn);
				albumKey = cur.getString(albumKeyColumn);
				artist = cur.getString(artistColumn);
				numOfSongs = cur.getInt(numOfSongsColumn);

				// Do something with the values.
				if (Constants.DEBUG) {
					Log.i(TAG, _id + " album:" + album + " albumArt:"
							+ albumArt + "albumKey: " + albumKey + " artist: "
							+ artist + " numOfSongs: " + numOfSongs + "---");
				}
				HashMap<String, String> hash = new HashMap<String, String>();
				hash.put("_id", _id + "");
				hash.put("album", album);
				hash.put("albumArt", albumArt);
				hash.put("albumKey", albumKey);
				hash.put("artist", artist);
				hash.put("numOfSongs", numOfSongs + "");
				albumList.add(hash);

			} while (cur.moveToNext());

		}
	}

	/**
	 * 是否创建了图片集
	 */
	boolean hasBuildImagesBucketList = false;

	/**
	 * 得到图片集
	 */
	void buildImagesBucketList() {
		buildImagesBucketList("Camera");
	}

	void buildImagesBucketList(String buckName) {
		String ZUIJING = "最近照片";
		long startTime = System.currentTimeMillis();
		// 构造缩略图索引
		getThumbnail();

		// 构造相册索引
		// 以前的内容太多，没必要
		// String columns[] = new String[] { Media._ID, Media.BUCKET_ID,
		// Media.PICASA_ID, Media.DATA, Media.DISPLAY_NAME, Media.TITLE,
		// Media.SIZE, Media.BUCKET_DISPLAY_NAME };
		String columns[] = new String[] { Media._ID, Media.BUCKET_ID,
				Media.DATA, Media.BUCKET_DISPLAY_NAME };

		// 查询条件
		String selection = null;
		if (buckName != null && !ZUIJING.equals(buckName)
				&& !"".equals(buckName)) {
			selection = Media.BUCKET_DISPLAY_NAME + "='" + buckName + "'";
		}

		// 得到一个游标
		Cursor cur = cr.query(Media.EXTERNAL_CONTENT_URI, columns, selection,
				null, Media.DATE_MODIFIED);

		if (cur.moveToFirst()) {
			// 获取指定列的索引
			// int photoNameIndex =
			// cur.getColumnIndexOrThrow(Media.DISPLAY_NAME);
			// int photoTitleIndex = cur.getColumnIndexOrThrow(Media.TITLE);
			// int photoSizeIndex = cur.getColumnIndexOrThrow(Media.SIZE);
			// int picasaIdIndex = cur.getColumnIndexOrThrow(Media.PICASA_ID);

			int photoIDIndex = cur.getColumnIndexOrThrow(Media._ID);
			int photoPathIndex = cur.getColumnIndexOrThrow(Media.DATA);
			int bucketNameIndex = cur
					.getColumnIndexOrThrow(Media.BUCKET_DISPLAY_NAME);
			int bucketIdIndex = cur.getColumnIndexOrThrow(Media.BUCKET_ID);

			// 获取图片总数
			// int totalNum = cur.getCount();

			do {
				// String name = cur.getString(photoNameIndex);
				// String title = cur.getString(photoTitleIndex);
				// String size = cur.getString(photoSizeIndex);
				// String picasaId = cur.getString(picasaIdIndex);
				String _id = cur.getString(photoIDIndex);
				String path = cur.getString(photoPathIndex);
				String bucketName = cur.getString(bucketNameIndex);
				String bucketId = cur.getString(bucketIdIndex);

				// Log.i(TAG, _id + ", bucketId: " + bucketId + ", picasaId: "
				// + picasaId + " name:" + name + " path:" + path
				// + " title: " + title + " size: " + size + " bucket: "
				// + bucketName + "---");

				ImageBucket bucket = bucketList.get(bucketId);
				if (bucket == null) {
					bucket = new ImageBucket();
					bucketList.put(bucketId, bucket);
					bucket.imageList = new ArrayList<ImageItem>();
					bucket.bucketName = bucketName;
				}
				bucket.count++;
				ImageItem imageItem = new ImageItem();
				imageItem.imageId = _id;
				imageItem.imagePath = path;
				imageItem.thumbnailPath = thumbnailList.get(_id);
				// TODO ==YY==先去掉缩略图或者图片为null的情况
				// if(path != null && imageItem.thumbnailPath != null)
				bucket.imageList.add(0, imageItem);

				// ==YY==增加功能：增加最近照片
			} while (cur.moveToNext());
		}

//		Iterator<Entry<String, ImageBucket>> itr = bucketList.entrySet()
//				.iterator();
//		while (itr.hasNext()) {
//			Map.Entry<String, ImageBucket> entry = (Map.Entry<String, ImageBucket>) itr
//					.next();
//			ImageBucket bucket = entry.getValue();
//			// Log.d(TAG, entry.getKey() + ", " + bucket.bucketName + ", "
//			// + bucket.count + " ---------- ");
//			for (int i = 0; i < bucket.imageList.size(); ++i) {
//				ImageItem image = bucket.imageList.get(i);
//				// Log.d(TAG, "----- " + image.imageId + ", " + image.imagePath
//				// + ", " + image.thumbnailPath);
//			}
//		}
		hasBuildImagesBucketList = true;
		long endTime = System.currentTimeMillis();
		if (Constants.DEBUG) {
			Log.d(TAG, "use time: " + (endTime - startTime) + " ms");
		}
	}

	/**
	 * 得到所有图片集
	 * 
	 * @param refresh
	 * @return
	 */
	public List<ImageBucket> getImagesBucketList(boolean refresh) {
		return getImagesBucketList(refresh, null);
	}

	/**
	 * 得到特定图片集
	 * 
	 * @param bucketName
	 *            查询特定bucket名称的图片集，为null则是所有
	 * @param refresh
	 * @return
	 */
	public List<ImageBucket> getImagesBucketList(boolean refresh,
			String bucketName) {
		if (refresh || (!refresh && !hasBuildImagesBucketList)) {
			bucketList.clear();// refresh设置为true后，发现相册里面数据有重复，所以添加了这句代码
			buildImagesBucketList(bucketName);
		}
		List<ImageBucket> tmpList = new ArrayList<ImageBucket>();
		Iterator<Entry<String, ImageBucket>> itr = bucketList.entrySet()
				.iterator();
		while (itr.hasNext()) {
			Map.Entry<String, ImageBucket> entry = (Map.Entry<String, ImageBucket>) itr
					.next();
			tmpList.add(entry.getValue());
		}
		return tmpList;
	}

	/**
	 * 得到原始图像路径
	 * 
	 * @param image_id
	 * @return
	 */
	String getOriginalImagePath(String image_id) {
		String path = null;
		// Log.i(TAG, "---(^o^)----" + image_id);
		String[] projection = { Media._ID, Media.DATA };
		Cursor cursor = cr.query(Media.EXTERNAL_CONTENT_URI, projection,
				Media._ID + "=" + image_id, null, null);
		if (cursor != null) {
			cursor.moveToFirst();
			path = cursor.getString(cursor.getColumnIndex(Media.DATA));

		}
		return path;
	}

	public ArrayList<ImageBucket> getAllImagesList() {
		long startTime = System.currentTimeMillis();
		// 构造缩略图索引,只初始化的时候加载
		// getThumbnail();

		// 构造相册索引
		String columns[] = new String[] { Media._ID, Media.DATA,
				Media.BUCKET_DISPLAY_NAME };

		// 得到一个游标
		Cursor cur = cr.query(Media.EXTERNAL_CONTENT_URI, columns, null, null,
				Media.DATE_MODIFIED);

		LinkedHashMap<String, ArrayList<ImageItem>> map = new LinkedHashMap<String, ArrayList<ImageItem>>();
		ArrayList<ImageItem> zuijin = new ArrayList<ImageItem>();

		if (cur.moveToFirst()) {
			// 获取指定列的索引
			int photoIDIndex = cur.getColumnIndexOrThrow(Media._ID);
			int photoPathIndex = cur.getColumnIndexOrThrow(Media.DATA);
			int bucketNameIndex = cur
					.getColumnIndexOrThrow(Media.BUCKET_DISPLAY_NAME);
			// int bucketIdIndex = cur.getColumnIndexOrThrow(Media.BUCKET_ID);

			int count = -1;
			do {
				count++;
				ImageItem imageItem = new ImageItem();
				imageItem.imageId = cur.getString(photoIDIndex);
				imageItem.imagePath = cur.getString(photoPathIndex);
				imageItem.thumbnailPath = thumbnailList.get(imageItem.imageId);
				// String bucketId = cur.getString(bucketIdIndex);
				if (imageItem.imagePath == null)
					continue;

				String bucketName = cur.getString(bucketNameIndex);
				ArrayList<ImageItem> item = map.get(bucketName);
				if (item == null) {
					item = new ArrayList<ImageItem>();
					map.put(bucketName, item);
				}
				item.add(0, imageItem);

				if (count < 100) {
					zuijin.add(0, imageItem);
				}
			} while (cur.moveToNext());
		}
		ArrayList<ImageBucket> buckets = new ArrayList<ImageBucket>();
		ImageBucket buck = new ImageBucket();
		buck.bucketName = "最近照片";
		buck.imageList = zuijin;
		buckets.add(buck);

		Iterator<String> itor = map.keySet().iterator();
		while (itor.hasNext()) {
			String name = itor.next();
			ImageBucket bk = new ImageBucket();
			bk.bucketName = name;
			bk.imageList = map.get(name);
			buckets.add(bk);
		}

		hasBuildImagesBucketList = true;
		long endTime = System.currentTimeMillis();
		if (Constants.DEBUG) {
			Log.d(TAG, "use time: " + (endTime - startTime) + " ms");
		}
		return buckets;
	}
}
