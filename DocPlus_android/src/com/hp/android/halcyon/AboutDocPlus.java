package com.hp.android.halcyon;

import java.io.InputStream;

import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.animation.AlphaAnimation;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.lib.json.JSONObject;

public class AboutDocPlus extends BaseActivity implements OnClickListener {

	private LinearLayout mWhoWeAre;
	// private TextView aboutPlus;
	private ListView listView;
	private View topView;
	private View bottomView;

	@Override
	public int getContentId() {
		return R.layout.activity_about_doc_plus;
	}

	@Override
	public void init() {
		initWidgets();
		initListener();
	}

	private void initWidgets() {
		mWhoWeAre = (LinearLayout) findViewById(R.id.ll_about_plus_who_we_are);
		// aboutPlus = (TextView) findViewById(R.id.tv_about_plus);
		// aboutPlus.setText(getFromAssets("about_doc_plus.txt"));
		listView = (ListView) findViewById(R.id.lv_about_doc_plus);
		topView = findViewById(R.id.top_view);
		bottomView = findViewById(R.id.bottom_view);

		listView.setAdapter(new AboutDocPlusAdapter());
		if (listView.getLastVisiblePosition() == (listView
				.getCount() - 1)) {
			bottomView.setVisibility(View.INVISIBLE);
		}
		if (listView.getFirstVisiblePosition() == 0) {
			topView.setVisibility(View.INVISIBLE);
		}

		// ((TextView) findViewById(R.id.tv_topbar_text)).setTextColor(Color
		// .parseColor("#535353"));
		// Typeface mFont = Typeface.createFromAsset(getAssets(),
		// "lantingchuheijian.TTF");
		// ((TextView) findViewById(R.id.tv_topbar_text)).setTypeface(mFont);
		setTitle("关于医加");
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
			System.out.println(object + "");
			result = object.optString("aboutPlus");

		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	private void initListener() {
		mWhoWeAre.setOnClickListener(this);
		listView.setOnScrollListener(new OnScrollListener() {

			@Override
			public void onScrollStateChanged(AbsListView arg0, int arg1) {
				// 判断滚动到底部
				if (listView.getLastVisiblePosition() == (listView.getCount() - 1)) {
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
				if (listView.getFirstVisiblePosition() == 0) {
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
	}

	@Override
	public void onClick(View view) {
		switch (view.getId()) {
		case R.id.ll_about_plus_who_we_are:
			// startActivity(new Intent(AboutDocPlus.this,
			// WhoWeAreActivity.class));
			break;

		default:
			break;
		}
	}

	class AboutDocPlusAdapter extends BaseAdapter {

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
			TextView tv = new TextView(AboutDocPlus.this);
			if (arg0 == 1) {
				tv.setText(getFromAssets("about_doc_plus.txt"));
			} else {
				tv.setLayoutParams(new AbsListView.LayoutParams(
						LayoutParams.MATCH_PARENT, 1));
			}

			return tv;
		}

	}
}
