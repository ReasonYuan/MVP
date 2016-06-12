//
//  ChartView.m
//  TestProject
//
//  Created by 廖敏 on 15/7/15.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "ChartView.h"
#import "Tools.h"
#import "EGORefreshTableHeaderView.h"

//#define USER_SCROLL  YES
#define USER_SCROLL  FALSE

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define TITLE_HEIGHT  20
#define PADDING_TOP  35

@interface OverlayView : UIImageView
{
@public
    UILabel* textLable;
}

-(void)setText:(NSString*)text;

@end

/**
 *chart 的点
 */
@interface Point2F : NSObject

+(instancetype)CreateWithX:(CGFloat)xValue andY:(CGFloat)yValue;

@property (assign,nonatomic) CGFloat x;

@property (assign,nonatomic) CGFloat y;

@property (assign,nonatomic) CGFloat xInView;

@property (assign,nonatomic) CGFloat yInView;

@property (assign,nonatomic) NSInteger index;

@property (assign,nonatomic) CGFloat cellWidth;

@end

@interface ChartView()<UIScrollViewDelegate,EGORefreshTableHeaderDelegate>
{
@public
    CGFloat scale;//比例，数据*比例=当前view的坐标点
    UIScrollView* scrollView;
    NSMutableArray* points;
    NSMutableArray* tmpArray;
    OverlayView* overlayView;
    EGORefreshTableHeaderView* _PullRightRefreshView;
    EGORefreshTableHeaderView* _PullLeftRefreshView;
    NSInteger firstIndex;
    BOOL onRefreshing;
    CGFloat padingBottom;
    UIActivityIndicatorView* indicatorView;
    BOOL noChange;
}
@end

@implementation ChartView
@synthesize chartDataSource;
@synthesize chartDelegate;
@synthesize strokeColor;
@synthesize titleFont;

-(id)init{
    self = [super init];
    if(self){
        [self onCreate];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self onCreate];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self onCreate];
    }
    return self;
}

-(void)showLoading
{
    indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:self.frame];
    indicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhiteLarge;
    [indicatorView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.3f]];
    [FQBaseViewController addChildViewFullInParent:indicatorView parent:self];
    [indicatorView startAnimating];
}

-(void)onCreate
{
    _isShowUnit = YES;
    _lineColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.6f];
    _textColor = [UIColor whiteColor];
    scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    scrollView.delegate = self;
    onRefreshing = NO;
    [self addSubview:scrollView];
    titleFont = [UIFont systemFontOfSize:12];
    overlayView = [[OverlayView alloc] initWithFrame:CGRectMake(0, 0, 50, PADDING_TOP)];
    scale = 1;
    
    points = [[NSMutableArray alloc] init];
    tmpArray = [[NSMutableArray alloc] init];
    strokeColor = [UIColor orangeColor];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouch:)];
    gesture.numberOfTouchesRequired = 1;
    gesture.numberOfTapsRequired = 1;
    [scrollView addGestureRecognizer:gesture];
    if(USER_SCROLL){
        _PullRightRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:scrollView orientation:EGOPullOrientationRight];
        _PullLeftRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:scrollView orientation:EGOPullOrientationLeft];
        _PullRightRefreshView.delegate = self;
        _PullLeftRefreshView.delegate = self;
        _PullLeftRefreshView.hidden = YES;
        _PullRightRefreshView.hidden = YES;
        scrollView.scrollEnabled = YES;
    }else{
        scrollView.scrollEnabled = NO;
        UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [scrollView addGestureRecognizer:swipeGesture];
        swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [scrollView addGestureRecognizer:swipeGesture];
    }
    firstIndex = -1;
}

-(void)onSwipe:(UISwipeGestureRecognizer*)gesture
{
    if([self.chartDelegate respondsToSelector:@selector(chartView:onRefresh:)]){
        if(gesture.direction == UISwipeGestureRecognizerDirectionLeft){
            if([self.chartDelegate chartView:self canRefresh:DirectionRight]) [self.chartDelegate chartView:self onRefresh:DirectionRight];
        }else if(gesture.direction == UISwipeGestureRecognizerDirectionRight){
            if([self.chartDelegate chartView:self canRefresh:DirectionLeft])[self.chartDelegate chartView:self onRefresh:DirectionLeft];
        }
        onRefreshing = YES;
    }
}


