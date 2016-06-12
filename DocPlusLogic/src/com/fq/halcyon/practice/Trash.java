package com.fq.halcyon.practice;

import java.util.ArrayList;
import java.util.Iterator;

import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.halcyon.logic2.DelPatientLogic;
import com.fq.lib.FileHelper;
import com.fq.lib.json.JSONArray;
import com.fq.lib.json.JSONObject;

public class Trash {

	class TrashElement {
		public TrashElement(String type, int id, String des) {
			this.type = type;
			this.id = id;
			this.description = des;
		}

		public String type;
		public String description;
		public int id;

		public String getType() {
			return type;
		}

		public void setType(String type) {
			this.type = type;
		}

		public String getDescription() {
			return description;
		}

		public void setDescription(String description) {
			this.description = description;
		}

		public int getId() {
			return id;
		}

		public void setId(int id) {
			this.id = id;
		}
	}

	/**
	 * 病案
	 */
	public static final String TYPE_MEDICA_RECORD = "Medical_Records";

	private static final String LOACAL_PATH = "TRASH";

	private static final String DES = "description";

	private static Trash mInstance;

	private JSONObject mTrash;

	private Trash() {
		mInstance = this;
		String localJson = FileHelper.readString(FileSystem.getInstance().getUserCachePath() + LOACAL_PATH, false);
		if (localJson != null && !localJson.equals("")) {
			try {
				mTrash = new JSONObject(localJson);
			} catch (Exception e) {
				e.printStackTrace();
				mTrash = new JSONObject();
			}
		} else {
			mTrash = new JSONObject();
		}
	}

	public void save() {
		String filePath = FileSystem.getInstance().getUserCachePath() + LOACAL_PATH;
		String dataString = mTrash.toString();
		FileHelper.saveFile(dataString, filePath, false);
	}

	public static Trash getInstance() {
		if (mInstance == null) {
			mInstance = new Trash();
		}
		return mInstance;
	}

	public void moveToTrash(String type, int id, String description) {
		try {
			JSONArray trash = mTrash.optJSONArray(type);
			JSONObject des = mTrash.optJSONObject(DES);
			if (des == null) {
				des = new JSONObject();
				mTrash.put(DES, des);
			}
			if (trash == null) {
				trash = new JSONArray();
				mTrash.put(type, trash);
			}
			des.put(String.valueOf(id), description);
			trash.put(id);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public String getDescription(int id) {
		JSONObject des = mTrash.optJSONObject(DES);
		if (des != null) {
			return des.optString(String.valueOf(id));
		}
		return "";

	}

	public void resumeFromTrash(String type, int id) {
		JSONArray trash = mTrash.optJSONArray(type);
		if (trash != null) {
			for (int i = 0; i < trash.length(); i++) {
				if (trash.optInt(i) == id) {
					trash.remove(i);
					return;
				}
			}
		}
	}

	public void deleteFromTrash(String type, int id) {
		DelPatientLogic logic = new DelPatientLogic(null);
		JSONArray trash = mTrash.optJSONArray(type);
		if (trash != null) {
			for (int i = 0; i < trash.length(); i++) {
				if (trash.optInt(i) == id) {
					trash.remove(i);
					logic.delMedical(id);
					return;
				}
			}
		}
	}

	public void deleteAll() {
		mTrash = new JSONObject();
	}

	public ArrayList<Integer> getTrash(String type) {
		ArrayList<Integer> trash = new ArrayList<Integer>();
		JSONArray trashJsonArray = mTrash.optJSONArray(type);
		if (trashJsonArray != null) {
			for (int i = 0; i < trashJsonArray.length(); i++) {
				trash.add(trashJsonArray.optInt(i));
			}
		}
		return trash;
	}

	public ArrayList<TrashElement> getAllElement() {
		ArrayList<TrashElement> all = new ArrayList<TrashElement>();
		Iterator<String> iterator = mTrash.keys();
		JSONObject des = mTrash.optJSONObject(DES);
		while (iterator.hasNext()) {
			String key = iterator.next();
			JSONArray array = mTrash.optJSONArray(key);
			if (array != null) {
				for (int i = 0; i < array.length(); i++) {
					int id = array.optInt(i);
					TrashElement element = new TrashElement(key, id, des.optString(String.valueOf(id)));
					all.add(element);
				}
			}
		}
		return all;
	}
}
