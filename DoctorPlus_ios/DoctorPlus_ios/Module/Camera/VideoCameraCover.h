//
//  AidView.h
//  OpencvTest
//
//  Created by 廖敏 on 15/7/7.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

@interface VideoCameraCover : UIView
{
    std::vector<cv::Vec4i> mLines;
    CGFloat wScale,hScale;
    std::vector<cv::Point2f> mPoints;
    UIColor* mColor;
    std::vector<CGFloat> arcLengths;
}


/**
 *points      矩形的四个点
 *isLarged    矩形的大小是否满足要求
 *arcLength   矩形的周长
 */
-(void)setPoints:(std::vector<cv::Point2f>)points Larged:(BOOL)isLarged arcLength:(CGFloat)lenth;

-(void)setLines:(std::vector<cv::Vec4i>)line;

-(BOOL)canShear;

@property (weak, nonatomic) IBOutlet UILabel *tips;

@property CGSize calculateImageSize; //进行运算时的图片大小

@property CGSize iamgeSize; //图片大小

@property (assign, nonatomic) BOOL  calculateX; //根据width计算

@end
