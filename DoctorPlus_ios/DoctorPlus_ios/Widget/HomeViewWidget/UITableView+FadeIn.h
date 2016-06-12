//
//  UITableView+FadeIn.h
//  TableViewWaveDemo
//
//  Created by 廖敏 on 15/5/26.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (FadeIn)

-(void)FadeIn:(void (^)())completion;

-(void)FadeOut:(void (^)())completion;;

@end
