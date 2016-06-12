package com.fq.lib;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.DES3Utils;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.Data;
import com.fq.lib.tools.FQLog;

public class FileHelper {

	protected static final String TAG = "FileHelper";

	/**
	 * 删除所有文件夹
	 */
	public void deleteAllFolder(String path) {
		File file = new File(path);
		FileHelper.deleteFile(file, true);
	}

	/**
	 * 
	 * 删除文件或文件夹
	 * 
	 * @param isDelteFolder
	 *            文件夹时，删除文件夹还是清空文件夹，true表示删除整个，false表示只清空.
	 */
	public static boolean deleteFile(File file, boolean isDelteFolder) {
		if (file.exists()) {
			if (file.isFile()) {
				file.delete();
			} else if (file.isDirectory()) {
				File files[] = file.listFiles();
				for (int i = 0; i < files.length; i++) {
					deleteFile(files[i], true);
				}
				if (isDelteFolder) {
					file.delete();
				}
			}
		} else {
			return false;
		}
		return true;
	}

	/**
	 * 返回字节数
	 */
	public static long getFileSize(File file) {
		long size = 0;
		if (file.isDirectory()) {
			File[] files = file.listFiles();
			for (int i = 0; i < files.length; i++) {
				size += getFileSize(files[i]);
				;
			}
		} else {
			size = file.length();
		}
		return size;
	}

	public static void copyfile(File fromFile, File toFile, Boolean rewrite) {
		if (!fromFile.canRead()) {
			return;
		}
		if (!toFile.getParentFile().exists()) {
			toFile.getParentFile().mkdirs();
		}
		if (toFile.exists() && rewrite) {
			toFile.delete();
		}
		try {
			FileInputStream fosfrom = new java.io.FileInputStream(fromFile);
			FileOutputStream fosto = new FileOutputStream(toFile);
			byte bt[] = new byte[1024];
			int c;
			while ((c = fosfrom.read(bt)) > 0) {
				fosto.write(bt, 0, c); // 将内容写到新文件当中
			}
			fosfrom.close();
			fosto.close();
		} catch (Exception ex) {
			return;
		}
	}

	/**
	 * 保存文件
	 * 
	 * @param is
	 *            文件流
	 * @param path
	 *            文件路径
	 * @param name
	 *            文件名
	 * @return
	 */
	public static boolean saveFile(InputStream is, String path, String name) {
		byte[] bys = new byte[1024 * 10];
		File file = new File(path + "/" + name);
		if (!file.exists()) {
			try {
				file.createNewFile();
			} catch (IOException e) {
				FQLog.print(TAG, "create file " + name + " fail!");
				e.printStackTrace();
				return false;
			}
		}
		try {
			FileOutputStream fos = new FileOutputStream(file);
			int len = -1;
			while (-1 != (len = is.read(bys))) {
				fos.write(bys, 0, len);
			}
			fos.flush();
			fos.close();
			is.close();
			return true;
		} catch (Exception e) {
			FQLog.print(TAG, "saveFile error");
			e.printStackTrace();
		}

		return false;
	}

	/**
	 * 保存字符串到文件
	 * @param str		需要保存的字符串
	 * @param path		保存的路径
	 * @param encode	是否需要的字符串加密
	 * @return
	 */
	public static boolean saveFile(String str, String path, boolean encode) {
		try {
			String filePath = path.substring(0, path.lastIndexOf('/'));
			String fileName = path.substring(path.lastIndexOf('/') + 1);
			return saveFile(str, filePath, fileName, encode);
		} catch (Exception e) {
		}
		return false;
	}

	/**
	 * 保存字符串到文件
	 * @param str  		需要保存的字符串
	 * @param path		保存的路径
	 * @param name		保存的文件名
	 * @param encode	是否需要的字符串加密
	 * @return
	 */
	public static boolean saveFile(String str, String path, String name, boolean encode) {
		File file = new File(path + "/" + name);
		File pathFile = new File(path);
		if (!pathFile.exists()) {
			pathFile.mkdirs();
		}
		try {
			String source = str;
			if(encode){
				source = DES3Utils.encryptMode(str.toString().getBytes(), Constants.KEY_STRING);
			}
			FileOutputStream fos = new FileOutputStream(file);
			fos.write(source.getBytes());
			fos.flush();
			fos.close();
			return true;
		} catch (Exception e) {
			FQLog.print(TAG, "saveFile error");
			e.printStackTrace();
		}

		return false;
	}

