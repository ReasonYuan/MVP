package com.fq.halcyon.logic2;

import java.util.HashMap;

import com.fq.halcyon.HalcyonHttpResponseHandle;
import com.fq.halcyon.api.ApiSystem;
import com.fq.halcyon.api.ApiSystem.API_TYPE;
import com.fq.halcyon.entity.FollowUpTemple;
import com.fq.http.async.FQHttpParams;
import com.fq.http.potocol.FQHttpResponseInterface;
import com.fq.lib.JsonHelper;
import com.fq.lib.json.JSONObject;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;

public class SearchFollowUpTempleDetailLogic {

	public interface SearchFollowUpTempleDetailLogicInterface extends FQHttpResponseInterface{
		public void onSearchError(int errCode,String msg);
		public void onSearchSuccess(FollowUpTemple mFollowUpTemple);
	}
	
	private SearchFollowUpTempleDetailLogicInterface mInterface;
	
	/**
	 * 随访模板的Id
	 */
	private int mFollowUpTempleId;
	
	private FollowUpTemple mFollowUpTemple;
	
	class SearchFollowUpTempleDetailLogicHandle extends HalcyonHttpResponseHandle{

		@Override
		public void onError(int code, Throwable e) {
			mInterface.onSearchError(code, e.toString());
		}

		@Override
		public void handle(int responseCode, String msg, int type,
				Object results) {
			if (responseCode == 0) {
				JSONObject mJsonObject = (JSONObject)results;
				mFollowUpTemple = new FollowUpTemple();
				mFollowUpTemple.setAtttributeByjson(mJsonObject);
				mFollowUpTemple.setmTempleId(mFollowUpTempleId);
				mFollowUpTemple.setUserId(Constants.getUser().getUserId());
				mInterface.onSearchSuccess(mFollowUpTemple);
			}else {
				mInterface.onSearchError(responseCode, msg);
			}
		}
		
	}
	
	private SearchFollowUpTempleDetailLogicHandle mHandle = new SearchFollowUpTempleDetailLogicHandle();
	
	public SearchFollowUpTempleDetailLogic(SearchFollowUpTempleDetailLogicInterface mIn,int templeId) {
		this.mInterface = mIn;
		this.mFollowUpTempleId = templeId;
	}
	
	public void getTempleDetail(){
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("user_id", Constants.getUser().getUserId());
		map.put("followup_template_id", mFollowUpTempleId);
		JSONObject json = JsonHelper.createJsonForDebug(map);
		String url = UriConstants.Conn.URL_PUB + "/timer/search_followup_template_detail.do";

		ApiSystem.getInstance().require(url, new FQHttpParams(json), API_TYPE.DIRECT, mHandle);
	}

}
