//
//  PracticeLoadingView.m
//  DoctorPlus_ios
//
//  Created by reason on 15-7-21.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "PracticeLoadingView.h"

@implementation PracticeLoadingView
{
    UIView* zheView;
    UIImageView* loadingImgeView;
    int width;
    int height;
    int top;
    int left;
    BOOL isShowInWindow;
}


-(id)initWithFrame:(CGRect)frame{
    //因为对于progressdialog边框是圆角，所以各面有5dp的外补丁
    frame = CGRectMake(5, 5, frame.size.width-10, frame.size.height-10);
    self = [super initWithFrame:frame];
    
    if(self){
        [self setBackgroundColor:[UIColor whiteColor]];
        loadingImgeView = [[UIImageView alloc] init];
        [loadingImgeView setImage:[UIImage imageNamed:@"loading"]];
        
        int showW = frame.size.width;//[[UIScreen mainScreen] bounds].size.width;
        int showH = frame.size.height;//[[UIScreen mainScreen] bounds].size.height;
        
        width = showW/3.0;
        height = 147.0*width/350.0+2;//+2的偏移量
        left = (showW-width)/2;
        top = (showH-height)/2;//3
        
        
        loadingImgeView.frame = CGRectMake(left, top, width, height);
        [self addSubview:loadingImgeView];
        
        //遮罩层
        zheView = [[UIView alloc] init];
        [zheView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:zheView];
    }
    return self;
}


/**
 *初始化等待界面的控件
 */
//-(void)initView{
//    [self setBackgroundColor:[UIColor whiteColor]];
//    loadingImgeView = [[UIImageView alloc] init];
//    [loadingImgeView setImage:[UIImage imageNamed:@"loading"]];
//    
//    int showW = [[UIScreen mainScreen] bounds].size.width;
//    int showH = [[UIScreen mainScreen] bounds].size.height;
//    
//    width = showW/3.0;
//    height = 147.0*width/350.0;
//    left = (showW-width)/2;
//    top = (showH-height-40)/2;
//    
//    
//    loadingImgeView.frame = CGRectMake(left, top, width, height);
//    [self addSubview:loadingImgeView];
//    
//    //遮罩层
//    zheView = [[UIView alloc] initWithFrame:CGRectMake(left-5, top, width+5, height)];
//    [zheView setBackgroundColor:[UIColor whiteColor]];
//    [self addSubview:zheView];
//}

/**
 *当等待页面加入到父控件时
 */

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if(newSuperview){
        isShowInWindow = YES;
        [self startAnimation];
    }else{
        isShowInWindow = NO;
    }
}

-(void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if(!newWindow){
        isShowInWindow = NO;
    }
}

/**
 *开始动画
 */
-(void)startAnimation{
    zheView.frame = CGRectMake(left-5, top, width+10, height);
    [UIView beginAnimations:@"ScareAnimation" context:NULL];
    [UIView setAnimationDuration:1.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    if(isShowInWindow)[UIView setAnimationDidStopSelector:@selector(secondAnimation)];
//    [UIView setAnimationRepeatAutoreverses:YES];
//    [UIView setAnimationRepeatCount:300];
    
    CGRect frame = zheView.frame;
    frame.origin.x = frame.origin.x+frame.size.width;
    frame.size.width = 0;
    zheView.frame = frame;
    
    [UIView commitAnimations];
}

-(void)secondAnimation{
    zheView.frame = CGRectMake(left-5, top, 0, height);
    [UIView beginAnimations:@"SecondAnimation" context:NULL];
    [UIView setAnimationDuration:1.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    if(isShowInWindow)[UIView setAnimationDidStopSelector:@selector(startAnimation)];

    zheView.frame = CGRectMake(left-5, top, width+10, height);;
    
    [UIView commitAnimations];

}


//    [UIView animateWithDuration:2 delay:0.f options:(UIViewAnimationOptions)UIViewAnimationCurveEaseIn animations:^(void)
//     {
//         self.frame = CGRectMake(0, 0, 0, self.frame.size.height);
//     } completion:^(BOOL finished){
//     }];

@end