-(NSInteger)cellCountOnePage
{
    if(!isPad){
        return 5;
    }else{
        CGFloat width = [UIScreen mainScreen].applicationFrame.size.width;
        return width / 60;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_PullRightRefreshView egoRefreshScrollViewDidScroll:scrollView];
    [_PullLeftRefreshView egoRefreshScrollViewDidScroll:scrollView];
    [self setNeedsDisplay];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_PullRightRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
    [_PullLeftRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

-(void)onTouch:(UITapGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:self];
    CGSize frameSzie = self.frame.size;
    if(self.chartDataSource && points.count > 0 && location.y < frameSzie.height - TITLE_HEIGHT){
        for (NSInteger i = 0; i < points.count; i++) {
            Point2F* point = [points objectAtIndex:i];
            CGFloat startX = [self xInView:point] - point.cellWidth/2.f;
            CGFloat endX = startX + point.cellWidth;
            if( startX <= location.x && endX > location.x){
                if(chartDelegate && [chartDelegate respondsToSelector:@selector(chartView:didClickedAtIndex:)]){
                    [chartDelegate chartView:self didClickedAtIndex:i];
                }
                if(self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(chartView:toastColor:)]){
                    [overlayView->textLable setTextColor:[self.chartDelegate chartView:self toastColor:i]];
                }if(self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(chartView:toastText:)]){
                    [overlayView setText:[self.chartDelegate chartView:self toastText:i]];
                }else{
                    [overlayView setText:[NSString stringWithFormat:_isShowUnit?@"%d份":@"%d",(int)[self.chartDataSource chartView:self dataForIndex:i]]];
                }
                CGSize overlaySzie = overlayView.frame.size;
                overlayView.frame = CGRectMake(point.x - overlaySzie.width/2.f , [self yInView:point]-overlaySzie.height, overlaySzie.width, overlaySzie.height);
                if(!overlayView.superview){
                    [scrollView addSubview:overlayView];
                }
                break;
            }
        }
    }
}

-(CGFloat)getCellWidth:(NSInteger) index
{
    if(chartDelegate && [chartDelegate respondsToSelector:@selector(chartView:cellWithForIndex:)]){
        return [chartDelegate chartView:self cellWithForIndex:index];
    }
    CGFloat width = [UIScreen mainScreen].applicationFrame.size.width;
    if(isPad) {
        int count = width / 60;
        return width / (CGFloat)count;
    };
    return width/5.f;
}


-(void)selected:(NSInteger)index
{
    CGSize frameSzie = self.frame.size;
    if(self.chartDataSource && points.count > 0 ){
        for (NSInteger i = 0; i < points.count; i++) {
            Point2F* point = [points objectAtIndex:i];
            CGFloat startX = [self xInView:point] - point.cellWidth/2.f;
            CGFloat endX = startX + point.cellWidth;
            if( index  == i){
                if(chartDelegate && [chartDelegate respondsToSelector:@selector(chartView:didClickedAtIndex:)]){
                    [chartDelegate chartView:self didClickedAtIndex:i];
                }
                if(self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(chartView:toastColor:)]){
                    [overlayView->textLable setTextColor:[self.chartDelegate chartView:self toastColor:i]];
                }if(self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(chartView:toastText:)]){
                    [overlayView setText:[self.chartDelegate chartView:self toastText:i]];
                }else{
                    [overlayView setText:[NSString stringWithFormat:_isShowUnit?@"%d份":@"%d",(int)[self.chartDataSource chartView:self dataForIndex:i]]];
                }
                CGSize overlaySzie = overlayView.frame.size;
                overlayView.frame = CGRectMake(point.x - overlaySzie.width/2.f , [self yInView:point]-overlaySzie.height, overlaySzie.width, overlaySzie.height);
                if(!overlayView.superview){
                    [scrollView addSubview:overlayView];
                }
                break;
            }
        }
    }
    
    
}

-(void)reloadData
{
    if(overlayView.superview){
        [overlayView removeFromSuperview];
    }
    firstIndex = -1;
    [self refresh];
}

-(void)setChartDataSource:(id<ChartViewDataSource>)dataSource
{
    chartDataSource = dataSource;
    [self refresh];
}

-(void)setStrokeColor:(UIColor *)color
{
    strokeColor = color;
    [self refresh];
}

-(void)setTitleFont:(UIFont *)font
{
    titleFont = font;
    [self refresh];
}

