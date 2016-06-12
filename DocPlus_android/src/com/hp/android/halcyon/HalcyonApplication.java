package com.hp.android.halcyon;

import java.lang.Thread.UncaughtExceptionHandler;
import java.util.List;
import java.util.Properties;
import java.util.UUID;

import org.apache.http.HttpVersion;
import org.apache.http.client.HttpClient;
import org.apache.http.conn.ClientConnectionManager;
import org.apache.http.conn.scheme.PlainSocketFactory;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.tsccm.ThreadSafeClientConnManager;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.params.HttpProtocolParams;
import org.apache.http.protocol.HTTP;

import android.app.Application;
import android.content.Context;
import android.os.Handler;
import android.util.Log;
import android.widget.Toast;

import com.baidu.mapapi.SDKInitializer;
import com.fq.halcyon.extend.filesystem.FileSystem;
import com.fq.lib.json.JSONObject;
import com.fq.lib.platform.Platform;
import com.fq.lib.tools.Constants;
import com.fq.lib.tools.FQLog;
import com.fq.lib.tools.FQRemoteDebugTool;
import com.fq.lib.tools.FQRemoteDebugTool.RemoteLogger;
import com.fq.platfrom.android.FQAsyncHttpClient;
import com.fq.platfrom.android.FQSecuritySession;
import com.fq.platfrom.android.PlatformAndroid;
import com.gotye.api.Gotye;
import com.gotye.api.GotyeAPI;
import com.gotye.api.GotyeChatListener;
import com.gotye.api.GotyeLoginListener;
import com.gotye.api.GotyeStatusCode;
import com.gotye.api.bean.GotyeMessage;
import com.gotye.api.bean.GotyeTargetType;
import com.gotye.api.bean.GotyeTargetable;
import com.gotye.api.bean.GotyeTextMessage;
import com.gotye.api.bean.GotyeUser;
import com.gotye.api.bean.GotyeVoiceMessage;
import com.gotye.api.media.WhineMode;
import com.gotye.api.utils.TimeUtil;
import com.hp.android.halcyon.server.HalcyonService;
import com.hp.android.halcyon.server.HalcyonService.OnNetWorkChangedListener;
import com.hp.android.halcyon.util.AlarmHelper;
import com.hp.android.halcyon.util.BaiDuTJSDk;
import com.hp.android.halcyon.util.FileManager;
import com.hp.android.halcyon.util.MessageStruct;
import com.hp.android.halcyon.util.TextFontUtils;
import com.hp.android.halcyon.util.mail.SendMail;
import com.loopj.android.http.YiyiLiveServerVerify;

//@ReportsCrashes(formKey = "", // will not be used
//	mailTo = "johnny.peng@yiyihealth.com",
//	mode = ReportingInteractionMode.SILENT,
//	resToastText = 0) //if mode is toast, must set a resource integer constant
public class HalcyonApplication extends Application implements GotyeLoginListener, GotyeChatListener, OnNetWorkChangedListener {
	
	public static final boolean USE_X86_SIMULATOR = false;
	
	public static Context mContext;

	private static Handler mHandler;

	public static GotyeAPI mApi;

	private static HalcyonApplication mInstance;
	
	public static boolean isNetWorkConnect = true;
	

	private HttpClient httpClient;
	private Thread uiThread;
	
	public static HalcyonApplication getInstance() {
		return mInstance;
		
	}

	public void onCreate() {
		super.onCreate();
		SDKInitializer.initialize(this);
		mInstance = this;
		mHandler = new Handler();
		mContext = getApplicationContext();
		httpClient = this.createHttpClient();
		uiThread = Thread.currentThread();
		FQAsyncHttpClient.setHandler(Thread.currentThread());
		FQAsyncHttpClient.setSession(FQSecuritySession.getInstance());
		try {
			YiyiLiveServerVerify.setYiyiCerSignature(getAssets().open("c"));
		} catch (Exception e) {
		}
		// 初始化目录
		FileManager fileManager = FileManager.getInstance();
		FileSystem.initWithRootPath(fileManager.getPhoneRootPath(), fileManager.getSDCardRootPath());
		fileManager = null;// fileManager只是用作提供android根目录
		Platform.setInstance(new PlatformAndroid());
			
		//用ACRA crash收集工具代替我们自己的处理器
		Thread.currentThread().setUncaughtExceptionHandler(restartHandler);
		//ACRA.init(this);

		if(!USE_X86_SIMULATOR) {
			// 初始化亲加
			Properties properties = new Properties();
//			d588c7b8-c641-4998-b0bc-3ac7360962d7 此处是大仙儿以前申请的appkey 后来换成了ios申请的 因为ios推送比较麻烦 各种证书
//			properties.put(Gotye.PRO_APP_KEY, "d588c7b8-c641-4998-b0bc-3ac7360962d7");
			properties.put(Gotye.PRO_APP_KEY, "44618818-be46-458c-9b17-dcc7b44019d1");
			Gotye.getInstance().init(this, properties);
		};
		
		//初始化字体
		TextFontUtils.init(this);
		
		//初始化百度统计分析
		BaiDuTJSDk.init(this);
		
		//设置远程log， 用于非常难搞的bug, logic工程里调用 FQRemoteDebugTool.log()来log信息，信息将发送到异常捕获邮箱
		FQRemoteDebugTool.setRemoteLogger(new RemoteLogger() {
			@Override
			public void log(String message) {
				SendMail.send_qqmail(message, mContext);
			}
		});
		AlarmHelper.init();
	}

