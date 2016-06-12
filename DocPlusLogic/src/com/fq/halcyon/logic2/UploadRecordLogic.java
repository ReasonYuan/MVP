package com.fq.halcyon.logic2;

import java.util.ArrayList;

import com.fq.halcyon.HalcyonUploadLooper;
import com.fq.halcyon.entity.Photo;
import com.fq.halcyon.entity.PhotoRecord;
import com.fq.halcyon.uimodels.OneCopy;
import com.fq.halcyon.uimodels.OneType;
import com.fq.http.async.FQHttpParams;
import com.fq.http.async.uploadloop.LoopCell;
import com.fq.http.async.uploadloop.LoopCell.CELL_TYPE;
import com.fq.http.async.uploadloop.LoopUpLoadCell;
import com.fq.http.async.uploadloop.LoopUpLoadCell.UP_TYPE;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class UploadRecordLogic {

	public UploadRecordLogic() {
	}
	
	public void upLoad(String patientaName,int recordId,ArrayList<OneType> types) {
		JSONObject json = new JSONObject();
		try {
			json.put("user_id",Constants.getUser().getUserId()); 
			json.put("record_id",recordId); 
		} catch (Exception e) {
		}
		// 确定，保存病历
		String uploadUrl = UriConstants.Conn.URL_PUB + "/record/item/create.do";
		FQHttpParams params = new FQHttpParams(json);

		for (int i = 0; i < types.size(); i++) {
			LoopCell cell = new LoopUpLoadCell(uploadUrl,params,UP_TYPE.UP_TYPE_RECORD);
			((LoopUpLoadCell)cell).uuid = types.get(i).uuid;
			((LoopUpLoadCell)cell).setRecordId(recordId);
			cell.name = patientaName;
			int fileSize = 0;
			OneType oneType = types.get(i);
			ArrayList<OneCopy> oneCopies = oneType.getAllCopies();
			for (int j = 0; j < oneCopies.size(); j++) {
				ArrayList<Photo> photos1 = new ArrayList<Photo>();
				OneCopy oneCopy = oneCopies.get(j);
				ArrayList<PhotoRecord> photos = oneCopy.getPhotos();
				if(photos.size() == 0) continue;
				for (int k = 0; k < photos.size(); k++) {
					String filePath = photos.get(k).getLocalPath();
					Photo photo = new Photo();
					photo.setLocalPath(filePath);
					photos1.add(photo);
				}
				fileSize  += photos1.size();
				cell.addPhotos(oneType.getType(), photos1);
			}
			cell.setType(CELL_TYPE.CELL_UPLOAD);
			if(fileSize != 0){
				HalcyonUploadLooper.getInstance().push(cell);
			}
		}
	}
	
}
