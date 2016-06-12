package com.fq.lib.tools;

public class UriConstants {
	/**
	 * 连接网络使用常量类
	 */
	public class Conn {
		//增加删除"/"来切换环境
		//[AppStore环境]
		/**AppStore环境配置开始
		public static final int PUB_PORT = 443;
		public static final String URL_PUB_NOYIYI = "https://www.yiyihealth.com" + ":" + PUB_PORT;
		public static final String URL_PUB = URL_PUB_NOYIYI+"/yiyi";//服务器地址
		public static final String URL_ZXING = "http://www.yiyihealth.com/yiyi";//生成二维码的地址
		public static final boolean DO_NOT_VERIFY_CERTIFICATE = false; //发布生产环境需要设置成false, 是否"不去"验证证书的合法性
		public static final boolean PRODUCTION_ENVIRONMENT = true;//是否是生产环境
		public static final boolean DEBUG_MODE = false;
		public static final String IM_ENVIROMENT = "appstore";
		public static final String IM_SDK_URI = "218.244.150.28:9090";
		/**///AppStore环境配置结束
		
		//[生产环境]
		/**生产环境配置开始
		public static final int PUB_PORT = 8180;
		public static final String URL_PUB_NOYIYI = "http://115.29.239.19" + ":" + PUB_PORT;
		public static final String URL_PUB = URL_PUB_NOYIYI+"/yiyi";//服务器地址
		public static final String URL_ZXING = "http://www.yiyihealth.com/yiyi";//生成二维码的地址
		public static final boolean DO_NOT_VERIFY_CERTIFICATE = true; //发布生产环境需要设置成false, 是否"不去"验证证书的合法性
		public static final boolean PRODUCTION_ENVIRONMENT = true;//是否是生产环境
		public static final boolean DEBUG_MODE = false;
		public static final String IM_ENVIROMENT = "release";
		public static final String IM_SDK_URI = "218.244.150.28:9090";
		/**///生产环境配置结束
		
		//[预生产环境]
		/**预生产环境配置开始
		public static final int PUB_PORT = 8180;
		public static final String URL_PUB_NOYIYI = "http://115.29.229.128" + ":" + PUB_PORT;
		public static final String URL_PUB = URL_PUB_NOYIYI+"/yiyi";//服务器地址
		public static final String URL_ZXING = "http://www.yiyihealth.com/yiyi";//生成二维码的地址
		public static final boolean DO_NOT_VERIFY_CERTIFICATE = true; //发布生产环境需要设置成false, 是否"不去"验证证书的合法性
		public static final boolean PRODUCTION_ENVIRONMENT = true;//是否是生产环境
		public static final boolean DEBUG_MODE = false;
		public static final String IM_ENVIROMENT = "prerelease";
		public static final String IM_SDK_URI = "218.244.150.28:9092";
		/**///预生产环境配置结束	
		
		//[mvp测试环境]
		/**mvp测试环境置开始
		public static final int PUB_PORT = 443;//8080 443
		public static final String URL_PUB_NOYIYI = "https://115.29.239.19" + ":" + PUB_PORT;
		public static final String URL_PUB = URL_PUB_NOYIYI+"/yiyi";//服务器地址 https://115.29.239.19
		public static final String URL_ZXING = "http://www.yiyihealth.com/yiyi";//生成二维码的地址
		public static final boolean DO_NOT_VERIFY_CERTIFICATE = true; //是否"不去"验证证书的合法性
		public static final boolean PRODUCTION_ENVIRONMENT = false;//是否是生产环境
		public static final boolean DEBUG_MODE = true;
		public static final String IM_ENVIROMENT = "test";
		public static final String IM_SDK_URI = "218.244.150.28:9092";
		/**///mvp测试环境配置结束	
		
		//[服务器开发环境]
		//**服务器开发环境配置开始
		public static final int PUB_PORT = 8081;
		public static final String URL_PUB = "http://120.26.141.214" + ":" + PUB_PORT+"/yiyi";//服务器地址
		public static final String URL_ZXING = "http://120.26.141.214:8081/yiyi";//生成二维码的地址
		public static final boolean DO_NOT_VERIFY_CERTIFICATE = true; //是否"不去"验证证书的合法性
		public static final boolean PRODUCTION_ENVIRONMENT = false;//是否是生产环境
		public static final boolean DEBUG_MODE = true;
		public static final String IM_ENVIROMENT = "development";
		public static final String IM_SDK_URI = "218.244.150.28:9092";
		/**///服务器开发环境配置结束	
		