-(void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    [self refresh];
}

-(void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self refresh];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self refresh];
}

-(void)refresh
{
    [points removeAllObjects];
    if(self.chartDataSource && [self.chartDataSource respondsToSelector:@selector(numberOfCellInChartView:)]){
        NSInteger number = [self.chartDataSource numberOfCellInChartView:self];
        do{
            if(number ==0)break;
            scale = 1;
            noChange = NO;
            firstIndex = -1;
            padingBottom = 0;
            CGFloat maxValue = 3;
            CGFloat minValue = [chartDataSource chartView:self dataForIndex:0];
            for (int i = 0 ; i < [chartDataSource numberOfCellInChartView:self]; i++) {
                CGFloat value = [chartDataSource chartView:self dataForIndex:i];
                if(value > maxValue) maxValue = value;
                if(value < minValue) minValue = value;
            }
            if(minValue == maxValue) noChange = YES;
            if(minValue != 0) padingBottom = self.frame.size.height / 8.f;
            CGFloat sum = 0;
            for (int i = 0 ; i < [chartDataSource numberOfCellInChartView:self]; i++) {
                CGFloat cellWidth = [self getCellWidth:i];
                CGFloat value = [chartDataSource chartView:self dataForIndex:i];
                sum += cellWidth;
                Point2F* point = [Point2F CreateWithX:sum - cellWidth/2.f andY:value - minValue];
                point.cellWidth = cellWidth;
                [points addObject:point];
            }
            [scrollView setContentSize:CGSizeMake(sum, self.frame.size.height)];
            scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            CGFloat maxHeight = self.frame.size.height - TITLE_HEIGHT - PADDING_TOP - padingBottom;
            if(maxValue - minValue != 0)scale = maxHeight / (float)(maxValue - minValue);
        }while (false) ;
        [self setNeedsDisplay];
        if(USER_SCROLL){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [NSThread sleepForTimeInterval:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(points.count > 0 ){
                        _PullLeftRefreshView.hidden = NO;
                        _PullRightRefreshView.hidden = NO;
                    }else{
                        _PullLeftRefreshView.hidden = YES;
                        _PullRightRefreshView.hidden = YES;
                    }
                });
            });
            
        }
    }
}


-(CGFloat)yInView:(Point2F*)point
{
    
    CGFloat height = self.frame.size.height;
    if(noChange && [chartDataSource chartView:self dataForIndex:0] != 0) {
        point.yInView = height / 2;
        return point.yInView;
    }
    point.yInView = height - TITLE_HEIGHT - padingBottom - (point.y * scale) ;
    return  point.yInView;
}

-(CGFloat)xInView:(Point2F*)point
{
    point.xInView = point.x - scrollView.contentOffset.x;
    return   point.xInView;
}

-(void)moveToIndex:(NSInteger)index ChartViewAlignment:(ChartViewAlignment)alignment
{
    if(!USER_SCROLL) return;
    if(chartDataSource){
        CGFloat move = 0;
        CGFloat sum = 0;
        for (NSInteger i = 0 ; i < [chartDataSource numberOfCellInChartView:self]; i++) {
            if (i == index) {
                move = sum;
            }
            CGFloat cellWidth = [self getCellWidth:i];
            sum += cellWidth;
        }
        CGSize contentSize = CGSizeMake(sum, self.frame.size.height);
        CGSize frameSize = scrollView.frame.size;
        [scrollView setContentSize:contentSize];
        CGFloat max = contentSize.width - frameSize.width;
        switch (alignment) {
            case AlignmentLeft:
            {
                [scrollView setContentOffset:CGPointMake(MIN(move, max), 0) animated:NO];
                break;
            }
            case AlignmentCenter:
            {
                move += [self getCellWidth:index]/2.f;
                move -= frameSize.width/2.f;
                if(move < 0){
                    move = 0;
                }
                [scrollView setContentOffset:CGPointMake(MIN(move, max), 0) animated:NO];
                break;
            }
            case AlignmentRight:
            {
                move += [self getCellWidth:index];
                move -= frameSize.width;
                if(move < 0) move = 0;
                [scrollView setContentOffset:CGPointMake(MIN(move, max), 0) animated:NO];
                break;
            }
            default:
                break;
        }
    }
}


- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    if(self.chartDelegate){
        if(view == _PullLeftRefreshView){
            if([self.chartDelegate respondsToSelector:@selector(chartView:onRefresh:)]){
                [self.chartDelegate chartView:self onRefresh:DirectionRight];
            }
        }else if(view == _PullRightRefreshView){
            if([self.chartDelegate respondsToSelector:@selector(chartView:onRefresh:)]){
                [self.chartDelegate chartView:self onRefresh:DirectionLeft];
            }
        }
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
    if(self.chartDelegate){
        if(view == _PullLeftRefreshView){
            if([self.chartDelegate respondsToSelector:@selector(chartView:canRefresh:)]){
                BOOL  res = ![self.chartDelegate chartView:self canRefresh:DirectionRight];
                return res;
            }
        }else if(view == _PullRightRefreshView){
            if([self.chartDelegate respondsToSelector:@selector(chartView:canRefresh:)]){
                BOOL  res = ![self.chartDelegate chartView:self canRefresh:DirectionLeft];
                return res;
            }
        }
    }
    return YES;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];
}

-(void)refreshCompleted
{
    if(USER_SCROLL){
        [_PullRightRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:scrollView];
        [_PullLeftRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:scrollView];
    }else{
        onRefreshing = NO;
        if(indicatorView){
            [indicatorView removeFromSuperview];
            indicatorView = nil;
        }
    }
    
}

-(BOOL)isRefresh
{
    if(USER_SCROLL){
        return [_PullLeftRefreshView isLoading] || [_PullRightRefreshView isLoading];
    }
    return onRefreshing;
}


