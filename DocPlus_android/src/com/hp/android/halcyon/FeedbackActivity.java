package com.hp.android.halcyon;

import android.annotation.SuppressLint;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.fq.android.plus.R;
import com.fq.halcyon.logic2.UploadFeedBackLogic;
import com.fq.halcyon.logic2.UploadFeedBackLogic.UploadFeedBackLogicInterface;
import com.hp.android.halcyon.util.UITools;
import com.hp.android.halcyon.widgets.CustomProgressDialog;

@SuppressLint("NewApi")
public class FeedbackActivity extends BaseActivity {
	// private TextView mManager;
	// private TextView mOptions;
	private TextView textnum;
	private EditText ed_feedBack;
	private CustomProgressDialog mDialog;
	private String mFeedBack;
	private LinearLayout mOutHide;
	private View topView, bottomView;
//	private Timer timer;

	@Override
	public int getContentId() {
		// TODO Auto-generated method stub
		return R.layout.activity_feedback;
	}

	@Override
	public void init() {
		// ((TextView) findViewById(R.id.tv_topbar_text)).setTextColor(Color
		// .parseColor("#535353"));
		// ((TextView) findViewById(R.id.tv_topbar_text)).setTypeface(mFont);
		setTitle("反馈意见");
		// mManager = (TextView) findViewById(R.id.jingli);
		// mOptions = (TextView) findViewById(R.id.opitions);
		textnum = (TextView) findViewById(R.id.tv_feedback_text_length);
		textnum.setText("0");
		topView = findViewById(R.id.top_view_feed_back);
		bottomView = findViewById(R.id.bottom_view_feed_back);
		ed_feedBack = (EditText) findViewById(R.id.et_feedback_content);
		// mManager.setTypeface(TextFontUtils.getTypeface(TextFontUtils.FONT_FZLTJT_BLOD));
		// mOptions.setTypeface(TextFontUtils.getTypeface(TextFontUtils.FONT_FZLTJT));

		ed_feedBack.addTextChangedListener(new TextWatcher() {
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
			}

			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
			}

			@Override
			public void afterTextChanged(Editable s) {
				findViewById(R.id.register_button).setEnabled(s.length() > 0);
				textnum.setText("" + s.length());

			}
		});

//		timer = new Timer();
//		TimerTask task = new TimerTask() {
//
//			@Override
//			public void run() {
//
//				Message message = new Message();
//				message.what = ed_feedBack.getScrollY();
//				handler.sendMessage(message);
//			}
//		};
//		timer.schedule(task, 200, 400);

		mOutHide = (LinearLayout) findViewById(R.id.feed_out_hide);
		mOutHide.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				((InputMethodManager) getSystemService(INPUT_METHOD_SERVICE))
						.hideSoftInputFromWindow(FeedbackActivity.this
								.getCurrentFocus().getWindowToken(),
								InputMethodManager.HIDE_NOT_ALWAYS);
			}
		});
	}

//	Handler handler = new Handler() {
//
//		public void handleMessage(Message msg) {
//
//			if (msg.what == 0) {
//				if (topView.getVisibility() != View.INVISIBLE) {
//					AlphaAnimation alpha = new AlphaAnimation(1, 0);
//					alpha.setDuration(800);
//					alpha.setFillAfter(true);
//					topView.startAnimation(alpha);
//					topView.setVisibility(View.INVISIBLE);
//				}
//			} else if (msg.what > 0) {
//				if (topView.getVisibility() != View.VISIBLE) {
//					AlphaAnimation alpha = new AlphaAnimation(0, 1);
//					alpha.setDuration(800);
//					alpha.setFillAfter(true);
//					topView.startAnimation(alpha);
//					topView.setVisibility(View.VISIBLE);
//				}
//			}
//
//			if (ed_feedBack.getLineHeight() * ed_feedBack.getLineCount()
//					+ ed_feedBack.getPaddingTop() * 2
//					+(ed_feedBack.getLineCount()-1)
//					* ed_feedBack.getLineSpacingExtra()
//					- ed_feedBack.getMeasuredHeight()
//					- ed_feedBack.getScrollY() >= -ed_feedBack.getLineHeight()
//					&& ed_feedBack.getLineHeight() * ed_feedBack.getLineCount()
//							+ ed_feedBack.getPaddingTop() * 2
//							- ed_feedBack.getMeasuredHeight()
//							- ed_feedBack.getScrollY() <= ed_feedBack
//								.getLineHeight()) {
//				if (bottomView.getVisibility() != View.INVISIBLE) {
//					AlphaAnimation alpha = new AlphaAnimation(1, 0);
//					alpha.setDuration(800);
//					alpha.setFillAfter(true);
//					bottomView.startAnimation(alpha);
//					bottomView.setVisibility(View.INVISIBLE);
//				}
//			} else {
//				if (bottomView.getVisibility() != View.VISIBLE) {
//					AlphaAnimation alpha = new AlphaAnimation(0, 1);
//					alpha.setDuration(800);
//					alpha.setFillAfter(true);
//					bottomView.startAnimation(alpha);
//					bottomView.setVisibility(View.VISIBLE);
//				}
//			}
//		};
//	};

	@Override
	public void onBackPressed() {
//		if (timer != null) {
//			timer.cancel();
//			timer = null;
//		}
		super.onBackPressed();

	};

	public void onSendClick(View v) {
		mDialog = new CustomProgressDialog(this);
		mDialog.setMessage("正在提交反馈意见...");
		mFeedBack = ed_feedBack.getText().toString().trim();
		new UploadFeedBackLogic(new UploadFeedBackLogicInterface() {

			@Override
			public void onErrorReturn(int code, Throwable e) {
				mDialog.dismiss();
				mDialog = null;
				UITools.showToast("提交反馈意见失败！");
			}

			@Override
			public void onDaraReturn(int responseCode, String msg) {
				mDialog.dismiss();
				mDialog = null;
				UITools.showToast("提交意见成功，谢谢参与！");
				finish();
			}

			@Override
			public void onError(int code, Throwable error) {

			}

		}, mFeedBack);
	}
}
