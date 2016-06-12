package com.fq.android.visualization;

import java.util.ArrayList;

import android.annotation.SuppressLint;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.fq.lib.tools.Constants;
import com.fq.lib.tools.UriConstants;
import com.hp.android.halcyon.BaseActivity;
import com.hp.android.halcyon.util.IntentKey;
import com.hp.android.halcyon.util.UITools;

@SuppressLint("SetJavaScriptEnabled")
public class ChartActivity extends BaseActivity {

	private WebView mWebView;
	private int mPatientId;
	private ArrayList<Integer> mRecordIds = new ArrayList<Integer>();

	private String mDataType;
	private String mDataColumn;
	
	@Override
	public int getContentId() {
		// TODO Auto-generated method stub
		return 0;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void init() {
		mPatientId = getIntent().getIntExtra("patientId", mPatientId);
		mRecordIds = (ArrayList<Integer>) getIntent().getSerializableExtra("recordIds");
		mDataType = getIntent().getStringExtra(IntentKey.VISUALIZE_DATA_TYPE);
		mDataColumn = getIntent().getStringExtra(IntentKey.VISUALIZE_DATA_COLUMN);
		//TODO 提出到strings.xml
		setTitle("数据可视化(Demo)");
		mWebView = new WebView(this);
		//允许运行javascript
		mWebView.getSettings().setJavaScriptEnabled(true);
		mContainer.addView(mWebView);
		//TODO 测试代码，以后需要修改成域名或配置在在文件里，根据发布不同的环境而不同
		mWebView.loadUrl(getUrl(mDataType, mDataColumn, mPatientId, mRecordIds));
		mWebView.setWebViewClient(new webClient());
	}

	class webClient extends WebViewClient{
        public void onPageFinished(WebView view, String url) {
        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
        	UITools.showToast("网络错误");
        }
	}
	
	public String getUrl(String dataType, String dataColumn, int patientId, ArrayList<Integer> recordIds){
	
		StringBuffer url = new StringBuffer();
		url.append(UriConstants.getVasualDataURL());
		url.append("?userId=" + Constants.getUser().getUserId() + "&dataType='" + dataType + "'&dataColumn='" + dataColumn + "'&patientId=" + patientId + "&recordIds='");
		if (recordIds.size() == 1) {
			url.append(recordIds.get(0));
		}else if(recordIds.size() > 1){
			url.append(recordIds.get(0));
			for (int i = 1; i < recordIds.size(); i++) {
				url.append(";" + recordIds.get(i));
			}
		}
		url.append("'");
		return url.toString();
	}
}