	/**
	 * 从文件中读取字符串
	 * @param filePath  文件路径
	 * @param decode	是否需要解密
	 * @return
	 */
	public static String readString(String filePath, boolean decode) {
		/*
		 * try { String filePath = path.substring(0,path.lastIndexOf('/'));
		 * String fileName = path.substring(path.lastIndexOf('/')+1); return
		 * readString(filePath, fileName); } catch (Exception e) { } return "";
		 */

		File file = new File(filePath);
		if (!file.exists()) {
			return "";
		}

		BufferedReader reader = null;
		StringBuilder returnString = new StringBuilder();
		try {
			reader = new BufferedReader(new InputStreamReader(new FileInputStream(file)));
			String lineTxt = null;
			while ((lineTxt = reader.readLine()) != null) {
				returnString.append(lineTxt);
			}
		} catch (Exception e) {
			return "";
		} finally {
			try {
				reader.close();
			} catch (Exception e2) {
			}
		}
		String out = returnString.toString().trim();
		if(decode){
			out = DES3Utils.decryptMode(out.getBytes(),Constants.KEY_STRING);
		}
		return out;
	}

	/**
	 *  从文件中读取字符串
	 * @param path		文件路径
	 * @param name		文件名字	
	 * @param decode	是否需要解密
	 * @return
	 */
	public static String readString(String path, String name, boolean decode) {
		return readString(path + "/" + name, decode);
		/*
		 * File file = new File(path + "/" + name); if (!file.exists()) { return
		 * ""; }
		 * 
		 * BufferedReader reader = null; StringBuilder returnString = new
		 * StringBuilder(); try { reader = new BufferedReader(new
		 * InputStreamReader( new FileInputStream(file))); String lineTxt =
		 * null; while ((lineTxt = reader.readLine()) != null) {
		 * returnString.append(lineTxt); } } catch (Exception e) { return ""; }
		 * finally { try { reader.close(); } catch (Exception e2) { } }
		 * 
		 * return returnString.toString().trim();
		 */
	}

