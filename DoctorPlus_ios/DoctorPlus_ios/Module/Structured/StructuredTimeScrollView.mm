//
//  StructuredTimeScrollView.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/24.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "StructuredTimeScrollView.h"
#include <vector>
#import "StructuredLayout.h"


typedef struct{
    int year;
    int month;
    int day;
    int startY;
    int endY;
} ItemLogicData;

@interface StructuredTimeItemView()
{
  
}

@property (nonatomic,assign ) ItemLogicData data;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthDayLabel;

@end

@implementation StructuredTimeItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [FQBaseViewController addChildViewFullInParent:[[NSBundle mainBundle] loadNibNamed:@"StructuredTimeItemView" owner:self options:nil][0] parent:self];
    }
    return self;
}

-(void)setData:(ItemLogicData)data
{
    _data = data;
    _yearLabel.text = [NSString stringWithFormat:@"%d",data.year];
    _monthDayLabel.text = [NSString stringWithFormat:@"%d/%d",data.month,data.day];
}

@end


@interface StructuredTimeScrollView()
{
    NSMutableArray* itemViews;
}
@end

@implementation StructuredTimeScrollView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.6f]];
        itemViews = [[NSMutableArray alloc] init];
        [self setScrollEnabled:NO];
    }
    return self;
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    CGFloat startY = self.contentOffset.y;
    CGFloat endY = startY + self.frame.size.height;
    for (UIView* view in self.subviews) {
        if([view isKindOfClass:[StructuredTimeItemView class]]){
            StructuredTimeItemView* item = (StructuredTimeItemView*)view;
            ItemLogicData data = item.data;
          
        }
    }
}

-(void)setData:(FQJSONArray *)data
{
    _data = data;
//    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (UIView* view in self.subviews) {
        if([view isKindOfClass:[StructuredTimeItemView class]]){
            [view removeFromSuperview];
        }
    }
    int startY = 0 , endY = 0;
    for (int i = 0; i < [_data length]; i++) {
        FQJSONObject* day = [_data optJSONObjectWithInt:i];
        endY = startY + STRUCT_CELL_HEIGTH* [day optIntWithNSString:@"maxSize"];
        ItemLogicData item = {[day optIntWithNSString:@"year"],[day optIntWithNSString:@"month"]+1,[day optIntWithNSString:@"day"],startY,endY};
        StructuredTimeItemView* itemView = [[StructuredTimeItemView alloc] initWithFrame:CGRectMake(0, startY+44, 44, STRUCT_CELL_HEIGTH)];
        itemView.data = item;
        [self addSubview:itemView];
         startY = endY;
    }
    [self setContentSize:CGSizeMake(self.frame.size.width, endY+44)];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@interface StructuredTitleView()
{
    
}
@property (weak, nonatomic) IBOutlet UIView *treatments;
@property (weak, nonatomic) IBOutlet UIView *symptoms;
@property (weak, nonatomic) IBOutlet UIView *checkups;
@property (weak, nonatomic) IBOutlet UIView *diagnosis;
@end


@implementation StructuredTitleView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"StructuredTitleView" owner:self options:nil];
        [self addSubview:_treatments];
        [self addSubview:_symptoms];
        [self addSubview:_checkups];
        [self addSubview:_diagnosis];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width/4.f;
    _symptoms.frame = CGRectMake(0, 0, width, self.frame.size.height);
    _diagnosis.frame = CGRectMake(width, 0, width, self.frame.size.height);
    _checkups.frame = CGRectMake( width*2,0, width, self.frame.size.height);
    _treatments.frame = CGRectMake(width*3,0, width, self.frame.size.height);
    
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGFloat width = rect.size.width/4.f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor grayColor] set];
    CGContextSetLineWidth(context, 1);

    CGContextMoveToPoint(context, width, 0);
    CGContextAddLineToPoint(context, width ,rect.size.height);
    CGContextMoveToPoint(context, width*2, 0);
    CGContextAddLineToPoint(context, width*2 ,rect.size.height);
    CGContextMoveToPoint(context, width*3, 0);
    CGContextAddLineToPoint(context, width*3 ,rect.size.height);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width ,rect.size.height);
    CGContextStrokePath(context);

}

@end

@implementation StructuredTitleItemView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

@end

