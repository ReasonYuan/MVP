//
//  StructuredCell.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/23.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "StructuredCell.h"

@interface StructuredCell()
{
    UILabel *lable;
    CGFloat prefixWidth;
    
}
@end

@implementation StructuredCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self onCreate];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self onCreate];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self onCreate];
    }
    return self;
}

-(void)onCreate
{
    lable = [[UILabel alloc] init];
    [self addSubview:lable];
    lable.text = @"dddd";
    _strokeColor = [UIColor blueColor];
    lable.textColor = [UIColor grayColor];
    lable.font = [UIFont systemFontOfSize:12];
    _cellStyle = Oval;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if(isPad){
        prefixWidth = self.frame.size.width / 8.f;
    }else{
        prefixWidth = self.frame.size.width / 6.f;
    }
    lable.frame = CGRectMake(prefixWidth+2, 2, self.frame.size.width - prefixWidth - 4, self.frame.size.height - 4);
}

-(void)setEmpty:(BOOL)empty
{
    _empty = empty;
    lable.hidden = _empty;
}

-(UIColor*)textColor
{
    return lable.textColor;
}

-(void)setTextColor:(UIColor *)textColor
{
    lable.textColor = textColor;
}

-(UIFont*)textFont
{
    return lable.font;
}

-(void)setTextFont:(UIFont *)textFont
{
    lable.font = textFont;
}

-(void)setText:(NSString *)text
{
    lable.text = text;
}

-(void)setCellStyle:(StructuredCellStyle)cellStyle
{
    _cellStyle = cellStyle;
    [self setNeedsDisplay];
}

-(void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    [self setNeedsDisplay];
}

-(UIColor *) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

static NSMutableDictionary* colors;

-(void)setIndex:(NSInteger)index
{
    if(colors == nil) colors = [[NSMutableDictionary alloc] init];
    NSNumber* key = [NSNumber numberWithInteger:index];
    UIColor* color = [colors objectForKey:key];
    if(!color){
        color = [self randomColor];
        [colors setObject:color forKey:color];
    }
    _index = index;
    self.strokeColor = color;
}

-(void)dealloc
{
    colors = nil;
}

-(void)reset
{
    self.empty = YES;
    self.discharge = NO;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_strokeColor set];
    if(!_empty){
        CGPoint center = CGPointMake(prefixWidth/2.f, CGRectGetMidY(rect));
        switch (self.cellStyle) {
            case Cicle:
            {
                CGContextMoveToPoint(context, center.x, center.y);
                CGContextAddArc(context, center.x, center.y, prefixWidth/2.f - 2, 0, 2*M_PI, 0);
                break;
            }
            case Oval:
            {
                CGFloat heigth = prefixWidth-4;
                CGFloat width = heigth/3.f;
                CGFloat halfWidth = width / 2.f;
                CGFloat halfHeigth = heigth / 2.f;
                CGContextMoveToPoint(context,center.x - halfWidth, center.y - halfHeigth);
                CGContextAddArc(context,center.x, center.y - halfHeigth, halfWidth, M_PI, 0, 0);
                CGContextAddLineToPoint(context,center.x + halfWidth, center.y + halfHeigth);
                CGContextAddArc(context,  center.x, center.y + halfHeigth, halfWidth, 0, M_PI, 0);
                CGContextAddLineToPoint(context,center.x - halfWidth, center.y - halfHeigth);
                break;
            }
            case Triangle:
            {
                CGFloat radius = prefixWidth/2.f - 2;
                CGFloat offsetX = radius*cosf(M_PI/6.f);
                CGPoint top = CGPointMake(center.x, center.y-radius/2.f);
                CGPoint left = CGPointMake(center.x-offsetX, center.y+radius/2.f);
                CGPoint right = CGPointMake(center.x+offsetX, center.y+radius/2.f);
                CGContextMoveToPoint(context, top.x, top.y);
                CGContextAddLineToPoint(context, left.x, left.y);
                CGContextAddLineToPoint(context, right.x, right.y);
                CGContextAddLineToPoint(context, top.x, top.y);
                break;
            }
            case Square:
            {
                CGFloat width = prefixWidth-4;
                CGFloat halfWidth = width / 2.f;
                CGContextMoveToPoint(context, center.x - halfWidth, center.y - halfWidth);
                CGContextAddLineToPoint(context, center.x - halfWidth, center.y + halfWidth);
                CGContextAddLineToPoint(context, center.x + halfWidth, center.y + halfWidth);
                CGContextAddLineToPoint(context, center.x + halfWidth, center.y - halfWidth);
                CGContextAddLineToPoint(context, center.x - halfWidth, center.y - halfWidth);
                break;
            }
            default:
                break;
        }
        CGContextDrawPath(context, kCGPathFill);
    }
   
    if(self.discharge){
        [[UIColor blackColor] set];
        CGContextSetLineWidth(context, 2);
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, rect.size.width, 0);
        CGContextStrokePath(context);
        if(self.row == 0){
            NSString* discharge = @"出院";
            [discharge drawAtPoint:CGPointMake(0, 0) withAttributes:nil];
        }
    }
    
    [[UIColor grayColor] set];
    CGFloat lengths[] = {3,3};
    CGContextSetLineDash(context, 0, lengths,2);
    
    CGContextMoveToPoint(context, rect.size.width, 0);
    CGContextAddLineToPoint(context, rect.size.width ,rect.size.height);
    CGContextAddLineToPoint(context, 0 , rect.size.height);
    CGContextStrokePath(context);
    
   
}



@end

