package com.fq.halcyon.entity.visualize;

import com.fq.lib.tools.UriConstants;

public class VisualMap extends VisualizeEntity{
	
	private static final long serialVersionUID = 1L;

	public VisualMap(){
		type = VISUALTYPE.MAP;
	}
	
	@Override
	public String getURL() {
		return UriConstants.getVasualMapURL()+"?"+getPraUserId();
	}
}
