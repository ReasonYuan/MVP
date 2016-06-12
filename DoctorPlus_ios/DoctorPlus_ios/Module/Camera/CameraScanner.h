//
//  Scanner.h
//  OpencvTest
//
//  Created by 廖敏 on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#ifndef __OpencvTest__Scanner__
#define __OpencvTest__Scanner__

//#define ISLARGETHANIOS8 [[[UIDevice currentDevice] systemVersion] floatValue]>=8
#define ISLARGETHANIOS8 NO

#import <opencv2/opencv.hpp>
namespace cv{

class CameraScanner {
public:
    static void findLargeSquare(cv::Mat& image, std::vector<cv::Point>& outSq);
    static void findLargeSquare(UIImage* image, std::vector<cv::Point>& outSq) NS_AVAILABLE_IOS(8_0);
    static BOOL isSquire(NSArray* points);
};
}
#endif /* defined(__OpencvTest__Scanner__) */
