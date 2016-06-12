//
//  StructuredCell.h
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/23.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, StructuredCellStyle) {
    Cicle = 0,
    Oval = 1,
    Triangle = 2,
    Square = 3,
};

/*
 *结构化表的最小组件
 */
@interface StructuredCell : UICollectionViewCell

@property (nonatomic,assign) StructuredCellStyle cellStyle;

@property (nonatomic,strong) NSString* text;

@property (nonatomic,strong) UIColor* textColor;

@property (nonatomic,strong) UIFont* textFont;

@property (nonatomic,strong) UIColor* strokeColor;

@property (nonatomic,assign) BOOL showMore;

@property (nonatomic,assign) BOOL empty;

@property (nonatomic,assign) NSInteger index;

@property (nonatomic,assign) BOOL discharge;

@property (nonatomic,assign) NSInteger row;

-(void)reset;

@end