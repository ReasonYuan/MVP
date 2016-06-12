//
//  HeadView.m
//  Test04
//
//  Created by HuHongbing on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HeadView.h"

@implementation HeadView
@synthesize delegate = _delegate;
@synthesize section,open,backBtn;

- (id)initWithFrame:(CGRect)frame
{
    NSInteger screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self = [super initWithFrame:frame];
    if (self) {
        open = NO;
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, screenWidth, 45.5);
        [btn addTarget:self action:@selector(doSelected) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:btn];
        UIImageView* line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 45.5, [[UIScreen mainScreen] bounds].size.width, 0.5)];
        line.backgroundColor = [UIColor grayColor];
        [self addSubview:line];
        self.backBtn = btn;
    }
    return self;
}

-(void)doSelected{
    if (_delegate && [_delegate respondsToSelector:@selector(selectedWith:)]){
     	[_delegate selectedWith:self];
    }
}
@end