	/**
	 * 加载本地保存的文件
	 */
	public synchronized static JSONArray loadDataFile(String filepath) {

		JSONArray data = new JSONArray();
		try {
			File dataFile = new File(filepath);

			if (dataFile.exists()) {
				ObjectInputStream ois = new ObjectInputStream(new FileInputStream(dataFile));
				Data localData = (Data) ois.readObject();
				ois.close();
				if (localData != null) {
					data = new JSONArray(localData.mLocalJson);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return data;
	}

	/**
	 * 加载本地保存的文件
	 */
	public synchronized static JSONObject loadJobjDataFile(String filepath) {

		JSONObject data = new JSONObject();
		try {
			File dataFile = new File(filepath);

			if (dataFile.exists()) {
				ObjectInputStream ois = new ObjectInputStream(new FileInputStream(dataFile));
				Data localData = (Data) ois.readObject();
				ois.close();
				if (localData != null) {
					data = new JSONObject(localData.mLocalJson);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return data;
	}

	/**
	 * 保存到本地文件
	 */
	public synchronized static void saveDataFile(Object json, String filePath) {
		File dataFile = new File(filePath);

		Data data = new Data();
		data.mLocalJson = json.toString();
		try {
			ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(dataFile));
			oos.writeObject(data);
			oos.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 保存对象到本地
	 */
	public synchronized static void saveSerializableObject(Object object, String path) {
		if (Constants.TARGET_FOR_IOS)
			return;
		File parentFile = new File(path.substring(0, path.lastIndexOf('/')));
		if (!parentFile.exists())
			parentFile.mkdirs();
		File dataFile = new File(path);
		if (!dataFile.exists()) {
			try {
				dataFile.createNewFile();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		ObjectOutputStream oos = null;
		try {
			oos = new ObjectOutputStream(new FileOutputStream(dataFile));
			oos.writeObject(object);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				oos.close();
			} catch (IOException e) {
			}
		}
	}

	/**
	 * load本地对象
	 */
	public synchronized static Object loadSerializableObject(String filePath) {
		if (Constants.TARGET_FOR_IOS)
			return null;
		File dataFile = new File(filePath);
		if (dataFile.exists()) {
			ObjectInputStream ois = null;
			try {
				ois = new ObjectInputStream(new FileInputStream(dataFile));
				Object data = ois.readObject();
				return data;
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if (ois != null)
						ois.close();
				} catch (IOException e) {
				}
			}
		}
		return null;
	}

	/**
	 * 保存文本到本地文件
	 */
	public synchronized static void saveTextFile(String text, String filePath) {
		File dataFile = new File(filePath);
		try {
			ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(dataFile));
			oos.writeObject(text);
			oos.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 保存文件
	 * 
	 * @param bys
	 *            需要保存的数据
	 * @param path
	 *            文件位置
	 * @param name
	 *            文件名字
	 * @return
	 */
	public static boolean saveFile(byte[] bys, String path, String name) {
		File file = new File(path + "/" + name);
		File pathFile = new File(path);
		if (!pathFile.exists()) {
			pathFile.mkdirs();
		}
		try {
			FileOutputStream fos = new FileOutputStream(file);
			fos.write(bys);
			fos.flush();
			fos.close();
			return true;
		} catch (Exception e) {
			FQLog.print(TAG, "saveFile error");
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * 装载以object方式序列化的String
	 * 
	 * @param filePath
	 */
	public synchronized static String loadTextFile(String filePath) {
		File dataFile = new File(filePath);
		try {
			ObjectInputStream ois = new ObjectInputStream(new FileInputStream(dataFile));
			String str = (String) ois.readObject();
			ois.close();
			return str;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}

	/**
	 * 清空webviewCache:packageName/cache/webviewCache;
	 */
	public static void clearAdCache() {
	}

	/**
	 * 复制单个文件
	 * 
	 * @param oldPath
	 *            String 原文件路径 如：c:/fqf.txt
	 * @param newPath
	 *            String 复制后路径 如：f:/fqf.txt
	 * @return boolean
	 */
	public static void copyFile(String oldPath, String newPath) {
		try {
			// int bytesum = 0;
			int byteread = 0;
			File oldfile = new File(oldPath);
			if (oldfile.exists()) { // 文件存在时
				InputStream inStream = new FileInputStream(oldPath); // 读入原文件
				FileOutputStream fs = new FileOutputStream(newPath);
				byte[] buffer = new byte[1444];
				// int length;
				while ((byteread = inStream.read(buffer)) != -1) {
					// bytesum += byteread; //字节数 文件大小
					// System.out.println(bytesum);
					fs.write(buffer, 0, byteread);
				}
				inStream.close();
				reNameOneFile(newPath);
			}
		} catch (Exception e) {
			System.out.println("复制单个文件操作出错");
			e.printStackTrace();

		}
	}

	public static void reNameOneFile(String newPath) {
		File oldfile = new File(newPath);
		File mNewFile = new File(newPath + ".png");
		boolean mMoveSuccess = oldfile.renameTo(mNewFile);
		if (mMoveSuccess && oldfile.exists()) {
			oldfile.delete();
		}
	}

	public static void reNameFileWithPath(String newPath) {
		File mFile = new File(newPath);
		File[] files = mFile.listFiles();
		String[] filesNames = mFile.list();
		if (filesNames.length > 0) {
			int size = mFile.list().length;
			for (int i = 0; i < size; i++) {
				File mFile2 = files[i];
				String mNewPath = mFile2.getAbsolutePath() + ".png";
				File mNewFile = new File(mNewPath);
				boolean mMoveSuccess = mFile2.renameTo(mNewFile);
				if (mMoveSuccess && mFile2.exists()) {
					mFile2.delete();
				}

			}
		}
	}
}
