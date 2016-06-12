package com.hp.android.halcyon;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

import com.fq.android.plus.R;
import com.fq.halcyon.entity.visualize.VisualizeEntity;
import com.fq.library.utils.FQLog;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

@SuppressLint("SetJavaScriptEnabled") 
public class DataVisualizationActivity extends Activity {

	public static final String EXTRA = "visualizentity";
	
	private WebView mWebView;
	private FrameLayout mBtnBack;
	private CustomProgressDialog mProgress;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_data_visualization);
		init();
	}

	public void init() {
		mBtnBack = (FrameLayout) findViewById(R.id.btn_data_visualization_back);
		mWebView = (WebView) findViewById(R.id.wv_data_visualization_char);
		//允许运行javascript
		mWebView.getSettings().setJavaScriptEnabled(true);
		//TODO 测试代码，以后需要修改成域名或配置在在文件里，根据发布不同的环境而不同
//		mWebView.loadUrl("http://115.29.229.128:8080/yiyi/map.jsp?userId=" + Constants.getUser().getUserId());
		VisualizeEntity entity = (VisualizeEntity) getIntent().getSerializableExtra(EXTRA);
		mWebView.loadUrl(entity.getURL());
		FQLog.i("url", "~~~~url:"+entity.getURL());
		
		mWebView.setWebViewClient(new webClient());
		mProgress = new CustomProgressDialog(this);
		mProgress.setMessage("正在加载数据...");
		
		mBtnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				finish();
			}
		});
	}

	private void dismissProgress(){
		if(mProgress != null){
			mProgress.dismiss();
			mProgress = null;
		}
	}
	
	class webClient extends WebViewClient{
        public void onPageFinished(WebView view, String url) {
        	dismissProgress();
        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
        	UITools.showToast("网络错误");
        	dismissProgress();
        }
	}
}
