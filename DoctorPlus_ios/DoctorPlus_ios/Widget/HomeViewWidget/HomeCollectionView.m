//
//  HomeCollectionView.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "HomeCollectionView.h"
#import "math.h"
#import "DoctorPlus_ios-Swift.h"
#import "EGORefreshTableHeaderView.h"

//#define HOME_MONTH_HEIGHT [UIScreen mainScreen].bounds.size.height*50.F/480.F
#define MAXCOUNT          3
#define RADIUS            3
#define FONT_SIZE         11
#define UPDATE_DRAW       NO
#define LinearGradient_margin  5

@interface HomeLinearGradientView()
{
    NSArray* data;
    NSInteger maxCount;
    NSMutableArray* points;
    UIFont* textFont;
    CGFloat textHeight;
    CGFloat currentScrollX;
}

@end

@implementation HomeLinearGradientView

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

-(CGFloat)getItemWidth
{
    return [self.collectionView getItemWidth];
}

-(void)onScroll:(CGFloat)scrollX
{
    if(UPDATE_DRAW){
        CGFloat dis = scrollX - currentScrollX;
        CGFloat nextOrginX = self.frame.origin.x - dis;
        if( nextOrginX  <=   -self.collectionView.frame.size.width ){
            nextOrginX = 0;
            [self setNeedsDisplay];
        }
        currentScrollX = scrollX;
        self.frame = CGRectMake(nextOrginX, 0, self.frame.size.width, self.frame.size.height);
    }else{
        self.frame = CGRectMake(-scrollX, 0, self.frame.size.width, self.frame.size.height );
    }
    
}

-(void)setDailyRecData:(NSArray *)dataSet
{
    maxCount = 3;
    if(!points)points = [[NSMutableArray alloc] init];
    if(!textFont) {
        textFont = [UIFont systemFontOfSize:FONT_SIZE];
        textHeight = [@"0份记录" sizeWithAttributes:@{NSFontAttributeName:textFont}].height;
    }
    data = dataSet;
    if(data != nil){
        for (int i = 0; i < data.count -1; i++) {
            NSInteger tmp = [[data objectAtIndex:i] integerValue];
            if(tmp > maxCount ) {
                maxCount = tmp;
            }
        }
        self.frame = CGRectMake(self.frame.origin.x, 0, [self getItemWidth] * dataSet.count, self.collectionView.frame.size.height - [HomeCollectionView getMonthViewHeighet] - [self.collectionView getItemWidth] * 2  );
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            [self setNeedsDisplay];
//        });
        [self setNeedsDisplay];

    }
    
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (data == nil)return;
    [points removeAllObjects];
    CGRect realRect;
    if(UPDATE_DRAW){
        realRect = CGRectMake(rect.origin.x+currentScrollX, rect.origin.y, rect.size.width, rect.size.height);
    }else{
        realRect = rect;
    }
    CGFloat width = realRect.size.width;
    CGFloat heigth = realRect.size.height;
    CGFloat orginX = realRect.origin.x;
    CGFloat itemWidth = [self getItemWidth];
    CGFloat halfItemWidth = itemWidth/2.f;
    CGFloat baseLine =  heigth - LinearGradient_margin; // -headerViewHeigth - 1/2 itemHeigth
    CGFloat increment = (baseLine - halfItemWidth) / maxCount;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 0);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetRGBStrokeColor(ctx,98/255.0,192/255.0,180/255.0,1);
    UIColor* color = [UIColor colorWithRed:98/255.0 green:192/255.0 blue:180/255.0 alpha:1];
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    
    
    NSInteger startDrawIndex = orginX / itemWidth - 1;
    if(startDrawIndex < 0) startDrawIndex = 0;
    NSInteger endDrawIndex = (orginX + width) / itemWidth +1;
    if(endDrawIndex > data.count - 1) endDrawIndex = data.count - 1;
    NSInteger lastCount = 0;
    void (^addPoint)( NSInteger,NSInteger ) = ^(NSInteger position, NSInteger tmpCount)
    {
        if (UPDATE_DRAW) {
            [points addObject:[[VPoint alloc] initWidthX:position*itemWidth + halfItemWidth - currentScrollX Y:baseLine - increment * tmpCount RecordCount:tmpCount TextfffsetY:textHeight/2.f]];
        }else{
            [points addObject:[[VPoint alloc] initWidthX:position*itemWidth + halfItemWidth Y:baseLine - increment * tmpCount RecordCount:tmpCount TextfffsetY:textHeight/2.f]];
        }
        
    };
    for (NSInteger i = startDrawIndex; i <= endDrawIndex; i++) {
        NSInteger tmpCount = [[data objectAtIndex:i] integerValue];
        if( lastCount != tmpCount || (i ==  startDrawIndex || i == endDrawIndex) ){
            if(i>0 && i!= endDrawIndex){
                addPoint(i-1,[[data objectAtIndex:i-1] integerValue]);
            }
            addPoint(i,tmpCount);
            lastCount = tmpCount;
        }
    }
    if(points.count > 1){
        //step 1 draw gradient
        //reference http://stackoverflow.com/questions/2985359/how-to-fill-a-path-with-gradient-in-drawrect
        CGFloat colors[] = {
            98/255.0,192/255.0,180/255.0,1.0,
            1.0, 1.0, 1.0, 0.0,
        };
        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, nil, 2);
        CGColorSpaceRelease(baseSpace);
        CGContextSaveGState(ctx);
        CGMutablePathRef path = CGPathCreateMutable();
        
        VPoint* first = [points firstObject];
        VPoint* last = [points lastObject];
        CGPathMoveToPoint(path, &CGAffineTransformIdentity,first.x , baseLine );
        for (NSInteger i = 0; i <= points.count - 1; i++) {
            VPoint* point = [points objectAtIndex:i];
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity , point.x , point.y);
        }
        CGPathAddLineToPoint(path, &CGAffineTransformIdentity , last.x , baseLine );
        
        CGPathCloseSubpath(path);
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(realRect), CGRectGetMinY(realRect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(realRect), CGRectGetMaxY(realRect) - halfItemWidth   );
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
        CGGradientRelease(gradient);
        CGContextRestoreGState(ctx);
        CGContextAddPath(ctx, path);
        CGPathRelease(path);
        CGContextDrawPath(ctx, kCGPathStroke);
        
        //step 2 draw Line and arc
        CGContextSetLineWidth(ctx, 1);
        CGContextMoveToPoint(ctx, first.x, first.y);
        for (NSInteger i = 1; i < points.count ; i++) {
            VPoint* point = [points objectAtIndex:i];
            CGContextAddLineToPoint(ctx, point.x, point.y);
        }
        CGContextStrokePath(ctx);
        
        //step 3 draw arc and text
        for (NSInteger i = 0; i < points.count ; i++) {
            VPoint* point = [points objectAtIndex:i];
            CGContextAddArc(ctx, point.x, point.y, RADIUS, 0, 2*M_PI, 0);
            CGContextStrokePath(ctx);
            NSString *text = [NSString stringWithFormat:@"%ld份记录",point.recordCount];
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = NSTextAlignmentCenter;
            //          [text drawAtPoint:point.cgPoint withAttributes:@{NSFontAttributeName:textFont}];
            [text drawAtPoint:point.cgPoint withFont:textFont];
        }
    }
}

