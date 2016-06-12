//
//  UITableView+FadeIn.m
//  TableViewWaveDemo
//
//  Created by 廖敏 on 15/5/26.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "UITableView+FadeIn.h"
#import "Tools.h"

@implementation UITableView (FadeIn)

-(void)FadeIn:(void (^)())completion;
{
    NSArray *array = [self indexPathsForVisibleRows];
    for (int i=0 ; i < [array count]; i++) {
        NSIndexPath *path = [array objectAtIndex:i];
        [self startAnimation:path IsFadeIn:YES ];
    }
    if(completion){
        [Tools Post:^{
            completion();
        } Delay:.5f];
    }
}

-(void)FadeOut:(void (^)())completion;
{
    NSArray *array = [self indexPathsForVisibleRows];
    for (int i=0 ; i < [array count]; i++) {
        NSIndexPath *path = [array objectAtIndex:i];
        [self startAnimation:path IsFadeIn:NO ];
    }
    
    if(completion){
        [Tools Post:^{
            completion();
        } Delay:.5f];
    }
}

-(void)startAnimation:(NSIndexPath*)path IsFadeIn:(BOOL)fadeIn
{
    UITableViewCell *cell = [self cellForRowAtIndexPath:path];
    CGPoint originPoint = cell.center;
    CGPoint originPointInSuper = [self convertPoint:originPoint toView:self.superview];
    if(fadeIn){
        if(originPointInSuper.y <= self.frame.size.height/2.f)
        { //上半部分
            cell.center = CGPointMake(originPoint.x,self.contentOffset.y - cell.frame.size.height/2.f);
        }else{
            cell.center = CGPointMake(originPoint.x,self.contentOffset.y + self.frame.size.height + cell.frame.size.height/2.f);
        }
    }

    [UIView animateWithDuration:.5f animations:^{
        if(fadeIn){
            cell.center = CGPointMake(originPoint.x, originPoint.y);
        }else{
            if(originPointInSuper.y <= self.frame.size.height/2.f)
            { //上半部分
                cell.center = CGPointMake(originPoint.x,self.contentOffset.y - cell.frame.size.height/2.f);
            }else{
                cell.center = CGPointMake(originPoint.x,self.contentOffset.y + self.frame.size.height + cell.frame.size.height/2.f);
            }
        }
        
    }];
}

@end
