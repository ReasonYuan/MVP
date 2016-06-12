//
//  ChartView.h
//  TestProject
//
//  Created by 廖敏 on 15/7/15.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChartView;


typedef NS_ENUM(NSInteger, ChartViewAlignment) {
    AlignmentLeft      = 0,
    AlignmentCenter    = 1,
    AlignmentRight     = 2,
};

typedef NS_ENUM(NSInteger, ChartViewRefreshDirection) {
    DirectionLeft      = 0,
    DirectionRight    = 1
};

/**
 *ChartView事件处理的回调
 */
@protocol ChartViewDelegate <NSObject>

/**
 *左右边是否能滑动
 */
-(BOOL)chartView:(ChartView*)view canRefresh:(ChartViewRefreshDirection)direction;

/**
*左右是否正在滑动
*/
-(void)chartView:(ChartView*)view onRefresh:(ChartViewRefreshDirection)direction;

@optional

/**
 *ChartView事件处理的回调
 */
-(void)chartView:(ChartView*)view didClickedAtIndex:(NSInteger)index;

/**
 *每个cell的宽度，不要去重载，还没测试
 */
-(CGFloat)chartView:(ChartView*)view cellWithForIndex:(NSInteger)index;

/**
 *
 */
-(void)chartView:(ChartView*)view firstCellShowIndex:(NSInteger)index;

/**
 *是否更改园的颜色
 */
-(BOOL)chartView:(ChartView*)view changeCicleColor:(NSInteger)index;


/**
 *特殊点得颜色
 */
-(UIColor*)chartViewCicleColor:(ChartView*)view ;

/**
 *弹出框的颜色
 */
-(UIColor*)chartView:(ChartView*)view toastColor:(NSInteger)index;

/**
 *弹出框的文字
 */
-(NSString*)chartView:(ChartView*)view toastText:(NSInteger)index;

/**
 *是否是今天
 */
-(BOOL)chartView:(ChartView*)view isTodayIndex:(NSInteger)index;

@end


/**
 *ChartView的数据源
 */
@protocol ChartViewDataSource <NSObject>
@required
-(NSInteger)numberOfCellInChartView:(ChartView*)chartView;//有多少条数据
-(CGFloat)chartView:(ChartView*)view dataForIndex:(NSInteger)index;//每个cell的数据
-(NSString*)chartView:(ChartView*)view titleForCell:(NSInteger)index;//底部显示的文字
@optional
-(NSInteger)chartView:(ChartView*)view number:(NSInteger)index;//cell的宽度
@end

@interface ChartView : UIView


@property (weak,nonatomic) id<ChartViewDelegate> chartDelegate;//事件代理

@property (weak,nonatomic) id<ChartViewDataSource> chartDataSource;//数据源

@property (strong,nonatomic) UIColor* strokeColor;//填充色

@property (strong,nonatomic) UIFont* titleFont;//title字体

@property (nonatomic,assign) BOOL isShowUnit;

@property (strong,nonatomic) UIColor* lineColor;// 线条充色

@property (strong,nonatomic) UIColor* textColor;

-(void)reloadData;//数据发生变化，重新填充数据

-(void)moveToIndex:(NSInteger)index ChartViewAlignment:(ChartViewAlignment)alignment;

-(void)refreshCompleted;

-(BOOL)isRefresh;

/**
 *一页显示多少条数据，iPhone固定7
 */
-(NSInteger)cellCountOnePage;

-(void)showLoading;

-(void)selected:(NSInteger)index;//选中第几列

@end