@end

@implementation VPoint

-(id)initWidthX:(CGFloat)x Y:(CGFloat)y RecordCount:(NSInteger)recordCount TextfffsetY:(CGFloat)offset;
{
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.recordCount = recordCount;
        self.cgPoint = CGPointMake(x+4, y - offset);
    }
    return  self;
}

@end

@interface HomeCollectionView(){
   
}

@end

@implementation HomeCollectionView


-(CGFloat)getItemWidth
{
    CGFloat width = floor((self.frame.size.height-[HomeCollectionView getMonthViewHeighet])/7.f);
    return width;
}

+(CGFloat)getMonthViewHeighet
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        return  100;
    }
    return 60.f;
}

@end

@interface HomeView() <EGORefreshTableHeaderDelegate>
{
    HomeLinearGradientView* gradienView;
    EGORefreshTableHeaderView* _PullRightRefreshView;
    EGORefreshTableHeaderView* _PullLeftRefreshView;
}
@end

@implementation HomeView

-(id)init{
    self = [super init];
    if(self){
        [self onCreate];
    }
    return  self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self onCreate];
    }
    return  self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self onCreate];
    }
    return  self;
}

-(void)addConstraintForSubView:(UIView*)subView bottomMargin:(CGFloat)marginBottom
{
    [subView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self addSubview:subView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-marginBottom]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

-(void)onCreate{
    [self setBackgroundColor:[UIColor clearColor]];
    gradienView = [[HomeLinearGradientView alloc] init];
    [self addSubview:gradienView];
    [gradienView setBackgroundColor:[UIColor clearColor]];
    self.collectionView = [[HomeCollectionView alloc] initWithFrame:self.frame collectionViewLayout:[[HomeViewLayout alloc] init]];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self addConstraintForSubView:self.collectionView bottomMargin:0];
    gradienView.collectionView = self.collectionView;
    
    _PullRightRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:self.collectionView orientation:EGOPullOrientationRight];
    _PullRightRefreshView.delegate = self;
    
    _PullLeftRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:self.collectionView orientation:EGOPullOrientationLeft];
    _PullLeftRefreshView.delegate = self;
    _PullLeftRefreshView.hidden = YES;
    _PullRightRefreshView.hidden = YES;
}