		//[客户端开发环境]
		/**客户端开发环境配置开始
		public static final int PUB_PORT = 8543;
		public static final String URL_PUB = "https://115.29.229.128" + ":" + PUB_PORT+"/yiyi";
		public static final String URL_ZXING = "http://115.29.229.128:8180/yiyi";//生成二维码的地址
		public static final boolean DO_NOT_VERIFY_CERTIFICATE = true; //是否"不去"验证证书的合法性
		public static final boolean PRODUCTION_ENVIRONMENT = false;//是否是生产环境
		public static final boolean DEBUG_MODE = true;
		public static final String IM_ENVIROMENT = "development";
		public static final String IM_SDK_URI = "218.244.150.28:9092";
		
		//[mvp DEMO环境]
		/**mvp DEMO环境置开始
		public static final int PUB_PORT = 443;
		public static final String URL_PUB = "https://120.26.107.4" + ":" + PUB_PORT+"/yiyi";//服务器地址 https://115.29.239.19
		public static final String URL_ZXING = "https://120.26.107.4:443/yiyi";//生成二维码的地址
		public static final boolean DO_NOT_VERIFY_CERTIFICATE = true; //是否"不去"验证证书的合法性
		public static final boolean PRODUCTION_ENVIRONMENT = false;//是否是生产环境
		public static final boolean DEBUG_MODE = true;
		/**///mvp DEMO环境配置结束
	}
	
	/**
	 * 得到申请好友的接口<br/>
	 * 客户端扫描邀请好友二维码时转为申请该用户为好友<br/>
	 * @return
	 */
	public static String getUserURL(){
		return Conn.URL_PUB+"/users/search_by_userid.do";
	}
	
	/**
	 * 得到邀请好友的接口，用于生成二维码
	 * @return
	 */
	public static String getInvitationURL(){
		return Conn.URL_PUB+"/users/get_invitation.do";//Conn.URL_ZXING
	}
	
	/**
	 * 图片下载url，服务器跳转到阿里云
	 * @return
	 */
	public static String getImageURL(){
		return Conn.URL_PUB+"/image/view.do";
//		return "http://115.29.229.128:8080/yiyi/image/view.do";
	}
	
	/**
	 * 得到下载安卓安卓包的URL
	 * @param type 1:行医助手_android  2:行医助手_ios <br/>3:健康助手_android  4:健康助手_ios
	 * @return 安装包的下载地址
	 */
//	public static String getDownLoadURL(int type){
//		switch (type) {
//		case Constants.CLIENT_DOCTOR_IOS:
//			return Conn.URL_PUB+"/DocPlus_android_0309.apk";
//		case Constants.CLIENT_HEALTH_ANDORID:
//			return Conn.URL_PUB+"/DocPlus_android_0309.apk";
//		case Constants.CLIENT_HEALTH_IOS:
//			return Conn.URL_PUB+"/DocPlus_android_0309.apk";
//		case Constants.CLIENT_DOCTOR_ANDORID:
//		default:
//			return Conn.URL_PUB+"/DocPlus_android_0309.apk";
//		}
//	}
	
	/**
	 * 得到分享时的图片icon的地址
	 */
	public static String getShareIconURL(){
		return "http://f.picphotos.baidu.com/album/s%3D740%3Bq%3D90/sign=08e12c5eb6fb43161e1f787e109f371e/32fa828ba61ea8d3c8933891930a304e241f58f5.jpg";
	}
	
	/**
	 * 得到可视化数据，地图分布类型的URL
	 * @return
	 */
	public static String getVasualMapURL(){
		return Conn.URL_PUB+"/map.jsp";
	}
	
	/**
	 * 得到可视化数据，数据分析的URL
	 * @return
	 */
	public static String getVasualDataURL(){
		return Conn.URL_PUB+"/dataZoom.jsp";
	}
}
