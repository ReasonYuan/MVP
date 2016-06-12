package com.hp.android.halcyon;

import java.io.InputStream;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.animation.AlphaAnimation;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.lib.json.JSONObject;

public class DealActivity extends BaseActivity {

	// private TextView tvDeal;
	private String str;
	private ListView lv;
	private ClickableSpan clickableSpan;
	private View topView;
	private View bottomView;

	@Override
	public int getContentId() {
		return R.layout.activity_deal;
	}

	@Override
	public void init() {
		// ((TextView) findViewById(R.id.tv_topbar_text)).setTextColor(Color
		// .parseColor("#535353"));
		// Typeface mFont = Typeface.createFromAsset(getAssets(),
		// "lantingchuheijian.TTF");
		// ((TextView) findViewById(R.id.tv_topbar_text)).setTypeface(mFont);
		str = "www.yiyihealth.com";
		// tvDeal = (TextView) findViewById(R.id.tv_deal);
		lv = (ListView) findViewById(R.id.lv_deal);
		topView = findViewById(R.id.view_xuanran_top);
		bottomView = findViewById(R.id.view_xuanran_bottom);
		lv.setAdapter(new DealAdapter());
		if (lv.getLastVisiblePosition() == (lv
				.getCount() - 1)) {
			bottomView.setVisibility(View.INVISIBLE);
		}
		if (lv.getFirstVisiblePosition() == 0) {
			topView.setVisibility(View.INVISIBLE);
		}
		lv.setOnScrollListener(new OnScrollListener() {

			@Override
			public void onScrollStateChanged(AbsListView arg0, int arg1) {

				// 判断滚动到底部
				if (lv.getLastVisiblePosition() == (lv.getCount() - 1)) {
					if (bottomView.getVisibility() != View.INVISIBLE) {
						AlphaAnimation alpha = new AlphaAnimation(1, 0);
						alpha.setDuration(800);
						alpha.setFillAfter(true);
						bottomView.startAnimation(alpha);
						bottomView.setVisibility(View.INVISIBLE);
					}

				} else {
					if (bottomView.getVisibility() != View.VISIBLE) {
						AlphaAnimation alpha = new AlphaAnimation(0, 1);
						alpha.setDuration(800);
						alpha.setFillAfter(true);
						bottomView.startAnimation(alpha);
						bottomView.setVisibility(View.VISIBLE);
					}

				}
				// 判断滚动到顶部
				if (lv.getFirstVisiblePosition() == 0) {
					if (topView.getVisibility() != View.INVISIBLE) {
						AlphaAnimation alpha = new AlphaAnimation(1, 0);
						alpha.setDuration(800);
						alpha.setFillAfter(true);
						topView.startAnimation(alpha);
						topView.setVisibility(View.INVISIBLE);
					}
				} else {
					if (topView.getVisibility() != View.VISIBLE) {
						AlphaAnimation alpha = new AlphaAnimation(0, 1);
						alpha.setDuration(800);
						alpha.setFillAfter(true);
						topView.startAnimation(alpha);
						topView.setVisibility(View.VISIBLE);
					}
				}

			}

			@Override
			public void onScroll(AbsListView arg0, int arg1, int arg2, int arg3) {

			}
		});
		// tvDeal.setText(getFromAssets("register_protocol.txt"));
		// tvDeal.setAutoLinkMask(Linkify.WEB_URLS);
		// tvDeal.setMovementMethod(LinkMovementMethod.getInstance());
		clickableSpan = new ClickableSpan() {

			@Override
			public void onClick(View arg0) {
				Intent intent = new Intent();
				intent.setAction("android.intent.action.VIEW");
				Uri content_url = Uri.parse("http://" + str);
				intent.setData(content_url);
				startActivity(intent);

			}
		};
		// setClickableSpanForTextView(tvDeal, clickableSpan,
		// getFromAssets("register_protocol.txt"));
		setTitle("注册协议");
	}

	public String getFromAssets(String fileName) {
		String result = "";
		try {
			InputStream in = getResources().getAssets().open(fileName);
			// 获取文件的字节数
			int lenght = in.available();
			// 创建byte数组
			byte[] buffer = new byte[lenght];
			// 将文件中的数据读到byte数组中
			in.read(buffer);
			String str = new String(buffer, "UTF-8");
			JSONObject object;
			object = new JSONObject(str);
			result = object.optString("registerProtocol");

		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	private void setClickableSpanForTextView(TextView tv,
			ClickableSpan clickableSpan, String text) {
		SpannableString sp = new SpannableString(text);
		int start = text.indexOf(str);
		int end = start + str.length();
		sp.setSpan(clickableSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
		tv.setText(sp);
		tv.setLinkTextColor(Color.BLUE);
		tv.setMovementMethod(LinkMovementMethod.getInstance());
		tv.setFocusable(false);
		tv.setClickable(false);
		tv.setLongClickable(false);
	}

	class DealAdapter extends BaseAdapter {

		@Override
		public int getCount() {
			return 3;
		}

		@Override
		public Object getItem(int arg0) {
			return null;
		}

		@Override
		public long getItemId(int arg0) {
			// TODO Auto-generated method stub
			return 0;
		}

		@Override
		public View getView(int arg0, View arg1, ViewGroup arg2) {
			TextView tv = new TextView(DealActivity.this);
			if (arg0 == 1) {
				setClickableSpanForTextView(tv, clickableSpan,
						getFromAssets("register_protocol.txt"));
			} else {
				tv.setLayoutParams(new AbsListView.LayoutParams(
						LayoutParams.MATCH_PARENT, 1));
			}

			return tv;
		}

	}

}
