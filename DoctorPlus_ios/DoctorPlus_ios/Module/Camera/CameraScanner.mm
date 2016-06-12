//
//  Scanner.cpp
//  OpencvTest
//
//  Created by 廖敏 on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#include "CameraScanner.h"
#include <algorithm>
#include <string>
#include <vector>
using namespace cv;
using namespace std;


// 仿照matlab，自适应求高低两个门限
void _AdaptiveFindThreshold(CvMat *dx, CvMat *dy, double *low, double *high)
{
    CvSize size;
    IplImage *imge=0;
    int i,j;
    CvHistogram *hist;
    int hist_size = 255;
    float range_0[]={0,256};
    float* ranges[] = { range_0 };
    double PercentOfPixelsNotEdges = 0.7;
    size = cvGetSize(dx);
    imge = cvCreateImage(size, IPL_DEPTH_32F, 1);
    // 计算边缘的强度, 并存于图像中
    float maxv = 0;
    for(i = 0; i < size.height; i++ )
    {
        const short* _dx = (short*)(dx->data.ptr + dx->step*i);
        const short* _dy = (short*)(dy->data.ptr + dy->step*i);
        float* _image = (float *)(imge->imageData + imge->widthStep*i);
        for(j = 0; j < size.width; j++)
        {
            _image[j] = (float)(abs(_dx[j]) + abs(_dy[j]));
            maxv = maxv < _image[j] ? _image[j]: maxv;
            
        }
    }
    if(maxv == 0){
        *high = 0;
        *low = 0;
        cvReleaseImage( &imge );
        return;
    }
    
    // 计算直方图
    range_0[1] = maxv;
    hist_size = (int)(hist_size > maxv ? maxv:hist_size);
    hist = cvCreateHist(1, &hist_size, CV_HIST_ARRAY, ranges, 1);
    cvCalcHist( &imge, hist, 0, NULL );
    int total = (int)(size.height * size.width * PercentOfPixelsNotEdges);
    float sum=0;
    int icount = hist->mat.dim[0].size;
    
    float *h = (float*)cvPtr1D( hist->bins, 0 );
    for(i = 0; i < icount; i++)
    {
        sum += h[i];
        if( sum > total )
            break;
    }
    // 计算高低门限
    *high = (i+1) * maxv / hist_size ;
    *low = *high * 0.4;
    cvReleaseImage( &imge );
    cvReleaseHist(&hist);
}

void AdaptiveFindThreshold(cv::Mat& src, double *low, double *high, int aperture_size=3)
{
    const int cn = src.channels();
    cv::Mat dx(src.rows, src.cols, CV_16SC(cn));
    cv::Mat dy(src.rows, src.cols, CV_16SC(cn));
    
    cv::Sobel(src, dx, CV_16S, 1, 0, aperture_size, 1, 0, cv::BORDER_ISOLATED);
    cv::Sobel(src, dy, CV_16S, 0, 1, aperture_size, 1, 0, cv::BORDER_ISOLATED);
    
    CvMat _dx = dx, _dy = dy;
    _AdaptiveFindThreshold(&_dx, &_dy, low, high);
    
}

double angle( cv::Point2f pt1, cv::Point2f pt2, cv::Point2f pt0 )
{
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

static CIDetector *detector = nil;

void CameraScanner::findLargeSquare(UIImage* image, std::vector<cv::Point>& outSq)
{
    if( !image  || !(ISLARGETHANIOS8)){
        return;
    }
    @try {
        if(!detector) detector =  detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow,CIDetectorTracking : @(YES)}];;
        CIImage* ciimage = [CIImage imageWithCGImage:image.CGImage];
        NSArray* rectangles = [detector featuresInImage:ciimage];
        if (![rectangles count]) return;
        float halfPerimiterValue = 0;
        CIRectangleFeature *biggestRectangle = [rectangles firstObject];
        for (CIRectangleFeature *rect in rectangles)
        {
            CGPoint p1 = rect.topLeft;
            CGPoint p2 = rect.topRight;
            CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
            
            CGPoint p3 = rect.topLeft;
            CGPoint p4 = rect.bottomLeft;
            CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
            
            CGFloat currentHalfPerimiterValue = height + width;
            
            if (halfPerimiterValue < currentHalfPerimiterValue)
            {
                halfPerimiterValue = currentHalfPerimiterValue;
                biggestRectangle = rect;
            }
        }
        CGFloat heigth = image.size.height;
        outSq.clear();
        outSq.push_back(cv::Point(biggestRectangle.topLeft.x,heigth - biggestRectangle.topLeft.y));
        outSq.push_back(cv::Point(biggestRectangle.topRight.x,heigth - biggestRectangle.topRight.y));
        outSq.push_back(cv::Point(biggestRectangle.bottomLeft.x,heigth - biggestRectangle.bottomLeft.y));
        outSq.push_back(cv::Point(biggestRectangle.bottomRight.x,heigth - biggestRectangle.bottomRight.y));

    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
   
}

