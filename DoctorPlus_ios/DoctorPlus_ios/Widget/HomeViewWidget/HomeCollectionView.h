//
//  HomeCollectionView.h
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VPoint : NSObject

@property (assign,nonatomic) CGFloat x;

@property (assign,nonatomic) CGFloat y;

@property (assign,nonatomic) NSInteger recordCount;

@property (nonatomic) CGPoint cgPoint;

-(id)initWidthX:(CGFloat)x Y:(CGFloat)y RecordCount:(NSInteger)recordCount TextfffsetY:(CGFloat)offset;

@end


@interface HomeCollectionView : UICollectionView

-(CGFloat)getItemWidth;

+(CGFloat)getMonthViewHeighet;

@end


@interface HomeLinearGradientView : UIView

@property (weak,nonatomic)HomeCollectionView* collectionView;

@end


@protocol HomeViewDelegate <NSObject>

-(BOOL)leftCanRefresh;

-(BOOL)rightCanRefresh;

-(void)onLeftRefresh;

-(void)onRightRefresh;

@end

typedef NS_ENUM(NSInteger, Alignment) {
    Left      = 0,
    Center    = 1,
    Right     = 2,
    None      = -1,
};



@interface HomeView : UIView


-(void)setDailyRecData:(NSArray*)data;

-(void)onScroll:(CGFloat)scrollX;

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView;

-(void)refreshComplete;

-(BOOL)isLoading;

-(Alignment)getRefreshDirection;

-(void)scrollToIndex:(NSInteger)index andAligment:(Alignment)aligmen;

@property (weak, nonatomic) id<HomeViewDelegate> delegate;

@property (strong,nonatomic) HomeCollectionView* collectionView;

@end