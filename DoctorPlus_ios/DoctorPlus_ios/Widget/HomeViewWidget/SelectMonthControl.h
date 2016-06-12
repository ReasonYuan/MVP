//
//  SelectMonthView.h
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/26.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "java/util/map.h"

@protocol SelectMonthControlDelegate <NSObject>

@required

-(void)didSelectedYear:(NSInteger)year andMonth:(NSInteger)month;

-(void)didRemovedFromSuperView;

-(void)willRemovedFromSuperView;

@end

@interface SelectMonthControl : NSObject <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;

@property (weak, nonatomic) UIView *topView;

@property (weak, nonatomic) id<SelectMonthControlDelegate> delegate;


-(void)setMMonthData:(id<JavaUtilMap>)data;


+(SelectMonthControl*)create:(UIView*)parent Data:(id<JavaUtilMap>) data Transparent:(BOOL)transparent;


@end