	public static Context getAppContext() {
		return HalcyonApplication.mContext;
	}

	public static void showToast(final String msg) {
		mHandler.post(new Runnable() {
			public void run() {
				Toast.makeText(mContext, msg, Toast.LENGTH_SHORT).show();
			}
		});
	}

	public static void runOnUITherad(Runnable run) {
		mHandler.post(run);
	}

	public UncaughtExceptionHandler restartHandler = new UncaughtExceptionHandler() {
		@Override
		public void uncaughtException(Thread thread, final Throwable ex) {
			thread.setUncaughtExceptionHandler(null);
			Log.e("", "", ex);
			new Thread(new Runnable() {
				@Override
				public void run() {
					try {
						if(ex.toString().indexOf("Unable to resume activity {com.fq.android.plus/com.hp.android.halcyon.HomeActivity}") >= 0){
							//忽略这个异常，通常调试时会发生这个异常，暂时不理会
						} else {
							SendMail.send_qqmail(ex.toString() + "\n" + SendMail.getStackTraceString(ex.getStackTrace()), mContext);
						}
					} catch (Exception e) {
						throw new RuntimeException("发送崩溃报告失败!", e);
					}
					//必须新起线程才能抛出异常导致程序崩溃
					throw new Error(ex);
				}
			}).start();
		}
	};

	public void onUserLoginIn() {
		if(USE_X86_SIMULATOR) return;
		if(HalcyonService.isNetworkConnected(mContext) && Constants.getUser() != null &&Constants.getUser().getUserId() !=0 ){
			if(mApi != null && String.valueOf(Constants.getUser().getUserId()).equals(mApi.getUsername())){
				return;
			}
			mApi = Gotye.getInstance().makeGotyeAPIForUser(String.valueOf(Constants.getUser().getUserId()));
			mApi.addLoginListener(this);
			mApi.addChatListener(this);
			mApi.login(null);
		}
	}

	public void onUserLoginOut() {
		if(USE_X86_SIMULATOR) return;
		if (mApi != null) {
			mApi.logout();
			mApi.removeAllChatListener();
			mApi.removeAllGroupListener();
			mApi.removeAllLoginListener();
			mApi.removeAllUserListener();
		}
		mApi = null;
	}
	
	/**
	 * 
	 * @param msgType {@link com.hp.android.halcyon.util.MessageStruct#MESSAGE_TYPE_ADD_NEW_FRIEND} or {@link com.hp.android.halcyon.util.MessageStruct#MESSAGE_TYPE_AGREE_ADD_NEW_FRIEND}
	 * @param msg  message body
	 * @param toUser 
	 */
	public void sendMessage(int msgType,String msg, int toUser){
		if(USE_X86_SIMULATOR) return;
		GotyeUser sender = new GotyeUser(mApi.getUsername());
		GotyeUser reciever = new GotyeUser(String.valueOf(toUser));
		GotyeTextMessage message = new GotyeTextMessage(UUID.randomUUID().toString(), TimeUtil.getCurrentTime(), reciever, sender);
		MessageStruct struct = new MessageStruct(msgType, msg, toUser);
		message.setText(struct.toString());
		struct.onMessageSend();
		mApi.sendMessageToTarget(message);
	}
	
	public void sendMessage(int msgType,String msg, int toUser,JSONObject mJsonObject){
		if(USE_X86_SIMULATOR) return;
		GotyeUser sender = new GotyeUser(mApi.getUsername());
		GotyeUser reciever = new GotyeUser(String.valueOf(toUser));
		GotyeTextMessage message = new GotyeTextMessage(UUID.randomUUID().toString(), TimeUtil.getCurrentTime(), reciever, sender);
		MessageStruct struct = new MessageStruct(msgType, msg, toUser,mJsonObject);
		message.setText(struct.toString());
		struct.onMessageSend();
		mApi.sendMessageToTarget(message);
	}
	
	@Override
	public void onGetHistoryMessages(String arg0, String arg1, GotyeTargetable arg2, String arg3, List<GotyeMessage> arg4, boolean arg5, int arg6) {
		
	}

