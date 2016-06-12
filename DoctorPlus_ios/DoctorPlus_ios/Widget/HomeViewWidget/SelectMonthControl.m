//
//  SelectMonthView.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/26.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "SelectMonthControl.h"
#import "SelectMonthViewCell.h"
#import "UITableView+FadeIn.h"
#import "java/util/Collections.h"
#import "java/util/Iterator.h"
#import "java/lang/Integer.h"
#import "java/util/ArrayList.h"
#import "UITableView+FadeIn.h"
#import "Tools.h"


@interface SelectMonthControl()
{
    id<JavaUtilMap> mMonthData;
    NSMutableArray* years;
    NSArray* monthLables;
    NSMutableDictionary* yearHeaderViews; //[section,view]
}
@end

@implementation SelectMonthControl

+(SelectMonthControl*)create:(UIView*)parent Data:(id<JavaUtilMap>)data Transparent:(BOOL)transparent
{
    SelectMonthControl* monthControl= [[SelectMonthControl alloc] init];
    monthControl->yearHeaderViews = [[NSMutableDictionary alloc] init];
    monthControl->years = [[NSMutableArray alloc] init];
    monthControl->monthLables =  @[@"一月",@"二月",@"三月",@"四月",@"五月",@"六月",@"七月",@"八月",@"九月",@"十月",@"十一月",@"十二月"];
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, parent.frame.size.width, parent.frame.size.height - 70) style:UITableViewStylePlain];
    [parent addSubview:tableView];
    tableView.backgroundColor = transparent?[UIColor clearColor]:[UIColor whiteColor];
    tableView.dataSource = monthControl;
    tableView.delegate = monthControl;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    monthControl.tableView = tableView;
    [tableView registerNib:[UINib nibWithNibName:@"SelectMonthViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SelectMonthViewCell"];
    tableView.showsVerticalScrollIndicator = NO;
    monthControl->mMonthData = data;
    if(data){
        id<JavaUtilIterator> iterator = [[data keySet] iterator];
        while ([iterator hasNext]) {
            JavaLangInteger* year = [iterator next];
            [monthControl->years addObject:[NSNumber numberWithInt:year.intValue]];
        }
        [monthControl->years sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber* num1 = (NSNumber*)obj1;
            NSNumber* num2 = (NSNumber*)obj2;
            if(num1 > num2) return NSOrderedDescending;
            if(num1 < num2) return NSOrderedAscending;
            return NSOrderedSame;
        }];
        if([data isEmpty]){
            NSDate *date = [NSDate date];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy"];
            NSString* ye = [df stringFromDate:date];
            [monthControl->years addObject:[NSNumber numberWithInt:[ye intValue]]];
        }else{
            NSNumber* last = [monthControl->years lastObject];
            int nextYear = [last intValue]+1;
            [monthControl->years addObject:[NSNumber numberWithInt:nextYear]];
        }
    }
    UIView* topView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, parent.frame.size.width, 70)];
    monthControl.topView = topView;
    UIButton* close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.frame = CGRectMake(parent.frame.size.width - 60 ,30, 30, 30);
    [close addTarget:monthControl action:@selector(onCloseClick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:close];
    [close setBackgroundImage:[UIImage imageNamed:@"btn_new_close.png"] forState:UIControlStateNormal];
    topView.backgroundColor = COLOR_EMERALD;
    [parent addSubview:topView];
    tableView.hidden = YES;
    [Tools  Post:^() {
        [tableView FadeIn:nil];
         tableView.hidden = NO;
    } Delay:0.2f];
    
    return monthControl;
}


-(void)onCloseClick:(UIButton*)sender
{
    if(self.delegate){
        [self.delegate willRemovedFromSuperView];
    }
    [self.tableView FadeOut:^{
        [self remove];
    }];
  
}


-(void)setMMonthData:(id<JavaUtilMap>)data
{
    mMonthData = data;
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSNumber* key = [NSNumber numberWithInteger:section];
    UILabel* lable = [yearHeaderViews objectForKey:key];
    if(!lable){
        lable = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 120,[self getSectionStartPointY:section], 80, 60)];
        lable.font = [UIFont systemFontOfSize:35];
        lable.textColor = COLOR_EMERALD;
        int year = [[years objectAtIndex:section] intValue];
        lable.text = [NSString stringWithFormat:@"%d",year];
        [tableView addSubview:lable];
        [yearHeaderViews setObject:lable forKey:key];
    }
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    headerView.backgroundColor = [UIColor grayColor];
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return years?[years count]:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

-(BOOL)havaDataAtIndexPath:(NSIndexPath *)indexPath
{
    int year = [[years objectAtIndex:indexPath.section] intValue];
    JavaLangInteger* javaYear = [[JavaLangInteger alloc] initWithInt:year];
    JavaUtilArrayList* list = [mMonthData getWithId:javaYear];
    if(list && [list containsWithId:[[JavaLangInteger alloc] initWithInt:indexPath.row + 1]]){
        return true;
    }
    return false;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectMonthViewCell";
    SelectMonthViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.Lable.text = [monthLables objectAtIndex:indexPath.row];
    cell.Lable.textColor = [UIColor lightGrayColor];
    if([self havaDataAtIndexPath:indexPath]){
         cell.Lable.textColor = [UIColor blackColor];
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:.66f green:.66f  blue:.66f  alpha:.44f ];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.delegate && [self havaDataAtIndexPath:indexPath]){
        if([self.delegate respondsToSelector:@selector(didSelectedYear:andMonth:)]){
            NSInteger year = [[years objectAtIndex:indexPath.section] integerValue];
            NSInteger month = indexPath.row + 1;
            [self.delegate didSelectedYear:year andMonth:month];
        }
    }
    if(self.delegate){
        [self.delegate willRemovedFromSuperView];
    }
    [self.tableView FadeOut:^{
        [self remove];
    }];
}

-(CGFloat)getSectionStartPointY:(NSInteger)section{
    NSInteger oneSectionHeight = 50*12+1;
    return oneSectionHeight*section;
}

-(CGFloat)getSectionEndPointY:(NSInteger)section{
    NSInteger oneSectionHeight = 50*12+1;
    return oneSectionHeight*(section+1);

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray* keys = [yearHeaderViews allKeys];
    for (NSInteger i = 0 ; i < keys.count ; i++) {
        NSNumber* key = [keys objectAtIndex:i];
        NSInteger section = [key integerValue];
        UILabel* lable = [yearHeaderViews objectForKey:key];
        if(lable){
            //重置位置
            NSInteger startY = [self getSectionStartPointY:section];
            NSInteger endY = [self getSectionEndPointY:section] - lable.frame.size.height;
            CGFloat offSetStartY = scrollView.contentOffset.y;
            CGFloat offSetEndY = offSetStartY + scrollView.frame.size.height;
            if(startY < offSetStartY){
                if(offSetStartY < endY){
                    lable.frame = CGRectMake(scrollView.frame.size.width - 120,offSetStartY,80,60);
                }else{
                    lable.frame = CGRectMake(scrollView.frame.size.width - 120,endY,80,60);
                }
            }else{
                lable.frame = CGRectMake(scrollView.frame.size.width - 120,startY,80,60);
            }
            if(startY > offSetEndY || [self getSectionStartPointY:section +1] < offSetStartY){ //越界移除
                [lable removeFromSuperview];
                [yearHeaderViews removeObjectForKey:key];
            }
        }
    }
}


-(void)remove{
    [self.tableView removeFromSuperview];
    [self.topView removeFromSuperview];
    if(self.delegate){
        [self.delegate didRemovedFromSuperView];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