-(void)onScroll:(CGFloat)scrollX
{
    [_PullRightRefreshView egoRefreshScrollViewDidScroll:self.collectionView];
    [_PullLeftRefreshView egoRefreshScrollViewDidScroll:self.collectionView];
    [gradienView onScroll:scrollX];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    [_PullRightRefreshView egoRefreshScrollViewDidEndDragging:self.collectionView];
    [_PullLeftRefreshView egoRefreshScrollViewDidEndDragging:self.collectionView];
}

-(void)setDailyRecData:(NSArray *)dataSet
{
    [gradienView setDailyRecData:dataSet];
    _PullLeftRefreshView.hidden = NO;
    _PullRightRefreshView.hidden = NO;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view { //发现左右是反的，我靠不改了
    if(self.delegate){
        if(view == _PullLeftRefreshView){
            if([self.delegate respondsToSelector:@selector(onRightRefresh)]){
                [self.delegate onRightRefresh];
            }
        }else if(view == _PullRightRefreshView){
            if([self.delegate respondsToSelector:@selector(onLeftRefresh)]){
                [self.delegate onLeftRefresh];
            }
        }
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view { //发现左右是反的，我靠不改了
    if(self.delegate){
        if(view == _PullLeftRefreshView){
            if([self.delegate respondsToSelector:@selector(rightCanRefresh)]){
                BOOL  res = ![self.delegate rightCanRefresh];
                return res;
            }
        }else if(view == _PullRightRefreshView){
            if([self.delegate respondsToSelector:@selector(leftCanRefresh)]){
                BOOL  res = ![self.delegate leftCanRefresh];
                return res;
            }
        }
    }
    return YES;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [NSDate date];
}

-(void)refreshComplete
{
    [_PullRightRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
    [_PullLeftRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
}

-(BOOL)isLoading
{
    return [_PullLeftRefreshView isLoading] || [_PullRightRefreshView isLoading];
}


-(void)scrollToIndex:(NSInteger)index andAligment:(Alignment)aligmen
{
    if(index < 0) return;
    void (^run)( void ) = ^()
    {
        CGFloat itemWidth = [self.collectionView getItemWidth];
        CGFloat offset = index * itemWidth;
        CGFloat contentSizeWidth = self.collectionView.contentSize.width;
        CGFloat frameWidth = self.collectionView.frame.size.width;
        CGPoint offsetPoint;
        switch (aligmen) {
            case Left:
            {
                if(offset + frameWidth <= contentSizeWidth){
                    offsetPoint = CGPointMake(offset, 0);
                }else{
                    offsetPoint = CGPointMake(contentSizeWidth - frameWidth, 0);
                }
                [self.collectionView setContentOffset:offsetPoint animated:NO];
            }
                break;
            case Center:
            {
                offset += itemWidth/2.f;
                CGFloat halfWidth = frameWidth/2.f;
                if(offset < halfWidth){
                    offsetPoint = CGPointMake(0, 0);
                }else if(offset > contentSizeWidth - halfWidth){
                    offsetPoint = CGPointMake(contentSizeWidth - halfWidth, 0);
                }else{
                    offsetPoint = CGPointMake(offset - halfWidth, 0);
                }
                [self.collectionView setContentOffset:offsetPoint animated:NO];
            }
                break;
            case Right:
            {
                if(offset + itemWidth <= contentSizeWidth){
                    offsetPoint = CGPointMake(offset - frameWidth + itemWidth, 0);
                }else{
                    offsetPoint = CGPointMake(contentSizeWidth - frameWidth, 0);
                }
                [self.collectionView setContentOffset:offsetPoint animated:NO];
            }
                break;
            default:
                break;
        }
        if(self.collectionView.delegate && [self.collectionView.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
            [self.collectionView.delegate scrollViewDidEndDecelerating:self.collectionView];
        }
    };
    if(self.collectionView.contentSize.width <= self.collectionView.frame.size.width){
        [Tools Post:^{
            run();
        } Delay:.2f];
    }else{
        run();
    }
    
   
}


-(Alignment)getRefreshDirection
{
    if([_PullLeftRefreshView isLoading]){
        return Right;
    }
    if([_PullRightRefreshView isLoading]){
        return Left;
    }
    return  None;
}


@end