void find_largest_square(const std::vector<std::vector<cv::Point> >& squares, std::vector<cv::Point>& biggest_square)
{
    if (!squares.size())
    {
        // no squares detected
        return;
    }
    
    int max_width = 0;
    int max_height = 0;
    int max_square_idx = 0;
    
    for (size_t i = 0; i < squares.size(); i++)
    {
        // Convert a set of 4 unordered Points into a meaningful cv::Rect structure.
        cv::Rect rectangle = boundingRect(cv::Mat(squares[i]));
        
        //        cout << "find_largest_square: #" << i << " rectangle x:" << rectangle.x << " y:" << rectangle.y << " " << rectangle.width << "x" << rectangle.height << endl;
        
        // Store the index position of the biggest square found
        if ((rectangle.width >= max_width) && (rectangle.height >= max_height))
        {
            max_width = rectangle.width;
            max_height = rectangle.height;
            max_square_idx = (int)i;
        }
    }
    
    biggest_square = squares[max_square_idx];
}

// http://stackoverflow.com/questions/8667818/opencv-c-obj-c-detecting-a-sheet-of-paper-square-detection
void CameraScanner::findLargeSquare(cv::Mat &image, std::vector<cv::Point> &outSq)
{
    
    std::vector<std::vector<cv::Point>> squares;
    // blur will enhance edge detection
    
    cv::Mat blurred(image);
    //    medianBlur(image, blurred, 9);
    GaussianBlur(image, blurred, cvSize(11,11), 0);//change from median blur to gaussian for more accuracy of square detection
    
    cv::Mat gray0(blurred.size(), CV_8U), gray;
    std::vector<std::vector<cv::Point> > contours;
    
    // find squares in every color plane of the image
    for (int c = 0; c < 3; c++)
    {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        
        // try several threshold levels
        const int threshold_level = 2;
        for (int l = 0; l < threshold_level; l++)
        {
            // Use Canny instead of zero threshold level!
            // Canny helps to catch squares with gradient shading
            if (l == 0)
            {
//                double low,high;
//                AdaptiveFindThreshold(gray0,&low,&high);
                Canny(gray0, gray, 10, 20, 3); //
                //                Canny(gray0, gray, 0, 50, 5);
                
                // Dilate helps to remove potential holes between edge segments
                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else
            {
                gray = gray0 >= (l+1) * 255 / threshold_level;
            }
            
            // Find contours and store them in a list
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            std::vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++)
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                if (approx.size() == 4 &&
                    fabs(contourArea(cv::Mat(approx))) > 6000 &&
                    isContourConvex(cv::Mat(approx)))
                {
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++)
                    {
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.3)
                        squares.push_back(approx);
                }
            }
        }
    }
    find_largest_square(squares, outSq);
}

 BOOL CameraScanner::isSquire(NSArray* points)
{
    if(points.count != 4)return NO;
    std::vector<cv::Point> approx;
    for (NSValue* point in points) {
        CGPoint cgpoint = point.CGPointValue;
        approx.push_back(cv::Point(cgpoint.x,cgpoint.y));
    }
    for (int i = 2 ; i < 5; i++)
    {
        double cosine = fabs(angle(approx[i%4], approx[i-2], approx[i-1]));
        if(cosine > 0.4) return NO;
    }
    return YES;
}