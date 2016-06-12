//
//  Tools.h
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+Thumbnail.h"
#import "Platform.h"
#import "java/util/ArrayList.h"

@interface Tools : NSObject

/**
 *  把任务post到其他线程
 *
 *  @param run      处理任务
 *  @param callback 主线程度的回调
 */
+(void)runOnOtherThread:(id (^)(void))run callback:(void (^)(id))callback;

/**
 *  任务延迟执行
 *
 *  @param run   处理任务
 *  @param delay 延迟时间
 */
+(void)Post:(void (^)())run Delay:(NSTimeInterval)delay;

/**
 *  更具rect大小计算出支持最大的字体dax
 *
 *  @param rect 矩形大小
 *
 *  @return font大小
 */
+(CGFloat)getMaxFontSizeInRect:(CGRect)rect;

/**
 *  创建一张.9图片
 *
 *  @param image  原图片
 *  @param left   拉伸区域距左边的距离
 *  @param right  拉伸区域距右边的距离
 *  @param top    拉伸区域距上边的距离
 *  @param bottom 拉伸区域距下边的距离
 *
 *  @return 拉伸后的图片
 */
+(UIImage*)createNinePathImageForImage:(UIImage*)image LeftMargin:(CGFloat)left RightMargin:(CGFloat)right TopMargin:(CGFloat)top BottomMargin:(CGFloat)bottom;

/**
 *  @param text 所要计算的文字
 *  @param font 所要计算的font
 *
 *  @return 计算font大小的字体所占的大小
 */
+(CGSize)measureText:(NSString*)text Font:(UIFont*)font;

+(CGFloat)measureText:(NSString*)text font:(UIFont*)font width:(CGFloat)width;

/**
 *  缓存object到内存
 *
 *  @param obj 被缓存的Object(弱引用)
 *  @param key key (强引用)
 */
+(void)cacheObject:(id)obj ForKey:(id)key;

/**
 *  从缓存中获取object,如果缓存中没有，则换回nil
 *
 *  @param key key
 *
 *  @return object or nil
 */
+(id)getObjectForKey:(id)key;

/**
 *
 *  @return 当前网络是否连接
 */
+(BOOL)isNetWorkConnect;

/**
 *
 *  @return wifi是否连接
 */
+(BOOL)isWifiConnect;

/**
 *  把java Array 转换成oc 的 Array
 *
 *  @param javaArray
 *
 *  @return oc 的 Array
 */
+(NSArray*)toNSarray:(JavaUtilArrayList*)javaArray;

/**
 *保存图片到本地[ComFqHalcyonExtendFilesystemFileSystem getInstance] getRecordCachePath]
 *@retturn 文件名
 */
+(NSString*)saveImage:(UIImage*)image;

//得到当前的UIViewController
+(UIViewController*)getCurrentViewController:(UIView*)soureView;

//得到当前的UIViewController
+(UIViewController*)getCurrentViewController;

+(BOOL)getProductionEnvironment:(int)production;

//+(BOOL)

/**
 * 版本的发布渠道
 */
+(NSString*)getChannel;

/**
 * 获得应用的版本号
 */
+(NSString*)getAppVersion;

/**
 *  颜色转化 “#ffffff” 转化为uicolor
 *
 *  @param stringToConvert
 *
 *  @return
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

+ (UIImage *) image:(UIImage*)image withTintColor:(UIColor *)tintColor;

+ (UIImage *) image:(UIImage*)image withGradientTintColor:(UIColor *)tintColor;

+ (UIImage *) image:(UIImage*)image withTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;

@end