	@Override
	public void onGetOfflineMessage(String arg0, String arg1, List<GotyeMessage> arg2, int arg3) {
		for (int i = 0; i < arg2.size(); i++) {
			MessageStruct message = new MessageStruct(((GotyeTextMessage)arg2.get(i)).getText());
			message.handleMessage(mContext);
		}
	}

	@Override
	public void onReceiveMessage(String arg0, String arg1, GotyeMessage arg2) {
		MessageStruct message = new MessageStruct(((GotyeTextMessage)arg2).getText());
		message.handleMessage(mContext);
	}

	@Override
	public void onReceiveVoiceMessage(String arg0, String arg1, GotyeTargetable arg2, GotyeTargetable arg3) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onSendMessage(String arg0, String arg1, GotyeMessage arg2, int status) {
		if(USE_X86_SIMULATOR) return;
		if(status == GotyeStatusCode.STATUS_OK){
//			Toast.makeText(this, "消息发送成功", Toast.LENGTH_SHORT).show();
			return;
		}
		if(status == GotyeStatusCode.STATUS_FORBIDDEN_SEND_MSG){
			Toast.makeText(this, "已被禁言", Toast.LENGTH_SHORT).show();
		}else if(status == GotyeStatusCode.STATUS_USER_NOT_EXISTS){
//			Toast.makeText(this, "该用户不存在", Toast.LENGTH_SHORT).show();
			Log.e("", "亲加用户不存在！");
		}else if(status == GotyeStatusCode.STATUS_SEND_MSG_TO_SELF){
			Toast.makeText(this, "不能向自己发送消息  "+ status, Toast.LENGTH_SHORT).show();
		}else if(status == GotyeStatusCode.STATUS_NOT_IN_ROOM){
			Toast.makeText(this, "您不在房间，发送失败  "+ status, Toast.LENGTH_SHORT).show();
		}else{
			//Toast.makeText(this, "发送失败" + status, Toast.LENGTH_SHORT).show();
			FQLog.e("Halcyon Gotye", "Gotye发送其他状态"+status);
		}
	}

	@Override
	public void onStartTalkTo(String arg0, String arg1, GotyeTargetable arg2, WhineMode arg3, boolean arg4) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onStopTalkTo(String arg0, String arg1, GotyeTargetable arg2, WhineMode arg3, boolean arg4, GotyeVoiceMessage arg5, long arg6, int arg7) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onVoiceMessageEnd(String arg0, String arg1, GotyeTargetable arg2, GotyeTargetable arg3) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onLogin(String arg0, String arg1, int arg2) {
		if(USE_X86_SIMULATOR) return;
		if(arg2 == GotyeStatusCode.STATUS_OK){
			//登录成功,获取离线信息
			mApi.getOfflineMsg(GotyeTargetType.GOTYE_USER, "", 10);
			return;
		}else{
			//登录失败 重新登录
			if(HalcyonService.isNetworkConnected(mContext)){
				mApi.login(null);
			}
		}

	}

	@Override
	public void onLogout(String arg0, String arg1, int arg2) {

	}

	@Override
	public void onNetWorkChanged(boolean connected) {
		isNetWorkConnect = connected;
		Platform.isNetWorkConnect = connected;
		if(connected){
			onUserLoginIn();
		}else {
			onUserLoginOut();
		}
	}
	
	public Thread getUiThread() {
		return uiThread;
	}
	
	// 创建HttpClient实例
	private HttpClient createHttpClient() {
		HttpParams params = new BasicHttpParams();
		HttpProtocolParams.setVersion(params, HttpVersion.HTTP_1_1);
		HttpProtocolParams.setContentCharset(params,
				HTTP.DEFAULT_CONTENT_CHARSET);
		HttpProtocolParams.setUseExpectContinue(params, true);
		HttpConnectionParams.setConnectionTimeout(params, 20 * 1000);
		HttpConnectionParams.setSoTimeout(params, 20 * 1000);
		HttpConnectionParams.setSocketBufferSize(params, 8192);
		SchemeRegistry schReg = new SchemeRegistry();
		schReg.register(new Scheme("http", PlainSocketFactory
				.getSocketFactory(), 80));
		schReg.register(new Scheme("https",
				SSLSocketFactory.getSocketFactory(), 443));

		ClientConnectionManager connMgr = new ThreadSafeClientConnManager(
				params, schReg);

		return new DefaultHttpClient(connMgr, params);
	}

	// 关闭连接管理器并释放资源
	private void shutdownHttpClient() {
		if (httpClient != null && httpClient.getConnectionManager() != null) {
			httpClient.getConnectionManager().shutdown();
		}
	}

	// 对外提供HttpClient实例
	public HttpClient getHttpClient() {
		return httpClient;
	}
}