-(void)drawRect:(CGRect)rect
{
    if(points.count <= 0)return;
    @try {
        [tmpArray removeAllObjects];
        CGFloat r1,g1,b1,a1;
        CGFloat r,g,b,a;
        [strokeColor getRed:&r green:&g blue:&b alpha:&a];
        
        static CGFloat titleHeigth = TITLE_HEIGHT;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat startX = CGRectGetMinX(rect);
        CGFloat startY = CGRectGetMinY(rect);
        //    CGFloat endX = CGRectGetMaxX(rect);
        CGFloat endY = CGRectGetMaxY(rect) - titleHeigth;
        
        //第一步 画竖线和文字,圆点
        //    CGContextSetRGBStrokeColor(context, 1, 00, 0, 1);//线条颜色
        NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:self.titleFont, NSFontAttributeName,style, NSParagraphStyleAttributeName,_textColor, NSForegroundColorAttributeName,nil];
        [_lineColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
        CGContextSetRGBStrokeColor(context, r1, g1, b1, a1);
        CGContextSetLineWidth(context,  .4f);
        CGRect titleRect = CGRectMake(0, endY, 0, titleHeigth);
        NSInteger startIndex = -1;
        for (NSInteger i = 0; i < points.count; i++) {
            Point2F* point = [points objectAtIndex:i];
            int x = [self xInView:point];
            if(x >= 0 && x <= rect.size.width){
                if(startIndex == -1) startIndex = i;
                [tmpArray addObject:point];
                CGContextMoveToPoint(context, x, startY);
                CGContextAddLineToPoint(context, x, endY);
                point.index = i;
                [self yInView:point];
                
            }
        }
        if( self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(chartView:firstCellShowIndex:)] && startIndex != firstIndex){
            firstIndex = startIndex;
            [self.chartDelegate chartView:self firstCellShowIndex:firstIndex];
        }
        
        Point2F* firstPoint = [tmpArray objectAtIndex:0];
        Point2F* lastPoint = [tmpArray objectAtIndex:tmpArray.count -1];
        
        CGContextStrokePath(context);
        
        for (Point2F* point in tmpArray) {
            CGFloat x = point.xInView;
            titleRect.origin.x = x - point.cellWidth/2.f;
            titleRect.size.width = point.cellWidth;
            [[chartDataSource chartView:self titleForCell:point.index] drawInRect:titleRect withAttributes:attributes];
        }
        CGContextStrokePath(context);
        
        
        NSMutableArray* tmp = [NSMutableArray arrayWithCapacity:1];
        Point2F* today = nil;
        [strokeColor set];
        for (Point2F* point in tmpArray) {
            CGFloat x = point.xInView;
            CGFloat y = point.yInView;
            if(self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(chartView:changeCicleColor:)]){
                if([self.chartDelegate chartView:self changeCicleColor:point.index]){
                    [tmp addObject:point];
                }
            }
            if([self.chartDelegate respondsToSelector:@selector(chartView:isTodayIndex:)]){
                if([self.chartDelegate chartView:self isTodayIndex:point.index]){
                    today = point;
                }
            }
            CGContextMoveToPoint(context, x, y);
            CGContextAddArc(context, x,  y, 3, 0, 2*M_PI, 0);
        }
        CGContextDrawPath(context, kCGPathFill);
        
        if(today){
            [strokeColor set];
            CGContextSetLineWidth(context,  2);
            //        CGContextMoveToPoint(context, today.xInView, today.yInView);
            CGContextAddArc(context, today.xInView, today.yInView, 6, 0, 2*M_PI, 0);
            CGContextDrawPath(context, kCGPathStroke);
            CGContextSetLineWidth(context,  .4f);
        }
        
        [strokeColor set];
        CGContextMoveToPoint(context, firstPoint.xInView, firstPoint.yInView);
        for (Point2F* point in tmpArray) {
            CGFloat x = point.xInView;
            CGFloat y = point.yInView;
            CGContextAddLineToPoint(context, x, y);
        }
        CGContextStrokePath(context);
        
        
        if([tmp count] > 0 && [self.chartDelegate respondsToSelector:@selector(chartViewCicleColor:)]){
            [[self.chartDelegate chartViewCicleColor:self] set];
            for (Point2F* point in tmp) {
                CGFloat x = point.xInView;
                CGFloat y = point.yInView;
                CGContextMoveToPoint(context, x, y);
                CGContextAddArc(context, x,  y, 3, 0, 2*M_PI, 0);
            }
            CGContextDrawPath(context, kCGPathFill);
        }
        
        
        //第二步 渐变色
        [strokeColor setStroke];
        CGContextSetLineWidth(context,  0);
        //reference http://stackoverflow.com/questions/2985359/how-to-fill-a-path-with-gradient-in-drawrect
        //    chartView.strokeColor
        
        CGFloat colors[] = {
            r,g,b,.6f,
            r,g,b,.15f,
        };
        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, nil, 2);
        CGColorSpaceRelease(baseSpace);
        CGContextSaveGState(context);
        
        CGMutablePathRef path = CGPathCreateMutable();
        if(startIndex > 0){
            firstPoint = [points objectAtIndex:startIndex-1];
            [self xInView:firstPoint];
            [self yInView:firstPoint];
        }
        
        CGPathMoveToPoint(path, &CGAffineTransformIdentity,firstPoint.xInView, endY);
        if(startIndex > 0){
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity , firstPoint.xInView, firstPoint.yInView);
        }
        Point2F* endPoint2f;
        for (NSInteger i = 0; i < tmpArray.count; i++) {
            Point2F* point = [tmpArray objectAtIndex:i];
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity , point.xInView, point.yInView);
            endPoint2f = point;
        }
        
        if(endPoint2f.index < points.count-1){
            endPoint2f = [points objectAtIndex:endPoint2f.index+1];
            [self xInView:endPoint2f];
            [self yInView:endPoint2f];
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity , endPoint2f.xInView, endPoint2f.yInView);
            lastPoint = endPoint2f;
        }
        
        CGPathAddLineToPoint(path, &CGAffineTransformIdentity , lastPoint.xInView , endY);
        
        CGPathCloseSubpath(path);
        CGContextAddPath(context, path);
        CGContextClip(context);
        
        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
        CGGradientRelease(gradient);
        CGContextRestoreGState(context);
        CGContextAddPath(context, path);
        CGPathRelease(path);
        
        [tmpArray removeAllObjects];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        [self setNeedsDisplay];
    }
    @finally {
        
    }
    
}


@end


@implementation Point2F

+(instancetype)CreateWithX:(CGFloat)xValue andY:(CGFloat)yValue
{
    Point2F* instance = [[Point2F alloc] init];
    instance.x = xValue;
    instance.y = yValue;
    return instance;
}

@end

@implementation OverlayView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.image = [UIImage imageNamed:@"pop_up_bg.png"];
        textLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 8)];
        textLable.textAlignment = NSTextAlignmentCenter;
        textLable.font = [UIFont systemFontOfSize:18];
        textLable.textColor = [UIColor whiteColor];
        [self addSubview:textLable];
    }
    return self;
}

-(void)setText:(NSString *)text
{
    textLable.text = text;
}

@end
