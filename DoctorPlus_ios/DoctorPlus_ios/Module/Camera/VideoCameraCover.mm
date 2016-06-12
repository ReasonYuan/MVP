//
//  AidView.m
//  OpencvTest
//
//  Created by 廖敏 on 15/7/7.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "VideoCameraCover.h"
#import "java/lang/system.h"
#define CACHE_FRAME 5
#define SHAEAR_COUNT 10


static int frameCached = 0;

@interface VideoCameraCover ()
{
    long long int lastShearTime;
}
@end

@implementation VideoCameraCover

-(void)setLines:(std::vector<cv::Vec4i>)line
{
    bool update = true;
    if(line.size() > 0 ){
        frameCached = 0;
    }else{
        update = false;
        frameCached ++;
    }
    if(frameCached > CACHE_FRAME){
        update = true;
    }
    
    if(update){
        mLines = line;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        mColor = [UIColor colorWithRed:50/255.f green:0/255.f blue:150/255.f alpha:0.3];
        wScale = screenSize.width / 288.f;
        hScale = screenSize.height / 352.f;
//        [self setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.1]];
        self.userInteractionEnabled = NO;
        [FQBaseViewController addChildViewFullInParent:[[NSBundle mainBundle] loadNibNamed:@"VideoCameraCover" owner:self options:nil][0] parent:self ];
       
    }
    return self;
}


-(BOOL)inCD{
    long long int now = [JavaLangSystem currentTimeMillis];
    if(now - lastShearTime <= 3000){
        arcLengths.clear();
        return YES;
    }
    return NO;
}

-(BOOL)canShear
{
    if([self inCD]) return NO;
    if(arcLengths.size() == SHAEAR_COUNT){
        auto it = arcLengths.begin();
        float avg = 0;
        float sum = 0;
        while (it != arcLengths.end()) {
            sum += *it;
            it++;
        }
        avg = sum / (float)arcLengths.size() ;
        it = arcLengths.begin();
        while (it != arcLengths.end()) {
            if(fabs(*it - avg) > 50) return NO;
            it++;
        }
        arcLengths.clear();
        lastShearTime = [JavaLangSystem currentTimeMillis];
        return YES;
    }
    return NO;
}



-(void)setPoints:(std::vector<cv::Point2f>)points Larged:(BOOL)isLarged arcLength:(CGFloat)lenth
{
    mPoints = points;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(mPoints.size() != 4){
            self.tips.text = @"";
        }else{
            if(!isLarged){
//                self.tips.text = @"亲，边框太小，近一点！";
                arcLengths.clear();
                mPoints.clear();
            }else{
                arcLengths.push_back(lenth);
                if(arcLengths.size() > SHAEAR_COUNT){
                    arcLengths.erase(arcLengths.begin());
                }
                self.tips.text = @"";
            }
        }

        [self setNeedsDisplay];
    });
}

cv::Point2f findNext(cv::Point& lastPoint,std::vector<cv::Point2f>& points,bool vertical){
    cv::Point2f tmp(0,0);
    if(points.size() > 0){
        float dis = 999999;
        auto it = points.begin();
        while (it != points.end()) {
            if(vertical){
                float tmpDis = abs((*it).x - lastPoint.x);
                if(tmpDis < dis){
                    dis = tmpDis;
                    tmp = *it;
                }
            }else{
                float tmpDis = abs((*it).y - lastPoint.y);
                if(tmpDis < dis){
                    dis = tmpDis;
                    tmp = *it;
                }
            }
            it++;
        }
        it = points.begin();
        while (it != points.end()) {
            if(*it == tmp){
                points.erase(it);
                break;
            }
            it++;
        }
    }
    return tmp;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if([self inCD]) mPoints.clear();
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1, 00, 0, 1);//线条颜色
    for (int i = 0; i < mLines.size(); i++)
    {
        cv::Vec4i line = mLines[i];
        CGContextMoveToPoint(context, line[0]*wScale, line[1]*hScale);
        CGContextAddLineToPoint(context, line[2]*wScale,line[3]*hScale);
        
    }
    CGContextStrokePath(context);

    CGSize viewSize = self.frame.size;
    CGFloat scaleX = viewSize.width / _calculateImageSize.width;
    CGFloat scaleY = viewSize.height / _calculateImageSize.height;
    std::vector<cv::Point2f> tmpPoints = mPoints;
    if(mPoints.size() == 4){
        UIBezierPath *path = [UIBezierPath bezierPath];
        cv::Point point = mPoints[0];
        cv::Point pointZero(0,0);
        auto ite = tmpPoints.begin();
        tmpPoints.erase(ite);
        CGPoint tmpPoint = CGPointMake(point.x*scaleX,point.y*scaleY ); //point in screen
        [path moveToPoint:tmpPoint];
        bool isVertical = true;
        while ((point= findNext(point, tmpPoints, !isVertical))!= pointZero) {
            isVertical = !isVertical;
            tmpPoint = CGPointMake(point.x*scaleX, point.y*scaleY);
            [path addLineToPoint:tmpPoint];
        }
        tmpPoint = CGPointMake(mPoints[0].x*scaleX, mPoints[0].y*scaleY);
        [path addLineToPoint:tmpPoint];
        
        // 设置描边宽度（为了让描边看上去更清楚）
        [path setLineWidth:5.0];
        //设置颜色（颜色设置也可以放在最上面，只要在绘制前都可以）
        [mColor setStroke];
        [mColor setFill];
        // 描边和填充
        [path stroke];
        [path fill];
    }else{
        
    }
}



@end
