//
//  CropView.m
//  MMCamScanner
//
//  Created by 廖敏 on 15/7/28.
//  Copyright (c) 2015年 madapps. All rights reserved.
//

#import "CropView.h"


@interface CropViewItem : UIView

@property(nonatomic,assign)NSInteger type;

@end


@implementation CropViewItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        
        CGContextSetLineWidth(context, 4.0f);
        [[UIColor blueColor] set];
        switch (self.type) {
            case 0: //left top
            {
                CGContextMoveToPoint(context, rect.size.width, 0);
                CGContextAddLineToPoint(context, 0, 0);
                CGContextAddLineToPoint(context, 0, rect.size.height);
            }
                break;
            case 1://right top
            {
                CGContextMoveToPoint(context, 0, 0);
                CGContextAddLineToPoint(context, rect.size.width, 0);
                CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
            }
                break;
            case 2://left bottom
            {
                CGContextMoveToPoint(context, 0, 0);
                CGContextAddLineToPoint(context, 0, rect.size.height);
                CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
            }
                break;
            case 3://right bottom
            {
                CGContextMoveToPoint(context, rect.size.width, 0);
                CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
                CGContextAddLineToPoint(context, 0, rect.size.height);
            }
                break;
            default:
                break;
        }
        
        CGContextStrokePath(context);
    }
}

@end


@interface CropView()
{
    CropViewItem* rt;
    CropViewItem* lt;
    CropViewItem* rb;
    CropViewItem* lb;
}

@end

#define kCropButtonSize 30

@implementation CropView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self onCreate:frame];
    }
    return self;
}

-(void)onCreate:(CGRect)frame
{
    NSInteger width = CGRectGetWidth(frame) / 4.f;
    lt = [[CropViewItem alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    rt = [[CropViewItem alloc] initWithFrame:CGRectMake(frame.size.width - width, 0, width, width)];
    lb = [[CropViewItem alloc] initWithFrame:CGRectMake(0, frame.size.height - width, width, width)];
    rb = [[CropViewItem alloc] initWithFrame:CGRectMake(frame.size.width - width, frame.size.height - width, width, width)];
    [self addSubview:rt];
    [self addSubview:lt];
    [self addSubview:rb];
    [self addSubview:lb];
    lt.type = 0;
    rt.type = 1;
    lb.type = 2;
    rb.type = 3;
    [self setBackgroundColor:[UIColor clearColor]];

}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        [self onCreate:frame];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    NSInteger width = CGRectGetWidth(frame) / 4.f;
    lt.frame = CGRectMake(0, 0, width, width);
    rt.frame = CGRectMake(frame.size.width - width, 0, width, width);
    lb.frame = CGRectMake(0, frame.size.height - width, width, width);
    rb.frame = CGRectMake(frame.size.width - width, frame.size.height - width, width, width);
    

}

@end
