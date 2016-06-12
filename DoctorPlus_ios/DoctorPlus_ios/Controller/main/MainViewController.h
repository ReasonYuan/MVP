//
//  MainViewController.h
//  DoctorPlus_ios
//
//  Created by reason on 15-7-14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITabBarController
{
}


/**
 *初始化tarbarItem
 */
-(void) setViewController:(UIViewController*)controller WithTabTitle:(NSString*)title imgName:(NSString*)imageName selectImgName:(NSString*)selectImgName;

// 给中间按钮设置样式
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;

/**
 *给tabbarItem的按钮设置消息条数
 */
-(void)setMsgNunber:(int)number ByIndex:(int)index;

@end
